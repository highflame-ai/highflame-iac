#!/usr/bin/env bash
#
# Create the evaluator's organization, default project and membership.
#
# Runs as the `seed` job in docker-compose.yaml, automatically, at the end of
# every `docker compose up`. It is not run by hand on the host any more: it
# needed bash and python3 there, which ruled out a Windows evaluator and made
# macOS depend on whichever python the machine happened to have. Inside the
# stack it needs neither, and it reaches the database and the ingress by their
# service names instead of through published host ports. See what it did with:
#
#   docker compose logs seed
#
# ============================================================================
# Why this job has to exist
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
# Idempotent: it runs on every `up`, against a fresh or an already-seeded stack.
set -euo pipefail

cd "$(dirname "$0")/.."

# The temporary copy of .env written below holds every secret; keep it private.
umask 077

# Run as whoever owns this directory, so the .env this job updates stays theirs
# and a root-squashed NFS home does not refuse the write. Same rule as
# bootstrap/generate.sh: an owner that reads as root means container root
# already maps to the operator.
OWNER=$(stat -c '%u:%g' .)
if [ "$(id -u)" = 0 ] && [ "${OWNER%%:*}" != 0 ]; then
  exec gosu "$OWNER" bash "$0" "$@"
fi

# PGHOST, PGUSER, PGPASSWORD and PGDATABASE come from the compose job, so every
# psql call below reaches the stack's database with no flags.
: "${HIGHFLAME_HOST_IP:?HIGHFLAME_HOST_IP is empty — set it in .env}"

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
# this job finds the tenant it made last time instead of making another.
AUTH_ORG_ID="airgap-eval"

# The organization and project UUIDs are NOT pinned here. They are whatever
# provisioning assigns, and this job writes them into .env for the notebook to
# read. Pinning them meant creating the rows by hand, which is how this tenant
# used to skip everything else provisioning does.

echo "waiting for Admin to finish its first-boot migrations..."
# account_members is created by Admin's tenancy migration. Polling for the TABLE
# rather than for a health endpoint is the honest check: a healthy Admin that has
# not yet migrated would make the insert below fail confusingly.
migrated() {
  psql -tAc "SELECT to_regclass('public.account_members') IS NOT NULL" 2>/dev/null | grep -q '^t$'
}
for _ in $(seq 1 60); do
  migrated && break
  sleep 5
done

if ! migrated; then
  echo
  echo "FAILED: account_members never appeared, so nothing was seeded."
  echo
  echo "  Admin still migrating, or failing?    docker compose logs highflame-admin"
  echo "  Then retry just this job:             docker compose up -d seed"
  exit 1
fi
echo "  account_members exists"

# ----------------------------------------------------------------------------
# Provision the organization and its default project through the product.
#
# This used to be two INSERTs into `tenants`. Writing those rows by hand
# produced a tenant that looked complete and was not: provisioning also gives a
# new project its default policies, and Cedar is default-deny, so a project
# created behind the product's back denies everything and names no policy while
# doing it. Everything the product does on the way is now done.
#
# Through the ingress, the path a browser takes, addressed by its service name
# so it does not depend on the host routing its own LAN address back to itself.
# No Host header is needed: nginx serves any name, and Keycloak stamps the
# issuer from KC_HOSTNAME rather than from the request, which Admin then checks
# — so a successful provision below is itself proof the issuer is right.
#
# Perl because it is what this image has for HTTP and JSON; the modules used
# are part of core Perl.
#
# Only the membership below still needs direct database access.
# ----------------------------------------------------------------------------
echo "provisioning the organization and its default project..."

PROVISION_OUT=$(
  HIGHFLAME_ACCOUNT_ID="$ACCOUNT_ID" \
  HIGHFLAME_AUTH_ORG_ID="$AUTH_ORG_ID" \
  perl - <<'PERL'
use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP qw(decode_json encode_json);

my $base = 'http://highflame-nginx';
my $http = HTTP::Tiny->new(timeout => 30);

sub call {
    my ($method, $path, %opt) = @_;
    my %headers;
    $headers{Authorization} = "Bearer $opt{token}" if $opt{token};

    my %args = (headers => \%headers);
    if ($opt{form}) {
        $headers{'Content-Type'} = 'application/x-www-form-urlencoded';
        $args{content} = $http->www_form_urlencode($opt{form});
    } elsif ($opt{json}) {
        $headers{'Content-Type'} = 'application/json';
        $args{content} = encode_json($opt{json});
    }

    my $res = $http->request($method, $base . $path, \%args);
    # HTTP::Tiny reports its own connection failures as 599; treat them the
    # way the rest of this job treats "no answer", as status 0.
    my $status = $res->{status} == 599 ? 0 : $res->{status};
    return ($status, $res->{content} // '');
}

sub fail { print STDERR "  $_[0]\n"; exit 1 }

# The API has to be reachable, not merely migrated. Waiting here keeps the
# failure legible: without it an unready Admin looks like a provisioning bug.
# Any answer below 500 counts, including the 401 an unauthenticated health
# probe gets: it proves the request reached Admin.
my ($ready, $last) = (0, '');
for (1 .. 60) {
    my ($status, $raw) = call('GET', '/v1/admin/health');
    if ($status && $status < 500) { $ready = 1; last }
    $last = $status ? "HTTP $status" : $raw;
    sleep 5;
}
fail("Admin never became reachable through the ingress (last: $last); docker compose ps")
    unless $ready;

my ($status, $raw) = call(
    'POST', '/auth/realms/highflame/protocol/openid-connect/token',
    form => {
        client_id     => 'highflame-studio',
        client_secret => $ENV{OIDC_CLIENT_SECRET} // '',
        grant_type    => 'password',
        username      => 'evaluator',
        password      => $ENV{EVALUATOR_PASSWORD} // '',
        scope         => 'openid',
    },
);
fail("keycloak returned $status: " . substr($raw, 0, 200)) unless $status == 200;

my $token = eval { decode_json($raw)->{id_token} };
fail('no id_token in the keycloak response') unless $token;

# account_id is pinned so the docs and the notebook can name it. The org and
# project UUIDs are the product's to choose. auth_provider says who actually
# authenticated the caller, rather than letting it default to Clerk.
($status, $raw) = call(
    'POST', '/v1/admin/tenancy/provision',
    token => $token,
    json  => {
        auth_org_id   => $ENV{HIGHFLAME_AUTH_ORG_ID},
        auth_provider => 'oidc',
        account_id    => $ENV{HIGHFLAME_ACCOUNT_ID},
        org_name      => 'Evaluation',
    },
);
fail("provisioning failed: $status " . substr($raw, 0, 300))
    unless $status == 200 || $status == 201;

my $body       = eval { decode_json($raw) } || {};
my $org        = $body->{organization}    || {};
my $project    = $body->{default_project} || {};
my $project_id = $project->{id} || $body->{default_project_id} || '';
fail('provisioning returned no default project: ' . substr($raw, 0, 300)) unless $project_id;

# Consumed by the shell below.
print(($org->{id} // ''), "\n", $project_id, "\n");
PERL
) || exit 1

ORG_UUID=$(printf '%s\n' "$PROVISION_OUT" | sed -n '1p')
PROJECT_UUID=$(printf '%s\n' "$PROVISION_OUT" | sed -n '2p')

# The project id goes into .env below, so accept nothing but a UUID: whatever
# the response held, it must not be able to add a line to that file.
uuid_re='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
if ! [[ "$PROJECT_UUID" =~ $uuid_re ]]; then
  echo "FAILED: provisioning returned a project id that is not a UUID; .env left unchanged."
  exit 1
fi
echo "  organization    ${ORG_UUID}"
echo "  default project ${PROJECT_UUID}"

# The membership that makes login possible. source='oidc' records provenance
# distinctly from clerk/scim/manual/mapping, so reconciliation can tell where
# the row came from.
#
# DO NOTHING on conflict, because this now runs on every `up`. Re-asserting the
# row each time would quietly re-activate an evaluator an operator had
# deactivated, or restore a role they had lowered, on the next restart.
psql -v ON_ERROR_STOP=1 -q <<SQL
INSERT INTO account_members (account_id, user_id, org_role, source, is_active)
VALUES ('${ACCOUNT_ID}', '${EVALUATOR_SUB}', 'admin', 'oidc', true)
ON CONFLICT (account_id, user_id) DO NOTHING;
SQL

# Verify rather than assume, and say which of the two failures this is.
MEMBERSHIP=$(psql -tAc \
  "SELECT is_active FROM account_members
    WHERE account_id = '${ACCOUNT_ID}' AND user_id = '${EVALUATOR_SUB}'")

case "$MEMBERSHIP" in
  t) echo "  membership      evaluator is an active member of ${ACCOUNT_ID}" ;;
  f)
    echo "  membership      evaluator is present but DEACTIVATED in ${ACCOUNT_ID};"
    echo "                  left as an operator set it, so their login returns 403"
    ;;
  *)
    echo
    echo "FAILED: the membership row is not present after seeding."
    echo "Nothing below would work, so this is an error rather than a warning."
    echo "  docker compose logs highflame-db"
    exit 1
    ;;
esac

# Record the ids provisioning chose, so the notebook reads them instead of
# carrying literals that have to be kept in step with this job by hand.
# Upsert rather than append: re-running must not leave two of each. Written
# back over the file rather than renamed onto it, so .env keeps its permissions.
upsert_env() {
  local key="$1" value="$2"
  # Leave the file alone when it already says this. The job runs on every
  # `up`, and rewriting an unchanged .env each time only risks racing an editor
  # that has it open.
  [ "$(grep -E "^${key}=" .env | tail -1 | cut -d= -f2- || true)" = "$value" ] && return 0
  awk -v k="$key" -v v="$value" \
    'BEGIN{FS=OFS="="} $1==k {print k"="v; found=1; next} {print} END{if(!found) print k"="v}' \
    .env > .env.tmp && cat .env.tmp > .env && rm -f .env.tmp
}
upsert_env HIGHFLAME_ACCOUNT_ID "$ACCOUNT_ID"
upsert_env HIGHFLAME_PROJECT_ID "$PROJECT_UUID"
echo "  recorded HIGHFLAME_ACCOUNT_ID and HIGHFLAME_PROJECT_ID in .env"

cat <<EOF

Ready. Sign in at ${CONN_PROTOCOL:-http}://${HIGHFLAME_HOST_IP}

  username    evaluator
  password    (EVALUATOR_PASSWORD from .env)
  account_id  ${ACCOUNT_ID}
  project_id  ${PROJECT_UUID}

The account_id and project_id above are what the cookbook notebook uses.
EOF
