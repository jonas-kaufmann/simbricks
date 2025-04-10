`timescale 1ps / 1ps

module vta_sim
#(
    parameter SIMBRICKS_PCI_SOCKET = "/path/to/socket",
    parameter SHM_PATH = "/path/to/shm",
    parameter SYNC_PERIOD = 500,
    parameter PCI_LATENCY = 500,
    parameter CLK_FREQ_MHZ = 150
)
(
    input clk,
    input rst
);      
    localparam CLK_PERIOD_PS = 1000000 / CLK_FREQ_MHZ;
    
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
    wire [5:0] s_axi_awid;
    wire [63:0] s_axi_awaddr;
    wire [7:0] s_axi_awlen;
    wire [2:0] s_axi_awsize;
    wire [1:0] s_axi_awburst;
    wire s_axi_awvalid;
    wire s_axi_awready;
    wire [63:0] s_axi_wdata;
    wire [7:0] s_axi_wstrb;
    wire s_axi_wlast;
    wire s_axi_wvalid;
    wire s_axi_wready;
    wire [7:0] s_axi_bid;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    wire s_axi_bready;
    wire [5:0] s_axi_arid;
    wire [63:0] s_axi_araddr;
    wire [7:0] s_axi_arlen;
    wire [2:0] s_axi_arsize;
    wire [1:0] s_axi_arburst;
    wire s_axi_arvalid;
    wire s_axi_arready;
    wire [7:0] s_axi_rid;
    wire [63:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rlast;
    wire s_axi_rvalid;
    wire s_axi_rready;

    s_axi_adapter s_axi_dma(
        .clk(clk),
        .s_axi_awid({2'b0, s_axi_awid}),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awsize({5'b0, s_axi_awsize}),
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
        .s_axi_arid({2'b0, s_axi_arid}),
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
    vta_base_VTAShell_wrapper_0_1 VTAShell_wrapper_0(
        .clock(clk),
        .m_axi_araddr(s_axi_araddr[48:0]),
        .m_axi_arburst(s_axi_arburst),
        .m_axi_arid(s_axi_arid),
        .m_axi_arlen(s_axi_arlen),
        .m_axi_arready(s_axi_arready),
        .m_axi_arsize(s_axi_arsize),
        .m_axi_arvalid(s_axi_arvalid),
        .m_axi_awaddr(s_axi_awaddr[48:0]),
        .m_axi_awburst(s_axi_awburst),
        .m_axi_awid(s_axi_awid),
        .m_axi_awlen(s_axi_awlen),
        .m_axi_awready(s_axi_awready),
        .m_axi_awsize(s_axi_awsize),
        .m_axi_awvalid(s_axi_awvalid),
        .m_axi_bid(s_axi_bid),
        .m_axi_bready(s_axi_bready),
        .m_axi_bresp(s_axi_bresp),
        .m_axi_bvalid(s_axi_bvalid),
        .m_axi_rdata(s_axi_rdata),
        .m_axi_rid(s_axi_rid),
        .m_axi_rlast(s_axi_rlast),
        .m_axi_rready(s_axi_rready),
        .m_axi_rresp(s_axi_rresp),
        .m_axi_rvalid(s_axi_rvalid),
        .m_axi_wdata(s_axi_wdata),
        .m_axi_wlast(s_axi_wlast),
        .m_axi_wready(s_axi_wready),
        .m_axi_wstrb(s_axi_wstrb),
        .m_axi_wvalid(s_axi_wvalid),
        .reset(rst),
        .s_axi_araddr(m_axil_araddr),
        .s_axi_arready(m_axil_arready),
        .s_axi_arvalid(m_axil_arvalid),
        .s_axi_awaddr(m_axil_awaddr),
        .s_axi_awready(m_axil_awready),
        .s_axi_awvalid(m_axil_awvalid),
        .s_axi_bready(m_axil_bready),
        .s_axi_bresp(m_axil_bresp),
        .s_axi_bvalid(m_axil_bvalid),
        .s_axi_rdata(m_axil_rdata),
        .s_axi_rready(m_axil_rready),
        .s_axi_rresp(m_axil_rresp),
        .s_axi_rvalid(m_axil_rvalid),
        .s_axi_wdata(m_axil_wdata),
        .s_axi_wready(m_axil_wready),
        .s_axi_wstrb(m_axil_wstrb),
        .s_axi_wvalid(m_axil_wvalid)
    );
    
    initial begin
        simbricks_init(
            SIMBRICKS_PCI_SOCKET,
            SHM_PATH,
            SYNC_PERIOD,
            PCI_LATENCY,
            CLK_FREQ_MHZ
        );
    end
        
    always @(posedge clk) begin
        if (simbricks_is_exit()) begin
            $display("Got exit signal from SimBricks adapter.");
            $finish();
        end
    end

endmodule
