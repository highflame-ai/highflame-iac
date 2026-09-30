#!/usr/bin/env bash
#
# Refuse to start the stack until bootstrap has run, and name what is missing.
#
# Runs as the `preflight` job in docker-compose.yaml on every `docker compose
# up`. The data tier waits for it to exit cleanly, and everything else waits on
# the data tier, so a failure here stops the whole stack before any service
# starts. Read the reason with:
#
#   docker compose logs preflight
#
# This replaces the `${VAR:?}` guards the compose file used to carry. Those
# fired at parse time for EVERY compose command, including the one that runs
# bootstrap, so the job that generates the secrets could not run until the
# secrets existed.
#
# Nothing here writes anything. The working directory is mounted read-only.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

problems=()

# Values compose interpolated into this job's environment from .env. Empty
# means bootstrap has not run, or .env was replaced after it did.
for var in HIGHFLAME_HOST_IP HIGHFLAME_LLM_BASE_URL \
           POSTGRES_PASSWORD CLICKHOUSE_PASSWORD KEYCLOAK_ADMIN_PASSWORD \
           OIDC_CLIENT_SECRET EVALUATOR_PASSWORD AUTH_SECRET \
           HIGHFLAME_AUTH_JWT_SECRET_KEY HIGHFLAME_TOKEN_ENCRYPTION_KEY \
           HIGHFLAME_INTERNAL_SERVICE_SECRET HIGHFLAME_MODELS_SECRET; do
  [ -n "${!var:-}" ] || problems+=("$var is empty in .env")
done

# Files bootstrap renders or generates, which the services bind-mount.
REALM=secrets/keycloak/highflame-realm.json
for file in "$REALM" \
            secrets/firehog/config.yaml \
            secrets/keys/private.pem secrets/keys/public.pem \
            secrets/keys/rsa-private.pem secrets/keys/rsa-public.pem \
            secrets/authz-keys/private.key secrets/authz-keys/public.key; do
  if [ -d "$file" ]; then
    # Docker creates a missing bind-mount source as an empty directory. Seeing
    # one here means an earlier `up` ran before bootstrap did.
    problems+=("$file is a directory, not a file — delete it, then run bootstrap")
  elif [ ! -f "$file" ]; then
    problems+=("$file is missing")
  fi
done

# The realm must have been rendered from the .env compose is using now. Both
# drifts below fail much later and much less clearly: a changed host address as
# invalid_redirect_uri at login, a changed client secret as invalid_client.
if [ -f "$REALM" ]; then
  if [ -n "${HIGHFLAME_HOST_IP:-}" ] &&
     ! grep -qF "\"${CONN_PROTOCOL:-http}://${HIGHFLAME_HOST_IP}\"" "$REALM"; then
    # Re-rendering is not enough on a stack that has already run: Keycloak
    # imports the realm only into an empty database and keeps the first one.
    problems+=("$REALM was rendered for a different HIGHFLAME_HOST_IP — run bootstrap again; if the stack has run before, Keycloak keeps the realm it first imported, so start over with docker compose down -v")
  fi
  if [ -n "${OIDC_CLIENT_SECRET:-}" ] && ! grep -qF "\"${OIDC_CLIENT_SECRET}\"" "$REALM"; then
    problems+=("$REALM holds a different client secret from .env — run bootstrap again")
  fi
fi

if [ ${#problems[@]} -gt 0 ]; then
  echo "Bootstrap output is missing or does not match .env, so the stack was not started:"
  printf '  - %s\n' "${problems[@]}"
  echo
  echo "Set HIGHFLAME_HOST_IP and HIGHFLAME_LLM_BASE_URL in .env, then:"
  echo "    docker compose run --rm bootstrap"
  echo "    docker compose up -d"
  exit 1
fi

echo "preflight: bootstrap output present and consistent with .env"
