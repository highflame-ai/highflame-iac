#!/usr/bin/env bash
#
# Create the evaluator's organization, default project and membership.
#
# ============================================================================
# Why this script has to exist
# ============================================================================
#
# Admin's `oidc_session` grant will not mint a token unless the caller already
# has an active `account_members` row for the account they name (ADR 0033 — the
# account is authorized against a store rather than trusted from an IdP claim).
#
# That is the right rule, and it creates a bootstrap problem on a FRESH on-prem
# install: the very first user has no membership row, so every login returns
# 403 access_denied and there is no in-product way to grant themselves one.
#
# In SaaS this never surfaces because creating a Clerk organization drives
# provisioning. With a generic OIDC provider nothing does.
#
# Admin's `bootstrap_super_admins` config does NOT close this: it grants a row in
# `user_global_roles`, whereas the grant checks `account_members`. So the first
# membership has to be created out of band, which is what this does.
#
# Upstream fix worth making (not done here — changing an authorization gate is
# not an evaluation-harness decision): either have the oidc_session grant accept
# a global super-admin as an alternative to account membership, or give Admin a
# first-run provisioning path for OIDC deployments.
#
# Idempotent: safe to re-run, and safe to run against an already-seeded stack.
set -euo pipefail

cd "$(dirname "$0")/.."
[ -f .env ] && set -a && . ./.env && set +a

PGUSER_="${POSTGRES_USER:-highflame}"
PGDB="${POSTGRES_DB:-javelin_data}"

# Fixed identifiers, so the notebook and the docs can reference them literally
# instead of telling the evaluator to go and look them up.
#
# EVALUATOR_SUB must equal the pinned `id` of the user in
# config/keycloak/highflame-realm.json. It becomes the `sub` of every token
# Keycloak issues, and therefore the account_members.user_id Admin matches on.
# Change one without the other and login fails with 403.
EVALUATOR_SUB="0f5d0c7e-26bd-437e-93d2-6ea988f1292e"
ACCOUNT_ID="100000000001"

# The organization's identifier at the identity provider. Stable, so re-running
# this script finds the tenant it made last time instead of making another.
AUTH_ORG_ID="airgap-eval"

# The organization and project UUIDs are NOT pinned here any more. They are
# whatever provisioning assigns, and this script writes them into .env for the
# notebook to read. Pinning them meant creating the rows by hand, which is how
# this tenant used to skip everything else provisioning does.
command -v python3 >/dev/null || { echo "python3 is required"; exit 1; }

echo "waiting for Admin to finish its first-boot migrations..."
# account_members is created by Admin's tenancy migration. Polling for the TABLE
# rather than for a health endpoint is the honest check: a healthy Admin that has
# not yet migrated would make the inserts below fail confusingly.
for _ in $(seq 1 60); do
  if docker compose exec -T highflame-db \
      psql -U "$PGUSER_" -d "$PGDB" -tAc \
      "SELECT to_regclass('public.account_members') IS NOT NULL" 2>/dev/null | grep -q '^t$'; then
    echo "  account_members exists"
    break
  fi
  sleep 5
done

# The loop above can exhaust its attempts. Falling through to the inserts is
# what made this script report success while doing nothing: `docker compose
# exec` against a service it cannot see prints a message and exits 0, `set -e`
# sees a clean status, and the heredoc below is simply skipped.
#
# The symptom appeared two steps later as `403 access_denied` from the notebook
# — the exact failure the header comment of this script exists to explain — with
# nothing pointing back here.
if ! docker compose exec -T highflame-db \
    psql -U "$PGUSER_" -d "$PGDB" -tAc \
    "SELECT to_regclass('public.account_members') IS NOT NULL" 2>/dev/null | grep -q '^t$'; then
  echo
  echo "FAILED: could not reach the database, so nothing was seeded."
  echo
  echo "  Is the stack up?          docker compose ps"
  echo "  Same project name?        COMPOSE_PROJECT_NAME in .env must match how"
  echo "                            you brought it up (this script calls docker"
  echo "                            compose without -p)"
  echo "  Admin still migrating?    docker compose logs highflame-admin"
  exit 1
fi

# ----------------------------------------------------------------------------
# Provision the organization and its default project through the product.
#
# This used to be two INSERTs into `tenants`. Writing those rows by hand
# produced a tenant that looked complete and was not: provisioning also gives a
# new project its default policies, and Cedar is default-deny, so a project
# created behind the product's back denies everything and names no policy while
# doing it. Everything the product does on the way is now done.
#
# Only the membership below still needs direct database access.
# ----------------------------------------------------------------------------
echo "provisioning the organization and its default project..."

PROVISION_OUT=$(
  HIGHFLAME_ACCOUNT_ID="$ACCOUNT_ID" \
  HIGHFLAME_AUTH_ORG_ID="$AUTH_ORG_ID" \
  python3 - <<'PYTHON'
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

env = {}
for line in open(".env"):
    line = line.strip()
    if line and not line.startswith("#") and "=" in line:
        key, value = line.split("=", 1)
        env[key] = value

HOSTNAME = env.get("HIGHFLAME_HOST_IP", "highflame.local")
PORT = env.get("HIGHFLAME_HTTP_PORT", "80")
BASE = f"http://127.0.0.1:{PORT}"
ACCOUNT_ID = os.environ["HIGHFLAME_ACCOUNT_ID"]
AUTH_ORG_ID = os.environ["HIGHFLAME_AUTH_ORG_ID"]


def request(method, path, body=None, token=None, form=False, tenant=None):
    headers = {"Host": HOSTNAME}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    # Provisioning runs before any tenant exists and must NOT carry these; the
    # policy calls afterwards are scoped and must.
    if tenant:
        account_id, project_id = tenant
        headers["x-javelin-accountid"] = account_id
        headers["x-highflame-project-id"] = project_id

    data = None
    if body is not None:
        if form:
            data = urllib.parse.urlencode(body).encode()
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        else:
            data = json.dumps(body).encode()
            headers["Content-Type"] = "application/json"

    req = urllib.request.Request(BASE + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.status, resp.read().decode()
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read().decode()
    except urllib.error.URLError as exc:
        return 0, str(exc.reason)


# The API has to be reachable, not merely migrated. Waiting here keeps the
# failure legible: without it an unready Admin looks like a provisioning bug.
for _ in range(60):
    status, _ = request("GET", "/v1/admin/health")
    if status and status < 500:
        break
    time.sleep(5)
else:
    sys.exit("  Admin never became reachable; is the stack up? docker compose ps")

status, raw = request(
    "POST",
    "/auth/realms/highflame/protocol/openid-connect/token",
    body={
        "client_id": "highflame-studio",
        "client_secret": env.get("OIDC_CLIENT_SECRET", ""),
        "grant_type": "password",
        "username": "evaluator",
        "password": env.get("EVALUATOR_PASSWORD", ""),
        "scope": "openid",
    },
    form=True,
)
if status != 200:
    sys.exit(f"  keycloak returned {status}: {raw[:200]}")

token = json.loads(raw).get("id_token")
if not token:
    sys.exit("  no id_token in the keycloak response")

# account_id is pinned so the docs and the notebook can name it. The org and
# project UUIDs are the product's to choose. auth_provider says who actually
# authenticated the caller, rather than letting it default to Clerk.
status, raw = request(
    "POST",
    "/v1/admin/tenancy/provision",
    body={
        "auth_org_id": AUTH_ORG_ID,
        "auth_provider": "oidc",
        "account_id": ACCOUNT_ID,
        "org_name": "Evaluation",
    },
    token=token,
)
if status not in (200, 201):
    sys.exit(f"  provisioning failed: {status} {raw[:300]}")

body = json.loads(raw)
org = body.get("organization") or {}
project = body.get("default_project") or {}
project_id = project.get("id") or body.get("default_project_id") or ""
if not project_id:
    sys.exit(f"  provisioning returned no default project: {raw[:300]}")

# Ask for the default policies explicitly, even though provisioning seeds them
# when it CREATES a project.
#
# Provisioning is idempotent by returning early once the organization exists, so
# a re-run against an existing tenant never reaches the seeding it performs on
# the first pass. Without this, "safe to re-run" would be true of the tenant
# rows and false of everything else: a tenant that lost its baseline permit, or
# that predates the product seeding one, would stay broken however many times
# this script was run. The call creates only what is missing.
BASELINE_TEMPLATE_ID = "organization.permit-baseline"
PRODUCTS = ["guardrails", "ai_gateway"]

stranded = []

for product in PRODUCTS:
    query = urllib.parse.urlencode({"product": product})
    status, raw = request(
        "POST",
        f"/v2/admin/policy/ensure-defaults?{query}",
        body={},
        token=token,
        tenant=(ACCOUNT_ID, project_id),
    )
    if status not in (200, 201):
        sys.exit(f"  could not ensure default policies for {product}: {status} {raw[:200]}")

    # Verify rather than trust the response: what matters is whether an active
    # baseline permit is in place now, not what the call reported doing.
    query = urllib.parse.urlencode({"limit": "200", "label": f"product:{product}"})
    status, raw = request(
        "GET", f"/v2/admin/policy?{query}", token=token, tenant=(ACCOUNT_ID, project_id)
    )
    present = False
    if status == 200:
        try:
            policies = json.loads(raw)
            policies = policies if isinstance(policies, list) else policies.get("policies", [])
        except ValueError:
            policies = []

        for p in policies:
            labels = p.get("labels") or {}
            if labels.get("template_id") == BASELINE_TEMPLATE_ID and p.get("is_active"):
                present = True
                break

    print(f"  {product:11} default policies in place: {present}", file=sys.stderr)
    if not present:
        stranded.append(product)

if stranded:
    print("", file=sys.stderr)
    print("  No active Baseline Permit for: " + ", ".join(stranded), file=sys.stderr)
    print("  Without it, a request matching no other policy is denied and the", file=sys.stderr)
    print("  refusal names no policy, so traffic fails without saying why.", file=sys.stderr)
    print("", file=sys.stderr)
    print("  Fix it in Studio: open that product's Policies page and turn", file=sys.stderr)
    print("  Default Behavior on. The toggle deploys the baseline permit.", file=sys.stderr)
    sys.exit(1)

# Consumed by the shell below.
print(org.get("id", ""))
print(project_id)
PYTHON
) || exit 1

ORG_UUID=$(printf '%s\n' "$PROVISION_OUT" | sed -n '1p')
PROJECT_UUID=$(printf '%s\n' "$PROVISION_OUT" | sed -n '2p')
echo "  organization    ${ORG_UUID}"
echo "  default project ${PROJECT_UUID}"

docker compose exec -T highflame-db psql -U "$PGUSER_" -d "$PGDB" -v ON_ERROR_STOP=1 <<SQL
\set ON_ERROR_STOP on

-- The membership that makes login possible. source='oidc' records provenance
-- distinctly from clerk/scim/manual/mapping, so reconciliation can tell where
-- the row came from.
INSERT INTO account_members (account_id, user_id, org_role, source, is_active)
VALUES ('${ACCOUNT_ID}', '${EVALUATOR_SUB}', 'admin', 'oidc', true)
ON CONFLICT (account_id, user_id)
  DO UPDATE SET org_role = 'admin', source = 'oidc', is_active = true;

\echo ''
\echo 'seeded:'
SELECT tenant_type, account_id, slug, auth_provider, is_default
  FROM tenants WHERE account_id = '${ACCOUNT_ID}' ORDER BY tenant_type;
SELECT account_id, user_id, org_role, source, is_active
  FROM account_members WHERE user_id = '${EVALUATOR_SUB}';
SQL

# Verify rather than assume. The inserts above run inside `docker compose exec`,
# whose exit status does not reliably reflect what happened inside — which is
# how this script used to report success having inserted nothing.
MEMBERS=$(docker compose exec -T highflame-db \
  psql -U "$PGUSER_" -d "$PGDB" -tAc \
  "SELECT count(*) FROM account_members
    WHERE account_id = '${ACCOUNT_ID}' AND user_id = '${EVALUATOR_SUB}' AND is_active" \
  2>/dev/null | tr -d '[:space:]')

if [ "${MEMBERS:-0}" -lt 1 ]; then
  echo
  echo "FAILED: the membership row is not present after seeding."
  echo "Nothing below would work, so this is an error rather than a warning."
  echo "  docker compose logs highflame-db | tail -40"
  exit 1
fi

# Record the ids provisioning chose, so the notebook reads them instead of
# carrying literals that have to be kept in step with this script by hand.
# Upsert rather than append: re-running must not leave two of each.
HIGHFLAME_ACCOUNT_ID="$ACCOUNT_ID" HIGHFLAME_PROJECT_ID="$PROJECT_UUID" python3 - <<'PYTHON'
import os
import pathlib
import re

path = pathlib.Path(".env")
text = path.read_text() if path.exists() else ""

for key in ("HIGHFLAME_ACCOUNT_ID", "HIGHFLAME_PROJECT_ID"):
    line = f"{key}={os.environ[key]}"
    pattern = re.compile(rf"^{key}=.*$", re.M)
    if pattern.search(text):
        text = pattern.sub(line, text)
    else:
        if text and not text.endswith("\n"):
            text += "\n"
        text += line + "\n"

path.write_text(text)
PYTHON
echo "  recorded HIGHFLAME_ACCOUNT_ID and HIGHFLAME_PROJECT_ID in .env"

cat <<EOF

Ready. Sign in at http://${HIGHFLAME_HOST_IP}

  username    evaluator
  password    (EVALUATOR_PASSWORD from .env)
  account_id  ${ACCOUNT_ID}
  project_id  ${PROJECT_UUID}

The account_id and project_id above are what the cookbook notebook uses.
EOF
