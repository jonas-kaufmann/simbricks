# Copyright 2021 Max Planck Institute for Software Systems, and
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

PACKER_VERSION_ARM64 := 1.7.0
KERNEL_VERSION_ARM64 := 5.15.93

BASE_IMAGE_ARM64 := $(d)output-base/base
MEMCACHED_IMAGE_ARM64 := $(d)output-memcached/memcached
NOPAXOS_IMAGE_ARM64 := $(d)output-nopaxos/nopaxos
VTA_DEP_IMAGE_ARM64 := $(d)output-vta_dep/vta_dep
VTA_IMAGE_ARM64 := $(d)output-vta/vta
GEMSTONE_IMAGE_ARM64 := $(d)output-gemstone/gemstone
COMPRESSED_IMAGES_ARM64 ?= false

IMAGES_ARM64 := $(BASE_IMAGE_ARM64) $(NOPAXOS_IMAGE_ARM64) \
    $(MEMCACHED_IMAGE_ARM64) \
    $(VTA_IMAGE_ARM64)
RAW_IMAGES_ARM64 := $(addsuffix .raw,$(IMAGES_ARM64))

IMAGES_MIN_ARM64 := $(BASE_IMAGE_ARM64)
RAW_IMAGES_MIN_ARM64 := $(addsuffix .raw,$(IMAGES_MIN_ARM64))

img_dir_arm64 := $(d)
packer_arm64 := $(d)packer

bz_image_arm64 := $(d)bzImage
vmlinux_arm64 := $(d)vmlinux
kernel_pardir_arm64 := $(d)kernel
kernel_dir_arm64 := $(kernel_pardir_arm64)/linux-$(KERNEL_VERSION_ARM64)
kernel_config_arm64 := $(kernel_pardir_arm64)/config-$(KERNEL_VERSION_ARM64)
kernel_options_arm64 := ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
kheader_dir_arm64 := $(d)kernel/kheaders
kheader_tar_arm64 := $(d)kheaders.tar.bz2
m5_bin_arm64 := $(d)m5
guest_init_arm64 := $(d)/scripts/guestinit.sh

build-images-aarch64: $(IMAGES_ARM64) $(RAW_IMAGES_ARM64) \
    $(vmlinux_arm64) \
    $(bz_image_arm64)

build-images-min-aarch64: $(IMAGES_MIN_ARM64) $(RAW_IMAGES_MIN_ARM64) \
    $(vmlinux_arm64) $(bz_image_arm64)

# only converts existing images to raw
convert-images-raw-aarch64:
	for i in $(IMAGES_ARM64); do \
	    [ -f $$i ] || continue; \
	    $(QEMU_IMG) convert -f qcow2 -O raw $$i $${i}.raw ; done

################################################
# Disk image

%.raw: %
	$(QEMU_IMG) convert -f qcow2 -O raw $< $@

$(BASE_IMAGE_ARM64): $(packer_arm64) $(QEMU) $(bz_image_arm64) \
    $(m5_bin_arm64) $(kheader_tar_arm64) $(guest_init_arm64) \
    $(kernel_config_arm64) $(kmod_udmabuf_arm64) \
    $(addprefix $(d), extended-image.pkr.hcl scripts/install-base.sh \
      scripts/cleanup.sh)
	rm -rf $(dir $@)
	mkdir -p $(img_dir_arm64)input-base
	cp $(m5_bin_arm64) $(kheader_tar_arm64) $(guest_init_arm64) \
	    $(bz_image_arm64) $(kernel_config_arm64) \
	    $(kmod_udmabuf_arm64) \
	    $(img_dir_arm64)input-base/
	truncate -s 64m $(img_dir_arm64)varstore.img
	truncate -s 64m $(img_dir_arm64)efi.img
	dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=$(img_dir_arm64)efi.img conv=notrunc
	cd $(img_dir_arm64) && ./packer-wrap.sh base base base.pkr.hcl \
	    $(COMPRESSED_IMAGES_ARM64)
	rm -rf $(img_dir_arm64)input-base
	touch $@

TVM_DIR_ARM64 := $(img_dir_arm64)tvm

$(VTA_DEP_IMAGE_ARM64): $(packer_arm64) $(QEMU) $(BASE_IMAGE_ARM64) \
    $(addprefix $(d), extended-image.pkr.hcl scripts/install-vta_dep.sh \
      scripts/cleanup.sh)
	rm -rf $(dir $@)
	cd $(img_dir_arm64) && ./packer-wrap.sh base vta_dep extended-image.pkr.hcl \
	    $(COMPRESSED_IMAGES_ARM64)
	touch $@

$(VTA_IMAGE_ARM64): $(packer_arm64) $(QEMU) $(VTA_DEP_IMAGE_ARM64) \
    $(addprefix $(d), extended-image.pkr.hcl scripts/install-vta.sh \
      scripts/cleanup.sh)
	rm -rf $(dir $@)
	cd $(img_dir_arm64) && ./packer_arm64-wrap.sh vta_dep vta extended-image.pkr.hcl \
	    $(COMPRESSED_IMAGES_ARM64)
	touch $@

$(GEMSTONE_IMAGE_ARM64): $(packer_arm64) $(QEMU) $(BASE_IMAGE_ARM64) \
    $(addprefix $(d), extended-image.pkr.hcl scripts/install-gemstone.sh \
      scripts/cleanup.sh)
	rm -rf $(dir $@)
	rm -rf $(img_dir_arm64)input-gemstone
	mkdir -p $(img_dir_arm64)input-gemstone
	ln -s /home/jonask/Repos/cpu_micro_benchmarks $(img_dir_arm64)input-gemstone/cpu_micro_benchmarks
	cd $(img_dir_arm64) && ./packer-wrap.sh base gemstone extended-image.pkr.hcl \
	    $(COMPRESSED_IMAGES_ARM64)
	touch $@


$(packer_arm64):
	wget -O $(img_dir_arm64)packer_$(PACKER_VERSION_ARM64)_linux_amd64.zip \
	    https://releases.hashicorp.com/packer/$(PACKER_VERSION_ARM64)/packer_$(PACKER_VERSION_ARM64)_linux_amd64.zip
	cd $(img_dir_arm64) && unzip packer_$(PACKER_VERSION_ARM64)_linux_amd64.zip
	rm -f $(img_dir_arm64)packer_$(PACKER_VERSION_ARM64)_linux_amd64.zip


################################################
# Kernel

$(kernel_dir_arm64)/vmlinux: $(kernel_dir_arm64)/.config
	$(MAKE) $(kernel_options_arm64) -C $(kernel_dir_arm64)
	touch $@

$(vmlinux_arm64): $(kernel_dir_arm64)/vmlinux
	cp $< $@
	touch $@

# this dependency is a bit stupid, but not sure how to better do this
$(bz_image_arm64): $(kernel_dir_arm64)/vmlinux
	cp $(kernel_dir_arm64)/arch/arm64/boot/Image.gz $@
	touch $@

$(kheader_tar_arm64): $(kernel_dir_arm64)/vmlinux
	rm -rf $(kheader_dir_arm64)
	mkdir -p $(kheader_dir_arm64)
	$(MAKE) $(kernel_options_arm64) -C $(kernel_dir_arm64) headers_install INSTALL_HDR_PATH=$(abspath $(kheader_dir_arm64)/usr)
	$(MAKE) $(kernel_options_arm64) -C $(kernel_dir_arm64) modules_install INSTALL_MOD_PATH=$(abspath $(kheader_dir_arm64))
	rm -f $(kheader_dir_arm64)/lib/modules/$(KERNEL_VERSION_ARM64)/build
	ln -s /usr/src/linux-headers-$(KERNEL_VERSION_ARM64) \
	    $(kheader_dir_arm64)/lib/modules/$(KERNEL_VERSION_ARM64)/build
	rm -f $(kheader_dir_arm64)/lib/modules/$(KERNEL_VERSION_ARM64)/source
	mkdir -p $(kheader_dir_arm64)/usr/src/linux-headers-$(KERNEL_VERSION_ARM64)
	cp -r $(kernel_dir_arm64)/.config $(kernel_dir_arm64)/Makefile \
	    $(kernel_dir_arm64)/Module.symvers $(kernel_dir_arm64)/scripts \
	    $(kernel_dir_arm64)/include \
	    $(kheader_dir_arm64)/usr/src/linux-headers-$(KERNEL_VERSION_ARM64)/
	mkdir -p $(kheader_dir_arm64)/usr/src/linux-headers-$(KERNEL_VERSION_ARM64)/tools/objtool/
	mkdir -p $(kheader_dir_arm64)/usr/src/linux-headers-$(KERNEL_VERSION_ARM64)/arch/arm64/
	cp -r $(kernel_dir_arm64)/arch/arm64/Makefile \
	    $(kernel_dir_arm64)/arch/arm64/include \
	    $(kheader_dir_arm64)/usr/src/linux-headers-$(KERNEL_VERSION_ARM64)/arch/arm64
	cd $(kheader_dir_arm64) && tar cjf $(abspath $@) .

$(kernel_dir_arm64)/.config: $(kernel_pardir_arm64)/config-$(KERNEL_VERSION_ARM64)
	rm -rf $(kernel_dir_arm64)
	wget -O - https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$(KERNEL_VERSION_ARM64).tar.xz | \
	    tar xJf - -C $(kernel_pardir_arm64)
	cd $(kernel_dir_arm64) && patch -p1 < ../linux-$(KERNEL_VERSION_ARM64)-timers-gem5.patch
	cp $< $@


$(eval $(call subdir,kmods))


CLEAN :=
DISTCLEAN := $(kernel_dir_arm64) $(packer_arm64) $(bz_image_arm64) \
    $(vmlinux_arm64) $(kheader_dir_arm64) \
    $(foreach i,$(IMAGES_ARM64),$(dir $(i)) $(subst output-,input-,$(dir $(i)))) \
    $(d)packer_cache $(d)kheaders.tar.bz2

include mk/subdir_post.mk
