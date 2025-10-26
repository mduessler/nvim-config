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

# Install rust dependency
ENV CARGO_HOME="/usr/local/cargo"
ENV RUSTUP_HOME="/usr/local/rustup"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || exit 1
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Install rust requirements
RUN cargo install selene

# Clean rust overhead - clean build cache, remove toolchain and strip installed binaries
WORKDIR ${CARGO_HOME}
RUN rm -rf "./registry" "./git" \
    && (rustup component remove rust-docs rust-src || true) \
    && (find "./bin" -type f -exec strip {} \; || true)

# Install neovim
WORKDIR /root/.local/share/src
ENV NVIM_GIT_DIR=/root/.local/share/src/neovim
RUN git clone https://github.com/neovim/neovim ${NVIM_GIT_DIR}
WORKDIR ${NVIM_GIT_DIR}

RUN git checkout "v${MAJOR_REQ}.${MINOR_REQ}.${PATCH_REQ}" \
    && make CMAKE_BUILD_TYPE=Release \
    && make install
