#!/usr/bin/env bash
#
# Seed the evaluation account's Cedar policies from the shipped template
# catalog.
#
# This is not optional decoration, and it is not a demo fixture. Two things make
# it load-bearing:
#
#   1. Cedar is DEFAULT-DENY. Without at least one permit policy, every request
#      is denied no matter what the forbid rules say. So an empty policy set is
#      not "no opinion" — combined with shield.fail_closed it is "deny
#      everything".
#
#   2. firehog's config in this bundle sets shield.fail_closed = true, so a
#      Shield that cannot evaluate refuses traffic rather than forwarding it
#      unscanned. That is the posture an air-gapped deployment wants, and it is
#      only usable once policies exist.
#
# Before this script existed the stack ran with zero policies, Shield answered
# every guard call with 500 "no policies loaded", and the gateway forwarded
# every prompt to the LLM completely unscanned while logging a single warning.
# The product looked like it was working. It was a passthrough proxy.
#
# The policies come from the catalog the product ships, not from anything
# written here, so what an evaluator sees is the real thing.
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

# Product namespace Shield evaluates for LLM gateway traffic. Policies seeded
# under any other product sync cleanly and are never consulted here — which is a
# genuinely confusing failure, because "policy sync completed" still logs
# success for the product you did populate.
PRODUCT = "ai_gateway"

# The three that make an honest demo without GPUs:
#   permit-baseline          required, or Cedar denies everything
#   privacy.defaults         PII, driven by pattern detectors
#   data-protection.secrets  credentials, likewise
#
# Deliberately NOT the *-model / advanced templates: those need the ML detector
# services, which this bundle does not ship.
TEMPLATES = [
    "organization.permit-baseline",
    "privacy.defaults",
    "data-protection.secrets",
]

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


import urllib.parse  # noqa: E402  (after helpers, used by request)

# --- 1. authenticate as the evaluator ---------------------------------------

print("authenticating as evaluator")
status, raw = request(
    "POST",
    f"/auth/realms/highflame/protocol/openid-connect/token",
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

# --- 2. read the shipped catalog --------------------------------------------

print("reading the policy template catalog")
status, raw = request("GET", "/v2/admin/policy/templates", token=token)
if status != 200:
    sys.exit(f"  admin returned {status}: {raw[:200]}")

catalog = json.loads(raw)
by_id = {t["id"]: t for t in catalog if t.get("product") == PRODUCT}
print(f"  {len(catalog)} templates, {len(by_id)} for product '{PRODUCT}'")

missing = [t for t in TEMPLATES if t not in by_id]
if missing:
    sys.exit(f"  catalog is missing: {', '.join(missing)}")

# --- 3. create them ---------------------------------------------------------

created = skipped = 0
for template_id in TEMPLATES:
    template = by_id[template_id]
    body = {
        "policy_name": template_id,
        # product is resolved from labels["product"]. The top-level "product"
        # field appears in the response model and is IGNORED on create — set it
        # alone and the policy is stored unscoped, syncs to nothing, and
        # nothing reports an error.
        "labels": {
            "product": PRODUCT,
            "source": "airgap-eval",
            "template_id": template_id,
        },
        "category": template.get("category", ""),
        "content": template["cedar_text"],
        "description": template.get("description", ""),
        "mode": "enforce",
        "is_active": True,
    }

    status, raw = request("POST", "/v2/admin/policy", body=body, token=token)
    if status in (200, 201):
        created += 1
        print(f"  created  {template_id}")
    elif status == 409:
        skipped += 1
        print(f"  keep     {template_id} (already present)")
    else:
        sys.exit(f"  FAILED   {template_id}: {status} {raw[:200]}")

print(f"\n{created} created, {skipped} already present")

# --- 4. confirm Shield actually loaded them ---------------------------------
#
# Creating a policy and having it enforced are different claims. Shield pulls
# every 30s, so wait for the pull rather than assert success on the create.

print("waiting for Shield to sync (polls every 30s)")
deadline = time.time() + 90
while time.time() < deadline:
    status, raw = request("GET", "/v2/admin/policy", token=token)
    if status == 200:
        try:
            policies = json.loads(raw)
            active = [
                p
                for p in (policies if isinstance(policies, list) else policies.get("policies", []))
                if p.get("product") == PRODUCT and p.get("is_active")
            ]
            if len(active) >= len(TEMPLATES):
                print(f"  {len(active)} active {PRODUCT} policies in the store")
                break
        except (ValueError, AttributeError):
            pass
    time.sleep(5)

print()
print("Seeded. Verify enforcement actually happens — do not take it on trust:")
print()
print("    docker compose logs highflame-shield | grep 'policy sync completed'")
print(f"        expect policies:{len(TEMPLATES)} for product={PRODUCT}")
print()
print("    then send a prompt containing a fake credential through the gateway;")
print("    the notebook's enforcement cell does exactly this.")
PYTHON
