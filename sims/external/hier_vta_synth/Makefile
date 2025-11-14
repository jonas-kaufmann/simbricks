SIMBRICKS_LIB_DIR := /local/jkaufman/simbricks-acdsim/lib
LIBSIMBRICKS := $(SIMBRICKS_LIB_DIR)/libsimbricks.a

ADDITIONAL_CFLAGS ?=
ADDITIONAL_VFLAGS ?=
CFLAGS := -I$(SIMBRICKS_LIB_DIR) -std=c++17 $(ADDITIONAL_CFLAGS)
VFLAGS := -Wno-fatal --threads 1 -j `nproc` -O3

NO_TRACE_CFLAGS := $(CFLAGS) $(ADDITIONAL_CFLAGS) -DTRACE_MODE=0
NO_TRACE_VFLAGS := $(VFLAGS) $(ADDITIONAL_VFLAGS)
VCD_TRACE_CFLAGS := $(CFLAGS) $(ADDITIONAL_CFLAGS) -DTRACE_MODE=1
VCD_TRACE_VFLAGS := $(VFLAGS) $(ADDITIONAL_VFLAGS) --trace-vcd --no-trace-top --trace-depth 2
SAIF_TRACE_CFLAGS := $(CFLAGS) $(ADDITIONAL_CFLAGS) -DTRACE_MODE=2
SAIF_TRACE_VFLAGS := $(VFLAGS) $(ADDITIONAL_VFLAGS) --trace-saif --no-trace-top


BIN := vta_sim_1x16_100_no_trace vta_sim_1x16_174_no_trace vta_sim_1x16_100_vcd_trace vta_sim_1x16_174_vcd_trace vta_sim_1x16_100_saif_trace vta_sim_1x16_174_saif_trace

all: $(BIN)

vta_sim_1x16_100_no_trace: vta_sim.sv vta_synth_1x16_100.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc ${LIBSIMBRICKS}
	verilator --top-module vta_sim -CFLAGS "${NO_TRACE_CFLAGS}" -y $(abspath ./verilator_xilinx) ${NO_TRACE_VFLAGS} --binary --build --exe -o $(abspath $@) $^

vta_sim_1x16_174_no_trace: vta_sim.sv vta_synth_1x16_174.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc ${LIBSIMBRICKS}
	verilator --top-module vta_sim -CFLAGS "${NO_TRACE_CFLAGS}" -y $(abspath ./verilator_xilinx) ${NO_TRACE_VFLAGS} --binary --build --exe -o $(abspath $@) $^

vta_sim_1x16_100_vcd_trace: vta_sim.sv vta_synth_1x16_100.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc ${LIBSIMBRICKS}
	verilator --top-module vta_sim -CFLAGS "${VCD_TRACE_CFLAGS}" -y $(abspath ./verilator_xilinx) ${VCD_TRACE_VFLAGS} --binary --build --exe -o $(abspath $@) $^

vta_sim_1x16_174_vcd_trace: vta_sim.sv vta_synth_1x16_174.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc ${LIBSIMBRICKS}
	verilator --top-module vta_sim -CFLAGS "${VCD_TRACE_CFLAGS}" -y $(abspath ./verilator_xilinx) ${VCD_TRACE_VFLAGS} --binary --build --exe -o $(abspath $@) $^

vta_sim_1x16_100_saif_trace: vta_sim.sv vta_synth_1x16_100.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc ${LIBSIMBRICKS}
	verilator --top-module vta_sim -CFLAGS "${SAIF_TRACE_CFLAGS}" -y $(abspath ./verilator_xilinx) ${SAIF_TRACE_VFLAGS} --binary --build --exe -o $(abspath $@) $^

vta_sim_1x16_174_saif_trace: vta_sim.sv vta_synth_1x16_174.v m_axil_adapter.sv s_axi_adapter.sv verilator_adapter.cc verilator_main.cc ${LIBSIMBRICKS}
	verilator --top-module vta_sim -CFLAGS "${SAIF_TRACE_CFLAGS}" -y $(abspath ./verilator_xilinx) ${SAIF_TRACE_VFLAGS} --binary --build --exe -o $(abspath $@) $^

clean:
	rm -rf ${BIN} obj_dir

.PHONY: all $(BIN) clean
