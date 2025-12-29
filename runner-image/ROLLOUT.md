# Runner Image Rollout & Fallback

This document explains how to roll out a new runner image version and how to revert (fallback) safely.

## Prerequisites
- Access to your container registry (credentials if required).
- Flux configured to deploy the ARC runners via the local chart.

## Rollout (New Version)
1. Set the desired version tag in [workflows/runner-image/TAG](workflows/runner-image/TAG).
2. Build and publish the image:
   ```bash
   # optional: set credentials
   export REGISTRY_USER='<user>'
   export REGISTRY_PASSWORD='<password>'
   # publish using TAG value
   workflows/runner-image/publish.sh
   ```
3. Update Flux to reference the new image tag:
   - Edit [flux/charts/web-app/values.yaml](flux/charts/web-app/values.yaml) `githubRunner.image` to the new tag.
   - Commit and push the change to trigger Flux reconciliation.
4. Verify rollout:
   - Ensure new runner pods are created in `arc-runners` and become Ready.
   - Run a small workflow on the scale set (e.g., checkout + `podman --version`).

## Fallback (Revert to Previous Version)
1. Change the tag back in [workflows/runner-image/TAG](workflows/runner-image/TAG) to the last known-good version.
2. (Optional if already present in registry) Re-publish:
   ```bash
   workflows/runner-image/publish.sh
   ```
3. Update Flux image reference:
   - Edit [flux/charts/web-app/values.yaml](flux/charts/web-app/values.yaml) `githubRunner.image` back to the previous tag.
   - Commit and push; Flux will roll back pods to the previous image.
4. Validate:
   - Confirm runner pods restart on the older image and complete a test workflow.

## Tips
- Avoid job-level `container:` in workflows to bypass ARC container hook issues.
- Tools like Podman/BuildKit are available directly on the runner image.
- If registry auth is required, set `REGISTRY_USER` and `REGISTRY_PASSWORD` in your env before publishing.
