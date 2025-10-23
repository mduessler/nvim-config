# Build image to build everything once.
# Copy required dependencies, requirements, etc to final images.
# This image contains everything which will be later on the local or remote image
#
FROM fedora:42 AS builder
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

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

# Image to use during local unit tests.
#
FROM fedora:42 AS local
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Image to use during remote linting and unit tests.
#
FROM fedora:42 AS remote
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]
