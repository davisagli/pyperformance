# syntax=docker/dockerfile:1
FROM ubuntu:latest

# Build dependencies
RUN <<EOT
    apt-get update
    apt-get -y upgrade
    apt-get -y build-dep python3
    apt-get install -y --no-install-recommends build-essential gdb pkg-config libffi-dev libssl-dev zlib1g-dev git ca-certificates
EOT

COPY . .

# build CPython main
RUN <<EOT
    cd base
    make clean
    ./configure --enable-optimizations
    make profile-opt
    ./python -m ensurepip
    ./python -m venv venv
    venv/bin/pip install pyperf
    cd ..
EOT

# build CPython branch
RUN <<EOT
    cd work
    make clean
    ./configure --enable-optimizations
    make profile-opt
    ./python -m ensurepip
    ./python -m venv venv
    venv/bin/pip install pyperf
    cd ..
EOT
