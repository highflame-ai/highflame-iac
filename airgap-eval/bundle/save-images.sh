#!/usr/bin/env bash
#
# Build the offline image bundle. Run this on a connected machine; the output is
# what you carry to the air-gapped one.
#
# Produces three files:
#
#   highflame-airgap-<version>.tar.zst   the images
#   highflame-airgap-<version>.sha256    checksum of the tarball
#   highflame-airgap-<version>.manifest  image ref -> content digest, one per line
#
# Why a manifest of per-image digests and not just a tarball checksum: the
# checksum proves the FILE arrived intact, which is a transport property. The
# manifest lets the receiving side confirm that each image it loaded is the exact
# image that was saved — so a substituted image inside a re-tarred archive is
# still caught. Air-gapped transfers move through hands and removable media, and
# "the file is intact" is a weaker claim than most people assume it is.
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${HIGHFLAME_VERSION:-latest}"
OUT_DIR="${OUT_DIR:-.}"
BASENAME="highflame-airgap-${VERSION}"
TARBALL="${OUT_DIR}/${BASENAME}.tar.zst"
CHECKSUM="${OUT_DIR}/${BASENAME}.sha256"
MANIFEST="${OUT_DIR}/${BASENAME}.manifest"

command -v docker >/dev/null || { echo "docker is required"; exit 1; }
command -v zstd  >/dev/null || { echo "zstd is required (apt install zstd)"; exit 1; }

# Read the image list from the compose file itself rather than maintaining a
# second copy here. A hand-maintained list is how you ship a bundle missing the
# one image someone added last week.
#
# Placeholder values are supplied only so `compose config` can interpolate; none
# of them end up in the bundle.
echo "resolving image list from docker-compose.yaml"
IMAGES=$(
  HIGHFLAME_HOSTNAME=placeholder \
  HIGHFLAME_LLM_BASE_URL=placeholder \
  POSTGRES_PASSWORD=placeholder \
  CLICKHOUSE_PASSWORD=placeholder \
  KEYCLOAK_ADMIN_PASSWORD=placeholder \
  OIDC_CLIENT_SECRET=placeholder \
  AUTH_SECRET=placeholder \
  HIGHFLAME_AUTH_JWT_SECRET_KEY=placeholder \
  HIGHFLAME_TOKEN_ENCRYPTION_KEY=placeholder \
  HIGHFLAME_INTERNAL_SERVICE_SECRET=placeholder \
  docker compose config --images | sort -u
)

[ -n "$IMAGES" ] || { echo "no images resolved — is this the airgap-eval directory?"; exit 1; }

echo "images to bundle:"
printf '  %s\n' $IMAGES

# Fail before saving if anything is missing locally, rather than producing a
# bundle that is quietly incomplete.
missing=()
for image in $IMAGES; do
  docker image inspect "$image" >/dev/null 2>&1 || missing+=("$image")
done
if [ ${#missing[@]} -gt 0 ]; then
  echo
  echo "not present locally — pull or build these first:"
  printf '  %s\n' "${missing[@]}"
  echo
  echo "note: the Studio image here is the ORDINARY one — the same image SaaS runs."
  echo "It selects its auth provider at runtime, and docker-compose.yaml sets"
  echo "HIGHFLAME_AUTH_PROVIDER=oidc. There is no OIDC-specific build to hunt for."
  echo
  echo "It must, however, be a Studio image containing highflame-studio#1503."
  echo "Earlier images do not read that variable — the provider was compiled in —"
  echo "so an older tag serves the Clerk login UI against this Keycloak-only"
  echo "stack. Pin HIGHFLAME_STUDIO_VERSION rather than leaving it on 'latest'."
  echo
  echo "NEXT_PUBLIC_AUTH_PROVIDER is no longer read at all; building with it"
  echo "silently produces a Clerk image. Studio refuses to start when the"
  echo "provider it resolves has no configuration, so that surfaces at boot."
  exit 1
fi

echo
echo "writing $MANIFEST"
: >"$MANIFEST"
for image in $IMAGES; do
  # RepoDigests is empty for locally-built images that were never pushed, so fall
  # back to the image ID. Both identify the exact content; only the digest is
  # verifiable against a registry, which an air-gapped site has no use for anyway.
  digest=$(docker image inspect "$image" --format '{{if .RepoDigests}}{{index .RepoDigests 0}}{{else}}{{.Id}}{{end}}')
  printf '%s\t%s\n' "$image" "$digest" >>"$MANIFEST"
done
cat "$MANIFEST" | sed 's/^/  /'

echo
echo "saving images (this takes a while and needs ~2x the image size in scratch space)"
# -T0 uses all cores; -19 is worth the time here because this file gets copied
# across an air gap, sometimes onto media where size actually matters.
docker save $IMAGES | zstd -T0 -19 -o "$TARBALL"

echo "writing $CHECKSUM"
( cd "$OUT_DIR" && sha256sum "$(basename "$TARBALL")" > "$(basename "$CHECKSUM")" )

echo
echo "bundle ready:"
ls -lh "$TARBALL" "$CHECKSUM" "$MANIFEST" | sed 's/^/  /'
echo
echo "carry all THREE files across. load-images.sh needs the manifest to verify"
echo "what it loaded, not just that the tarball arrived intact."
