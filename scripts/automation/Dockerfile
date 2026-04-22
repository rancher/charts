FROM registry.suse.com/bci/bci-base:latest

# ============================================================================
# Propagate Container Image - Pre-installed dependencies for branch sync
# ============================================================================
#
# This image contains all dependencies needed for automation-core propagation:
# - System tools: git, make, gawk, jq, go
# - GitHub CLI: gh (from releases)
# - YAML processor: yq (from releases)
#
# Built once per propagate run, reused for all branch containers.
#
# ============================================================================

# Install system dependencies via zypper
RUN zypper --non-interactive refresh && \
    zypper --non-interactive install git make gawk jq go && \
    zypper clean --all

# Install gh CLI from GitHub releases
RUN GH_VERSION='v2.89.0' && \
    curl -sL "https://github.com/cli/cli/releases/download/${GH_VERSION}/gh_${GH_VERSION#v}_linux_amd64.tar.gz" -o /tmp/gh.tar.gz && \
    tar -xzf /tmp/gh.tar.gz -C /tmp && \
    mv "/tmp/gh_${GH_VERSION#v}_linux_amd64/bin/gh" /usr/bin/gh && \
    chmod +x /usr/bin/gh && \
    rm -rf /tmp/gh.tar.gz "/tmp/gh_${GH_VERSION#v}_linux_amd64"

# Install yq from GitHub releases
RUN YQ_VERSION='v4.52.5' && \
    curl -sL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Verify installations
RUN git --version && \
    make --version && \
    gawk --version && \
    jq --version && \
    go version && \
    gh --version && \
    yq --version

# Clone rancher/charts repository and download charts-build-scripts binary
# Strategy: Checkout dev-v2.15 temporarily to run pull-scripts, then return to automation-core
# The binary persists (untracked), while modified files (.gitignore, Makefile) are discarded
RUN git clone --depth 1 --branch dev-v2.15 https://github.com/rancher/charts.git /repo && \
    cd /repo && \
    git remote rename origin upstream && \
    git config user.name "Automation Build" && \
    git config user.email "automation@rancher.com" && \
    git fetch upstream automation-core:refs/remotes/upstream/automation-core --depth 1 && \
    make pull-scripts && \
    (git add . && git commit -m "DELETE_ME: download charts-build-scripts binary" || true) && \
    git checkout -b automation-core upstream/automation-core && \
    git branch -D dev-v2.15

WORKDIR /workspace
