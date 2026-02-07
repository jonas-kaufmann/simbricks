# Copyright 2026 Max Planck Institute for Software Systems, and
# National University of Singapore
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

include mk/subdir_pre.mk

builddir_udmabuf_arm64 := $(d)build/
kmod_udmabuf_arm64 := $(d)u-dma-buf.ko

$(builddir_udmabuf_arm64): $(files_mod_udmabuf)
	mkdir -p $@
	cp $^ $@
	touch $@

$(kmod_udmabuf_arm64): export KERNEL_SRC_DIR := $(abspath $(kernel_dir_arm64))
$(kmod_udmabuf_arm64): export ARCH := arm64
$(kmod_udmabuf_arm64): export CROSS_COMPILE=aarch64-linux-gnu-
$(kmod_udmabuf_arm64): export PWD=$(abspath $(builddir_udmabuf_arm64))
$(kmod_udmabuf_arm64): $(builddir_udmabuf_arm64) $(vmlinux_arm64)
	$(MAKE) -C $(builddir_udmabuf_arm64)
	cp $(builddir_udmabuf_arm64)/u-dma-buf.ko $@

CLEAN := $(builddir_udmabuf_arm64) $(kmod_udmabuf_arm64)

include mk/subdir_post.mk
