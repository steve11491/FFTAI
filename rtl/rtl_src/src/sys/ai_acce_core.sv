


module ai_acce_core #(
    parameter WIDTH = 16,
    parameter GEMM_MAC_ROW_NUM = 16,
    parameter GEMM_MAC_COL_NUM = 16,
    parameter DUAL_MAC_ROW_NUM = GEMM_MAC_ROW_NUM / 2,
    parameter DUAL_MAC_COL_NUM = GEMM_MAC_COL_NUM / 2,
    parameter FFT_BUTTER_ROW_NUM = 4,
    parameter FFT_BUTTER_COL_NUM = DUAL_MAC_ROW_NUM * DUAL_MAC_COL_NUM / FFT_BUTTER_ROW_NUM,

    parameter INPUTS_NUM  = DUAL_MAC_ROW_NUM,
    parameter OUTPUT_NUM  = DUAL_MAC_ROW_NUM * 2,
    parameter STAGES_NUM  = $clog2(DUAL_MAC_ROW_NUM),
    parameter ODATA_WIDTH = WIDTH * 2 + 2 + STAGES_NUM * 2,
    parameter SEL_WIDTH   = $clog2(GEMM_MAC_ROW_NUM),

    // pe_array
    parameter MULT_DELAY = 1,
    parameter ADD_DELAY = 1,
    parameter READ_ADDR_GEN_DELAY = 3,//imap\weight\bias读地址产生逻辑的延迟（固定为3）
    parameter WRITE_ADDR_GEN_DELAY = 2,  //omap写地址产生逻辑的延迟（固定为2）
    parameter READ_ADDR_TO_DATA_OUT_DELAY = 2,  //给出读地址到数据读出的延迟
    parameter READ_DELAY_N = READ_ADDR_GEN_DELAY + READ_ADDR_TO_DATA_OUT_DELAY - 1,
    // parameter CAL_DELAY_M = $clog2(GEMM_MAC_ROW_NUM) + 2,  //计算阵列的延迟
    parameter NUM_DELAY_HEADS = 3,  // 延迟头的数量
    parameter int CAL_DELAY_STC = $clog2(GEMM_MAC_ROW_NUM) + 2,
    parameter int CAL_DELAY_DWC = 2,
    parameter int CAL_DELAY_POOL = 1,
    parameter int MAX_CAL_DELAY_M = CAL_DELAY_STC,

    parameter QUAN_DELAY_Q  = 5,
    parameter MAX_BLOCK_DIM = 256,


    parameter DIM_WIDTH = $clog2(MAX_BLOCK_DIM),
    parameter IMAP_DIM_WIDTH = DIM_WIDTH + 2,
    parameter IMAP_RAM_DEPTH = 2 ** 11,
    parameter WEIGHT_RAM_DEPTH = 2 ** 11,
    parameter BIAS_RAM_DEPTH = 2 ** 11,
    parameter BIAS2_RAM_DEPTH = 2 ** 11,
    parameter OMAP_RAM_DEPTH = 2 ** 11,
    parameter IMAP_RAM_ADDR_WIDTH = $clog2(IMAP_RAM_DEPTH),
    parameter WEIGHT_RAM_ADDR_WIDTH = $clog2(WEIGHT_RAM_DEPTH),
    parameter BIAS_RAM_ADDR_WIDTH = $clog2(BIAS_RAM_DEPTH),
    parameter BIAS2_RAM_ADDR_WIDTH = $clog2(BIAS2_RAM_DEPTH),
    parameter OMAP_RAM_ADDR_WIDTH = $clog2(OMAP_RAM_DEPTH),

    parameter MAX_STRIDE_X = 3,
    parameter MAX_STRIDE_Y = 3,
    parameter MAX_DILATION_X = 3,
    parameter MAX_DILATION_Y = 3,
    parameter MAX_WIN_R = 9,
    parameter MAX_WIN_S = 9,
    parameter STRIDE_X_WIDTH = $clog2(MAX_STRIDE_X + 1),
    parameter STRIDE_Y_WIDTH = $clog2(MAX_STRIDE_Y + 1),
    parameter DILATION_X_WIDTH = $clog2(MAX_DILATION_X + 1),
    parameter DILATION_Y_WIDTH = $clog2(MAX_DILATION_Y + 1),
    parameter WIN_R_WIDTH = $clog2(MAX_WIN_R),
    parameter WIN_S_WIDTH = $clog2(MAX_WIN_S),

    //acc
    parameter CHANNEL_NUM = GEMM_MAC_COL_NUM,
    parameter ACC_WIDTH = ODATA_WIDTH + 2,
    parameter FIFO_ACC_DEPTH = 2 ** 10,
    parameter FIFO_ACC_ADDR_WIDTH = $clog2(FIFO_ACC_DEPTH),

    //quan

    parameter QUAN_IN_WIDTH = ACC_WIDTH,  //
    parameter QUAN_OUT_WIDTH = 20,
    parameter SCALE_WIDTH = 16,
    parameter SHIFT_WIDTH = 4,
    parameter ZERO_POINT_WIDTH = 16,

    // bias2
    parameter BIAS2_WIDTH = 16,  // int16情况下的bias2位宽
    parameter BIAS2_RAM_WIDTH = 16,  //omap ram的位宽
    parameter BIAS2_SCALE_WIDTH = 16,
    parameter BIAS2_SHIFT_WIDTH = 4,


    //axi
    parameter BUS_WIDTH = 64,
    parameter BUS_ADDR_WIDTH = 32,


    // control
    parameter MAX_NUM_DIM = 256,
    parameter NUM_WIDTH = $clog2(MAX_NUM_DIM),
    parameter IMAP_WIDTH = WIDTH,
    parameter PADDING_WIDTH = 5,
    parameter WEIGHT_WIDTH = WIDTH,
    parameter BIAS_WIDTH = 32,
    parameter OMAP_WIDTH = 16,
    parameter OMAP_RAM_WIDTH = ACC_WIDTH,

    parameter AIWIH_WIDTH = 20,  // 最大宽度*高度
    parameter AIW_WIDTH   = 11,  //最大宽度
    parameter WICRS_WIDTH = 22,
    parameter WIC_WIDTH   = 11,
    parameter AOWOH_WIDTH = 20,
    parameter AOW_WIDTH   = 11,


    //FFT
    parameter FFT_STAGE_WIDTH   = 4,
    parameter FFT_SIGNLEN_WIDTH = 16,
    parameter FFT_ERROR_WIDTH   = 1,

    parameter FFT_MAX_POINT = 4096,  //don't change
    parameter FFT_CORE_COL  = 8,     //don't change
    parameter FFT_CORE_ROW  = 4,     //don't change
    parameter FFT_CORE_NUM  = 4,     //FFT_CORE_NUM <= FFT_BUTTER_COL_NUM*2/FFT_CORE_COL


    parameter C_M_AXI_BURST_LEN = 256,
    parameter C_M_AXI_ID_WIDTH = 2,
    parameter C_M_AXI_ADDR_WIDTH = BUS_ADDR_WIDTH,
    parameter C_M_AXI_DATA_WIDTH = BUS_WIDTH,
    parameter C_M_AXI_AWUSER_WIDTH = 1,
    parameter C_M_AXI_ARUSER_WIDTH = 1,
    parameter C_M_AXI_WUSER_WIDTH = 1,
    parameter C_M_AXI_RUSER_WIDTH = 1,
    parameter C_M_AXI_BUSER_WIDTH = 1
) (



    input wire imap_m_axi_aclk,
    input wire imap_m_axi_aresetn,

    output wire [C_M_AXI_ID_WIDTH-1 : 0] imap_m_axi_awid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] imap_m_axi_awaddr,
    output wire [7 : 0] imap_m_axi_awlen,
    output wire [2 : 0] imap_m_axi_awsize,
    output wire [1 : 0] imap_m_axi_awburst,
    output wire imap_m_axi_awlock,
    output wire [3 : 0] imap_m_axi_awcache,
    output wire [2 : 0] imap_m_axi_awprot,
    output wire [3 : 0] imap_m_axi_awqos,
    output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] imap_m_axi_awuser,
    output wire imap_m_axi_awvalid,
    input wire imap_m_axi_awready,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] imap_m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] imap_m_axi_wstrb,
    output wire imap_m_axi_wlast,
    output wire [C_M_AXI_WUSER_WIDTH-1 : 0] imap_m_axi_wuser,
    output wire imap_m_axi_wvalid,
    input wire imap_m_axi_wready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] imap_m_axi_bid,
    input wire [1 : 0] imap_m_axi_bresp,
    input wire [C_M_AXI_BUSER_WIDTH-1 : 0] imap_m_axi_buser,
    input wire imap_m_axi_bvalid,
    output wire imap_m_axi_bready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] imap_m_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] imap_m_axi_araddr,
    output wire [7 : 0] imap_m_axi_arlen,
    output wire [2 : 0] imap_m_axi_arsize,
    output wire [1 : 0] imap_m_axi_arburst,
    output wire imap_m_axi_arlock,
    output wire [3 : 0] imap_m_axi_arcache,
    output wire [2 : 0] imap_m_axi_arprot,
    output wire [3 : 0] imap_m_axi_arqos,
    output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] imap_m_axi_aruser,
    output wire imap_m_axi_arvalid,
    input wire imap_m_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] imap_m_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] imap_m_axi_rdata,
    input wire [1 : 0] imap_m_axi_rresp,
    input wire imap_m_axi_rlast,
    input wire [C_M_AXI_RUSER_WIDTH-1 : 0] imap_m_axi_ruser,
    input wire imap_m_axi_rvalid,
    output wire imap_m_axi_rready,




    input wire weight_m_axi_aclk,
    input wire weight_m_axi_aresetn,

    output wire [C_M_AXI_ID_WIDTH-1 : 0] weight_m_axi_awid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] weight_m_axi_awaddr,
    output wire [7 : 0] weight_m_axi_awlen,
    output wire [2 : 0] weight_m_axi_awsize,
    output wire [1 : 0] weight_m_axi_awburst,
    output wire weight_m_axi_awlock,
    output wire [3 : 0] weight_m_axi_awcache,
    output wire [2 : 0] weight_m_axi_awprot,
    output wire [3 : 0] weight_m_axi_awqos,
    output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] weight_m_axi_awuser,
    output wire weight_m_axi_awvalid,
    input wire weight_m_axi_awready,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] weight_m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] weight_m_axi_wstrb,
    output wire weight_m_axi_wlast,
    output wire [C_M_AXI_WUSER_WIDTH-1 : 0] weight_m_axi_wuser,
    output wire weight_m_axi_wvalid,
    input wire weight_m_axi_wready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] weight_m_axi_bid,
    input wire [1 : 0] weight_m_axi_bresp,
    input wire [C_M_AXI_BUSER_WIDTH-1 : 0] weight_m_axi_buser,
    input wire weight_m_axi_bvalid,
    output wire weight_m_axi_bready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] weight_m_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] weight_m_axi_araddr,
    output wire [7 : 0] weight_m_axi_arlen,
    output wire [2 : 0] weight_m_axi_arsize,
    output wire [1 : 0] weight_m_axi_arburst,
    output wire weight_m_axi_arlock,
    output wire [3 : 0] weight_m_axi_arcache,
    output wire [2 : 0] weight_m_axi_arprot,
    output wire [3 : 0] weight_m_axi_arqos,
    output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] weight_m_axi_aruser,
    output wire weight_m_axi_arvalid,
    input wire weight_m_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] weight_m_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] weight_m_axi_rdata,
    input wire [1 : 0] weight_m_axi_rresp,
    input wire weight_m_axi_rlast,
    input wire [C_M_AXI_RUSER_WIDTH-1 : 0] weight_m_axi_ruser,
    input wire weight_m_axi_rvalid,
    output wire weight_m_axi_rready,


    input wire bias2_m_axi_aclk,
    input wire bias2_m_axi_aresetn,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] bias2_m_axi_awid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_m_axi_awaddr,
    output wire [7 : 0] bias2_m_axi_awlen,
    output wire [2 : 0] bias2_m_axi_awsize,
    output wire [1 : 0] bias2_m_axi_awburst,
    output wire bias2_m_axi_awlock,
    output wire [3 : 0] bias2_m_axi_awcache,
    output wire [2 : 0] bias2_m_axi_awprot,
    output wire [3 : 0] bias2_m_axi_awqos,
    output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] bias2_m_axi_awuser,
    output wire bias2_m_axi_awvalid,
    input wire bias2_m_axi_awready,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] bias2_m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] bias2_m_axi_wstrb,
    output wire bias2_m_axi_wlast,
    output wire [C_M_AXI_WUSER_WIDTH-1 : 0] bias2_m_axi_wuser,
    output wire bias2_m_axi_wvalid,
    input wire bias2_m_axi_wready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] bias2_m_axi_bid,
    input wire [1 : 0] bias2_m_axi_bresp,
    input wire [C_M_AXI_BUSER_WIDTH-1 : 0] bias2_m_axi_buser,
    input wire bias2_m_axi_bvalid,
    output wire bias2_m_axi_bready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] bias2_m_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_m_axi_araddr,
    output wire [7 : 0] bias2_m_axi_arlen,
    output wire [2 : 0] bias2_m_axi_arsize,
    output wire [1 : 0] bias2_m_axi_arburst,
    output wire bias2_m_axi_arlock,
    output wire [3 : 0] bias2_m_axi_arcache,
    output wire [2 : 0] bias2_m_axi_arprot,
    output wire [3 : 0] bias2_m_axi_arqos,
    output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] bias2_m_axi_aruser,
    output wire bias2_m_axi_arvalid,
    input wire bias2_m_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] bias2_m_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] bias2_m_axi_rdata,
    input wire [1 : 0] bias2_m_axi_rresp,
    input wire bias2_m_axi_rlast,
    input wire [C_M_AXI_RUSER_WIDTH-1 : 0] bias2_m_axi_ruser,
    input wire bias2_m_axi_rvalid,
    output wire bias2_m_axi_rready,


    input wire omap_m_axi_aclk,
    input wire omap_m_axi_aresetn,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] omap_m_axi_awid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] omap_m_axi_awaddr,
    output wire [7 : 0] omap_m_axi_awlen,
    output wire [2 : 0] omap_m_axi_awsize,
    output wire [1 : 0] omap_m_axi_awburst,
    output wire omap_m_axi_awlock,
    output wire [3 : 0] omap_m_axi_awcache,
    output wire [2 : 0] omap_m_axi_awprot,
    output wire [3 : 0] omap_m_axi_awqos,
    output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] omap_m_axi_awuser,
    output wire omap_m_axi_awvalid,
    input wire omap_m_axi_awready,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] omap_m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] omap_m_axi_wstrb,
    output wire omap_m_axi_wlast,
    output wire [C_M_AXI_WUSER_WIDTH-1 : 0] omap_m_axi_wuser,
    output wire omap_m_axi_wvalid,
    input wire omap_m_axi_wready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] omap_m_axi_bid,
    input wire [1 : 0] omap_m_axi_bresp,
    input wire [C_M_AXI_BUSER_WIDTH-1 : 0] omap_m_axi_buser,
    input wire omap_m_axi_bvalid,
    output wire omap_m_axi_bready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] omap_m_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] omap_m_axi_araddr,
    output wire [7 : 0] omap_m_axi_arlen,
    output wire [2 : 0] omap_m_axi_arsize,
    output wire [1 : 0] omap_m_axi_arburst,
    output wire omap_m_axi_arlock,
    output wire [3 : 0] omap_m_axi_arcache,
    output wire [2 : 0] omap_m_axi_arprot,
    output wire [3 : 0] omap_m_axi_arqos,
    output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] omap_m_axi_aruser,
    output wire omap_m_axi_arvalid,
    input wire omap_m_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] omap_m_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] omap_m_axi_rdata,
    input wire [1 : 0] omap_m_axi_rresp,
    input wire omap_m_axi_rlast,
    input wire [C_M_AXI_RUSER_WIDTH-1 : 0] omap_m_axi_ruser,
    input wire omap_m_axi_rvalid,
    output wire omap_m_axi_rready,


    input wire clk,
    input wire rstn,

    input wire mat_core_start,  //1

    output wire layer_done,
    output wire is_mat_core_busy,
    output wire is_mat_core_ready,

    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_W_BASE_ADDR,    //32
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_R_BASE_ADDR,    //32
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_W_BASE_ADDR,  //32
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_R_BASE_ADDR,  //32
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] omap_axi_W_BASE_ADDR,    //32
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias_axi_R_BASE_ADDR,    //32
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_W_BASE_ADDR,   //32
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_R_BASE_ADDR,   //32

    input wire       is_fft,                  //1
    input wire       is_int16,                //1
    input wire       relu_enable,             //1
    input wire       use_quan_external,       //1
    input wire       use_bias_external,       //1
    input wire       bias_mode_external,      //1
    input wire       use_bias2_add_external,
    input wire       is_pool,
    input wire       pool_type,
    input wire [1:0] conv_type,

    input wire [BIAS2_SCALE_WIDTH-1:0] bias2_scale,  //int8情况下 低8位有效，int16情况下16位有效
    input wire [BIAS2_SHIFT_WIDTH-1:0] bias2_shift,
    input wire [PADDING_WIDTH-1:0] padding_external[3:0],  //8*4

    input wire [     WIN_R_WIDTH-1:0] total_len_r,  //8
    input wire [     WIN_S_WIDTH-1:0] total_len_s,  //8
    input wire [  STRIDE_X_WIDTH-1:0] stride_x,     //8
    input wire [  STRIDE_Y_WIDTH-1:0] stride_y,     //8
    input wire [DILATION_X_WIDTH-1:0] dilation_x,   //8
    input wire [DILATION_Y_WIDTH-1:0] dilation_y,   //8

    input wire [ZERO_POINT_WIDTH-1:0] zero_point_in,   //16
    input wire [ZERO_POINT_WIDTH-1:0] zero_point_out,  //16
    input wire [     SCALE_WIDTH-1:0] scale,           //16
    input wire [     SHIFT_WIDTH-1:0] shift,           //8

    input wire [NUM_WIDTH-1:0] num_oc,  //8
    input wire [NUM_WIDTH-1:0] num_ic,  //8
    input wire [NUM_WIDTH-1:0] num_rs,  //8
    input wire [NUM_WIDTH-1:0] num_ow,  //8
    input wire [NUM_WIDTH-1:0] num_oh,  //8


    input wire [DIM_WIDTH-1:0] basic_oc,  //8
    input wire [DIM_WIDTH-1:0] basic_ic,  //8
    input wire [DIM_WIDTH-1:0] basic_rs,  //8
    input wire [DIM_WIDTH-1:0] basic_ow,  //8
    input wire [DIM_WIDTH-1:0] basic_oh,  //8


    input wire [DIM_WIDTH-1:0] remain_oc,  //8
    input wire [DIM_WIDTH-1:0] remain_ic,  //8
    input wire [DIM_WIDTH-1:0] remain_rs,  //8
    input wire [DIM_WIDTH-1:0] remain_ow,  //8
    input wire [DIM_WIDTH-1:0] remain_oh,  //8


    input wire [IMAP_DIM_WIDTH-1:0] basic_ow_sx,  //16
    input wire [IMAP_DIM_WIDTH-1:0] basic_oh_sy,  //16
    input wire [IMAP_DIM_WIDTH-1:0] basic_iw,  //16
    input wire [IMAP_DIM_WIDTH-1:0] basic_ih,  //16
    input wire [IMAP_DIM_WIDTH-1:0] remain_iw,  //16
    input wire [IMAP_DIM_WIDTH-1:0] remain_ih,  //16

    input wire [AIWIH_WIDTH-1:0] Aiwih,  //32
    input wire [AIW_WIDTH-1:0] Aiw,  //32
    input wire [WICRS_WIDTH-1:0] Wicrs,  //32
    input wire [WIC_WIDTH-1:0] Wic,  //32
    input wire [AOWOH_WIDTH-1:0] Aowoh,  //32
    input wire [AOW_WIDTH-1:0] Aow,  //32
    //****************FFT Port***************************//
    //CTL
    input fft_config,
    input fft_start,
    input is_ifft_mode,
    input [FFT_STAGE_WIDTH-1:0] fft_stage,
    input [FFT_SIGNLEN_WIDTH-1:0] fft_sign_len,

    output fft_done,
    output fft_done_intr


);


    (* mark_debug = "false"*) wire layer_done_w;
    assign layer_done_w = layer_done;

    localparam STC = 0, DWC = 1;
    // wire is_stc = (~is_pool && conv_type == STC);
    // wire is_dwc = (~is_pool && conv_type == DWC);


    reg is_stc;
    reg is_not_stc;
    reg is_dwc;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_stc <= 0;
            is_not_stc <= 0;
            is_dwc <= 0;
        end else begin
            is_stc <= ((~is_pool) && (conv_type == STC));
            is_not_stc <= ~((~is_pool) && (conv_type == STC));
            is_dwc <= ((~is_pool) && (conv_type == DWC));

        end
    end

    (* mark_debug = "false"*) reg [GEMM_MAC_COL_NUM-1:0] mat_col_enable_mask;
    (* mark_debug = "false"*) reg [GEMM_MAC_ROW_NUM-1:0] mat_row_enable_mask;
    reg [WIDTH-1:0] mat_data_in[GEMM_MAC_ROW_NUM-1:0];

    reg [ODATA_WIDTH-1:0] mat_data_out[GEMM_MAC_COL_NUM-1:0];
    (* mark_debug = "false"*) reg [GEMM_MAC_COL_NUM-1:0] mat_out_valid;

    reg [FFT_BUTTER_COL_NUM-1:0] fft_in_valid[FFT_BUTTER_ROW_NUM-1:0];
    reg [WIDTH-1:0] X2r[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [WIDTH-1:0] X2i[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [WIDTH-1:0] Wr[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [WIDTH-1:0] Wi[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [WIDTH-1:0] X1r[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [WIDTH-1:0] X1i[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [ODATA_WIDTH-1:0] fft_out1_r[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [ODATA_WIDTH-1:0] fft_out1_i[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [ODATA_WIDTH-1:0] fft_out2_r[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg [ODATA_WIDTH-1:0] fft_out2_i[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];
    reg fft_out_valid[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0];



    reg is_group_conv;
    assign is_group_conv = 0;
    (* mark_debug = "false"*) reg [GEMM_MAC_COL_NUM-1:0] mat_col_in_valid;
    (* mark_debug = "false"*) reg [SEL_WIDTH-1:0] mat_weight_in_row_sel;
    reg [WIDTH-1:0] mat_weight_in[GEMM_MAC_COL_NUM-1:0];
    logic [WIDTH-1:0] mat_weight_reg[GEMM_MAC_ROW_NUM-1:0][GEMM_MAC_COL_NUM-1:0];



    reg pe_array_start;

    reg [DIM_WIDTH*2-1:0] block_len_owh;
    reg [DIM_WIDTH-1:0] block_len_ic;
    reg [DIM_WIDTH-1:0] block_len_oc;
    reg [WIN_R_WIDTH*WIN_S_WIDTH-1:0] block_len_rs;
    reg [IMAP_DIM_WIDTH*2-1:0] block_len_iwh;
    reg [IMAP_DIM_WIDTH-1:0] block_len_iw;
    reg [IMAP_DIM_WIDTH-1:0] block_len_ih;
    reg [DIM_WIDTH-1:0] block_len_ow;
    reg [DIM_WIDTH-1:0] block_len_oh;

    reg total_rs_start;
    reg total_rs_done;

    reg use_bias_internal;

    reg bias_mode_internal;

    reg use_quan_internal;


    wire weight_pingpong;

    wire acc_pool_out_enable;
    wire is_acc_pool_first;
    wire fifo_acc_rd_en;
    wire [GEMM_MAC_COL_NUM-1:0] acc_pool_enable_mask;
    wire [IMAP_RAM_ADDR_WIDTH-1:0] imap_addr;
    wire [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_addr;
    wire [BIAS_RAM_ADDR_WIDTH-1:0] bias_addr;
    wire [BIAS2_RAM_ADDR_WIDTH-1:0] bias2_addr;
    wire [OMAP_RAM_ADDR_WIDTH-1:0] omap_addr;
    wire [GEMM_MAC_ROW_NUM-1:0] imap_ren;
    wire [GEMM_MAC_COL_NUM-1:0] weight_ren;
    wire [GEMM_MAC_COL_NUM-1:0] bias_ren;
    wire [GEMM_MAC_COL_NUM-1:0] bias2_ren;
    wire [GEMM_MAC_COL_NUM-1:0] omap_wen;
    wire imap_ric_even_odd_flag;
    wire is_pe_array_busy;




    (* mark_debug = "false"*) reg [ACC_WIDTH-1:0] acc_in[CHANNEL_NUM-1:0];
    (* mark_debug = "false"*) reg [ACC_WIDTH-1:0] c_in[CHANNEL_NUM-1:0];

    // multi_channel_acc_fifo Outputs
    wire [ACC_WIDTH-1:0] acc_pool_out[CHANNEL_NUM-1:0];
    (* mark_debug = "false"*) wire [CHANNEL_NUM-1:0] acc_pool_out_valid;


    // multi_channel_quan_relu_top Outputs
    wire [QUAN_OUT_WIDTH+4-1:0] quan_relu_out[CHANNEL_NUM-1:0];
    (* mark_debug = "false"*) wire [CHANNEL_NUM-1:0] quan_relu_out_valid;



    wire [IMAP_DIM_WIDTH-1:0] L1_block_len_iwih_border[3:0];  // 0-3 right|left|bottom|top
    (* mark_debug = "false"*) wire is_padding;


    (* mark_debug = "false"*) logic [ODATA_WIDTH/2-1:0] mat_data_out_int8[GEMM_MAC_COL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign {mat_data_out_int8[i*2+1], mat_data_out_int8[i*2]} = mat_data_out[i];
        end
    endgenerate
    (* mark_debug = "false"*) reg [8-1:0] mat_weight_in_int8[GEMM_MAC_COL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign {mat_weight_in_int8[i*2+1], mat_weight_in_int8[i*2]} = mat_weight_in[i];
        end
    endgenerate
    (* mark_debug = "false"*) wire [ACC_WIDTH/2-1:0] acc_pool_out_int8[CHANNEL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {acc_pool_out_int8[i*2+1], acc_pool_out_int8[i*2]} = acc_pool_out[i];
        end
    endgenerate

    (* mark_debug = "false"*) wire [(QUAN_OUT_WIDTH+4)/2-1:0] quan_relu_out_int8[GEMM_MAC_COL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign {quan_relu_out_int8[i*2+1], quan_relu_out_int8[i*2]} = quan_relu_out[i];
        end
    endgenerate

    weight_pingpong_regfile #(
        .WIDTH           (WIDTH),
        .GEMM_MAC_ROW_NUM(GEMM_MAC_ROW_NUM),
        .GEMM_MAC_COL_NUM(GEMM_MAC_COL_NUM),
        .SEL_WIDTH       (SEL_WIDTH)
    ) u_weight_pingpong_regfile (
        .clk                  (clk),
        .rstn                 (rstn),
        .is_int16             (is_int16),
        .pingpong             (weight_pingpong),
        .is_dwc               (is_dwc),
        .mat_col_in_valid     (mat_col_in_valid),
        .mat_weight_in_row_sel(mat_weight_in_row_sel),
        .mat_weight_in        (mat_weight_in),

        .mat_weight_reg(mat_weight_reg)
    );

    localparam CAL_DELAY_M = CAL_DELAY_STC;
    pe_array_rect_select #(
        .WIDTH             (WIDTH),
        .GEMM_MAC_ROW_NUM  (GEMM_MAC_ROW_NUM),
        .GEMM_MAC_COL_NUM  (GEMM_MAC_COL_NUM),
        .DUAL_MAC_ROW_NUM  (DUAL_MAC_ROW_NUM),
        .DUAL_MAC_COL_NUM  (DUAL_MAC_COL_NUM),
        .FFT_BUTTER_ROW_NUM(FFT_BUTTER_ROW_NUM),
        .FFT_BUTTER_COL_NUM(FFT_BUTTER_COL_NUM),
        .INPUTS_NUM        (INPUTS_NUM),
        .OUTPUT_NUM        (OUTPUT_NUM),
        .STAGES_NUM        (STAGES_NUM),
        .ODATA_WIDTH       (ODATA_WIDTH),
        .CAL_DELAY_M       (CAL_DELAY_M),
        .ZERO_POINT        (ZERO_POINT_WIDTH)
    ) u_pe_array_rect_select (
        .clk                (clk),
        .rstn               (rstn),
        .is_fft             (is_fft),
        .is_int16           (is_int16),
        .is_padding         (is_padding),
        .zero_point_in      (zero_point_in),
        .mat_col_enable_mask(mat_col_enable_mask),
        .mat_row_enable_mask(mat_row_enable_mask),
        .mat_data_in        (mat_data_in),
        .mat_weight_in      (mat_weight_reg),

        .fft_in_valid(fft_in_valid),
        .X2r         (X2r),
        .X2i         (X2i),
        .Wr          (Wr),
        .Wi          (Wi),
        .X1r         (X1r),
        .X1i         (X1i),

        .mat_data_out (mat_data_out),
        .mat_out_valid(mat_out_valid),
        .fft_out1_r   (fft_out1_r),
        .fft_out1_i   (fft_out1_i),
        .fft_out2_r   (fft_out2_r),
        .fft_out2_i   (fft_out2_i),
        .fft_out_valid(fft_out_valid)
    );


    reg  [ CHANNEL_NUM-1:0] imap_data_out_valid;
    reg  [  IMAP_WIDTH-1:0] imap_data_out       [CHANNEL_NUM-1:0];



    wire [WEIGHT_WIDTH-1:0] dwc_weight_in       [CHANNEL_NUM-1:0];
    assign dwc_weight_in = mat_weight_reg[0];

    multi_channel_acc_pool_fifo #(
        .CHANNEL_NUM        (CHANNEL_NUM),
        .ODATA_WIDTH        (ODATA_WIDTH),
        .IMAP_WIDTH         (IMAP_WIDTH),
        .WEIGHT_WIDTH       (WEIGHT_WIDTH),
        .ACC_WIDTH          (ACC_WIDTH),
        .ZERO_POINT_WIDTH   (ZERO_POINT_WIDTH),
        .FIFO_ACC_DEPTH     (FIFO_ACC_DEPTH),
        .FIFO_ACC_ADDR_WIDTH(FIFO_ACC_ADDR_WIDTH)
    ) u_multi_channel_acc_pool_fifo (
        .clk                 (clk),
        .rstn                (rstn),
        .is_int16            (is_int16),
        .is_pool             (is_pool),
        .pool_type           (pool_type),
        .conv_type           (conv_type),
        .is_padding          (is_padding),
        .zero_point_in       (zero_point_in),
        .use_bias_internal   (use_bias_internal),
        .acc_pool_out_enable (acc_pool_out_enable),
        .is_acc_pool_first   (is_acc_pool_first),
        .fifo_acc_rd_en      (fifo_acc_rd_en),
        .acc_pool_enable_mask(acc_pool_enable_mask),
        .mat_data_out_valid  (mat_out_valid),
        .mat_data_out        (mat_data_out),
        .dwc_weight_in       (dwc_weight_in),
        .imap_data_out_valid (imap_data_out_valid),
        .imap_data_out       (imap_data_out),
        .c_in                (c_in),

        .acc_pool_out(acc_pool_out),
        .out_valid   (acc_pool_out_valid)
    );

    multi_channel_quan_relu_top #(
        .CHANNEL_NUM   (CHANNEL_NUM),
        .ACC_OUT_WIDTH (ACC_WIDTH),
        .QUAN_IN_WIDTH (QUAN_IN_WIDTH),
        .QUAN_OUT_WIDTH(QUAN_OUT_WIDTH),
        .SCALE_WIDTH   (SCALE_WIDTH),
        .SHIFT_WIDTH   (SHIFT_WIDTH),
        .ZERO_POINT_WIDTH(ZERO_POINT_WIDTH)
    ) u_multi_channel_quan_relu_top (
        .clk                  (clk),
        .rstn                 (rstn),
        .is_int16             (is_int16),
        .zero_point_out       (zero_point_out),
        .quan_enable          (use_quan_internal),
        .relu_enable          (relu_enable),
        .quan_relu_enable_mask(acc_pool_out_valid),
        .in_valid             (acc_pool_out_valid),
        .acc_out              (acc_pool_out),
        .scale                (scale),
        .shift                (shift),

        .quan_relu_out      (quan_relu_out),
        .quan_relu_out_valid(quan_relu_out_valid)
    );

    //     reg   use_bias2_add                        = 0 ;
    // reg   [CHANNEL_NUM-1:0]  in_valid          = 0 ;
    // reg   [CHANNEL_NUM-1:0]  ele_add_mask      = 0 ;
    (* mark_debug = "false"*)reg  [      WIDTH-1:0] bias2_in          [CHANNEL_NUM-1:0];
    (* mark_debug = "false"*)reg  [      WIDTH-1:0] quan_in           [CHANNEL_NUM-1:0];

    // multi_channel_ele_add_top Outputs
    (* mark_debug = "false"*)wire [      WIDTH-1:0] ele_add_dout      [CHANNEL_NUM-1:0];
    (* mark_debug = "false"*)wire [CHANNEL_NUM-1:0] ele_add_out_valid;

    multi_channel_ele_add_top #(
        .CHANNEL_NUM   (CHANNEL_NUM),
        .WIDTH         (WIDTH),
        .QUAN_OUT_WIDTH(QUAN_OUT_WIDTH)
    ) u_multi_channel_ele_add_top (
        .clk          (clk),
        .rstn         (rstn),
        .is_int16     (is_int16),
        .use_bias2_add(use_bias2_add_external),
        .in_valid     (quan_relu_out_valid),
        .ele_add_mask (quan_relu_out_valid),
        .bias2_in     (bias2_in),
        .quan_in      (quan_relu_out),

        .dout     (ele_add_dout),
        .out_valid(ele_add_out_valid)
    );


    convpool_L1_control #(
        .WIDTH                      (WIDTH),
        // .C_WIDTH                    (C_WIDTH),
        .GEMM_MAC_ROW_NUM           (GEMM_MAC_ROW_NUM),
        .GEMM_MAC_COL_NUM           (GEMM_MAC_COL_NUM),
        .DUAL_MAC_ROW_NUM           (DUAL_MAC_ROW_NUM),
        .DUAL_MAC_COL_NUM           (DUAL_MAC_COL_NUM),
        .FFT_BUTTER_ROW_NUM         (FFT_BUTTER_ROW_NUM),
        .FFT_BUTTER_COL_NUM         (FFT_BUTTER_COL_NUM),
        .INPUTS_NUM                 (INPUTS_NUM),
        .OUTPUT_NUM                 (OUTPUT_NUM),
        .STAGES_NUM                 (STAGES_NUM),
        .ODATA_WIDTH                (ODATA_WIDTH),
        .MULT_DELAY                 (MULT_DELAY),
        .ADD_DELAY                  (ADD_DELAY),
        .READ_ADDR_GEN_DELAY        (READ_ADDR_GEN_DELAY),
        .WRITE_ADDR_GEN_DELAY       (WRITE_ADDR_GEN_DELAY),
        .READ_ADDR_TO_DATA_OUT_DELAY(READ_ADDR_TO_DATA_OUT_DELAY),
        .READ_DELAY_N               (READ_DELAY_N),

        // .CAL_DELAY_M     (CAL_DELAY_M),
        .NUM_DELAY_HEADS (NUM_DELAY_HEADS),
        .CAL_DELAY_STC   (CAL_DELAY_STC),
        .CAL_DELAY_DWC   (CAL_DELAY_DWC),
        .CAL_DELAY_POOL  (CAL_DELAY_POOL),
        .MAX_CAL_DELAY_M (MAX_CAL_DELAY_M),
        .QUAN_DELAY_Q    (QUAN_DELAY_Q),
        .MAX_BLOCK_DIM   (MAX_BLOCK_DIM),
        .SEL_WIDTH       (SEL_WIDTH),
        .DIM_WIDTH       (DIM_WIDTH),
        .IMAP_DIM_WIDTH  (IMAP_DIM_WIDTH),
        .IMAP_RAM_DEPTH  (IMAP_RAM_DEPTH),
        .WEIGHT_RAM_DEPTH(WEIGHT_RAM_DEPTH),
        .BIAS_RAM_DEPTH  (BIAS_RAM_DEPTH),
        .BIAS2_RAM_DEPTH (BIAS2_RAM_DEPTH),

        .OMAP_RAM_DEPTH       (OMAP_RAM_DEPTH),
        .IMAP_RAM_ADDR_WIDTH  (IMAP_RAM_ADDR_WIDTH),
        .WEIGHT_RAM_ADDR_WIDTH(WEIGHT_RAM_ADDR_WIDTH),
        .BIAS_RAM_ADDR_WIDTH  (BIAS_RAM_ADDR_WIDTH),
        .BIAS2_RAM_ADDR_WIDTH (BIAS2_RAM_ADDR_WIDTH),
        .OMAP_RAM_ADDR_WIDTH  (OMAP_RAM_ADDR_WIDTH),
        .MAX_STRIDE_X         (MAX_STRIDE_X),
        .MAX_STRIDE_Y         (MAX_STRIDE_Y),
        .MAX_DILATION_X       (MAX_DILATION_X),
        .MAX_DILATION_Y       (MAX_DILATION_Y),
        .MAX_WIN_R            (MAX_WIN_R),
        .MAX_WIN_S            (MAX_WIN_S),
        .STRIDE_X_WIDTH       (STRIDE_X_WIDTH),
        .STRIDE_Y_WIDTH       (STRIDE_Y_WIDTH),
        .DILATION_X_WIDTH     (DILATION_X_WIDTH),
        .DILATION_Y_WIDTH     (DILATION_Y_WIDTH),
        .WIN_R_WIDTH          (WIN_R_WIDTH),
        .WIN_S_WIDTH          (WIN_S_WIDTH)
    ) u_convpool_L1_control (
        .clk                     (clk),
        .rstn                    (rstn),
        .is_int16                (is_int16),
        .start                   (pe_array_start),
        .is_pool                 (is_pool),
        .pool_type               (pool_type),
        .conv_type               (conv_type),
        .block_len_owh           (block_len_owh),
        .block_len_ic            (block_len_ic),
        .block_len_oc            (block_len_oc),
        .block_len_rs            (block_len_rs),
        .block_len_iwh           (block_len_iwh),
        .block_len_iw            (block_len_iw),
        .block_len_ih            (block_len_ih),
        .block_len_ow            (block_len_ow),
        .block_len_oh            (block_len_oh),
        .total_len_r             (total_len_r),
        .total_len_s             (total_len_s),
        .total_rs_start          (total_rs_start),
        .total_rs_done           (total_rs_done),
        .stride_x                (stride_x),
        .stride_y                (stride_y),
        .dilation_x              (dilation_x),
        .dilation_y              (dilation_y),
        .use_bias_internal       (use_bias_internal),
        .bias_mode_internal      (bias_mode_internal),
        .use_quan                (use_quan_internal),
        .use_bias2_add           (use_bias2_add_external),
        .L1_block_len_iwih_border(L1_block_len_iwih_border),
        .is_padding              (is_padding),

        .weight_pingpong      (weight_pingpong),
        .mat_weight_in_row_sel(mat_weight_in_row_sel),
        .mat_col_enable_mask  (mat_col_enable_mask),
        .mat_row_enable_mask  (mat_row_enable_mask),

        .acc_pool_out_enable (acc_pool_out_enable),
        .is_acc_pool_first   (is_acc_pool_first),
        .fifo_acc_rd_en (fifo_acc_rd_en),
        .acc_pool_enable_mask(acc_pool_enable_mask),

        .imap_addr  (imap_addr),
        .weight_addr(weight_addr),
        .bias_addr  (bias_addr),
        .bias2_addr  (bias2_addr),
        .omap_addr  (omap_addr),
        .imap_ren   (imap_ren),
        .weight_ren (weight_ren),
        .bias_ren   (bias_ren),
        .bias2_ren   (bias2_ren),
        .omap_wen   (omap_wen),
        .imap_ric_even_odd_flag(imap_ric_even_odd_flag),

        .is_pe_array_busy(is_pe_array_busy)
    );









    // axi_full_interface_top Inputs
    reg                             imap_axi_init_wtx_pulse;
    // reg  [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_W_BASE_ADDR;
    reg  [                   8-1:0] imap_axi_w_burst_len;
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_w_offset_addr;
    reg  [C_M_AXI_DATA_WIDTH-1 : 0] imap_axi_w_data;
    reg                             imap_axi_w_data_valid;
    reg                             imap_write_data_tx_wlast;

    reg                             imap_axi_init_rtx_pulse;
    // reg  [  C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_R_BASE_ADDR;
    reg  [                   8-1:0] imap_axi_r_burst_len;
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_r_offset_addr;
    wire                            imap_axi_dma_rready;
    wire                            imap_axi_write_data_ready;
    wire                            imap_axi_write_data_tx_done_pulse;
    wire                            imap_axi_read_addr_tx_done_pulse;
    wire                            imap_axi_read_data_tx_done_pulse;
    wire [C_M_AXI_DATA_WIDTH-1 : 0] imap_axi_r_data;
    wire                            imap_axi_r_data_valid;




    // assign imap_m_axi_aclk = clk;
    // assign imap_m_axi_aresetn = rstn;
    axi_full_interface_top #(
        .C_M_AXI_BURST_LEN   (C_M_AXI_BURST_LEN),
        .C_M_AXI_ID_WIDTH    (C_M_AXI_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH  (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH  (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH (C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH (C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH (C_M_AXI_BUSER_WIDTH),
        .M_ID                (0)
    ) u_axi_full_interface_top_imap (
        .init_wtx_pulse(imap_axi_init_wtx_pulse),  //init_wtx_pulse拉高时w_offset_addr有效
        .W_BASE_ADDR(imap_axi_W_BASE_ADDR),
        .w_burst_len(imap_axi_w_burst_len),
        .w_offset_addr(imap_axi_w_offset_addr),
        .write_data_ready(imap_axi_write_data_ready),//这个时�?�w_offset_addr完戝条手，slave端wdata也已绝ready，坯以开始w_data的传�?
        .w_data(imap_axi_w_data),
        .w_data_valid(imap_axi_w_data_valid),
        .write_data_tx_wlast(imap_write_data_tx_wlast),
        .write_data_tx_done_pulse(imap_axi_write_data_tx_done_pulse),  //写data传输完戝pulse
        .init_rtx_pulse(imap_axi_init_rtx_pulse),
        .R_BASE_ADDR(imap_axi_R_BASE_ADDR),
        .r_burst_len(imap_axi_r_burst_len),
        .r_offset_addr(imap_axi_r_offset_addr),
        .dma_rready(imap_axi_dma_rready),
        .read_addr_tx_done_pulse(imap_axi_read_addr_tx_done_pulse),  //读addr传输完戝pulse
        .r_data(imap_axi_r_data),
        .r_data_valid(imap_axi_r_data_valid),
        .read_data_tx_done_pulse(imap_axi_read_data_tx_done_pulse),  //读data传输完戝pulse

        .m_axi_aclk(imap_m_axi_aclk),
        .m_axi_aresetn(imap_m_axi_aresetn),
        .m_axi_awid(imap_m_axi_awid),
        .m_axi_awaddr(imap_m_axi_awaddr),
        .m_axi_awlen(imap_m_axi_awlen),
        .m_axi_awsize(imap_m_axi_awsize),
        .m_axi_awburst(imap_m_axi_awburst),
        .m_axi_awlock(imap_m_axi_awlock),
        .m_axi_awcache(imap_m_axi_awcache),
        .m_axi_awprot(imap_m_axi_awprot),
        .m_axi_awqos(imap_m_axi_awqos),  //none
        .m_axi_awuser(imap_m_axi_awuser),  //none
        .m_axi_awvalid(imap_m_axi_awvalid),
        .m_axi_awready(imap_m_axi_awready),
        .m_axi_wdata(imap_m_axi_wdata),
        .m_axi_wstrb(imap_m_axi_wstrb),
        .m_axi_wlast(imap_m_axi_wlast),
        .m_axi_wuser(imap_m_axi_wuser),  //none
        .m_axi_wvalid(imap_m_axi_wvalid),
        .m_axi_wready(imap_m_axi_wready),
        .m_axi_bid(imap_m_axi_bid),
        .m_axi_bresp(imap_m_axi_bresp),
        .m_axi_buser(imap_m_axi_buser),  //none
        .m_axi_bvalid(imap_m_axi_bvalid),
        .m_axi_bready(imap_m_axi_bready),
        .m_axi_arid(imap_m_axi_arid),
        .m_axi_araddr(imap_m_axi_araddr),
        .m_axi_arlen(imap_m_axi_arlen),
        .m_axi_arsize(imap_m_axi_arsize),
        .m_axi_arburst(imap_m_axi_arburst),
        .m_axi_arlock(imap_m_axi_arlock),
        .m_axi_arcache(imap_m_axi_arcache),
        .m_axi_arprot(imap_m_axi_arprot),
        .m_axi_arqos(imap_m_axi_arqos),  //none
        .m_axi_aruser(imap_m_axi_aruser),  //none
        .m_axi_arvalid(imap_m_axi_arvalid),
        .m_axi_arready(imap_m_axi_arready),
        .m_axi_rid(imap_m_axi_rid),
        .m_axi_rdata(imap_m_axi_rdata),
        .m_axi_rresp(imap_m_axi_rresp),
        .m_axi_rlast(imap_m_axi_rlast),
        .m_axi_ruser(imap_m_axi_ruser),  //none
        .m_axi_rvalid(imap_m_axi_rvalid),
        .m_axi_rready(imap_m_axi_rready)
    );









    (* mark_debug = "false"*)reg  [                    3:0] use_padding_external;



    (* mark_debug = "false"*)reg                            load_imap_start;
    (* mark_debug = "false"*)reg                            is_cnt_load_imap_h_end;
    (* mark_debug = "false"*)reg                            is_cnt_load_imap_w_end;
    (* mark_debug = "false"*)reg                            is_cnt_load_imap_ic_end;

    (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_load_imap_h;
    (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_load_imap_w;
    (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_load_imap_ic;

    (* mark_debug = "false"*)reg                            imap_din_valid;
    (* mark_debug = "false"*)reg  [          BUS_WIDTH-1:0] imap_din_data;

    // dma_imap Outputs
    (* mark_debug = "false"*)wire                           init_imap_rtx_pulse;

    (* mark_debug = "false"*)wire [     BUS_ADDR_WIDTH-1:0] imap_offset_addr;
    (* mark_debug = "false"*)wire [                  8-1:0] imap_load_burst_len;
    (* mark_debug = "false"*)wire [IMAP_RAM_ADDR_WIDTH-1:0] imap_waddr;
    (* mark_debug = "false"*)wire [         IMAP_WIDTH-1:0] imap_wdata              [GEMM_MAC_ROW_NUM-1:0];
    (* mark_debug = "false"*)wire [   GEMM_MAC_ROW_NUM-1:0] imap_wen;
    (* mark_debug = "false"*)wire                           imap_wic_even_odd_flag;
    (* mark_debug = "false"*)wire                           is_load_imap_done;
    (* mark_debug = "false"*)wire                           is_load_imap_busy;

    (* mark_debug = "false"*)reg                            dma_imap_arready;
    (* mark_debug = "false"*)wire                           dma_imap_rready;





    generate
        for (genvar i = 0; i < 4; i = i + 1) begin
            assign use_padding_external[i] = padding_external[i] != 0;
        end
    endgenerate

    localparam C_WIDTH = $clog2(CHANNEL_NUM * 2);
    localparam BURST_NUM_WIDTH_IMAP = $clog2(
        CHANNEL_NUM * 2
    ) + IMAP_DIM_WIDTH - 8 - $clog2(
        BUS_WIDTH / 8
    );

    // bias需要加1

    localparam BURST_NUM_WIDTH = $clog2(CHANNEL_NUM * 2) + DIM_WIDTH - 8 - $clog2(BUS_WIDTH / 8);

    wire [      IMAP_DIM_WIDTH-1:0] imap_block_len_iw_np;
    wire [      IMAP_DIM_WIDTH-1:0] imap_block_len_ih_np;
    wire [           DIM_WIDTH-1:0] imap_block_len_ic;
    wire [    IMAP_DIM_WIDTH+1-1:0] imap_block_len_iw_add1;
    wire [(IMAP_DIM_WIDTH+1)*2-1:0] imap_block_len_iwh_add1;
    wire [                     3:0] padding_flag;
    wire [       PADDING_WIDTH-1:0] padding_internal                  [3:0];
    wire [           DIM_WIDTH-1:0] weight_block_len_ic;
    wire [           DIM_WIDTH-1:0] weight_block_len_rs;
    wire [           DIM_WIDTH-1:0] weight_block_len_oc;
    wire [         DIM_WIDTH+1-1:0] weight_block_len_ic_add1;
    wire [     (DIM_WIDTH+1)*2-1:0] weight_block_len_icrs_add1;
    wire [           DIM_WIDTH-1:0] bias_block_len_ow;
    wire [           DIM_WIDTH-1:0] bias_block_len_oh;
    wire [           DIM_WIDTH-1:0] bias_block_len_oc;
    wire [         DIM_WIDTH+1-1:0] bias_block_len_ow_add1;
    wire [     (DIM_WIDTH+1)*2-1:0] bias_block_len_owh_add1;
    wire [           DIM_WIDTH-1:0] omap_block_len_ow;
    wire [           DIM_WIDTH-1:0] omap_block_len_oh;
    wire [           DIM_WIDTH-1:0] omap_block_len_oc;
    wire [         DIM_WIDTH+1-1:0] omap_block_len_ow_add1;
    wire [     (DIM_WIDTH+1)*2-1:0] omap_block_len_owh_add1;
    wire [             C_WIDTH-1:0] imap_currc_end_c;
    wire [             C_WIDTH-1:0] imap_currc_not_end_c;
    wire [BURST_NUM_WIDTH_IMAP-1:0] imap_burst_num_end_c;
    wire [BURST_NUM_WIDTH_IMAP-1:0] imap_burst_num_not_end_c;
    wire [                     7:0] imap_remain_burst_len_end_c;
    wire [                     7:0] imap_remain_burst_len_not_end_c;
    wire [             C_WIDTH-1:0] weight_currc_end_c;
    wire [             C_WIDTH-1:0] weight_currc_not_end_c;
    wire [     BURST_NUM_WIDTH-1:0] weight_burst_num_end_c;
    wire [     BURST_NUM_WIDTH-1:0] weight_burst_num_not_end_c;
    wire [                     7:0] weight_remain_burst_len_end_c;
    wire [                     7:0] weight_remain_burst_len_not_end_c;
    wire [             C_WIDTH-1:0] bias_currc_end_c;
    wire [             C_WIDTH-1:0] bias_currc_not_end_c;
    wire [   BURST_NUM_WIDTH+1-1:0] bias_burst_num_end_c;
    wire [   BURST_NUM_WIDTH+1-1:0] bias_burst_num_not_end_c;
    wire [                     7:0] bias_remain_burst_len_end_c;
    wire [                     7:0] bias_remain_burst_len_not_end_c;
    wire [             C_WIDTH-1:0] bias2_currc_end_c;
    wire [             C_WIDTH-1:0] bias2_currc_not_end_c;
    wire [     BURST_NUM_WIDTH-1:0] bias2_burst_num_end_c;
    wire [     BURST_NUM_WIDTH-1:0] bias2_burst_num_not_end_c;
    wire [                     7:0] bias2_remain_burst_len_end_c;
    wire [                     7:0] bias2_remain_burst_len_not_end_c;
    wire [             C_WIDTH-1:0] omap_currc_end_c;
    wire [             C_WIDTH-1:0] omap_currc_not_end_c;
    wire [     BURST_NUM_WIDTH-1:0] omap_burst_num_end_c;
    wire [     BURST_NUM_WIDTH-1:0] omap_burst_num_not_end_c;
    wire [                     7:0] omap_remain_burst_len_end_c;
    wire [                     7:0] omap_remain_burst_len_not_end_c;
    wire [         DIM_WIDTH+1-1:0] basic_ow_add1;
    wire [         DIM_WIDTH+1-1:0] basic_oh_add1;
    wire [         DIM_WIDTH+1-1:0] basic_oc_add1;
    wire [         DIM_WIDTH+1-1:0] basic_ic_add1;
    wire [         DIM_WIDTH+1-1:0] basic_rs_add1;
    wire [    IMAP_DIM_WIDTH+1-1:0] basic_ow_sx_add1;
    wire [    IMAP_DIM_WIDTH+1-1:0] basic_oh_sy_add1;



    dma_imap #(
        .CHANNEL_NUM        (GEMM_MAC_ROW_NUM),
        .NUM_WIDTH          (NUM_WIDTH),
        .DIM_WIDTH          (DIM_WIDTH),
        .IMAP_DIM_WIDTH     (IMAP_DIM_WIDTH),
        .BUS_WIDTH          (BUS_WIDTH),
        .BUS_ADDR_WIDTH     (BUS_ADDR_WIDTH),
        .IMAP_WIDTH         (IMAP_WIDTH),
        .IMAP_RAM_ADDR_WIDTH(IMAP_RAM_ADDR_WIDTH),
        .PADDING_WIDTH      (PADDING_WIDTH),
        .AIWIH_WIDTH        (AIWIH_WIDTH),
        .AIW_WIDTH          (AIW_WIDTH)
    ) u_dma_imap (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16),
        .padding_flag              (padding_flag),
        .padding_external          (padding_external),
        .padding_internal          (padding_internal),
        .Aiwih                     (Aiwih),
        .Aiw                       (Aiw),
        .basic_ic_add1             (basic_ic_add1),
        .basic_ow_sx_add1          (basic_ow_sx_add1),
        .basic_oh_sy_add1          (basic_oh_sy_add1),
        .load_imap_start           (load_imap_start),
        .currc_end_c               (imap_currc_end_c),
        .currc_not_end_c           (imap_currc_not_end_c),
        .burst_num_end_c           (imap_burst_num_end_c),
        .burst_num_not_end_c       (imap_burst_num_not_end_c),
        .remain_burst_len_end_c    (imap_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(imap_remain_burst_len_not_end_c),
        .block_len_iw_np           (imap_block_len_iw_np),
        .block_len_ih_np           (imap_block_len_ih_np),
        .block_len_ic              (imap_block_len_ic),
        .block_len_iw_add1         (imap_block_len_iw_add1),
        .block_len_iwh_add1        (imap_block_len_iwh_add1),
        .cnt_load_imap_h           (cnt_load_imap_h),
        .cnt_load_imap_w           (cnt_load_imap_w),
        .cnt_load_imap_ic          (cnt_load_imap_ic),

        .din_valid(imap_din_valid),
        .din_data (imap_din_data),

        .dma_imap_arready(dma_imap_arready),
        .init_imap_rtx_pulse(init_imap_rtx_pulse),
        .imap_offset_addr   (imap_offset_addr),
        .imap_load_burst_len(imap_load_burst_len),
        .dma_imap_rready(dma_imap_rready),

        .imap_waddr       (imap_waddr),
        .imap_wdata       (imap_wdata),
        .imap_wen         (imap_wen),
        // .imap_wic_even_odd_flag(imap_wic_even_odd_flag),
        .is_load_imap_done(is_load_imap_done),
        .is_load_imap_busy(is_load_imap_busy)
    );

    // assign imap_axi_init_wtx_pulse = 0;
    // assign imap_axi_W_BASE_ADDR = 0;
    // assign imap_axi_w_burst_len = 0;
    // assign imap_axi_w_offset_addr = 0;
    // assign imap_axi_write_data_ready = 0;
    // assign imap_axi_w_data = 0;
    // assign imap_axi_w_data_valid = 0;

    // assign imap_write_data_tx_wlast = 0;

    // assign imap_axi_init_rtx_pulse = init_imap_rtx_pulse;

    // assign imap_axi_r_burst_len = imap_load_burst_len;
    // assign imap_axi_r_offset_addr = imap_offset_addr;

    assign dma_imap_arready = imap_m_axi_arready;
    // assign imap_axi_dma_rready = dma_imap_rready;

    // assign imap_din_valid = imap_axi_r_data_valid;
    // assign imap_din_data = imap_axi_r_data;




    // axi_full_interface_top Inputs
    reg                             weight_axi_init_wtx_pulse;
    // reg  [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_W_BASE_ADDR;
    reg  [                   8-1:0] weight_axi_w_burst_len;
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_w_offset_addr;
    reg  [C_M_AXI_DATA_WIDTH-1 : 0] weight_axi_w_data;
    reg                             weight_axi_w_data_valid;

    reg                             weight_write_data_tx_wlast;

    reg                             weight_axi_init_rtx_pulse;
    wire                            weight_axi_dma_rready;
    // reg  [  C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_R_BASE_ADDR;
    reg  [                   8-1:0] weight_axi_r_burst_len;
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_r_offset_addr;
    wire                            weight_axi_write_data_ready;
    wire                            weight_axi_write_data_tx_done_pulse;
    wire                            weight_axi_read_addr_tx_done_pulse;
    wire                            weight_axi_read_data_tx_done_pulse;
    wire [C_M_AXI_DATA_WIDTH-1 : 0] weight_axi_r_data;
    wire                            weight_axi_r_data_valid;



    // assign weight_m_axi_aclk = clk;
    // assign weight_m_axi_aresetn = rstn;
    axi_full_interface_top #(
        .C_M_AXI_BURST_LEN   (C_M_AXI_BURST_LEN),
        .C_M_AXI_ID_WIDTH    (C_M_AXI_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH  (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH  (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH (C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH (C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH (C_M_AXI_BUSER_WIDTH),
        .M_ID                (1)
    ) u_axi_full_interface_top_weight (
        .init_wtx_pulse(weight_axi_init_wtx_pulse),  //init_wtx_pulseæ‹‰é«˜æ—¶w_offset_addræœ‰æ•ˆ
        .W_BASE_ADDR(weight_axi_W_BASE_ADDR),
        .w_burst_len(weight_axi_w_burst_len),
        .w_offset_addr(weight_axi_w_offset_addr),
        .write_data_ready(weight_axi_write_data_ready),//è¿™ä¸ªæ—¶å?™w_offset_addrå®Œæˆ�æ�¡æ‰‹ï¼Œslaveç«¯wdataä¹Ÿå·²ç»�readyï¼Œå�¯ä»¥å¼€å§‹w_dataçš„ä¼ è¾?
        .w_data(weight_axi_w_data),
        .w_data_valid(weight_axi_w_data_valid),
        .write_data_tx_wlast(weight_write_data_tx_wlast),
        .write_data_tx_done_pulse(weight_axi_write_data_tx_done_pulse),  //å†™dataä¼ è¾“å®Œæˆ�pulse
        .init_rtx_pulse(weight_axi_init_rtx_pulse),
        .R_BASE_ADDR(weight_axi_R_BASE_ADDR),
        .r_burst_len(weight_axi_r_burst_len),
        .r_offset_addr(weight_axi_r_offset_addr),
        .dma_rready(weight_axi_dma_rready),
        .read_addr_tx_done_pulse(weight_axi_read_addr_tx_done_pulse),  //è¯»addrä¼ è¾“å®Œæˆ�pulse
        .r_data(weight_axi_r_data),
        .r_data_valid(weight_axi_r_data_valid),
        .read_data_tx_done_pulse(weight_axi_read_data_tx_done_pulse),  //è¯»dataä¼ è¾“å®Œæˆ�pulse

        .m_axi_aclk(weight_m_axi_aclk),
        .m_axi_aresetn(weight_m_axi_aresetn),
        .m_axi_awid(weight_m_axi_awid),
        .m_axi_awaddr(weight_m_axi_awaddr),
        .m_axi_awlen(weight_m_axi_awlen),
        .m_axi_awsize(weight_m_axi_awsize),
        .m_axi_awburst(weight_m_axi_awburst),
        .m_axi_awlock(weight_m_axi_awlock),
        .m_axi_awcache(weight_m_axi_awcache),
        .m_axi_awprot(weight_m_axi_awprot),
        .m_axi_awqos(weight_m_axi_awqos),  //none
        .m_axi_awuser(weight_m_axi_awuser),  //none
        .m_axi_awvalid(weight_m_axi_awvalid),
        .m_axi_awready(weight_m_axi_awready),
        .m_axi_wdata(weight_m_axi_wdata),
        .m_axi_wstrb(weight_m_axi_wstrb),
        .m_axi_wlast(weight_m_axi_wlast),
        .m_axi_wuser(weight_m_axi_wuser),  //none
        .m_axi_wvalid(weight_m_axi_wvalid),
        .m_axi_wready(weight_m_axi_wready),
        .m_axi_bid(weight_m_axi_bid),
        .m_axi_bresp(weight_m_axi_bresp),
        .m_axi_buser(weight_m_axi_buser),  //none
        .m_axi_bvalid(weight_m_axi_bvalid),
        .m_axi_bready(weight_m_axi_bready),
        .m_axi_arid(weight_m_axi_arid),
        .m_axi_araddr(weight_m_axi_araddr),
        .m_axi_arlen(weight_m_axi_arlen),
        .m_axi_arsize(weight_m_axi_arsize),
        .m_axi_arburst(weight_m_axi_arburst),
        .m_axi_arlock(weight_m_axi_arlock),
        .m_axi_arcache(weight_m_axi_arcache),
        .m_axi_arprot(weight_m_axi_arprot),
        .m_axi_arqos(weight_m_axi_arqos),  //none
        .m_axi_aruser(weight_m_axi_aruser),  //none
        .m_axi_arvalid(weight_m_axi_arvalid),
        .m_axi_arready(weight_m_axi_arready),
        .m_axi_rid(weight_m_axi_rid),
        .m_axi_rdata(weight_m_axi_rdata),
        .m_axi_rresp(weight_m_axi_rresp),
        .m_axi_rlast(weight_m_axi_rlast),
        .m_axi_ruser(weight_m_axi_ruser),  //none
        .m_axi_rvalid(weight_m_axi_rvalid),
        .m_axi_rready(weight_m_axi_rready)
    );

    // assign weight_m_axi_ruser = 0;
    // assign weight_m_axi_buser = 0;



    (* mark_debug = "false"*) reg load_weight_start;
    (* mark_debug = "false"*) reg is_cnt_load_wei_rs_end;
    (* mark_debug = "false"*) reg is_cnt_load_wei_ic_end;
    (* mark_debug = "false"*) reg is_cnt_load_wei_oc_end;
    (* mark_debug = "false"*) reg [NUM_WIDTH-1:0] cnt_load_wei_rs;
    (* mark_debug = "false"*) reg [NUM_WIDTH-1:0] cnt_load_wei_ic;
    (* mark_debug = "false"*) reg [NUM_WIDTH-1:0] cnt_load_wei_oc;
    (* mark_debug = "false"*) (* mark_debug = "false"*) reg weight_din_valid;
    (* mark_debug = "false"*) reg [BUS_WIDTH-1:0] weight_din_data;

    // dma_weight Outputs
    (* mark_debug = "false"*) wire init_weight_rtx_pulse;
    (* mark_debug = "false"*) wire [BUS_ADDR_WIDTH-1:0] weight_offset_addr;
    (* mark_debug = "false"*) wire [8-1:0] weight_load_burst_len;
    (* mark_debug = "false"*) wire [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_waddr;
    (* mark_debug = "false"*) wire [WEIGHT_WIDTH-1:0] weight_wdata[GEMM_MAC_COL_NUM-1:0];
    (* mark_debug = "false"*) wire [GEMM_MAC_COL_NUM-1:0] weight_wen;
    (* mark_debug = "false"*) wire is_load_weight_done;
    (* mark_debug = "false"*) wire is_load_weight_busy;

    (* mark_debug = "false"*) reg dma_weight_arready;
    (* mark_debug = "false"*) wire dma_weight_rready;


    wire [DIM_WIDTH-1+1:0] basic_ic_add1_true = is_dwc ? 0 : basic_ic_add1;
    dma_weight #(
        .CHANNEL_NUM          (GEMM_MAC_COL_NUM),
        .NUM_WIDTH            (NUM_WIDTH),
        .DIM_WIDTH            (DIM_WIDTH),
        .BUS_WIDTH            (BUS_WIDTH),
        .BUS_ADDR_WIDTH       (BUS_ADDR_WIDTH),
        .WEIGHT_WIDTH         (WEIGHT_WIDTH),
        .WEIGHT_RAM_ADDR_WIDTH(WEIGHT_RAM_ADDR_WIDTH),
        .WICRS_WIDTH          (WICRS_WIDTH),
        .WIC_WIDTH            (WIC_WIDTH)
    ) u_dma_weight (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16),
        .Wicrs                     (Wicrs),
        .Wic                       (Wic),
        .basic_oc_add1             (basic_oc_add1),
        .basic_ic_add1             (basic_ic_add1_true),
        .basic_rs_add1             (basic_rs_add1),
        .load_weight_start         (load_weight_start),
        .currc_end_c               (weight_currc_end_c),
        .currc_not_end_c           (weight_currc_not_end_c),
        .burst_num_end_c           (weight_burst_num_end_c),
        .burst_num_not_end_c       (weight_burst_num_not_end_c),
        .remain_burst_len_end_c    (weight_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(weight_remain_burst_len_not_end_c),
        .block_len_ic              (weight_block_len_ic),
        .block_len_rs              (weight_block_len_rs),
        .block_len_oc              (weight_block_len_oc),
        .block_len_ic_add1         (weight_block_len_ic_add1),
        .block_len_icrs_add1       (weight_block_len_icrs_add1),
        .cnt_load_wei_rs           (cnt_load_wei_rs),
        .cnt_load_wei_ic           (cnt_load_wei_ic),
        .cnt_load_wei_oc           (cnt_load_wei_oc),

        .din_valid(weight_din_valid),
        .din_data (weight_din_data),

        .dma_weight_arready(dma_weight_arready),
        .init_weight_rtx_pulse(init_weight_rtx_pulse),
        .weight_offset_addr   (weight_offset_addr),
        .weight_load_burst_len(weight_load_burst_len),
        .dma_weight_rready(dma_weight_rready),

        .weight_waddr       (weight_waddr),
        .weight_wdata       (weight_wdata),
        .weight_wen         (weight_wen),
        .is_load_weight_done(is_load_weight_done),
        .is_load_weight_busy(is_load_weight_busy)
    );

    // assign weight_axi_init_wtx_pulse = 0;
    // assign weight_axi_W_BASE_ADDR = 0;
    // assign weight_axi_w_burst_len = 0;
    // assign weight_axi_w_offset_addr = 0;
    // assign weight_axi_write_data_ready = 0;
    // assign weight_axi_w_data = 0;
    // assign weight_axi_w_data_valid = 0;
    // assign weight_write_data_tx_wlast = 0;

    // assign weight_axi_init_rtx_pulse = init_weight_rtx_pulse;

    // assign weight_axi_r_burst_len = weight_load_burst_len;
    // assign weight_axi_r_offset_addr = weight_offset_addr;

    assign dma_weight_arready = weight_m_axi_arready;
    // assign weight_axi_dma_rready = dma_weight_rready;

    // assign weight_din_valid = weight_axi_r_data_valid;
    // assign weight_din_data = weight_axi_r_data;




    //=========================================================================================================
    // axi_full_interface_top Inputs
    reg                             bias2_axi_init_wtx_pulse;
    // reg  [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_W_BASE_ADDR;
    reg  [                   8-1:0] bias2_axi_w_burst_len;
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_w_offset_addr;
    reg  [C_M_AXI_DATA_WIDTH-1 : 0] bias2_axi_w_data;
    reg                             bias2_axi_w_data_valid;

    reg                             bias2_write_data_tx_wlast;

    reg                             bias2_axi_init_rtx_pulse;
    wire                            bias2_axi_dma_rready;
    // reg  [  C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_R_BASE_ADDR;
    reg  [                   8-1:0] bias2_axi_r_burst_len;
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_r_offset_addr;
    wire                            bias2_axi_write_data_ready;
    wire                            bias2_axi_write_data_tx_done_pulse;
    wire                            bias2_axi_read_addr_tx_done_pulse;
    wire                            bias2_axi_read_data_tx_done_pulse;
    wire [C_M_AXI_DATA_WIDTH-1 : 0] bias2_axi_r_data;
    wire                            bias2_axi_r_data_valid;



    // assign bias2_m_axi_aclk = clk;
    // assign bias2_m_axi_aresetn = rstn;
    axi_full_interface_top #(
        .C_M_AXI_BURST_LEN   (C_M_AXI_BURST_LEN),
        .C_M_AXI_ID_WIDTH    (C_M_AXI_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH  (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH  (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH (C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH (C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH (C_M_AXI_BUSER_WIDTH),
        .M_ID                (2)
    ) u_axi_full_interface_top_bias2 (
        .init_wtx_pulse(bias2_axi_init_wtx_pulse),  //init_wtx_pulseæ‹‰é«˜æ—¶w_offset_addræœ‰æ•ˆ
        .W_BASE_ADDR(bias2_axi_W_BASE_ADDR),
        .w_burst_len(bias2_axi_w_burst_len),
        .w_offset_addr(bias2_axi_w_offset_addr),
        .write_data_ready(bias2_axi_write_data_ready),//è¿™ä¸ªæ—¶å?™w_offset_addrå®Œæˆ�æ�¡æ‰‹ï¼Œslaveç«¯wdataä¹Ÿå·²ç»�readyï¼Œå�¯ä»¥å¼€å§‹w_dataçš„ä¼ è¾?
        .w_data(bias2_axi_w_data),
        .w_data_valid(bias2_axi_w_data_valid),
        .write_data_tx_wlast(bias2_write_data_tx_wlast),
        .write_data_tx_done_pulse(bias2_axi_write_data_tx_done_pulse),  //å†™dataä¼ è¾“å®Œæˆ�pulse
        .init_rtx_pulse(bias2_axi_init_rtx_pulse),
        .R_BASE_ADDR(bias2_axi_R_BASE_ADDR),
        .r_burst_len(bias2_axi_r_burst_len),
        .r_offset_addr(bias2_axi_r_offset_addr),
        .dma_rready(bias2_axi_dma_rready),
        .read_addr_tx_done_pulse(bias2_axi_read_addr_tx_done_pulse),  //è¯»addrä¼ è¾“å®Œæˆ�pulse
        .r_data(bias2_axi_r_data),
        .r_data_valid(bias2_axi_r_data_valid),
        .read_data_tx_done_pulse(bias2_axi_read_data_tx_done_pulse),  //è¯»dataä¼ è¾“å®Œæˆ�pulse

        .m_axi_aclk(bias2_m_axi_aclk),
        .m_axi_aresetn(bias2_m_axi_aresetn),
        .m_axi_awid(bias2_m_axi_awid),
        .m_axi_awaddr(bias2_m_axi_awaddr),
        .m_axi_awlen(bias2_m_axi_awlen),
        .m_axi_awsize(bias2_m_axi_awsize),
        .m_axi_awburst(bias2_m_axi_awburst),
        .m_axi_awlock(bias2_m_axi_awlock),
        .m_axi_awcache(bias2_m_axi_awcache),
        .m_axi_awprot(bias2_m_axi_awprot),
        .m_axi_awqos(bias2_m_axi_awqos),  //none
        .m_axi_awuser(bias2_m_axi_awuser),  //none
        .m_axi_awvalid(bias2_m_axi_awvalid),
        .m_axi_awready(bias2_m_axi_awready),
        .m_axi_wdata(bias2_m_axi_wdata),
        .m_axi_wstrb(bias2_m_axi_wstrb),
        .m_axi_wlast(bias2_m_axi_wlast),
        .m_axi_wuser(bias2_m_axi_wuser),  //none
        .m_axi_wvalid(bias2_m_axi_wvalid),
        .m_axi_wready(bias2_m_axi_wready),
        .m_axi_bid(bias2_m_axi_bid),
        .m_axi_bresp(bias2_m_axi_bresp),
        .m_axi_buser(bias2_m_axi_buser),  //none
        .m_axi_bvalid(bias2_m_axi_bvalid),
        .m_axi_bready(bias2_m_axi_bready),
        .m_axi_arid(bias2_m_axi_arid),
        .m_axi_araddr(bias2_m_axi_araddr),
        .m_axi_arlen(bias2_m_axi_arlen),
        .m_axi_arsize(bias2_m_axi_arsize),
        .m_axi_arburst(bias2_m_axi_arburst),
        .m_axi_arlock(bias2_m_axi_arlock),
        .m_axi_arcache(bias2_m_axi_arcache),
        .m_axi_arprot(bias2_m_axi_arprot),
        .m_axi_arqos(bias2_m_axi_arqos),  //none
        .m_axi_aruser(bias2_m_axi_aruser),  //none
        .m_axi_arvalid(bias2_m_axi_arvalid),
        .m_axi_arready(bias2_m_axi_arready),
        .m_axi_rid(bias2_m_axi_rid),
        .m_axi_rdata(bias2_m_axi_rdata),
        .m_axi_rresp(bias2_m_axi_rresp),
        .m_axi_rlast(bias2_m_axi_rlast),
        .m_axi_ruser(bias2_m_axi_ruser),  //none
        .m_axi_rvalid(bias2_m_axi_rvalid),
        .m_axi_rready(bias2_m_axi_rready)
    );

    // assign bias2_m_axi_ruser = 0;
    // assign bias2_m_axi_buser = 0;





    wire load_bias2_start;


    (* mark_debug = "false"*) reg [NUM_WIDTH-1:0] cnt_load_bias_h;
    (* mark_debug = "false"*) reg [NUM_WIDTH-1:0] cnt_load_bias_w;
    (* mark_debug = "false"*) reg [NUM_WIDTH-1:0] cnt_load_bias_oc;
    (* mark_debug = "false"*) wire dma_bias2_arready;  //准备接收地址
    (* mark_debug = "false"*) wire init_bias2_rtx_pulse;  //开始传输地址
    reg [BUS_ADDR_WIDTH-1:0] bias2_offset_addr;
    wire [8-1:0] bias2_load_burst_len;
    (* mark_debug = "false"*) reg dma_bias2_rready;

    (* mark_debug = "false"*) wire bias2_din_valid;
    (* mark_debug = "false"*)wire [BUS_WIDTH-1:0] bias2_din_data;  //din_valid为高时，din有效

    reg [BIAS2_RAM_ADDR_WIDTH-1:0] bias2_waddr;
    wire [IMAP_WIDTH-1:0] bias2_wdata[CHANNEL_NUM-1:0];
    reg [CHANNEL_NUM-1:0] bias2_wen;
    reg is_load_bias2_done;
    reg is_load_bias2_busy;

    dma_bias2 #(
        .CHANNEL_NUM         (CHANNEL_NUM),
        .NUM_WIDTH           (NUM_WIDTH),
        .DIM_WIDTH           (DIM_WIDTH),
        .BUS_WIDTH           (BUS_WIDTH),
        .BUS_ADDR_WIDTH      (BUS_ADDR_WIDTH),
        .BIAS2_WIDTH         (BIAS2_WIDTH),
        .BIAS2_RAM_WIDTH     (BIAS2_RAM_WIDTH),
        .BIAS2_RAM_ADDR_WIDTH(BIAS2_RAM_ADDR_WIDTH),
        .AOWOH_WIDTH         (AOWOH_WIDTH),
        .AOW_WIDTH           (AOW_WIDTH),
        .C_WIDTH             (C_WIDTH),
        .BURST_NUM_WIDTH     (BURST_NUM_WIDTH),
        .BIAS2_SCALE_WIDTH   (BIAS2_SCALE_WIDTH),
        .BIAS2_SHIFT_WIDTH   (BIAS2_SHIFT_WIDTH)
    ) u_dma_bias2 (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16),
        .scale                     (bias2_scale),
        .shift                     (bias2_shift),
        .Aowoh                     (Aowoh),
        .Aow                       (Aow),
        .basic_oc_add1             (basic_oc_add1),
        .basic_ow_add1             (basic_ow_add1),
        .basic_oh_add1             (basic_oh_add1),
        .load_bias2_start          (load_bias2_start),
        .currc_end_c               (bias2_currc_end_c),
        .currc_not_end_c           (bias2_currc_not_end_c),
        .burst_num_end_c           (bias2_burst_num_end_c),
        .burst_num_not_end_c       (bias2_burst_num_not_end_c),
        .remain_burst_len_end_c    (bias2_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(bias2_remain_burst_len_not_end_c),
        .block_len_ow              (bias_block_len_ow),
        .block_len_oh              (bias_block_len_oh),
        .block_len_oc              (bias_block_len_oc),
        .block_len_ow_add1         (bias_block_len_ow_add1),
        .block_len_owh_add1        (bias_block_len_owh_add1),
        .cnt_load_bias2_w          (cnt_load_bias_w),
        .cnt_load_bias2_h          (cnt_load_bias_h),
        .cnt_load_bias2_oc         (cnt_load_bias_oc),
        .dma_bias2_arready         (dma_bias2_arready),
        .din_valid                 (bias2_din_valid),
        .din_data                  (bias2_din_data),

        .init_bias2_rtx_pulse(init_bias2_rtx_pulse),
        .bias2_offset_addr   (bias2_offset_addr),
        .bias2_load_burst_len(bias2_load_burst_len),
        .dma_bias2_rready    (dma_bias2_rready),
        .bias2_waddr         (bias2_waddr),
        .bias2_wdata         (bias2_wdata),
        .bias2_wen           (bias2_wen),
        .is_load_bias2_done  (is_load_bias2_done),
        .is_load_bias2_busy  (is_load_bias2_busy)
    );

    // assign bias2_axi_init_wtx_pulse = 0;
    // assign bias2_axi_W_BASE_ADDR = 0;
    // assign bias2_axi_w_burst_len = 0;
    // assign bias2_axi_w_offset_addr = 0;
    // assign bias2_axi_write_data_ready = 0;
    // assign bias2_axi_w_data = 0;
    // assign bias2_axi_w_data_valid = 0;
    // assign bias2_write_data_tx_wlast = 0;

    // assign bias2_axi_init_rtx_pulse = init_bias2_rtx_pulse;

    // assign bias2_axi_r_burst_len = bias2_load_burst_len;
    // assign bias2_axi_r_offset_addr = bias2_offset_addr;

    assign dma_bias2_arready = bias2_m_axi_arready;
    // assign bias2_axi_dma_rready = dma_bias2_rready;

    // assign bias2_din_valid = bias2_axi_r_data_valid;
    // assign bias2_din_data = bias2_axi_r_data;




    // axi_full_interface_top Inputs
    reg                             omap_axi_init_wtx_pulse;
    // reg  [  C_M_AXI_ADDR_WIDTH-1 : 0] omap_axi_W_BASE_ADDR;
    reg  [                   8-1:0] omap_axi_w_burst_len;
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0] omap_axi_w_offset_addr;
    reg  [C_M_AXI_DATA_WIDTH-1 : 0] omap_axi_w_data;
    reg                             omap_axi_w_data_valid;
    reg                             bias_axi_init_rtx_pulse;
    wire                            bias_axi_dma_rready;
    // reg  [  C_M_AXI_ADDR_WIDTH-1 : 0] bias_axi_R_BASE_ADDR;
    reg  [                   8-1:0] bias_axi_r_burst_len;
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0] bias_axi_r_offset_addr;
    wire                            omap_axi_write_data_ready;
    wire                            omap_axi_write_data_tx_wlast;
    wire                            omap_axi_write_data_tx_done_pulse;
    wire                            bias_axi_read_addr_tx_done_pulse;
    wire                            bias_axi_read_data_tx_done_pulse;
    wire [C_M_AXI_DATA_WIDTH-1 : 0] bias_axi_r_data;
    wire                            bias_axi_r_data_valid;


    // assign omap_m_axi_aclk = clk;
    // assign omap_m_axi_aresetn = rstn;
    axi_full_interface_top #(
        .C_M_AXI_BURST_LEN   (C_M_AXI_BURST_LEN),
        .C_M_AXI_ID_WIDTH    (C_M_AXI_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH  (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH  (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH (C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH (C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH (C_M_AXI_BUSER_WIDTH),
        .M_ID                (3)
    ) u_axi_full_interface_top_bias_omap (
        .init_wtx_pulse(omap_axi_init_wtx_pulse),  //init_wtx_pulse拉高时w_offset_addr有效
        .W_BASE_ADDR(omap_axi_W_BASE_ADDR),
        .w_burst_len(omap_axi_w_burst_len),
        .w_offset_addr(omap_axi_w_offset_addr),
        .write_data_ready(omap_axi_write_data_ready),//这个时候w_offset_addr完成握手，slave端wdata也已经ready，可以开始w_data的传输
        .w_data(omap_axi_w_data),
        .w_data_valid(omap_axi_w_data_valid),
        .write_data_tx_wlast(omap_axi_write_data_tx_wlast),
        .write_data_tx_done_pulse(omap_axi_write_data_tx_done_pulse),  //写data传输完成pulse
        .init_rtx_pulse(bias_axi_init_rtx_pulse),
        .R_BASE_ADDR(bias_axi_R_BASE_ADDR),
        .r_burst_len(bias_axi_r_burst_len),
        .r_offset_addr(bias_axi_r_offset_addr),
        .dma_rready(bias_axi_dma_rready),
        .read_addr_tx_done_pulse(bias_axi_read_addr_tx_done_pulse),  //读addr传输完成pulse
        .r_data(bias_axi_r_data),
        .r_data_valid(bias_axi_r_data_valid),
        .read_data_tx_done_pulse(bias_axi_read_data_tx_done_pulse),  //读data传输完成pulse

        .m_axi_aclk(omap_m_axi_aclk),
        .m_axi_aresetn(omap_m_axi_aresetn),
        .m_axi_awid(omap_m_axi_awid),
        .m_axi_awaddr(omap_m_axi_awaddr),
        .m_axi_awlen(omap_m_axi_awlen),
        .m_axi_awsize(omap_m_axi_awsize),
        .m_axi_awburst(omap_m_axi_awburst),
        .m_axi_awlock(omap_m_axi_awlock),
        .m_axi_awcache(omap_m_axi_awcache),
        .m_axi_awprot(omap_m_axi_awprot),
        .m_axi_awqos(omap_m_axi_awqos),  //none
        .m_axi_awuser(omap_m_axi_awuser),  //none
        .m_axi_awvalid(omap_m_axi_awvalid),
        .m_axi_awready(omap_m_axi_awready),
        .m_axi_wdata(omap_m_axi_wdata),
        .m_axi_wstrb(omap_m_axi_wstrb),
        .m_axi_wlast(omap_m_axi_wlast),
        .m_axi_wuser(omap_m_axi_wuser),  //none
        .m_axi_wvalid(omap_m_axi_wvalid),
        .m_axi_wready(omap_m_axi_wready),
        .m_axi_bid(omap_m_axi_bid),
        .m_axi_bresp(omap_m_axi_bresp),
        .m_axi_buser(omap_m_axi_buser),  //none
        .m_axi_bvalid(omap_m_axi_bvalid),
        .m_axi_bready(omap_m_axi_bready),
        .m_axi_arid(omap_m_axi_arid),
        .m_axi_araddr(omap_m_axi_araddr),
        .m_axi_arlen(omap_m_axi_arlen),
        .m_axi_arsize(omap_m_axi_arsize),
        .m_axi_arburst(omap_m_axi_arburst),
        .m_axi_arlock(omap_m_axi_arlock),
        .m_axi_arcache(omap_m_axi_arcache),
        .m_axi_arprot(omap_m_axi_arprot),
        .m_axi_arqos(omap_m_axi_arqos),  //none
        .m_axi_aruser(omap_m_axi_aruser),  //none
        .m_axi_arvalid(omap_m_axi_arvalid),
        .m_axi_arready(omap_m_axi_arready),
        .m_axi_rid(omap_m_axi_rid),
        .m_axi_rdata(omap_m_axi_rdata),
        .m_axi_rresp(omap_m_axi_rresp),
        .m_axi_rlast(omap_m_axi_rlast),
        .m_axi_ruser(omap_m_axi_ruser),  //none
        .m_axi_rvalid(omap_m_axi_rvalid),
        .m_axi_rready(omap_m_axi_rready)
    );

    // assign omap_m_axi_ruser = 0;
    // assign omap_m_axi_buser = 0;



    (* mark_debug = "false"*)reg                            write_omap_start;
    (* mark_debug = "false"*)reg                            is_cnt_write_omap_h_end;
    (* mark_debug = "false"*)reg                            is_cnt_write_omap_w_end;
    (* mark_debug = "false"*)reg                            is_cnt_write_omap_oc_end;
    (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_write_omap_h;
    (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_write_omap_w;
    (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_write_omap_oc;

    (* mark_debug = "false"*)wire                           dma_omap_awready;
    (* mark_debug = "false"*)wire                           init_omap_wtx_pulse;
    (* mark_debug = "false"*)wire [     BUS_ADDR_WIDTH-1:0] omap_offset_addr;
    (* mark_debug = "false"*)wire [                  8-1:0] omap_write_burst_len;
    (* mark_debug = "false"*)reg                            dma_omap_wready;


    (* mark_debug = "false"*)reg                            omap_dout_valid;
    (* mark_debug = "false"*)reg  [          BUS_WIDTH-1:0] omap_dout_data;
    (* mark_debug = "false"*)wire                           dma_omap_wlast;
    // dma_omap Outputs

    (* mark_debug = "false"*)wire [OMAP_RAM_ADDR_WIDTH-1:0] omap_axi_raddr;
    (* mark_debug = "false"*)wire [   GEMM_MAC_COL_NUM-1:0] omap_axi_ren;
    (* mark_debug = "false"*)wire [     OMAP_RAM_WIDTH-1:0] omap_axi_rdata           [GEMM_MAC_COL_NUM-1:0];
    (* mark_debug = "false"*)wire [   GEMM_MAC_COL_NUM-1:0] omap_axi_rdata_valid;
    (* mark_debug = "false"*)wire                           is_write_omap_done;
    (* mark_debug = "false"*)wire                           is_write_omap_busy;



    dma_omap #(
        .CHANNEL_NUM        (GEMM_MAC_COL_NUM),
        .NUM_WIDTH          (NUM_WIDTH),
        .DIM_WIDTH          (DIM_WIDTH),
        .BUS_WIDTH          (BUS_WIDTH),
        .BUS_ADDR_WIDTH     (BUS_ADDR_WIDTH),
        .OMAP_WIDTH         (OMAP_WIDTH),
        .OMAP_RAM_WIDTH     (OMAP_RAM_WIDTH),
        .OMAP_RAM_ADDR_WIDTH(OMAP_RAM_ADDR_WIDTH),
        .AOWOH_WIDTH        (AOWOH_WIDTH),
        .AOW_WIDTH          (AOW_WIDTH)
    ) u_dma_omap (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16),
        .Aowoh                     (Aowoh),
        .Aow                       (Aow),
        .basic_oc_add1             (basic_oc_add1),
        .basic_ow_add1             (basic_ow_add1),
        .basic_oh_add1             (basic_oh_add1),
        .write_omap_start          (write_omap_start),
        .currc_end_c               (omap_currc_end_c),
        .currc_not_end_c           (omap_currc_not_end_c),
        .burst_num_end_c           (omap_burst_num_end_c),
        .burst_num_not_end_c       (omap_burst_num_not_end_c),
        .remain_burst_len_end_c    (omap_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(omap_remain_burst_len_not_end_c),
        .block_len_ow              (omap_block_len_ow),
        .block_len_oh              (omap_block_len_oh),
        .block_len_oc              (omap_block_len_oc),
        .block_len_ow_add1         (omap_block_len_ow_add1),
        .block_len_owh_add1        (omap_block_len_owh_add1),
        .cnt_write_omap_w          (cnt_write_omap_w),
        .cnt_write_omap_h          (cnt_write_omap_h),
        .cnt_write_omap_oc         (cnt_write_omap_oc),

        .dma_omap_awready    (dma_omap_awready),
        .init_omap_wtx_pulse (init_omap_wtx_pulse),
        .omap_offset_addr    (omap_offset_addr),
        .omap_write_burst_len(omap_write_burst_len),
        .dma_omap_wlast      (dma_omap_wlast),
        .dma_omap_wready     (dma_omap_wready),


        .dout_valid(omap_dout_valid),
        .dout_data (omap_dout_data),

        .omap_raddr      (omap_axi_raddr),
        .omap_ren        (omap_axi_ren),
        .omap_rdata      (omap_axi_rdata),
        .omap_rdata_valid(omap_axi_rdata_valid),

        .is_write_omap_done(is_write_omap_done),
        .is_write_omap_busy(is_write_omap_busy)
    );

    assign dma_omap_awready = omap_m_axi_awready;
    // assign omap_axi_init_wtx_pulse = init_omap_wtx_pulse;

    // assign omap_axi_w_burst_len = omap_write_burst_len;
    // assign omap_axi_w_offset_addr = omap_offset_addr;
    // assign omap_axi_write_data_tx_wlast = dma_omap_wlast;
    assign dma_omap_wready  = omap_m_axi_wready;
    // assign omap_axi_w_data = omap_dout_data;
    // assign omap_axi_w_data_valid = omap_dout_valid;


    (* mark_debug = "false"*)reg                            load_bias_start;
    (* mark_debug = "false"*)reg                            is_cnt_load_bias_h_end;
    (* mark_debug = "false"*)reg                            is_cnt_load_bias_w_end;
    (* mark_debug = "false"*)reg                            is_cnt_load_bias_oc_end;
    // (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_load_bias_h;
    // (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_load_bias_w;
    // (* mark_debug = "false"*)reg  [          NUM_WIDTH-1:0] cnt_load_bias_oc;
    (* mark_debug = "false"*)reg                            bias_din_valid;
    (* mark_debug = "false"*)reg  [          BUS_WIDTH-1:0] bias_din_data;

    // dma_bias Outputs
    (* mark_debug = "false"*)wire                           init_bias_rtx_pulse;
    (* mark_debug = "false"*)wire [     BUS_ADDR_WIDTH-1:0] bias_offset_addr;
    (* mark_debug = "false"*)wire [                  8-1:0] bias_load_burst_len;
    (* mark_debug = "false"*)wire [OMAP_RAM_ADDR_WIDTH-1:0] bias_axi_waddr;
    (* mark_debug = "false"*)wire [     OMAP_RAM_WIDTH-1:0] bias_axi_wdata          [GEMM_MAC_COL_NUM-1:0];
    (* mark_debug = "false"*)wire [   GEMM_MAC_COL_NUM-1:0] bias_axi_wen;
    (* mark_debug = "false"*)wire                           is_load_bias_done;
    (* mark_debug = "false"*)wire                           is_load_bias_busy;

    (* mark_debug = "false"*)reg                            dma_bias_arready;
    (* mark_debug = "false"*)wire                           dma_bias_rready;



    dma_bias #(
        .CHANNEL_NUM        (GEMM_MAC_COL_NUM),
        .NUM_WIDTH          (NUM_WIDTH),
        .DIM_WIDTH          (DIM_WIDTH),
        .BUS_WIDTH          (BUS_WIDTH),
        .BUS_ADDR_WIDTH     (BUS_ADDR_WIDTH),
        .BIAS_WIDTH         (BIAS_WIDTH),
        .OMAP_RAM_WIDTH     (OMAP_RAM_WIDTH),
        .OMAP_RAM_ADDR_WIDTH(OMAP_RAM_ADDR_WIDTH),
        .AOWOH_WIDTH        (AOWOH_WIDTH),
        .AOW_WIDTH          (AOW_WIDTH)
    ) u_dma_bias (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16),
        .bias_mode_external        (bias_mode_external),
        .Aowoh                     (Aowoh),
        .Aow                       (Aow),
        .basic_oc_add1             (basic_oc_add1),
        .basic_ow_add1             (basic_ow_add1),
        .basic_oh_add1             (basic_oh_add1),
        .load_bias_start           (load_bias_start),
        .currc_end_c               (bias_currc_end_c),
        .currc_not_end_c           (bias_currc_not_end_c),
        .burst_num_end_c           (bias_burst_num_end_c),
        .burst_num_not_end_c       (bias_burst_num_not_end_c),
        .remain_burst_len_end_c    (bias_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(bias_remain_burst_len_not_end_c),
        .block_len_ow              (bias_block_len_ow),
        .block_len_oh              (bias_block_len_oh),
        .block_len_oc              (bias_block_len_oc),
        .block_len_ow_add1         (bias_block_len_ow_add1),
        .block_len_owh_add1        (bias_block_len_owh_add1),
        .cnt_load_bias_w           (cnt_load_bias_w),
        .cnt_load_bias_h           (cnt_load_bias_h),
        .cnt_load_bias_oc          (cnt_load_bias_oc),

        .din_valid(bias_din_valid),
        .din_data (bias_din_data),


        .dma_bias_arready(dma_bias_arready),
        .init_bias_rtx_pulse(init_bias_rtx_pulse),
        .bias_offset_addr   (bias_offset_addr),
        .bias_load_burst_len(bias_load_burst_len),
        .dma_bias_rready(dma_bias_rready),

        .bias_waddr       (bias_axi_waddr),
        .bias_wdata       (bias_axi_wdata),
        .bias_wen         (bias_axi_wen),
        .is_load_bias_done(is_load_bias_done),
        .is_load_bias_busy(is_load_bias_busy)
    );



    // assign bias_axi_init_rtx_pulse = init_bias_rtx_pulse;

    // assign bias_axi_r_burst_len = bias_load_burst_len;
    // assign bias_axi_r_offset_addr = bias_offset_addr;

    assign dma_bias_arready = omap_m_axi_arready;
    // assign bias_axi_dma_rready = dma_bias_rready;

    // assign bias_din_valid = bias_axi_r_data_valid;
    // assign bias_din_data = bias_axi_r_data;


    // parameter IMAP_WIDTH = WIDTH;
    reg                            ram_imap_pingpong;
    reg  [   GEMM_MAC_ROW_NUM-1:0] imap_rd_en;
    reg  [IMAP_RAM_ADDR_WIDTH-1:0] imap_rd_addr      [GEMM_MAC_ROW_NUM-1:0];
    reg  [   GEMM_MAC_ROW_NUM-1:0] imap_wr_en;
    reg  [IMAP_RAM_ADDR_WIDTH-1:0] imap_wr_addr      [GEMM_MAC_ROW_NUM-1:0];
    reg  [         IMAP_WIDTH-1:0] imap_wr_data      [GEMM_MAC_ROW_NUM-1:0];

    // ram_imap Outputs
    wire [         IMAP_WIDTH-1:0] imap_rd_data      [GEMM_MAC_ROW_NUM-1:0];
    wire [   GEMM_MAC_ROW_NUM-1:0] imap_rd_valid;

    ram_imap #(
        .CHANNEL_NUM(GEMM_MAC_ROW_NUM),
        .WIDTH      (IMAP_WIDTH),
        .DEPTH      (IMAP_RAM_DEPTH),
        .ADDR_WIDTH (IMAP_RAM_ADDR_WIDTH)
    ) u_ram_imap (
        .clk                   (clk),
        .rstn                  (rstn),
        .is_int16              (is_int16),
        .is_imap_all_read      (~is_stc),
        .ram_imap_pingpong     (ram_imap_pingpong),
        .imap_ric_even_odd_flag(imap_ric_even_odd_flag),
        .rd_en                 (imap_rd_en),
        .rd_addr               (imap_rd_addr),
        // .imap_wic_even_odd_flag(imap_wic_even_odd_flag),
        .wr_en                 (imap_wr_en),
        .wr_addr               (imap_wr_addr),
        .wr_data               (imap_wr_data),
        .rd_data               (imap_rd_data),
        .rd_valid              (imap_rd_valid)
    );

    // axi imap dma write
    assign imap_wr_en = imap_wen;
    generate
        for (genvar i = 0; i < GEMM_MAC_ROW_NUM; i = i + 1) begin
            assign imap_wr_addr[i] = imap_waddr;
        end
    endgenerate

    assign imap_wr_data = imap_wdata;

    //pe array imap read
    assign imap_rd_en   = imap_ren;
    generate
        for (genvar i = 0; i < GEMM_MAC_ROW_NUM; i = i + 1) begin
            assign imap_rd_addr[i] = imap_addr;
        end
    endgenerate
    assign mat_data_in = imap_rd_data;

    assign imap_data_out = imap_rd_data;
    assign imap_data_out_valid = imap_rd_valid;




    // parameter WEIGHT_WIDTH = WIDTH;

    reg                              ram_weight_pingpong;
    reg  [     GEMM_MAC_COL_NUM-1:0] weight_rd_en;
    reg  [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_rd_addr      [GEMM_MAC_COL_NUM-1:0];
    reg  [     GEMM_MAC_COL_NUM-1:0] weight_wr_en;
    reg  [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_wr_addr      [GEMM_MAC_COL_NUM-1:0];
    reg  [         WEIGHT_WIDTH-1:0] weight_wr_data      [GEMM_MAC_COL_NUM-1:0];

    // ram_weight Outputs
    wire [         WEIGHT_WIDTH-1:0] weight_rd_data      [GEMM_MAC_COL_NUM-1:0];
    wire [     GEMM_MAC_COL_NUM-1:0] weight_rd_valid;


    ram_weight #(
        .CHANNEL_NUM(GEMM_MAC_COL_NUM),
        .WIDTH      (WEIGHT_WIDTH),
        .DEPTH      (WEIGHT_RAM_DEPTH),
        .ADDR_WIDTH (WEIGHT_RAM_ADDR_WIDTH)
    ) u_ram_weight (
        .clk                (clk),
        .rstn               (rstn),
        .ram_weight_pingpong(ram_weight_pingpong),
        .rd_en              (weight_rd_en),
        .rd_addr            (weight_rd_addr),
        .wr_en              (weight_wr_en),
        .wr_addr            (weight_wr_addr),
        .wr_data            (weight_wr_data),
        .rd_data            (weight_rd_data),
        .rd_valid           (weight_rd_valid)
    );

    // axi weight dma write
    assign weight_wr_en = weight_wen;
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign weight_wr_addr[i] = weight_waddr;
        end
    endgenerate

    assign weight_wr_data = weight_wdata;


    // pe array weight read
    assign weight_rd_en   = weight_ren;
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign weight_rd_addr[i] = weight_addr;
        end
    endgenerate
    assign mat_weight_in = weight_rd_data;
    assign mat_col_in_valid = weight_rd_valid;


    reg                             ram_bias2_pingpong;
    reg  [    GEMM_MAC_COL_NUM-1:0] bias2_rd_en;
    reg  [BIAS2_RAM_ADDR_WIDTH-1:0] bias2_rd_addr      [GEMM_MAC_COL_NUM-1:0];
    reg  [    GEMM_MAC_COL_NUM-1:0] bias2_wr_en;
    reg  [BIAS2_RAM_ADDR_WIDTH-1:0] bias2_wr_addr      [GEMM_MAC_COL_NUM-1:0];
    reg  [         BIAS2_WIDTH-1:0] bias2_wr_data      [GEMM_MAC_COL_NUM-1:0];

    // ram_bias2 Outputs
    wire [         BIAS2_WIDTH-1:0] bias2_rd_data      [GEMM_MAC_COL_NUM-1:0];
    wire [    GEMM_MAC_COL_NUM-1:0] bias2_rd_valid;


    ram_bias2 #(
        .CHANNEL_NUM(GEMM_MAC_COL_NUM),
        .WIDTH      (BIAS2_WIDTH),
        .DEPTH      (BIAS2_RAM_DEPTH),
        .ADDR_WIDTH (BIAS2_RAM_ADDR_WIDTH)
    ) u_ram_bias2 (
        .clk               (clk),
        .rstn              (rstn),
        .ram_bias2_pingpong(ram_bias2_pingpong),
        .rd_en             (bias2_rd_en),
        .rd_addr           (bias2_rd_addr),
        .wr_en             (bias2_wr_en),
        .wr_addr           (bias2_wr_addr),
        .wr_data           (bias2_wr_data),
        .rd_data           (bias2_rd_data),
        .rd_valid          (bias2_rd_valid)
    );

    // axi bias2 dma write
    assign bias2_wr_en = bias2_wen;
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign bias2_wr_addr[i] = bias2_waddr;
        end
    endgenerate

    assign bias2_wr_data = bias2_wdata;


    // pe array bias2 read
    assign bias2_rd_en   = bias2_ren;
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign bias2_rd_addr[i] = bias2_addr;
        end
    endgenerate
    assign bias2_in = bias2_rd_data;


    reg  [                    1:0] ram_omap_sel      [                 4:0];
    reg  [                    2:0] ram_omap_ren_sel;
    reg  [   GEMM_MAC_COL_NUM-1:0] omap_pe_wr_en;
    reg  [   GEMM_MAC_COL_NUM-1:0] omap_pe_rd_en;
    reg  [OMAP_RAM_ADDR_WIDTH-1:0] omap_pe_wr_addr   [GEMM_MAC_COL_NUM-1:0];
    reg  [    OMAP_RAM_WIDTH -1:0] omap_pe_wr_data   [GEMM_MAC_COL_NUM-1:0];
    reg  [OMAP_RAM_ADDR_WIDTH-1:0] omap_pe_rd_addr   [GEMM_MAC_COL_NUM-1:0];

    reg  [   GEMM_MAC_COL_NUM-1:0] omap_bus_wr_en;
    reg  [   GEMM_MAC_COL_NUM-1:0] omap_bus_rd_en;
    reg  [OMAP_RAM_ADDR_WIDTH-1:0] omap_bus_wr_addr  [GEMM_MAC_COL_NUM-1:0];
    reg  [     OMAP_RAM_WIDTH-1:0] omap_bus_wr_data  [GEMM_MAC_COL_NUM-1:0];
    reg  [OMAP_RAM_ADDR_WIDTH-1:0] omap_bus_rd_addr  [GEMM_MAC_COL_NUM-1:0];

    // ram_omap Outputs
    wire [     OMAP_RAM_WIDTH-1:0] omap_pe_rd_data   [GEMM_MAC_COL_NUM-1:0];
    wire [   GEMM_MAC_COL_NUM-1:0] omap_pe_rd_valid;
    wire [     OMAP_RAM_WIDTH-1:0] omap_bus_rd_data  [GEMM_MAC_COL_NUM-1:0];
    wire [   GEMM_MAC_COL_NUM-1:0] omap_bus_rd_valid;


    ram_omap #(
        .CHANNEL_NUM(GEMM_MAC_COL_NUM),
        .WIDTH      (OMAP_RAM_WIDTH),
        .DEPTH      (OMAP_RAM_DEPTH),
        .ADDR_WIDTH (OMAP_RAM_ADDR_WIDTH)
    ) u_ram_omap (
        .clk             (clk),
        .rstn            (rstn),
        .ram_omap_sel    (ram_omap_sel),
        .ram_omap_ren_sel(ram_omap_ren_sel),
        .pe_wr_en        (omap_pe_wr_en),
        .pe_rd_en        (omap_pe_rd_en),
        .pe_wr_addr      (omap_pe_wr_addr),
        .pe_wr_data      (omap_pe_wr_data),
        .pe_rd_addr      (omap_pe_rd_addr),
        .bus_wr_en       (omap_bus_wr_en),
        .bus_rd_en       (omap_bus_rd_en),
        .bus_wr_addr     (omap_bus_wr_addr),
        .bus_wr_data     (omap_bus_wr_data),
        .bus_rd_addr     (omap_bus_rd_addr),
        .pe_rd_data      (omap_pe_rd_data),
        .pe_rd_valid     (omap_pe_rd_valid),
        .bus_rd_data     (omap_bus_rd_data),
        .bus_rd_valid    (omap_bus_rd_valid)
    );


    // pe array bias read | omap write
    assign omap_pe_wr_en = omap_wen;
    assign omap_pe_rd_en = bias_ren;
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign omap_pe_wr_addr[i] = omap_addr;
            assign omap_pe_rd_addr[i] = bias_addr;
        end
    endgenerate
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign omap_pe_wr_data[i] = use_quan_internal ? ({{(OMAP_RAM_WIDTH-WIDTH){1'b0}},ele_add_dout[i][WIDTH-1:0]}
                                                                    )
                                                    :acc_pool_out[i];
        end
    endgenerate
    assign c_in = omap_pe_rd_data;


    // axi dma bias write | omap read
    assign omap_bus_wr_en = bias_axi_wen;
    assign omap_bus_rd_en = omap_axi_ren;
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign omap_bus_wr_addr[i] = bias_axi_waddr;
            assign omap_bus_rd_addr[i] = omap_axi_raddr;
        end
    endgenerate
    assign omap_bus_wr_data = bias_axi_wdata;
    assign omap_axi_rdata = omap_bus_rd_data;
    assign omap_axi_rdata_valid = omap_bus_rd_valid;




    reg is_pe_array_done;

    // conv_L2_control Outputs
    (* mark_debug = "false"*) wire L2_load_weight_start;
    (* mark_debug = "false"*) wire L2_load_bias_start;
    (* mark_debug = "false"*) wire L2_load_bias2_start;
    (* mark_debug = "false"*) wire L2_load_imap_start;
    (* mark_debug = "false"*) wire L2_write_omap_start;

    (* mark_debug = "false"*) wire L2_pe_array_start;
    wire L2_total_rs_start;
    wire L2_total_rs_done;
    wire L2_use_bias_internal;
    wire L2_bias_mode_internal;
    wire L2_use_quan_internal;

    wire is_cnt_cal_w_end;
    wire is_cnt_cal_h_end;
    wire is_cnt_cal_oc_end;
    wire is_cnt_cal_ic_end;
    wire is_cnt_cal_rs_end;
    wire L2_is_cnt_load_bias_w_end;
    wire L2_is_cnt_load_bias_h_end;
    wire L2_is_cnt_load_bias_oc_end;
    wire L2_is_cnt_load_wei_rs_end;
    wire L2_is_cnt_load_wei_ic_end;
    wire L2_is_cnt_load_wei_oc_end;
    wire L2_is_cnt_load_imap_w_end;
    wire L2_is_cnt_load_imap_h_end;
    wire L2_is_cnt_load_imap_ic_end;
    wire L2_is_cnt_write_omap_w_end;
    wire L2_is_cnt_write_omap_h_end;
    wire L2_is_cnt_write_omap_oc_end;

    wire [NUM_WIDTH-1:0] cnt_cal_w;
    wire [NUM_WIDTH-1:0] cnt_cal_h;
    wire [NUM_WIDTH-1:0] cnt_cal_oc;
    wire [NUM_WIDTH-1:0] cnt_cal_ic;
    wire [NUM_WIDTH-1:0] cnt_cal_rs;


    convpool_L2_control #(
        .WIDTH                      (WIDTH),
        // .C_WIDTH                    (C_WIDTH),
        .GEMM_MAC_ROW_NUM           (GEMM_MAC_ROW_NUM),
        .GEMM_MAC_COL_NUM           (GEMM_MAC_COL_NUM),
        .DUAL_MAC_ROW_NUM           (DUAL_MAC_ROW_NUM),
        .DUAL_MAC_COL_NUM           (DUAL_MAC_COL_NUM),
        .FFT_BUTTER_ROW_NUM         (FFT_BUTTER_ROW_NUM),
        .FFT_BUTTER_COL_NUM         (FFT_BUTTER_COL_NUM),
        .INPUTS_NUM                 (INPUTS_NUM),
        .OUTPUT_NUM                 (OUTPUT_NUM),
        .STAGES_NUM                 (STAGES_NUM),
        .ODATA_WIDTH                (ODATA_WIDTH),
        .MULT_DELAY                 (MULT_DELAY),
        .ADD_DELAY                  (ADD_DELAY),
        .READ_ADDR_GEN_DELAY        (READ_ADDR_GEN_DELAY),
        .WRITE_ADDR_GEN_DELAY       (WRITE_ADDR_GEN_DELAY),
        .READ_ADDR_TO_DATA_OUT_DELAY(READ_ADDR_TO_DATA_OUT_DELAY),
        .READ_DELAY_N               (READ_DELAY_N),
        .NUM_DELAY_HEADS            (NUM_DELAY_HEADS),
        .CAL_DELAY_STC              (CAL_DELAY_STC),
        .CAL_DELAY_DWC              (CAL_DELAY_DWC),
        .CAL_DELAY_POOL             (CAL_DELAY_POOL),
        .MAX_CAL_DELAY_M            (MAX_CAL_DELAY_M),
        .QUAN_DELAY_Q               (QUAN_DELAY_Q),
        .MAX_BLOCK_DIM              (MAX_BLOCK_DIM),
        .MAX_NUM_DIM                (MAX_NUM_DIM),
        .NUM_WIDTH                  (NUM_WIDTH),
        .SEL_WIDTH                  (SEL_WIDTH),
        .DIM_WIDTH                  (DIM_WIDTH),
        .IMAP_DIM_WIDTH             (IMAP_DIM_WIDTH),
        .IMAP_RAM_DEPTH             (IMAP_RAM_DEPTH),
        .WEIGHT_RAM_DEPTH           (WEIGHT_RAM_DEPTH),
        .BIAS_RAM_DEPTH             (BIAS_RAM_DEPTH),
        .BIAS2_RAM_DEPTH            (BIAS2_RAM_DEPTH),
        .OMAP_RAM_DEPTH             (OMAP_RAM_DEPTH),
        .IMAP_RAM_ADDR_WIDTH        (IMAP_RAM_ADDR_WIDTH),
        .WEIGHT_RAM_ADDR_WIDTH      (WEIGHT_RAM_ADDR_WIDTH),
        .BIAS_RAM_ADDR_WIDTH        (BIAS_RAM_ADDR_WIDTH),
        .BIAS2_RAM_ADDR_WIDTH       (BIAS2_RAM_ADDR_WIDTH),
        .OMAP_RAM_ADDR_WIDTH        (OMAP_RAM_ADDR_WIDTH),
        .MAX_STRIDE_X               (MAX_STRIDE_X),
        .MAX_STRIDE_Y               (MAX_STRIDE_Y),
        .MAX_DILATION_X             (MAX_DILATION_X),
        .MAX_DILATION_Y             (MAX_DILATION_Y),
        .MAX_WIN_R                  (MAX_WIN_R),
        .MAX_WIN_S                  (MAX_WIN_S),
        .STRIDE_X_WIDTH             (STRIDE_X_WIDTH),
        .STRIDE_Y_WIDTH             (STRIDE_Y_WIDTH),
        .DILATION_X_WIDTH           (DILATION_X_WIDTH),
        .DILATION_Y_WIDTH           (DILATION_Y_WIDTH),
        .WIN_R_WIDTH                (WIN_R_WIDTH),
        .WIN_S_WIDTH                (WIN_S_WIDTH)
    ) u_convpool_L2_control (
        .clk                   (clk),
        .rstn                  (rstn),
        .is_int16              (is_int16),
        .is_matmul             (is_matmul),
        .is_pool               (is_pool),
        .pool_type             (pool_type),
        .conv_type             (conv_type),
        .mat_core_start        (mat_core_start),
        .num_ow                (num_ow),
        .num_oh                (num_oh),
        .num_oc                (num_oc),
        .num_ic                (num_ic),
        .num_rs                (num_rs),
        .is_pe_array_busy      (is_pe_array_busy),
        .is_load_weight_busy   (is_load_weight_busy),
        .is_load_bias_busy     (is_load_bias_busy),
        .is_load_bias2_busy    (is_load_bias2_busy),
        .is_load_imap_busy     (is_load_imap_busy),
        .is_write_omap_busy    (is_write_omap_busy),
        .is_pe_array_done      (is_pe_array_done),
        .is_load_weight_done   (is_load_weight_done),
        .is_load_bias_done     (is_load_bias_done),
        .is_load_bias2_done    (is_load_bias2_done),
        .is_load_imap_done     (is_load_imap_done),
        .is_write_omap_done    (is_write_omap_done),
        .use_bias_external     (use_bias_external),
        .bias_mode_external    (bias_mode_external),
        .use_quan_external     (use_quan_external),
        .use_bias2_add_external(use_bias2_add_external),

        .load_weight_start       (L2_load_weight_start),
        .load_bias_start         (L2_load_bias_start),
        .load_bias2_start        (L2_load_bias2_start),
        .load_imap_start         (L2_load_imap_start),
        .write_omap_start        (L2_write_omap_start),
        .ram_weight_pingpong     (ram_weight_pingpong),
        .ram_imap_pingpong       (ram_imap_pingpong),
        .ram_bias2_pingpong      (ram_bias2_pingpong),
        .ram_omap_sel            (ram_omap_sel),
        .ram_omap_ren_sel        (ram_omap_ren_sel),
        .pe_array_start          (L2_pe_array_start),
        .total_rs_start          (L2_total_rs_start),
        .total_rs_done           (L2_total_rs_done),
        .use_bias_internal       (L2_use_bias_internal),
        .bias_mode_internal      (L2_bias_mode_internal),
        .use_quan_internal       (L2_use_quan_internal),
        .is_cnt_cal_w_end        (is_cnt_cal_w_end),
        .is_cnt_cal_h_end        (is_cnt_cal_h_end),
        .is_cnt_cal_oc_end       (is_cnt_cal_oc_end),
        .is_cnt_cal_ic_end       (is_cnt_cal_ic_end),
        .is_cnt_cal_rs_end       (is_cnt_cal_rs_end),
        .is_cnt_load_bias_w_end  (L2_is_cnt_load_bias_w_end),
        .is_cnt_load_bias_h_end  (L2_is_cnt_load_bias_h_end),
        .is_cnt_load_bias_oc_end (L2_is_cnt_load_bias_oc_end),
        .is_cnt_load_wei_rs_end  (L2_is_cnt_load_wei_rs_end),
        .is_cnt_load_wei_ic_end  (L2_is_cnt_load_wei_ic_end),
        .is_cnt_load_wei_oc_end  (L2_is_cnt_load_wei_oc_end),
        .is_cnt_load_imap_w_end  (L2_is_cnt_load_imap_w_end),
        .is_cnt_load_imap_h_end  (L2_is_cnt_load_imap_h_end),
        .is_cnt_load_imap_ic_end (L2_is_cnt_load_imap_ic_end),
        .is_cnt_write_omap_w_end (L2_is_cnt_write_omap_w_end),
        .is_cnt_write_omap_h_end (L2_is_cnt_write_omap_h_end),
        .is_cnt_write_omap_oc_end(L2_is_cnt_write_omap_oc_end),
        .cnt_cal_w               (cnt_cal_w),
        .cnt_cal_h               (cnt_cal_h),
        .cnt_cal_oc              (cnt_cal_oc),
        .cnt_cal_ic              (cnt_cal_ic),
        .cnt_cal_rs              (cnt_cal_rs),
        .cnt_load_bias_w         (cnt_load_bias_w),
        .cnt_load_bias_h         (cnt_load_bias_h),
        .cnt_load_bias_oc        (cnt_load_bias_oc),
        .cnt_load_wei_rs         (cnt_load_wei_rs),
        .cnt_load_wei_ic         (cnt_load_wei_ic),
        .cnt_load_wei_oc         (cnt_load_wei_oc),
        .cnt_load_imap_w         (cnt_load_imap_w),
        .cnt_load_imap_h         (cnt_load_imap_h),
        .cnt_load_imap_ic        (cnt_load_imap_ic),
        .cnt_write_omap_w        (cnt_write_omap_w),
        .cnt_write_omap_h        (cnt_write_omap_h),
        .cnt_write_omap_oc       (cnt_write_omap_oc),
        .layer_done              (layer_done),
        .is_mat_core_busy        (is_mat_core_busy),
        .is_mat_core_ready       (is_mat_core_ready)
    );




    L2todma_param_reg #(
        .IMAP_DIM_WIDTH      (IMAP_DIM_WIDTH),
        .DIM_WIDTH           (DIM_WIDTH),
        .PADDING_WIDTH       (PADDING_WIDTH),
        .NUM_WIDTH           (NUM_WIDTH),
        .WEIGHT_WIDTH        (WEIGHT_WIDTH),
        .IMAP_WIDTH          (IMAP_WIDTH),
        .OMAP_WIDTH          (OMAP_WIDTH),
        .BIAS_WIDTH          (BIAS_WIDTH),
        .CHANNEL_NUM         (CHANNEL_NUM),
        .BUS_WIDTH           (BUS_WIDTH),
        .C_WIDTH             (C_WIDTH),
        .BURST_NUM_WIDTH     (BURST_NUM_WIDTH),
        .BURST_NUM_WIDTH_IMAP(BURST_NUM_WIDTH_IMAP)
    ) u_L2todma_param_reg (
        .clk                              (clk),
        .rstn                             (rstn),
        .is_int16                         (is_int16),
        .is_dwc                           (is_dwc),
        .L2_load_imap_start               (L2_load_imap_start),
        .is_cnt_load_imap_w_end           (L2_is_cnt_load_imap_w_end),
        .is_cnt_load_imap_h_end           (L2_is_cnt_load_imap_h_end),
        .is_cnt_load_imap_ic_end          (L2_is_cnt_load_imap_ic_end),
        .L2_load_weight_start             (L2_load_weight_start),
        .is_cnt_load_wei_rs_end           (L2_is_cnt_load_wei_rs_end),
        .is_cnt_load_wei_ic_end           (L2_is_cnt_load_wei_ic_end),
        .is_cnt_load_wei_oc_end           (L2_is_cnt_load_wei_oc_end),
        .L2_load_bias_start               (L2_load_bias_start),
        .L2_load_bias2_start              (L2_load_bias2_start),
        .is_cnt_load_bias_w_end           (L2_is_cnt_load_bias_w_end),
        .is_cnt_load_bias_h_end           (L2_is_cnt_load_bias_h_end),
        .is_cnt_load_bias_oc_end          (L2_is_cnt_load_bias_oc_end),
        .L2_write_omap_start              (L2_write_omap_start),
        .is_cnt_write_omap_w_end          (L2_is_cnt_write_omap_w_end),
        .is_cnt_write_omap_h_end          (L2_is_cnt_write_omap_h_end),
        .is_cnt_write_omap_oc_end         (L2_is_cnt_write_omap_oc_end),
        .basic_ow                         (basic_ow),
        .basic_oh                         (basic_oh),
        .basic_oc                         (basic_oc),
        .basic_ic                         (basic_ic),
        .basic_rs                         (basic_rs),
        .basic_iw                         (basic_iw),
        .basic_ih                         (basic_ih),
        .basic_ow_sx                      (basic_ow_sx),
        .basic_oh_sy                      (basic_oh_sy),
        .remain_ow                        (remain_ow),
        .remain_oh                        (remain_oh),
        .remain_oc                        (remain_oc),
        .remain_ic                        (remain_ic),
        .remain_rs                        (remain_rs),
        .remain_iw                        (remain_iw),
        .remain_ih                        (remain_ih),
        .use_padding_external             (use_padding_external),
        .padding_external                 (padding_external),
        .cnt_load_imap_h                  (cnt_load_imap_h),
        .cnt_load_imap_w                  (cnt_load_imap_w),
        .bias_mode_external               (bias_mode_external),
        .load_imap_start                  (load_imap_start),
        .load_weight_start                (load_weight_start),
        .load_bias_start                  (load_bias_start),
        .load_bias2_start                 (load_bias2_start),
        .write_omap_start                 (write_omap_start),
        .imap_block_len_iw_np             (imap_block_len_iw_np),
        .imap_block_len_ih_np             (imap_block_len_ih_np),
        .imap_block_len_ic                (imap_block_len_ic),
        .imap_block_len_iw_add1           (imap_block_len_iw_add1),
        .imap_block_len_iwh_add1          (imap_block_len_iwh_add1),
        .padding_flag                     (padding_flag),
        .padding_internal                 (padding_internal),
        .weight_block_len_ic              (weight_block_len_ic),
        .weight_block_len_rs              (weight_block_len_rs),
        .weight_block_len_oc              (weight_block_len_oc),
        .weight_block_len_ic_add1         (weight_block_len_ic_add1),
        .weight_block_len_icrs_add1       (weight_block_len_icrs_add1),
        .bias_block_len_ow                (bias_block_len_ow),
        .bias_block_len_oh                (bias_block_len_oh),
        .bias_block_len_oc                (bias_block_len_oc),
        .bias_block_len_ow_add1           (bias_block_len_ow_add1),
        .bias_block_len_owh_add1          (bias_block_len_owh_add1),
        .omap_block_len_ow                (omap_block_len_ow),
        .omap_block_len_oh                (omap_block_len_oh),
        .omap_block_len_oc                (omap_block_len_oc),
        .omap_block_len_ow_add1           (omap_block_len_ow_add1),
        .omap_block_len_owh_add1          (omap_block_len_owh_add1),
        .imap_currc_end_c                 (imap_currc_end_c),
        .imap_currc_not_end_c             (imap_currc_not_end_c),
        .imap_burst_num_end_c             (imap_burst_num_end_c),
        .imap_burst_num_not_end_c         (imap_burst_num_not_end_c),
        .imap_remain_burst_len_end_c      (imap_remain_burst_len_end_c),
        .imap_remain_burst_len_not_end_c  (imap_remain_burst_len_not_end_c),
        .weight_currc_end_c               (weight_currc_end_c),
        .weight_currc_not_end_c           (weight_currc_not_end_c),
        .weight_burst_num_end_c           (weight_burst_num_end_c),
        .weight_burst_num_not_end_c       (weight_burst_num_not_end_c),
        .weight_remain_burst_len_end_c    (weight_remain_burst_len_end_c),
        .weight_remain_burst_len_not_end_c(weight_remain_burst_len_not_end_c),
        .bias_currc_end_c                 (bias_currc_end_c),
        .bias_currc_not_end_c             (bias_currc_not_end_c),
        .bias_burst_num_end_c             (bias_burst_num_end_c),
        .bias_burst_num_not_end_c         (bias_burst_num_not_end_c),
        .bias_remain_burst_len_end_c      (bias_remain_burst_len_end_c),
        .bias_remain_burst_len_not_end_c  (bias_remain_burst_len_not_end_c),
        .bias2_currc_end_c                (bias2_currc_end_c),
        .bias2_currc_not_end_c            (bias2_currc_not_end_c),
        .bias2_burst_num_end_c            (bias2_burst_num_end_c),
        .bias2_burst_num_not_end_c        (bias2_burst_num_not_end_c),
        .bias2_remain_burst_len_end_c     (bias2_remain_burst_len_end_c),
        .bias2_remain_burst_len_not_end_c (bias2_remain_burst_len_not_end_c),
        .omap_currc_end_c                 (omap_currc_end_c),
        .omap_currc_not_end_c             (omap_currc_not_end_c),
        .omap_burst_num_end_c             (omap_burst_num_end_c),
        .omap_burst_num_not_end_c         (omap_burst_num_not_end_c),
        .omap_remain_burst_len_end_c      (omap_remain_burst_len_end_c),
        .omap_remain_burst_len_not_end_c  (omap_remain_burst_len_not_end_c),
        .basic_ow_add1                    (basic_ow_add1),
        .basic_oh_add1                    (basic_oh_add1),
        .basic_oc_add1                    (basic_oc_add1),
        .basic_ic_add1                    (basic_ic_add1),
        .basic_rs_add1                    (basic_rs_add1),
        .basic_ow_sx_add1                 (basic_ow_sx_add1),
        .basic_oh_sy_add1                 (basic_oh_sy_add1)
    );



    reg  [              DIM_WIDTH-1:0] L1_block_len_ow;
    reg  [              DIM_WIDTH-1:0] L1_block_len_oh;

    // L2toL1_pe_param_reg Outputs
    wire [            DIM_WIDTH*2-1:0] L1_block_len_owh;
    wire [              DIM_WIDTH-1:0] L1_block_len_ic;
    wire [              DIM_WIDTH-1:0] L1_block_len_oc;
    wire [WIN_R_WIDTH*WIN_S_WIDTH-1:0] L1_block_len_rs;
    wire [       IMAP_DIM_WIDTH*2-1:0] L1_block_len_iwh;
    wire [         IMAP_DIM_WIDTH-1:0] L1_block_len_iw;
    wire [         IMAP_DIM_WIDTH-1:0] L1_block_len_ih;
    wire                               L1_pe_array_start;
    wire                               L1_total_rs_start;
    wire                               L1_total_rs_done;
    wire                               L1_use_bias_internal;
    wire                               L1_bias_mode_internal;
    wire                               L1_use_quan_internal;
    L2toL1_pe_param_reg #(
        .NUM_WIDTH       (NUM_WIDTH),
        .DIM_WIDTH       (DIM_WIDTH),
        .IMAP_DIM_WIDTH  (IMAP_DIM_WIDTH),
        .WIN_R_WIDTH     (WIN_R_WIDTH),
        .WIN_S_WIDTH     (WIN_S_WIDTH),
        .STRIDE_X_WIDTH  (STRIDE_X_WIDTH),
        .STRIDE_Y_WIDTH  (STRIDE_Y_WIDTH),
        .DILATION_X_WIDTH(DILATION_X_WIDTH),
        .DILATION_Y_WIDTH(DILATION_Y_WIDTH)
    ) u_L2toL1_pe_param_reg (
        .clk                  (clk),
        .rstn                 (rstn),
        .cnt_cal_w            (cnt_cal_w),
        .cnt_cal_h            (cnt_cal_h),
        .cnt_cal_oc           (cnt_cal_oc),
        .cnt_cal_ic           (cnt_cal_ic),
        .cnt_cal_rs           (cnt_cal_rs),
        .is_cnt_cal_ic_end    (is_cnt_cal_ic_end),
        .is_cnt_cal_oc_end    (is_cnt_cal_oc_end),
        .is_cnt_cal_rs_end    (is_cnt_cal_rs_end),
        .is_cnt_cal_w_end     (is_cnt_cal_w_end),
        .is_cnt_cal_h_end     (is_cnt_cal_h_end),
        .basic_ow             (basic_ow),
        .basic_oh             (basic_oh),
        .basic_oc             (basic_oc),
        .basic_ic             (basic_ic),
        .basic_rs             (basic_rs),
        .basic_iw             (basic_iw),
        .basic_ih             (basic_ih),
        .remain_ow            (remain_ow),
        .remain_oh            (remain_oh),
        .remain_oc            (remain_oc),
        .remain_ic            (remain_ic),
        .remain_rs            (remain_rs),
        .remain_iw            (remain_iw),
        .remain_ih            (remain_ih),
        .L2_pe_array_start    (L2_pe_array_start),
        .L2_total_rs_start    (L2_total_rs_start),
        .L2_total_rs_done     (L2_total_rs_done),
        .L2_use_bias_internal (L2_use_bias_internal),
        .L2_bias_mode_internal(L2_bias_mode_internal),
        .L2_use_quan_internal (L2_use_quan_internal),
        .use_padding_external (use_padding_external),
        .padding_external     (padding_external),

        .L1_block_len_ow         (L1_block_len_ow),
        .L1_block_len_oh         (L1_block_len_oh),
        .L1_block_len_owh        (L1_block_len_owh),
        .L1_block_len_ic         (L1_block_len_ic),
        .L1_block_len_oc         (L1_block_len_oc),
        .L1_block_len_rs         (L1_block_len_rs),
        .L1_block_len_iwh        (L1_block_len_iwh),
        .L1_block_len_iw         (L1_block_len_iw),
        .L1_block_len_ih         (L1_block_len_ih),
        .L1_pe_array_start       (L1_pe_array_start),
        .L1_total_rs_start       (L1_total_rs_start),
        .L1_total_rs_done        (L1_total_rs_done),
        .L1_use_bias_internal    (L1_use_bias_internal),
        .L1_bias_mode_internal   (L1_bias_mode_internal),
        .L1_use_quan_internal    (L1_use_quan_internal),
        .L1_block_len_iwih_border(L1_block_len_iwih_border)
    );

    assign block_len_ow       = L1_block_len_ow;
    assign block_len_oh       = L1_block_len_oh;
    assign block_len_owh      = L1_block_len_owh;
    assign block_len_ic       = L1_block_len_ic;
    assign block_len_oc       = L1_block_len_oc;
    assign block_len_rs       = L1_block_len_rs;
    assign block_len_iwh      = L1_block_len_iwh;
    assign block_len_iw       = L1_block_len_iw;
    assign block_len_ih       = L1_block_len_ih;
    assign pe_array_start     = L1_pe_array_start;
    assign total_rs_start     = L1_total_rs_start;
    assign total_rs_done      = L1_total_rs_done;
    assign use_bias_internal  = L1_use_bias_internal;
    assign bias_mode_internal = L1_bias_mode_internal;
    assign use_quan_internal  = L1_use_quan_internal;

    /***********************************************************************/
    /*****************************FFT Logic*********************************/
    /***********************************************************************/
    localparam FFT_BUS_DATA_NUM = BUS_WIDTH / WIDTH / 2;
    localparam FFT_CORE_MAX_NUM = 4;

    (* mark_debug = "false"*) wire ffti_rready;
    (* mark_debug = "false"*) wire [FFT_CORE_NUM-1:0] ffti_rvaild;
    (* mark_debug = "false"*) wire [FFT_CORE_NUM-1:0] ffti_rhask;
    (* mark_debug = "false"*)wire [WIDTH*2-1:0] ffti_data[FFT_CORE_NUM-1:0][FFT_CORE_COL-1:0];
    (* mark_debug = "false"*) wire [FFT_CORE_NUM-1:0] ffto_wready;
    (* mark_debug = "false"*) wire [FFT_CORE_NUM-1:0] ffto_wvaild;
    (* mark_debug = "false"*)wire [WIDTH*2-1:0] ffto_data[FFT_CORE_NUM-1:0][FFT_BUS_DATA_NUM-1:0];

    //FFT L1 Control
    (* mark_debug = "false"*) reg [3:0] fft_burst_num;
    (* mark_debug = "false"*) wire [FFT_CORE_NUM-1:0] ffti_done_pulse;
    (* mark_debug = "false"*) wire [FFT_CORE_NUM-1:0] ffto_done_pulse;


    //burst 
    always @(posedge clk) begin
        if (!rstn) begin
            fft_burst_num <= 4'b0;
        end else begin
            fft_burst_num <= 1 << (fft_stage - 9);
        end
    end

    //done
    reg [FFT_CORE_NUM:0] ffti_done_cnt;
    reg [FFT_CORE_NUM:0] ffto_done_cnt;
    reg [FFT_CORE_NUM:0] fft_cul_done;
    always @(posedge clk) begin
        if (!rstn || fft_config) begin
            ffti_done_cnt <= 'b0;
        end else if (fft_start && |ffti_done_pulse) begin
            ffti_done_cnt <= ffti_done_cnt + ffti_done_pulse;
        end else if (&ffti_done_cnt[FFT_CORE_NUM-1:0]) begin
            ffti_done_cnt <= 'b0;
        end
    end
    always @(posedge clk) begin
        if (!rstn || fft_config) begin
            ffto_done_cnt <= 'b0;
        end else if (fft_start && |ffto_done_pulse) begin
            ffto_done_cnt <= ffto_done_cnt + ffto_done_pulse;
        end else if (&ffto_done_cnt[FFT_CORE_NUM-1:0]) begin
            ffto_done_cnt <= 'b0;
        end
    end
    always @(posedge clk) begin
        if (!rstn || !fft_start) begin
            fft_cul_done <= 1'b0;
        end else if (&ffto_done_cnt[FFT_CORE_NUM-1:0]) begin
            fft_cul_done <= 1'b1;
        end
    end
    assign fft_done_intr = &ffto_done_cnt[FFT_CORE_NUM-1:0];
    assign fft_done = fft_cul_done;


    //FFT CORE
    fft_core #(
        .WIDTH(WIDTH),
        .BUS_WIDTH(BUS_WIDTH),
        .FFT_STAGE_WIDTH(FFT_STAGE_WIDTH),
        .FFT_MAX_POINT(FFT_MAX_POINT),
        .FFT_CORE_COL(FFT_CORE_COL),
        .FFT_CORE_ROW(FFT_CORE_ROW),
        .FFT_CORE_NUM(FFT_CORE_NUM),
        .FFT_CORE_MAX_NUM(FFT_CORE_MAX_NUM),
        .ALU_WIDTH(ODATA_WIDTH),
        .ALU_PARALLEL(FFT_BUTTER_COL_NUM)
    ) u_fft_core (
        .clk (clk),
        .rstn(rstn),

        .fft_start(fft_start),
        .fft_stage(fft_stage),

        .bus_i_data (ffti_data),
        .bus_i_vaild(ffti_rvaild),
        .bus_i_hask (ffti_rhask),
        .bus_i_ready(ffti_rready),
        .bus_o_ready(ffto_wready),
        .bus_o_vaild(ffto_wvaild),
        .bus_o_data (ffto_data),

        //alu
        .fft_out1_r(fft_out1_r),
        .fft_out1_i(fft_out1_i),
        .fft_out2_r(fft_out2_r),
        .fft_out2_i(fft_out2_i),
        .fft_out_valid(fft_out_valid),
        .fft_in_valid(fft_in_valid),
        .X2r(X2r),
        .X2i(X2i),
        .Wr(Wr),
        .Wi(Wi),
        .X1r(X1r),
        .X1i(X1i)
    );


    //FFT DMA
    (* mark_debug = "false"*) wire fft_r_addr_ready[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire fft_r_addr_valid[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire [BUS_ADDR_WIDTH-1:0] fft_r_offset_addr[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire [8-1:0] fft_r_burst_len[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire fft_r_data_ready[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire [BUS_WIDTH-1:0] fft_r_data[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire fft_r_data_valid[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire fft_r_data_rlast[FFT_CORE_MAX_NUM-1:0];

    (* mark_debug = "false"*) wire fft_w_addr_ready[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire fft_w_addr_valid[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire [BUS_ADDR_WIDTH-1:0] fft_w_offset_addr[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire [8-1:0] fft_w_burst_len[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire fft_w_data_ready[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire [BUS_WIDTH-1:0] fft_w_data[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire fft_w_data_valid[FFT_CORE_MAX_NUM-1:0];
    (* mark_debug = "false"*) wire fft_w_data_wlast[FFT_CORE_MAX_NUM-1:0];

    assign fft_r_addr_ready[0] = imap_m_axi_arready;
    assign fft_w_addr_ready[0] = imap_m_axi_awready;
    assign fft_w_data_ready[0] = imap_m_axi_wready;
    assign fft_r_data_rlast[0] = imap_m_axi_rlast;

    assign fft_r_addr_ready[1] = weight_m_axi_arready;
    assign fft_w_addr_ready[1] = weight_m_axi_awready;
    assign fft_w_data_ready[1] = weight_m_axi_wready;
    assign fft_r_data_rlast[1] = weight_m_axi_rlast;

    assign fft_r_addr_ready[2] = bias2_m_axi_arready;
    assign fft_w_addr_ready[2] = bias2_m_axi_awready;
    assign fft_w_data_ready[2] = bias2_m_axi_wready;
    assign fft_r_data_rlast[2] = bias2_m_axi_rlast;

    assign fft_r_addr_ready[3] = omap_m_axi_arready;
    assign fft_w_addr_ready[3] = omap_m_axi_awready;
    assign fft_w_data_ready[3] = omap_m_axi_wready;
    assign fft_r_data_rlast[3] = omap_m_axi_rlast;


    generate
        for (genvar m = 0; m < FFT_CORE_NUM; m = m + 1) begin : FFTI_DMA
            dma_ffti #(
                .DATA_WIDTH(WIDTH * 2),
                .BUS_WIDTH(BUS_WIDTH),
                .BUS_ADDR_WIDTH(BUS_ADDR_WIDTH),
                .FFT_SIGNLEN_WIDTH(FFT_SIGNLEN_WIDTH),
                .FFT_CORE_COL(FFT_CORE_COL),
                .FFT_CORE_NUM(FFT_CORE_NUM)
            ) u_dma_ffti (
                .clk(clk),
                .rstn(rstn),
                .is_fft(is_fft),
                .fft_config(fft_config),
                .fft_start(fft_start),
                .is_ifft_mode(is_ifft_mode),
                .burst_num(fft_burst_num),
                .fft_sign_len(fft_sign_len),
                .ffti_done_pulse(ffti_done_pulse[m]),

                .r_addr_ready (fft_r_addr_ready[m]),
                .r_addr_valid (fft_r_addr_valid[m]),
                .r_offset_addr(fft_r_offset_addr[m]),
                .r_burst_len  (fft_r_burst_len[m]),

                .r_data_ready(fft_r_data_ready[m]),
                .r_data(fft_r_data[m]),
                .r_data_valid(fft_r_data_valid[m]),
                .r_data_rlast(fft_r_data_rlast[m]),

                .ffti_rready(ffti_rready),
                .ffti_rvaild(ffti_rvaild[m]),
                .ffti_rhask (ffti_rhask[m]),
                .ffti_data  (ffti_data[m])
            );
        end
    endgenerate

    generate
        for (genvar m = 0; m < FFT_CORE_NUM; m = m + 1) begin : FFTO_DMA
            dma_ffto #(
                .DATA_WIDTH(WIDTH * 2),
                .BUS_WIDTH(BUS_WIDTH),
                .BUS_ADDR_WIDTH(BUS_ADDR_WIDTH),
                .FFT_SIGNLEN_WIDTH(FFT_SIGNLEN_WIDTH),
                .FFT_CORE_COL(FFT_CORE_COL),
                .FFT_CORE_NUM(FFT_CORE_NUM)
            ) u_dma_ffto (
                .clk(clk),
                .rstn(rstn),
                .is_fft(is_fft),
                .fft_config(fft_config),
                .fft_start(fft_start),
                .burst_num(fft_burst_num),
                .fft_sign_len(fft_sign_len),
                .ffto_done_pulse(ffto_done_pulse[m]),

                .w_addr_ready (fft_w_addr_ready[m]),
                .w_addr_valid (fft_w_addr_valid[m]),
                .w_offset_addr(fft_w_offset_addr[m]),
                .w_burst_len  (fft_w_burst_len[m]),

                .w_data_ready(fft_w_data_ready[m]),
                .w_data(fft_w_data[m]),
                .w_data_valid(fft_w_data_valid[m]),
                .w_data_wlast(fft_w_data_wlast[m]),

                .ffto_wready(ffto_wready[m]),
                .ffto_wvaild(ffto_wvaild[m]),
                .ffto_data  (ffto_data[m])
            );
        end
    endgenerate


    //AXI 0
    // assign imap_axi_init_wtx_pulse      = is_fft ? fft_w_addr_valid[0] : 0;
    // assign imap_axi_w_burst_len         = is_fft ? fft_w_burst_len[0] : 0;
    // assign imap_axi_w_offset_addr       = is_fft ? fft_w_offset_addr[0] : 0;
    // assign imap_axi_write_data_ready    = 0;
    // assign imap_axi_w_data              = is_fft ? fft_w_data[0] : 0;
    // assign imap_axi_w_data_valid        = is_fft ? fft_w_data_valid[0] : 0;
    // assign imap_write_data_tx_wlast     = is_fft ? fft_w_data_wlast[0] : 0;
    assign imap_axi_init_wtx_pulse      = fft_w_addr_valid[0];
    assign imap_axi_w_burst_len         = fft_w_burst_len[0];
    assign imap_axi_w_offset_addr       = fft_w_offset_addr[0];
    assign imap_axi_write_data_ready    = 0;
    assign imap_axi_w_data              = fft_w_data[0];
    assign imap_axi_w_data_valid        = fft_w_data_valid[0];
    assign imap_write_data_tx_wlast     = fft_w_data_wlast[0];

    assign imap_axi_init_rtx_pulse      = is_fft ? fft_r_addr_valid[0] : init_imap_rtx_pulse;
    assign imap_axi_r_burst_len         = is_fft ? fft_r_burst_len[0] : imap_load_burst_len;
    assign imap_axi_r_offset_addr       = is_fft ? fft_r_offset_addr[0] : imap_offset_addr;
    assign imap_axi_dma_rready          = is_fft ? fft_r_data_ready[0] : dma_imap_rready;
    assign imap_din_valid               = imap_axi_r_data_valid & (!is_fft);
    assign imap_din_data                = imap_axi_r_data;
    assign fft_r_data_valid[0]          = imap_axi_r_data_valid & is_fft;
    assign fft_r_data[0]                = imap_axi_r_data;

    //AXI 1
    // assign weight_axi_init_wtx_pulse    = is_fft ? fft_w_addr_valid[1] : 0;
    // assign weight_axi_w_burst_len       = is_fft ? fft_w_burst_len[1] : 0;
    // assign weight_axi_w_offset_addr     = is_fft ? fft_w_offset_addr[1] : 0;
    // assign weight_axi_write_data_ready  = 0;
    // assign weight_axi_w_data            = is_fft ? fft_w_data[1] : 0;
    // assign weight_axi_w_data_valid      = is_fft ? fft_w_data_valid[1] : 0;
    // assign weight_write_data_tx_wlast   = is_fft ? fft_w_data_wlast[1] : 0;
    assign weight_axi_init_wtx_pulse    = 0;
    assign weight_axi_w_burst_len       = 0;
    assign weight_axi_w_offset_addr     = 0;
    assign weight_axi_write_data_ready  = 0;
    assign weight_axi_w_data            = 0;
    assign weight_axi_w_data_valid      = 0;
    assign weight_write_data_tx_wlast   = 0;

    assign weight_axi_init_rtx_pulse    = is_fft ? fft_r_addr_valid[1] : init_weight_rtx_pulse;
    assign weight_axi_r_burst_len       = is_fft ? fft_r_burst_len[1] : weight_load_burst_len;
    assign weight_axi_r_offset_addr     = is_fft ? fft_r_offset_addr[1] : weight_offset_addr;
    assign weight_axi_dma_rready        = is_fft ? fft_r_data_ready[1] : dma_weight_rready;
    assign weight_din_valid             = weight_axi_r_data_valid & (!is_fft);
    assign weight_din_data              = weight_axi_r_data;
    assign fft_r_data_valid[1]          = weight_axi_r_data_valid & is_fft;
    assign fft_r_data[1]                = weight_axi_r_data;

    //AXI 2
    // assign bias2_axi_init_wtx_pulse     = is_fft ? fft_w_addr_valid[2] : 0;
    // assign bias2_axi_w_burst_len        = is_fft ? fft_w_burst_len[2] : 0;
    // assign bias2_axi_w_offset_addr      = is_fft ? fft_w_offset_addr[2] : 0;
    // assign bias2_axi_write_data_ready   = 0;
    // assign bias2_axi_w_data             = is_fft ? fft_w_data[2] : 0;
    // assign bias2_axi_w_data_valid       = is_fft ? fft_w_data_valid[2] : 0;
    // assign bias2_write_data_tx_wlast    = is_fft ? fft_w_data_wlast[2] : 0;
    assign bias2_axi_init_wtx_pulse     = 0;
    assign bias2_axi_w_burst_len        = 0;
    assign bias2_axi_w_offset_addr      = 0;
    assign bias2_axi_write_data_ready   = 0;
    assign bias2_axi_w_data             = 0;
    assign bias2_axi_w_data_valid       = 0;
    assign bias2_write_data_tx_wlast    = 0;

    assign bias2_axi_init_rtx_pulse     = is_fft ? fft_r_addr_valid[2] : init_bias2_rtx_pulse;
    assign bias2_axi_r_burst_len        = is_fft ? fft_r_burst_len[2] : bias2_load_burst_len;
    assign bias2_axi_r_offset_addr      = is_fft ? fft_r_offset_addr[2] : bias2_offset_addr;
    assign bias2_axi_dma_rready         = is_fft ? fft_r_data_ready[2] : dma_bias2_rready;
    assign bias2_din_valid              = bias2_axi_r_data_valid & (!is_fft);
    assign bias2_din_data               = bias2_axi_r_data;
    assign fft_r_data_valid[2]          = bias2_axi_r_data_valid & is_fft;
    assign fft_r_data[2]                = bias2_axi_r_data;

    //AXI 3
    assign omap_axi_init_wtx_pulse      = is_fft ? fft_w_addr_valid[3] : init_omap_wtx_pulse;
    assign omap_axi_w_burst_len         = is_fft ? fft_w_burst_len[3] : omap_write_burst_len;
    assign omap_axi_w_offset_addr       = is_fft ? fft_w_offset_addr[3] : omap_offset_addr;
    assign omap_axi_write_data_ready    = 0;
    assign omap_axi_w_data              = is_fft ? fft_w_data[3] : omap_dout_data;
    assign omap_axi_w_data_valid        = is_fft ? fft_w_data_valid[3] : omap_dout_valid;
    assign omap_axi_write_data_tx_wlast = is_fft ? fft_w_data_wlast[3] : dma_omap_wlast;

    assign bias_axi_init_rtx_pulse      = is_fft ? fft_r_addr_valid[3] : init_bias_rtx_pulse;
    assign bias_axi_r_burst_len         = is_fft ? fft_r_burst_len[3] : bias_load_burst_len;
    assign bias_axi_r_offset_addr       = is_fft ? fft_r_offset_addr[3] : bias_offset_addr;
    assign bias_axi_dma_rready          = is_fft ? fft_r_data_ready[3] : dma_bias_rready;
    assign bias_din_valid               = bias_axi_r_data_valid & (!is_fft);
    assign bias_din_data                = bias_axi_r_data;
    assign fft_r_data_valid[3]          = bias_axi_r_data_valid & is_fft;
    assign fft_r_data[3]                = bias_axi_r_data;



endmodule
