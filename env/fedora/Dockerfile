# Build image to build everything once.
# Copy required dependencies, requirements, etc to final images.
# This image contains everything which will be later on the local or remote image
#
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
    libgcc \
    libstdc++ \
    libtermkey \
    libvterm \
    lua \
    lua-devel \
    make \
    ncurses-libs \
    ninja-build \
    nodejs \
    npm \
    openssl-devel \
    openssl-libs \
    pkg-config \
    python3 \
    python3-pip \
    unibilium \
    zlib-devel \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/lib/dnf /var/log/dnf* /var/log/yum.* \
    && dnf autoremove -y

# Strip executeables
RUN for dir in ${PATH//:/ }; do find "${dir}" -type f -executable -exec strip --strip-unneeded {} \;; done

# Create global env variables
ENV HOME=/root
ENV GIT_DIR=${HOME}/.local/share/src
RUN mkdir -p ${GIT_DIR}

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
    && rustup component remove rust-docs rust-src || true \
    && rustup self clean \
    && find "./bin" -type f -exec strip {} \; || true

# Install neovim
WORKDIR ${GIT_DIR}
ENV NVIM_GIT_GIT="${GIT_DIR}/neovim"
RUN git clone https://github.com/neovim/neovim ${NVIM_GIT_GIT}
WORKDIR ${NVIM_GIT_GIT}
RUN git checkout "v${MAJOR_REQ}.${MINOR_REQ}.${PATCH_REQ}" \
    && make CMAKE_BUILD_TYPE=Release \
    && make install

# Image to use during local unit tests.
#
FROM fedora:42 AS local
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG MAJOR_REQ
ARG MINOR_REQ
ARG PATCH_REQ

# Image to use during remote linting and unit tests.
#
FROM fedora:42 AS remote
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG MAJOR_REQ
ARG MINOR_REQ
ARG PATCH_REQ
