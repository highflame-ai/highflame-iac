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
points an agent at this stack's gateway, and walks through the
tenancy authorisation gate, gateway inspection, PII detection and the resulting
telemetry — all against this stack, with no internet.

The notebook is the intended interface for this evaluation, not a convenience
wrapper around the UI. See the Studio limitation under "Known limitations": the
dashboard does not render on an OIDC build yet, so the API and gateway are what
there is to evaluate. For a technical assessment of how the platform deploys,
authorises and enforces, that is arguably the more useful surface anyway — but it
is a limitation, not a design preference, and it is stated as one.

---

## Point the SDK at it

The SDK reaches this stack over four values:

```bash
HIGHFLAME_BASE_URL=http://highflame.local      # Shield: guard and detect
HIGHFLAME_IDENTITY_URL=http://highflame.local  # AuthN: agent registration
HIGHFLAME_TOKEN_URL=http://highflame.local/oauth2/token
HIGHFLAME_API_KEY=zid_sk_...                   # a service key, minted below
```

Set `HIGHFLAME_TOKEN_URL` yourself. The SDK defaults it to the hosted service,
and an unset value is the one mistake here that fails with a confusing
authentication error rather than a connection error.

Mint the key with `POST /v1/admin/service-keys`, the way the notebook does.
Studio's API key screen is part of the dashboard that does not render on an OIDC
build.

### Two limits, stated up front

**The ingress publishes AuthN's token endpoint and its agent-registry routes,
and nothing else.** Those are the only identity routes that accept a bearer
token, which is all an SDK caller holds. AuthN's remaining admin routes are
gated on a secret that the services share over the internal network, so
publishing them would add attack surface that no SDK caller could use. Agent
registration, delegation and the guard path all work. The identity admin
namespaces answer 404 through this ingress.

**`tokens.verify()` does not work here.** The SDK builds its key-set URL from
the identity URL, and on this single origin that path serves Studio's own keys.
Delegation and every guard decision are unaffected; only the local
signature check on a token this stack issued is unavailable.

### The gateway

Separate base URL, and it keeps the `/llm` segment:

```bash
http://highflame.local/gateway/llm/v1
```

---

## Support

There is no phone-home, so nothing tells us how this is going. Send
`egress-report.txt`, `docker compose logs`, and what you were doing.
