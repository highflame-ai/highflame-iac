#!/bin/bash

command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required but not installed. Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "curl is required but not installed. Aborting."; exit 1; }

HIGHFLAME_GH_TOKEN=${HIGHFLAME_GH_TOKEN}
GH_ASSET_NAME=${1}
RELEASE_VER=${2}

OWNER="highflame-ai"
REPO="highflame-overwatch"
ASSET_NAME="highflame-overwatch"

if [[ -z ${HIGHFLAME_GH_TOKEN} ]] || [[ -z ${GH_ASSET_NAME} ]] || [[ -z ${RELEASE_VER} ]] ; then
    echo "Usage : export HIGHFLAME_GH_TOKEN=highflame-gh-token; ${0} GH_ASSET_NAME RELEASE_VER"
    echo "Example : export HIGHFLAME_GH_TOKEN=highflame-gh-token; ${0} highflame-overwatch-linux-amd64 v0.0.2"
    exit 1
else
    ASSET_ID=$(curl -s \
    -H "Authorization: token ${HIGHFLAME_GH_TOKEN}" \
    https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/$RELEASE_VER \
    | jq -r ".assets[] | select(.name==\"${GH_ASSET_NAME}\") | .id")

    curl -L \
    -H "Authorization: token ${HIGHFLAME_GH_TOKEN}" \
    -H "Accept: application/octet-stream" \
    https://api.github.com/repos/${OWNER}/${REPO}/releases/assets/${ASSET_ID} \
    -o ${ASSET_NAME}
fi