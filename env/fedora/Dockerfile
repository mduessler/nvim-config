# Build image to build everything once.
# Copy required dependencies, requirements, etc to final images.
# This image contains everything which will be later on the local or remote image
#
FROM fedora:42 AS builder

# Image to use during local unit tests.
#
FROM fedora:42 AS local

# Image to use during remote linting and unit tests.
#
FROM fedora:42 AS remote
