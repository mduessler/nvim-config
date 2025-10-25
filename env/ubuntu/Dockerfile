# Build image to build everything.
# Copy required dependencies, requirements, etc to final images.
# This image contains everything which will be later on the local or remote image
#
FROM ubuntu:24.04 AS builder
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG MAJOR_REQ
ARG MINOR_REQ
ARG PATCH_REQ

# Installing all necessary dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    binutils \
    cmake \
    coreutils \
    curl \
    gcc \
    g++ \
    git \
    gettext \
    libc6 \
    libc6-dev \
    libgcc1 \
    libstdc++6 \
    libtermkey-dev \
    libvterm-dev \
    lua5.3 \
    liblua5.3-dev \
    luarocks \
    make \
    libncurses5-dev \
    libncursesw5-dev \
    ninja-build \
    nodejs \
    npm \
    libssl-dev \
    pkg-config \
    python3 \
    python3-pip \
    libunibilium-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ENV HOME=/root
ENV LOCAL_GIT_DIR=${HOME}/.local/share/src
RUN mkdir -p ${LOCAL_GIT_DIR}
ENV NVIM_CONFIG=${HOME}/.config/nvim
RUN mkdir -p ${NVIM_CONFIG}
