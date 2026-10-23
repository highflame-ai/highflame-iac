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

## How it works

The `highflame-collector` image is built `FROM otel/opentelemetry-collector-contrib:0.146.1` and bakes its own `config.yaml`. You add a second file, `siem.yaml`, and start the Collector with both:

```
--config=/etc/otelcol-contrib/config.yaml --config=/etc/otelcol-contrib/siem.yaml
```

The Collector merges the second file onto the first. `siem.yaml` only adds an exporter, a few processors and a new `traces/siem` pipeline, so it never copies the base config and can't drift from it.

The new pipeline has its own queue:
- If the SIEM is down, its exporter retries and then drops. Studio's data keeps flowing.
- The queue is in memory, so a Collector restart loses whatever is still waiting for the SIEM.

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
    sending_queue: { enabled: true, queue_size: 5000 }
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
| `resource/siem` | Removes the Collector host's name and OS, so your SIEM doesn't see Highflame's infrastructure. | Never needed. |
| `attributes/siem` | Removes `hf.payload`: prompt and tool content, already redacted when a secret or PII was found. | Your SOC needs the content. Delete this processor from the pipeline. |
| `filter/siem` | Drops spans with no `hf.decision`, keeping enforcement decisions and leaving out plumbing spans. | You want every span. Delete this processor from the pipeline. |

**Other destinations:** replace the `exporters:` block and the pipeline's `exporters:` list, and keep the processors.

```yaml
# Any OTLP endpoint
exporters:
  otlphttp/siem:
    endpoint: ${env:SIEM_OTLP_ENDPOINT}
    headers: { Authorization: "Bearer ${env:SIEM_OTLP_TOKEN}" }
    sending_queue: { enabled: true, queue_size: 5000 }
    retry_on_failure: { enabled: true, max_elapsed_time: 300s }
# pipeline: exporters: [otlphttp/siem]

# Datadog APM (traces, not Cloud SIEM)
exporters:
  datadog:
    api: { key: "${env:DD_API_KEY}", site: "${env:DD_SITE}" }
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
     -e CLICKHOUSE_ENDPOINT=tcp://x:9000 -e SPLUNK_HEC_ENDPOINT=https://x -e SPLUNK_HEC_TOKEN=t -e SPLUNK_HEC_INDEX=i \
     otel/opentelemetry-collector-contrib:0.146.1 validate \
     --config=/cfg/config.yaml --config=/cfg/siem.yaml
   ```

2. **Check the Collector started.** In its logs, `Everything is ready` means it did. Repeated `Exporting failed. Will retry` lines from `splunk_hec` mean the endpoint, token or network is wrong. Studio data is unaffected either way.
3. **Check Splunk.** After a request that Shield allows or denies, search `index=highflame sourcetype="highflame:otel"`. Each event's `name` is the span name, its attributes carry `hf.*`, and `service.name` arrives as an indexed field.

Tested 2026-10-22 with contrib 0.146.1 (`highflame-collector` 0.0.9 base), the `airgap-eval` Collector config, ClickHouse 25.3 and a stub HEC endpoint:
- Splunk received only the decision span, with `hf.payload` and the host name removed, the `Authorization: Splunk <token>` header, and the configured index and sourcetype.
- ClickHouse received every span unchanged.
- With the HEC endpoint down, `splunk_hec` retried while ClickHouse kept receiving.
- The OTLP and Datadog variants passed `validate`, but haven't been run against a live endpoint.
