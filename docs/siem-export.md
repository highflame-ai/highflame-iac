# Export Highflame events to a SIEM (single-tenant installs)

On an on-prem or air-gapped Highflame stack, the Highflame Collector can send events to Splunk, Datadog or any OTLP endpoint alongside the ClickHouse path that feeds Studio. This needs configuration only, with no code change and no image rebuild.

This is the single-tenant case of [ADR 0047](https://github.com/highflame-ai/highflame-architecture/blob/main/adrs/0047-alerting-and-siem-egress.md) (D11). Shared SaaS uses the egress service instead.

## What you get, and what you don't

| | Supported here |
|---|---|
| Splunk HEC | Yes. Each span arrives as one HEC event. |
| Any OTLP endpoint (Elastic, Grafana, a Datadog Agent's OTLP intake, …) | Yes, through `otlphttp`. |
| Datadog | Yes, but the `datadog` exporter sends **APM traces**, not Cloud SIEM logs. |
| Email, Slack, PagerDuty, plain JSON webhooks | **No.** The Collector has no exporters for these, and no dedup, rate limits or per-policy routing. Alert from the SIEM instead (Splunk alerts, Datadog monitors), or run the egress service (ADR 0047). |

Events arrive in OpenTelemetry shape: span name, `service.name`, and `hf.*` attributes such as `hf.decision`, `hf.event_type`, `hf.highest_severity` and `hf.determining_policies`. They are not OCSF, so map fields in the SIEM.

**Searching in the SIEM:**
- **Alert and monitor mode.** When a policy runs in alert or monitor mode, Shield sends `hf.decision=allow` even when Cedar denied. The real outcome is in `hf.actual_decision`, and `hf.alerted="true"` marks an alert. Search on `hf.actual_decision` (falling back to `hf.decision`) or on `hf.alerted`, not on `hf.decision` alone, or you will miss exactly the events alert mode exists for.
- **Multi-value attributes.** `hf.determining_policies` and `hf.signal_vulns` are comma-separated strings, not arrays. Split them in the SIEM.

## How it works

The `highflame-collector` image is built `FROM otel/opentelemetry-collector-contrib:0.146.1` and bakes its own `config.yaml`. You add a second file, `siem.yaml`, and start the Collector with both:

```
--config=/etc/otelcol-contrib/config.yaml --config=/etc/otelcol-contrib/siem.yaml
```

The Collector merges the second file onto the first. `siem.yaml` only adds an exporter, a few processors and a new `traces/siem` pipeline, so it never copies the base config and can't drift from it.

The new pipeline has its own queue, but it shares the Collector's memory and its `memory_limiter` with the ClickHouse pipeline. Once process memory passes the limit, the Collector refuses incoming spans for **both** pipelines.

That is why the queue below is capped in bytes (`sizer: bytes`) at a small fraction of the limit:
- **If the SIEM is down,** its exporter retries, its queue fills up to the cap, and it drops further SIEM events (the log says `queue is full`). Studio's data keeps flowing.
- **Without the cap,** a long SIEM outage fills memory and the Collector starts refusing data for ClickHouse too. In testing, Studio lost 63% of events.
- **Keep `queue_size` well under the `memory_limiter`'s `limit_mib`.** 32 MiB suits the air-gapped config's 256 MiB limit. Raise it only if you also raise the limit and the pod's memory.
- **The queue is in memory,** so a Collector restart loses whatever is still waiting for the SIEM.

## 1. Write `siem.yaml`

```yaml
# Adds a SIEM export next to Highflame's ClickHouse pipeline.
# Loaded as a second --config; merges onto the image's config.yaml.
processors:
  resource/siem:
    attributes:
      - { key: host.name, action: delete }
      - { key: os.type, action: delete }
  attributes/siem:
    actions:
      - { key: hf.payload, action: delete }
  filter/siem:
    error_mode: ignore
    traces:
      span:
        - 'attributes["hf.decision"] == nil'

exporters:
  splunk_hec:
    endpoint: ${env:SPLUNK_HEC_ENDPOINT}
    token: ${env:SPLUNK_HEC_TOKEN}
    source: highflame
    sourcetype: highflame:otel
    index: ${env:SPLUNK_HEC_INDEX}
    # 32 MiB cap: a stalled SIEM drops its own events instead of starving ClickHouse
    sending_queue: { enabled: true, sizer: bytes, queue_size: 33554432 }
    retry_on_failure: { enabled: true, max_elapsed_time: 300s }

service:
  pipelines:
    traces/siem:
      receivers: [otlp]
      processors: [memory_limiter, resource/siem, attributes/siem, filter/siem, batch]
      exporters: [splunk_hec]
```

What each processor does:

| Processor | Effect | Change it when |
|---|---|---|
| `resource/siem` | Removes `host.name` and `os.type` that a sending service set on its own resource, so your SIEM doesn't see the hosts Highflame runs on. The Collector doesn't add its own host here, because `resourcedetection` runs only in the base pipeline. | You want the sending host in the SIEM. Delete this processor from the pipeline. |
| `attributes/siem` | Removes `hf.payload`: prompt and tool content, already redacted when a secret or PII was found. | Your SOC needs the content. Delete this processor from the pipeline. |
| `filter/siem` | Drops spans with no `hf.decision`, keeping enforcement decisions and leaving out plumbing spans. | You want every span. Delete this processor from the pipeline. |

**Other destinations:** replace the `exporters:` block and the pipeline's `exporters:` list, and keep the processors.

```yaml
# Any OTLP endpoint
exporters:
  otlphttp/siem:
    endpoint: ${env:SIEM_OTLP_ENDPOINT}
    headers: { Authorization: "Bearer ${env:SIEM_OTLP_TOKEN}" }
    sending_queue: { enabled: true, sizer: bytes, queue_size: 33554432 }
    retry_on_failure: { enabled: true, max_elapsed_time: 300s }
# pipeline: exporters: [otlphttp/siem]

# Datadog APM (traces, not Cloud SIEM)
exporters:
  datadog:
    api: { key: "${env:DD_API_KEY}", site: "${env:DD_SITE}" }
    sending_queue: { enabled: true, sizer: bytes, queue_size: 33554432 }
# pipeline: exporters: [datadog]
```

## 2a. Air-gapped Docker Compose (`airgap-eval/`)

1. Save the file as `airgap-eval/config/collector/siem.yaml`.
2. Add the variables to `airgap-eval/.env`:

   ```
   SPLUNK_HEC_ENDPOINT=https://splunk.example.com:8088/services/collector
   SPLUNK_HEC_TOKEN=<HEC token>
   SPLUNK_HEC_INDEX=highflame
   ```

3. In `docker-compose.yaml`, extend the `highflame-collector` service:

   ```yaml
   highflame-collector:
     # ...existing settings...
     command:
       - --config=/etc/otelcol-contrib/config.yaml
       - --config=/etc/otelcol-contrib/siem.yaml
     environment:
       # ...existing CLICKHOUSE_* entries...
       SPLUNK_HEC_ENDPOINT: ${SPLUNK_HEC_ENDPOINT}
       SPLUNK_HEC_TOKEN: ${SPLUNK_HEC_TOKEN}
       SPLUNK_HEC_INDEX: ${SPLUNK_HEC_INDEX:-highflame}
     volumes:
       - ./config/collector/config.yaml:/etc/otelcol-contrib/config.yaml:ro
       - ./config/collector/siem.yaml:/etc/otelcol-contrib/siem.yaml:ro
   ```

4. Recreate the service with `docker compose up -d highflame-collector`.

## 2b. Kubernetes (Helm)

Add the following to your Collector values file, for example `helm-values/EKS/highflame-collector-helm-values-tmpl.yml`. Paste the `siem.yaml` from step 1 under `configFile`, indented.

```yaml
secrets:
  enabled: true
  secretData:
    # ...existing entries...
    SPLUNK_HEC_ENDPOINT: https://splunk.example.com:8088/services/collector
    SPLUNK_HEC_TOKEN: <HEC token>
    SPLUNK_HEC_INDEX: highflame

configfiles:
  enabled: true
  configFile:
    siem.yaml: |-
      processors:
        resource/siem:
      # ...the rest of siem.yaml...

volumes:
  - name: siem-config
    configMap:
      name: highflame-collector-file   # <fullnameOverride>-file
volumeMounts:
  - name: siem-config
    mountPath: /etc/otelcol-contrib/siem.yaml
    subPath: siem.yaml                 # mount the one file; a directory mount would hide the baked config.yaml
    readOnly: true

entrypoint:
  enabled: true
  args:
    - --config=/etc/otelcol-contrib/config.yaml
    - --config=/etc/otelcol-contrib/siem.yaml
```

Then `helm upgrade` the release.
- A `subPath` mount doesn't pick up ConfigMap edits on its own. After changing `siem.yaml`, run `kubectl rollout restart deployment/highflame-collector`.
- `entrypoint.args` replaces the image's default `CMD` and keeps its entrypoint (`/otelcol-contrib`), so list both `--config` flags.

## 3. Verify

1. **Validate the merged config before rolling it out.** Use the same contrib version as the image, and set the env vars both files reference (dummy values are fine):

   ```bash
   docker run --rm -v "$PWD:/cfg" \
     -e CLICKHOUSE_ENDPOINT=tcp://x:9000 -e CLICKHOUSE_USER=u -e CLICKHOUSE_PASSWORD=p -e CLICKHOUSE_DATABASE=d \
     -e SPLUNK_HEC_ENDPOINT=https://x -e SPLUNK_HEC_TOKEN=t -e SPLUNK_HEC_INDEX=i \
     otel/opentelemetry-collector-contrib:0.146.1 validate \
     --config=/cfg/config.yaml --config=/cfg/siem.yaml
   ```

2. **Check the Collector started.** In its logs, `Everything is ready` means it did.
   - Repeated `Exporting failed. Will retry` lines from `splunk_hec` mean the endpoint, token or network is wrong.
   - `queue is full` means the SIEM queue hit its cap and SIEM events are being dropped. Studio's data is unaffected.
   - `memory usage is above` from `memory_limiter` means the Collector is refusing data for every pipeline, ClickHouse included. Lower the SIEM `queue_size` or raise the memory limit.
3. **Check Splunk.** After a request that Shield allows or denies, search `index=highflame sourcetype="highflame:otel"`. Each event's `name` is the span name, its attributes carry `hf.*`, and `service.name` arrives as an indexed field.

Tested with contrib 0.146.1 (`highflame-collector` 0.0.9 base), the `airgap-eval` Collector config (256 MiB `memory_limiter`), ClickHouse 25.3 and a stub HEC endpoint:
- **2026-10-22.** Splunk received only the decision span, with `hf.payload` removed, the `Authorization: Splunk <token>` header, and the configured index and sourcetype. (The test span carried no `host.name`, so that deletion wasn't exercised.) ClickHouse received every span unchanged.
- **2026-10-24, SIEM outage.** 150,000 decision spans were sent while the HEC endpoint was down:
  - With the earlier `queue_size: 5000` (counted in batches), the `memory_limiter` refused 95 of 150 requests and ClickHouse got 55,000 rows.
  - With the 32 MiB byte cap, nothing was refused and ClickHouse got all 150,000. Only the SIEM queue dropped events.
- The OTLP and Datadog variants passed `validate`, but haven't been run against a live endpoint.
