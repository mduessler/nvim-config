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

# Install pre-commit for linting
RUN python3 -m pip install --no-cache-dir pre-commit==4.2.0

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
FROM fedora:42 AS base

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG USER_TEST=tester
ARG MAJOR_REQ
ARG MINOR_REQ
ARG PATCH_REQ

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
COPY --from=builder /usr/share/lua/5.4/luaunit.lua /usr/share/lua/5.4/luaunit.lua
COPY --from=builder /usr/lib64/lua/5.4/lpeglabel.so /usr/lib64/lua/5.4/lpeglabel.so

# Copy nvim downloads
COPY --from=builder /root/.local/share/nvim ${XDG_DATA_HOME}/nvim

# Image from which the environment for local unit test is build.
FROM base AS local

WORKDIR "${NVIM_CONFIG}"
COPY . .

ENTRYPOINT ["./env/entrypoint"]

# Image from which the environment for remote unit test and linting is build.
FROM base AS remote

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Install dependencies to execute pre-commit and run tests
RUN dnf install -y --setopt=install_weak_deps=False \
    ca-certificates \
    libatomic \
    openssl-libs \
    python \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/lib/dnf /var/log/dnf* /var/log/yum.* \
    && dnf autoremove -y

# Copy hadolint for pre-commit
COPY --from=builder /usr/bin/hadolint /usr/bin/hadolint

# Copy python pre-commit libraries
# Move the python site-package libraries from /usr/local/lib to /usr/lib
COPY --from=builder /usr/local/lib/python3.*/site-packages/ /tmp/site-packages/
RUN regex="^Python ([0-9]\.[0-9]+)." \
    && if [[ $(python --version) =~ ${regex} ]]; then \
        mkdir -p "/usr/lib/python${BASH_REMATCH[1]}"; \
        cp -r /tmp/site-packages "/usr/lib/python${BASH_REMATCH[1]}"; \
        rm -rf /tmp/site-packages; \
    fi

COPY --from=builder /usr/local/lib64/python3.*/site-packages/ /tmp/site-packages/
RUN regex="^Python ([0-9]\.[0-9]+)." \
    && if [[ $(python --version) =~ ${regex} ]]; then \
        mkdir -p "/usr/lib64/python${BASH_REMATCH[1]}"; \
        cp -r /tmp/site-packages "/usr/lib64/python${BASH_REMATCH[1]}"; \
        rm -rf /tmp/site-packages; \
    fi

# Copy pre-commit and dependencies
COPY --from=builder /usr/local/bin/pre-commit /usr/local/bin/pre-commit
COPY --from=builder /usr/local/sbin/pre-commit /usr/local/sbin/pre-commit

WORKDIR ${NVIM_CONFIG}

# Image that serves as the basis for creating environment images for remote
# and local testing of the installation script.
FROM fedora:42 AS install

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ARG USER_TEST=tester

RUN dnf install -y git \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/lib/dnf /var/log/dnf* /var/log/yum.* \
    && dnf autoremove -y

RUN mkdir -p "/home/${USER_TEST}" && groupadd "${USER_TEST}" \
    && useradd -m -g "${USER_TEST}" "${USER_TEST}" \
    && echo "${USER_TEST} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USER_TEST}" \
    && echo "Defaults:${USER_TEST} !requiretty" >> "/etc/sudoers.d/${USER_TEST}" \
    && chmod 0440 "/etc/sudoers.d/${USER_TEST}"   && dnf autoremove -y

ENV HOME=/home/${USER_TEST}
ENV NVIM_CONFIG=$HOME/.config/nvim

RUN chown -R tester:tester ${HOME}
USER tester

# Image from which the environment for local testing of the installation script
# is built.
FROM install AS install-local

RUN mkdir -p "${NVIM_CONFIG}"
WORKDIR ${NVIM_CONFIG}

COPY ./ .

USER root
RUN chown -R tester:tester "${HOME}"
USER tester

ENTRYPOINT ["./env/entrypoint-install"]
