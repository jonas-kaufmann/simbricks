`timescale 1ps / 1ps
`include "vta_params.svh"


module vta_sim(
    input clk,
    input rst
);
    string pci_socket_str;
    string shm_path_str;
    longint sync_period;
    longint pci_latency;
    longint clk_freq_mhz;
    longint clk_period_ps;

    import "DPI-C" function void simbricks_init(
        input string pci_socket,
        input string shm_path,
        input longint sync_period,
        input longint pci_latency,
        input longint clk_freq_mhz
    );

    import "DPI-C" function bit simbricks_is_exit();
    
    // M AXI Lite for Control
    wire [31:0] m_axil_awaddr;
    wire [2:0] m_axil_awprot;
    wire m_axil_awvalid;
    wire m_axil_awready;
    wire [31:0] m_axil_wdata;
    wire [3:0] m_axil_wstrb;
    wire m_axil_wvalid;
    wire m_axil_wready;
    wire [1:0] m_axil_bresp;
    wire m_axil_bvalid;
    wire m_axil_bready;
    wire [31:0] m_axil_araddr;
    wire [2:0] m_axil_arprot;
    wire m_axil_arvalid;
    wire m_axil_arready;
    wire [31:0] m_axil_rdata;
    wire [1:0] m_axil_rresp;
    wire m_axil_rvalid;
    wire m_axil_rready;

    m_axil_adapter m_axil_ctrl(
        .clk(clk),
        .m_axil_awaddr(m_axil_awaddr),
        .m_axil_awprot(m_axil_awprot),
        .m_axil_awvalid(m_axil_awvalid),
        .m_axil_awready(m_axil_awready),
        .m_axil_wdata(m_axil_wdata),
        .m_axil_wstrb(m_axil_wstrb),
        .m_axil_wvalid(m_axil_wvalid),
        .m_axil_wready(m_axil_wready),
        .m_axil_bresp(m_axil_bresp),
        .m_axil_bvalid(m_axil_bvalid),
        .m_axil_bready(m_axil_bready),
        .m_axil_araddr(m_axil_araddr),
        .m_axil_arprot(m_axil_arprot),
        .m_axil_arvalid(m_axil_arvalid),
        .m_axil_arready(m_axil_arready),
        .m_axil_rdata(m_axil_rdata),
        .m_axil_rresp(m_axil_rresp),
        .m_axil_rvalid(m_axil_rvalid),
        .m_axil_rready(m_axil_rready)
    );

    // S AXI for DMAs
    wire [7:0] s_axi_awid;
    wire [63:0] s_axi_awaddr;
    wire [7:0] s_axi_awlen;
    wire [2:0] s_axi_awsize;
    wire [1:0] s_axi_awburst;
    wire s_axi_awvalid;
    wire s_axi_awready;
    wire [`VTA_BITS_DATA-1:0] s_axi_wdata;
    wire [(`VTA_BITS_DATA/8)-1:0] s_axi_wstrb;
    wire s_axi_wlast;
    wire s_axi_wvalid;
    wire s_axi_wready;
    wire [7:0] s_axi_bid;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    wire s_axi_bready;
    wire [7:0] s_axi_arid;
    wire [63:0] s_axi_araddr;
    wire [7:0] s_axi_arlen;
    wire [2:0] s_axi_arsize;
    wire [1:0] s_axi_arburst;
    wire s_axi_arvalid;
    wire s_axi_arready;
    wire [7:0] s_axi_rid;
    wire [`VTA_BITS_DATA-1:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rlast;
    wire s_axi_rvalid;
    wire s_axi_rready;

    s_axi_adapter s_axi_dma(
        .clk(clk),
        .s_axi_awid(s_axi_awid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bid(s_axi_bid),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_arid(s_axi_arid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rid(s_axi_rid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );

    // instantiate main module
    VTAShell VTAShell_wrapper_0(
        .clock(clk),
        .reset(rst),

        .io_host_aw_ready(m_axil_awready),
        .io_host_aw_valid(m_axil_awvalid),
        .io_host_aw_bits_addr(m_axil_awaddr[15:0]),
        .io_host_w_ready(m_axil_wready),
        .io_host_w_valid(m_axil_wvalid),
        .io_host_w_bits_data(m_axil_wdata),
        .io_host_w_bits_strb(m_axil_wstrb),
        .io_host_b_ready(m_axil_bready),
        .io_host_b_valid(m_axil_bvalid),
        .io_host_b_bits_resp(m_axil_bresp),
        .io_host_ar_ready(m_axil_arready),
        .io_host_ar_valid(m_axil_arvalid),
        .io_host_ar_bits_addr(m_axil_araddr[15:0]),
        .io_host_r_ready(m_axil_rready),
        .io_host_r_valid(m_axil_rvalid),
        .io_host_r_bits_data(m_axil_rdata),
        .io_host_r_bits_resp(m_axil_rresp),

        .io_mem_aw_ready(s_axi_awready),
        .io_mem_aw_valid(s_axi_awvalid),
        .io_mem_aw_bits_addr(s_axi_awaddr),
        .io_mem_aw_bits_id(s_axi_awid),
        .io_mem_aw_bits_user(),
        .io_mem_aw_bits_len(s_axi_awlen[`VTA_BITS_LEN-1:0]),
        .io_mem_aw_bits_size(s_axi_awsize),
        .io_mem_aw_bits_burst(s_axi_awburst),
        .io_mem_aw_bits_lock(),
        .io_mem_aw_bits_cache(),
        .io_mem_aw_bits_prot(),
        .io_mem_aw_bits_qos(),
        .io_mem_aw_bits_region(),
        .io_mem_w_ready(s_axi_wready),
        .io_mem_w_valid(s_axi_wvalid),
        .io_mem_w_bits_data(s_axi_wdata),
        .io_mem_w_bits_strb(s_axi_wstrb),
        .io_mem_w_bits_last(s_axi_wlast),
        .io_mem_w_bits_id(),
        .io_mem_w_bits_user(),
        .io_mem_b_ready(s_axi_bready),
        .io_mem_b_valid(s_axi_bvalid),
        .io_mem_b_bits_resp(s_axi_bresp),
        .io_mem_b_bits_id(s_axi_bid),
        .io_mem_b_bits_user(),
        .io_mem_ar_ready(s_axi_arready),
        .io_mem_ar_valid(s_axi_arvalid),
        .io_mem_ar_bits_addr(s_axi_araddr),
        .io_mem_ar_bits_id(s_axi_arid),
        .io_mem_ar_bits_user(),
        .io_mem_ar_bits_len(s_axi_arlen[`VTA_BITS_LEN-1:0]),
        .io_mem_ar_bits_size(s_axi_arsize),
        .io_mem_ar_bits_burst(s_axi_arburst),
        .io_mem_ar_bits_lock(),
        .io_mem_ar_bits_cache(),
        .io_mem_ar_bits_prot(),
        .io_mem_ar_bits_qos(),
        .io_mem_ar_bits_region(),
        .io_mem_r_ready(s_axi_rready),
        .io_mem_r_valid(s_axi_rvalid),
        .io_mem_r_bits_data(s_axi_rdata),
        .io_mem_r_bits_resp(s_axi_rresp),
        .io_mem_r_bits_last(s_axi_rlast),
        .io_mem_r_bits_id(s_axi_rid),
        .io_mem_r_bits_user('0)
    );

    initial begin
        if (!$value$plusargs("PCI_SOCKET=%s", pci_socket_str)) begin
            $fatal(1, "Missing required +PCI_SOCKET=<value> argument");
        end
        if (!$value$plusargs("SHM_PATH=%s", shm_path_str)) begin
            $fatal(1, "Missing required +SHM_PATH=<value> argument");
        end
        if (!$value$plusargs("SYNC_PERIOD=%d", sync_period)) begin
            $fatal(1, "Missing required +SYNC_PERIOD=<value> argument");
        end
        if (!$value$plusargs("PCI_LATENCY=%d", pci_latency)) begin
            $fatal(1, "Missing required +PCI_LATENCY=<value> argument");
        end
        if (!$value$plusargs("CLK_FREQ_MHZ=%d", clk_freq_mhz)) begin
            $fatal(1, "Missing required +CLK_FREQ_MHZ=<value> argument");
        end

        clk_period_ps = 1000000 / clk_freq_mhz;

        simbricks_init(
            pci_socket_str,
            shm_path_str,
            sync_period,
            pci_latency,
            clk_freq_mhz
        );
    end

    always @(posedge clk) begin
        if (simbricks_is_exit()) begin
            $display("Got exit signal from SimBricks adapter.");
            $finish();
        end
    end

endmodule
