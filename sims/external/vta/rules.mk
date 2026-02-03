include mk/subdir_pre.mk

VERILATOR_MDIR := $(d)obj_dir

CC := clang-20
CXX := clang++-20
ADDITIONAL_CFLAGS ?=
ADDITIONAL_VFLAGS ?=
BASE_CFLAGS := -I$(abspath $(lib_dir)) -std=c++17 $(ADDITIONAL_CFLAGS)
BASE_VFLAGS := -Wno-fatal --threads 2 -j `nproc` -O3 --compiler clang -MAKEFLAGS "OPT=-march=native" --Mdir $(VERILATOR_MDIR)

NO_TRACE_CFLAGS := $(BASE_CFLAGS) $(ADDITIONAL_CFLAGS) -DTRACE_MODE=0
NO_TRACE_VFLAGS := $(BASE_VFLAGS) $(ADDITIONAL_VFLAGS)
VCD_TRACE_CFLAGS := $(BASE_CFLAGS) $(ADDITIONAL_CFLAGS) -DTRACE_MODE=1
VCD_TRACE_VFLAGS := $(BASE_VFLAGS) $(ADDITIONAL_VFLAGS) --trace-vcd --no-trace-top --trace-depth 2
SAIF_TRACE_CFLAGS := $(BASE_CFLAGS) $(ADDITIONAL_CFLAGS) -DTRACE_MODE=2
SAIF_TRACE_VFLAGS := $(BASE_VFLAGS) $(ADDITIONAL_VFLAGS) --trace-saif --no-trace-top

BIN := $(d)vta_rtl_sim_1x16_no_trace \
	$(d)vta_rtl_sim_1x16_vcd_trace \
	$(d)vta_rtl_sim_1x16_saif_trace \
	$(d)vta_rtl_sim_1x32_no_trace \
	$(d)vta_rtl_sim_1x32_vcd_trace \
	$(d)vta_rtl_sim_1x32_saif_trace \
	$(d)vta_synth_sim_1x16_100_no_trace \
	$(d)vta_synth_sim_1x16_174_no_trace \
	$(d)vta_synth_sim_1x16_100_vcd_trace \
	$(d)vta_synth_sim_1x16_174_vcd_trace \
	$(d)vta_synth_sim_1x16_100_saif_trace \
	$(d)vta_synth_sim_1x16_174_saif_trace
VERILATOR_XILINX := $(d)verilator_xilinx

vta-all: $(BIN)

$(d)vta_rtl_sim_1x16_no_trace: private CFLAGS := $(NO_TRACE_CFLAGS)
$(d)vta_rtl_sim_1x16_no_trace: private VFLAGS := $(NO_TRACE_VFLAGS)
$(d)vta_rtl_sim_1x16_no_trace: $(d)vta_sim_rtl.sv $(d)vta_rtl_1x16.sv $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_rtl_sim_1x16_vcd_trace: private CFLAGS := $(VCD_TRACE_CFLAGS)
$(d)vta_rtl_sim_1x16_vcd_trace: private VFLAGS := $(VCD_TRACE_VFLAGS)
$(d)vta_rtl_sim_1x16_vcd_trace: $(d)vta_sim_rtl.sv $(d)vta_rtl_1x16.sv $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_rtl_sim_1x16_saif_trace: private CFLAGS := $(SAIF_TRACE_CFLAGS)
$(d)vta_rtl_sim_1x16_saif_trace: private VFLAGS := $(SAIF_TRACE_VFLAGS)
$(d)vta_rtl_sim_1x16_saif_trace: $(d)vta_sim_rtl.sv $(d)vta_rtl_1x16.sv $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_rtl_sim_1x32_no_trace: private CFLAGS := $(NO_TRACE_CFLAGS)
$(d)vta_rtl_sim_1x32_no_trace: private VFLAGS := $(NO_TRACE_VFLAGS)
$(d)vta_rtl_sim_1x32_no_trace: $(d)vta_sim_rtl.sv $(d)vta_rtl_1x32.sv $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_rtl_sim_1x32_vcd_trace: private CFLAGS := $(VCD_TRACE_CFLAGS)
$(d)vta_rtl_sim_1x32_vcd_trace: private VFLAGS := $(VCD_TRACE_VFLAGS)
$(d)vta_rtl_sim_1x32_vcd_trace: $(d)vta_sim_rtl.sv $(d)vta_rtl_1x32.sv $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_rtl_sim_1x32_saif_trace: private CFLAGS := $(SAIF_TRACE_CFLAGS)
$(d)vta_rtl_sim_1x32_saif_trace: private VFLAGS := $(SAIF_TRACE_VFLAGS)
$(d)vta_rtl_sim_1x32_saif_trace: $(d)vta_sim_rtl.sv $(d)vta_rtl_1x32.sv $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_synth_sim_1x16_100_no_trace: private CFLAGS := $(NO_TRACE_CFLAGS)
$(d)vta_synth_sim_1x16_100_no_trace: private VFLAGS := $(NO_TRACE_VFLAGS)
$(d)vta_synth_sim_1x16_100_no_trace: $(d)vta_sim_synth.sv $(d)vta_synth_1x16_100.v $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_synth_sim_1x16_174_no_trace: private CFLAGS := $(NO_TRACE_CFLAGS)
$(d)vta_synth_sim_1x16_174_no_trace: private VFLAGS := $(NO_TRACE_VFLAGS)
$(d)vta_synth_sim_1x16_174_no_trace: $(d)vta_sim_synth.sv $(d)vta_synth_1x16_174.v $(d)m_axil_adapter.sv $(d)$(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_synth_sim_1x16_100_vcd_trace: private CFLAGS := $(VCD_TRACE_CFLAGS)
$(d)vta_synth_sim_1x16_100_vcd_trace: private VFLAGS := $(VCD_TRACE_VFLAGS)
$(d)vta_synth_sim_1x16_100_vcd_trace: $(d)vta_sim_synth.sv $(d)vta_synth_1x16_100.v $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_synth_sim_1x16_174_vcd_trace: private CFLAGS := $(VCD_TRACE_CFLAGS)
$(d)vta_synth_sim_1x16_174_vcd_trace: private VFLAGS := $(VCD_TRACE_VFLAGS)
$(d)vta_synth_sim_1x16_174_vcd_trace: $(d)vta_sim_synth.sv $(d)vta_synth_1x16_174.v $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_synth_sim_1x16_100_saif_trace: private CFLAGS := $(SAIF_TRACE_CFLAGS)
$(d)vta_synth_sim_1x16_100_saif_trace: private VFLAGS := $(SAIF_TRACE_VFLAGS)
$(d)vta_synth_sim_1x16_100_saif_trace: $(d)vta_sim_synth.sv $(d)vta_synth_1x16_100.v $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

$(d)vta_synth_sim_1x16_174_saif_trace: private CFLAGS := $(SAIF_TRACE_CFLAGS)
$(d)vta_synth_sim_1x16_174_saif_trace: private VFLAGS := $(SAIF_TRACE_VFLAGS)
$(d)vta_synth_sim_1x16_174_saif_trace: $(d)vta_sim_synth.sv $(d)vta_synth_1x16_174.v $(d)m_axil_adapter.sv $(d)s_axi_adapter.sv $(d)verilator_adapter.cc $(d)verilator_main.cc $(abspath $(lib_simbricks))
	verilator --top-module vta_sim -CFLAGS "$(CFLAGS)" -y $(VERILATOR_XILINX) $(VFLAGS) --binary --build --exe -o $(abspath $@) $^

vta-clean:
	rm -rf $(BIN) $(VERILATOR_MDIR)

CLEAN := vta-clean

.PHONY: vta-all $(BIN) vta-clean

include mk/subdir_post.mk
