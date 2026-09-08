# Highflame — air-gapped evaluation stack

The whole Highflame platform on one machine, with **Docker and Python 3 as the only
dependency**. No Kubernetes, no Helm, no cloud account, no Highflame tenant, and
no internet at runtime.

---

[Read the Deployment docs here](https://docs.highflame.ai/docs/deployment/poc)

## Prove it does not phone home

This is the part worth doing yourself rather than taking on trust.

```bash
./verify/no-egress.sh --report egress-report.txt
```

**Read this first, because it bounds what follows.** The stack runs on an
ordinary Docker bridge network, which has a gateway — so nothing in it
*structurally* prevents a container from opening an outbound connection. That is
a deliberate trade, not an oversight: an isolated network removes the route by
which Admin and Studio fetch OpenID metadata from the issuer URL, and making
that work would force every deployment to use a resolvable hostname instead of
an IP. Plenty of organisations cannot edit `/etc/hosts` on a developer laptop,
and a bundle that will not run is worse than one whose isolation you add
yourself.

So what the script proves is that **nothing here is configured to phone home and
nothing is doing so** — not that it could not. It checks, and prints raw
evidence for, each of:

1. The network posture, stated plainly, including whether egress is possible
2. Which containers publish a host port — only nginx should, so it is the single
   entry point from your network
3. What a container on the app network can actually reach (tried, not assumed),
   reported either way
4. No running container holds a connection to a Highflame-operated or analytics
   endpoint
5. No Highflame-operated host appears anywhere in the resolved configuration —
   including the detector model endpoints
6. The one intended egress points at _your_ LLM, and it prints the value so you
   can confirm it
7. Every LLM provider endpoint is explicitly pinned, none left to a public
   default

A check it cannot complete is reported as **WARN / unproven**, never as a pass.
The report is plain text, meant to be attached to your own review.

**To make isolation structural**, do it outside the stack where a config change
cannot undo it: run the host with its uplink removed, or block egress for this
bridge at the host firewall. The stack is designed to behave identically either
way, and `no-egress.sh` will then report check 3 as a pass rather than a
warning.

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
# Use the address you set as HIGHFLAME_HOST_IP. Not a hostname, which needs DNS
# this stack does not provide, and not 127.0.0.1.
HIGHFLAME_BASE_URL=http://10.0.0.42      # Shield: guard and detect
HIGHFLAME_IDENTITY_URL=http://10.0.0.42  # AuthN: agent registration
HIGHFLAME_TOKEN_URL=http://10.0.0.42/oauth2/token
HIGHFLAME_API_KEY=zid_sk_...             # a service key, minted below
```

Set `HIGHFLAME_TOKEN_URL` yourself. The SDK defaults it to the hosted service,
and an unset value is the one mistake here that fails with a confusing
authentication error rather than a connection error.

Mint the key with `POST /v1/admin/service-keys`, the way the notebook does.
Studio's API key screen is part of the dashboard that does not render on an OIDC
build.

### One limit, stated up front

**The ingress publishes AuthN's token endpoint, its agent-registry routes and
its key set, and nothing else.** Those are the only identity routes an SDK
caller needs and the only ones that accept a bearer token, which is all it
holds. AuthN's remaining admin routes are gated on a secret that the services
share over the internal network, so publishing them would add attack surface
that no SDK caller could use. Agent registration, delegation, token
verification and the guard path all work. The identity admin namespaces answer
404 through this ingress.

### The gateway

Separate base URL, and it keeps the `/llm` segment:

```bash
http://10.0.0.42/gateway/llm/v1
```

---

## Support

There is no phone-home, so nothing tells us how this is going. Send
`egress-report.txt`, `docker compose logs`, and what you were doing.
