




`define INPUT_UNSIGNED

`timescale 1ns / 1ps
`define read_2d_array_from_file(file_path, index1, index2, data) \
    fid = $fopen(file_path, "r"); \
    if (fid) begin \
        for (i = 0; i < index1; i++) begin \
        for (j = 0; j < index2; j++) begin \
            $fscanf(fid, "%d", data[i][j]); \
        //   $display("mat_data_in[%0d][%0d] is: %d", i, j, data[i][j]); \
        end \
        end \
        $fclose(fid); \
    end \
    else begin \
        $error("Failed to open file: %s", file_path); \
    end 

(* DONT_TOUCH = "yes" *)
module model9_cv2_conv_ai_acce_tb;

    reg clk;
    reg rstn;


    // initial begin
    //     $dumpfile("model9_cv2_conv_ai_acce_tb.vcd");
    //     $dumpvars(0, model9_cv2_conv_ai_acce_tb);
    // end

    localparam T = 10;  //100MHz
    //generate 100MHz clock
    initial begin
        clk = 0;
        forever clk = #(T / 2) ~clk;
    end
    //reset for the first half cycle
    initial begin
        rstn = 0;
        #(T * 1.6) rstn = 1;
    end
    localparam END_TIME = 100000;
    reg finish_flag;
    initial begin
        // #(T * (END_TIME)) $finish;
        wait (finish_flag);
        #(T * (100)) $finish;
    end


    parameter WIDTH = 16;
    parameter GEMM_MAC_ROW_NUM = 16;
    parameter GEMM_MAC_COL_NUM = 16;
    parameter DUAL_MAC_ROW_NUM = GEMM_MAC_ROW_NUM / 2;
    parameter DUAL_MAC_COL_NUM = GEMM_MAC_COL_NUM / 2;
    parameter FFT_BUTTER_ROW_NUM = 4;
    parameter FFT_BUTTER_COL_NUM = DUAL_MAC_ROW_NUM * DUAL_MAC_COL_NUM / FFT_BUTTER_ROW_NUM;
    parameter INPUTS_NUM = DUAL_MAC_ROW_NUM;
    parameter OUTPUT_NUM = DUAL_MAC_ROW_NUM * 2;
    parameter STAGES_NUM = $clog2(DUAL_MAC_ROW_NUM);
    parameter ODATA_WIDTH = WIDTH * 2 + 2 + STAGES_NUM * 2;
    parameter SEL_WIDTH = $clog2(GEMM_MAC_ROW_NUM);
    parameter MULT_DELAY = 1;
    parameter ADD_DELAY = 1;
    parameter READ_ADDR_GEN_DELAY = 3;
    parameter WRITE_ADDR_GEN_DELAY = 2;
    parameter READ_ADDR_TO_DATA_OUT_DELAY = 2;
    parameter READ_DELAY_N = READ_ADDR_GEN_DELAY + READ_ADDR_TO_DATA_OUT_DELAY - 1;
    // parameter CAL_DELAY_M = $clog2(GEMM_MAC_ROW_NUM) + 2;
    // parameter CAL_DELAY_M = 1;
    // parameter CAL_DELAY_M = 2;
    parameter NUM_DELAY_HEADS = 3;  // å»¶è¿Ÿå¤´çš„æ•°é‡�
    parameter int CAL_DELAY_STC = $clog2(GEMM_MAC_ROW_NUM) + 2;
    parameter int CAL_DELAY_DWC = 2;
    parameter int CAL_DELAY_POOL = 1;
    parameter int MAX_CAL_DELAY_M = CAL_DELAY_STC;

    parameter QUAN_DELAY_Q = 5;
    parameter MAX_BLOCK_DIM = 256;
    parameter DIM_WIDTH = $clog2(MAX_BLOCK_DIM);
    parameter IMAP_DIM_WIDTH = DIM_WIDTH + 2;
    parameter IMAP_RAM_DEPTH = 2 ** 11;
    parameter WEIGHT_RAM_DEPTH = 2 ** 11;
    parameter BIAS_RAM_DEPTH = 2 ** 11;
    parameter BIAS2_RAM_DEPTH = 2 ** 11;
    parameter OMAP_RAM_DEPTH = 2 ** 11;
    parameter IMAP_RAM_ADDR_WIDTH = $clog2(IMAP_RAM_DEPTH);
    parameter WEIGHT_RAM_ADDR_WIDTH = $clog2(WEIGHT_RAM_DEPTH);
    parameter BIAS_RAM_ADDR_WIDTH = $clog2(BIAS_RAM_DEPTH);
    parameter BIAS2_RAM_ADDR_WIDTH = $clog2(BIAS2_RAM_DEPTH);
    parameter OMAP_RAM_ADDR_WIDTH = $clog2(OMAP_RAM_DEPTH);

    parameter MAX_STRIDE_X = 3;
    parameter MAX_STRIDE_Y = 3;
    parameter MAX_DILATION_X = 3;
    parameter MAX_DILATION_Y = 3;
    parameter MAX_WIN_R = 9;
    parameter MAX_WIN_S = 9;
    parameter STRIDE_X_WIDTH = $clog2(MAX_STRIDE_X + 1);
    parameter STRIDE_Y_WIDTH = $clog2(MAX_STRIDE_Y + 1);
    parameter DILATION_X_WIDTH = $clog2(MAX_DILATION_X + 1);
    parameter DILATION_Y_WIDTH = $clog2(MAX_DILATION_Y + 1);
    parameter WIN_R_WIDTH = $clog2(MAX_WIN_R);
    parameter WIN_S_WIDTH = $clog2(MAX_WIN_S);
    parameter CHANNEL_NUM = GEMM_MAC_COL_NUM;
    parameter ACC_WIDTH = ODATA_WIDTH + 4;
    parameter FIFO_ACC_DEPTH = 2 ** 10;
    parameter FIFO_ACC_ADDR_WIDTH = $clog2(FIFO_ACC_DEPTH);
    parameter QUAN_IN_WIDTH = ACC_WIDTH;
    parameter QUAN_OUT_WIDTH = 16;
    parameter SCALE_WIDTH = 16;
    parameter SHIFT_WIDTH = 4;
    parameter ZERO_POINT_WIDTH = 16;
    parameter BUS_WIDTH = 64;
    parameter BUS_ADDR_WIDTH = 32;
    parameter MAX_NUM_DIM = 256;
    parameter NUM_WIDTH = $clog2(MAX_NUM_DIM);
    parameter IMAP_WIDTH = WIDTH;
    parameter PADDING_WIDTH = 5;
    parameter AIWIH_WIDTH = 20;  // æœ?å¤§è¾“å…¥é?šé�“*å®½åº¦
    parameter AIW_WIDTH = 11;  //æœ?å¤§è¾“å…¥é?šé�“2048
    parameter WEIGHT_WIDTH = WIDTH;
    parameter WICRS_WIDTH = 22;
    parameter WIC_WIDTH = 11;
    parameter OMAP_WIDTH = 16;
    parameter OMAP_RAM_WIDTH = ACC_WIDTH;
    parameter AOWOH_WIDTH = 20;
    parameter AOW_WIDTH = 11;
    parameter BIAS_WIDTH = 32;

    parameter BIAS2_WIDTH = 16;
    parameter BIAS2_RAM_WIDTH = 16;
    parameter BIAS2_SCALE_WIDTH = 16;
    parameter BIAS2_SHIFT_WIDTH = 4;
    parameter C_M_AXI_BURST_LEN = 256;
    parameter C_M_AXI_ID_WIDTH = 2;
    parameter C_M_AXI_ADDR_WIDTH = BUS_ADDR_WIDTH;
    parameter C_M_AXI_DATA_WIDTH = BUS_WIDTH;
    parameter C_M_AXI_AWUSER_WIDTH = 1;
    parameter C_M_AXI_ARUSER_WIDTH = 1;
    parameter C_M_AXI_WUSER_WIDTH = 1;
    parameter C_M_AXI_RUSER_WIDTH = 1;
    parameter C_M_AXI_BUSER_WIDTH = 1;

    // ai_acce Inputs
    wire imap_m_axi_aclk;
    wire imap_m_axi_aresetn;
    wire weight_m_axi_aclk;
    wire weight_m_axi_aresetn;
    wire bias2_m_axi_aclk;
    wire bias2_m_axi_aresetn;
    wire omap_m_axi_aclk;
    wire omap_m_axi_aresetn;

    assign imap_m_axi_aclk = clk;
    assign weight_m_axi_aclk = clk;
    assign bias2_m_axi_aclk = clk;
    assign omap_m_axi_aclk = clk;

    assign imap_m_axi_aresetn = rstn;
    assign weight_m_axi_aresetn = rstn;
    assign bias2_m_axi_aresetn = rstn;
    assign omap_m_axi_aresetn = rstn;

    reg                                     imap_m_axi_awready;
    reg                                     imap_m_axi_wready;
    reg        [    C_M_AXI_ID_WIDTH-1 : 0] imap_m_axi_bid;
    reg        [                     1 : 0] imap_m_axi_bresp;
    reg        [ C_M_AXI_BUSER_WIDTH-1 : 0] imap_m_axi_buser;
    reg                                     imap_m_axi_bvalid;
    reg                                     imap_m_axi_arready;
    reg        [    C_M_AXI_ID_WIDTH-1 : 0] imap_m_axi_rid;
    reg        [  C_M_AXI_DATA_WIDTH-1 : 0] imap_m_axi_rdata;
    reg        [                     1 : 0] imap_m_axi_rresp;
    reg                                     imap_m_axi_rlast;
    reg        [ C_M_AXI_RUSER_WIDTH-1 : 0] imap_m_axi_ruser;
    reg                                     imap_m_axi_rvalid;
    reg                                     weight_m_axi_awready;
    reg                                     weight_m_axi_wready;
    reg        [    C_M_AXI_ID_WIDTH-1 : 0] weight_m_axi_bid;
    reg        [                     1 : 0] weight_m_axi_bresp;
    reg        [ C_M_AXI_BUSER_WIDTH-1 : 0] weight_m_axi_buser;
    reg                                     weight_m_axi_bvalid;
    reg                                     weight_m_axi_arready;
    reg        [    C_M_AXI_ID_WIDTH-1 : 0] weight_m_axi_rid;
    reg        [  C_M_AXI_DATA_WIDTH-1 : 0] weight_m_axi_rdata;
    reg        [                     1 : 0] weight_m_axi_rresp;
    reg                                     weight_m_axi_rlast;
    reg        [ C_M_AXI_RUSER_WIDTH-1 : 0] weight_m_axi_ruser;
    reg                                     weight_m_axi_rvalid;

    reg                                     bias2_m_axi_awready;
    reg                                     bias2_m_axi_wready;
    reg        [    C_M_AXI_ID_WIDTH-1 : 0] bias2_m_axi_bid;
    reg        [                     1 : 0] bias2_m_axi_bresp;
    reg        [ C_M_AXI_BUSER_WIDTH-1 : 0] bias2_m_axi_buser;
    reg                                     bias2_m_axi_bvalid;
    reg                                     bias2_m_axi_arready;
    reg        [    C_M_AXI_ID_WIDTH-1 : 0] bias2_m_axi_rid;
    reg        [  C_M_AXI_DATA_WIDTH-1 : 0] bias2_m_axi_rdata;
    reg        [                     1 : 0] bias2_m_axi_rresp;
    reg                                     bias2_m_axi_rlast;
    reg        [ C_M_AXI_RUSER_WIDTH-1 : 0] bias2_m_axi_ruser;
    reg                                     bias2_m_axi_rvalid;
    reg                                     omap_m_axi_awready;
    reg                                     omap_m_axi_wready;
    reg        [    C_M_AXI_ID_WIDTH-1 : 0] omap_m_axi_bid;
    reg        [                     1 : 0] omap_m_axi_bresp;
    reg        [ C_M_AXI_BUSER_WIDTH-1 : 0] omap_m_axi_buser;
    reg                                     omap_m_axi_bvalid;
    reg                                     omap_m_axi_arready;
    reg        [    C_M_AXI_ID_WIDTH-1 : 0] omap_m_axi_rid;
    reg        [  C_M_AXI_DATA_WIDTH-1 : 0] omap_m_axi_rdata;
    reg        [                     1 : 0] omap_m_axi_rresp;
    reg                                     omap_m_axi_rlast;
    reg        [ C_M_AXI_RUSER_WIDTH-1 : 0] omap_m_axi_ruser;
    reg                                     omap_m_axi_rvalid;

    reg                                     is_fft;
    reg                                     is_int16;
    reg                                     is_matmul;
    reg                                     mat_core_start;
    reg                                     relu_enable;
    reg                                     use_quan_external;
    reg                                     use_bias_external;
    reg                                     bias_mode_external;
    reg                                     use_bias2_add_external;
    reg                                     is_pool;
    reg                                     pool_type;
    reg        [                       1:0] conv_type;
    reg        [     BIAS2_SCALE_WIDTH-1:0] bias2_scale;
    reg        [     BIAS2_SHIFT_WIDTH-1:0] bias2_shift;
    reg signed [      ZERO_POINT_WIDTH-1:0] zero_point_in;
    reg signed [      ZERO_POINT_WIDTH-1:0] zero_point_out;
    reg        [           SCALE_WIDTH-1:0] scale;
    reg        [           SHIFT_WIDTH-1:0] shift;
    reg        [             NUM_WIDTH-1:0] num_ow;
    reg        [             NUM_WIDTH-1:0] num_oh;
    reg        [             NUM_WIDTH-1:0] num_oc;
    reg        [             NUM_WIDTH-1:0] num_ic;
    reg        [             NUM_WIDTH-1:0] num_rs;
    reg        [           WIN_R_WIDTH-1:0] total_len_r;
    reg        [           WIN_S_WIDTH-1:0] total_len_s;
    reg        [        STRIDE_X_WIDTH-1:0] stride_x;
    reg        [        STRIDE_Y_WIDTH-1:0] stride_y;
    reg        [      DILATION_X_WIDTH-1:0] dilation_x;
    reg        [      DILATION_Y_WIDTH-1:0] dilation_y;
    reg        [             DIM_WIDTH-1:0] basic_oc;
    reg        [             DIM_WIDTH-1:0] basic_ic;
    reg        [             DIM_WIDTH-1:0] basic_rs;
    reg        [             DIM_WIDTH-1:0] basic_ow;
    reg        [             DIM_WIDTH-1:0] basic_oh;
    reg        [        IMAP_DIM_WIDTH-1:0] basic_ow_sx;
    reg        [        IMAP_DIM_WIDTH-1:0] basic_oh_sy;
    reg        [        IMAP_DIM_WIDTH-1:0] basic_iw;
    reg        [        IMAP_DIM_WIDTH-1:0] basic_ih;
    reg        [             DIM_WIDTH-1:0] remain_oc;
    reg        [             DIM_WIDTH-1:0] remain_ic;
    reg        [             DIM_WIDTH-1:0] remain_rs;
    reg        [             DIM_WIDTH-1:0] remain_ow;
    reg        [             DIM_WIDTH-1:0] remain_oh;
    reg        [        IMAP_DIM_WIDTH-1:0] remain_iw;
    reg        [        IMAP_DIM_WIDTH-1:0] remain_ih;
    reg        [  C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_R_BASE_ADDR;
    reg        [  C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_R_BASE_ADDR;
    reg        [  C_M_AXI_ADDR_WIDTH-1 : 0] omap_axi_W_BASE_ADDR;
    reg        [  C_M_AXI_ADDR_WIDTH-1 : 0] bias_axi_R_BASE_ADDR;
    reg        [  C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_R_BASE_ADDR;
    reg        [         PADDING_WIDTH-1:0] padding_external       [3:0];
    wire       [           AIWIH_WIDTH-1:0] Aiwih;
    wire       [             AIW_WIDTH-1:0] Aiw;
    wire       [           WICRS_WIDTH-1:0] Wicrs;
    wire       [             WIC_WIDTH-1:0] Wic;
    wire       [           AOWOH_WIDTH-1:0] Aowoh;
    wire       [             AOW_WIDTH-1:0] Aow;

    // ai_acce Outputs
    wire       [    C_M_AXI_ID_WIDTH-1 : 0] imap_m_axi_awid;
    wire       [  C_M_AXI_ADDR_WIDTH-1 : 0] imap_m_axi_awaddr;
    wire       [                     7 : 0] imap_m_axi_awlen;
    wire       [                     2 : 0] imap_m_axi_awsize;
    wire       [                     1 : 0] imap_m_axi_awburst;
    wire                                    imap_m_axi_awlock;
    wire       [                     3 : 0] imap_m_axi_awcache;
    wire       [                     2 : 0] imap_m_axi_awprot;
    wire       [                     3 : 0] imap_m_axi_awqos;
    wire       [C_M_AXI_AWUSER_WIDTH-1 : 0] imap_m_axi_awuser;
    wire                                    imap_m_axi_awvalid;
    wire       [  C_M_AXI_DATA_WIDTH-1 : 0] imap_m_axi_wdata;
    wire       [C_M_AXI_DATA_WIDTH/8-1 : 0] imap_m_axi_wstrb;
    wire                                    imap_m_axi_wlast;
    wire       [ C_M_AXI_WUSER_WIDTH-1 : 0] imap_m_axi_wuser;
    wire                                    imap_m_axi_wvalid;
    wire                                    imap_m_axi_bready;
    wire       [    C_M_AXI_ID_WIDTH-1 : 0] imap_m_axi_arid;
    wire       [  C_M_AXI_ADDR_WIDTH-1 : 0] imap_m_axi_araddr;
    wire       [                     7 : 0] imap_m_axi_arlen;
    wire       [                     2 : 0] imap_m_axi_arsize;
    wire       [                     1 : 0] imap_m_axi_arburst;
    wire                                    imap_m_axi_arlock;
    wire       [                     3 : 0] imap_m_axi_arcache;
    wire       [                     2 : 0] imap_m_axi_arprot;
    wire       [                     3 : 0] imap_m_axi_arqos;
    wire       [C_M_AXI_ARUSER_WIDTH-1 : 0] imap_m_axi_aruser;
    wire                                    imap_m_axi_arvalid;
    wire                                    imap_m_axi_rready;
    wire       [    C_M_AXI_ID_WIDTH-1 : 0] weight_m_axi_awid;
    wire       [  C_M_AXI_ADDR_WIDTH-1 : 0] weight_m_axi_awaddr;
    wire       [                     7 : 0] weight_m_axi_awlen;
    wire       [                     2 : 0] weight_m_axi_awsize;
    wire       [                     1 : 0] weight_m_axi_awburst;
    wire                                    weight_m_axi_awlock;
    wire       [                     3 : 0] weight_m_axi_awcache;
    wire       [                     2 : 0] weight_m_axi_awprot;
    wire       [                     3 : 0] weight_m_axi_awqos;
    wire       [C_M_AXI_AWUSER_WIDTH-1 : 0] weight_m_axi_awuser;
    wire                                    weight_m_axi_awvalid;
    wire       [  C_M_AXI_DATA_WIDTH-1 : 0] weight_m_axi_wdata;
    wire       [C_M_AXI_DATA_WIDTH/8-1 : 0] weight_m_axi_wstrb;
    wire                                    weight_m_axi_wlast;
    wire       [ C_M_AXI_WUSER_WIDTH-1 : 0] weight_m_axi_wuser;
    wire                                    weight_m_axi_wvalid;
    wire                                    weight_m_axi_bready;
    wire       [    C_M_AXI_ID_WIDTH-1 : 0] weight_m_axi_arid;
    wire       [  C_M_AXI_ADDR_WIDTH-1 : 0] weight_m_axi_araddr;
    wire       [                     7 : 0] weight_m_axi_arlen;
    wire       [                     2 : 0] weight_m_axi_arsize;
    wire       [                     1 : 0] weight_m_axi_arburst;
    wire                                    weight_m_axi_arlock;
    wire       [                     3 : 0] weight_m_axi_arcache;
    wire       [                     2 : 0] weight_m_axi_arprot;
    wire       [                     3 : 0] weight_m_axi_arqos;
    wire       [C_M_AXI_ARUSER_WIDTH-1 : 0] weight_m_axi_aruser;
    wire                                    weight_m_axi_arvalid;
    wire                                    weight_m_axi_rready;

    wire       [    C_M_AXI_ID_WIDTH-1 : 0] bias2_m_axi_awid;
    wire       [  C_M_AXI_ADDR_WIDTH-1 : 0] bias2_m_axi_awaddr;
    wire       [                     7 : 0] bias2_m_axi_awlen;
    wire       [                     2 : 0] bias2_m_axi_awsize;
    wire       [                     1 : 0] bias2_m_axi_awburst;
    wire                                    bias2_m_axi_awlock;
    wire       [                     3 : 0] bias2_m_axi_awcache;
    wire       [                     2 : 0] bias2_m_axi_awprot;
    wire       [                     3 : 0] bias2_m_axi_awqos;
    wire       [C_M_AXI_AWUSER_WIDTH-1 : 0] bias2_m_axi_awuser;
    wire                                    bias2_m_axi_awvalid;
    wire       [  C_M_AXI_DATA_WIDTH-1 : 0] bias2_m_axi_wdata;
    wire       [C_M_AXI_DATA_WIDTH/8-1 : 0] bias2_m_axi_wstrb;
    wire                                    bias2_m_axi_wlast;
    wire       [ C_M_AXI_WUSER_WIDTH-1 : 0] bias2_m_axi_wuser;
    wire                                    bias2_m_axi_wvalid;
    wire                                    bias2_m_axi_bready;
    wire       [    C_M_AXI_ID_WIDTH-1 : 0] bias2_m_axi_arid;
    wire       [  C_M_AXI_ADDR_WIDTH-1 : 0] bias2_m_axi_araddr;
    wire       [                     7 : 0] bias2_m_axi_arlen;
    wire       [                     2 : 0] bias2_m_axi_arsize;
    wire       [                     1 : 0] bias2_m_axi_arburst;
    wire                                    bias2_m_axi_arlock;
    wire       [                     3 : 0] bias2_m_axi_arcache;
    wire       [                     2 : 0] bias2_m_axi_arprot;
    wire       [                     3 : 0] bias2_m_axi_arqos;
    wire       [C_M_AXI_ARUSER_WIDTH-1 : 0] bias2_m_axi_aruser;
    wire                                    bias2_m_axi_arvalid;
    wire                                    bias2_m_axi_rready;

    wire       [    C_M_AXI_ID_WIDTH-1 : 0] omap_m_axi_awid;
    wire       [  C_M_AXI_ADDR_WIDTH-1 : 0] omap_m_axi_awaddr;
    wire       [                     7 : 0] omap_m_axi_awlen;
    wire       [                     2 : 0] omap_m_axi_awsize;
    wire       [                     1 : 0] omap_m_axi_awburst;
    wire                                    omap_m_axi_awlock;
    wire       [                     3 : 0] omap_m_axi_awcache;
    wire       [                     2 : 0] omap_m_axi_awprot;
    wire       [                     3 : 0] omap_m_axi_awqos;
    wire       [C_M_AXI_AWUSER_WIDTH-1 : 0] omap_m_axi_awuser;
    wire                                    omap_m_axi_awvalid;
    wire       [  C_M_AXI_DATA_WIDTH-1 : 0] omap_m_axi_wdata;
    wire       [C_M_AXI_DATA_WIDTH/8-1 : 0] omap_m_axi_wstrb;
    wire                                    omap_m_axi_wlast;
    wire       [ C_M_AXI_WUSER_WIDTH-1 : 0] omap_m_axi_wuser;
    wire                                    omap_m_axi_wvalid;
    wire                                    omap_m_axi_bready;
    wire       [    C_M_AXI_ID_WIDTH-1 : 0] omap_m_axi_arid;
    wire       [  C_M_AXI_ADDR_WIDTH-1 : 0] omap_m_axi_araddr;
    wire       [                     7 : 0] omap_m_axi_arlen;
    wire       [                     2 : 0] omap_m_axi_arsize;
    wire       [                     1 : 0] omap_m_axi_arburst;
    wire                                    omap_m_axi_arlock;
    wire       [                     3 : 0] omap_m_axi_arcache;
    wire       [                     2 : 0] omap_m_axi_arprot;
    wire       [                     3 : 0] omap_m_axi_arqos;
    wire       [C_M_AXI_ARUSER_WIDTH-1 : 0] omap_m_axi_aruser;
    wire                                    omap_m_axi_arvalid;
    wire                                    omap_m_axi_rready;
    wire                                    layer_done;




    ai_acce_core #(
        .WIDTH                      (WIDTH),
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
        .SEL_WIDTH                  (SEL_WIDTH),
        .MULT_DELAY                 (MULT_DELAY),
        .ADD_DELAY                  (ADD_DELAY),
        .READ_ADDR_GEN_DELAY        (READ_ADDR_GEN_DELAY),
        .WRITE_ADDR_GEN_DELAY       (WRITE_ADDR_GEN_DELAY),
        .READ_ADDR_TO_DATA_OUT_DELAY(READ_ADDR_TO_DATA_OUT_DELAY),
        .READ_DELAY_N               (READ_DELAY_N),
        // .CAL_DELAY_M                (CAL_DELAY_M),
        .NUM_DELAY_HEADS            (NUM_DELAY_HEADS),
        .CAL_DELAY_STC              (CAL_DELAY_STC),
        .CAL_DELAY_DWC              (CAL_DELAY_DWC),
        .CAL_DELAY_POOL             (CAL_DELAY_POOL),
        .MAX_CAL_DELAY_M            (MAX_CAL_DELAY_M),
        .QUAN_DELAY_Q               (QUAN_DELAY_Q),
        .MAX_BLOCK_DIM              (MAX_BLOCK_DIM),
        .DIM_WIDTH                  (DIM_WIDTH),
        .IMAP_DIM_WIDTH             (IMAP_DIM_WIDTH),
        .IMAP_RAM_DEPTH             (IMAP_RAM_DEPTH),
        .WEIGHT_RAM_DEPTH           (WEIGHT_RAM_DEPTH),
        .BIAS_RAM_DEPTH             (BIAS_RAM_DEPTH),
        .OMAP_RAM_DEPTH             (OMAP_RAM_DEPTH),
        .IMAP_RAM_ADDR_WIDTH        (IMAP_RAM_ADDR_WIDTH),
        .WEIGHT_RAM_ADDR_WIDTH      (WEIGHT_RAM_ADDR_WIDTH),
        .BIAS_RAM_ADDR_WIDTH        (BIAS_RAM_ADDR_WIDTH),
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
        .WIN_S_WIDTH                (WIN_S_WIDTH),
        .CHANNEL_NUM                (CHANNEL_NUM),
        .ACC_WIDTH                  (ACC_WIDTH),
        .FIFO_ACC_DEPTH             (FIFO_ACC_DEPTH),
        .FIFO_ACC_ADDR_WIDTH        (FIFO_ACC_ADDR_WIDTH),
        .QUAN_IN_WIDTH              (QUAN_IN_WIDTH),
        .QUAN_OUT_WIDTH             (QUAN_OUT_WIDTH),
        .SCALE_WIDTH                (SCALE_WIDTH),
        .SHIFT_WIDTH                (SHIFT_WIDTH),
        .ZERO_POINT_WIDTH           (ZERO_POINT_WIDTH),
        .BIAS2_WIDTH                (BIAS2_WIDTH),
        .BIAS2_RAM_WIDTH            (BIAS2_RAM_WIDTH),
        .BIAS2_SCALE_WIDTH          (BIAS2_SCALE_WIDTH),
        .BIAS2_SHIFT_WIDTH          (BIAS2_SHIFT_WIDTH),
        .BUS_WIDTH                  (BUS_WIDTH),
        .BUS_ADDR_WIDTH             (BUS_ADDR_WIDTH),
        .MAX_NUM_DIM                (MAX_NUM_DIM),
        .NUM_WIDTH                  (NUM_WIDTH),
        .IMAP_WIDTH                 (IMAP_WIDTH),
        .PADDING_WIDTH              (PADDING_WIDTH),
        .AIWIH_WIDTH                (AIWIH_WIDTH),
        .AIW_WIDTH                  (AIW_WIDTH),
        .WEIGHT_WIDTH               (WEIGHT_WIDTH),
        .WICRS_WIDTH                (WICRS_WIDTH),
        .WIC_WIDTH                  (WIC_WIDTH),
        .OMAP_WIDTH                 (OMAP_WIDTH),
        .OMAP_RAM_WIDTH             (OMAP_RAM_WIDTH),
        .AOWOH_WIDTH                (AOWOH_WIDTH),
        .AOW_WIDTH                  (AOW_WIDTH),
        .BIAS_WIDTH                 (BIAS_WIDTH),
        .C_M_AXI_BURST_LEN          (C_M_AXI_BURST_LEN),
        .C_M_AXI_ID_WIDTH           (C_M_AXI_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH         (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH         (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH       (C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH       (C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH        (C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH        (C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH        (C_M_AXI_BUSER_WIDTH)
    ) u_ai_acce (
        .imap_m_axi_awready  (imap_m_axi_awready),
        .imap_m_axi_wready   (imap_m_axi_wready),
        .imap_m_axi_bid      (imap_m_axi_bid),
        .imap_m_axi_bresp    (imap_m_axi_bresp),
        .imap_m_axi_buser    (imap_m_axi_buser),
        .imap_m_axi_bvalid   (imap_m_axi_bvalid),
        .imap_m_axi_arready  (imap_m_axi_arready),
        .imap_m_axi_rid      (imap_m_axi_rid),
        .imap_m_axi_rdata    (imap_m_axi_rdata),
        .imap_m_axi_rresp    (imap_m_axi_rresp),
        .imap_m_axi_rlast    (imap_m_axi_rlast),
        .imap_m_axi_ruser    (imap_m_axi_ruser),
        .imap_m_axi_rvalid   (imap_m_axi_rvalid),
        .weight_m_axi_awready(weight_m_axi_awready),
        .weight_m_axi_wready (weight_m_axi_wready),
        .weight_m_axi_bid    (weight_m_axi_bid),
        .weight_m_axi_bresp  (weight_m_axi_bresp),
        .weight_m_axi_buser  (weight_m_axi_buser),
        .weight_m_axi_bvalid (weight_m_axi_bvalid),
        .weight_m_axi_arready(weight_m_axi_arready),
        .weight_m_axi_rid    (weight_m_axi_rid),
        .weight_m_axi_rdata  (weight_m_axi_rdata),
        .weight_m_axi_rresp  (weight_m_axi_rresp),
        .weight_m_axi_rlast  (weight_m_axi_rlast),
        .weight_m_axi_ruser  (weight_m_axi_ruser),
        .weight_m_axi_rvalid (weight_m_axi_rvalid),

        .bias2_m_axi_awready(bias2_m_axi_awready),
        .bias2_m_axi_wready (bias2_m_axi_wready),
        .bias2_m_axi_bid    (bias2_m_axi_bid),
        .bias2_m_axi_bresp  (bias2_m_axi_bresp),
        .bias2_m_axi_buser  (bias2_m_axi_buser),
        .bias2_m_axi_bvalid (bias2_m_axi_bvalid),
        .bias2_m_axi_arready(bias2_m_axi_arready),
        .bias2_m_axi_rid    (bias2_m_axi_rid),
        .bias2_m_axi_rdata  (bias2_m_axi_rdata),
        .bias2_m_axi_rresp  (bias2_m_axi_rresp),
        .bias2_m_axi_rlast  (bias2_m_axi_rlast),
        .bias2_m_axi_ruser  (bias2_m_axi_ruser),
        .bias2_m_axi_rvalid (bias2_m_axi_rvalid),

        .omap_m_axi_awready(omap_m_axi_awready),
        .omap_m_axi_wready (omap_m_axi_wready),
        .omap_m_axi_bid    (omap_m_axi_bid),
        .omap_m_axi_bresp  (omap_m_axi_bresp),
        .omap_m_axi_buser  (omap_m_axi_buser),
        .omap_m_axi_bvalid (omap_m_axi_bvalid),
        .omap_m_axi_arready(omap_m_axi_arready),
        .omap_m_axi_rid    (omap_m_axi_rid),
        .omap_m_axi_rdata  (omap_m_axi_rdata),
        .omap_m_axi_rresp  (omap_m_axi_rresp),
        .omap_m_axi_rlast  (omap_m_axi_rlast),
        .omap_m_axi_ruser  (omap_m_axi_ruser),
        .omap_m_axi_rvalid (omap_m_axi_rvalid),

        .clk                   (clk),
        .rstn                  (rstn),
        .is_fft                (is_fft),
        .is_int16              (is_int16),
        .mat_core_start        (mat_core_start),
        .relu_enable           (relu_enable),
        .use_quan_external     (use_quan_external),
        .use_bias_external     (use_bias_external),
        .bias_mode_external    (bias_mode_external),
        .use_bias2_add_external(use_bias2_add_external),
        .is_pool               (is_pool),
        .pool_type             (pool_type),
        .conv_type             (conv_type),
        .bias2_scale           (bias2_scale),
        .bias2_shift           (bias2_shift),
        .zero_point_in         (zero_point_in),
        .zero_point_out        (zero_point_out),
        .scale                 (scale),
        .shift                 (shift),
        .num_ow                (num_ow),
        .num_oh                (num_oh),
        .num_oc                (num_oc),
        .num_ic                (num_ic),
        .num_rs                (num_rs),
        .total_len_r           (total_len_r),
        .total_len_s           (total_len_s),
        .stride_x              (stride_x),
        .stride_y              (stride_y),
        .dilation_x            (dilation_x),
        .dilation_y            (dilation_y),
        .basic_oc              (basic_oc),
        .basic_ic              (basic_ic),
        .basic_rs              (basic_rs),
        .basic_ow              (basic_ow),
        .basic_oh              (basic_oh),
        .basic_ow_sx           (basic_ow_sx),
        .basic_oh_sy           (basic_oh_sy),
        .basic_iw              (basic_iw),
        .basic_ih              (basic_ih),
        .remain_oc             (remain_oc),
        .remain_ic             (remain_ic),
        .remain_rs             (remain_rs),
        .remain_ow             (remain_ow),
        .remain_oh             (remain_oh),
        .remain_iw             (remain_iw),
        .remain_ih             (remain_ih),
        .imap_axi_R_BASE_ADDR  (imap_axi_R_BASE_ADDR),
        .weight_axi_R_BASE_ADDR(weight_axi_R_BASE_ADDR),
        .omap_axi_W_BASE_ADDR  (omap_axi_W_BASE_ADDR),
        .bias_axi_R_BASE_ADDR  (bias_axi_R_BASE_ADDR),
        .bias2_axi_R_BASE_ADDR (bias2_axi_R_BASE_ADDR),
        .padding_external      (padding_external),
        .Aiwih                 (Aiwih),
        .Aiw                   (Aiw),
        .Wicrs                 (Wicrs),
        .Wic                   (Wic),
        // .concat_dim            (concat_dim),
        // .concat_len            (concat_len),
        .Aowoh                 (Aowoh),
        .Aow                   (Aow),

        .imap_m_axi_aclk   (imap_m_axi_aclk),
        .imap_m_axi_aresetn(imap_m_axi_aresetn),
        .imap_m_axi_awid   (imap_m_axi_awid),
        .imap_m_axi_awaddr (imap_m_axi_awaddr),
        .imap_m_axi_awlen  (imap_m_axi_awlen),
        .imap_m_axi_awsize (imap_m_axi_awsize),
        .imap_m_axi_awburst(imap_m_axi_awburst),
        .imap_m_axi_awlock (imap_m_axi_awlock),
        .imap_m_axi_awcache(imap_m_axi_awcache),
        .imap_m_axi_awprot (imap_m_axi_awprot),
        .imap_m_axi_awqos  (imap_m_axi_awqos),
        .imap_m_axi_awuser (imap_m_axi_awuser),
        .imap_m_axi_awvalid(imap_m_axi_awvalid),
        .imap_m_axi_wdata  (imap_m_axi_wdata),
        .imap_m_axi_wstrb  (imap_m_axi_wstrb),
        .imap_m_axi_wlast  (imap_m_axi_wlast),
        .imap_m_axi_wuser  (imap_m_axi_wuser),
        .imap_m_axi_wvalid (imap_m_axi_wvalid),
        .imap_m_axi_bready (imap_m_axi_bready),
        .imap_m_axi_arid   (imap_m_axi_arid),
        .imap_m_axi_araddr (imap_m_axi_araddr),
        .imap_m_axi_arlen  (imap_m_axi_arlen),
        .imap_m_axi_arsize (imap_m_axi_arsize),
        .imap_m_axi_arburst(imap_m_axi_arburst),
        .imap_m_axi_arlock (imap_m_axi_arlock),
        .imap_m_axi_arcache(imap_m_axi_arcache),
        .imap_m_axi_arprot (imap_m_axi_arprot),
        .imap_m_axi_arqos  (imap_m_axi_arqos),
        .imap_m_axi_aruser (imap_m_axi_aruser),
        .imap_m_axi_arvalid(imap_m_axi_arvalid),
        .imap_m_axi_rready (imap_m_axi_rready),

        .weight_m_axi_aclk   (weight_m_axi_aclk),
        .weight_m_axi_aresetn(weight_m_axi_aresetn),
        .weight_m_axi_awid   (weight_m_axi_awid),
        .weight_m_axi_awaddr (weight_m_axi_awaddr),
        .weight_m_axi_awlen  (weight_m_axi_awlen),
        .weight_m_axi_awsize (weight_m_axi_awsize),
        .weight_m_axi_awburst(weight_m_axi_awburst),
        .weight_m_axi_awlock (weight_m_axi_awlock),
        .weight_m_axi_awcache(weight_m_axi_awcache),
        .weight_m_axi_awprot (weight_m_axi_awprot),
        .weight_m_axi_awqos  (weight_m_axi_awqos),
        .weight_m_axi_awuser (weight_m_axi_awuser),
        .weight_m_axi_awvalid(weight_m_axi_awvalid),
        .weight_m_axi_wdata  (weight_m_axi_wdata),
        .weight_m_axi_wstrb  (weight_m_axi_wstrb),
        .weight_m_axi_wlast  (weight_m_axi_wlast),
        .weight_m_axi_wuser  (weight_m_axi_wuser),
        .weight_m_axi_wvalid (weight_m_axi_wvalid),
        .weight_m_axi_bready (weight_m_axi_bready),
        .weight_m_axi_arid   (weight_m_axi_arid),
        .weight_m_axi_araddr (weight_m_axi_araddr),
        .weight_m_axi_arlen  (weight_m_axi_arlen),
        .weight_m_axi_arsize (weight_m_axi_arsize),
        .weight_m_axi_arburst(weight_m_axi_arburst),
        .weight_m_axi_arlock (weight_m_axi_arlock),
        .weight_m_axi_arcache(weight_m_axi_arcache),
        .weight_m_axi_arprot (weight_m_axi_arprot),
        .weight_m_axi_arqos  (weight_m_axi_arqos),
        .weight_m_axi_aruser (weight_m_axi_aruser),
        .weight_m_axi_arvalid(weight_m_axi_arvalid),
        .weight_m_axi_rready (weight_m_axi_rready),

        .bias2_m_axi_aclk   (bias2_m_axi_aclk),
        .bias2_m_axi_aresetn(bias2_m_axi_aresetn),
        .bias2_m_axi_awid   (bias2_m_axi_awid),
        .bias2_m_axi_awaddr (bias2_m_axi_awaddr),
        .bias2_m_axi_awlen  (bias2_m_axi_awlen),
        .bias2_m_axi_awsize (bias2_m_axi_awsize),
        .bias2_m_axi_awburst(bias2_m_axi_awburst),
        .bias2_m_axi_awlock (bias2_m_axi_awlock),
        .bias2_m_axi_awcache(bias2_m_axi_awcache),
        .bias2_m_axi_awprot (bias2_m_axi_awprot),
        .bias2_m_axi_awqos  (bias2_m_axi_awqos),
        .bias2_m_axi_awuser (bias2_m_axi_awuser),
        .bias2_m_axi_awvalid(bias2_m_axi_awvalid),
        .bias2_m_axi_wdata  (bias2_m_axi_wdata),
        .bias2_m_axi_wstrb  (bias2_m_axi_wstrb),
        .bias2_m_axi_wlast  (bias2_m_axi_wlast),
        .bias2_m_axi_wuser  (bias2_m_axi_wuser),
        .bias2_m_axi_wvalid (bias2_m_axi_wvalid),
        .bias2_m_axi_bready (bias2_m_axi_bready),
        .bias2_m_axi_arid   (bias2_m_axi_arid),
        .bias2_m_axi_araddr (bias2_m_axi_araddr),
        .bias2_m_axi_arlen  (bias2_m_axi_arlen),
        .bias2_m_axi_arsize (bias2_m_axi_arsize),
        .bias2_m_axi_arburst(bias2_m_axi_arburst),
        .bias2_m_axi_arlock (bias2_m_axi_arlock),
        .bias2_m_axi_arcache(bias2_m_axi_arcache),
        .bias2_m_axi_arprot (bias2_m_axi_arprot),
        .bias2_m_axi_arqos  (bias2_m_axi_arqos),
        .bias2_m_axi_aruser (bias2_m_axi_aruser),
        .bias2_m_axi_arvalid(bias2_m_axi_arvalid),
        .bias2_m_axi_rready (bias2_m_axi_rready),

        .omap_m_axi_aclk   (omap_m_axi_aclk),
        .omap_m_axi_aresetn(omap_m_axi_aresetn),
        .omap_m_axi_awid   (omap_m_axi_awid),
        .omap_m_axi_awaddr (omap_m_axi_awaddr),
        .omap_m_axi_awlen  (omap_m_axi_awlen),
        .omap_m_axi_awsize (omap_m_axi_awsize),
        .omap_m_axi_awburst(omap_m_axi_awburst),
        .omap_m_axi_awlock (omap_m_axi_awlock),
        .omap_m_axi_awcache(omap_m_axi_awcache),
        .omap_m_axi_awprot (omap_m_axi_awprot),
        .omap_m_axi_awqos  (omap_m_axi_awqos),
        .omap_m_axi_awuser (omap_m_axi_awuser),
        .omap_m_axi_awvalid(omap_m_axi_awvalid),
        .omap_m_axi_wdata  (omap_m_axi_wdata),
        .omap_m_axi_wstrb  (omap_m_axi_wstrb),
        .omap_m_axi_wlast  (omap_m_axi_wlast),
        .omap_m_axi_wuser  (omap_m_axi_wuser),
        .omap_m_axi_wvalid (omap_m_axi_wvalid),
        .omap_m_axi_bready (omap_m_axi_bready),
        .omap_m_axi_arid   (omap_m_axi_arid),
        .omap_m_axi_araddr (omap_m_axi_araddr),
        .omap_m_axi_arlen  (omap_m_axi_arlen),
        .omap_m_axi_arsize (omap_m_axi_arsize),
        .omap_m_axi_arburst(omap_m_axi_arburst),
        .omap_m_axi_arlock (omap_m_axi_arlock),
        .omap_m_axi_arcache(omap_m_axi_arcache),
        .omap_m_axi_arprot (omap_m_axi_arprot),
        .omap_m_axi_arqos  (omap_m_axi_arqos),
        .omap_m_axi_aruser (omap_m_axi_aruser),
        .omap_m_axi_arvalid(omap_m_axi_arvalid),
        .omap_m_axi_rready (omap_m_axi_rready),
        .layer_done        (layer_done)
    );






    parameter DATA_WIDTH = BUS_WIDTH;
    parameter ADDR_WIDTH = BUS_ADDR_WIDTH;
    parameter STRB_WIDTH = (DATA_WIDTH / 8);
    parameter ID_WIDTH = 1;
    parameter PIPELINE_OUTPUT = 0;

    parameter VALID_ADDR_WIDTH = 20;  //è¿™é‡Œå‡�å°‘å†…å­˜å� ç”¨

    reg  [  ID_WIDTH-1:0] imap_s_axi_awid;
    reg  [ADDR_WIDTH-1:0] imap_s_axi_awaddr;
    reg  [           7:0] imap_s_axi_awlen;
    reg  [           2:0] imap_s_axi_awsize;
    reg  [           1:0] imap_s_axi_awburst;
    reg                   imap_s_axi_awlock;
    reg  [           3:0] imap_s_axi_awcache;
    reg  [           2:0] imap_s_axi_awprot;
    reg                   imap_s_axi_awvalid;
    reg  [DATA_WIDTH-1:0] imap_s_axi_wdata;
    reg  [STRB_WIDTH-1:0] imap_s_axi_wstrb;
    reg                   imap_s_axi_wlast;
    reg                   imap_s_axi_wvalid;
    reg                   imap_s_axi_bready;
    reg  [  ID_WIDTH-1:0] imap_s_axi_arid;
    reg  [ADDR_WIDTH-1:0] imap_s_axi_araddr;
    reg  [           7:0] imap_s_axi_arlen;
    reg  [           2:0] imap_s_axi_arsize;
    reg  [           1:0] imap_s_axi_arburst;
    reg                   imap_s_axi_arlock;
    reg  [           3:0] imap_s_axi_arcache;
    reg  [           2:0] imap_s_axi_arprot;
    reg                   imap_s_axi_arvalid;
    reg                   imap_s_axi_rready;

    // axi_ram Outputs
    wire                  imap_s_axi_awready;
    wire                  imap_s_axi_wready;
    wire [  ID_WIDTH-1:0] imap_s_axi_bid;
    wire [           1:0] imap_s_axi_bresp;
    wire                  imap_s_axi_bvalid;
    wire                  imap_s_axi_arready;
    wire [  ID_WIDTH-1:0] imap_s_axi_rid;
    wire [DATA_WIDTH-1:0] imap_s_axi_rdata;
    wire [           1:0] imap_s_axi_rresp;
    wire                  imap_s_axi_rlast;
    wire                  imap_s_axi_rvalid;

    axi_ram #(
        .DATA_WIDTH      (DATA_WIDTH),
        .ADDR_WIDTH      (ADDR_WIDTH),
        .STRB_WIDTH      (STRB_WIDTH),
        .ID_WIDTH        (ID_WIDTH),
        .PIPELINE_OUTPUT (PIPELINE_OUTPUT),
        .VALID_ADDR_WIDTH(VALID_ADDR_WIDTH)
    ) u_axi_ram_imap (
        .clk          (clk),
        .rst          (~rstn),
        .s_axi_awid   (imap_s_axi_awid),
        .s_axi_awaddr (imap_s_axi_awaddr),
        .s_axi_awlen  (imap_s_axi_awlen),
        .s_axi_awsize (imap_s_axi_awsize),
        .s_axi_awburst(imap_s_axi_awburst),
        .s_axi_awlock (imap_s_axi_awlock),
        .s_axi_awcache(imap_s_axi_awcache),
        .s_axi_awprot (imap_s_axi_awprot),
        .s_axi_awvalid(imap_s_axi_awvalid),
        .s_axi_awready(imap_s_axi_awready),
        .s_axi_wdata  (imap_s_axi_wdata),
        .s_axi_wstrb  (imap_s_axi_wstrb),
        .s_axi_wlast  (imap_s_axi_wlast),
        .s_axi_wvalid (imap_s_axi_wvalid),
        .s_axi_wready (imap_s_axi_wready),
        .s_axi_bid    (imap_s_axi_bid),
        .s_axi_bresp  (imap_s_axi_bresp),
        .s_axi_bvalid (imap_s_axi_bvalid),
        .s_axi_bready (imap_s_axi_bready),
        .s_axi_arid   (imap_s_axi_arid),
        .s_axi_araddr (imap_s_axi_araddr),
        .s_axi_arlen  (imap_s_axi_arlen),
        .s_axi_arsize (imap_s_axi_arsize),
        .s_axi_arburst(imap_s_axi_arburst),
        .s_axi_arlock (imap_s_axi_arlock),
        .s_axi_arcache(imap_s_axi_arcache),
        .s_axi_arprot (imap_s_axi_arprot),
        .s_axi_arvalid(imap_s_axi_arvalid),
        .s_axi_arready(imap_s_axi_arready),
        .s_axi_rid    (imap_s_axi_rid),
        .s_axi_rdata  (imap_s_axi_rdata),
        .s_axi_rresp  (imap_s_axi_rresp),
        .s_axi_rlast  (imap_s_axi_rlast),
        .s_axi_rvalid (imap_s_axi_rvalid),
        .s_axi_rready (imap_s_axi_rready)
    );








    assign imap_m_axi_ruser   = 0;
    assign imap_m_axi_buser   = 0;



    assign imap_s_axi_awid    = imap_m_axi_awid;
    assign imap_s_axi_awaddr  = imap_m_axi_awaddr;
    assign imap_s_axi_awlen   = imap_m_axi_awlen;
    assign imap_s_axi_awsize  = imap_m_axi_awsize;
    assign imap_s_axi_awburst = imap_m_axi_awburst;
    assign imap_s_axi_awlock  = imap_m_axi_awlock;
    assign imap_s_axi_awcache = imap_m_axi_awcache;
    assign imap_s_axi_awprot  = imap_m_axi_awprot;
    assign imap_s_axi_awvalid = imap_m_axi_awvalid;
    assign imap_m_axi_awready = imap_s_axi_awready;  //input
    assign imap_s_axi_wdata   = imap_m_axi_wdata;
    assign imap_s_axi_wstrb   = imap_m_axi_wstrb;
    assign imap_s_axi_wlast   = imap_m_axi_wlast;
    assign imap_s_axi_wvalid  = imap_m_axi_wvalid;
    assign imap_m_axi_wready  = imap_s_axi_wready;  //input
    assign imap_m_axi_bid     = imap_s_axi_bid;  //input
    assign imap_m_axi_bresp   = imap_s_axi_bresp;  //input
    assign imap_m_axi_bvalid  = imap_s_axi_bvalid;  //input
    assign imap_s_axi_bready  = imap_m_axi_bready;
    assign imap_s_axi_arid    = imap_m_axi_arid;
    assign imap_s_axi_araddr  = imap_m_axi_araddr;
    assign imap_s_axi_arlen   = imap_m_axi_arlen;
    assign imap_s_axi_arsize  = imap_m_axi_arsize;
    assign imap_s_axi_arburst = imap_m_axi_arburst;
    assign imap_s_axi_arlock  = imap_m_axi_arlock;
    assign imap_s_axi_arcache = imap_m_axi_arcache;
    assign imap_s_axi_arprot  = imap_m_axi_arprot;
    assign imap_s_axi_arvalid = imap_m_axi_arvalid;
    assign imap_m_axi_arready = imap_s_axi_arready;  //input
    assign imap_m_axi_rid     = imap_s_axi_rid;  //input
    assign imap_m_axi_rdata   = imap_s_axi_rdata;  //input
    assign imap_m_axi_rresp   = imap_s_axi_rresp;  //input
    assign imap_m_axi_rlast   = imap_s_axi_rlast;  //input
    assign imap_m_axi_rvalid  = imap_s_axi_rvalid;  //input
    assign imap_s_axi_rready  = imap_m_axi_rready;



    reg  [  ID_WIDTH-1:0] weight_s_axi_awid;
    reg  [ADDR_WIDTH-1:0] weight_s_axi_awaddr;
    reg  [           7:0] weight_s_axi_awlen;
    reg  [           2:0] weight_s_axi_awsize;
    reg  [           1:0] weight_s_axi_awburst;
    reg                   weight_s_axi_awlock;
    reg  [           3:0] weight_s_axi_awcache;
    reg  [           2:0] weight_s_axi_awprot;
    reg                   weight_s_axi_awvalid;
    reg  [DATA_WIDTH-1:0] weight_s_axi_wdata;
    reg  [STRB_WIDTH-1:0] weight_s_axi_wstrb;
    reg                   weight_s_axi_wlast;
    reg                   weight_s_axi_wvalid;
    reg                   weight_s_axi_bready;
    reg  [  ID_WIDTH-1:0] weight_s_axi_arid;
    reg  [ADDR_WIDTH-1:0] weight_s_axi_araddr;
    reg  [           7:0] weight_s_axi_arlen;
    reg  [           2:0] weight_s_axi_arsize;
    reg  [           1:0] weight_s_axi_arburst;
    reg                   weight_s_axi_arlock;
    reg  [           3:0] weight_s_axi_arcache;
    reg  [           2:0] weight_s_axi_arprot;
    reg                   weight_s_axi_arvalid;
    reg                   weight_s_axi_rready;

    // axi_ram Outputs
    wire                  weight_s_axi_awready;
    wire                  weight_s_axi_wready;
    wire [  ID_WIDTH-1:0] weight_s_axi_bid;
    wire [           1:0] weight_s_axi_bresp;
    wire                  weight_s_axi_bvalid;
    wire                  weight_s_axi_arready;
    wire [  ID_WIDTH-1:0] weight_s_axi_rid;
    wire [DATA_WIDTH-1:0] weight_s_axi_rdata;
    wire [           1:0] weight_s_axi_rresp;
    wire                  weight_s_axi_rlast;
    wire                  weight_s_axi_rvalid;

    axi_ram #(
        .DATA_WIDTH      (DATA_WIDTH),
        .ADDR_WIDTH      (ADDR_WIDTH),
        .STRB_WIDTH      (STRB_WIDTH),
        .ID_WIDTH        (ID_WIDTH),
        .PIPELINE_OUTPUT (PIPELINE_OUTPUT),
        .VALID_ADDR_WIDTH(VALID_ADDR_WIDTH)
    ) u_axi_ram_weight (
        .clk          (clk),
        .rst          (~rstn),
        .s_axi_awid   (weight_s_axi_awid),
        .s_axi_awaddr (weight_s_axi_awaddr),
        .s_axi_awlen  (weight_s_axi_awlen),
        .s_axi_awsize (weight_s_axi_awsize),
        .s_axi_awburst(weight_s_axi_awburst),
        .s_axi_awlock (weight_s_axi_awlock),
        .s_axi_awcache(weight_s_axi_awcache),
        .s_axi_awprot (weight_s_axi_awprot),
        .s_axi_awvalid(weight_s_axi_awvalid),
        .s_axi_awready(weight_s_axi_awready),
        .s_axi_wdata  (weight_s_axi_wdata),
        .s_axi_wstrb  (weight_s_axi_wstrb),
        .s_axi_wlast  (weight_s_axi_wlast),
        .s_axi_wvalid (weight_s_axi_wvalid),
        .s_axi_wready (weight_s_axi_wready),
        .s_axi_bid    (weight_s_axi_bid),
        .s_axi_bresp  (weight_s_axi_bresp),
        .s_axi_bvalid (weight_s_axi_bvalid),
        .s_axi_bready (weight_s_axi_bready),
        .s_axi_arid   (weight_s_axi_arid),
        .s_axi_araddr (weight_s_axi_araddr),
        .s_axi_arlen  (weight_s_axi_arlen),
        .s_axi_arsize (weight_s_axi_arsize),
        .s_axi_arburst(weight_s_axi_arburst),
        .s_axi_arlock (weight_s_axi_arlock),
        .s_axi_arcache(weight_s_axi_arcache),
        .s_axi_arprot (weight_s_axi_arprot),
        .s_axi_arvalid(weight_s_axi_arvalid),
        .s_axi_arready(weight_s_axi_arready),
        .s_axi_rid    (weight_s_axi_rid),
        .s_axi_rdata  (weight_s_axi_rdata),
        .s_axi_rresp  (weight_s_axi_rresp),
        .s_axi_rlast  (weight_s_axi_rlast),
        .s_axi_rvalid (weight_s_axi_rvalid),
        .s_axi_rready (weight_s_axi_rready)
    );







    assign weight_m_axi_ruser   = 0;
    assign weight_m_axi_buser   = 0;



    assign weight_s_axi_awid    = weight_m_axi_awid;
    assign weight_s_axi_awaddr  = weight_m_axi_awaddr;
    assign weight_s_axi_awlen   = weight_m_axi_awlen;
    assign weight_s_axi_awsize  = weight_m_axi_awsize;
    assign weight_s_axi_awburst = weight_m_axi_awburst;
    assign weight_s_axi_awlock  = weight_m_axi_awlock;
    assign weight_s_axi_awcache = weight_m_axi_awcache;
    assign weight_s_axi_awprot  = weight_m_axi_awprot;
    assign weight_s_axi_awvalid = weight_m_axi_awvalid;
    assign weight_m_axi_awready = weight_s_axi_awready;  //input
    assign weight_s_axi_wdata   = weight_m_axi_wdata;
    assign weight_s_axi_wstrb   = weight_m_axi_wstrb;
    assign weight_s_axi_wlast   = weight_m_axi_wlast;
    assign weight_s_axi_wvalid  = weight_m_axi_wvalid;
    assign weight_m_axi_wready  = weight_s_axi_wready;  //input
    assign weight_m_axi_bid     = weight_s_axi_bid;  //input
    assign weight_m_axi_bresp   = weight_s_axi_bresp;  //input
    assign weight_m_axi_bvalid  = weight_s_axi_bvalid;  //input
    assign weight_s_axi_bready  = weight_m_axi_bready;
    assign weight_s_axi_arid    = weight_m_axi_arid;
    assign weight_s_axi_araddr  = weight_m_axi_araddr;
    assign weight_s_axi_arlen   = weight_m_axi_arlen;
    assign weight_s_axi_arsize  = weight_m_axi_arsize;
    assign weight_s_axi_arburst = weight_m_axi_arburst;
    assign weight_s_axi_arlock  = weight_m_axi_arlock;
    assign weight_s_axi_arcache = weight_m_axi_arcache;
    assign weight_s_axi_arprot  = weight_m_axi_arprot;
    assign weight_s_axi_arvalid = weight_m_axi_arvalid;
    assign weight_m_axi_arready = weight_s_axi_arready;  //input
    assign weight_m_axi_rid     = weight_s_axi_rid;  //input
    assign weight_m_axi_rdata   = weight_s_axi_rdata;  //input
    assign weight_m_axi_rresp   = weight_s_axi_rresp;  //input
    assign weight_m_axi_rlast   = weight_s_axi_rlast;  //input
    assign weight_m_axi_rvalid  = weight_s_axi_rvalid;  //input
    assign weight_s_axi_rready  = weight_m_axi_rready;



    reg  [  ID_WIDTH-1:0] bias2_s_axi_awid;
    reg  [ADDR_WIDTH-1:0] bias2_s_axi_awaddr;
    reg  [           7:0] bias2_s_axi_awlen;
    reg  [           2:0] bias2_s_axi_awsize;
    reg  [           1:0] bias2_s_axi_awburst;
    reg                   bias2_s_axi_awlock;
    reg  [           3:0] bias2_s_axi_awcache;
    reg  [           2:0] bias2_s_axi_awprot;
    reg                   bias2_s_axi_awvalid;
    reg  [DATA_WIDTH-1:0] bias2_s_axi_wdata;
    reg  [STRB_WIDTH-1:0] bias2_s_axi_wstrb;
    reg                   bias2_s_axi_wlast;
    reg                   bias2_s_axi_wvalid;
    reg                   bias2_s_axi_bready;
    reg  [  ID_WIDTH-1:0] bias2_s_axi_arid;
    reg  [ADDR_WIDTH-1:0] bias2_s_axi_araddr;
    reg  [           7:0] bias2_s_axi_arlen;
    reg  [           2:0] bias2_s_axi_arsize;
    reg  [           1:0] bias2_s_axi_arburst;
    reg                   bias2_s_axi_arlock;
    reg  [           3:0] bias2_s_axi_arcache;
    reg  [           2:0] bias2_s_axi_arprot;
    reg                   bias2_s_axi_arvalid;
    reg                   bias2_s_axi_rready;

    // axi_ram Outputs
    wire                  bias2_s_axi_awready;
    wire                  bias2_s_axi_wready;
    wire [  ID_WIDTH-1:0] bias2_s_axi_bid;
    wire [           1:0] bias2_s_axi_bresp;
    wire                  bias2_s_axi_bvalid;
    wire                  bias2_s_axi_arready;
    wire [  ID_WIDTH-1:0] bias2_s_axi_rid;
    wire [DATA_WIDTH-1:0] bias2_s_axi_rdata;
    wire [           1:0] bias2_s_axi_rresp;
    wire                  bias2_s_axi_rlast;
    wire                  bias2_s_axi_rvalid;

    axi_ram #(
        .DATA_WIDTH      (DATA_WIDTH),
        .ADDR_WIDTH      (ADDR_WIDTH),
        .STRB_WIDTH      (STRB_WIDTH),
        .ID_WIDTH        (ID_WIDTH),
        .PIPELINE_OUTPUT (PIPELINE_OUTPUT),
        .VALID_ADDR_WIDTH(VALID_ADDR_WIDTH)
    ) u_axi_ram_bias2 (
        .clk          (clk),
        .rst          (~rstn),
        .s_axi_awid   (bias2_s_axi_awid),
        .s_axi_awaddr (bias2_s_axi_awaddr),
        .s_axi_awlen  (bias2_s_axi_awlen),
        .s_axi_awsize (bias2_s_axi_awsize),
        .s_axi_awburst(bias2_s_axi_awburst),
        .s_axi_awlock (bias2_s_axi_awlock),
        .s_axi_awcache(bias2_s_axi_awcache),
        .s_axi_awprot (bias2_s_axi_awprot),
        .s_axi_awvalid(bias2_s_axi_awvalid),
        .s_axi_awready(bias2_s_axi_awready),
        .s_axi_wdata  (bias2_s_axi_wdata),
        .s_axi_wstrb  (bias2_s_axi_wstrb),
        .s_axi_wlast  (bias2_s_axi_wlast),
        .s_axi_wvalid (bias2_s_axi_wvalid),
        .s_axi_wready (bias2_s_axi_wready),
        .s_axi_bid    (bias2_s_axi_bid),
        .s_axi_bresp  (bias2_s_axi_bresp),
        .s_axi_bvalid (bias2_s_axi_bvalid),
        .s_axi_bready (bias2_s_axi_bready),
        .s_axi_arid   (bias2_s_axi_arid),
        .s_axi_araddr (bias2_s_axi_araddr),
        .s_axi_arlen  (bias2_s_axi_arlen),
        .s_axi_arsize (bias2_s_axi_arsize),
        .s_axi_arburst(bias2_s_axi_arburst),
        .s_axi_arlock (bias2_s_axi_arlock),
        .s_axi_arcache(bias2_s_axi_arcache),
        .s_axi_arprot (bias2_s_axi_arprot),
        .s_axi_arvalid(bias2_s_axi_arvalid),
        .s_axi_arready(bias2_s_axi_arready),
        .s_axi_rid    (bias2_s_axi_rid),
        .s_axi_rdata  (bias2_s_axi_rdata),
        .s_axi_rresp  (bias2_s_axi_rresp),
        .s_axi_rlast  (bias2_s_axi_rlast),
        .s_axi_rvalid (bias2_s_axi_rvalid),
        .s_axi_rready (bias2_s_axi_rready)
    );







    assign bias2_m_axi_ruser   = 0;
    assign bias2_m_axi_buser   = 0;



    assign bias2_s_axi_awid    = bias2_m_axi_awid;
    assign bias2_s_axi_awaddr  = bias2_m_axi_awaddr;
    assign bias2_s_axi_awlen   = bias2_m_axi_awlen;
    assign bias2_s_axi_awsize  = bias2_m_axi_awsize;
    assign bias2_s_axi_awburst = bias2_m_axi_awburst;
    assign bias2_s_axi_awlock  = bias2_m_axi_awlock;
    assign bias2_s_axi_awcache = bias2_m_axi_awcache;
    assign bias2_s_axi_awprot  = bias2_m_axi_awprot;
    assign bias2_s_axi_awvalid = bias2_m_axi_awvalid;
    assign bias2_m_axi_awready = bias2_s_axi_awready;  //input
    assign bias2_s_axi_wdata   = bias2_m_axi_wdata;
    assign bias2_s_axi_wstrb   = bias2_m_axi_wstrb;
    assign bias2_s_axi_wlast   = bias2_m_axi_wlast;
    assign bias2_s_axi_wvalid  = bias2_m_axi_wvalid;
    assign bias2_m_axi_wready  = bias2_s_axi_wready;  //input
    assign bias2_m_axi_bid     = bias2_s_axi_bid;  //input
    assign bias2_m_axi_bresp   = bias2_s_axi_bresp;  //input
    assign bias2_m_axi_bvalid  = bias2_s_axi_bvalid;  //input
    assign bias2_s_axi_bready  = bias2_m_axi_bready;
    assign bias2_s_axi_arid    = bias2_m_axi_arid;
    assign bias2_s_axi_araddr  = bias2_m_axi_araddr;
    assign bias2_s_axi_arlen   = bias2_m_axi_arlen;
    assign bias2_s_axi_arsize  = bias2_m_axi_arsize;
    assign bias2_s_axi_arburst = bias2_m_axi_arburst;
    assign bias2_s_axi_arlock  = bias2_m_axi_arlock;
    assign bias2_s_axi_arcache = bias2_m_axi_arcache;
    assign bias2_s_axi_arprot  = bias2_m_axi_arprot;
    assign bias2_s_axi_arvalid = bias2_m_axi_arvalid;
    assign bias2_m_axi_arready = bias2_s_axi_arready;  //input
    assign bias2_m_axi_rid     = bias2_s_axi_rid;  //input
    assign bias2_m_axi_rdata   = bias2_s_axi_rdata;  //input
    assign bias2_m_axi_rresp   = bias2_s_axi_rresp;  //input
    assign bias2_m_axi_rlast   = bias2_s_axi_rlast;  //input
    assign bias2_m_axi_rvalid  = bias2_s_axi_rvalid;  //input
    assign bias2_s_axi_rready  = bias2_m_axi_rready;


    reg  [  ID_WIDTH-1:0] omap_s_axi_awid;
    reg  [ADDR_WIDTH-1:0] omap_s_axi_awaddr;
    reg  [           7:0] omap_s_axi_awlen;
    reg  [           2:0] omap_s_axi_awsize;
    reg  [           1:0] omap_s_axi_awburst;
    reg                   omap_s_axi_awlock;
    reg  [           3:0] omap_s_axi_awcache;
    reg  [           2:0] omap_s_axi_awprot;
    reg                   omap_s_axi_awvalid;
    reg  [DATA_WIDTH-1:0] omap_s_axi_wdata;
    reg  [STRB_WIDTH-1:0] omap_s_axi_wstrb;
    reg                   omap_s_axi_wlast;
    reg                   omap_s_axi_wvalid;
    reg                   omap_s_axi_bready;
    reg  [  ID_WIDTH-1:0] omap_s_axi_arid;
    reg  [ADDR_WIDTH-1:0] omap_s_axi_araddr;
    reg  [           7:0] omap_s_axi_arlen;
    reg  [           2:0] omap_s_axi_arsize;
    reg  [           1:0] omap_s_axi_arburst;
    reg                   omap_s_axi_arlock;
    reg  [           3:0] omap_s_axi_arcache;
    reg  [           2:0] omap_s_axi_arprot;
    reg                   omap_s_axi_arvalid;
    reg                   omap_s_axi_rready;

    // axi_ram Outputs
    wire                  omap_s_axi_awready;
    wire                  omap_s_axi_wready;
    wire [  ID_WIDTH-1:0] omap_s_axi_bid;
    wire [           1:0] omap_s_axi_bresp;
    wire                  omap_s_axi_bvalid;
    wire                  omap_s_axi_arready;
    wire [  ID_WIDTH-1:0] omap_s_axi_rid;
    wire [DATA_WIDTH-1:0] omap_s_axi_rdata;
    wire [           1:0] omap_s_axi_rresp;
    wire                  omap_s_axi_rlast;
    wire                  omap_s_axi_rvalid;

    axi_ram #(
        .DATA_WIDTH      (DATA_WIDTH),
        .ADDR_WIDTH      (ADDR_WIDTH),
        .STRB_WIDTH      (STRB_WIDTH),
        .ID_WIDTH        (ID_WIDTH),
        .PIPELINE_OUTPUT (PIPELINE_OUTPUT),
        .VALID_ADDR_WIDTH(VALID_ADDR_WIDTH)
    ) u_axi_ram_bias_omap (
        .clk          (clk),
        .rst          (~rstn),
        .s_axi_awid   (omap_s_axi_awid),
        .s_axi_awaddr (omap_s_axi_awaddr),
        .s_axi_awlen  (omap_s_axi_awlen),
        .s_axi_awsize (omap_s_axi_awsize),
        .s_axi_awburst(omap_s_axi_awburst),
        .s_axi_awlock (omap_s_axi_awlock),
        .s_axi_awcache(omap_s_axi_awcache),
        .s_axi_awprot (omap_s_axi_awprot),
        .s_axi_awvalid(omap_s_axi_awvalid),
        .s_axi_awready(omap_s_axi_awready),
        .s_axi_wdata  (omap_s_axi_wdata),
        .s_axi_wstrb  (omap_s_axi_wstrb),
        .s_axi_wlast  (omap_s_axi_wlast),
        .s_axi_wvalid (omap_s_axi_wvalid),
        .s_axi_wready (omap_s_axi_wready),
        .s_axi_bid    (omap_s_axi_bid),
        .s_axi_bresp  (omap_s_axi_bresp),
        .s_axi_bvalid (omap_s_axi_bvalid),
        .s_axi_bready (omap_s_axi_bready),
        .s_axi_arid   (omap_s_axi_arid),
        .s_axi_araddr (omap_s_axi_araddr),
        .s_axi_arlen  (omap_s_axi_arlen),
        .s_axi_arsize (omap_s_axi_arsize),
        .s_axi_arburst(omap_s_axi_arburst),
        .s_axi_arlock (omap_s_axi_arlock),
        .s_axi_arcache(omap_s_axi_arcache),
        .s_axi_arprot (omap_s_axi_arprot),
        .s_axi_arvalid(omap_s_axi_arvalid),
        .s_axi_arready(omap_s_axi_arready),
        .s_axi_rid    (omap_s_axi_rid),
        .s_axi_rdata  (omap_s_axi_rdata),
        .s_axi_rresp  (omap_s_axi_rresp),
        .s_axi_rlast  (omap_s_axi_rlast),
        .s_axi_rvalid (omap_s_axi_rvalid),
        .s_axi_rready (omap_s_axi_rready)
    );





    assign omap_m_axi_ruser   = 0;
    assign omap_m_axi_buser   = 0;



    assign omap_s_axi_awid    = omap_m_axi_awid;
    assign omap_s_axi_awaddr  = omap_m_axi_awaddr;
    assign omap_s_axi_awlen   = omap_m_axi_awlen;
    assign omap_s_axi_awsize  = omap_m_axi_awsize;
    assign omap_s_axi_awburst = omap_m_axi_awburst;
    assign omap_s_axi_awlock  = omap_m_axi_awlock;
    assign omap_s_axi_awcache = omap_m_axi_awcache;
    assign omap_s_axi_awprot  = omap_m_axi_awprot;
    assign omap_s_axi_awvalid = omap_m_axi_awvalid;
    assign omap_m_axi_awready = omap_s_axi_awready;  //input
    assign omap_s_axi_wdata   = omap_m_axi_wdata;
    assign omap_s_axi_wstrb   = omap_m_axi_wstrb;
    assign omap_s_axi_wlast   = omap_m_axi_wlast;
    assign omap_s_axi_wvalid  = omap_m_axi_wvalid;
    assign omap_m_axi_wready  = omap_s_axi_wready;  //input
    assign omap_m_axi_bid     = omap_s_axi_bid;  //input
    assign omap_m_axi_bresp   = omap_s_axi_bresp;  //input
    assign omap_m_axi_bvalid  = omap_s_axi_bvalid;  //input
    assign omap_s_axi_bready  = omap_m_axi_bready;
    assign omap_s_axi_arid    = omap_m_axi_arid;
    assign omap_s_axi_araddr  = omap_m_axi_araddr;
    assign omap_s_axi_arlen   = omap_m_axi_arlen;
    assign omap_s_axi_arsize  = omap_m_axi_arsize;
    assign omap_s_axi_arburst = omap_m_axi_arburst;
    assign omap_s_axi_arlock  = omap_m_axi_arlock;
    assign omap_s_axi_arcache = omap_m_axi_arcache;
    assign omap_s_axi_arprot  = omap_m_axi_arprot;
    assign omap_s_axi_arvalid = omap_m_axi_arvalid;
    assign omap_m_axi_arready = omap_s_axi_arready;  //input
    assign omap_m_axi_rid     = omap_s_axi_rid;  //input
    assign omap_m_axi_rdata   = omap_s_axi_rdata;  //input
    assign omap_m_axi_rresp   = omap_s_axi_rresp;  //input
    assign omap_m_axi_rlast   = omap_s_axi_rlast;  //input
    assign omap_m_axi_rvalid  = omap_s_axi_rvalid;  //input
    assign omap_s_axi_rready  = omap_m_axi_rready;



    parameter block_c_imap_int16 = BUS_WIDTH / IMAP_WIDTH;
    parameter block_c_imap_int8 = BUS_WIDTH / (IMAP_WIDTH / 2);
    parameter block_c_weight_int16 = BUS_WIDTH / WEIGHT_WIDTH;
    parameter block_c_weight_int8 = BUS_WIDTH / (WEIGHT_WIDTH / 2);
    parameter block_c_bias_int16 = BUS_WIDTH / BIAS_WIDTH;
    parameter block_c_bias_int8 = BUS_WIDTH / (BIAS_WIDTH / 2);
    parameter block_c_bias2_int16 = BUS_WIDTH / BIAS2_WIDTH;
    parameter block_c_bias2_int8 = BUS_WIDTH / (BIAS2_WIDTH / 2);
    parameter block_c_omap_int16 = BUS_WIDTH / OMAP_WIDTH;
    parameter block_c_omap_int8 = BUS_WIDTH / (OMAP_WIDTH / 2);

    localparam STC = 0, DWC = 1;
    localparam MAX_POOL = 1'b0, AVG_POOL = 1'b1;


    parameter In_channels = 1024;
    parameter Input_height = 20;
    parameter Input_width = 20;
    parameter Out_channels = 512;
    parameter Kernel_height = 1;
    parameter Kernel_width = 1;
    parameter Padding_x = 0;
    parameter Padding_y = 0;
    parameter Stride_x = 1;
    parameter Stride_y = 1;
    parameter Dilation_x = 1;
    parameter Dilation_y = 1;
    parameter Basic_ow = 10;
    parameter Basic_oh = 10;
    parameter Basic_ic = 128;
    parameter Basic_oc = 256;
    parameter Basic_rs = 1;
    parameter USE_BIAS = 1;
    parameter LOAD_BIAS_MODE = 0;
    parameter USE_RELU = 1;
    parameter USE_BIAS2_ADD = 0;
    parameter IS_POOL = 0;
    parameter POOL_TYPE = MAX_POOL;
    parameter CONV_TYPE = STC;
    parameter Scale_int8 = 17270;
    parameter Shift_int8 = 6;
    parameter ZERO_POINT_IN = -128;
    parameter ZERO_POINT_OUT = -128;



    wire is_conv = ~is_pool;
    wire is_stc = (~is_pool && conv_type == STC);
    wire is_dwc = (~is_pool && conv_type == DWC);
    parameter  Output_width = (Input_width + 2 * Padding_x - Dilation_x * (Kernel_width - 1) - 1) / Stride_x + 1;
    parameter  Output_height = (Input_height + 2 * Padding_y - Dilation_y * (Kernel_height - 1) - 1) / Stride_y + 1;

    parameter Remain_ow = Output_width % Basic_ow == 0 ? Basic_ow : Output_width % Basic_ow;
    parameter Remain_oh = Output_height % Basic_oh == 0 ? Basic_oh : Output_height % Basic_oh;
    parameter Remain_oc = Out_channels % Basic_oc == 0 ? Basic_oc : Out_channels % Basic_oc;
    parameter Remain_ic = In_channels % Basic_ic == 0 ? Basic_ic : In_channels % Basic_ic;
    parameter Remain_rs = (
        Kernel_height*Kernel_width) % Basic_rs == 0?Basic_rs : (Kernel_height*Kernel_width) % Basic_rs;


    parameter Num_ow = int'($ceil(real'(real'(Output_width) / real'(Basic_ow))));
    parameter Num_oh = int'($ceil(real'(real'(Output_height) / real'(Basic_oh))));
    parameter Num_oc = int'($ceil(real'(real'(Out_channels) / real'(Basic_oc))));
    parameter Num_ic = int'($ceil(real'(real'(In_channels) / real'(Basic_ic))));
    parameter Num_rs = int'($ceil(real'(real'(Kernel_height * Kernel_width) / real'(Basic_rs))));
    parameter Basic_iw = (Basic_ow - 1) * Stride_x + (Kernel_width - 1) * Dilation_x + 1;
    parameter Basic_ih = (Basic_oh - 1) * Stride_y + (Kernel_height - 1) * Dilation_y + 1;
    parameter Basic_ow_sx = (Basic_ow) * Stride_x;
    parameter Basic_oh_sy = (Basic_oh) * Stride_y;

    parameter Top_padding = Padding_y;
    parameter Bottom_padding = Padding_y;
    parameter Left_padding = Padding_x;
    parameter Right_padding = Padding_x;


    parameter  Remain_ih = (Input_height + Top_padding + Bottom_padding ) - Basic_oh_sy * (Num_oh - 1);
    parameter Remain_iw = (Input_width + Left_padding + Right_padding) - Basic_ow_sx * (Num_ow - 1);



    parameter Ceil_Total_Out_channels_int8_bias = int'($ceil(
        real'(real'(Out_channels) / real'(block_c_bias_int8))
    )) * block_c_bias_int8;
    parameter Ceil_Total_Out_channels_int16_bias = int'($ceil(
        real'(real'(Out_channels) / real'(block_c_bias_int16))
    )) * block_c_bias_int16;

    parameter Ceil_Total_Out_channels_int8_bias2 = int'($ceil(
        real'(real'(Out_channels) / real'(block_c_bias2_int8))
    )) * block_c_bias2_int8;
    parameter Ceil_Total_Out_channels_int16_bias2 = int'($ceil(
        real'(real'(Out_channels) / real'(block_c_bias2_int16))
    )) * block_c_bias2_int16;

    parameter Ceil_Total_Out_channels_int8 = int'($ceil(
        real'(real'(Out_channels) / real'(block_c_weight_int8))
    )) * block_c_weight_int8;
    parameter Ceil_Total_Out_channels_int16 = int'($ceil(
        real'(real'(Out_channels) / real'(block_c_weight_int16))
    )) * block_c_weight_int16;

    parameter Ceil_Total_In_channels_int8 = int'($ceil(
        real'(real'(In_channels) / real'(block_c_imap_int8))
    )) * block_c_imap_int8;
    parameter Ceil_Total_In_channels_int16 = int'($ceil(
        real'(real'(In_channels) / real'(block_c_imap_int16))
    )) * block_c_imap_int16;



    assign Aiwih = is_int16 ? Input_width * Input_height : Input_width * Input_height;
    assign Aiw   = is_int16 ? Input_width : Input_width;
    assign Wicrs = (is_dwc ? 1 : In_channels) * Kernel_height * Kernel_width;
    assign Wic   = (is_dwc ? 1 : In_channels);
    assign Aowoh = is_int16 ? Output_width * Output_height : Output_width * Output_height;
    assign Aow   = is_int16 ? Output_width : Output_width;





    int scale_int8;
    int shift_int8;
    int scale_int16;
    int shift_int16;
    int bias2_scale_int8;
    int bias2_shift_int8;
    int bias2_scale_int16;
    int bias2_shift_int16;
    assign scale = is_int16 ? scale_int16 : scale_int8;
    assign shift = is_int16 ? shift_int16 : shift_int8;
    assign bias2_scale = is_int16 ? bias2_scale_int16 : bias2_scale_int8;
    assign bias2_shift = is_int16 ? bias2_shift_int16 : bias2_shift_int8;

    assign imap_axi_R_BASE_ADDR = 0;
    assign weight_axi_R_BASE_ADDR = 0;
    assign omap_axi_W_BASE_ADDR = 2 ** VALID_ADDR_WIDTH / 2 * (BUS_WIDTH / 8);
    assign bias_axi_R_BASE_ADDR = 0;
    assign bias2_axi_R_BASE_ADDR = 0;

    assign zero_point_in = ZERO_POINT_IN;
    assign zero_point_out = ZERO_POINT_OUT;

    initial begin

        // concat_dim = 0;
        // concat_len = 0;
        use_bias2_add_external = USE_BIAS2_ADD;

        use_quan_external = 1;
        is_pool = IS_POOL;
        pool_type = POOL_TYPE;
        conv_type = CONV_TYPE;


        bias2_scale_int8 = 125;
        bias2_shift_int8 = 1;
        bias2_scale_int16 = 32113;
        bias2_shift_int16 = 1;

        scale_int8 = Scale_int8;
        shift_int8 = Shift_int8;
        scale_int16 = 0;
        shift_int16 = 0;
        relu_enable = USE_RELU;
        is_matmul = 0;
        use_bias_external = USE_BIAS;
        bias_mode_external = LOAD_BIAS_MODE;

        basic_ow = Basic_ow - 1;
        basic_oh = Basic_oh - 1;
        basic_oc = Basic_oc - 1;
        basic_rs = Basic_rs - 1;
        basic_ic = Basic_ic - 1;
        basic_iw = Basic_iw - 1;
        basic_ih = Basic_ih - 1;
        basic_ow_sx = Basic_ow_sx - 1;
        basic_oh_sy = Basic_oh_sy - 1;

        remain_ow = Remain_ow - 1;
        remain_oh = Remain_oh - 1;
        remain_oc = Remain_oc - 1;
        remain_rs = Remain_rs - 1;
        remain_ic = Remain_ic - 1;
        remain_iw = Remain_iw - 1;
        remain_ih = Remain_ih - 1;

        total_len_r = Kernel_height - 1;
        total_len_s = Kernel_width - 1;

        stride_x = Stride_x;
        stride_y = Stride_y;
        dilation_x = Dilation_x;
        dilation_y = Dilation_y;

        num_ow = Num_ow - 1;
        num_oh = Num_oh - 1;
        num_oc = Num_oc - 1;
        num_ic = Num_ic - 1;
        num_rs = Num_rs - 1;

        padding_external = {Top_padding, Bottom_padding, Left_padding, Right_padding};

    end

    reg done_flag;

    dq_dff #(
        .N (20),
        .DW(1)
    ) u_delay_done_flag (
        .clk(clk),
        .rstn(rstn),
        .d(layer_done),
        .q(done_flag)
    );
    // assign finish_flag = done_flag & is_int16;
    assign finish_flag = done_flag & ~is_int16;


    parameter imap_ROW_int8 = Input_height * Input_width * Ceil_Total_In_channels_int8/block_c_imap_int8 ;
    parameter imap_ROW_int16 = Input_height * Input_width * Ceil_Total_In_channels_int16/block_c_imap_int16 ;
    logic signed [IMAP_WIDTH/2-1:0] imap_int8[block_c_imap_int8-1:0];
    logic signed [IMAP_WIDTH-1:0] imap_int16[block_c_imap_int16-1:0];

    logic [BUS_WIDTH-1:0] imap_int8_initial_data;
    logic [BUS_WIDTH-1:0] imap_int16_initial_data;


    `define SRC_PATH "D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\conv_data\\model_data_export_signed\\model9_cv2_conv"
    `define OUT_DATA_PATH "D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\conv_data\\model_data_export_signed\\model9_cv2_conv\\pe_data_ai_acce"

    integer i, j;
    integer fid;
    integer
        fid_wlog_int8,
        fid_imap_int8,
        fid_imap_int16,
        fid_weight_int8,
        fid_weight_int16,
        fid_bias_int8,
        fid_bias_int16,
        fid_bias2_int8,
        fid_bias2_int16;

    initial begin



        fid_wlog_int8 = $fopen({`OUT_DATA_PATH, "\\log.txt"}, "w");
        fid_imap_int8 = $fopen({`SRC_PATH, "\\input_tensor_int8.txt"}, "r");
        if (fid_imap_int8) begin
            for (integer i = 0; i < imap_ROW_int8; i++) begin
                for (integer j = 0; j < block_c_imap_int8; j++) begin
                    $fscanf(fid_imap_int8, "%d", imap_int8[j]);
                end
                #10;
                u_axi_ram_imap.mem[i] = imap_int8_initial_data;
                $fdisplay(fid_wlog_int8, "u_axi_ram_imap.mem[%d]:%h , imap_int8_initial_data:%h\n",
                          i, u_axi_ram_imap.mem[i], imap_int8_initial_data);

            end
            $fclose(fid_imap_int8);
            $fclose(fid_wlog_int8);
        end else begin
            $error("Failed to open file: %s", {`SRC_PATH, "\\input_tensor_int8.txt"});
        end
    end

    initial begin
        wait (done_flag);
        #(T * 10);
        fid_imap_int16 = $fopen({`SRC_PATH, "\\input_tensor_int16.txt"}, "r");
        if (fid_imap_int16) begin
            for (integer i = 0; i < imap_ROW_int16; i++) begin
                for (integer j = 0; j < block_c_imap_int16; j++) begin
                    $fscanf(fid_imap_int16, "%d", imap_int16[j]);
                end
                #10;
                u_axi_ram_imap.mem[i] = imap_int16_initial_data;
            end
            $fclose(fid_imap_int16);
        end else begin
            $error("Failed to open file: %s", {`SRC_PATH, "\\input_tensor_int16.txt"});
        end


    end

    generate

        for (genvar j = 0; j < block_c_imap_int8; j = j + 1) begin
            assign imap_int8_initial_data[IMAP_WIDTH/2*(j+1)-1:IMAP_WIDTH/2*j] = imap_int8[j];
        end

        for (genvar j = 0; j < block_c_imap_int16; j = j + 1) begin
            assign imap_int16_initial_data[IMAP_WIDTH*(j+1)-1:IMAP_WIDTH*j] = imap_int16[j];
        end

    endgenerate


    parameter weight_ROW_int8 = Kernel_height * Kernel_width * Ceil_Total_Out_channels_int8/block_c_weight_int8 * In_channels;
    parameter weight_ROW_int16 = Kernel_height * Kernel_width * Ceil_Total_Out_channels_int16/block_c_weight_int16 * In_channels;
    parameter weight_ROW_int8_dwc = Kernel_height * Kernel_width * Ceil_Total_Out_channels_int8/block_c_weight_int8 ;
    parameter weight_ROW_int16_dwc = Kernel_height * Kernel_width * Ceil_Total_Out_channels_int16/block_c_weight_int16 ;

    logic signed [WEIGHT_WIDTH/2-1:0] weight_int8[block_c_weight_int8-1:0];
    logic signed [WEIGHT_WIDTH-1:0] weight_int16[block_c_weight_int16-1:0];

    logic [BUS_WIDTH-1:0] weight_int8_initial_data;
    logic [BUS_WIDTH-1:0] weight_int16_initial_data;

    initial begin




        fid_weight_int8 = $fopen({`SRC_PATH, "\\kernel_int8.txt"}, "r");
        if (fid_weight_int8) begin
            for (integer i = 0; i < weight_ROW_int8; i++) begin
                for (integer j = 0; j < block_c_weight_int8; j++) begin
                    $fscanf(fid_weight_int8, "%d", weight_int8[j]);
                end
                #10;
                u_axi_ram_weight.mem[i] = weight_int8_initial_data;
            end
            $fclose(fid_weight_int8);

        end else begin
            $error("Failed to open file: %s", {`SRC_PATH, "\\kernel_int8.txt"});
        end
    end

    initial begin
        wait (done_flag);
        #(T * 10);
        fid_weight_int16 = $fopen({`SRC_PATH, "\\kernel_int16.txt"}, "r");
        if (fid_weight_int16) begin
            for (integer i = 0; i < weight_ROW_int16; i++) begin
                for (integer j = 0; j < block_c_weight_int16; j++) begin
                    $fscanf(fid_weight_int16, "%d", weight_int16[j]);
                end
                #10;
                u_axi_ram_weight.mem[i] = weight_int16_initial_data;
            end
            $fclose(fid_weight_int16);
        end else begin
            $error("Failed to open file: %s", {`SRC_PATH, "\\kernel_int16.txt"});
        end

    end

    generate

        for (genvar j = 0; j < block_c_weight_int8; j = j + 1) begin
            assign weight_int8_initial_data[WEIGHT_WIDTH/2*(j+1)-1:WEIGHT_WIDTH/2*j] = weight_int8[j];
        end

        for (genvar j = 0; j < block_c_weight_int16; j = j + 1) begin
            assign weight_int16_initial_data[WEIGHT_WIDTH*(j+1)-1:WEIGHT_WIDTH*j] = weight_int16[j];
        end

    endgenerate


    parameter bias_ROW_int8 = Output_height * Output_width * Ceil_Total_Out_channels_int8_bias/block_c_bias_int8 ;
    parameter bias_ROW_int16 = Output_height * Output_width * Ceil_Total_Out_channels_int16_bias/block_c_bias_int16 ;
    logic signed [BIAS_WIDTH/2-1:0] bias_int8[block_c_bias_int8-1:0];
    logic signed [BIAS_WIDTH-1:0] bias_int16[block_c_bias_int16-1:0];

    logic signed [BUS_WIDTH-1:0] bias_int8_initial_data;
    logic signed [BUS_WIDTH-1:0] bias_int16_initial_data;


    initial begin



        fid_bias_int8 = $fopen({`SRC_PATH, "\\bias_int8.txt"}, "r");
        if (fid_bias_int8) begin
            for (integer i = 0; i < bias_ROW_int8; i++) begin
                for (integer j = 0; j < block_c_bias_int8; j++) begin
                    $fscanf(fid_bias_int8, "%d", bias_int8[j]);
                end
                #10;
                u_axi_ram_bias_omap.mem[i] = bias_int8_initial_data;
            end
            $fclose(fid_bias_int8);

        end else begin
            $error("Failed to open file: %s", {`SRC_PATH, "\\bias_int8.txt"});
        end
    end

    initial begin
        wait (done_flag);
        #(T * 10);
        fid_bias_int16 = $fopen({`SRC_PATH, "\\bias_int16.txt"}, "r");
        if (fid_bias_int16) begin
            for (integer i = 0; i < bias_ROW_int16; i++) begin
                for (integer j = 0; j < block_c_bias_int16; j++) begin
                    $fscanf(fid_bias_int16, "%d", bias_int16[j]);
                end
                #10;
                u_axi_ram_bias_omap.mem[i] = bias_int16_initial_data;
            end
            $fclose(fid_bias_int16);
        end else begin
            $error("Failed to open file: %s", {`SRC_PATH, "\\bias_int16.txt"});
        end

    end

    generate

        for (genvar j = 0; j < block_c_bias_int8; j = j + 1) begin
            assign bias_int8_initial_data[BIAS_WIDTH/2*(j+1)-1:BIAS_WIDTH/2*j] = bias_int8[j];
        end

        for (genvar j = 0; j < block_c_bias_int16; j = j + 1) begin
            assign bias_int16_initial_data[BIAS_WIDTH*(j+1)-1:BIAS_WIDTH*j] = bias_int16[j];
        end

    endgenerate


    parameter bias2_ROW_int8 = Output_height * Output_width * Ceil_Total_Out_channels_int8_bias2/block_c_bias2_int8 ;
    parameter bias2_ROW_int16 = Output_height * Output_width * Ceil_Total_Out_channels_int16_bias2/block_c_bias2_int16 ;
    logic signed [BIAS2_WIDTH/2-1:0] bias2_int8[block_c_bias2_int8-1:0];
    logic signed [BIAS2_WIDTH-1:0] bias2_int16[block_c_bias2_int16-1:0];

    logic signed [BUS_WIDTH-1:0] bias2_int8_initial_data;
    logic signed [BUS_WIDTH-1:0] bias2_int16_initial_data;


    initial begin



        fid_bias2_int8 = $fopen({`SRC_PATH, "\\bias2_int8.txt"}, "r");
        if (fid_bias2_int8) begin
            for (integer i = 0; i < bias2_ROW_int8; i++) begin
                for (integer j = 0; j < block_c_bias2_int8; j++) begin
                    $fscanf(fid_bias2_int8, "%d", bias2_int8[j]);
                end
                #10;
                u_axi_ram_bias2.mem[i] = bias2_int8_initial_data;
            end
            $fclose(fid_bias2_int8);

        end else begin
            $error("Failed to open file: %s", {`SRC_PATH, "\\bias2_int8.txt"});
        end
    end

    initial begin
        wait (done_flag);
        #(T * 10);
        fid_bias2_int16 = $fopen({`SRC_PATH, "\\bias2_int16.txt"}, "r");
        if (fid_bias2_int16) begin
            for (integer i = 0; i < bias2_ROW_int16; i++) begin
                for (integer j = 0; j < block_c_bias2_int16; j++) begin
                    $fscanf(fid_bias2_int16, "%d", bias2_int16[j]);
                end
                #10;
                u_axi_ram_bias2.mem[i] = bias2_int16_initial_data;
            end
            $fclose(fid_bias2_int16);
        end else begin
            $error("Failed to open file: %s", {`SRC_PATH, "\\bias2_int16.txt"});
        end

    end

    generate

        for (genvar j = 0; j < block_c_bias2_int8; j = j + 1) begin
            assign bias2_int8_initial_data[BIAS2_WIDTH/2*(j+1)-1:BIAS2_WIDTH/2*j] = bias2_int8[j];
        end

        for (genvar j = 0; j < block_c_bias2_int16; j = j + 1) begin
            assign bias2_int16_initial_data[BIAS2_WIDTH*(j+1)-1:BIAS2_WIDTH*j] = bias2_int16[j];
        end

    endgenerate

    function integer find_max_row;
        input integer imap_ROW;
        input integer weight_ROW;
        input integer bias_ROW;
        input integer bias2_ROW;

        integer max_row;

        begin
            max_row = imap_ROW;

            if (weight_ROW > max_row) begin
                max_row = weight_ROW;
            end

            if (bias_ROW > max_row) begin
                max_row = bias_ROW;
            end
            if (bias2_ROW > max_row) begin
                max_row = bias2_ROW;
            end

            find_max_row = max_row;
        end
    endfunction

    parameter max_row_int8 = find_max_row(
        imap_ROW_int8, weight_ROW_int8, bias_ROW_int8, bias2_ROW_int8
    );
    parameter max_row_int16 = find_max_row(
        imap_ROW_int16, weight_ROW_int16, bias_ROW_int16, bias2_ROW_int16
    );


    initial begin
        is_fft   = 0;
        is_int16 = 0;

        #(max_row_int8 * 10 + 100);

        #(T * 2) mat_core_start = 0;


        #(T * 8) mat_core_start = 1;
        #(T * 1) mat_core_start = 0;

        wait (done_flag);
        #(max_row_int16 * 10 + 100);
        #(T * 100);


        #(T * 1) is_int16 = 1;
        #(T * 1) mat_core_start = 1;
        #(T * 1) mat_core_start = 0;




    end


    // ================================data_in=========================================

    // logic signed [WIDTH/2+1-1:0] mat_data_in_int8[GEMM_MAC_ROW_NUM-1:0];
    // logic signed [WIDTH+1-1:0] mat_data_in_int16[GEMM_MAC_ROW_NUM-1:0];

    logic [ODATA_WIDTH/2-1:0] mat_data_out_int8[GEMM_MAC_COL_NUM*2-1:0];
    logic [ACC_WIDTH/2-1:0] mat_acc_out_int8[GEMM_MAC_COL_NUM*2-1:0];
    logic [(IMAP_WIDTH+2)/2-1:0] imap_data_out_add_zeropoint_pad_int8[GEMM_MAC_ROW_NUM*2-1:0];
    wire use_add = ~(u_ai_acce.is_padding);

    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign {mat_data_out_int8[i*2+1], mat_data_out_int8[i*2]} = u_ai_acce.mat_data_out[i];
        end
    endgenerate
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign {mat_acc_out_int8[i*2+1], mat_acc_out_int8[i*2]} = u_ai_acce.u_multi_channel_acc_pool_fifo.acc_pool_out_w[i];
        end
    endgenerate

    generate
        for (genvar i = 0; i < GEMM_MAC_ROW_NUM; i = i + 1) begin
            assign {imap_data_out_add_zeropoint_pad_int8[i*2+1], imap_data_out_add_zeropoint_pad_int8[i*2]} = u_ai_acce.u_multi_channel_acc_pool_fifo.imap_data_out_add_zeropoint_pad[i];
        end
    endgenerate


    int mat_data_in_fd;

    initial begin
        wait (done_flag);
        mat_data_in_fd = $fopen({`OUT_DATA_PATH, "\\mat_data_in_int16.txt"}, "w");
        wait (finish_flag);
        #1;
        $fclose(mat_data_in_fd);
    end


    always @(posedge clk) begin
        if (is_stc) begin
            if (is_int16 && |u_ai_acce.mat_row_enable_mask) begin
                for (int i = 0; i < GEMM_MAC_ROW_NUM; i = i + 1) begin
                    if (u_ai_acce.mat_row_enable_mask[i] && ~(u_ai_acce.is_padding)) begin
                        $fwrite(
                            mat_data_in_fd, "%d ",
                            $signed(
                                u_ai_acce.u_pe_array_rect_select.mat_data_in_add_zero_point[i]));
                    end else begin
                        $fwrite(mat_data_in_fd, "0 ");
                    end
                end
                $fwrite(mat_data_in_fd, "\n");
            end
        end else begin
            if (is_int16 && |u_ai_acce.u_multi_channel_acc_pool_fifo.imap_data_out_add_zeropoint_pad_valid) begin
                for (int i = 0; i < GEMM_MAC_ROW_NUM; i = i + 1) begin
                    // if (u_ai_acce.u_multi_channel_acc_pool_fifo.imap_data_out_add_zeropoint_pad_valid[i] && ~(u_ai_acce.is_padding)) begin
                    $fwrite(
                        mat_data_in_fd, "%d ",
                        $signed(
                            u_ai_acce.u_multi_channel_acc_pool_fifo.imap_data_out_add_zeropoint_pad[i]));
                    // end else begin
                    //     $fwrite(mat_data_in_fd, "0 ");
                    // end
                end
                $fwrite(mat_data_in_fd, "\n");
            end
        end

    end

    int mat_data_in_int8_fd;
    initial begin
        mat_data_in_int8_fd = $fopen({`OUT_DATA_PATH, "\\mat_data_in_int8.txt"}, "w");
        wait (~is_int16 && done_flag);
        $fclose(mat_data_in_int8_fd);
    end


    always @(posedge clk) begin
        if (is_stc) begin
            if (~is_int16 && |u_ai_acce.mat_row_enable_mask) begin
                for (int i = 0; i < GEMM_MAC_ROW_NUM; i = i + 1) begin
                    if (u_ai_acce.mat_row_enable_mask[i] && ~(u_ai_acce.is_padding)) begin
                        $fwrite(
                            mat_data_in_int8_fd, "%d ",
                            $signed(
                                u_ai_acce.u_pe_array_rect_select.mat_data_in_add_zero_point[i]));
                    end else begin
                        $fwrite(mat_data_in_int8_fd, "0 ");
                    end
                end
                $fwrite(mat_data_in_int8_fd, "\n");
            end
        end else begin
            if (~is_int16 && |u_ai_acce.u_multi_channel_acc_pool_fifo.imap_data_out_add_zeropoint_pad_valid) begin
                for (int i = 0; i < GEMM_MAC_ROW_NUM * 2; i = i + 1) begin
                    // if (u_ai_acce.u_multi_channel_acc_pool_fifo.imap_data_out_add_zeropoint_pad_valid[i/2] && ~(u_ai_acce.is_padding)) begin
                    $fwrite(mat_data_in_int8_fd, "%d ",
                            $signed(imap_data_out_add_zeropoint_pad_int8[i]));
                    // end else begin
                    //     $fwrite(mat_data_in_int8_fd, "0 ");
                    // end
                end
                $fwrite(mat_data_in_int8_fd, "\n");
            end
        end

    end

    int mat_data_out_fd;
    initial begin
        mat_data_out_fd = $fopen({`OUT_DATA_PATH, "\\mat_data_out_int16.txt"}, "w");
        wait (finish_flag);
        #1;
        $fclose(mat_data_out_fd);
    end


    always @(posedge clk) begin
        if (is_stc) begin
            if (is_int16 && |u_ai_acce.mat_out_valid) begin
                for (int i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                    if (u_ai_acce.mat_out_valid[i]) begin
                        $fwrite(mat_data_out_fd, "%d ", $signed(u_ai_acce.mat_data_out[i]));
                    end else begin
                        $fwrite(mat_data_out_fd, "0 ");
                    end
                end
                $fwrite(mat_data_out_fd, "\n");
            end
        end else if (is_dwc) begin
            if (is_int16 && |u_ai_acce.u_multi_channel_acc_pool_fifo.in_valid) begin
                for (int i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                    if (u_ai_acce.u_multi_channel_acc_pool_fifo.in_valid[i]) begin
                        $fwrite(mat_data_out_fd, "%d ",
                                $signed(u_ai_acce.u_multi_channel_acc_pool_fifo.acc_in[i]));
                    end else begin
                        $fwrite(mat_data_out_fd, "0 ");
                    end
                end
                $fwrite(mat_data_out_fd, "\n");
            end
        end else begin
            if (is_int16 && |u_ai_acce.u_multi_channel_acc_pool_fifo.acc_pool_out_valid_w) begin
                for (int i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                    if (u_ai_acce.u_multi_channel_acc_pool_fifo.acc_pool_out_valid_w[i]) begin
                        $fwrite(mat_data_out_fd, "%d ",
                                $signed(u_ai_acce.u_multi_channel_acc_pool_fifo.acc_pool_out_w[i]));
                    end else begin
                        $fwrite(mat_data_out_fd, "0 ");
                    end
                end
                $fwrite(mat_data_out_fd, "\n");
            end
        end

    end

    int mat_data_out_int8_fd;
    initial begin
        mat_data_out_int8_fd = $fopen({`OUT_DATA_PATH, "\\mat_data_out_int8.txt"}, "w");
        wait (~is_int16 && done_flag);
        $fclose(mat_data_out_int8_fd);
    end


    always @(posedge clk) begin
        if (is_stc) begin
            if (~is_int16 && |u_ai_acce.mat_out_valid) begin
                for (int i = 0; i < GEMM_MAC_COL_NUM * 2; i = i + 1) begin
                    if (u_ai_acce.mat_out_valid[i/2]) begin
                        $fwrite(mat_data_out_int8_fd, "%d ", $signed(mat_data_out_int8[i]));
                    end else begin
                        $fwrite(mat_data_out_int8_fd, "0 ");
                    end
                end
                $fwrite(mat_data_out_int8_fd, "\n");
            end
        end else if (is_dwc) begin
            if (~is_int16 && |u_ai_acce.u_multi_channel_acc_pool_fifo.in_valid) begin
                for (int i = 0; i < GEMM_MAC_COL_NUM * 2; i = i + 1) begin
                    if (u_ai_acce.u_multi_channel_acc_pool_fifo.in_valid[i/2]) begin
                        $fwrite(mat_data_out_int8_fd, "%d ",
                                $signed(u_ai_acce.u_multi_channel_acc_pool_fifo.acc_in_int8[i]));
                    end else begin
                        $fwrite(mat_data_out_int8_fd, "0 ");
                    end
                end
                $fwrite(mat_data_out_int8_fd, "\n");
            end

        end else begin
            if (~is_int16 && |u_ai_acce.u_multi_channel_acc_pool_fifo.acc_pool_out_valid_w) begin
                for (int i = 0; i < GEMM_MAC_COL_NUM * 2; i = i + 1) begin
                    if (u_ai_acce.u_multi_channel_acc_pool_fifo.acc_pool_out_valid_w[i/2]) begin
                        $fwrite(mat_data_out_int8_fd, "%d ", $signed(mat_acc_out_int8[i]));
                    end else begin
                        $fwrite(mat_data_out_int8_fd, "0 ");
                    end
                end
                $fwrite(mat_data_out_int8_fd, "\n");
            end
        end

    end

    // ================================weight=========================================

    reg [8-1:0] mat_weight_in_int8[GEMM_MAC_COL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign {mat_weight_in_int8[i*2+1], mat_weight_in_int8[i*2]} = u_ai_acce.mat_weight_in[i];
        end
    endgenerate


    int mat_weight_in_fd;

    initial begin
        mat_weight_in_fd = $fopen({`OUT_DATA_PATH, "\\mat_weight_in_int16.txt"}, "w");
        wait (finish_flag);
        #1;
        $fclose(mat_weight_in_fd);
    end


    always @(posedge clk) begin
        if (~is_pool && is_int16 && |u_ai_acce.mat_col_in_valid) begin
            for (int i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                if (u_ai_acce.mat_col_in_valid[i]) begin
                    $fwrite(mat_weight_in_fd, "%d ", $signed(u_ai_acce.mat_weight_in[i]));
                end else begin
                    $fwrite(mat_weight_in_fd, "0 ");
                end
            end
            $fwrite(mat_weight_in_fd, "\n");
        end
    end

    int mat_weight_in_int8_fd;
    initial begin
        mat_weight_in_int8_fd = $fopen({`OUT_DATA_PATH, "\\mat_weight_in_int8.txt"}, "w");
        wait (~is_int16 && done_flag);
        $fclose(mat_weight_in_int8_fd);
    end


    always @(posedge clk) begin
        if (~is_pool && ~is_int16 && |u_ai_acce.mat_col_in_valid) begin
            for (int i = 0; i < GEMM_MAC_COL_NUM * 2; i = i + 1) begin
                if (u_ai_acce.mat_col_in_valid[i/2]) begin
                    $fwrite(mat_weight_in_int8_fd, "%d ", $signed(mat_weight_in_int8[i]));
                end else begin
                    $fwrite(mat_weight_in_int8_fd, "0 ");
                end
            end
            $fwrite(mat_weight_in_int8_fd, "\n");
        end
    end

    // for debug
    wire [ACC_WIDTH/2-1:0] acc_pool_out_int8[CHANNEL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {acc_pool_out_int8[i*2+1], acc_pool_out_int8[i*2]} = u_ai_acce.acc_pool_out[i];
        end
    endgenerate


    // ================================acc=========================================
    int acc_out_fd;

    initial begin
        acc_out_fd = $fopen({`OUT_DATA_PATH, "\\acc_pool_out_int16.txt"}, "w");
        wait (finish_flag);
        #1;
        $fclose(acc_out_fd);
    end


    always @(posedge clk) begin
        if (is_int16 && |u_ai_acce.acc_pool_out_valid) begin
            for (int i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                if (u_ai_acce.acc_pool_out_valid[i]) begin
                    $fwrite(acc_out_fd, "%d ", $signed(u_ai_acce.acc_pool_out[i]));
                end else begin
                    $fwrite(acc_out_fd, "0 ");
                end
            end
            $fwrite(acc_out_fd, "\n");
        end
    end

    int acc_out_int8_fd;
    initial begin
        acc_out_int8_fd = $fopen({`OUT_DATA_PATH, "\\acc_pool_out_int8.txt"}, "w");
        wait (~is_int16 && done_flag);
        $fclose(acc_out_int8_fd);
    end

    always @(posedge clk) begin
        if (~is_int16 && |u_ai_acce.acc_pool_out_valid) begin
            for (int i = 0; i < GEMM_MAC_COL_NUM * 2; i = i + 1) begin
                if (u_ai_acce.acc_pool_out_valid[i/2]) begin
                    $fwrite(acc_out_int8_fd, "%d ", $signed(acc_pool_out_int8[i]));
                end else begin
                    $fwrite(acc_out_int8_fd, "0 ");
                end
            end
            $fwrite(acc_out_int8_fd, "\n");
        end
    end


    // quan_relu_out
    wire [(QUAN_OUT_WIDTH+4)/2-1:0] quan_relu_out_int8[GEMM_MAC_COL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign {quan_relu_out_int8[i*2+1], quan_relu_out_int8[i*2]} = u_ai_acce.quan_relu_out[i];
        end
    endgenerate
    int quan_relu_out_int8_fd;
    initial begin
        quan_relu_out_int8_fd = $fopen({`OUT_DATA_PATH, "\\quan_relu_out_int8.txt"}, "w");
        wait (~is_int16 && done_flag);
        $fclose(quan_relu_out_int8_fd);
    end


    always @(posedge clk) begin
        if (~is_int16 && |u_ai_acce.quan_relu_out_valid) begin
            for (int i = 0; i < GEMM_MAC_COL_NUM * 2; i = i + 1) begin
                if (u_ai_acce.quan_relu_out_valid[i/2]) begin
                    $fwrite(quan_relu_out_int8_fd, "%d ", $signed(quan_relu_out_int8[i]));
                end else begin
                    $fwrite(quan_relu_out_int8_fd, "0 ");
                end
            end
            $fwrite(quan_relu_out_int8_fd, "\n");
        end
    end


    int quan_relu_out_int16_fd;
    initial begin
        quan_relu_out_int16_fd = $fopen({`OUT_DATA_PATH, "\\quan_relu_out_int16.txt"}, "w");
        wait (finish_flag);
        #1;
        $fclose(quan_relu_out_int16_fd);
    end


    always @(posedge clk) begin
        if (is_int16 && |u_ai_acce.quan_relu_out_valid) begin
            for (int i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                if (u_ai_acce.quan_relu_out_valid[i]) begin
                    $fwrite(quan_relu_out_int16_fd, "%d ", $signed(u_ai_acce.quan_relu_out[i]));
                end else begin
                    $fwrite(quan_relu_out_int16_fd, "0 ");
                end
            end
            $fwrite(quan_relu_out_int16_fd, "\n");
        end
    end

    // omap ddr
    parameter omap_ROW_int8 = Output_height * Output_width * Ceil_Total_Out_channels_int8/block_c_omap_int8 ;
    parameter omap_ROW_int16 = Output_height * Output_width * Ceil_Total_Out_channels_int16/block_c_omap_int16 ;

    logic signed [OMAP_WIDTH/2-1:0] omap_ddr_int8 [ omap_ROW_int8-1:0][ block_c_omap_int8-1:0];
    logic signed [  OMAP_WIDTH-1:0] omap_ddr_int16[omap_ROW_int16-1:0][block_c_omap_int16-1:0];

    always @(posedge clk) begin
        for (int i = 0; i < BUS_WIDTH / (OMAP_WIDTH / 2); i = i + 1) begin
            if (u_axi_ram_bias_omap.mem_wr_en) begin
                omap_ddr_int8[u_axi_ram_bias_omap.write_addr_valid-(2**VALID_ADDR_WIDTH/2)][i]<=u_axi_ram_bias_omap.s_axi_wdata[(OMAP_WIDTH/2)*i +: (OMAP_WIDTH/2)];
            end
        end
    end
    always @(posedge clk) begin
        for (int i = 0; i < BUS_WIDTH / (OMAP_WIDTH); i = i + 1) begin
            if (u_axi_ram_bias_omap.mem_wr_en) begin
                omap_ddr_int16[u_axi_ram_bias_omap.write_addr_valid-(2**VALID_ADDR_WIDTH/2)][i]<=u_axi_ram_bias_omap.s_axi_wdata[(OMAP_WIDTH)*i +: (OMAP_WIDTH)];
            end
        end
    end


    int omap_fd;

    initial begin
        omap_fd = $fopen({`OUT_DATA_PATH, "\\omap_ddr_int16.txt"}, "w");
        wait (is_int16 & done_flag);

        for (integer i = 0; i < omap_ROW_int16; i = i + 1) begin
            for (integer j = 0; j < BUS_WIDTH / OMAP_WIDTH; j = j + 1) begin
                $fwrite(omap_fd, "%d ", $signed(omap_ddr_int16[i][j]));
            end
            $fwrite(omap_fd, "\n");
        end

        $fclose(omap_fd);
    end

    int omap_fd_int8;
    initial begin
        omap_fd_int8 = $fopen({`OUT_DATA_PATH, "\\omap_ddr_int8.txt"}, "w");
        wait (~is_int16 & done_flag);

        for (integer i = 0; i < omap_ROW_int8; i = i + 1) begin
            for (integer j = 0; j < BUS_WIDTH / (OMAP_WIDTH / 2); j = j + 1) begin
                $fwrite(omap_fd_int8, "%d ", $signed(omap_ddr_int8[i][j]));
            end
            $fwrite(omap_fd_int8, "\n");
        end

        $fclose(omap_fd_int8);
    end


endmodule
