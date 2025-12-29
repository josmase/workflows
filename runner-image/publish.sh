#!/usr/bin/env bash
set -euo pipefail

# Simple build & publish script for the ARC runner image
# Uses a single-value TAG file to set the image tag.

REPO_ROOT_DIR="$(cd "$(dirname "$0")"/../.. && pwd)"
IMAGE_DIR="$REPO_ROOT_DIR/workflows/runner-image"
TAG_FILE="$IMAGE_DIR/TAG"

REGISTRY="${REGISTRY:-artifactory.local.hejsan.xyz}"
IMAGE_PATH="${IMAGE_PATH:-docker/actions/runner-kaniko}"

if [[ ! -f "$TAG_FILE" ]]; then
  echo "TAG file not found: $TAG_FILE" >&2
  exit 1
fi
TAG=$(tr -d '\n' < "$TAG_FILE")
if [[ -z "$TAG" ]]; then
  echo "TAG file is empty: $TAG_FILE" >&2
  exit 1
fi
IMAGE_REF="$REGISTRY/$IMAGE_PATH:$TAG"

# Choose container tool: prefer podman, fallback to docker
BUILDER=""
if command -v podman >/dev/null 2>&1; then
  BUILDER="podman"
elif command -v docker >/dev/null 2>&1; then
  BUILDER="docker"
else
  echo "Neither podman nor docker found on PATH" >&2
  exit 1
fi

echo "Building $IMAGE_REF using $BUILDER"

# Optional registry auth via env vars
if [[ -n "${REGISTRY_USER:-}" && -n "${REGISTRY_PASSWORD:-}" ]]; then
  echo "Logging into $REGISTRY"
  $BUILDER login "$REGISTRY" -u "$REGISTRY_USER" -p "$REGISTRY_PASSWORD"
fi

$BUILDER build -f "$IMAGE_DIR/Dockerfile" -t "$IMAGE_REF" "$IMAGE_DIR"
$BUILDER push "$IMAGE_REF"

echo "Published $IMAGE_REF"