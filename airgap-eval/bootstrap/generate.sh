#!/usr/bin/env bash
#
# Generate every secret this stack needs, once, locally.
#
# Runs as the `bootstrap` job in bootstrap.yaml, the same way on every
# operating system:
#
#   docker compose -f bootstrap.yaml run --rm bootstrap
#   docker compose -f bootstrap.yaml run --rm bootstrap --force   # regenerate
#
# It runs in the Postgres image the stack already uses, which carries openssl
# and bash, so the host needs nothing but Docker. That is the point: an
# evaluator on Windows or macOS has neither a POSIX shell nor a predictable
# openssl, and a script that only runs on the host we tested is not a bundle.
#
# Nothing is fetched, registered or phoned home. The job runs with no network
# at all. Secrets are produced by `openssl rand` and written to two places that
# must agree:
#
#   .env                             — consumed by docker compose
#   secrets/keycloak/*-realm.json    — imported by Keycloak on first boot
#
# Writing both from ONE generated value is the point. The client secret and the
# evaluator password appear in both files, and if they drift the failure is
# opaque: Keycloak rejects the token exchange with invalid_client, or login
# silently fails, and neither says "your two config files disagree".
#
# Why not commit the keys instead: this bundle is handed to security reviewers,
# and the first thing they do is grep it for key material. Committed PEMs would
# also mean every evaluator shares one JWT signing key.
#
# Idempotent by refusal: it will not overwrite secrets that are already set,
# so re-running after editing .env is safe. Use --force to regenerate.
set -euo pipefail

cd "$(dirname "$0")/.."

# Nothing this writes is for anyone else. Without this the container's root
# umask (022) made every temporary copy of .env world-readable, and .env itself
# readable by all from the moment it was copied until the chmod further down.
# Files the services must read are opened up explicitly below.
umask 077

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

# The container runs as root, and on Linux a bind mount keeps the numeric owner,
# so everything written here would land root-owned and the .env the operator is
# told to edit would need sudo. Hand it all back to whoever owns this directory,
# on every exit path. On Docker Desktop (macOS, Windows) the mount maps
# ownership itself and chown is refused or ignored, which is fine.
OWNER=$(stat -c '%u:%g' .)
restore_owner() {
  chown -R "$OWNER" .env secrets 2>/dev/null || true
}
trap restore_owner EXIT

# --force AFTER the stack has run once will break it. Postgres and ClickHouse
# store the credentials they were initialised with, and Keycloak imports the
# realm only into an empty database, so regenerating leaves compose passing
# values the stack no longer accepts. Learned the direct way.
#
# The compose job mounts the database volume read-only at this path so the
# check works without handing the container the Docker socket.
if [ "$FORCE" -eq 1 ] && [ -f /stack/postgres-data/PG_VERSION ]; then
  echo "Refusing --force: this stack already has data volumes, and regenerating"
  echo "the database passwords would lock you out of them."
  echo
  echo "To start over from scratch (destroys evaluation data, which is fine):"
  echo "    docker compose down -v"
  echo "    docker compose -f bootstrap.yaml run --rm bootstrap --force"
  exit 1
fi

REALM_TEMPLATE="config/keycloak/highflame-realm.json"
REALM_RENDERED="secrets/keycloak/highflame-realm.json"
KEYS_DIR="secrets/keys"

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
command -v openssl >/dev/null || {
  echo "openssl not found. Run this through compose, which supplies it:"
  echo "    docker compose -f bootstrap.yaml run --rm bootstrap"
  exit 1
}

# Copying the example is the first thing every evaluator does, and `cp` is not a
# command on every host. Doing it here keeps the whole setup to docker commands.
if [ ! -f .env ]; then
  cp .env.example .env
  echo "created .env from .env.example"
fi

# An .env saved by a Windows editor has CRLF line endings. Compose tolerates
# them; this script does not, because every value read below would carry a
# trailing carriage return into the realm and the rendered configs, and the
# result is an issuer URL that is wrong by one invisible byte. Normalise once,
# in place, so the file keeps its owner and permissions.
if grep -q $'\r' .env; then
  tr -d '\r' < .env > .env.tmp && cat .env.tmp > .env && rm -f .env.tmp
  echo "converted .env line endings to LF"
fi

missing=()
for required in HIGHFLAME_LLM_BASE_URL HIGHFLAME_HOST_IP; do
  # tail -1, not head -1: docker compose honours the LAST assignment in a .env,
  # and appending to the bottom of the file is what people actually do. Reading
  # the first match meant the empty placeholder shipped in .env.example won, and
  # bootstrap insisted the variable was unset while compose would have used the
  # value fine.
  value=$(grep -E "^${required}=" .env | tail -1 | cut -d= -f2- || true)
  [ -z "$value" ] && missing+=("$required")
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "These must be set in .env before bootstrapping, then run it again:"
    printf '    %s\n' "${missing[@]}"
    echo

    for var in "${missing[@]}"; do
        case "$var" in
            HIGHFLAME_LLM_BASE_URL)
                echo "HIGHFLAME_LLM_BASE_URL is your own internal LLM endpoint — the stack"
                echo "never needs a public one. See .env.example for the reasoning."
                ;;
            HIGHFLAME_HOST_IP)
                echo "HIGHFLAME_HOST_IP must be set to the IP address of the host running the stack."
                echo "See .env.example for more information."
                ;;
        esac
    done
    exit 1
fi

mkdir -p "$(dirname "$REALM_RENDERED")" "$KEYS_DIR"

# ---------------------------------------------------------------------------
# Secret generation
# ---------------------------------------------------------------------------
# base64 then strip non-alphanumerics: several of these end up in URLs, YAML and
# JDBC connection strings, and a stray '/' or '+' breaks at least one of those in
# a way that is tedious to trace back to the password.
rand() { openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c "${1:-32}"; }

# set_env KEY — generate and write only if currently empty (or --force).
set_env() {
  local key="$1" len="${2:-32}" current
  current=$(grep -E "^${key}=" .env | head -1 | cut -d= -f2- || true)

  if [ -n "$current" ] && [ "$FORCE" -eq 0 ]; then
    echo "  keep      $key (already set)"
    return
  fi

  local value
  value=$(rand "$len")
  # Through a temp file, then copied back over rather than renamed, so .env
  # keeps its inode, owner and permissions. A rename would replace the operator's
  # file with one owned by this container's user.
  awk -v k="$key" -v v="$value" \
    'BEGIN{FS=OFS="="} $1==k {print k"="v; found=1; next} {print} END{if(!found) print k"="v}' \
    .env > .env.tmp && cat .env.tmp > .env && rm -f .env.tmp
  echo "  generated $key"
}

echo "generating secrets into .env"
set_env POSTGRES_PASSWORD 32
set_env CLICKHOUSE_PASSWORD 32
set_env KEYCLOAK_ADMIN_PASSWORD 24
set_env OIDC_CLIENT_SECRET 40
set_env EVALUATOR_PASSWORD 20
set_env AUTH_SECRET 44
# AuthN fails closed at startup on a key shorter than 32 bytes rather than
# starting up weak, so these are deliberately generous.
set_env HIGHFLAME_AUTH_JWT_SECRET_KEY 48
set_env HIGHFLAME_TOKEN_ENCRYPTION_KEY 48
set_env HIGHFLAME_INTERNAL_SERVICE_SECRET 48
set_env HIGHFLAME_MODELS_SECRET 32

chmod 600 .env

# ---------------------------------------------------------------------------
# Render the Keycloak realm from the SAME values
# ---------------------------------------------------------------------------
set -a; . ./.env; set +a

echo "rendering $REALM_RENDERED"

# The external origin, assembled exactly as compose assembles it, so the redirect
# URIs Keycloak will accept match the ones Studio actually sends. rootUrl is what
# the relative "/*" redirect URI resolves against; without it Keycloak has no
# base for the relative form and rejects the authorization request with
# invalid_redirect_uri, which reads like a client misconfiguration rather than a
# missing field.
# The origin a BROWSER uses to reach Studio. It is what the realm's rootUrl and
# redirect URIs resolve against, so it must equal the origin Studio actually
# serves on — otherwise Keycloak rejects the callback as invalid_redirect_uri.
#
# Two addressing styles are supported because the compose file has used both:
# HIGHFLAME_IP with per-service ports, and a single HIGHFLAME_HOSTNAME behind the
# nginx ingress. Deriving it here rather than hard-coding one keeps this file
# correct under either, instead of silently rendering a realm that disagrees with
# the compose that imports it.
# HIGHFLAME_HOST_IP is the name docker-compose.yaml uses and the one shipped in
# .env.example; HIGHFLAME_IP is accepted as an alias because this script used to
# ask for that and the error message named it. They were genuinely different
# variables before: setting the documented one left this script refusing to run,
# and setting the one this script asked for left compose building URLs against
# an empty host.
#
# No port. The browser reaches every service through the bundled nginx on :80,
# so the realm's redirect URIs must be built against that origin — see the
# single-origin note in docker-compose.yaml.
HOST_ADDR="${HIGHFLAME_HOST_IP:-${HIGHFLAME_IP:-}}"
if [ -n "$HOST_ADDR" ]; then
  EXTERNAL_URL="${CONN_PROTOCOL:-http}://${HOST_ADDR}"
elif [ -n "${HIGHFLAME_HOSTNAME:-}" ]; then
  EXTERNAL_URL="${CONN_PROTOCOL:-http}://${HIGHFLAME_HOSTNAME}${HIGHFLAME_PORT_SUFFIX:-}"
else
  echo "Set HIGHFLAME_HOST_IP (or HIGHFLAME_HOSTNAME) in .env — the realm's redirect"
  echo "URIs are built from it, and a realm with the wrong origin fails login"
  echo "with invalid_redirect_uri rather than anything that names the cause."
  exit 1
fi

# Substitution only — no JSON parsing. That is deliberate: it is what lets this
# run in an image that carries openssl and sed but no python, so the host needs
# nothing but docker. The template holds an explicit placeholder for every value
# rather than expecting a field to be inserted.
#
# `|` as the delimiter because EXTERNAL_URL contains slashes.
sed -e "s|REPLACE_ME_OIDC_CLIENT_SECRET|${OIDC_CLIENT_SECRET}|g" \
    -e "s|REPLACE_ME_EVALUATOR_PASSWORD|${EVALUATOR_PASSWORD}|g" \
    -e "s|REPLACE_ME_EXTERNAL_URL|${EXTERNAL_URL}|g" \
    "$REALM_TEMPLATE" > "$REALM_RENDERED"

# Fail loudly rather than importing a realm with a literal REPLACE_ME_ value,
# which would surface much later and much less clearly as invalid_client.
if grep -q "REPLACE_ME_" "$REALM_RENDERED"; then
  echo "  a placeholder survived rendering:"
  grep -o "REPLACE_ME_[A-Z_]*" "$REALM_RENDERED" | sort -u | sed "s/^/    /"
  rm -f "$REALM_RENDERED"
  exit 1
fi

# 644, not 600, for the same reason as the keys below: Keycloak reads this as
# its own uid (1000), not yours. 600 only worked where the operator happened to
# be uid 1000 too; anyone else got a Keycloak that could not import its realm.
# It holds the client secret and the evaluator password, so it is secrets/ being
# 700 that keeps other users on this host from reading it.
chmod 644 "$REALM_RENDERED"
echo "  client secret and evaluator password written from .env"

# ---------------------------------------------------------------------------
# Render Firehog's config
# ---------------------------------------------------------------------------
# Firehog does NOT expand ${VAR} in its config file. The release build takes the
# literal string and panics:
#
#   [SHIELD] shield.enabled=true but the Shield client could not be constructed
#   (invalid Shield URL: ${HIGHFLAME_SHIELD_URL}). Refusing to start unscanned.
#
# (Refusing to start rather than running unscanned is the right call by Firehog —
# it just means the config has to arrive already substituted.)
#
# Env-var expansion is per-service and inconsistent across this platform: Admin
# renders a config.yaml.template, Shield expands ${VAR} itself, Firehog does
# neither. Rendering here removes the need to know which is which.
echo "rendering secrets/firehog/config.yaml"
mkdir -p secrets/firehog
# Substitution only, same reasoning as the realm above: no python on the host.
# Every ${VAR} the template uses is named explicitly here, so adding one to the
# template without adding it here fails the check below rather than shipping a
# config with a literal ${...} in it — which is precisely the failure this step
# exists to prevent (firehog does not expand env vars itself and panics on the
# literal string).
sed -e "s|\${HIGHFLAME_SHIELD_URL}|${HIGHFLAME_SHIELD_URL:-http://highflame-shield:8070/v1/shield}|g" \
    -e "s|\${HIGHFLAME_INTERNAL_SERVICE_SECRET}|${HIGHFLAME_INTERNAL_SERVICE_SECRET}|g" \
    "config/firehog/config.yaml.template" > "secrets/firehog/config.yaml"

if grep -qE '\$\{[A-Z_]+\}' "secrets/firehog/config.yaml"; then
  echo "  unsubstituted placeholders remain:"
  grep -oE '\$\{[A-Z_]+\}' "secrets/firehog/config.yaml" | sort -u | sed "s/^/    /"
  rm -f "secrets/firehog/config.yaml"
  exit 1
fi

chmod 644 "secrets/firehog/config.yaml"
echo "  substituted, no placeholders left"

# ---------------------------------------------------------------------------
# AuthN signing keys — TWO pairs, with names AuthN actually looks for
# ---------------------------------------------------------------------------
# AuthN needs both, and it fails closed at startup on either being absent:
#
#   private.pem / public.pem          ECDSA P-256. AuthN's own signing keys.
#                                     config.yaml points at these paths directly.
#   rsa-private.pem / rsa-public.pem  RSA. RS256 tokens shared with Admin, which
#                                     Shield and Observatory verify.
#
# The filenames are not a choice. AuthN's config.yaml hard-codes
# /app/keys/private.pem, so generating only the RSA pair produces
# "private key not found at /app/keys/private.pem" and a crash loop — which is
# exactly what happened before this was fixed.
if [ -f "$KEYS_DIR/rsa-private.pem" ] && [ -f "$KEYS_DIR/private.pem" ] && [ "$FORCE" -eq 0 ]; then
  echo "keeping existing AuthN keypairs in $KEYS_DIR"
else
  echo "generating AuthN RS256 keypair in $KEYS_DIR"
  openssl genrsa -out "$KEYS_DIR/rsa-private.pem" 2048 2>/dev/null
  openssl rsa -in "$KEYS_DIR/rsa-private.pem" -pubout -out "$KEYS_DIR/rsa-public.pem" 2>/dev/null

  echo "generating AuthN ECDSA P-256 keypair in $KEYS_DIR"
  openssl ecparam -name prime256v1 -genkey -noout -out "$KEYS_DIR/private.pem" 2>/dev/null
  openssl ec -in "$KEYS_DIR/private.pem" -pubout -out "$KEYS_DIR/public.pem" 2>/dev/null

  # 644, not 600. These are bind-mounted into containers that run as uid 10000,
  # while the files end up owned by you (see restore_owner above) — so 600 makes
  # them unreadable inside the container and AuthN dies with "permission denied"
  # on its own private key. Owning them as uid 10000 instead would leave you
  # unable to read your own keys without root.
  #
  # Other users on this host still cannot read them: secrets/ itself is 700 (see
  # the end of this file). The Docker daemon resolves bind-mount sources as root,
  # so the containers never need to pass through it.
fi

# Outside the branch on purpose. Permissions must be corrected even when the keys
# were kept, or a re-run against keys generated by an older version of this script
# leaves them unreadable inside the containers — which is exactly what happened:
# bootstrap said "keeping existing keypairs", skipped the chmod, and AuthN kept
# dying on "permission denied".
chmod 644 "$KEYS_DIR"/*.pem

# ---------------------------------------------------------------------------
# AuthZ policy-signing keys (ED25519)
# ---------------------------------------------------------------------------
# Named private.key / public.key because authz's config.yaml points at those
# exact paths. Same lesson as AuthN's keys: the filenames are not a choice, and
# 644 so the container user (uid 10000) can read them.
AUTHZ_KEYS="secrets/authz-keys"
mkdir -p "$AUTHZ_KEYS"
if [ -f "$AUTHZ_KEYS/private.key" ] && [ "$FORCE" -eq 0 ]; then
  echo "keeping existing AuthZ keypair in $AUTHZ_KEYS"
else
  echo "generating AuthZ ED25519 keypair in $AUTHZ_KEYS"
  openssl genpkey -algorithm ed25519 -out "$AUTHZ_KEYS/private.key" 2>/dev/null
  openssl pkey -in "$AUTHZ_KEYS/private.key" -pubout -out "$AUTHZ_KEYS/public.key" 2>/dev/null
fi
chmod 644 "$AUTHZ_KEYS"/*.key

# ---------------------------------------------------------------------------
# Directory permissions
# ---------------------------------------------------------------------------
# The files above are 644 because the services read them as their own uids.
# What keeps other users on this host out is the top directory: 700, owned by
# you. The subdirectories are 755 because keys/ and authz-keys/ are mounted as
# directories, and a container user has to be able to list them; they are only
# reachable through secrets/, so that exposes nothing.
chmod 755 secrets/keycloak secrets/firehog "$KEYS_DIR" "$AUTHZ_KEYS"
chmod 700 secrets

# ---------------------------------------------------------------------------
# Warn about services left on "latest"
# ---------------------------------------------------------------------------
# Three times now a fix has merged, the bundle has pointed at "latest", and
# "latest" has been the build from before the fix — shipping the defect the
# release was cut to remove, with nothing in the stack saying so. It happened
# with the tenant-boundary fix (admin#1331, needed v1.1.1) and again with
# agent authorization (shield#513).
#
# "latest" is a moving pointer to whatever was published last, which is not the
# same as "the newest build" and is never the same as "a build containing the
# thing you need". This warns rather than fails, because an unpinned tag is the
# right default while evaluating and the wrong one when handing the bundle to
# someone else.
#
# The names are the ones docker-compose.yaml reads, and an unset one IS latest,
# because that is the compose default. This used to check names compose never
# read and required an explicit `=latest`, so it never fired — and under
# pipefail the grep that found nothing ended the script before it said
# "Bootstrap complete".
unpinned=""
for var in HIGHFLAME_ADMIN_IMG_VERSION HIGHFLAME_AUTHN_IMG_VERSION HIGHFLAME_AUTHZ_IMG_VERSION \
           HIGHFLAME_SHIELD_IMG_VERSION HIGHFLAME_COLLECTOR_IMG_VERSION HIGHFLAME_CERBERUS_IMG_VERSION \
           HIGHFLAME_OBS_IMG_VERSION HIGHFLAME_FIREHOG_IMG_VERSION HIGHFLAME_STUDIO_IMG_VERSION \
           HIGHFLAME_FLAG_IMG_VERSION; do
  value=$(grep -E "^${var}=" .env | tail -1 | cut -d= -f2- || true)
  if [ -z "$value" ] || [ "$value" = "latest" ]; then
    name=${var#HIGHFLAME_}
    unpinned="$unpinned ${name%_IMG_VERSION}"
  fi
done

if [ -n "$unpinned" ]; then
  echo
  echo "NOTE: these services are on 'latest', so what you get depends on when you pull:"
  echo "  ${unpinned# }"
  echo "  Pin them in .env before sharing this bundle."
fi

cat <<EOF

Bootstrap complete.

  next:   docker compose up -d
          # starts the stack, then the seed job provisions the organization,
          # its default project and that project's default policies, and adds
          # your membership. Its output has the account and project ids:
  then:   docker compose logs seed

Sign in at ${EXTERNAL_URL} as 'evaluator'.
The password is EVALUATOR_PASSWORD in .env.

Do not commit .env or secrets/ — both are gitignored.
EOF
