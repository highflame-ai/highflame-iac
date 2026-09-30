# shellcheck shell=bash
# Reading and writing .env the way docker compose reads it. Sourced by the
# setup jobs (generate.sh, preflight.sh, seed-tenant.sh), which all run with the
# bundle directory as their working directory.
#
# Every job has to agree with compose on what a line means. When one of them
# read values differently — raw text after `KEY=` — a quoted or commented value
# was one thing to compose and another to the job, and the job's advice to
# re-run bootstrap could never clear the mismatch it reported.
#
# .env is never sourced: that runs it as shell, and the seed job writes to it.

# The key pattern compose accepts: optional leading space, an optional
# `export `, optional space around `=`.
env_key_re() { printf '^[[:space:]]*(export[[:space:]]+)?%s[[:space:]]*=' "$1"; }

# env_get KEY — the value compose would use: last assignment wins, surrounding
# whitespace is dropped, one pair of matching quotes is removed, and an unquoted
# value ends at whitespace followed by `#`. Escapes inside double quotes and
# ${VAR} expansion are not handled; nothing this bundle generates uses either.
env_get() {
  local v
  v=$(grep -E "$(env_key_re "$1")" .env 2>/dev/null | tail -1 | cut -d= -f2- || true)
  v="${v#"${v%%[![:space:]]*}"}"
  case "$v" in
    \"*) v="${v#\"}"; v="${v%%\"*}" ;;
    \'*) v="${v#\'}"; v="${v%%\'*}" ;;
    *)   v="${v%%[[:space:]]#*}"; v="${v%"${v##*[![:space:]]}"}" ;;
  esac
  printf '%s' "$v"
}

# env_set KEY VALUE — replace every assignment of KEY, in any form env_get
# accepts, with KEY=VALUE, or append one. Rewriting every copy matters: compose
# reads the last, so leaving an older form in place can shadow the new value.
#
# Through a temp file, then copied back over rather than renamed, so .env keeps
# its inode, owner and permissions. Callers set umask 077 so the temp file is
# never readable by anyone else.
env_set() {
  awk -v k="$1" -v v="$2" '
    { line = $0; sub(/^[[:space:]]*(export[[:space:]]+)?/, "", line) }
    index(line, k) == 1 && substr(line, length(k) + 1) ~ /^[[:space:]]*=/ {
      if (!found) print k "=" v
      found = 1
      next
    }
    { print }
    END { if (!found) print k "=" v }
  ' .env > .env.tmp && cat .env.tmp > .env && rm -f .env.tmp
}
