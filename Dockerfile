ARG BUILD_FROM=ubuntu:noble
FROM ${BUILD_FROM}

# Set environment variables for GitLab configuration
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true \
    DEBIAN_FRONTEND="noninteractive" \
    HOME="/root" \
    LANG="C.UTF-8" \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_PREFER_BINARY=1 \
    PS1="$(whoami)@$(hostname):$(pwd)$ " \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    YARN_HTTP_TIMEOUT=1000000 \
    TERM="xterm-256color" \
    GITLAB_HOME=/var/opt/gitlab \
    GITLAB_LOG_DIR=/var/log/gitlab \
    GITLAB_USER=git \
    GITLAB_UID=998 \
    GITLAB_GROUP=git \
    GITLAB_GID=998 \
    GITLAB_PORT=69

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install base system
ARG BUILD_ARCH=amd64
ARG BASHIO_VERSION="v0.17.0"
ARG S6_OVERLAY_VERSION="3.2.1.0"
ARG TEMPIO_VERSION="2024.11.2"

RUN \
    apt-get update \
    \
    && apt-get install -y --no-install-recommends \
        openssh-server \
        ca-certificates \
        curl \
        jq \
        tzdata \
        xz-utils \
        perl \
        debian-archive-keyring \
        lsb-release \
        apt-transport-https \
        software-properties-common \
    \
    && curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | bash

# Copy root filesystem
COPY rootfs /

# Expose ports
EXPOSE $GITLAB_PORT 22

# Start GitLab
CMD ["gitlab-ctl", "reconfigure"]

# Build arugments
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION
ARG BUILD_REPOSITORY

# Labels
LABEL \
    io.hass.name="Addon Ubuntu base for ${BUILD_ARCH}" \
    io.hass.description="Home Assistant Community Add-on: ${BUILD_ARCH} Ubuntu base image" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="base" \
    io.hass.version=${BUILD_VERSION} \
    io.hass.base.version=${BUILD_VERSION} \
    io.hass.base.name="ubuntu" \
    io.hass.base.image="hassioaddons/ubuntu-base" \
    maintainer="Niels Koch" \
    org.opencontainers.image.title="GitLab-CE" \
    org.opencontainers.image.description="Home Assistant Community Add-on: GitLab" \
    org.opencontainers.image.vendor="DB8KN" \
    org.opencontainers.image.authors="Niels Koch" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
