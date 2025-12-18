#!/bin/bash
set -eux

# build tvm
mkdir -p /root
git clone --depth 1 --recursive --branch acdsim-v0.8.0 https://github.com/jonas-kaufmann/tvm-simbricks.git /root/tvm
cd /root/tvm
cp 3rdparty/vta-hw/config/simbricks_pci_sample.json 3rdparty/vta-hw/config/vta_config.json
mkdir build
cp cmake/config.cmake build
cd build
echo "set(USE_LLVM OFF)" >> config.cmake
echo "set(SUMMARIZE ON)" >> config.cmake
echo "set(CMAKE_BUILD_TYPE RelWithDebInfo)" >> config.cmake
export CXXFLAGS="-D SIM_CTRL=1"
cmake ..
make -j`nproc` runtime vta
