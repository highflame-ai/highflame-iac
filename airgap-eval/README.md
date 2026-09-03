# Highflame — air-gapped evaluation stack

The whole Highflame platform on one machine, with **Docker and Python 3 as the only
dependency**. No Kubernetes, no Helm, no cloud account, no Highflame tenant, and
no internet at runtime.

---

[Read the Deployment docs here](https://docs.highflame.ai/docs/deployment/poc)

## Prove it cannot phone home

This is the part worth doing yourself rather than taking on trust.

```bash
./verify/no-egress.sh --report egress-report.txt
```

It checks, and prints raw evidence for, each of:

1. The application network is `internal` — no gateway, structurally
2. Only nginx and the AI gateway are attached to an externally-routable network
3. A container on the app network **cannot** open an outbound connection (tried,
   not assumed)
4. No running container holds a connection to a Highflame-operated or analytics
   endpoint
5. No Highflame-operated host appears anywhere in the resolved configuration —
   including the detector model endpoints
6. The one permitted egress points at _your_ LLM, and it prints the value so you
   can confirm it

A check it cannot complete is reported as **WARN / unproven**, never as a pass.
The report is plain text, meant to be attached to your own review.

To go further: run it with the host's uplink physically removed, or with
`iptables` logging on. The stack is designed to behave identically.

---

## Evaluate it end to end — via the notebook

`notebook/` contains a Jupyter notebook that authenticates through Keycloak,
points an agent at `http://highflame.local/gateway/v1`, and walks through the
tenancy authorisation gate, gateway inspection, PII detection and the resulting
telemetry — all against this stack, with no internet.

The notebook is the intended interface for this evaluation, not a convenience
wrapper around the UI. See the Studio limitation under "Known limitations": the
dashboard does not render on an OIDC build yet, so the API and gateway are what
there is to evaluate. For a technical assessment of how the platform deploys,
authorises and enforces, that is arguably the more useful surface anyway — but it
is a limitation, not a design preference, and it is stated as one.

---

## Support

There is no phone-home, so nothing tells us how this is going. Send
`egress-report.txt`, `docker compose logs`, and what you were doing.
