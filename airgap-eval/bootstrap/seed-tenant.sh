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
ORG_UUID="11111111-1111-4111-8111-111111111111"
PROJECT_UUID="22222222-2222-4222-8222-222222222222"

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

docker compose exec -T highflame-db psql -U "$PGUSER_" -d "$PGDB" -v ON_ERROR_STOP=1 <<SQL
\set ON_ERROR_STOP on

-- Organization. auth_provider='oidc' with a stable auth_org_id, so Admin's
-- Clerk-org lookup path is never involved. The UNIQUE key here is
-- (auth_provider, auth_org_id) as of ADR 0033, which is what lets an on-prem
-- 'oidc' org coexist with a 'clerk' org carrying the same identifier.
INSERT INTO tenants (
  id, parent_id, tenant_type, auth_provider, auth_org_id, account_id,
  name, slug, tier, metadata, settings, is_active, is_default
) VALUES (
  '${ORG_UUID}', NULL, 'organization', 'oidc', 'airgap-eval', '${ACCOUNT_ID}',
  'Evaluation', 'evaluation', 'enterprise', '{}'::jsonb, '{}'::jsonb, true, false
) ON CONFLICT (account_id, slug) DO NOTHING;

-- Default project. Studio's oidc_session grant resolves this when the caller
-- names no project_id, so without it first login fails on project resolution.
INSERT INTO tenants (
  id, parent_id, tenant_type, auth_provider, auth_org_id, account_id,
  name, slug, tier, metadata, settings, is_active, is_default
) VALUES (
  '${PROJECT_UUID}', '${ORG_UUID}', 'project', 'oidc', NULL, '${ACCOUNT_ID}',
  'Default', 'default', 'enterprise', '{}'::jsonb, '{}'::jsonb, true, true
) ON CONFLICT (account_id, slug) DO NOTHING;

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

cat <<EOF

Ready. Sign in at http://${HIGHFLAME_HOST_IP}

  username    evaluator
  password    (EVALUATOR_PASSWORD from .env)
  account_id  ${ACCOUNT_ID}
  project_id  ${PROJECT_UUID}

The account_id and project_id above are what the cookbook notebook uses.
EOF
