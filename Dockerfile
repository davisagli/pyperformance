# syntax=docker/dockerfile:1
FROM ubuntu:latest AS base

# Build dependencies
RUN <<EOT
    apt-get update
    apt-get -y upgrade
    apt-get -y build-dep python3
    apt-get install -y --no-install-recommends build-essential gdb pkg-config libffi-dev libssl-dev zlib1g-dev git ca-certificates
EOT

COPY . .

# build CPython main
FROM base as main
RUN <<EOT
    cd base
    make clean
    ./configure --enable-optimizations
    make profile-opt -j
    ./python -m ensurepip
    ./python -m venv venv
    venv/bin/pip install pyperf
    cd ..
EOT

# build CPython branch
FROM base as branch
RUN <<EOT
    cd work
    make clean
    ./configure --enable-optimizations
    make profile-opt -j
    ./python -m ensurepip
    ./python -m venv venv
    venv/bin/pip install pyperf
    cd ..
EOT

# Combined image
FROM main as final
COPY --from=branch work work
