# Image to build all dependencies.
FROM fedora:42 AS builder

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG MAJOR_REQ
ARG MINOR_REQ
ARG PATCH_REQ

# Installing all necessary dependencies.
RUN dnf install -y --setopt=install_weak_deps=False \
    bash \
    binutils \
    cmake \
    coreutils \
    curl \
    gcc \
    gcc-c++ \
    git \
    gettext \
    glibc \
    glibc-gconv-extra \
    hadolint \
    libgcc \
    libstdc++ \
    libtermkey \
    libvterm \
    lua \
    lua-devel \
    luarocks \
    make \
    ncurses-libs \
    ninja-build \
    nodejs \
    npm \
    openssl-devel \
    openssl-libs \
    pkg-config \
    python \
    python3-pip \
    unibilium \
    zlib-devel \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/lib/dnf /usr/share/doc/* /usr/share/man/* /usr/share/locale/* \
    && dnf autoremove -y

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

# Install bats
WORKDIR /root/.local/share/src
ENV BATS_GIT_DIR=/root/.local/share/src/bats-core
RUN git clone https://github.com/bats-core/bats-core /root/.local/share/src/bats-core
WORKDIR /root/.local/share/src/bats-core
RUN ./install.sh /usr/local

# Strip bats.
RUN (find "/usr/local/libexec/bats-core" -type f -exec strip {} \; || true) \
    && (find "/usr/local/lib/bats-core/" -type f -exec strip {} \; || true) \
    && (strip --strip-unneeded /usr/local/bats || true)

# Install lua libraries
RUN luarocks install lpeglabel && \
    luarocks install luaunit

# Image that serves as the basis for creating environment images for remote
# and local unit tests.
FROM fedora:42 AS base

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Image from which the environment for local unit test is build.
FROM base AS local

# Image from which the environment for remote unit test and linting is build.
FROM base AS remote

# Image that serves as the basis for creating environment images for remote
# and local testing of the installation script.
FROM fedora:42 AS install

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Image from which the environment for local testing of the installation script
# is built.
FROM install AS install-local
