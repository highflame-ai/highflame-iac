#!/usr/bin/env bash
#
# Prove — don't assert — that this stack cannot phone home.
#
# Run this yourself. It is deliberately written to be read in full before it is
# trusted: every check states what it proves, what it does NOT prove, and prints
# the raw evidence rather than a summary you have to believe. Output is also
# written to a report file you can attach to your own security review.
#
# Exit code 0 = every check passed. Non-zero = at least one FAIL. A WARN is a
# check that could not be completed (usually a container without a shell), and is
# reported as unproven rather than quietly passing.
#
#   ./verify/no-egress.sh                 # human-readable
#   ./verify/no-egress.sh --report out.txt
#
set -uo pipefail

# Ask compose what the project is called rather than hard-coding it. The name
# lives in docker-compose.yaml and has already been changed once; a stale
# constant here does not fail loudly, it fails as "network does not exist — is
# the stack up?", which sends the reader to look at a stack that is running
# perfectly well.
PROJECT="${COMPOSE_PROJECT_NAME:-}"
if [ -z "$PROJECT" ]; then
  PROJECT=$(docker compose config 2>/dev/null | sed -n 's/^name: *//p' | head -1)
fi
PROJECT="${PROJECT:-highflame-airgap}"
APP_NET="${PROJECT}_app"
EDGE_NET="${PROJECT}_edge"
# A busybox-based image already present in the offline bundle, so this script
# needs no network of its own to run.
PROBE_IMAGE="${PROBE_IMAGE:-nginx:1.27-alpine}"

REPORT=""
[ "${1:-}" = "--report" ] && REPORT="${2:?--report needs a path}"

PASS=0 FAIL=0 WARN=0 UNEXPECTED_WARN=0

# Warnings we know about and accept. Anything warning for a reason NOT on this
# list fails the run.
#
# The reason is specific rather than principled hand-wringing. Twice now a check
# in this file has quietly excused itself and the summary still read PASS: once
# when a renamed variable made it report "could not read firehog's configured LLM
# endpoint" — leaving the ONE permitted egress path unverified — and once when a
# stale project name made it say the network did not exist. Both times the
# overall verdict stayed green and the exit code stayed 0, so anything automated
# would have treated an unchecked stack as a clean one.
#
# "Could not check" must not read as "checked and fine". A genuinely unprovable
# check belongs here, named, so adding one is a decision somebody makes on
# purpose rather than a check silently going quiet.
EXPECTED_WARNINGS='no shell available'

say() { printf '%s\n' "$*"; [ -n "$REPORT" ] && printf '%s\n' "$*" >>"$REPORT"; }
ok()   { PASS=$((PASS+1)); say "  PASS  $*"; }
bad()  { FAIL=$((FAIL+1)); say "  FAIL  $*"; }
warn() {
  WARN=$((WARN+1))

  if printf '%s' "$*" | grep -qE "$EXPECTED_WARNINGS"; then
    say "  WARN  $*"
  else
    UNEXPECTED_WARN=$((UNEXPECTED_WARN+1))
    say "  WARN  $* [UNEXPECTED — this check did not run, so nothing here is proven]"
  fi
}
hdr()  { say ""; say "=== $* ==="; }

[ -n "$REPORT" ] && : >"$REPORT"

say "Highflame air-gapped evaluation — egress verification"
say "project: $PROJECT"
say "date:    $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
say "host:    $(uname -srm)"

# ---------------------------------------------------------------------------
hdr "1. The application network has no route off this machine"
# Docker's `internal: true` does not add a gateway to the bridge. This is a
# property of how the network was created, not a firewall rule someone can
# forget — which is why it is checked first and checked structurally.
# ---------------------------------------------------------------------------
if ! docker network inspect "$APP_NET" >/dev/null 2>&1; then
  bad "network $APP_NET does not exist — is the stack up? (docker compose up -d)"
  say ""
  say "SUMMARY: pass=$PASS fail=$FAIL warn=$WARN"
  exit 1
fi

INTERNAL=$(docker network inspect "$APP_NET" --format '{{.Internal}}')
say "  docker network inspect $APP_NET --format '{{.Internal}}' -> $INTERNAL"
if [ "$INTERNAL" = "true" ]; then
  ok "$APP_NET is an internal network (no gateway, no NAT to the host's uplink)"
else
  bad "$APP_NET is NOT internal — containers on it can reach the internet"
fi

# ---------------------------------------------------------------------------
hdr "2. Only the two intended services can reach outside"
# nginx needs it so your browser can reach the UI. firehog needs it because a
# gateway that inspects LLM traffic must reach the LLM you configured. Anything
# else appearing here is a finding.
# ---------------------------------------------------------------------------
EXPECTED_EDGE="highflame-firehog highflame-nginx"
if docker network inspect "$EDGE_NET" >/dev/null 2>&1; then
  ACTUAL_EDGE=$(docker network inspect "$EDGE_NET" \
    --format '{{range .Containers}}{{.Name}} {{end}}' | tr ' ' '\n' | grep -v '^$' | sort | tr '\n' ' ' | sed 's/ $//')
  say "  on $EDGE_NET: ${ACTUAL_EDGE:-<none>}"
  say "  expected:    $EXPECTED_EDGE"
  if [ "$ACTUAL_EDGE" = "$EXPECTED_EDGE" ]; then
    ok "exactly the two intended services are externally connected"
  else
    bad "unexpected membership of the externally-routable network"
  fi
else
  warn "network $EDGE_NET not found — cannot confirm which services are externally connected"
fi

# ---------------------------------------------------------------------------
hdr "3. Empirical: a container on the app network cannot open an outbound connection"
# Checks 1 and 2 are structural. This one actually tries, from inside the same
# network the Highflame services run on, and must fail.
#
# Note honestly what this does NOT prove: it demonstrates the network has no
# route, not that any particular service refrained from trying. Check 5 covers
# intent by inspecting configuration.
# ---------------------------------------------------------------------------
for target in 1.1.1.1:53 8.8.8.8:53; do
  host=${target%:*}; port=${target#*:}
  if docker run --rm --network "$APP_NET" "$PROBE_IMAGE" \
       timeout 5 nc -z "$host" "$port" >/dev/null 2>&1; then
    bad "reached $target from $APP_NET — the network is NOT isolated"
  else
    ok "could not reach $target from $APP_NET (connection has nowhere to go)"
  fi
done

# DNS resolution of an external name should also fail on an internal network.
if docker run --rm --network "$APP_NET" "$PROBE_IMAGE" \
     timeout 5 nslookup api.highflame.ai >/dev/null 2>&1; then
  warn "external DNS resolved from $APP_NET — resolution alone is not egress, but check your DNS setup"
else
  ok "external DNS does not resolve from $APP_NET"
fi

# ---------------------------------------------------------------------------
hdr "4. No live connection to a Highflame-operated or analytics endpoint"
# Reads each container's own kernel connection table where possible. Containers
# without a shell are reported as WARN, never silently skipped.
# ---------------------------------------------------------------------------
# Hosted services this product touches in its SaaS configuration and must not
# touch here. Passed to python, not awk: awk's -v strips the backslash from
# `\.`, turning it into "any character" — which matched our own `highflame-ai`
# image names against the pattern `highflame\.ai`. A checker that cries wolf is
# worse than no checker.
BANNED_HOSTS='highflame\.ai|clerk\.com|clerk\.accounts|posthog|sentry\.io|segment\.io|unkey\.(dev|io)|googleapis\.com|storage\.cloud\.google|huggingface\.co|hf\.co'

CONTAINERS=$(docker ps --filter "label=com.docker.compose.project=$PROJECT" --format '{{.Names}}' | sort)
if [ -z "$CONTAINERS" ]; then
  warn "no running containers for project $PROJECT"
fi

# Decode /proc/net/tcp and report only genuinely non-private remotes.
#
# The addresses there are LITTLE-ENDIAN hex, which is the trap: 172.23.0.4 is
# written `040017AC`. An earlier version of this script pattern-matched the hex
# prefix as if it were big-endian, so every ordinary container-to-container
# connection on the Docker bridge looked like egress and the whole run failed.
read_external() {
  docker exec "$1" sh -c 'cat /proc/net/tcp /proc/net/tcp6 2>/dev/null' 2>/dev/null |
  python3 -c '
import ipaddress, sys

def decode(hexaddr):
    # IPv4: 8 hex chars, little-endian per 4-byte word.
    if len(hexaddr) == 8:
        b = bytes.fromhex(hexaddr)[::-1]
        return ipaddress.IPv4Address(b)
    # IPv6: 32 hex chars, little-endian within each 4-byte word.
    if len(hexaddr) == 32:
        words = [bytes.fromhex(hexaddr[i:i+8])[::-1] for i in range(0, 32, 8)]
        return ipaddress.IPv6Address(b"".join(words))
    return None

out = []
for line in sys.stdin:
    parts = line.split()
    if len(parts) < 4 or ":" not in parts[2]:
        continue
    if parts[3] != "01":          # 01 = ESTABLISHED
        continue
    host, _, port = parts[2].rpartition(":")
    try:
        ip = decode(host)
    except Exception:
        continue
    if ip is None:
        continue
    # Loopback, link-local, RFC1918 and the IPv6 equivalents are all local.
    if ip.is_private or ip.is_loopback or ip.is_link_local or ip.is_unspecified:
        continue
    out.append(f"{ip}:{int(port, 16)}")

for entry in sorted(set(out))[:5]:
    print(entry)
'
}

for c in $CONTAINERS; do
  if ! docker exec "$c" sh -c 'true' >/dev/null 2>&1; then
    warn "$c: no shell available, could not read its connection table (unproven, not passed)"
    continue
  fi

  external=$(read_external "$c")
  if [ -n "$external" ]; then
    say "  $c -> $(printf '%s' "$external" | tr '\n' ' ')"
    case "$c" in
      highflame-firehog|highflame-nginx)
        ok "$c has external connections — expected for this service" ;;
      *) bad "$c has an external connection and should not" ;;
    esac
  else
    ok "$c holds no connection to a public address"
  fi
done

# ---------------------------------------------------------------------------
hdr "5. Configuration does not point at Highflame-operated services"
# Intent, not just capability. The SaaS defaults send detector inference to
# guard.gpu-models.highflame.ai; if that reappears here, prompt content would be
# leaving the box the moment the network allowed it.
# ---------------------------------------------------------------------------
CFG=$(docker compose config 2>/dev/null)
if [ -z "$CFG" ]; then
  warn "could not render 'docker compose config' — run this from the airgap-eval directory"
else
  # Match on the VALUE, never the key, and do it in python so the regex means
  # what it says. Two separate bugs lived here:
  #   * matching the whole line flagged `NEXT_PUBLIC_POSTHOG_KEY: ""` — a name
  #     containing a banned word whose empty value is exactly what we want
  #   * awk -v strips `\.`, so `highflame\.ai` became `highflame.ai` with `.`
  #     as a wildcard, matching our own `highflame-ai` image names
  hits=$(printf '%s\n' "$CFG" | BANNED="$BANNED_HOSTS" python3 -c '
import os, re, sys

pattern = re.compile(os.environ["BANNED"], re.IGNORECASE)
for number, line in enumerate(sys.stdin, 1):
    _, sep, value = line.partition(":")
    if not sep or value.strip().startswith("#"):
        continue
    if pattern.search(value):
        print(f"  {number}: {line.rstrip()}")
' || true)
  if [ -n "$hits" ]; then
    say "$hits"
    bad "resolved configuration points at a Highflame-operated or analytics host"
  else
    ok "no Highflame-operated or analytics host in any configured value"
  fi

  # Detector models must resolve to in-stack services.
  guards=$(printf '%s\n' "$CFG" | grep -iE 'HIGHFLAME_GUARD[A-Z_]*_URL' || true)
  say "  detector endpoints:"
  printf '%s\n' "$guards" | sed 's/^/    /' | while read -r l; do [ -n "$l" ] && say "$l"; done
  # This bundle ships without the ML model servers, so these endpoints are
  # expected to be unresolvable (`.disabled.invalid`). What matters is not that
  # they resolve, but that they never point OUTWARD — the hosted product sends
  # this content to guard.gpu-models.highflame.ai.
  if printf '%s\n' "$guards" | grep -qiE 'gpu-models|highflame\.ai'; then
    bad "a detector model endpoint points outside the stack — prompt content would leave the box"
  else
    ok "no detector model endpoint points outside the stack"
  fi
fi

# ---------------------------------------------------------------------------
hdr "6. The one permitted egress goes only where you configured it"
# firehog is allowed out, to your LLM. This prints what it was configured with so
# you can confirm it is YOUR endpoint and nothing else.
# ---------------------------------------------------------------------------
# OPENAI_BASE_URL, not HIGHFLAME_LLM_BASE_URL. The latter is what .env calls the
# setting, but firehog reads nothing by that name — it takes per-provider
# variables, and HIGHFLAME_LLM_BASE_URL feeds the OpenAI-compatible one. This
# check read the old name after that changed and reported "could not read
# firehog's configured LLM endpoint", which is the check quietly excusing itself
# rather than failing: the one permitted egress went unverified while the run
# still said PASS overall.
LLM=$(docker inspect highflame-firehog \
  --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | grep '^OPENAI_BASE_URL=' | cut -d= -f2- || true)
if [ -n "$LLM" ]; then
  say "  firehog LLM endpoint: $LLM"
  if printf '%s' "$LLM" | grep -qiE 'highflame\.ai'; then
    bad "the configured LLM endpoint is a Highflame-operated host"
  else
    ok "the configured LLM endpoint is yours, not ours"
  fi
else
  warn "could not read firehog's configured LLM endpoint"
fi

# ---------------------------------------------------------------------------
hdr "7. Every LLM provider endpoint is pinned, and none of them is public"
# The check that would have caught the one this script missed.
#
# Checks 1-6 read configuration, and configuration is exactly where this problem
# is not. firehog carries a compiled-in provider table whose fourteen entries all
# default to a public endpoint — api.openai.com, api.anthropic.com,
# generativelanguage.googleapis.com and so on — each overridable by its own
# environment variable. An UNSET variable therefore means "use the public
# default", so absence of configuration is the vulnerability, and a checker that
# reads what is present finds nothing to report.
#
# It found nothing to report. This script passed 19/0/1 on a stack that answered
# an openai/gpt-4 request with a 401 from OpenAI in 207ms — a live endpoint, on a
# stack whose whole claim is that nothing leaves. So: unset is a FAIL here, not a
# skip.
#
# Read from the RUNNING container rather than compose config, because what the
# process actually received is the thing that matters.
# ---------------------------------------------------------------------------
PROVIDER_VARS="OPENAI_BASE_URL OPENAI_CHATGPT_BASE_URL ANTHROPIC_BASE_URL GEMINI_BASE_URL VERTEX_BASE_URL GROQ_BASE_URL MISTRAL_BASE_URL OLLAMA_BASE_URL TOGETHER_BASE_URL DEEPSEEK_BASE_URL XAI_BASE_URL ZAI_BASE_URL AZURE_OPENAI_ENDPOINT BEDROCK_ENDPOINT"

if ! docker inspect highflame-firehog >/dev/null 2>&1; then
  warn "highflame-firehog is not running — provider endpoints unproven, not passed"
else
  FH_ENV=$(docker inspect highflame-firehog --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null)

  unset_vars=""
  public_vars=""
  for var in $PROVIDER_VARS; do
    value=$(printf '%s\n' "$FH_ENV" | sed -n "s|^${var}=||p" | head -1)

    if [ -z "$value" ]; then
      # The failure mode that produced the incident: no value means the binary's
      # own public default applies.
      unset_vars="$unset_vars $var"
      continue
    fi

    # Anything that is not obviously internal is treated as public. Deliberately
    # a denylist of shapes we accept rather than of hosts we reject: the list of
    # public LLM endpoints grows, and a new provider must fail this check rather
    # than pass it by not being known yet.
    case "$value" in
      *.disabled.invalid*|*.invalid*|http://highflame-*|https://highflame-*) : ;;
      *localhost*|*127.0.0.1*) : ;;
      *)
        # Whatever the operator configured as their own endpoint is reported so a
        # reviewer can confirm it, rather than silently accepted.
        say "  configured: $var = $value"
        case "$value" in
          *api.openai.com*|*api.anthropic.com*|*googleapis.com*|*api.groq.com*|\
          *api.mistral.ai*|*api.together.xyz*|*api.deepseek.com*|*api.x.ai*|\
          *openai.azure.com*|*amazonaws.com*|*bigmodel.cn*|*chatgpt.com*)
            public_vars="$public_vars $var" ;;
        esac ;;
    esac
  done

  if [ -n "$unset_vars" ]; then
    say "  unset (the binary's public default applies):$unset_vars"
    bad "one or more provider endpoints are unset and will fall back to a public service"
  else
    ok "every provider endpoint is explicitly set — none left to a built-in default"
  fi

  if [ -n "$public_vars" ]; then
    say "  public:$public_vars"
    bad "a provider endpoint points at a public LLM service"
  else
    ok "no provider endpoint names a public LLM service"
  fi
fi

# ---------------------------------------------------------------------------
say ""
say "============================================================"
say "SUMMARY: pass=$PASS fail=$FAIL warn=$WARN"
if [ "$FAIL" -gt 0 ]; then
  say "RESULT: FAIL — at least one check found egress or egress-capable configuration."
elif [ "$UNEXPECTED_WARN" -gt 0 ]; then
  say "RESULT: FAIL — $UNEXPECTED_WARN check(s) did not run."
  say "        Nothing was found wrong, but nothing was checked either, and a"
  say "        check that cannot run proves less than one that fails."
elif [ "$WARN" -gt 0 ]; then
  say "RESULT: PASS WITH KNOWN-UNPROVABLE CHECKS — $WARN check(s) could not be"
  say "        completed for reasons this script recognises. Treat those as"
  say "        unverified rather than as passes."
else
  say "RESULT: PASS — no egress path found outside the one you configured."
fi
say "============================================================"
[ -n "$REPORT" ] && say "" && say "report written to $REPORT"

exit $(( FAIL > 0 || UNEXPECTED_WARN > 0 ? 1 : 0 ))
