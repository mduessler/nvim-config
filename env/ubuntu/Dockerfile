# Image to build all dependencies.
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
    lua5.4 \
    liblua5.4-dev \
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

# Creating directory structure
RUN mkdir -p /root/.local/share/src /root/.config/nvim
