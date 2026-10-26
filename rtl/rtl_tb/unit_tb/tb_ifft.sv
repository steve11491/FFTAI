//=================================================================================
// Test#7: ai_acce_top IFFT 模式 (512 点)
//
// is_ifft_mode = reg29[11] (与 fft_stage 同一寄存器, bit11)
// dma_ffti 对输入虚部取反(共轭) → FFT管线 → 输出 = conj(IFFT(input))
// 对于实信号输入, conj(IFFT(X*32)) = 32*x_norm (可直检)
//
// 输入: 频域 X[k]*32 (int16, 峰值8192@bin5), 预填DDR
// 期望输出: ≈ 32*cos(2π*5n/512) (峰值32, 512个时域样本)
//=================================================================================
module tb_ifft;

    localparam PERIOD = 10;
    localparam NPOINT = 512;
    localparam STAGE = 9;
    localparam TONE = 5;
    localparam R_BASE = 32'h3C00_0000;
    localparam W_BASE = 32'h3C80_0000;
    localparam IFFT_BIT = 11;  // reg29[11]

    reg clk, rstn;

    reg  [31:0] AWADDR;  reg [2:0] AWPROT;  reg AWVALID;
    wire        AWREADY;
    reg  [31:0] WDATA;   reg [3:0] WSTRB;   reg WVALID;
    wire        WREADY;
    wire [1:0]  BRESP;   wire BVALID;       reg BREADY;
    reg  [31:0] ARADDR;  reg [2:0] ARPROT;  reg ARVALID;
    wire        ARREADY;
    wire [31:0] RDATA;   wire [1:0] RRESP;  wire RVALID;  reg RREADY;

    task axi_wr(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            AWADDR = addr; AWPROT = 0; AWVALID = 1;
            WDATA = data;  WSTRB = 4'hF; WVALID = 1;
            BREADY = 1;
            while (!BVALID) @(posedge clk);
            @(posedge clk);
            AWVALID = 0; WVALID = 0; BREADY = 0;
        end
    endtask

    wire [1:0]  awid[3:0];  wire [31:0] awaddr[3:0];
    wire [7:0]  awlen[3:0]; wire [2:0]  awsize[3:0];
    wire [1:0]  awburst[3:0]; wire awlock[3:0];
    wire [3:0]  awcache[3:0]; wire [2:0] awprot[3:0];
    wire [3:0]  awqos[3:0];  wire awvalid[3:0]; wire awready[3:0];
    wire [63:0] wdata[3:0];  wire [7:0] wstrb[3:0];
    wire wlast[3:0]; wire wvalid[3:0]; wire wready[3:0];
    wire [1:0]  bid[3:0];   wire [1:0] bresp[3:0];
    wire bvalid[3:0]; wire bready[3:0];
    wire [1:0]  arid[3:0];  wire [31:0] araddr[3:0];
    wire [7:0]  arlen[3:0]; wire [2:0]  arsize[3:0];
    wire [1:0]  arburst[3:0]; wire arlock[3:0];
    wire [3:0]  arcache[3:0]; wire [2:0] arprot[3:0];
    wire [3:0]  arqos[3:0];  wire arvalid[3:0]; wire arready[3:0];
    wire [63:0] rdata_ch[3:0]; wire [1:0] rresp[3:0];
    wire rlast[3:0]; wire rvalid[3:0]; wire rready[3:0];

    ai_acce_top dut (
        .clk(clk), .rstn(rstn),
        .S_AXI_ACLK(clk), .S_AXI_ARESETN(rstn),
        .S_AXI_AWADDR(AWADDR), .S_AXI_AWPROT(AWPROT),
        .S_AXI_AWVALID(AWVALID), .S_AXI_AWREADY(AWREADY),
        .S_AXI_WDATA(WDATA), .S_AXI_WSTRB(WSTRB),
        .S_AXI_WVALID(WVALID), .S_AXI_WREADY(WREADY),
        .S_AXI_BRESP(BRESP), .S_AXI_BVALID(BVALID), .S_AXI_BREADY(BREADY),
        .S_AXI_ARADDR(ARADDR), .S_AXI_ARPROT(ARPROT),
        .S_AXI_ARVALID(ARVALID), .S_AXI_ARREADY(ARREADY),
        .S_AXI_RDATA(RDATA), .S_AXI_RRESP(RRESP),
        .S_AXI_RVALID(RVALID), .S_AXI_RREADY(RREADY),
        .imap_m_axi_aclk(clk), .imap_m_axi_aresetn(rstn),
        .imap_m_axi_awid(awid[0]), .imap_m_axi_awaddr(awaddr[0]),
        .imap_m_axi_awlen(awlen[0]), .imap_m_axi_awsize(awsize[0]),
        .imap_m_axi_awburst(awburst[0]), .imap_m_axi_awlock(awlock[0]),
        .imap_m_axi_awcache(awcache[0]), .imap_m_axi_awprot(awprot[0]),
        .imap_m_axi_awqos(awqos[0]), .imap_m_axi_awvalid(awvalid[0]),
        .imap_m_axi_awready(awready[0]),
        .imap_m_axi_wdata(wdata[0]), .imap_m_axi_wstrb(wstrb[0]),
        .imap_m_axi_wlast(wlast[0]), .imap_m_axi_wvalid(wvalid[0]),
        .imap_m_axi_wready(wready[0]),
        .imap_m_axi_bid(bid[0]), .imap_m_axi_bresp(bresp[0]),
        .imap_m_axi_bvalid(bvalid[0]), .imap_m_axi_bready(bready[0]),
        .imap_m_axi_arid(arid[0]), .imap_m_axi_araddr(araddr[0]),
        .imap_m_axi_arlen(arlen[0]), .imap_m_axi_arsize(arsize[0]),
        .imap_m_axi_arburst(arburst[0]), .imap_m_axi_arlock(arlock[0]),
        .imap_m_axi_arcache(arcache[0]), .imap_m_axi_arprot(arprot[0]),
        .imap_m_axi_arqos(arqos[0]), .imap_m_axi_arvalid(arvalid[0]),
        .imap_m_axi_arready(arready[0]),
        .imap_m_axi_rdata(rdata_ch[0]), .imap_m_axi_rresp(rresp[0]),
        .imap_m_axi_rlast(rlast[0]), .imap_m_axi_rvalid(rvalid[0]),
        .imap_m_axi_rready(rready[0]),
        .weight_m_axi_aclk(clk), .weight_m_axi_aresetn(rstn),
        .weight_m_axi_awid(awid[1]), .weight_m_axi_awaddr(awaddr[1]),
        .weight_m_axi_awlen(awlen[1]), .weight_m_axi_awsize(awsize[1]),
        .weight_m_axi_awburst(awburst[1]), .weight_m_axi_awlock(awlock[1]),
        .weight_m_axi_awcache(awcache[1]), .weight_m_axi_awprot(awprot[1]),
        .weight_m_axi_awqos(arqos[1]), .weight_m_axi_awvalid(awvalid[1]),
        .weight_m_axi_awready(awready[1]),
        .weight_m_axi_wdata(wdata[1]), .weight_m_axi_wstrb(wstrb[1]),
        .weight_m_axi_wlast(wlast[1]), .weight_m_axi_wvalid(wvalid[1]),
        .weight_m_axi_wready(wready[1]),
        .weight_m_axi_bid(bid[1]), .weight_m_axi_bresp(bresp[1]),
        .weight_m_axi_bvalid(bvalid[1]), .weight_m_axi_bready(bready[1]),
        .weight_m_axi_arid(arid[1]), .weight_m_axi_araddr(araddr[1]),
        .weight_m_axi_arlen(arlen[1]), .weight_m_axi_arsize(arsize[1]),
        .weight_m_axi_arburst(arburst[1]), .weight_m_axi_arlock(arlock[1]),
        .weight_m_axi_arcache(arcache[1]), .weight_m_axi_arprot(arprot[1]),
        .weight_m_axi_arqos(arqos[1]), .weight_m_axi_arvalid(arvalid[1]),
        .weight_m_axi_arready(arready[1]),
        .weight_m_axi_rdata(rdata_ch[1]), .weight_m_axi_rresp(rresp[1]),
        .weight_m_axi_rlast(rlast[1]), .weight_m_axi_rvalid(rvalid[1]),
        .weight_m_axi_rready(rready[1]),
        .bias2_m_axi_aclk(clk), .bias2_m_axi_aresetn(rstn),
        .bias2_m_axi_awid(awid[2]), .bias2_m_axi_awaddr(awaddr[2]),
        .bias2_m_axi_awlen(awlen[2]), .bias2_m_axi_awsize(awsize[2]),
        .bias2_m_axi_awburst(awburst[2]), .bias2_m_axi_awlock(awlock[2]),
        .bias2_m_axi_awcache(awcache[2]), .bias2_m_axi_awprot(awprot[2]),
        .bias2_m_axi_arqos(arqos[2]), .bias2_m_axi_awvalid(awvalid[2]),
        .bias2_m_axi_awready(awready[2]),
        .bias2_m_axi_wdata(wdata[2]), .bias2_m_axi_wstrb(wstrb[2]),
        .bias2_m_axi_wlast(wlast[2]), .bias2_m_axi_wvalid(wvalid[2]),
        .bias2_m_axi_wready(wready[2]),
        .bias2_m_axi_bid(bid[2]), .bias2_m_axi_bresp(bresp[2]),
        .bias2_m_axi_bvalid(bvalid[2]), .bias2_m_axi_bready(bready[2]),
        .bias2_m_axi_arid(arid[2]), .bias2_m_axi_araddr(araddr[2]),
        .bias2_m_axi_arlen(arlen[2]), .bias2_m_axi_arsize(arsize[2]),
        .bias2_m_axi_arburst(arburst[2]), .bias2_m_axi_arlock(arlock[2]),
        .bias2_m_axi_arcache(arcache[2]), .bias2_m_axi_arprot(arprot[2]),
        .bias2_m_axi_awqos(awqos[2]), .bias2_m_axi_arvalid(arvalid[2]),
        .bias2_m_axi_arready(arready[2]),
        .bias2_m_axi_rdata(rdata_ch[2]), .bias2_m_axi_rresp(rresp[2]),
        .bias2_m_axi_rlast(rlast[2]), .bias2_m_axi_rvalid(rvalid[2]),
        .bias2_m_axi_rready(rready[2]),
        .omap_m_axi_aclk(clk), .omap_m_axi_aresetn(rstn),
        .omap_m_axi_awid(awid[3]), .omap_m_axi_awaddr(awaddr[3]),
        .omap_m_axi_awlen(awlen[3]), .omap_m_axi_awsize(awsize[3]),
        .omap_m_axi_awburst(awburst[3]), .omap_m_axi_awlock(awlock[3]),
        .omap_m_axi_awcache(awcache[3]), .omap_m_axi_awprot(awprot[3]),
        .omap_m_axi_awqos(arqos[3]), .omap_m_axi_awvalid(awvalid[3]),
        .omap_m_axi_awready(awready[3]),
        .omap_m_axi_wdata(wdata[3]), .omap_m_axi_wstrb(wstrb[3]),
        .omap_m_axi_wlast(wlast[3]), .omap_m_axi_wvalid(wvalid[3]),
        .omap_m_axi_wready(wready[3]),
        .omap_m_axi_bid(bid[3]), .omap_m_axi_bresp(bresp[3]),
        .omap_m_axi_bvalid(bvalid[3]), .omap_m_axi_bready(bready[3]),
        .omap_m_axi_arid(arid[3]), .omap_m_axi_araddr(araddr[3]),
        .omap_m_axi_arlen(arlen[3]), .omap_m_axi_arsize(arsize[3]),
        .omap_m_axi_arburst(arburst[3]), .omap_m_axi_arlock(arlock[3]),
        .omap_m_axi_arcache(arcache[3]), .omap_m_axi_arprot(arprot[3]),
        .omap_m_axi_arqos(arqos[3]), .omap_m_axi_arvalid(arvalid[3]),
        .omap_m_axi_arready(arready[3]),
        .omap_m_axi_rdata(rdata_ch[3]), .omap_m_axi_rresp(rresp[3]),
        .omap_m_axi_rlast(rlast[3]), .omap_m_axi_rvalid(rvalid[3]),
        .omap_m_axi_rready(rready[3])
    );

    genvar ch;
    generate
        for (ch = 0; ch < 4; ch = ch + 1) begin : DDR
            axi_ram #(
                .DATA_WIDTH(64), .ADDR_WIDTH(16), .STRB_WIDTH(8),
                .ID_WIDTH(2), .PIPELINE_OUTPUT(1), .VALID_ADDR_WIDTH(13)
            ) ram (
                .clk(clk), .rst(~rstn),
                .s_axi_awid(awid[ch]), .s_axi_awaddr(awaddr[ch]),
                .s_axi_awlen(awlen[ch]), .s_axi_awsize(awsize[ch]),
                .s_axi_awburst(awburst[ch]), .s_axi_awlock(awlock[ch]),
                .s_axi_awcache(awcache[ch]), .s_axi_awprot(awprot[ch]),
                .s_axi_awvalid(awvalid[ch]), .s_axi_awready(awready[ch]),
                .s_axi_wdata(wdata[ch]), .s_axi_wstrb(wstrb[ch]),
                .s_axi_wlast(wlast[ch]), .s_axi_wvalid(wvalid[ch]),
                .s_axi_wready(wready[ch]),
                .s_axi_bid(bid[ch]), .s_axi_bresp(bresp[ch]),
                .s_axi_bvalid(bvalid[ch]), .s_axi_bready(bready[ch]),
                .s_axi_arid(arid[ch]), .s_axi_araddr(araddr[ch]),
                .s_axi_arlen(arlen[ch]), .s_axi_arsize(arsize[ch]),
                .s_axi_arburst(arburst[ch]), .s_axi_arlock(arlock[ch]),
                .s_axi_arcache(arcache[ch]), .s_axi_arprot(arprot[ch]),
                .s_axi_arvalid(arvalid[ch]), .s_axi_arready(arready[ch]),
                .s_axi_rid(bid[ch]), .s_axi_rdata(rdata_ch[ch]),
                .s_axi_rresp(rresp[ch]), .s_axi_rlast(rlast[ch]),
                .s_axi_rvalid(rvalid[ch]), .s_axi_rready(rready[ch])
            );
        end
    endgenerate

    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    integer fi, fo, i, code, done_cnt, timeout;
    reg signed [15:0] re_val, im_val;
    reg [31:0] w_lo, w_hi;
    reg [63:0] wout;
    reg [31:0] reg29_val;
    real angle, expect_val;

    always @(posedge clk)
        if (dut.u_ai_acce_core.FFTO_DMA[0].u_dma_ffto.ffto_done_pulse)
            done_cnt <= done_cnt + 1;

    initial begin
        rstn = 0; done_cnt = 0;
        AWADDR = 0; AWPROT = 0; AWVALID = 0;
        WDATA = 0; WSTRB = 0; WVALID = 0; BREADY = 0;
        ARADDR = 0; ARPROT = 0; ARVALID = 0; RREADY = 0;

        // 预填频域 IFFT 输入 (X[k]*32)
        fi = $fopen("D:/project_PLF/FFTAI/rtl/rtl_tb/unit_tb/ifft_in_512.txt", "r");
        if (!fi) begin $error("open ifft input fail"); $finish; end
        for (i = 0; i < NPOINT/2; i=i+1) begin
            code = $fscanf(fi, "%d %d", re_val, im_val);
            w_lo = {im_val[15:0], re_val[15:0]};  // {im, re}
            code = $fscanf(fi, "%d %d", re_val, im_val);
            w_hi = {im_val[15:0], re_val[15:0]};
            DDR[0].ram.mem[i] = {w_hi, w_lo};
        end
        $fclose(fi);

        #(PERIOD*10) rstn = 1;
        #(PERIOD*10);

        // 配置: is_fft + is_int16 + IFFT 模式
        axi_wr(32'h24, 32'h3);       // reg9: is_fft=1, is_int16=1
        axi_wr(32'h04, R_BASE);
        axi_wr(32'h08, W_BASE);

        // reg29: sign_len=1, stage=9, IFFT=1(bit11), config=1
        reg29_val = (1<<16) | (STAGE<<12) | (1<<IFFT_BIT);
        axi_wr(32'h74, reg29_val | 1);  // config=1
        #(PERIOD*10);
        axi_wr(32'h74, reg29_val);      // config=0
        #(PERIOD*10);
        axi_wr(32'h74, reg29_val | 2);  // start=1 (保持)

        timeout = 0;
        while (done_cnt < 1 && timeout < 500000) begin
            @(posedge clk); timeout = timeout + 1;
        end
        #(PERIOD*200);
        $display("IFFT done=%0d cycles=%0d", done_cnt, timeout);

        // 回读输出
        fo = $fopen("D:/project_PLF/FFTAI/sim/fft_reg/ifft_out.txt", "w");
        for (i = 0; i < NPOINT/2; i=i+1) begin
            wout = DDR[0].ram.mem[i];
            $fwrite(fo, "%0d %0d %0d %0d\n",
                $signed(wout[15:0]),  $signed(wout[31:16]),
                $signed(wout[47:32]), $signed(wout[63:48]));
        end
        $fclose(fo);
        $display("TB_IFFT done");
        $finish;
    end

endmodule
