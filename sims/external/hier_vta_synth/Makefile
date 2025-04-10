SIMBRICKS_LIB_DIR := /home/jonask/Repos/simbricks/lib
LIBSIMBRICKS := $(SIMBRICKS_LIB_DIR)/libsimbricks.a

CFLAGS := -I$(SIMBRICKS_LIB_DIR)
VFLAGS := --trace -Wno-fatal --threads 4
ADDITIONAL_VFLAGS ?= 

vta_sim: vta_sim.sv hier_vta_1x16.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc /home/jonask/Repos/simbricks/lib/libsimbricks.a
	verilator -j `nproc` --top-module $@ -CFLAGS "${CFLAGS}" -y $(abspath ./verilator_xilinx) ${VFLAGS} ${ADDITIONAL_VFLAGS} --binary --build --exe -o $(abspath $@) $^

all: vta_sim

clean:
	rm -rf vta_sim obj_dir

.PHONY: vta_sim clean
