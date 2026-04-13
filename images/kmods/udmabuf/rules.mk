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

$(builddir_udmabuf): $(files_mod_udmabuf)
	mkdir -p $@
	cp $^ $@
	touch $@

$(kmod_udmabuf): export KERNEL_SRC_DIR := $(abspath $(kernel_dir))
$(kmod_udmabuf): export PWD=$(abspath $(builddir_udmabuf))
$(kmod_udmabuf): $(builddir_udmabuf) $(vmlinux)
	$(MAKE) -C $(builddir_udmabuf)
	cp $(builddir_udmabuf)/u-dma-buf.ko $@

CLEAN := $(builddir_udmabuf) $(kmod_udmabuf)

include mk/subdir_post.mk
