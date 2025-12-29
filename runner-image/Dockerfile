# Custom GitHub Actions runner image with Podman + Buildkit
# Base: official GitHub Actions runner
FROM ghcr.io/actions/actions-runner:2.330.0

USER root

# Install podman toolchain and supporting utilities
# - podman: container engine (rootless capable)
# - buildah/skopeo: build/push helpers used by podman internally
# - slirp4netns/fuse-overlayfs: rootless networking & storage driver
# - crun: fast OCI runtime preferred by podman
# - jq,curl,ca-certificates: common CLI tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      podman buildah skopeo slirp4netns fuse-overlayfs crun \
      jq curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install buildctl (BuildKit CLI)
ARG BUILDKIT_VERSION=v0.13.2
RUN curl -fsSL "https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz" \
    | tar -xz --strip-components=1 -C /usr/local/bin bin/buildctl

# Configure rootless podman defaults
# Use fuse-overlayfs and crun; set XDG_RUNTIME_DIR for the runner user
COPY containers.conf /etc/containers/containers.conf
COPY storage.conf /etc/containers/storage.conf

# Create runtime dir for the runner user and set permissions
RUN mkdir -p /home/runner/.local/run && chown -R runner:runner /home/runner/.local
ENV XDG_RUNTIME_DIR=/home/runner/.local/run

# Optional: pre-create auth/config locations
RUN mkdir -p /home/runner/.config/containers && chown -R runner:runner /home/runner/.config

# Switch back to runner user for job steps
USER runner

# Display versions for debugging
RUN podman --version && buildctl --version && crun --version

# Notes:
# - This image supports running jobs WITHOUT a job container (recommended with ARC)
# - Use podman/buildctl directly in workflow steps (no `container:` at job level)
# - For caching, prefer registry-based cache (podman: --cache-to/--cache-from; buildkit: --cache-to/--cache-from)
