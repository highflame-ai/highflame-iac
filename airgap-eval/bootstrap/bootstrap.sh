#!/bin/sh
#
# Generate every secret and key this stack needs — inside a container, so the
# only thing this machine needs is Docker.
#
# This is a thin wrapper. The real work is bootstrap/generate.sh, which runs in
# the Postgres image the stack already uses; that image carries openssl and a
# POSIX shell, and it is already in the offline bundle, so containerising costs
# nothing to download and adds no new dependency to the air-gapped transfer.
#
# Why not just run generate.sh on the host: openssl's availability and flag
# behaviour vary across distributions (RHEL and Ubuntu disagree, and minimal
# base images often ship neither openssl nor python). Running it in a pinned
# image makes the result identical everywhere by construction, which is a
# stronger guarantee than "works on the distro we tested".
#
# Why not commit the keys instead: this bundle is handed to security reviewers,
# and the first thing they do is grep it for key material. Committed PEMs would
# also mean every evaluator shares one JWT signing key.
#
# Nothing here reaches the network. `openssl rand` runs on this machine, and the
# image is one you already have.
set -eu

cd "$(dirname "$0")/.."

# The image is deliberately the same pin the stack runs, so the bundle contains
# exactly one Postgres image and this can never reference something the
# air-gapped host does not have.
BOOTSTRAP_IMAGE="${HIGHFLAME_BOOTSTRAP_IMAGE:-pgvector/pgvector:pg17}"

# Escape hatch, and what generate.sh checks to know it is already inside the
# container. Also lets anyone who prefers their host toolchain skip Docker:
#     HIGHFLAME_BOOTSTRAP_IN_CONTAINER=1 ./bootstrap/generate.sh
if [ "${HIGHFLAME_BOOTSTRAP_IN_CONTAINER:-0}" = "1" ]; then
  exec ./bootstrap/generate.sh "$@"
fi

command -v docker >/dev/null || {
  echo "docker is required (it is the only prerequisite)."
  echo
  echo "If you would rather use this machine's own openssl:"
  echo "    HIGHFLAME_BOOTSTRAP_IN_CONTAINER=1 ./bootstrap/generate.sh"
  exit 1
}

docker image inspect "$BOOTSTRAP_IMAGE" >/dev/null 2>&1 || {
  echo "The image $BOOTSTRAP_IMAGE is not present locally."
  echo
  echo "Offline: load the bundle first —  ./bundle/load-images.sh <bundle>.tar.zst"
  echo "Online:  docker pull $BOOTSTRAP_IMAGE"
  exit 1
}

# Run as the invoking user so .env and secrets/ stay editable afterwards. Without
# this every generated file lands root-owned and the operator needs sudo to touch
# the .env they are told to edit.
exec docker run --rm \
  --network none \
  -v "$PWD:/work" \
  -w /work \
  -u "$(id -u):$(id -g)" \
  -e HIGHFLAME_BOOTSTRAP_IN_CONTAINER=1 \
  --entrypoint /bin/bash \
  "$BOOTSTRAP_IMAGE" \
  ./bootstrap/generate.sh "$@"
