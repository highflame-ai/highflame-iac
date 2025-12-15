#!/bin/bash

command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required but not installed. Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "curl is required but not installed. Aborting."; exit 1; }

JAVELIN_GH_TOKEN=${JAVELIN_GH_TOKEN}
GH_ASSET_NAME=${1}
RELEASE_VER=${2}

OWNER="highflame-ai"
REPO="javelin-overwatch"
ASSET_NAME="javelin-overwatch"

if [[ -z ${JAVELIN_GH_TOKEN} ]] || [[ -z ${GH_ASSET_NAME} ]] || [[ -z ${RELEASE_VER} ]] ; then
    echo "Usage : export JAVELIN_GH_TOKEN=javelin-gh-token; ${0} GH_ASSET_NAME RELEASE_VER"
    echo "Example : export JAVELIN_GH_TOKEN=javelin-gh-token; ${0} javelin-overwatch-linux-amd64 v0.0.2"
    exit 1
else
    ASSET_ID=$(curl -s \
    -H "Authorization: token ${JAVELIN_GH_TOKEN}" \
    https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/$RELEASE_VER \
    | jq -r ".assets[] | select(.name==\"${GH_ASSET_NAME}\") | .id")

    curl -L \
    -H "Authorization: token ${JAVELIN_GH_TOKEN}" \
    -H "Accept: application/octet-stream" \
    https://api.github.com/repos/${OWNER}/${REPO}/releases/assets/${ASSET_ID} \
    -o ${ASSET_NAME}
fi