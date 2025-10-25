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

# Install rust dependency
ENV CARGO_HOME="/usr/local/cargo"
ENV RUSTUP_HOME="/usr/local/rustup"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || exit 1
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Install rust requirements
RUN cargo install selene

# Clean rust overhead
# Clean build cache, remove toolchain and strip installed binaries
WORKDIR ${CARGO_HOME}
RUN rm -rf "./registry" "./git" \
    && (rustup component remove rust-docs rust-src || true) \
    && (find "./bin" -type f -exec strip {} \; || true)

# Install neovim
WORKDIR ${LOCAL_GIT_DIR}
ENV NVIM_GIT_DIR="${LOCAL_GIT_DIR}/neovim"
RUN git clone https://github.com/neovim/neovim ${NVIM_GIT_DIR}
WORKDIR ${NVIM_GIT_DIR}

RUN git checkout "v${MAJOR_REQ}.${MINOR_REQ}.${PATCH_REQ}" \
    && make CMAKE_BUILD_TYPE=Release \
    && make install

# Install bats
WORKDIR ${LOCAL_GIT_DIR}
ENV BATS_GIT_DIR="${LOCAL_GIT_DIR}/bats-core"
RUN git clone https://github.com/bats-core/bats-core ${BATS_GIT_DIR}
WORKDIR ${BATS_GIT_DIR}
RUN ./install.sh /usr/local

# Strip bats.
RUN (find "/usr/local/libexec/bats-core" -type f -exec strip {} \; || true) \
    && (find "/usr/local/lib/bats-core/" -type f -exec strip {} \; || true) \
    && (strip --strip-unneeded /usr/local/bats || true)

# Install nvim plugins and set them up.
WORKDIR ${NVIM_CONFIG}
COPY ./init.lua .
COPY ./lua/lsp ./lua/lsp
COPY ./lua/utils ./lua/utils
COPY ./lua/config ./lua/config
COPY ./lua/plugins ./lua/plugins
COPY ./lazy-lock.json ./lazy-lock.json

RUN timeout 15m nvim --headless || true

# Image which is used by local and remote.
FROM fedora:42 AS base

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]
