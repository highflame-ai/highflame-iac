#!/usr/bin/env bash
#
# Exercise the air-gapped bundle's setup jobs the way an evaluator runs them:
# through `docker compose`, with nothing on the host but Docker.
#
# Covers the bootstrap and preflight jobs end to end. The seed job is not run
# here: it needs the whole stack, and the stack's images are private.
#
# Runs against a throwaway copy of airgap-eval under its own compose project,
# so it never touches a stack that is already running from the real directory.
#
#   .github/scripts/airgap-setup-test.sh
set -euo pipefail

SRC="$(cd "$(dirname "$0")/../../airgap-eval" && pwd)"
WORK="$(mktemp -d)"
export COMPOSE_PROJECT_NAME="airgap-setup-test-$$"
VOLUME="${COMPOSE_PROJECT_NAME}_postgres-data"

cleanup() {
  (cd "$WORK" && docker compose down -v --remove-orphans >/dev/null 2>&1) || true
  docker volume rm -f "$VOLUME" >/dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap cleanup EXIT

cp -R "$SRC/." "$WORK/"
rm -rf "$WORK/.env" "$WORK/secrets"
cd "$WORK"

failures=0
pass() { echo "  PASS  $*"; }
fail() { echo "  FAIL  $*"; failures=$((failures + 1)); }

# expect <description> <expected exit> <output pattern> -- <command...>
expect() {
  local what="$1" want_rc="$2" pattern="$3"
  shift 4
  local out rc=0
  out=$("$@" 2>&1) || rc=$?
  if [ "$rc" -ne "$want_rc" ]; then
    fail "$what: exit $rc, wanted $want_rc"
    printf '%s\n' "$out" | sed 's/^/        /'
  elif [ -n "$pattern" ] && ! printf '%s\n' "$out" | grep -qE "$pattern"; then
    fail "$what: output did not match /$pattern/"
    printf '%s\n' "$out" | sed 's/^/        /'
  else
    pass "$what"
  fi
}

echo "== the stack refuses to start before bootstrap has run"
# Every generated secret is required, so compose stops at parse time rather
# than starting anything with an empty password. 15 is compose's exit status for
# an interpolation error.
expect "up refuses and names the bootstrap command" 15 "run docker compose -f bootstrap.yaml run --rm bootstrap" \
  -- docker compose up -d --no-start
[ ! -e secrets ] && pass "no bind-mount directories were created" \
  || fail "secrets/ exists after a refused up"

echo "== the bootstrap file parses with no .env, and says nothing about it"
out=$(docker compose -f bootstrap.yaml config -q 2>&1) || true
if [ -z "$out" ]; then pass "no warnings or errors"; else fail "compose config printed: $out"; fi

echo "== bootstrap with no .env creates one and asks for the two values"
expect "bootstrap stops on the missing values" 1 "HIGHFLAME_HOST_IP" \
  -- docker compose -f bootstrap.yaml run --rm bootstrap
[ -f .env ] && pass ".env created from the example" || fail ".env was not created"

echo "== bootstrap with a .env saved by a Windows editor"
printf 'HIGHFLAME_HOST_IP=10.0.0.42\nHIGHFLAME_LLM_BASE_URL=http://llm.example.invalid:8000/v1\n' >> .env
sed -i.bak 's/$/\r/' .env && rm -f .env.bak
expect "bootstrap completes" 0 "Bootstrap complete" \
  -- docker compose -f bootstrap.yaml run --rm bootstrap

if grep -q $'\r' .env; then fail ".env still has CRLF"; else pass ".env normalised to LF"; fi
if grep -q $'\r' secrets/keycloak/highflame-realm.json; then
  fail "a carriage return reached the realm"
else
  pass "no carriage return in the realm"
fi
grep -q '"rootUrl": "http://10.0.0.42"' secrets/keycloak/highflame-realm.json \
  && pass "realm origin is the configured address" \
  || fail "realm origin is not http://10.0.0.42"
grep -q 'REPLACE_ME_' secrets/keycloak/highflame-realm.json \
  && fail "a placeholder survived in the realm" || pass "no placeholders in the realm"
grep -qE '\$\{[A-Z_]+\}' secrets/firehog/config.yaml \
  && fail "a placeholder survived in firehog's config" || pass "no placeholders in firehog's config"

missing_keys=0
for f in secrets/keys/private.pem secrets/keys/public.pem \
         secrets/keys/rsa-private.pem secrets/keys/rsa-public.pem \
         secrets/authz-keys/private.key secrets/authz-keys/public.key; do
  [ -s "$f" ] || { fail "$f missing or empty"; missing_keys=1; }
done
[ "$missing_keys" -eq 0 ] && pass "all six key files present"

# The job runs as root; everything must come back owned by the caller, or the
# .env they are told to edit needs sudo.
me="$(id -u):$(id -g)"
wrong=$(find .env secrets \! -user "$(id -u)" 2>/dev/null | head -5)
[ -z "$wrong" ] && pass "everything owned by $me" || fail "not owned by $me: $wrong"

# Keycloak (uid 1000) and AuthN/AuthZ (uid 10000) read these; the caller is
# neither in general, so they must be world-readable.
bad_mode=0
for f in secrets/keycloak/highflame-realm.json secrets/keys/private.pem secrets/authz-keys/private.key; do
  [ "$(stat -c '%a' "$f")" = "644" ] || { fail "$f is not 644"; bad_mode=1; }
done
[ "$bad_mode" -eq 0 ] && pass "files the services read are 644"

[ "$(stat -c '%a' secrets)" = "700" ] && pass "secrets/ is 700" || fail "secrets/ is not 700"
[ "$(stat -c '%a' .env)" = "600" ] && pass ".env is 600" || fail ".env is not 600"
[ ! -e .env.tmp ] && pass "no temporary copy of .env left behind" || fail ".env.tmp left behind"

secret=$(grep '^POSTGRES_PASSWORD=' .env | cut -d= -f2)
[ ${#secret} -eq 32 ] && pass "secrets generated" || fail "POSTGRES_PASSWORD not generated"

echo "== bootstrap again keeps what exists"
expect "re-run keeps secrets" 0 "keep +POSTGRES_PASSWORD" \
  -- docker compose -f bootstrap.yaml run --rm bootstrap
[ "$(grep '^POSTGRES_PASSWORD=' .env | cut -d= -f2)" = "$secret" ] \
  && pass "POSTGRES_PASSWORD unchanged" || fail "POSTGRES_PASSWORD changed on re-run"

echo "== an emptied secret stops compose, even for a single service without its dependencies"
# ClickHouse starts with a passwordless, any-address user when this is empty,
# so --no-deps (which skips preflight) must still be refused.
cp .env .env.good
sed -i.bak 's/^CLICKHOUSE_PASSWORD=.*/CLICKHOUSE_PASSWORD=/' .env && rm -f .env.bak
expect "empty CLICKHOUSE_PASSWORD refused" 15 "CLICKHOUSE_PASSWORD is empty" \
  -- docker compose up -d --no-deps --no-start highflame-clickhouse
mv .env.good .env

echo "== preflight accepts the bootstrapped stack"
expect "preflight passes" 0 "consistent with .env" \
  -- docker compose run --rm preflight

echo "== preflight catches a host address changed after bootstrap"
echo 'HIGHFLAME_HOST_IP=10.0.0.99' >> .env
expect "preflight refuses the drift" 1 "different HIGHFLAME_HOST_IP" \
  -- docker compose run --rm preflight
sed -i.bak '$d' .env && rm -f .env.bak

echo "== --force is allowed on an empty stack and refused once it has data"
expect "--force with no data" 0 "generated POSTGRES_PASSWORD" \
  -- docker compose -f bootstrap.yaml run --rm bootstrap --force
docker run --rm --entrypoint sh -v "$VOLUME:/d" pgvector/pgvector:pg17 -c 'touch /d/PG_VERSION'
expect "--force with data" 1 "Refusing --force" \
  -- docker compose -f bootstrap.yaml run --rm bootstrap --force

echo
if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed"
  exit 1
fi
echo "all checks passed"
