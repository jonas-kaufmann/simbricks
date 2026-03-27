FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Berlin \
    apt-get install -y --no-install-recommends \
    autoconf \
    bc \
    bear \
    bison \
    build-essential \
    clang-20 \
    clangd-20 \
    cmake \
    direnv \
    flex \
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu \
    gdb \
    graphviz \
    help2man \
    kmod \
    libboost-coroutine-dev \
    libboost-fiber-dev \
    libboost-iostreams-dev \
    libboost-program-options-dev \
    libclang-rt-20-dev \
    libelf-dev \
    libfl-dev \
    libfl2 \
    libglib2.0-dev \
    libgmp-dev \
    libgoogle-perftools-dev \
    libnanomsg-dev \
    libpcap-dev \
    libpixman-1-dev \
    libprotobuf-dev \
    libssl-dev \
    libtool \
    lld-20 \
    locales \
    mold \
    ninja-build \
    perl \
    perl-doc \
    protobuf-compiler \
    python-is-python3 \
    python3 \
    python3-dev \
    python3-numpy \
    python3-pil \
    python3-pip \
    python3-pydot \
    qemu-system-aarch64 \
    rsync \
    scons \
    tmux \
    unzip \
    wget \
    zlib1g \
    zlib1g-dev \
 && locale-gen en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/* \
 && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-20 200 \
 && echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc

RUN curl -sSf https://sh.rustup.rs | sh -s -- -y \
 && export PATH="/root/.cargo/bin:$PATH" \
 && cargo install --git https://gitlab.com/surfer-project/surfer.git surver \
 && cp /root/.cargo/bin/surver /usr/local/bin/ \
 && rustup self uninstall -y
