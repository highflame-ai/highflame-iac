#!/usr/bin/env bash
#
# Give the evaluation tenant the default policies every project gets, by asking
# the product to provision them — not by writing policies of our own.
#
# Why this script has to exist at all
# -----------------------------------
# Admin seeds a project's default policies when it CREATES the project
# (highflame-admin, tenancy.Service.seedDefaultPolicies -> authz
# /policies/ensure-defaults). This bundle does not create its project that way:
# bootstrap/seed-tenant.sh writes the account, project and membership straight
# into Postgres, because account_members has no API a fresh install can reach.
# That bypasses the hook, so the tenant is born with no policies at all.
#
# Why that matters more than it sounds
# ------------------------------------
#   1. Cedar is DEFAULT-DENY. Without a permit policy every request is denied no
#      matter what the forbid rules say, so an empty policy set is not "no
#      opinion" — it is "deny everything".
#
#   2. firehog's config here sets shield.fail_closed = true, so a Shield that
#      cannot evaluate refuses traffic rather than forwarding it unscanned. That
#      is the posture an air-gapped deployment wants, and it is only usable once
#      policies exist.
#
#   3. The denial is anonymous. A request that matches no policy comes back with
#      an empty policy_reason and no determining policies, which the SDK prints
#      as "Refused by Highflame: None". Nothing tells the operator what to fix.
#
# Before any of this existed the stack ran with zero policies, Shield answered
# every guard call with 500 "no policies loaded", and the gateway forwarded every
# prompt to the LLM completely unscanned while logging a single warning. The
# product looked like it was working. It was a passthrough proxy.
#
# What it seeds, and what it deliberately does not
# ------------------------------------------------
# ensure-defaults provisions exactly one policy per product — Baseline Permit
# (organization.permit-baseline), the permit everything else narrows. It seeds no
# detection policies, by design: those are the evaluator's to deploy from
# Studio's template catalogue, the same way a customer deploys them, so what gets
# enforced is a decision someone made and can point at rather than something a
# bootstrap script decided on their behalf.
#
# An earlier version of this script created a curated set of templates directly.
# That produced policies no one had chosen, labelled with a marker no product
# code path writes, and it hid the fact that this tenant never went through
# project provisioning at all.
#
# Idempotent: authz returns early if the project already has project-wide
# policies, so re-running is free.
set -euo pipefail

cd "$(dirname "$0")/.."

command -v python3 >/dev/null || { echo "python3 is required"; exit 1; }

if [ ! -f .env ]; then
  echo "No .env found. Run ./bootstrap/bootstrap.sh first."
  exit 1
fi

python3 - "$@" <<'PYTHON'
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

# --- config -----------------------------------------------------------------

env = {}
for line in open(".env"):
    line = line.strip()
    if line and not line.startswith("#") and "=" in line:
        key, value = line.split("=", 1)
        env[key] = value

HOSTNAME = env.get("HIGHFLAME_HOST_IP", "highflame.local")
PORT = env.get("HIGHFLAME_HTTP_PORT", "80")
CLIENT_SECRET = env.get("OIDC_CLIENT_SECRET", "")
PASSWORD = env.get("EVALUATOR_PASSWORD", "")

# Reach nginx on the published port and name the vhost explicitly, so this works
# whether or not the operator has added HIGHFLAME_HOST_IP to /etc/hosts yet.
BASE = f"http://127.0.0.1:{PORT}"

# Must match bootstrap/seed-tenant.sh — the policies are scoped to the tenant it
# creates, and a mismatch produces policies nothing will ever evaluate.
ACCOUNT_ID = "100000000001"
PROJECT_ID = "22222222-2222-4222-8222-222222222222"

# The two product namespaces this bundle actually evaluates:
#   guardrails  agent and SDK traffic (Shield's /guard, the notebooks)
#   ai_gateway  LLM traffic through firehog
#
# Policies seeded under any other product sync cleanly and are never consulted —
# a genuinely confusing failure, because "policy sync completed" still logs
# success for the product you did populate.
PRODUCTS = ["guardrails", "ai_gateway"]

BASELINE_TEMPLATE_ID = "organization.permit-baseline"

# --- helpers ----------------------------------------------------------------


def request(method, path, body=None, token=None, form=False):
    url = BASE + path
    headers = {"Host": HOSTNAME}

    if token:
        headers["Authorization"] = f"Bearer {token}"
        headers["x-javelin-accountid"] = ACCOUNT_ID
        headers["x-highflame-project-id"] = PROJECT_ID

    data = None
    if body is not None:
        if form:
            data = urllib.parse.urlencode(body).encode()
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        else:
            data = json.dumps(body).encode()
            headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.status, resp.read().decode()
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read().decode()
    except urllib.error.URLError as exc:
        print(f"\ncannot reach the stack at {BASE} ({exc.reason}).")
        print("Is it running?  docker compose ps")
        sys.exit(1)


def policies_for(token, product):
    """Every project-wide policy stored for a product."""
    query = urllib.parse.urlencode({"limit": "200", "label": f"product:{product}"})
    status, raw = request("GET", f"/v2/admin/policy?{query}", token=token)
    if status != 200:
        return None

    try:
        body = json.loads(raw)
    except ValueError:
        return None

    items = body if isinstance(body, list) else body.get("policies", [])
    return [p for p in items if not p.get("agent_id") and not p.get("application_id")]


def has_baseline(policies):
    for p in policies or []:
        if (p.get("labels") or {}).get("template_id") == BASELINE_TEMPLATE_ID and p.get("is_active"):
            return True
    return False


# --- 1. authenticate as the evaluator ---------------------------------------

print("authenticating as evaluator")
status, raw = request(
    "POST",
    "/auth/realms/highflame/protocol/openid-connect/token",
    body={
        "client_id": "highflame-studio",
        "client_secret": CLIENT_SECRET,
        "grant_type": "password",
        "username": "evaluator",
        "password": PASSWORD,
        "scope": "openid",
    },
    form=True,
)
if status != 200:
    sys.exit(f"  keycloak returned {status}: {raw[:200]}")

token = json.loads(raw).get("id_token")
if not token:
    sys.exit("  no id_token in the response")

# --- 2. ask the product to provision its defaults ----------------------------

stranded = []
provisioned = []

for product in PRODUCTS:
    query = urllib.parse.urlencode({"product": product})
    status, raw = request(
        "POST", f"/v2/admin/policy/ensure-defaults?{query}", body={}, token=token
    )
    if status not in (200, 201):
        sys.exit(f"  FAILED   ensure-defaults for {product}: {status} {raw[:200]}")

    try:
        result = json.loads(raw)
    except ValueError:
        result = {}

    created = result.get("created") or []
    if created:
        provisioned.append(product)
        names = ", ".join(p.get("policy_name", "?") for p in created)
        print(f"  {product:11} provisioned: {names}")
    else:
        # The "existing" list is every project-wide policy, agent grants
        # included, so counting it says more than naming it would.
        count = len(result.get("existing") or [])
        print(f"  {product:11} already provisioned ({count} project-wide policies)")

    # ensure-defaults returns early when the project already has ANY project-wide
    # policy, so a project that lost only its baseline — or that had a detection
    # policy deployed before defaults ever ran — is NOT repaired by the call
    # above and reports "already present" while still missing the permit.
    # Studio cannot fix that state either: the organization category is filtered
    # out of the template catalogue, and the Default Behavior toggle is disabled
    # when no baseline exists (highflame-studio#1607). So say so loudly here,
    # where it is still cheap to fix.
    if not has_baseline(policies_for(token, product)):
        stranded.append(product)

if stranded:
    print()
    print("PROBLEM: no active Baseline Permit for: " + ", ".join(stranded))
    print()
    print("  The project already holds other policies, so ensure-defaults declined")
    print("  to seed, and Cedar will deny anything no other policy permits — with")
    print("  no policy named in the refusal.")
    print()
    print("  Studio cannot create it (highflame-studio#1607). Deploy it directly:")
    print()
    print("      curl -X POST http://127.0.0.1:$PORT/v2/admin/policy \\")
    print("        -H 'Host: <HIGHFLAME_HOST_IP>' -H 'Authorization: Bearer <id_token>' \\")
    print("        -H 'x-javelin-accountid: 100000000001' \\")
    print("        -H 'x-highflame-project-id: 22222222-2222-4222-8222-222222222222' \\")
    print("        -H 'Content-Type: application/json' \\")
    print("        -d '{\"policy_name\":\"Baseline Permit\",\"mode\":\"enforce\",\"is_active\":true,")
    print("             \"labels\":{\"product\":\"<product>\",\"template_id\":\"organization.permit-baseline\"},")
    print("             \"content\":\"<cedar_text from /v2/admin/policy/templates>\"}'")
    sys.exit(1)

# --- 3. confirm Shield actually loaded them ---------------------------------
#
# Provisioning a policy and having it enforced are different claims. Shield pulls
# every 30s, so wait for the pull rather than assert success on the create.

print("\nwaiting for Shield to sync (polls every 30s)")
deadline = time.time() + 90
while time.time() < deadline:
    counts = {p: len(policies_for(token, p) or []) for p in PRODUCTS}
    if all(n > 0 for n in counts.values()):
        print("  " + ", ".join(f"{p}: {n} project-wide" for p, n in counts.items()))
        break
    time.sleep(5)

print()
if provisioned:
    print("Baseline permit in place. Nothing is DETECTED yet — that is deliberate.")
    print()
    print("Deploy the detection policies you want from Studio, the way a customer")
    print("would:  Guardrails -> Policies, and AI Gateway -> Policies.")
    print()
    print("  Structural PII      (privacy.defaults)          enforce")
    print("  Secrets Detection   (data-protection.defaults)  monitor, or enforce")
    print()
    print("Both are pattern detectors, so they run without the ML detector services")
    print("this bundle does not ship. The *-model and advanced templates need those,")
    print("and will sit there matching nothing.")
else:
    print("Every product already had its defaults; nothing to do.")
    print()
    print("What is deployed is whatever you deployed from Studio. Check it under")
    print("Guardrails -> Policies and AI Gateway -> Policies.")
print()
print("Then verify enforcement actually happens — do not take it on trust:")
print()
print("    docker compose logs highflame-shield | grep 'policy sync completed'")
print()
print("    then send a prompt containing a fake credential through the gateway;")
print("    the notebook's enforcement cell does exactly this.")
PYTHON
