//=================================================================================
// tb_fft_sys: 2R.3 系统级 FFT 验证——ai_acce_top + AXI-Lite BFM + 4×axi_ram
//
// 复刻 main.cpp 板级寄存器流:
//   reg9  = 3              (is_fft=1, is_int16=1)
//   reg1  = 0x3C000000     (core0 R 基址 -> u_axi_ram_imap mem[0..])
//   reg2  = 0x3C800000     (core0 W 基址 -> mem[4096..])
//   reg29 = (sign_len<<16)|(stage<<12)|config ... start
// 预填: u_axi_ram_imap.mem[i] = {样本2i+1, 样本2i} (32b={im,re}, im=0)
// 回读: mem[4096+j] -> sim/fft_sys/out_512.txt (每行 re im)
// 对拍: python vs note/p2_scripts/sys_data/sys_expect_512.txt (C-fl 模型, bit-exact)
//=================================================================================
module tb_fft_sys;

    localparam PERIOD = 10;
    localparam NPOINT = 512;
    localparam STAGE = 9;
    localparam SIGN_LEN = 1;
    localparam R_BASE = 32'h3C00_0000;
    localparam W_BASE = 32'h3C80_0000;
    localparam W_IDX = 4096;          // 0x8000 >> 3

    reg clk, rstn;

    // ---------------- AXI-Lite BFM ----------------
    reg  [31:0] S_AXI_AWADDR;
    reg  [2:0]  S_AXI_AWPROT;
    reg         S_AXI_AWVALID;
    wire        S_AXI_AWREADY;
    reg  [31:0] S_AXI_WDATA;
    reg  [3:0]  S_AXI_WSTRB;
    reg         S_AXI_WVALID;
    wire        S_AXI_WREADY;
    wire [1:0]  S_AXI_BRESP;
    wire        S_AXI_BVALID;
    reg         S_AXI_BREADY;
    reg  [31:0] S_AXI_ARADDR;
    reg  [2:0]  S_AXI_ARPROT;
    reg         S_AXI_ARVALID;
    wire        S_AXI_ARREADY;
    wire [31:0] S_AXI_RDATA;
    wire [1:0]  S_AXI_RRESP;
    wire        S_AXI_RVALID;
    reg         S_AXI_RREADY;

    task axi_wr(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            S_AXI_AWADDR = addr; S_AXI_AWPROT = 0; S_AXI_AWVALID = 1;
            S_AXI_WDATA = data;  S_AXI_WSTRB = 4'hF; S_AXI_WVALID = 1;
            S_AXI_BREADY = 1;
            while (!S_AXI_BVALID) @(posedge clk);
            @(posedge clk);
            S_AXI_AWVALID = 0; S_AXI_WVALID = 0; S_AXI_BREADY = 0;
        end
    endtask

    // ---------------- DUT ----------------
    wire [1:0]  imap_m_axi_awid,  weight_m_axi_awid,  bias2_m_axi_awid,  omap_m_axi_awid;
    wire [31:0] imap_m_axi_awaddr, weight_m_axi_awaddr, bias2_m_axi_awaddr, omap_m_axi_awaddr;
    wire [7:0]  imap_m_axi_awlen,  weight_m_axi_awlen,  bias2_m_axi_awlen,  omap_m_axi_awlen;
    wire [2:0]  imap_m_axi_awsize, weight_m_axi_awsize, bias2_m_axi_awsize, omap_m_axi_awsize;
    wire [1:0]  imap_m_axi_awburst, weight_m_axi_awburst, bias2_m_axi_awburst, omap_m_axi_awburst;
    wire        imap_m_axi_awlock, weight_m_axi_awlock, bias2_m_axi_awlock, omap_m_axi_awlock;
    wire [3:0]  imap_m_axi_awcache, weight_m_axi_awcache, bias2_m_axi_awcache, omap_m_axi_awcache;
    wire [2:0]  imap_m_axi_awprot, weight_m_axi_awprot, bias2_m_axi_awprot, omap_m_axi_awprot;
    wire [3:0]  imap_m_axi_awqos,  weight_m_axi_awqos,  bias2_m_axi_awqos,  omap_m_axi_awqos;
    wire        imap_m_axi_awvalid, weight_m_axi_awvalid, bias2_m_axi_awvalid, omap_m_axi_awvalid;
    wire        imap_m_axi_awready, weight_m_axi_awready, bias2_m_axi_awready, omap_m_axi_awready;
    wire [63:0] imap_m_axi_wdata,  weight_m_axi_wdata,  bias2_m_axi_wdata,  omap_m_axi_wdata;
    wire [7:0]  imap_m_axi_wstrb,  weight_m_axi_wstrb,  bias2_m_axi_wstrb,  omap_m_axi_wstrb;
    wire        imap_m_axi_wlast,  weight_m_axi_wlast,  bias2_m_axi_wlast,  omap_m_axi_wlast;
    wire        imap_m_axi_wvalid, weight_m_axi_wvalid, bias2_m_axi_wvalid, omap_m_axi_wvalid;
    wire        imap_m_axi_wready, weight_m_axi_wready, bias2_m_axi_wready, omap_m_axi_wready;
    wire [1:0]  imap_m_axi_bid,    weight_m_axi_bid,    bias2_m_axi_bid,    omap_m_axi_bid;
    wire [1:0]  imap_m_axi_bresp,  weight_m_axi_bresp,  bias2_m_axi_bresp,  omap_m_axi_bresp;
    wire        imap_m_axi_bvalid, weight_m_axi_bvalid, bias2_m_axi_bvalid, omap_m_axi_bvalid;
    wire        imap_m_axi_bready, weight_m_axi_bready, bias2_m_axi_bready, omap_m_axi_bready;
    wire [1:0]  imap_m_axi_arid,   weight_m_axi_arid,   bias2_m_axi_arid,   omap_m_axi_arid;
    wire [31:0] imap_m_axi_araddr, weight_m_axi_araddr, bias2_m_axi_araddr, omap_m_axi_araddr;
    wire [7:0]  imap_m_axi_arlen,  weight_m_axi_arlen,  bias2_m_axi_arlen,  omap_m_axi_arlen;
    wire [2:0]  imap_m_axi_arsize, weight_m_axi_arsize, bias2_m_axi_arsize, omap_m_axi_arsize;
    wire [1:0]  imap_m_axi_arburst, weight_m_axi_arburst, bias2_m_axi_arburst, omap_m_axi_arburst;
    wire        imap_m_axi_arlock, weight_m_axi_arlock, bias2_m_axi_arlock, omap_m_axi_arlock;
    wire [3:0]  imap_m_axi_arcache, weight_m_axi_arcache, bias2_m_axi_arcache, omap_m_axi_arcache;
    wire [2:0]  imap_m_axi_arprot, weight_m_axi_arprot, bias2_m_axi_arprot, omap_m_axi_arprot;
    wire [3:0]  imap_m_axi_arqos,  weight_m_axi_arqos,  bias2_m_axi_arqos,  omap_m_axi_arqos;
    wire        imap_m_axi_arvalid, weight_m_axi_arvalid, bias2_m_axi_arvalid, omap_m_axi_arvalid;
    wire        imap_m_axi_arready, weight_m_axi_arready, bias2_m_axi_arready, omap_m_axi_arready;
    wire [63:0] imap_m_axi_rdata,  weight_m_axi_rdata,  bias2_m_axi_rdata,  omap_m_axi_rdata;
    wire [1:0]  imap_m_axi_rresp,  weight_m_axi_rresp,  bias2_m_axi_rresp,  omap_m_axi_rresp;
    wire        imap_m_axi_rlast,  weight_m_axi_rlast,  bias2_m_axi_rlast,  omap_m_axi_rlast;
    wire        imap_m_axi_rvalid, weight_m_axi_rvalid, bias2_m_axi_rvalid, omap_m_axi_rvalid;
    wire        imap_m_axi_rready, weight_m_axi_rready, bias2_m_axi_rready, omap_m_axi_rready;

    ai_acce_top dut (
        .S_AXI_ACLK(clk), .S_AXI_ARESETN(rstn),
        .S_AXI_AWADDR(S_AXI_AWADDR), .S_AXI_AWPROT(S_AXI_AWPROT),
        .S_AXI_AWVALID(S_AXI_AWVALID), .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA), .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID), .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP), .S_AXI_BVALID(S_AXI_BVALID), .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARADDR(S_AXI_ARADDR), .S_AXI_ARPROT(S_AXI_ARPROT),
        .S_AXI_ARVALID(S_AXI_ARVALID), .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA), .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID), .S_AXI_RREADY(S_AXI_RREADY),

        .clk(clk), .rstn(rstn),
        .imap_m_axi_aclk(clk), .imap_m_axi_aresetn(rstn),
        .weight_m_axi_aclk(clk), .weight_m_axi_aresetn(rstn),
        .bias2_m_axi_aclk(clk), .bias2_m_axi_aresetn(rstn),
        .omap_m_axi_aclk(clk), .omap_m_axi_aresetn(rstn),

        .imap_m_axi_awid(imap_m_axi_awid), .imap_m_axi_awaddr(imap_m_axi_awaddr),
        .imap_m_axi_awlen(imap_m_axi_awlen), .imap_m_axi_awsize(imap_m_axi_awsize),
        .imap_m_axi_awburst(imap_m_axi_awburst), .imap_m_axi_awlock(imap_m_axi_awlock),
        .imap_m_axi_awcache(imap_m_axi_awcache), .imap_m_axi_awprot(imap_m_axi_awprot),
        .imap_m_axi_awqos(imap_m_axi_awqos), .imap_m_axi_awvalid(imap_m_axi_awvalid),
        .imap_m_axi_awready(imap_m_axi_awready), .imap_m_axi_wdata(imap_m_axi_wdata),
        .imap_m_axi_wstrb(imap_m_axi_wstrb), .imap_m_axi_wlast(imap_m_axi_wlast),
        .imap_m_axi_wvalid(imap_m_axi_wvalid), .imap_m_axi_wready(imap_m_axi_wready),
        .imap_m_axi_bid(imap_m_axi_bid), .imap_m_axi_bresp(imap_m_axi_bresp),
        .imap_m_axi_bvalid(imap_m_axi_bvalid), .imap_m_axi_bready(imap_m_axi_bready),
        .imap_m_axi_arid(imap_m_axi_arid), .imap_m_axi_araddr(imap_m_axi_araddr),
        .imap_m_axi_arlen(imap_m_axi_arlen), .imap_m_axi_arsize(imap_m_axi_arsize),
        .imap_m_axi_arburst(imap_m_axi_arburst), .imap_m_axi_arlock(imap_m_axi_arlock),
        .imap_m_axi_arcache(imap_m_axi_arcache), .imap_m_axi_arprot(imap_m_axi_arprot),
        .imap_m_axi_arqos(imap_m_axi_arqos), .imap_m_axi_arvalid(imap_m_axi_arvalid),
        .imap_m_axi_arready(imap_m_axi_arready), .imap_m_axi_rdata(imap_m_axi_rdata),
        .imap_m_axi_rresp(imap_m_axi_rresp), .imap_m_axi_rlast(imap_m_axi_rlast),
        .imap_m_axi_rvalid(imap_m_axi_rvalid), .imap_m_axi_rready(imap_m_axi_rready),

        .weight_m_axi_awid(weight_m_axi_awid), .weight_m_axi_awaddr(weight_m_axi_awaddr),
        .weight_m_axi_awlen(weight_m_axi_awlen), .weight_m_axi_awsize(weight_m_axi_awsize),
        .weight_m_axi_awburst(weight_m_axi_awburst), .weight_m_axi_awlock(weight_m_axi_awlock),
        .weight_m_axi_awcache(weight_m_axi_awcache), .weight_m_axi_awprot(weight_m_axi_awprot),
        .weight_m_axi_awqos(weight_m_axi_awqos), .weight_m_axi_awvalid(weight_m_axi_awvalid),
        .weight_m_axi_awready(weight_m_axi_awready), .weight_m_axi_wdata(weight_m_axi_wdata),
        .weight_m_axi_wstrb(weight_m_axi_wstrb), .weight_m_axi_wlast(weight_m_axi_wlast),
        .weight_m_axi_wvalid(weight_m_axi_wvalid), .weight_m_axi_wready(weight_m_axi_wready),
        .weight_m_axi_bid(weight_m_axi_bid), .weight_m_axi_bresp(weight_m_axi_bresp),
        .weight_m_axi_bvalid(weight_m_axi_bvalid), .weight_m_axi_bready(weight_m_axi_bready),
        .weight_m_axi_arid(weight_m_axi_arid), .weight_m_axi_araddr(weight_m_axi_araddr),
        .weight_m_axi_arlen(weight_m_axi_arlen), .weight_m_axi_arsize(weight_m_axi_arsize),
        .weight_m_axi_arburst(weight_m_axi_arburst), .weight_m_axi_arlock(weight_m_axi_arlock),
        .weight_m_axi_arcache(weight_m_axi_arcache), .weight_m_axi_arprot(weight_m_axi_arprot),
        .weight_m_axi_arqos(weight_m_axi_arqos), .weight_m_axi_arvalid(weight_m_axi_arvalid),
        .weight_m_axi_arready(weight_m_axi_arready), .weight_m_axi_rdata(weight_m_axi_rdata),
        .weight_m_axi_rresp(weight_m_axi_rresp), .weight_m_axi_rlast(weight_m_axi_rlast),
        .weight_m_axi_rvalid(weight_m_axi_rvalid), .weight_m_axi_rready(weight_m_axi_rready),

        .bias2_m_axi_awid(bias2_m_axi_awid), .bias2_m_axi_awaddr(bias2_m_axi_awaddr),
        .bias2_m_axi_awlen(bias2_m_axi_awlen), .bias2_m_axi_awsize(bias2_m_axi_awsize),
        .bias2_m_axi_awburst(bias2_m_axi_awburst), .bias2_m_axi_awlock(bias2_m_axi_awlock),
        .bias2_m_axi_awcache(bias2_m_axi_awcache), .bias2_m_axi_awprot(bias2_m_axi_awprot),
        .bias2_m_axi_awqos(bias2_m_axi_awqos), .bias2_m_axi_awvalid(bias2_m_axi_awvalid),
        .bias2_m_axi_awready(bias2_m_axi_awready), .bias2_m_axi_wdata(bias2_m_axi_wdata),
        .bias2_m_axi_wstrb(bias2_m_axi_wstrb), .bias2_m_axi_wlast(bias2_m_axi_wlast),
        .bias2_m_axi_wvalid(bias2_m_axi_wvalid), .bias2_m_axi_wready(bias2_m_axi_wready),
        .bias2_m_axi_bid(bias2_m_axi_bid), .bias2_m_axi_bresp(bias2_m_axi_bresp),
        .bias2_m_axi_bvalid(bias2_m_axi_bvalid), .bias2_m_axi_bready(bias2_m_axi_bready),
        .bias2_m_axi_arid(bias2_m_axi_arid), .bias2_m_axi_araddr(bias2_m_axi_araddr),
        .bias2_m_axi_arlen(bias2_m_axi_arlen), .bias2_m_axi_arsize(bias2_m_axi_arsize),
        .bias2_m_axi_arburst(bias2_m_axi_arburst), .bias2_m_axi_arlock(bias2_m_axi_arlock),
        .bias2_m_axi_arcache(bias2_m_axi_arcache), .bias2_m_axi_arprot(bias2_m_axi_arprot),
        .bias2_m_axi_arqos(bias2_m_axi_arqos), .bias2_m_axi_arvalid(bias2_m_axi_arvalid),
        .bias2_m_axi_arready(bias2_m_axi_arready), .bias2_m_axi_rdata(bias2_m_axi_rdata),
        .bias2_m_axi_rresp(bias2_m_axi_rresp), .bias2_m_axi_rlast(bias2_m_axi_rlast),
        .bias2_m_axi_rvalid(bias2_m_axi_rvalid), .bias2_m_axi_rready(bias2_m_axi_rready),

        .omap_m_axi_awid(omap_m_axi_awid), .omap_m_axi_awaddr(omap_m_axi_awaddr),
        .omap_m_axi_awlen(omap_m_axi_awlen), .omap_m_axi_awsize(omap_m_axi_awsize),
        .omap_m_axi_awburst(omap_m_axi_awburst), .omap_m_axi_awlock(omap_m_axi_awlock),
        .omap_m_axi_awcache(omap_m_axi_awcache), .omap_m_axi_awprot(omap_m_axi_awprot),
        .omap_m_axi_awqos(omap_m_axi_awqos), .omap_m_axi_awvalid(omap_m_axi_awvalid),
        .omap_m_axi_awready(omap_m_axi_awready), .omap_m_axi_wdata(omap_m_axi_wdata),
        .omap_m_axi_wstrb(omap_m_axi_wstrb), .omap_m_axi_wlast(omap_m_axi_wlast),
        .omap_m_axi_wvalid(omap_m_axi_wvalid), .omap_m_axi_wready(omap_m_axi_wready),
        .omap_m_axi_bid(omap_m_axi_bid), .omap_m_axi_bresp(omap_m_axi_bresp),
        .omap_m_axi_bvalid(omap_m_axi_bvalid), .omap_m_axi_bready(omap_m_axi_bready),
        .omap_m_axi_arid(omap_m_axi_arid), .omap_m_axi_araddr(omap_m_axi_araddr),
        .omap_m_axi_arlen(omap_m_axi_arlen), .omap_m_axi_arsize(omap_m_axi_arsize),
        .omap_m_axi_arburst(omap_m_axi_arburst), .omap_m_axi_arlock(omap_m_axi_arlock),
        .omap_m_axi_arcache(omap_m_axi_arcache), .omap_m_axi_arprot(omap_m_axi_arprot),
        .omap_m_axi_arqos(omap_m_axi_arqos), .omap_m_axi_arvalid(omap_m_axi_arvalid),
        .omap_m_axi_arready(omap_m_axi_arready), .omap_m_axi_rdata(omap_m_axi_rdata),
        .omap_m_axi_rresp(omap_m_axi_rresp), .omap_m_axi_rlast(omap_m_axi_rlast),
        .omap_m_axi_rvalid(omap_m_axi_rvalid), .omap_m_axi_rready(omap_m_axi_rready)
    );

    // ---------------- 4×axi_ram DDR 模型 ----------------
    axi_ram #(.DATA_WIDTH(64), .ADDR_WIDTH(16), .STRB_WIDTH(8),
              .ID_WIDTH(2), .PIPELINE_OUTPUT(1), .VALID_ADDR_WIDTH(13)) u_axi_ram_imap (
        .clk(clk), .rst(~rstn),
        .s_axi_awid(imap_m_axi_awid), .s_axi_awaddr(imap_m_axi_awaddr),
        .s_axi_awlen(imap_m_axi_awlen), .s_axi_awsize(imap_m_axi_awsize),
        .s_axi_awburst(imap_m_axi_awburst), .s_axi_awlock(imap_m_axi_awlock),
        .s_axi_awcache(imap_m_axi_awcache), .s_axi_awprot(imap_m_axi_awprot),
        .s_axi_awvalid(imap_m_axi_awvalid), .s_axi_awready(imap_m_axi_awready),
        .s_axi_wdata(imap_m_axi_wdata), .s_axi_wstrb(imap_m_axi_wstrb),
        .s_axi_wlast(imap_m_axi_wlast), .s_axi_wvalid(imap_m_axi_wvalid),
        .s_axi_wready(imap_m_axi_wready),
        .s_axi_bid(imap_m_axi_bid), .s_axi_bresp(imap_m_axi_bresp),
        .s_axi_bvalid(imap_m_axi_bvalid), .s_axi_bready(imap_m_axi_bready),
        .s_axi_arid(imap_m_axi_arid), .s_axi_araddr(imap_m_axi_araddr),
        .s_axi_arlen(imap_m_axi_arlen), .s_axi_arsize(imap_m_axi_arsize),
        .s_axi_arburst(imap_m_axi_arburst), .s_axi_arlock(imap_m_axi_arlock),
        .s_axi_arcache(imap_m_axi_arcache), .s_axi_arprot(imap_m_axi_arprot),
        .s_axi_arvalid(imap_m_axi_arvalid), .s_axi_arready(imap_m_axi_arready),
        .s_axi_rid(imap_m_axi_rid), .s_axi_rdata(imap_m_axi_rdata),
        .s_axi_rresp(imap_m_axi_rresp), .s_axi_rlast(imap_m_axi_rlast),
        .s_axi_rvalid(imap_m_axi_rvalid), .s_axi_rready(imap_m_axi_rready)
    );

    axi_ram #(.DATA_WIDTH(64), .ADDR_WIDTH(16), .STRB_WIDTH(8),
              .ID_WIDTH(2), .PIPELINE_OUTPUT(1), .VALID_ADDR_WIDTH(13)) u_axi_ram_weight (
        .clk(clk), .rst(~rstn),
        .s_axi_awid(weight_m_axi_awid), .s_axi_awaddr(weight_m_axi_awaddr),
        .s_axi_awlen(weight_m_axi_awlen), .s_axi_awsize(weight_m_axi_awsize),
        .s_axi_awburst(weight_m_axi_awburst), .s_axi_awlock(weight_m_axi_awlock),
        .s_axi_awcache(weight_m_axi_awcache), .s_axi_awprot(weight_m_axi_awprot),
        .s_axi_awvalid(weight_m_axi_awvalid), .s_axi_awready(weight_m_axi_awready),
        .s_axi_wdata(weight_m_axi_wdata), .s_axi_wstrb(weight_m_axi_wstrb),
        .s_axi_wlast(weight_m_axi_wlast), .s_axi_wvalid(weight_m_axi_wvalid),
        .s_axi_wready(weight_m_axi_wready),
        .s_axi_bid(weight_m_axi_bid), .s_axi_bresp(weight_m_axi_bresp),
        .s_axi_bvalid(weight_m_axi_bvalid), .s_axi_bready(weight_m_axi_bready),
        .s_axi_arid(weight_m_axi_arid), .s_axi_araddr(weight_m_axi_araddr),
        .s_axi_arlen(weight_m_axi_arlen), .s_axi_arsize(weight_m_axi_arsize),
        .s_axi_arburst(weight_m_axi_arburst), .s_axi_arlock(weight_m_axi_arlock),
        .s_axi_arcache(weight_m_axi_arcache), .s_axi_arprot(weight_m_axi_arprot),
        .s_axi_arvalid(weight_m_axi_arvalid), .s_axi_arready(weight_m_axi_arready),
        .s_axi_rid(weight_m_axi_rid), .s_axi_rdata(weight_m_axi_rdata),
        .s_axi_rresp(weight_m_axi_rresp), .s_axi_rlast(weight_m_axi_rlast),
        .s_axi_rvalid(weight_m_axi_rvalid), .s_axi_rready(weight_m_axi_rready)
    );

    axi_ram #(.DATA_WIDTH(64), .ADDR_WIDTH(16), .STRB_WIDTH(8),
              .ID_WIDTH(2), .PIPELINE_OUTPUT(1), .VALID_ADDR_WIDTH(13)) u_axi_ram_bias2 (
        .clk(clk), .rst(~rstn),
        .s_axi_awid(bias2_m_axi_awid), .s_axi_awaddr(bias2_m_axi_awaddr),
        .s_axi_awlen(bias2_m_axi_awlen), .s_axi_awsize(bias2_m_axi_awsize),
        .s_axi_awburst(bias2_m_axi_awburst), .s_axi_awlock(bias2_m_axi_awlock),
        .s_axi_awcache(bias2_m_axi_awcache), .s_axi_awprot(bias2_m_axi_awprot),
        .s_axi_awvalid(bias2_m_axi_awvalid), .s_axi_awready(bias2_m_axi_awready),
        .s_axi_wdata(bias2_m_axi_wdata), .s_axi_wstrb(bias2_m_axi_wstrb),
        .s_axi_wlast(bias2_m_axi_wlast), .s_axi_wvalid(bias2_m_axi_wvalid),
        .s_axi_wready(bias2_m_axi_wready),
        .s_axi_bid(bias2_m_axi_bid), .s_axi_bresp(bias2_m_axi_bresp),
        .s_axi_bvalid(bias2_m_axi_bvalid), .s_axi_bready(bias2_m_axi_bready),
        .s_axi_arid(bias2_m_axi_arid), .s_axi_araddr(bias2_m_axi_araddr),
        .s_axi_arlen(bias2_m_axi_arlen), .s_axi_arsize(bias2_m_axi_arsize),
        .s_axi_arburst(bias2_m_axi_arburst), .s_axi_arlock(bias2_m_axi_arlock),
        .s_axi_arcache(bias2_m_axi_arcache), .s_axi_arprot(bias2_m_axi_arprot),
        .s_axi_arvalid(bias2_m_axi_arvalid), .s_axi_arready(bias2_m_axi_arready),
        .s_axi_rid(bias2_m_axi_rid), .s_axi_rdata(bias2_m_axi_rdata),
        .s_axi_rresp(bias2_m_axi_rresp), .s_axi_rlast(bias2_m_axi_rlast),
        .s_axi_rvalid(bias2_m_axi_rvalid), .s_axi_rready(bias2_m_axi_rready)
    );

    axi_ram #(.DATA_WIDTH(64), .ADDR_WIDTH(16), .STRB_WIDTH(8),
              .ID_WIDTH(2), .PIPELINE_OUTPUT(1), .VALID_ADDR_WIDTH(13)) u_axi_ram_omap (
        .clk(clk), .rst(~rstn),
        .s_axi_awid(omap_m_axi_awid), .s_axi_awaddr(omap_m_axi_awaddr),
        .s_axi_awlen(omap_m_axi_awlen), .s_axi_awsize(omap_m_axi_awsize),
        .s_axi_awburst(omap_m_axi_awburst), .s_axi_awlock(omap_m_axi_awlock),
        .s_axi_awcache(omap_m_axi_awcache), .s_axi_awprot(omap_m_axi_awprot),
        .s_axi_awvalid(omap_m_axi_awvalid), .s_axi_awready(omap_m_axi_awready),
        .s_axi_wdata(omap_m_axi_wdata), .s_axi_wstrb(omap_m_axi_wstrb),
        .s_axi_wlast(omap_m_axi_wlast), .s_axi_wvalid(omap_m_axi_wvalid),
        .s_axi_wready(omap_m_axi_wready),
        .s_axi_bid(omap_m_axi_bid), .s_axi_bresp(omap_m_axi_bresp),
        .s_axi_bvalid(omap_m_axi_bvalid), .s_axi_bready(omap_m_axi_bready),
        .s_axi_arid(omap_m_axi_arid), .s_axi_araddr(omap_m_axi_araddr),
        .s_axi_arlen(omap_m_axi_arlen), .s_axi_arsize(omap_m_axi_arsize),
        .s_axi_arburst(omap_m_axi_arburst), .s_axi_arlock(omap_m_axi_arlock),
        .s_axi_arcache(omap_m_axi_arcache), .s_axi_arprot(omap_m_axi_arprot),
        .s_axi_arvalid(omap_m_axi_arvalid), .s_axi_arready(omap_m_axi_arready),
        .s_axi_rid(omap_m_axi_rid), .s_axi_rdata(omap_m_axi_rdata),
        .s_axi_rresp(omap_m_axi_rresp), .s_axi_rlast(omap_m_axi_rlast),
        .s_axi_rvalid(omap_m_axi_rvalid), .s_axi_rready(omap_m_axi_rready)
    );

    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    // ---------------- 主流程 ----------------
    integer fi, fo, i, code;
    reg signed [15:0] sval;
    reg [31:0] w0, w1;  // 32位: {im16,re16} 每字两个复样本
    reg [31:0] reg29_val;
    integer done_cnt;
    integer ar_cnt, rvalid_cnt;
    reg [31:0] araddr_last;

    initial begin
        // done 脉冲计数（层次引用）
        done_cnt = 0; ar_cnt = 0; rvalid_cnt = 0;
        rstn = 0;
        S_AXI_AWADDR = 0; S_AXI_AWPROT = 0; S_AXI_AWVALID = 0;
        S_AXI_WDATA = 0; S_AXI_WSTRB = 0; S_AXI_WVALID = 0; S_AXI_BREADY = 0;
        S_AXI_ARADDR = 0; S_AXI_ARPROT = 0; S_AXI_ARVALID = 0; S_AXI_RREADY = 0;

        // 预填输入: 512 实数样本 -> 256 个 64b 字 (低32=偶样本, 高32=奇样本, 32b={im=0,re})
        fi = $fopen("D:/project_PLF/FFTAI/note/p2_scripts/sys_data/sys_in_512.txt", "r");
        if (!fi) begin $error("open sys_in fail"); $finish; end
        for (i = 0; i < NPOINT/2*SIGN_LEN; i=i+1) begin
            code = $fscanf(fi, "%d", sval); w0 = {16'h0, sval};
            code = $fscanf(fi, "%d", sval); w1 = {16'h0, sval};
            u_axi_ram_imap.mem[i] = {w1, w0};
        end
        $fclose(fi);

        #(PERIOD*10) rstn = 1;
        #(PERIOD*10);

        // ---- main.cpp 寄存器序列 ----
        axi_wr(32'h24, 32'h3);            // reg9: is_fft=1, is_int16=1
        axi_wr(32'h04, R_BASE);           // reg1: core0 R 基址
        axi_wr(32'h08, W_BASE);           // reg2: core0 W 基址
        reg29_val = (SIGN_LEN<<16) | (STAGE<<12);
        axi_wr(32'h74, reg29_val | 1);    // reg29: config=1
        #(PERIOD*10);
        axi_wr(32'h74, reg29_val);        // config=0
        #(PERIOD*10);
        axi_wr(32'h74, reg29_val | 2);    // start=1（保持，main.cpp 同款：不清零）

        // 等 ffto done（层次脉冲计数），超时 20 万周期
        i = 0;
        while (done_cnt < SIGN_LEN && i < 200000) begin
            @(posedge clk); i = i + 1;
        end
        #(PERIOD*100);

        // ---- 调试探针 ----
        $display("DBG reg9=%h reg29=%h reg1=%h reg2=%h",
            dut.u_ai_acce_instr_encoder.slv_reg9,
            dut.u_ai_acce_instr_encoder.slv_reg29,
            dut.u_ai_acce_instr_encoder.slv_reg1,
            dut.u_ai_acce_instr_encoder.slv_reg2);
        $display("DBG fft_config=%b fft_start=%b is_fft=%b is_int16=%b fft_stage=%0d sign_len=%0d",
            dut.u_ai_acce_core.fft_config, dut.u_ai_acce_core.fft_start,
            dut.u_ai_acce_core.is_fft, dut.u_ai_acce_core.is_int16,
            dut.u_ai_acce_core.fft_stage, dut.u_ai_acce_core.fft_sign_len);
        $display("DBG ffti rtx_vaild=%b burst_num=%h sign_cnt=%0d fifo_cnt=%0d",
            dut.u_ai_acce_core.FFTI_DMA[0].u_dma_ffti.rtx_vaild,
            dut.u_ai_acce_core.fft_burst_num,
            dut.u_ai_acce_core.FFTI_DMA[0].u_dma_ffti.fft_sign_cnt,
            dut.u_ai_acce_core.FFTI_DMA[0].u_dma_ffti.ffti_data_fifo_counter);
        $display("DBG rtx_act=%b rdatahask_cnt=%0d busi_vaild=%0d ffto_fifo_cnt=%0d",
            dut.u_ai_acce_core.FFTI_DMA[0].u_dma_ffti.rtx_activate,
            dut.u_ai_acce_core.FFTI_DMA[0].u_dma_ffti.r_data_ready,
            dut.u_ai_acce_core.u_fft_core.bus_i_vaild[0],
            dut.u_ai_acce_core.FFTO_DMA[0].u_dma_ffto.ffto_data_fifo_counter);
        $display("DBG ar_cnt=%0d araddr_last=%h rvalid_cnt=%0d ffti_done=%0d ffto_wvaild=%b",
            ar_cnt, araddr_last, rvalid_cnt,
            dut.u_ai_acce_core.FFTI_DMA[0].u_dma_ffti.ffti_done_pulse,
            dut.u_ai_acce_core.ffto_wvaild[0]);
        $display("DBG mem[0]=%h mem[1]=%h memW[4096]=%h", u_axi_ram_imap.mem[0],
            u_axi_ram_imap.mem[1], u_axi_ram_imap.mem[4096]);

        // ---- 回读输出: mem[4096..] 256 字 -> 512 样本 (re im) ----
        fo = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/out_512.txt", "w");
        for (i = 0; i < NPOINT/2*SIGN_LEN; i=i+1) begin
            w0 = u_axi_ram_imap.mem[i];  // 就地覆写：输出在 R 区同偏移
            $fwrite(fo, "%0d %0d %0d %0d\n",
                $signed(w0[15:0]),  $signed(w0[31:16]),
                $signed(w0[47:32]), $signed(w0[63:48]));
        end
        $fclose(fo);
        $display("TB_FFT_SYS done: done_cnt=%0d cycles=%0d", done_cnt, i);
        $finish;
    end

    // ffto done 脉冲计数
    always @(posedge clk)
        if (dut.u_ai_acce_core.FFTO_DMA[0].u_dma_ffto.ffto_done_pulse)
            done_cnt <= done_cnt + 1;

    // 趟调度时间线探针
    reg [3:0] left_stage_d;
    integer ev_a2r, ev_p2ri, ev_p2ro;
    initial begin ev_a2r=0; ev_p2ri=0; ev_p2ro=0; left_stage_d=0; end
    always @(posedge clk) begin
        if (dut.u_ai_acce_core.u_fft_core.fft_control_inst.axi2ramin_end) ev_a2r <= ev_a2r + 1;
        if (dut.u_ai_acce_core.u_fft_core.fft_control_inst.pe2ramin_end)  begin
            ev_p2ri <= ev_p2ri + 1;
            $display("[T=%0t] pe2ramin_end #%0d left_stage=%0d", $time, ev_p2ri+1,
                dut.u_ai_acce_core.u_fft_core.fft_control_inst.mdc_left_stage);
        end
        if (dut.u_ai_acce_core.u_fft_core.fft_control_inst.pe2ramout_end) begin
            ev_p2ro <= ev_p2ro + 1;
            $display("[T=%0t] pe2ramout_end #%0d left_stage=%0d out_stage=%b", $time, ev_p2ro+1,
                dut.u_ai_acce_core.u_fft_core.fft_control_inst.mdc_left_stage,
                dut.u_ai_acce_core.u_fft_core.fft_control_inst.fft_core_out_stage);
        end
        left_stage_d <= dut.u_ai_acce_core.u_fft_core.fft_control_inst.mdc_left_stage;
        if (left_stage_d != dut.u_ai_acce_core.u_fft_core.fft_control_inst.mdc_left_stage)
            $display("[T=%0t] left_stage %0d -> %0d", $time, left_stage_d,
                dut.u_ai_acce_core.u_fft_core.fft_control_inst.mdc_left_stage);
    end

    // AXI 读事务计数
    always @(posedge clk) begin
        if (imap_m_axi_arvalid && imap_m_axi_arready) begin
            ar_cnt <= ar_cnt + 1;
            araddr_last <= imap_m_axi_araddr;
        end
        if (imap_m_axi_rvalid && imap_m_axi_rready) rvalid_cnt <= rvalid_cnt + 1;
    end

    // 末趟(pass3)数据流捕获: X1/X2/W 进 ALU 的实际值
    integer p3f; reg p3_open; integer p3n;
    initial begin p3_open = 0; p3n = 0; end
    always @(posedge clk) begin
        if (ev_p2ri == 2) p3_open <= 1;
        if (p3_open && p3n < 256 && dut.u_ai_acce_core.u_fft_core.fft_in_valid[0][0]) begin
            if (p3n == 0) p3f = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/pass3_stream.txt", "w");
            $fwrite(p3f, "%0d %0d %0d %0d %0d %0d\n",
                dut.u_ai_acce_core.u_fft_core.X1r[0][0], dut.u_ai_acce_core.u_fft_core.X1i[0][0],
                dut.u_ai_acce_core.u_fft_core.X2r[0][0], dut.u_ai_acce_core.u_fft_core.X2i[0][0],
                dut.u_ai_acce_core.u_fft_core.Wr[0][0],  dut.u_ai_acce_core.u_fft_core.Wi[0][0]);
            p3n <= p3n + 1;
            if (p3n == 255) $fclose(p3f);
        end
    end



    // 趟3前 RAM IN 三bank快照（genvar 常量路径）
    integer snap_done;
    initial snap_done = 0;
    always @(posedge clk) if (ev_p2ri == 2 && !snap_done) snap_done <= 1;
    genvar gb, gl;
    generate
        for (gb = 0; gb < 3; gb = gb + 1) begin : SNAPB
            for (gl = 0; gl < 8; gl = gl + 1) begin : SNAPL
                initial begin
                    wait (snap_done);
                    repeat (20) @(posedge clk);
                    #1;
                    begin : cntblk
                        integer nz; integer a;
                        nz = 0;
                        for (a = 0; a < 64; a = a + 1)
                            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[gb].ram_in_inst.RAMIN[gl].ram_i_0.RAM[a] !== 32'h0) nz = nz + 1;
                        $display("SNAP bank=%0d lane=%0d 非零(前64)=%0d 首值=%h", gb, gl, nz,
                            dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[gb].ram_in_inst.RAMIN[gl].ram_i_0.RAM[0]);
                    end
                end
            end
        end
    endgenerate


    // 趟2回写窗口: bank0 各 lane 实际写入数据非零统计
    integer p2w; initial p2w = 0;
    always @(posedge clk) begin
        if (ev_p2ri == 1) p2w <= 1;
        if (ev_p2ri == 2) p2w <= 0;
    end
    genvar wl;
    generate
        for (wl = 0; wl < 8; wl = wl + 1) begin : WRPROBE
            integer wcnt_nz; integer wcnt_all;
            initial begin wcnt_nz = 0; wcnt_all = 0; end
            always @(posedge clk) if (p2w && dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_wr_ena[0][wl]) begin
                wcnt_all <= wcnt_all + 1;
                if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_wr_data[0][wl] !== 32'h0) wcnt_nz <= wcnt_nz + 1;
            end
            initial begin
                wait (ev_p2ri == 2);
                repeat (5) @(posedge clk);
                $display("WR bank0 lane=%0d 写入%0d次 非零%0d", wl, wcnt_all, wcnt_nz);
            end
        end
    endgenerate


    // ALU 减法支路活性: fft_out1_r[0][*] vs fft_out2_r[0][*] 非零统计(全程)
    integer o1nz, o1all, o2nz, o2all;
    initial begin o1nz=0; o1all=0; o2nz=0; o2all=0; end
    always @(posedge clk) begin
        if (dut.u_ai_acce_core.fft_out_valid[0][0]) begin
            o1all <= o1all + 1; o2all <= o2all + 1;
            if (dut.u_ai_acce_core.fft_out1_r[0][0] !== 40'h0) o1nz <= o1nz + 1;
            if (dut.u_ai_acce_core.fft_out2_r[0][0] !== 40'h0) o2nz <= o2nz + 1;
        end
    end
    final begin
        $display("ALUACT out1(减) 采样%0d 非零%0d | out2(加) 采样%0d 非零%0d", o1all, o1nz, o2all, o2nz);
    end


    // 分级活性: fft_out1/2_r[0][s] s=0..3 逐级非零统计
    integer s1nz[3:0]; integer s2nz[3:0]; integer sall[3:0];
    integer si; initial begin for (si=0;si<4;si=si+1) begin s1nz[si]=0; s2nz[si]=0; sall[si]=0; end end
    genvar ps;
    generate
        for (ps = 0; ps < 4; ps = ps + 1) begin : STGPROBE
            always @(posedge clk) if (dut.u_ai_acce_core.fft_out_valid[0][ps]) begin
                sall[ps] <= sall[ps] + 1;
                if (dut.u_ai_acce_core.fft_out1_r[0][ps] !== 40'h0) s1nz[ps] <= s1nz[ps] + 1;
                if (dut.u_ai_acce_core.fft_out2_r[0][ps] !== 40'h0) s2nz[ps] <= s2nz[ps] + 1;
            end
        end
    endgenerate
    final begin
        for (si=0;si<4;si=si+1)
            $display("STAGE %0d: valid=%0d out1非零=%0d out2非零=%0d", si, sall[si], s1nz[si], s2nz[si]);
    end


    // mdc[0] 输出与第4级开关双路对比
    integer sw0nz, sw1nz, do0nz, do1nz, swall;
    initial begin sw0nz=0; sw1nz=0; do0nz=0; do1nz=0; swall=0; end
    always @(posedge clk) begin
        if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_ena[3]) begin
            swall <= swall + 1;
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_o_0[3][15:0] !== 16'h0) sw0nz <= sw0nz + 1;
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_o_1[3][15:0] !== 16'h0) sw1nz <= sw1nz + 1;
        end
        if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.mdc_vaild) begin
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.data_o_real[0] !== 16'h0) do0nz <= do0nz + 1;
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.data_o_real[1] !== 16'h0) do1nz <= do1nz + 1;
        end
    end
    final $display("MDCOUT switch_ena=%0d sw0非零=%0d sw1非零=%0d | mdc_vaild期 do0非零=%0d do1非零=%0d", swall, sw0nz, sw1nz, do0nz, do1nz);


    // array_sort 写入拍数据检查: pe_o_vaild 时 array_sort_i 偶/奇非零率
    integer asin_e, asin_o, asall;
    initial begin asin_e=0; asin_o=0; asall=0; end
    always @(posedge clk)
        if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_ram_inst.pe_o_vaild) begin
            asall <= asall + 1;
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[2] !== 32'h0) asin_e <= asin_e + 1;
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[3] !== 32'h0) asin_o <= asin_o + 1;
        end
    final $display("ASIN pe_vaild=%0d 输入偶lane非零=%0d 奇lane非零=%0d", asall, asin_e, asin_o);


    // array_sort 全流捕获: 写入流/读出流/计数器
    integer fain, faout, vin_cnt, vout_cnt;
    initial begin vin_cnt=0; vout_cnt=0; fain=-1; faout=-1; end
    always @(posedge clk) begin
        if (done_cnt == 0 && fain == -1 && rstn) begin
            fain = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/asin.txt", "w");
            faout = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/asout.txt", "w");
        end
        if (fain != -1 && done_cnt < 1) begin
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_ram_inst.pe_o_vaild) begin
                $fwrite(fain, "%0d %h %h %h %h %h %h %h %h %0d %0d %0d %0d %0d\n", dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_cnt, dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[1], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[2], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[3], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[4], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[5], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[6], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_i[7], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.ram_in_num_o, dut.u_ai_acce_core.u_fft_core.fft_control_inst.ram_in_back_num_i_reg, dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_rd_ena[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_rd_ena[1], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_rd_ena[2]);
                vin_cnt <= vin_cnt + 1;
            end
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_ram_inst.array_sort_vaild) begin
                $fwrite(faout, "%0d %h %h %h %h %h %h %h %h\n", dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_cnt, dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_o[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_o[1], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_o[2], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_o[3], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_o[4], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_o[5], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_o[6], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_o[7]);
                vout_cnt <= vout_cnt + 1;
            end
        end
    end
    final $display("ASCAP in=%0d out=%0d", vin_cnt, vout_cnt);

    // 趟1->2 边界逐拍记录: 各级开关使能 + 第4级开关两路 + mdc 两路输出
    integer fbd; initial fbd = 0;
    always @(posedge clk) begin
        if ($time > 4000 && $time < 5700) begin
            if (fbd == 0) fbd = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/boundary.txt", "w");
            $fwrite(fbd, "%0d %b %b %h %h %h %h %h %h %b %h %h %h\n", $time,
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_ena[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_ena[3],
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_o_0[3], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_o_1[3],
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.data_o_real[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.data_o_real[1],
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_i_0[3], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.switch_i_1[3], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.dc_switch_inst[3].dc_switch_fifo_inst.switch_cnt[3],
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.data_i_real[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.data_i_real[1],
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.data_i_imag[0]);
        end else if (fbd != 0 && $time >= 5700) begin
            $fclose(fbd); fbd = -1;
        end
    end
    // valid 链气泡追踪: 读使能/读有效/mdc使能
    integer fvc; initial fvc = 0;
    always @(posedge clk) begin
        if ($time > 4200 && $time < 4900) begin
            if (fvc == 0) fvc = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/validchain.txt", "w");
            $fwrite(fvc, "%0d %b %b %b %b %b %b %b\n", $time,
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_rd_ena[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_rd_ena[1], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_rd_ena[2],
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_vaild[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_vaild[1], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_vaild[2],
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.R2MDC[0].mdc_inst.mdc_ena);
        end else if (fvc != 0 && $time >= 4900) begin
            $fclose(fvc); fvc = -1;
        end
    end
    // bank2 全量dump(趟1写回内容) at ev_p2ri==1+30拍
    integer b2d; initial b2d = 0;
    genvar bl, ba;
    generate
        for (bl = 0; bl < 8; bl = bl + 1) begin : B2DUMP
            initial begin
                wait (ev_p2ri == 1);
                repeat (30) @(posedge clk);
                #1;
                if (b2d == 0) b2d = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/bank2dump.txt", "w");
                $fwrite(b2d, "lane%0d %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\n", bl, dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[1], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[2], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[3], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[4], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[5], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[6], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[7], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[8], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[9], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[10], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[11], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[12], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[13], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[14], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[15], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[16], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[17], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[18], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[19], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[20], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[21], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[22], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[23], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[24], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[25], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[26], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[27], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[28], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[29], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[30], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[31], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[32], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[33], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[34], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[35], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[36], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[37], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[38], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[39], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[40], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[41], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[42], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[43], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[44], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[45], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[46], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[47], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[48], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[49], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[50], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[51], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[52], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[53], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[54], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[55], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[56], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[57], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[58], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[59], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[60], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[61], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[62], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[2].ram_in_inst.RAMIN[bl].ram_i_0.RAM[63]);
            end
        end
    endgenerate
    // pe2ram_cnt / flush 相位时间线
    integer fcnt; initial fcnt = 0;
    always @(posedge clk) begin
        if ($time > 3600 && $time < 4400 && dut.u_ai_acce_core.u_fft_core.fft_control_inst.pe2ramin_ena) begin
            if (fcnt == 0) fcnt = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/cntline.txt", "w");
            $fwrite(fcnt, "%0d %0d %b %b %b\n", $time, dut.u_ai_acce_core.u_fft_core.fft_control_inst.pe2ram_cnt,
                dut.u_ai_acce_core.u_fft_core.fft_control_inst.pebuff2ramin_vaild, dut.u_ai_acce_core.u_fft_core.fft_control_inst.pe2ramin_ena,
                dut.u_ai_acce_core.u_fft_core.fft_control_inst.pe2ramin_addr[0]);
        end else if (fcnt != 0 && $time >= 4400) begin
            $fclose(fcnt); fcnt = -1;
        end
    end
    // 趟1 flush: bank2 lane0 写使能+写数据+地址 逐拍
    integer fwr; initial fwr = 0;
    always @(posedge clk) begin
        if ($time > 3700 && $time < 4350) begin
            if (fwr == 0) fwr = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/wr_line.txt", "w");
            $fwrite(fwr, "%0d %b %h %0d\n", $time,
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_wr_ena[2][0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_wr_data[2][0],
                dut.u_ai_acce_core.u_fft_core.fft_control_inst.ram_in_back_addr_i_reg[0]);
        end else if (fwr != 0 && $time >= 4350) begin
            $fclose(fwr); fwr = -1;
        end
    end
    // pass1 全程 pe_o_vaild / array_sort_vaild 逐拍
    integer fpv; initial fpv = 0;
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4400) begin
            if (fpv == 0) fpv = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/pv_line.txt", "w");
            $fwrite(fpv, "%0d %b %b %0d\n", $time,
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_ram_inst.pe_o_vaild,
                dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.array_sort_ram_inst.array_sort_vaild,
                dut.u_ai_acce_core.u_fft_core.fft_control_inst.pe2ram_cnt);
        end else if (fpv != 0 && $time >= 4400) begin
            $fclose(fpv); fpv = -1;
        end
    end
    // mdc[j] 输入(RAM读)活性: mdc_real_i[j][0/1] 趟1窗口
    integer iz [0:7]; integer ii;
    initial begin for (ii=0; ii<8; ii=ii+1) iz[ii]=0; end
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4100)
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.mdc_real_i[0][0] !== 16'h0)
                iz[0] <= iz[0] + 1;
    end
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4100)
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.mdc_real_i[0][1] !== 16'h0)
                iz[1] <= iz[1] + 1;
    end
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4100)
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.mdc_real_i[1][0] !== 16'h0)
                iz[2] <= iz[2] + 1;
    end
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4100)
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.mdc_real_i[1][1] !== 16'h0)
                iz[3] <= iz[3] + 1;
    end
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4100)
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.mdc_real_i[2][0] !== 16'h0)
                iz[4] <= iz[4] + 1;
    end
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4100)
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.mdc_real_i[2][1] !== 16'h0)
                iz[5] <= iz[5] + 1;
    end
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4100)
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.mdc_real_i[3][0] !== 16'h0)
                iz[6] <= iz[6] + 1;
    end
    always @(posedge clk) begin
        if ($time > 3300 && $time < 4100)
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.mdc_array_inst.mdc_real_i[3][1] !== 16'h0)
                iz[7] <= iz[7] + 1;
    end
    final begin
        for (ii=0; ii<4; ii=ii+1)
            $display("MDcin 实例%0d: 输入路0非零=%0d 路1非零=%0d", ii, iz[ii*2], iz[ii*2+1]);
    end
    // bank0 dump(DMA输入摆放) at ev_p2ri==1+30拍(bank0尚未被趟2改写)
    integer b0d; initial b0d = 0;
    genvar bl0;
    generate
        for (bl0 = 0; bl0 < 8; bl0 = bl0 + 1) begin : B0DUMP
            initial begin
                wait (ev_p2ri == 1);
                repeat (30) @(posedge clk);
                #1;
                if (b0d == 0) b0d = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/bank0dump.txt", "w");
                $fwrite(b0d, "lane%0d %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h\n", bl0, dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[0], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[1], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[2], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[3], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[4], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[5], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[6], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[7], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[8], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[9], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[10], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[11], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[12], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[13], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[14], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[15], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[16], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[17], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[18], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[19], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[20], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[21], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[22], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[23], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[24], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[25], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[26], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[27], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[28], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[29], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[30], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[31], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[32], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[33], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[34], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[35], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[36], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[37], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[38], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[39], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[40], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[41], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[42], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[43], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[44], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[45], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[46], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[47], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[48], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[49], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[50], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[51], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[52], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[53], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[54], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[55], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[56], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[57], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[58], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[59], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[60], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[61], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[62], dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.TRIPLE_RAM_IN[0].ram_in_inst.RAMIN[bl0].ram_i_0.RAM[63]);
            end
        end
    endgenerate


    final begin
        $display("MEM0 mem[0]=%h mem[1]=%h mem[2]=%h mem[255]=%h",
            u_axi_ram_imap.mem[0], u_axi_ram_imap.mem[1], u_axi_ram_imap.mem[2], u_axi_ram_imap.mem[255]);
    end


    // 高32位样本通路活性
    integer rhi, rlo, f4, f0;
    initial begin rhi=0; rlo=0; f4=0; f0=0; end
    always @(posedge clk) begin
        if (imap_m_axi_rvalid && imap_m_axi_rready) begin
            if (imap_m_axi_rdata[63:32] !== 32'h0) rhi <= rhi + 1;
            if (imap_m_axi_rdata[31:0]  !== 32'h0) rlo <= rlo + 1;
        end
        if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_wr_ena[0][0])
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_wr_data[0][0] !== 32'h0) f0 <= f0 + 1;
        if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_wr_ena[0][4])
            if (dut.u_ai_acce_core.u_fft_core.FFT_ARRAY[0].u_fft_array.ffti_wr_data[0][4] !== 32'h0) f4 <= f4 + 1;
    end
    final $display("HI32 总线rdata高32非零=%0d 低32非零=%0d | bus_i_data lane0非零=%0d lane4非零=%0d", rhi, rlo, f0, f4);

endmodule
