#include <Vvta_sim.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <cstdint>
#include <iostream>
#include <ostream>
#include <sstream>
#include <string>

#define VL_TRACE

int main(int argc, char** argv, char**) {
  if (argc != 5) {
    std::cerr << "usage: vta_sim <clock frequency in MHz> <enable tracing> "
                 "<path to waveform "
                 "file without .vcd suffix> <nanoseconds after which to write "
                 "to next waveform file>"
              << std::endl;
    return 1;
  }
  uint64_t clk_freq = std::stoull(argv[1]);
  uint64_t clk_period_ps = 1000000 / clk_freq;
  bool do_trace = std::stoi(argv[2]);
  uint64_t sampling_period_ps = std::stoull(argv[4]) * 1000;
  uint64_t trace_idx = 0;
  uint64_t next_trace_file_at_ps = sampling_period_ps;

  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  const std::unique_ptr<Vvta_sim> topp{new Vvta_sim{contextp.get(), ""}};

  // Reset design
  topp->rst = 1;
  for (int i = 0; i < 10; ++i) {
    topp->clk = 0;
    topp->eval();
    topp->clk = 1;
    topp->eval();
  }
  topp->rst = 0;

// Set up tracing
#ifdef VL_TRACE
  const std::unique_ptr<VerilatedVcdC> tfp{new VerilatedVcdC};
  if (do_trace) {
    Verilated::traceEverOn(true);
    topp->trace(tfp.get(), 0);
    //   tfp->dumpvars(0, "vta_sim");
    std::ostringstream trace_file_stream;
    trace_file_stream << argv[3] << "_0.vcd";
    tfp->open(trace_file_stream.str().c_str());
  }
#endif

  // Simulate until $finish
  while (!contextp->gotFinish()) {
    // Evaluate model
    topp->clk = !topp->clk;
    topp->eval();
// Trace
#ifdef VL_TRACE
    if (do_trace) {
      if (contextp->time() >= next_trace_file_at_ps) {
        next_trace_file_at_ps = contextp->time() + sampling_period_ps;
        tfp->close();
        std::ostringstream trace_file_stream;
        trace_file_stream << argv[3] << "_" << ++trace_idx << ".vcd";
        tfp->open(trace_file_stream.str().c_str());
      }
      tfp->dump(contextp->time());
    }
#endif
    // Advance time
    contextp->timeInc(clk_period_ps / 2);
  }

// Close trace
#ifdef VL_TRACE
  if (do_trace) {
    tfp->close();
  }
#endif

  // Execute 'final' processes
  topp->final();
  // Print statistical summary report
  contextp->statsPrintSummary();

  return 0;
}
