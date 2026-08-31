#!/bin/sh
set -eu

# Roll the production compose stack back to a previously published image tag.
# Usage: rollback.sh <image> <tag>
# Example: rollback.sh ghcr.io/org/syncphoto v1.0.0

IMAGE="${1:?image name is required}"
TAG="${2:?image tag is required}"
APP_DIR="${PRODUCTION_APP_DIR:-/opt/syncbox}"
STATE_FILE="${APP_DIR}/.deployed-tag"
PREVIOUS_FILE="${APP_DIR}/.previous-tag"

cd "${APP_DIR}"

if [ -f "${STATE_FILE}" ]; then
  cp "${STATE_FILE}" "${PREVIOUS_FILE}"
fi

export SYNCBOX_IMAGE="${IMAGE}"
export SYNCBOX_IMAGE_TAG="${TAG}"

docker pull "${IMAGE}:${TAG}"
docker compose --env-file .env up -d --remove-orphans
printf '%s\n' "${TAG}" > "${STATE_FILE}"

echo "Deployed ${IMAGE}:${TAG}"
