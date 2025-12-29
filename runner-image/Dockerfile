# Custom GitHub Actions runner image for Kubernetes Jobs + Kaniko
# Base: official GitHub Actions runner
FROM ghcr.io/actions/actions-runner:2.330.0

USER root

# Install minimal dependencies
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  git gh curl ca-certificates jq && \
  rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash runner || true
RUN echo "runner:100000:65536" >> /etc/subuid && \
  echo "runner:100000:65536" >> /etc/subgid

# Switch back to runner user
USER runner

# Display versions for debugging
RUN git --version && curl --version

# Notes:
# - This image runs jobs WITHOUT containers (ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER=false)
# - Container build requests are intercepted by container hooks
# - Hooks create Kubernetes Jobs that run Kaniko executor
# - Kaniko builds images directly without container daemon
# - Runs with minimal attack surface
