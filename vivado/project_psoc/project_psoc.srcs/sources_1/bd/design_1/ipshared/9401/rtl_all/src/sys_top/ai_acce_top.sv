




// (* DONT_TOUCH = "yes" *)
module ai_acce_top #(
    parameter C_M_AXI_BURST_LEN = 256,
    parameter C_M_AXI_ID_WIDTH = 2,
    parameter C_M_AXI_ADDR_WIDTH = 32,
    parameter C_M_AXI_DATA_WIDTH = 64,
    parameter C_M_AXI_AWUSER_WIDTH = 1,
    parameter C_M_AXI_ARUSER_WIDTH = 1,
    parameter C_M_AXI_WUSER_WIDTH = 1,
    parameter C_M_AXI_RUSER_WIDTH = 1,
    parameter C_M_AXI_BUSER_WIDTH = 1,

    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 32
) (

    input wire S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input wire S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output wire S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input wire S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output wire S_AXI_WREADY,
    // Write response. This signal indicates the status
    // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
    output wire S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input wire S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
    input wire S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
    output wire S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
    // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
    // signaling the required read data.
    output wire S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input wire S_AXI_RREADY,

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

    output wire fft_done_intr,
    output wire layer_done


);

    localparam WIDTH = 16;
    localparam GEMM_MAC_ROW_NUM = 16;
    localparam GEMM_MAC_COL_NUM = 16;
    localparam DUAL_MAC_ROW_NUM = GEMM_MAC_ROW_NUM / 2;
    localparam DUAL_MAC_COL_NUM = GEMM_MAC_COL_NUM / 2;
    localparam FFT_BUTTER_ROW_NUM = 4;
    localparam FFT_BUTTER_COL_NUM = DUAL_MAC_ROW_NUM * DUAL_MAC_COL_NUM / FFT_BUTTER_ROW_NUM;

    localparam INPUTS_NUM = DUAL_MAC_ROW_NUM;
    localparam OUTPUT_NUM = DUAL_MAC_ROW_NUM * 2;
    localparam STAGES_NUM = $clog2(DUAL_MAC_ROW_NUM);
    localparam ODATA_WIDTH = WIDTH * 2 + 2 + STAGES_NUM * 2;
    localparam SEL_WIDTH = $clog2(GEMM_MAC_ROW_NUM);

    // pe_array
    localparam MULT_DELAY = 1;
    localparam ADD_DELAY = 1;
    localparam READ_ADDR_GEN_DELAY = 3;//imap\weight\bias读地址产生逻辑的延迟（固定为3）
    localparam WRITE_ADDR_GEN_DELAY = 2;  //omap写地址产生逻辑的延迟（固定为2）
    localparam READ_ADDR_TO_DATA_OUT_DELAY = 2;  //给出读地址到数据读出的延迟
    localparam READ_DELAY_N = READ_ADDR_GEN_DELAY + READ_ADDR_TO_DATA_OUT_DELAY - 1;
    // localparam CAL_DELAY_M = $clog2(GEMM_MAC_ROW_NUM) + 2;  //计算阵列的延迟
    parameter NUM_DELAY_HEADS = 3;  // 延迟头的数量
    parameter int CAL_DELAY_STC = $clog2(GEMM_MAC_ROW_NUM) + 2;
    parameter int CAL_DELAY_DWC = 2;
    parameter int CAL_DELAY_POOL = 1;
    parameter int MAX_CAL_DELAY_M = CAL_DELAY_STC;

    localparam QUAN_DELAY_Q = 5;
    localparam MAX_BLOCK_DIM = 256;


    localparam DIM_WIDTH = $clog2(MAX_BLOCK_DIM);
    localparam IMAP_DIM_WIDTH = DIM_WIDTH + 2;
    // localparam IMAP_RAM_DEPTH = 2 ** 11;
    // localparam WEIGHT_RAM_DEPTH = 2 ** 11;
    // localparam BIAS_RAM_DEPTH = 2 ** 11;
    // localparam BIAS2_RAM_DEPTH = 2 ** 11;
    // localparam OMAP_RAM_DEPTH = 2 ** 11;
    localparam IMAP_RAM_DEPTH = 2 ** 11;
    localparam WEIGHT_RAM_DEPTH = 2 ** 10;
    localparam BIAS_RAM_DEPTH = 2 ** 10;
    localparam BIAS2_RAM_DEPTH = 2 ** 10;
    localparam OMAP_RAM_DEPTH = 2 ** 10;
    localparam IMAP_RAM_ADDR_WIDTH = $clog2(IMAP_RAM_DEPTH);
    localparam WEIGHT_RAM_ADDR_WIDTH = $clog2(WEIGHT_RAM_DEPTH);
    localparam BIAS_RAM_ADDR_WIDTH = $clog2(BIAS_RAM_DEPTH);
    localparam BIAS2_RAM_ADDR_WIDTH = $clog2(BIAS2_RAM_DEPTH);
    localparam OMAP_RAM_ADDR_WIDTH = $clog2(OMAP_RAM_DEPTH);

    localparam MAX_STRIDE_X = 3;
    localparam MAX_STRIDE_Y = 3;
    localparam MAX_DILATION_X = 3;
    localparam MAX_DILATION_Y = 3;
    localparam MAX_WIN_R = 9;
    localparam MAX_WIN_S = 9;
    localparam STRIDE_X_WIDTH = $clog2(MAX_STRIDE_X + 1);
    localparam STRIDE_Y_WIDTH = $clog2(MAX_STRIDE_Y + 1);
    localparam DILATION_X_WIDTH = $clog2(MAX_DILATION_X + 1);
    localparam DILATION_Y_WIDTH = $clog2(MAX_DILATION_Y + 1);
    localparam WIN_R_WIDTH = $clog2(MAX_WIN_R);
    localparam WIN_S_WIDTH = $clog2(MAX_WIN_S);

    //acc
    localparam CHANNEL_NUM = GEMM_MAC_COL_NUM;
    localparam ACC_WIDTH = ODATA_WIDTH;
    localparam FIFO_ACC_DEPTH = 2 ** 10;
    localparam FIFO_ACC_ADDR_WIDTH = $clog2(FIFO_ACC_DEPTH);

    //quan

    localparam QUAN_IN_WIDTH = ACC_WIDTH;  //
    localparam QUAN_OUT_WIDTH = 20;
    localparam SCALE_WIDTH = 16;
    localparam SHIFT_WIDTH = 4;
    localparam ZERO_POINT_WIDTH = 16;

    //bias2 add

    parameter BIAS2_WIDTH = 16;  // int16情况下的bias2位宽
    parameter BIAS2_RAM_WIDTH = 16;  //omap ram的位宽
    parameter BIAS2_SCALE_WIDTH = 16;
    parameter BIAS2_SHIFT_WIDTH = 4;

    //axi
    localparam BUS_WIDTH = C_M_AXI_DATA_WIDTH;
    localparam BUS_ADDR_WIDTH = 32;


    // control
    localparam MAX_NUM_DIM = 256;
    localparam NUM_WIDTH = $clog2(MAX_NUM_DIM);
    localparam IMAP_WIDTH = WIDTH;
    localparam PADDING_WIDTH = 5;
    localparam WEIGHT_WIDTH = WIDTH;
    localparam BIAS_WIDTH = 32;
    localparam OMAP_WIDTH = 16;
    localparam OMAP_RAM_WIDTH = ACC_WIDTH;

    localparam AIWIH_WIDTH = 20;  // 最大宽度*高度
    localparam AIW_WIDTH = 11;  //最大宽度
    localparam WICRS_WIDTH = 22;
    localparam WIC_WIDTH = 11;
    localparam AOWOH_WIDTH = 20;
    localparam AOW_WIDTH = 11;

    //fft
    localparam FFT_CORE_NUM = 1;
    localparam FFT_STAGE_WIDTH = 4;
    localparam FFT_SIGNLEN_WIDTH = 16;



    (* mark_debug = "false"*) wire ai_acce_clk;
    assign ai_acce_clk = clk;
    (* mark_debug = "false"*)wire                            mat_core_start;

    // wire                            layer_done;
    (* mark_debug = "false"*)wire                            is_mat_core_busy;
    (* mark_debug = "false"*)wire                            is_mat_core_ready;

    (* mark_debug = "false"*)wire [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_R_BASE_ADDR;  //32
    (* mark_debug = "false"*)wire [C_M_AXI_ADDR_WIDTH-1 : 0] imap_axi_W_BASE_ADDR;  //32
    (* mark_debug = "false"*)wire [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_R_BASE_ADDR;  //
    (* mark_debug = "false"*)wire [C_M_AXI_ADDR_WIDTH-1 : 0] weight_axi_W_BASE_ADDR;  //
    (* mark_debug = "false"*)wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_R_BASE_ADDR;  //3
    (* mark_debug = "false"*)wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias2_axi_W_BASE_ADDR;
    (* mark_debug = "false"*)wire [C_M_AXI_ADDR_WIDTH-1 : 0] bias_axi_R_BASE_ADDR;  //32
    (* mark_debug = "false"*)wire [C_M_AXI_ADDR_WIDTH-1 : 0] omap_axi_W_BASE_ADDR;  //32

    (* mark_debug = "false"*)wire                            is_fft;  //1
    (* mark_debug = "false"*)wire                            is_int16;  //1
    (* mark_debug = "false"*)wire                            relu_enable;  //1
    (* mark_debug = "false"*)wire                            use_quan_external;  //1
    (* mark_debug = "false"*)wire                            use_bias_external;  //1
    (* mark_debug = "false"*)wire                            bias_mode_external;  //1
    (* mark_debug = "false"*)wire                            use_bias2_add_external;  //1
    (* mark_debug = "false"*)wire                            is_pool;
    (* mark_debug = "false"*)wire                            pool_type;
    (* mark_debug = "false"*)wire [                     1:0] conv_type;
    (* mark_debug = "false"*)wire [       PADDING_WIDTH-1:0] padding_external            [3:0];  //8*4

    (* mark_debug = "false"*)wire [         WIN_R_WIDTH-1:0] total_len_r;  //8
    (* mark_debug = "false"*)wire [         WIN_S_WIDTH-1:0] total_len_s;  //8
    (* mark_debug = "false"*)wire [      STRIDE_X_WIDTH-1:0] stride_x;  //8
    (* mark_debug = "false"*)wire [      STRIDE_Y_WIDTH-1:0] stride_y;  //8
    (* mark_debug = "false"*)wire [    DILATION_X_WIDTH-1:0] dilation_x;  //8
    (* mark_debug = "false"*)wire [    DILATION_Y_WIDTH-1:0] dilation_y;  //8
    (* mark_debug = "false"*)wire [    ZERO_POINT_WIDTH-1:0] zero_point_in;
    (* mark_debug = "false"*)wire [    ZERO_POINT_WIDTH-1:0] zero_point_out;  //16
    (* mark_debug = "false"*)wire [         SCALE_WIDTH-1:0] scale;  //16
    (* mark_debug = "false"*)wire [         SHIFT_WIDTH-1:0] shift;  //8
    (* mark_debug = "false"*)wire [   BIAS2_SCALE_WIDTH-1:0] bias2_scale;  //16
    (* mark_debug = "false"*)wire [   BIAS2_SHIFT_WIDTH-1:0] bias2_shift;  //8

    (* mark_debug = "false"*)wire [           NUM_WIDTH-1:0] num_oc;  //8
    (* mark_debug = "false"*)wire [           NUM_WIDTH-1:0] num_ic;  //8
    (* mark_debug = "false"*)wire [           NUM_WIDTH-1:0] num_rs;  //8
    (* mark_debug = "false"*)wire [           NUM_WIDTH-1:0] num_ow;  //8
    (* mark_debug = "false"*)wire [           NUM_WIDTH-1:0] num_oh;  //8


    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] basic_oc;  //8
    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] basic_ic;  //8
    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] basic_rs;  //8
    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] basic_ow;  //8
    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] basic_oh;  //8


    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] remain_oc;  //8
    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] remain_ic;  //8
    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] remain_rs;  //8
    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] remain_ow;  //8
    (* mark_debug = "false"*)wire [           DIM_WIDTH-1:0] remain_oh;  //8


    (* mark_debug = "false"*)wire [      IMAP_DIM_WIDTH-1:0] basic_ow_sx;  //16
    (* mark_debug = "false"*)wire [      IMAP_DIM_WIDTH-1:0] basic_oh_sy;  //16
    (* mark_debug = "false"*)wire [      IMAP_DIM_WIDTH-1:0] basic_iw;  //16
    (* mark_debug = "false"*)wire [      IMAP_DIM_WIDTH-1:0] basic_ih;  //16
    (* mark_debug = "false"*)wire [      IMAP_DIM_WIDTH-1:0] remain_iw;  //16
    (* mark_debug = "false"*)wire [      IMAP_DIM_WIDTH-1:0] remain_ih;  //16

    (* mark_debug = "false"*)wire [         AIWIH_WIDTH-1:0] Aiwih;  //3232
    (* mark_debug = "false"*)wire [           AIW_WIDTH-1:0] Aiw;  //32
    (* mark_debug = "false"*)wire [         WICRS_WIDTH-1:0] Wicrs;  //3232
    (* mark_debug = "false"*)wire [           WIC_WIDTH-1:0] Wic;  //32
    (* mark_debug = "false"*)wire [         AOWOH_WIDTH-1:0] Aowoh;  //3232
    (* mark_debug = "false"*)wire [           AOW_WIDTH-1:0] Aow;  //32

    (* mark_debug = "false"*)wire                            fft_config;
    (* mark_debug = "false"*)wire                            fft_start;
    (* mark_debug = "false"*)wire                            is_ifft_mode;
    (* mark_debug = "false"*)wire [     FFT_STAGE_WIDTH-1:0] fft_stage;
    (* mark_debug = "false"*)wire [   FFT_SIGNLEN_WIDTH-1:0] fft_sign_len;

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
        .WIN_S_WIDTH                (WIN_S_WIDTH),
        .CHANNEL_NUM                (CHANNEL_NUM),
        .ACC_WIDTH                  (ACC_WIDTH),
        .FIFO_ACC_DEPTH             (FIFO_ACC_DEPTH),
        .FIFO_ACC_ADDR_WIDTH        (FIFO_ACC_ADDR_WIDTH),
        .QUAN_IN_WIDTH              (QUAN_IN_WIDTH),
        .QUAN_OUT_WIDTH             (QUAN_OUT_WIDTH),
        .SCALE_WIDTH                (SCALE_WIDTH),
        .SHIFT_WIDTH                (SHIFT_WIDTH),
        .BIAS2_SCALE_WIDTH          (BIAS2_SCALE_WIDTH),
        .BIAS2_SHIFT_WIDTH          (BIAS2_SHIFT_WIDTH),
        .ZERO_POINT_WIDTH           (ZERO_POINT_WIDTH),
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

        .FFT_STAGE_WIDTH  (FFT_STAGE_WIDTH),
        .FFT_SIGNLEN_WIDTH(FFT_SIGNLEN_WIDTH),
        .FFT_CORE_NUM     (FFT_CORE_NUM),

        .C_M_AXI_BURST_LEN   (C_M_AXI_BURST_LEN),
        .C_M_AXI_ID_WIDTH    (C_M_AXI_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH  (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH  (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH (C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH (C_M_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH (C_M_AXI_BUSER_WIDTH)
    ) u_ai_acce_core (
        .imap_m_axi_awready(imap_m_axi_awready),
        .imap_m_axi_wready (imap_m_axi_wready),
        .imap_m_axi_bid    (imap_m_axi_bid),
        .imap_m_axi_bresp  (imap_m_axi_bresp),
        .imap_m_axi_buser  (imap_m_axi_buser),
        .imap_m_axi_bvalid (imap_m_axi_bvalid),
        .imap_m_axi_arready(imap_m_axi_arready),
        .imap_m_axi_rid    (imap_m_axi_rid),
        .imap_m_axi_rdata  (imap_m_axi_rdata),
        .imap_m_axi_rresp  (imap_m_axi_rresp),
        .imap_m_axi_rlast  (imap_m_axi_rlast),
        .imap_m_axi_ruser  (imap_m_axi_ruser),
        .imap_m_axi_rvalid (imap_m_axi_rvalid),

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
        .zero_point_in         (zero_point_in),
        .zero_point_out        (zero_point_out),
        .scale                 (scale),
        .shift                 (shift),
        .bias2_scale           (bias2_scale),
        .bias2_shift           (bias2_shift),
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
        .imap_axi_W_BASE_ADDR  (imap_axi_W_BASE_ADDR),
        .weight_axi_R_BASE_ADDR(weight_axi_R_BASE_ADDR),
        .weight_axi_W_BASE_ADDR(weight_axi_W_BASE_ADDR),
        .bias2_axi_R_BASE_ADDR (bias2_axi_R_BASE_ADDR),
        .bias2_axi_W_BASE_ADDR (bias2_axi_W_BASE_ADDR),
        .bias_axi_R_BASE_ADDR  (bias_axi_R_BASE_ADDR),
        .omap_axi_W_BASE_ADDR  (omap_axi_W_BASE_ADDR),
        .padding_external      (padding_external),
        .Aiwih                 (Aiwih),
        .Aiw                   (Aiw),
        .Wicrs                 (Wicrs),
        .Wic                   (Wic),
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

        .fft_config(fft_config),
        .fft_start(fft_start),
        .is_ifft_mode(is_ifft_mode),
        .fft_stage(fft_stage),
        .fft_sign_len(fft_sign_len),
        .fft_done(fft_done),
        .fft_done_intr(fft_done_intr),

        .layer_done       (layer_done),
        .is_mat_core_busy (is_mat_core_busy),
        .is_mat_core_ready(is_mat_core_ready)
    );




    ai_acce_instr_encoder #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .DIM_WIDTH         (DIM_WIDTH),
        .IMAP_DIM_WIDTH    (IMAP_DIM_WIDTH),
        .STRIDE_X_WIDTH    (STRIDE_X_WIDTH),
        .STRIDE_Y_WIDTH    (STRIDE_Y_WIDTH),
        .DILATION_X_WIDTH  (DILATION_X_WIDTH),
        .DILATION_Y_WIDTH  (DILATION_Y_WIDTH),
        .WIN_R_WIDTH       (WIN_R_WIDTH),
        .WIN_S_WIDTH       (WIN_S_WIDTH),
        .SCALE_WIDTH       (SCALE_WIDTH),
        .SHIFT_WIDTH       (SHIFT_WIDTH),
        .BIAS2_SCALE_WIDTH (BIAS2_SCALE_WIDTH),
        .BIAS2_SHIFT_WIDTH (BIAS2_SCALE_WIDTH),
        .ZERO_POINT_WIDTH  (ZERO_POINT_WIDTH),
        .NUM_WIDTH         (NUM_WIDTH),
        .PADDING_WIDTH     (PADDING_WIDTH),
        .AIWIH_WIDTH       (AIWIH_WIDTH),
        .AIW_WIDTH         (AIW_WIDTH),
        .WICRS_WIDTH       (WICRS_WIDTH),
        .WIC_WIDTH         (WIC_WIDTH),
        .AOWOH_WIDTH       (AOWOH_WIDTH),
        .AOW_WIDTH         (AOW_WIDTH),
        .FFT_STAGE_WIDTH   (FFT_STAGE_WIDTH),
        .FFT_SIGNLEN_WIDTH (FFT_SIGNLEN_WIDTH),
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH)
    ) u_ai_acce_instr_encoder (
        .S_AXI_ACLK       (S_AXI_ACLK),
        .S_AXI_ARESETN    (S_AXI_ARESETN),
        .S_AXI_AWADDR     (S_AXI_AWADDR),
        .S_AXI_AWPROT     (S_AXI_AWPROT),
        .S_AXI_AWVALID    (S_AXI_AWVALID),
        .S_AXI_WDATA      (S_AXI_WDATA),
        .S_AXI_WSTRB      (S_AXI_WSTRB),
        .S_AXI_WVALID     (S_AXI_WVALID),
        .S_AXI_BREADY     (S_AXI_BREADY),
        .S_AXI_ARADDR     (S_AXI_ARADDR),
        .S_AXI_ARPROT     (S_AXI_ARPROT),
        .S_AXI_ARVALID    (S_AXI_ARVALID),
        .S_AXI_RREADY     (S_AXI_RREADY),
        .is_mat_core_busy (is_mat_core_busy),
        .layer_done       (layer_done),
        .is_mat_core_ready(is_mat_core_ready),
        .fft_done         (fft_done),

        .S_AXI_AWREADY         (S_AXI_AWREADY),
        .S_AXI_WREADY          (S_AXI_WREADY),
        .S_AXI_BRESP           (S_AXI_BRESP),
        .S_AXI_BVALID          (S_AXI_BVALID),
        .S_AXI_ARREADY         (S_AXI_ARREADY),
        .S_AXI_RDATA           (S_AXI_RDATA),
        .S_AXI_RRESP           (S_AXI_RRESP),
        .S_AXI_RVALID          (S_AXI_RVALID),
        .mat_core_start        (mat_core_start),
        .imap_axi_R_BASE_ADDR  (imap_axi_R_BASE_ADDR),
        .imap_axi_W_BASE_ADDR  (imap_axi_W_BASE_ADDR),
        .weight_axi_R_BASE_ADDR(weight_axi_R_BASE_ADDR),
        .weight_axi_W_BASE_ADDR(weight_axi_W_BASE_ADDR),
        .bias2_axi_R_BASE_ADDR (bias2_axi_R_BASE_ADDR),
        .bias2_axi_W_BASE_ADDR (bias2_axi_W_BASE_ADDR),
        .bias_axi_R_BASE_ADDR  (bias_axi_R_BASE_ADDR),
        .omap_axi_W_BASE_ADDR  (omap_axi_W_BASE_ADDR),
        .is_fft                (is_fft),
        .is_int16              (is_int16),
        .relu_enable           (relu_enable),
        .use_quan_external     (use_quan_external),
        .use_bias_external     (use_bias_external),
        .bias_mode_external    (bias_mode_external),
        .use_bias2_add_external(use_bias2_add_external),
        .is_pool               (is_pool),
        .pool_type             (pool_type),
        .conv_type             (conv_type),
        .padding_external      (padding_external),
        .total_len_r           (total_len_r),
        .total_len_s           (total_len_s),
        .stride_x              (stride_x),
        .stride_y              (stride_y),
        .dilation_x            (dilation_x),
        .dilation_y            (dilation_y),
        .zero_point_in         (zero_point_in),
        .zero_point_out        (zero_point_out),
        .scale                 (scale),
        .shift                 (shift),
        .bias2_scale           (bias2_scale),
        .bias2_shift           (bias2_shift),
        .num_oc                (num_oc),
        .num_ic                (num_ic),
        .num_rs                (num_rs),
        .num_ow                (num_ow),
        .num_oh                (num_oh),
        .basic_oc              (basic_oc),
        .basic_ic              (basic_ic),
        .basic_rs              (basic_rs),
        .basic_ow              (basic_ow),
        .basic_oh              (basic_oh),
        .remain_oc             (remain_oc),
        .remain_ic             (remain_ic),
        .remain_rs             (remain_rs),
        .remain_ow             (remain_ow),
        .remain_oh             (remain_oh),
        .basic_ow_sx           (basic_ow_sx),
        .basic_oh_sy           (basic_oh_sy),
        .basic_iw              (basic_iw),
        .basic_ih              (basic_ih),
        .remain_iw             (remain_iw),
        .remain_ih             (remain_ih),
        .Aiwih                 (Aiwih),
        .Aiw                   (Aiw),
        .Wicrs                 (Wicrs),
        .Wic                   (Wic),
        .Aowoh                 (Aowoh),
        .Aow                   (Aow),

        .fft_config  (fft_config),
        .fft_start   (fft_start),
        .is_ifft_mode(is_ifft_mode),
        .fft_stage   (fft_stage),
        .fft_sign_len(fft_sign_len)

    );




endmodule
