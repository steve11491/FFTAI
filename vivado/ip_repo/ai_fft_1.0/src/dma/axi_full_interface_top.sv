
module axi_full_interface_top #(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Master Bus Interface M_AXI
    parameter integer C_M_AXI_BURST_LEN = 256,
    parameter integer C_M_AXI_ID_WIDTH = 1,
    parameter integer C_M_AXI_ADDR_WIDTH = 32,
    parameter integer C_M_AXI_DATA_WIDTH = 32,
    parameter integer C_M_AXI_AWUSER_WIDTH = 0,
    parameter integer C_M_AXI_ARUSER_WIDTH = 0,
    parameter integer C_M_AXI_WUSER_WIDTH = 0,
    parameter integer C_M_AXI_RUSER_WIDTH = 0,
    parameter integer C_M_AXI_BUSER_WIDTH = 0,
    parameter M_ID = 0
) (
    // Users to add ports here
    input wire init_wtx_pulse,  //init_wtx_pulse拉高时w_offset_addr有效
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] W_BASE_ADDR,
    input wire [8-1:0] w_burst_len,
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] w_offset_addr,
    output reg write_data_ready,//这个时候w_offset_addr完成握手，slave端wdata也已经ready，可以开始w_data的传输

    input wire [C_M_AXI_DATA_WIDTH-1 : 0] w_data,
    input wire w_data_valid,
    input wire write_data_tx_wlast,  //写data传输的最后一个
    output reg write_data_tx_done_pulse,  //写data传输完成pulse

    input wire init_rtx_pulse,
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] R_BASE_ADDR,
    input wire [8-1:0] r_burst_len,
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] r_offset_addr,
    input wire dma_rready,
    output reg read_addr_tx_done_pulse,  //读addr传输完成pulse

    output wire [C_M_AXI_DATA_WIDTH-1 : 0] r_data,
    output wire r_data_valid,
    output reg read_data_tx_done_pulse,  //读data传输完成pulse

    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Master Bus Interface M_AXI
    input wire m_axi_aclk,
    input wire m_axi_aresetn,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_awid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_awaddr,
    output wire [7 : 0] m_axi_awlen,
    output wire [2 : 0] m_axi_awsize,
    output wire [1 : 0] m_axi_awburst,
    output wire m_axi_awlock,
    output wire [3 : 0] m_axi_awcache,
    output wire [2 : 0] m_axi_awprot,
    output wire [3 : 0] m_axi_awqos,
    output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] m_axi_awuser,
    output wire m_axi_awvalid,
    input wire m_axi_awready,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb,
    output wire m_axi_wlast,
    output wire [C_M_AXI_WUSER_WIDTH-1 : 0] m_axi_wuser,
    output wire m_axi_wvalid,
    input wire m_axi_wready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_bid,
    input wire [1 : 0] m_axi_bresp,
    input wire [C_M_AXI_BUSER_WIDTH-1 : 0] m_axi_buser,
    input wire m_axi_bvalid,
    output wire m_axi_bready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
    output wire [7 : 0] m_axi_arlen,
    output wire [2 : 0] m_axi_arsize,
    output wire [1 : 0] m_axi_arburst,
    output wire m_axi_arlock,
    output wire [3 : 0] m_axi_arcache,
    output wire [2 : 0] m_axi_arprot,
    output wire [3 : 0] m_axi_arqos,
    output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] m_axi_aruser,
    output wire m_axi_arvalid,
    input wire m_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
    input wire [1 : 0] m_axi_rresp,
    input wire m_axi_rlast,
    input wire [C_M_AXI_RUSER_WIDTH-1 : 0] m_axi_ruser,
    input wire m_axi_rvalid,
    output wire m_axi_rready
);
    // Instantiation of Axi Bus Interface M_AXI
    axi_full_interface #(
        .C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
        .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH),
        .M_ID(M_ID)
    ) axi_full_interface_inst (
        .init_wtx_pulse(init_wtx_pulse),  //init_wtx_pulse拉高时w_offset_addr有效
        .W_BASE_ADDR(W_BASE_ADDR),
        .w_burst_len(w_burst_len),
        .w_offset_addr(w_offset_addr),
        .write_data_ready(write_data_ready),//这个时候w_offset_addr完成握手，slave端wdata也已经ready，可以开始w_data的传输
        .w_data(w_data),
        .w_data_valid(w_data_valid),
        .write_data_tx_wlast(write_data_tx_wlast),
        .write_data_tx_done_pulse(write_data_tx_done_pulse),  //写data传输完成pulse
        .init_rtx_pulse(init_rtx_pulse),
        .R_BASE_ADDR(R_BASE_ADDR),
        .r_burst_len(r_burst_len),
        .r_offset_addr(r_offset_addr),
        .dma_rready(dma_rready),
        .read_addr_tx_done_pulse(read_addr_tx_done_pulse),  //读addr传输完成pulse
        .r_data(r_data),
        .r_data_valid(r_data_valid),
        .read_data_tx_done_pulse(read_data_tx_done_pulse),  //读data传输完成pulse

        .M_AXI_ACLK(m_axi_aclk),
        .M_AXI_ARESETN(m_axi_aresetn),
        .M_AXI_AWID(m_axi_awid),
        .M_AXI_AWADDR(m_axi_awaddr),
        .M_AXI_AWLEN(m_axi_awlen),
        .M_AXI_AWSIZE(m_axi_awsize),
        .M_AXI_AWBURST(m_axi_awburst),
        .M_AXI_AWLOCK(m_axi_awlock),
        .M_AXI_AWCACHE(m_axi_awcache),
        .M_AXI_AWPROT(m_axi_awprot),
        .M_AXI_AWQOS(m_axi_awqos),
        .M_AXI_AWUSER(m_axi_awuser),
        .M_AXI_AWVALID(m_axi_awvalid),
        .M_AXI_AWREADY(m_axi_awready),
        .M_AXI_WDATA(m_axi_wdata),
        .M_AXI_WSTRB(m_axi_wstrb),
        .M_AXI_WLAST(m_axi_wlast),
        .M_AXI_WUSER(m_axi_wuser),
        .M_AXI_WVALID(m_axi_wvalid),
        .M_AXI_WREADY(m_axi_wready),
        .M_AXI_BID(m_axi_bid),
        .M_AXI_BRESP(m_axi_bresp),
        .M_AXI_BUSER(m_axi_buser),
        .M_AXI_BVALID(m_axi_bvalid),
        .M_AXI_BREADY(m_axi_bready),
        .M_AXI_ARID(m_axi_arid),
        .M_AXI_ARADDR(m_axi_araddr),
        .M_AXI_ARLEN(m_axi_arlen),
        .M_AXI_ARSIZE(m_axi_arsize),
        .M_AXI_ARBURST(m_axi_arburst),
        .M_AXI_ARLOCK(m_axi_arlock),
        .M_AXI_ARCACHE(m_axi_arcache),
        .M_AXI_ARPROT(m_axi_arprot),
        .M_AXI_ARQOS(m_axi_arqos),
        .M_AXI_ARUSER(m_axi_aruser),
        .M_AXI_ARVALID(m_axi_arvalid),
        .M_AXI_ARREADY(m_axi_arready),
        .M_AXI_RID(m_axi_rid),
        .M_AXI_RDATA(m_axi_rdata),
        .M_AXI_RRESP(m_axi_rresp),
        .M_AXI_RLAST(m_axi_rlast),
        .M_AXI_RUSER(m_axi_ruser),
        .M_AXI_RVALID(m_axi_rvalid),
        .M_AXI_RREADY(m_axi_rready)
    );

    // Add user logic here

    // User logic ends

endmodule
