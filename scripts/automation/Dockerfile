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
# Sources scripts/version from automation-core for CBS version/checksum
RUN git clone --depth 1 --branch automation-core https://github.com/rancher/charts.git /repo && \
    cd /repo && \
    git remote rename origin upstream && \
    git config user.name "Automation Build" && \
    git config user.email "automation@rancher.com" && \
    mkdir -p bin && \
    source scripts/version && \
    curl -sL "${CHARTS_BUILD_SCRIPTS_REPO%.git}/releases/download/${CHARTS_BUILD_SCRIPT_VERSION}/charts-build-scripts_linux_amd64" -o bin/charts-build-scripts && \
    echo "${CHARTS_BUILD_SCRIPT_CHECKSUM_LINUX_AMD64}  bin/charts-build-scripts" | sha256sum -c && \
    chmod +x bin/charts-build-scripts && bin/charts-build-scripts --version

WORKDIR /workspace
