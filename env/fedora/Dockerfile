# Image to build all dependencies.
FROM fedora:42 AS builder

# Image that serves as the basis for creating environment images for remote
# and local unit tests.
FROM fedora:42 AS base

# Image from which the environment for local unit test is build.
FROM base AS local

# Image from which the environment for remote unit test and linting is build.
FROM base AS remote

# Image that serves as the basis for creating environment images for remote
# and local testing of the installation script.
FROM fedora:42 AS install

# Image from which the environment for local testing of the installation script
# is built.
FROM install AS install-local
