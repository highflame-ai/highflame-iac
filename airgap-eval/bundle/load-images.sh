#!/usr/bin/env bash
#
# Load the offline image bundle. Run this on the air-gapped machine.
#
#   ./bundle/load-images.sh highflame-airgap-<version>.tar.zst
#
# Nothing is pulled. This script does not use the network at all, and will still
# work with the host's uplink physically removed — which is the point, and which
# is worth actually testing rather than assuming.
#
# It verifies twice, because the two checks answer different questions:
#
#   the .sha256    did the FILE arrive intact?
#   the .manifest  is each image I now have the image that was saved?
#
# The second is the one that matters if the bundle passed through hands or media
# you do not control. A re-tarred archive with one image swapped satisfies its own
# freshly-computed checksum perfectly well.
set -euo pipefail

TARBALL="${1:-}"
if [ -z "$TARBALL" ]; then
  echo "usage: $0 <highflame-airgap-VERSION.tar.zst>"
  exit 1
fi
[ -f "$TARBALL" ] || { echo "not found: $TARBALL"; exit 1; }

command -v docker >/dev/null || { echo "docker is required"; exit 1; }
command -v zstd  >/dev/null || { echo "zstd is required (apt install zstd)"; exit 1; }

BASE="${TARBALL%.tar.zst}"
CHECKSUM="${BASE}.sha256"
MANIFEST="${BASE}.manifest"

# ---------------------------------------------------------------------------
echo "== 1. verifying the tarball =="
# ---------------------------------------------------------------------------
if [ -f "$CHECKSUM" ]; then
  # sha256sum needs to run where the file is, since the checksum records a
  # bare filename.
  if ( cd "$(dirname "$TARBALL")" && sha256sum -c "$(basename "$CHECKSUM")" ); then
    echo "  checksum OK"
  else
    echo
    echo "CHECKSUM MISMATCH — refusing to load."
    echo "The file is corrupt or has been modified in transit. Re-copy it; do not"
    echo "load it and hope."
    exit 1
  fi
else
  echo "  WARNING: $CHECKSUM not found — cannot verify the tarball arrived intact."
  echo "  Continuing, but this is a weaker position than you probably want."
fi

# ---------------------------------------------------------------------------
echo
echo "== 2. loading images (no network access required) =="
# ---------------------------------------------------------------------------
zstd -dc "$TARBALL" | docker load

# ---------------------------------------------------------------------------
echo
echo "== 3. verifying what was loaded against the manifest =="
# ---------------------------------------------------------------------------
if [ ! -f "$MANIFEST" ]; then
  echo "  WARNING: $MANIFEST not found — images are loaded but UNVERIFIED."
  echo "  You have confirmed the file arrived intact, not that its contents are"
  echo "  the ones that were built. Ask for the manifest."
  exit 0
fi

fail=0 checked=0
while IFS=$'\t' read -r image expected; do
  [ -z "${image:-}" ] && continue
  checked=$((checked + 1))

  if ! docker image inspect "$image" >/dev/null 2>&1; then
    echo "  MISSING  $image"
    fail=$((fail + 1))
    continue
  fi

  actual=$(docker image inspect "$image" \
    --format '{{if .RepoDigests}}{{index .RepoDigests 0}}{{else}}{{.Id}}{{end}}')

  if [ "$actual" = "$expected" ]; then
    echo "  OK       $image"
  else
    echo "  MISMATCH $image"
    echo "             expected $expected"
    echo "             actual   $actual"
    fail=$((fail + 1))
  fi
done < "$MANIFEST"

echo
if [ "$fail" -gt 0 ]; then
  echo "FAILED: $fail of $checked images do not match the manifest."
  echo "Do not run the stack. Obtain a fresh bundle from a trusted path."
  exit 1
fi

cat <<EOF
All $checked images verified against the manifest.

Next:
    cp .env.example .env      # set HIGHFLAME_HOSTNAME and HIGHFLAME_LLM_BASE_URL
    ./bootstrap/bootstrap.sh
    docker compose up -d
    ./bootstrap/seed-tenant.sh
    ./verify/no-egress.sh --report egress-report.txt
EOF
