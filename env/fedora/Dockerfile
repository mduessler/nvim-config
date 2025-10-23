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
    python3 \
    python3-pip \
    unibilium \
    zlib-devel \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/lib/dnf /var/log/dnf* /var/log/yum.* \
    && dnf autoremove -y

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
    && rustup component remove rust-docs rust-src || true \
    && find "./bin" -type f -exec strip {} \; || true

# Install neovim
WORKDIR ${LOCAL_GIT_DIR}
ENV NVIM_GIT_DIR="${LOCAL_GIT_DIR}/neovim"
RUN git clone https://github.com/neovim/neovim ${NVIM_GIT_DIR}
WORKDIR ${NVIM_GIT_DIR}

RUN git checkout "v${MAJOR_REQ}.${MINOR_REQ}.${PATCH_REQ}" \
    && make CMAKE_BUILD_TYPE=Release \
    && make install

# Install bat
WORKDIR ${LOCAL_GIT_DIR}
ENV BATS_GIT_DIR="${LOCAL_GIT_DIR}/bats-core"
RUN git clone https://github.com/bats-core/bats-core ${BATS_GIT_DIR}
WORKDIR ${BATS_GIT_DIR}
RUN ./install.sh /usr/local

# Strip bats.
RUN find "/usr/local/libexec/bats-core" -type f -exec strip {} \; || true \
    && find "/usr/local/lib/bats-core/" -type f -exec strip {} \; || true \
    && strip --strip-unneeded /usr/local/bats || true

# Install lua libraries
RUN luarocks install lpeglabel && \
    luarocks install luaunit

# Install pre-commit for linting
RUN python -m pip install --no-cache-dir pre-commit==4.2.0

# Install nvim plugins and set them up.
WORKDIR ${NVIM_CONFIG}
COPY ./init.lua .
COPY ./lua/lsp ./lua/lsp
COPY ./lua/utils ./lua/utils
COPY ./lua/config ./lua/config
COPY ./lua/plugins ./lua/plugins
COPY ./lazy-lock.json ./lazy-lock.json

RUN timeout 10m nvim --headless || true

# Image which is used by local and remote.
FROM fedora:42 AS base

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Create test user
ARG USER_TEST=tester

ARG MAJOR_REQ
ARG MINOR_REQ
ARG PATCH_REQ

RUN mkdir -p "/home/${USER_TEST}" && groupadd "${USER_TEST}" \
    && useradd -m -g "${USER_TEST}" "${USER_TEST}" \
    && echo "${USER_TEST} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USER_TEST}" \
    && echo "Defaults:${USER_TEST} !requiretty" >> "/etc/sudoers.d/${USER_TEST}" \
    && chmod 0440 "/etc/sudoers.d/${USER_TEST}"


ENV MAJOR_REQ=${MAJOR_REQ}
ENV MINOR_REQ=${MINOR_REQ}
ENV PATCH_REQ=${PATCH_REQ}
ENV HOME="/home/${USER_TEST}"
ENV XDG_CONFIG_HOME="${HOME}/.config"
ENV XDG_CACHE_HOME="${HOME}/.cache"
ENV XDG_DATA_HOME="${HOME}/.local/share"
ENV XDG_STATE_HOME="${HOME}/.local/state"
ENV NVIM_CONFIG="${HOME}/.config/nvim"


# Selene from builder
COPY --from=builder /usr/local/cargo/bin/selene /usr/local/bin/selene

# Copy nvim
COPY --from=builder /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=builder /usr/local/share/nvim /usr/local/share/nvim

# Copy bats
COPY --from=builder /usr/local/bin/bats /usr/local/bin/bats
COPY --from=builder /usr/local/libexec/bats-core /usr/local/libexec/bats-core
COPY --from=builder /usr/local/lib/bats-core/ /usr/local/lib/bats-core/

# Copy from lua
COPY --from=builder /usr/share/lua/5.4/luaunit.lua /usr/share/lua/5.4/luaunit.lua
COPY --from=builder /usr/lib64/lua/5.4/lpeglabel.so /usr/lib64/lua/5.4/lpeglabel.so

# Copy nvim downloads
COPY --from=builder /root/.local/share/nvim ${XDG_DATA_HOME}/nvim

# Image to use during local unit tests.
#
FROM base AS local
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

WORKDIR "${NVIM_CONFIG}"
COPY . .

ENTRYPOINT ["./env/entrypoint"]

# Image to use during remote linting and unit tests.
#
FROM base AS remote
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Copy git dependency and needed libs.
COPY --from=builder /usr/bin/git /usr/bin/git
COPY --from=builder /usr/libexec/git-core/git-remote-http /usr/libexec/git-core/git-remote-http
COPY --from=builder /usr/libexec/git-core/git-remote-https /usr/libexec/git-core/git-remote-https

# Copy curl dependency
COPY --from=builder /usr/bin/curl /usr/bin/curl

# Copy certificates installed with ca-certificates
COPY --from=builder /etc/pki/ca-trust /etc/pki/ca-trust

# Copy hadolint for pre-commit
COPY --from=builder /usr/bin/hadolint /usr/bin/hadolint
