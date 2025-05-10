SIMBRICKS_LIB_DIR := /local/jkaufman/simbricks-acdsim/lib
LIBSIMBRICKS := $(SIMBRICKS_LIB_DIR)/libsimbricks.a

ADDITIONAL_CFLAGS ?=
ADDITIONAL_VFLAGS ?=
CFLAGS := -I$(SIMBRICKS_LIB_DIR) -std=c++17 $(ADDITIONAL_CFLAGS)
VFLAGS := -Wno-fatal --threads 4 -j 8 -O3

vta_sim_1x16_100: vta_sim.sv vta_synth_1x16_100.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc /local/jkaufman/simbricks-acdsim/lib/libsimbricks.a
	verilator -j `nproc` --top-module vta_sim -CFLAGS "${CFLAGS}" -y $(abspath ./verilator_xilinx) ${VFLAGS} ${ADDITIONAL_VFLAGS} --binary --build --exe -o $(abspath $@) $^

vta_sim_1x16_175: vta_sim.sv vta_synth_1x16_175.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc /local/jkaufman/simbricks-acdsim/lib/libsimbricks.a
	verilator -j `nproc` --top-module vta_sim -CFLAGS "${CFLAGS}" -y $(abspath ./verilator_xilinx) ${VFLAGS} ${ADDITIONAL_VFLAGS} --binary --build --exe -o $(abspath $@) $^

clean:
	rm -rf vta_sim_1x16_100 vta_sim_1x16_175 obj_dir

.PHONY: vta_sim clean
