# Custom GitHub Actions runner image for Kubernetes Jobs + Kaniko
# Base: official GitHub Actions runner
FROM ghcr.io/actions/actions-runner:2.330.0

USER root

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  chmod +x kubectl && \
  mv kubectl /usr/local/bin/kubectl

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
RUN git --version && curl --version && kubectl version --client

# Notes:
# - This image runs jobs WITHOUT containers (ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER=false)
# - kubectl is used to create Kubernetes Jobs for Kaniko builds
# - Kaniko executor runs in separate Jobs to build images
# - ServiceAccount permissions allow Job creation via RBAC
# - Runs with minimal attack surface
