FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Berlin \
    apt-get install -y --no-install-recommends \
    autoconf \
    bear \
    build-essential \
    clang-20 \
    clangd-20 \
    cmake \
    direnv \
    flex \
    graphviz \
    kmod \
    libboost-coroutine-dev \
    libboost-fiber-dev \
    libboost-iostreams-dev \
    libboost-program-options-dev \
    libelf-dev \
    libglib2.0-dev \
    libgmp-dev \
    libgoogle-perftools-dev \
    libnanomsg-dev \
    libpcap-dev \
    libpixman-1-dev \
    libprotobuf-dev \
    libssl-dev \
    libtool \
    locales \
    mold \
    ninja-build \
    protobuf-compiler \
    python-is-python3 \
    python3 \
    python3-dev \
    python3-pip \
    rsync \
    scons \
    unzip \
    wget \
 && locale-gen en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/* \
 && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-20 200 \
 && echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc
