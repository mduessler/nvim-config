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

# Install nvim plugins and set them up.
WORKDIR ${NVIM_CONFIG}
COPY ./init.lua .
COPY ./lua/lsp ./lua/lsp
COPY ./lua/utils ./lua/utils
COPY ./lua/config ./lua/config
COPY ./lua/plugins ./lua/plugins
COPY ./lazy-lock.json ./lazy-lock.json

RUN timeout 15m nvim --headless || true

# Image that serves as the basis for creating environment images for remote
# and local unit tests.
FROM ubuntu:24.04 AS base

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG USER_TEST=tester
ARG MAJOR_REQ
ARG MINOR_REQ
ARG PATCH_REQ

RUN apt-get update && apt-get install -y --no-install-recommends sudo && rm -rf /var/lib/apt/lists/*

# Create test user
RUN mkdir -p "/home/${USER_TEST}" && groupadd "${USER_TEST}" \
    && useradd -m -g "${USER_TEST}" "${USER_TEST}" \
    && echo "${USER_TEST} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USER_TEST}" \
    && echo "Defaults:${USER_TEST} !requiretty" >> "/etc/sudoers.d/${USER_TEST}" \
    && chmod 0440 "/etc/sudoers.d/${USER_TEST}"

ENV USER_TEST=${USER_TEST}
ENV MAJOR_REQ=${MAJOR_REQ}
ENV MINOR_REQ=${MINOR_REQ}
ENV PATCH_REQ=${PATCH_REQ}
ENV HOME="/home/${USER_TEST}"
ENV XDG_CONFIG_HOME="${HOME}/.config"
ENV XDG_CACHE_HOME="${HOME}/.cache"
ENV XDG_DATA_HOME="${HOME}/.local/share"
ENV XDG_STATE_HOME="${HOME}/.local/state"
ENV NVIM_CONFIG="${HOME}/.config/nvim"

# Copy selene
COPY --from=builder /usr/local/cargo/bin/selene /usr/local/bin/selene

# Copy nvim
COPY --from=builder /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=builder /usr/local/share/nvim /usr/local/share/nvim

# Copy bats
COPY --from=builder /usr/local/bin/bats /usr/local/bin/bats
COPY --from=builder /usr/local/libexec/bats-core /usr/local/libexec/bats-core
COPY --from=builder /usr/local/lib/bats-core/ /usr/local/lib/bats-core/

# Copy from lua
COPY --from=builder /usr/local/share/lua/5.1/luaunit.lua /usr/local/share/lua/5.1/luaunit.lua
COPY --from=builder /usr/local/lib/luarocks/rocks-5.1/lpeglabel /usr/local/lib/luarocks/rocks-5.1/lpeglabel

# Copy nvim downloads
COPY --from=builder /root/.local/share/nvim ${XDG_DATA_HOME}/nvim

# Image from which the environment for local unit test is build.
FROM base AS local
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

WORKDIR "${NVIM_CONFIG}"
COPY . .

ENTRYPOINT ["./env/entrypoint"]

# Image from which the environment for remote unit test and linting is build.
FROM base AS remote
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Install dependencies to execute unit tests
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    lua5.4 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${HOME}

# Image that serves as the basis for creating environment images for remote
# and local testing of the installation script.
FROM ubuntu:24.04 AS install
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG USER_TEST=tester

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create test user
RUN mkdir -p "/home/${USER_TEST}" && groupadd "${USER_TEST}" \
    && useradd -m -g "${USER_TEST}" "${USER_TEST}" \
    && echo "${USER_TEST} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USER_TEST}" \
    && echo "Defaults:${USER_TEST} !requiretty" >> "/etc/sudoers.d/${USER_TEST}" \
    && chmod 0440 "/etc/sudoers.d/${USER_TEST}"

ENV HOME=/home/${USER_TEST}
ENV NVIM_CONFIG=$HOME/.config/nvim

RUN chown -R tester:tester ${HOME}
USER tester
