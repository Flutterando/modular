#!/usr/bin/env bash
#
# Build the Modular documentation site image and publish it to Docker Hub.
#
# Usage:
#   ./publish-docker.sh [TAG]          # TAG defaults to "latest"
#
# Environment variables:
#   DOCKER_USER      Docker Hub user/org        (default: flutterando)
#   IMAGE_NAME       repository name            (default: modular-docs)
#   PLATFORMS        target platforms           (default: linux/amd64,linux/arm64)
#   DOCKER_PASSWORD  if set (with DOCKER_USER), used for a non-interactive login
#
# Prereqs: Docker with buildx. You must be logged in (`docker login`) unless you
# pass DOCKER_PASSWORD for an automated login (e.g. in CI).

set -euo pipefail

# Always run from the doc/ directory (where the Dockerfile lives).
cd "$(dirname "$0")"

DOCKER_USER="${DOCKER_USER:-flutterando}"
IMAGE_NAME="${IMAGE_NAME:-modular-docs}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
TAG="${1:-latest}"
IMAGE="${DOCKER_USER}/${IMAGE_NAME}"

echo "==> Publishing ${IMAGE}:${TAG} (platforms: ${PLATFORMS})"

# Optional non-interactive login (handy for CI).
if [[ -n "${DOCKER_PASSWORD:-}" ]]; then
  echo "==> Logging in to Docker Hub as ${DOCKER_USER}"
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
fi

# Multi-arch build needs a buildx builder with the container driver.
BUILDER="modular-docs-builder"
if ! docker buildx inspect "${BUILDER}" >/dev/null 2>&1; then
  echo "==> Creating buildx builder '${BUILDER}'"
  docker buildx create --name "${BUILDER}" --driver docker-container --use
else
  docker buildx use "${BUILDER}"
fi

# Tag the requested TAG, and also :latest when publishing a versioned tag.
TAGS=(--tag "${IMAGE}:${TAG}")
if [[ "${TAG}" != "latest" ]]; then
  TAGS+=(--tag "${IMAGE}:latest")
fi

docker buildx build \
  --platform "${PLATFORMS}" \
  "${TAGS[@]}" \
  --push \
  .

echo "==> Done."
echo "    Pushed ${IMAGE}:${TAG}$([[ "${TAG}" != "latest" ]] && echo " and ${IMAGE}:latest")"
echo "    Run it with:  docker run --rm -p 8080:80 ${IMAGE}:${TAG}"
