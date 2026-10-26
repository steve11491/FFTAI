


module convpool_L1_control #(
    parameter WIDTH = 16,
    parameter C_WIDTH = 32,
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


    parameter MULT_DELAY = 1,
    parameter ADD_DELAY  = 1,

    parameter READ_ADDR_GEN_DELAY = 3,//imap\weight\bias读地址产生逻辑的延迟（固定为3）
    parameter WRITE_ADDR_GEN_DELAY = 2,  //omap写地址产生逻辑的延迟（固定为2）
    // parameter READ_DELAY_N = 5,  //读取ram的延迟
    parameter READ_ADDR_TO_DATA_OUT_DELAY = 3,  //给出读地址到数据读出的延迟
    parameter READ_DELAY_N = READ_ADDR_GEN_DELAY + READ_ADDR_TO_DATA_OUT_DELAY - 1,
    // parameter CAL_DELAY_M = $clog2(GEMM_MAC_ROW_NUM),  //计算阵列的延迟
    parameter NUM_DELAY_HEADS = 3,  // 延迟头的数量
    parameter CAL_DELAY_STC = $clog2(GEMM_MAC_ROW_NUM) + 2,
    parameter CAL_DELAY_DWC = 2,
    parameter CAL_DELAY_POOL = 1,
    parameter MAX_CAL_DELAY_M = CAL_DELAY_STC,

    // parameter QUAN_DELAY_Q = 4,  // 量化的延迟：int8:4。int16:5
    parameter QUAN_DELAY_Q = 3,  // 量化的延迟：int8:3。int16:4
    parameter MAX_BLOCK_DIM = 128,
    parameter SEL_WIDTH = $clog2(GEMM_MAC_ROW_NUM),
    parameter DIM_WIDTH = $clog2(MAX_BLOCK_DIM) + 1,
    parameter IMAP_DIM_WIDTH = DIM_WIDTH + 2,

    parameter IMAP_RAM_DEPTH = 1024,
    parameter WEIGHT_RAM_DEPTH = 1024,
    parameter BIAS_RAM_DEPTH = 1024,
    parameter BIAS2_RAM_DEPTH = 1024,
    parameter OMAP_RAM_DEPTH = 1024,
    parameter IMAP_RAM_ADDR_WIDTH = $clog2(IMAP_RAM_DEPTH),
    parameter WEIGHT_RAM_ADDR_WIDTH = $clog2(WEIGHT_RAM_DEPTH),
    parameter BIAS_RAM_ADDR_WIDTH = $clog2(BIAS_RAM_DEPTH),
    parameter BIAS2_RAM_ADDR_WIDTH = $clog2(BIAS2_RAM_DEPTH),
    parameter OMAP_RAM_ADDR_WIDTH = $clog2(OMAP_RAM_DEPTH),

    parameter MAX_STRIDE_X = 2,
    parameter MAX_STRIDE_Y = 2,
    parameter MAX_DILATION_X = 3,
    parameter MAX_DILATION_Y = 3,
    parameter MAX_WIN_R = 5,
    parameter MAX_WIN_S = 5,
    parameter STRIDE_X_WIDTH = $clog2(MAX_STRIDE_X + 1),
    parameter STRIDE_Y_WIDTH = $clog2(MAX_STRIDE_Y + 1),
    parameter DILATION_X_WIDTH = $clog2(MAX_DILATION_X + 1),
    parameter DILATION_Y_WIDTH = $clog2(MAX_DILATION_Y + 1),
    parameter WIN_R_WIDTH = $clog2(MAX_WIN_R),
    parameter WIN_S_WIDTH = $clog2(MAX_WIN_S)
) (
    input wire                               clk,
    input wire                               rstn,
    input wire                               is_int16,
    // input wire is_matmul,
    input wire                               is_pool,
    input wire                               pool_type,
    input wire [                        1:0] conv_type,
    input wire                               start,
    input wire [            DIM_WIDTH*2-1:0] block_len_owh,  // 输出特征图平铺长度
    input wire [              DIM_WIDTH-1:0] block_len_ic,   // 输入通道平铺长度
    input wire [              DIM_WIDTH-1:0] block_len_oc,   //输出通道平铺长度
    input wire [WIN_R_WIDTH*WIN_S_WIDTH-1:0] block_len_rs,   //窗口平铺长度

    input wire [IMAP_DIM_WIDTH*2-1:0] block_len_iwh,  // 输入特征图平铺长度
    input wire [  IMAP_DIM_WIDTH-1:0] block_len_iw,   // 输入特征图块宽度
    input wire [  IMAP_DIM_WIDTH-1:0] block_len_ih,   // 输入特征图块高度

    input wire [DIM_WIDTH-1:0] block_len_ow,  // 输出特征图块宽度
    input wire [DIM_WIDTH-1:0] block_len_oh,  // 输出特征图块高度

    input wire [WIN_R_WIDTH-1:0] total_len_r,  //窗口整体高度
    input wire [WIN_S_WIDTH-1:0] total_len_s,  //窗口整体宽度

    input wire total_rs_start,
    input wire total_rs_done,

    input wire [  STRIDE_X_WIDTH-1:0] stride_x,
    input wire [  STRIDE_Y_WIDTH-1:0] stride_y,
    input wire [DILATION_X_WIDTH-1:0] dilation_x,
    input wire [DILATION_Y_WIDTH-1:0] dilation_y,

    input wire use_bias_internal,
    // input wire is_bias_first,
    input wire bias_mode_internal,//内部bias的形式，bias_mode=0是向量模式，输出特征图每个通道上的数据加上一个相同的bias，
    //bias_mode=1是张量模式，输出特征图上任意一个点的bias都不一样

    input wire use_quan,
    input wire use_bias2_add,
    input wire [IMAP_DIM_WIDTH-1:0] L1_block_len_iwih_border[3:0],  // 0-3 right|left|bottom|top
    output wire is_padding,

    //================================================= pe array interface
    output reg weight_pingpong,
    output reg [SEL_WIDTH-1:0] mat_weight_in_row_sel,
    output reg [GEMM_MAC_COL_NUM-1:0] mat_col_enable_mask,
    output reg [GEMM_MAC_ROW_NUM-1:0] mat_row_enable_mask,

    // ================================================= acc array interface
                          output reg                             acc_pool_out_enable,
    (*MAX_FANOUT = 128 *) output reg                             is_acc_pool_first,
                          output reg                             fifo_acc_rd_en,
                          output reg [     GEMM_MAC_COL_NUM-1:0] acc_pool_enable_mask,
    //================================================= bram bank interface
                          output reg [  IMAP_RAM_ADDR_WIDTH-1:0] imap_addr,
                          output reg [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_addr,
                          output reg [  BIAS_RAM_ADDR_WIDTH-1:0] bias_addr,
                          output reg [ BIAS2_RAM_ADDR_WIDTH-1:0] bias2_addr,
                          output reg [  OMAP_RAM_ADDR_WIDTH-1:0] omap_addr,

    output reg [GEMM_MAC_ROW_NUM-1:0] imap_ren,
    output reg [GEMM_MAC_COL_NUM-1:0] weight_ren,
    output reg [GEMM_MAC_COL_NUM-1:0] bias_ren,
    output reg [GEMM_MAC_COL_NUM-1:0] bias2_ren,
    output reg [GEMM_MAC_COL_NUM-1:0] omap_wen,

    output wire imap_ric_even_odd_flag,



    //================================================= status interface
    output reg is_pe_array_busy
);
    localparam STC = 0, DWC = 1;
    localparam MAX_POOL = 1'b0, AVG_POOL = 1'b1;

    // wire is_maxpool = (is_pool && (pool_type == MAX_POOL));
    // wire is_avgpool = (is_pool && (pool_type == AVG_POOL));
    // wire is_conv = ~is_pool;
    // wire is_stc = ((~is_pool) && (conv_type == STC));
    // wire is_dwc = ((~is_pool) && (conv_type == DWC));
    // wire is_use_acc = (~is_pool) | is_avgpool;

    reg is_maxpool;
    reg is_avgpool;
    reg is_conv;
    reg is_stc;
    reg is_not_stc;
    reg is_dwc;
    reg is_use_acc;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_maxpool <= 0;
            is_avgpool <= 0;
            is_conv <= 0;
            is_stc <= 0;
            is_not_stc <= 0;
            is_dwc <= 0;
            is_use_acc <= 0;
        end else begin
            is_maxpool <= (is_pool && (pool_type == MAX_POOL));
            is_avgpool <= (is_pool && (pool_type == AVG_POOL));
            is_conv <= ~is_pool;
            is_stc <= ((~is_pool) && (conv_type == STC));
            is_not_stc <= ~((~is_pool) && (conv_type == STC));
            is_dwc <= ((~is_pool) && (conv_type == DWC));
            is_use_acc <= (~is_pool) | is_avgpool;
        end
    end

    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
        end else begin
            is_int16_reg <= is_int16;
        end
    end


    // wire is_dw_conv = 1'b0;

    wire load_weight_continue = 0;
    reg weight_load_finish_t;
    reg feature_load_finish_t;
    reg is_not_first_t;

    reg weight_load_finish;
    reg feature_load_finish;
    reg feature_write_finish;
    reg is_not_first;


    //状态机
    localparam S_IDLE = 0, S_LOAD_WEIGHT = 1, S_LOAD_CAL = 2, S_WRITE = 3;
    // localparam S_CAL_LOAD_NEXT = 3, S_CAL_ONLY = 4;

    reg [2:0] curr_state, next_state;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            curr_state <= 0;
        end else begin
            curr_state <= next_state;
        end
    end

    always @(*) begin
        begin
            case (curr_state)
                S_IDLE: begin
                    if (start) begin
                        if (is_not_stc) begin
                            next_state = S_LOAD_CAL;
                        end else begin
                            next_state = S_LOAD_WEIGHT;
                        end

                    end else begin
                        next_state = S_IDLE;
                    end
                end
                S_LOAD_WEIGHT: begin
                    if (is_not_first) begin
                        next_state = S_LOAD_CAL;
                    end else begin
                        next_state = S_LOAD_WEIGHT;
                    end
                end
                S_LOAD_CAL: begin
                    if (feature_load_finish) begin
                        next_state = S_WRITE;
                    end else begin
                        next_state = S_LOAD_CAL;
                    end
                end
                S_WRITE: begin
                    if (feature_write_finish) begin
                        next_state = S_IDLE;
                    end else begin
                        next_state = S_WRITE;
                    end
                end

                default: begin
                    next_state = S_IDLE;
                end
            endcase
        end
    end


    wire pe_array_read_fea_enable;
    assign is_pe_array_busy = (curr_state != S_IDLE);
    assign pe_array_read_fea_enable = (curr_state == S_LOAD_CAL);
    // assign pe_array_read_fea_enable = (curr_state == S_CAL_LOAD_NEXT) || (curr_state == S_LOAD_CAL)|| (curr_state == S_CAL_ONLY);

    reg is_ri_weight_load_finish;
    reg is_ri_feature_load_finish;
    wire is_ri_weight_load_ing;
    wire is_ri_feature_load_ing;

    wire is_acc_out_ing_w;
    wire is_acc_out_ing;
    reg is_bias2_add_ing;
    reg is_wi_feature_write_ing;//is_ro_feature_write_start_pulse 经过detect_pulse_delay wh个周期后，再延迟？个周期，？根据是否经过量化有不同



    wire is_ri_feature_write_start_pulse;
    wire is_ro_feature_write_start_pulse;  // delay N

    reg [SEL_WIDTH-1:0] mat_weight_in_ri_row_sel;
    reg [SEL_WIDTH-1:0] mat_weight_in_ro_row_sel;  // delay N

    reg [BIAS_RAM_ADDR_WIDTH-1:0] bias_acci_addr;
    reg [GEMM_MAC_COL_NUM-1:0] bias_acci_ren;
    reg [BIAS_RAM_ADDR_WIDTH-1:0] bias_acco_addr;  // delay M
    reg [GEMM_MAC_COL_NUM-1:0] bias_acco_ren;  // delay M

    reg ri_weight_pingpong;
    reg ro_weight_pingpong;  // delay N

    reg [GEMM_MAC_ROW_NUM-1:0] ri_row_mask_ic_fea;
    reg [GEMM_MAC_COL_NUM-1:0] ri_col_mask_oc_fea;


    reg [GEMM_MAC_ROW_NUM-1:0] ro_row_mask_ic_fea;  // delay N
    reg [GEMM_MAC_COL_NUM-1:0] ro_col_mask_oc_fea;  // delay N
    reg [GEMM_MAC_COL_NUM-1:0] acco_col_mask_oc_fea;  // delay N+M

    reg is_cnt_ri_block_len_rs_ic_fea_start;
    reg is_cnt_acco_block_len_rs_ic_fea_start;  // delay N+M

    reg [GEMM_MAC_COL_NUM-1:0] ri_col_mask_oc_wei;
    reg [GEMM_MAC_COL_NUM-1:0] acc_col_mask_oc_fea;
    reg [GEMM_MAC_COL_NUM-1:0] bias2_add_col_mask_oc_fea;
    reg [GEMM_MAC_COL_NUM-1:0] wi_col_mask_oc_fea;

    localparam log2_ROW_NUM = $clog2(GEMM_MAC_ROW_NUM);
    localparam log2_COL_NUM = $clog2(GEMM_MAC_COL_NUM);
    localparam CNT_IC_SEL_WIDTH = log2_ROW_NUM;
    localparam CNT_IC_WIDTH = DIM_WIDTH - log2_ROW_NUM;
    localparam CNT_OC_WIDTH = DIM_WIDTH - log2_COL_NUM;

    reg [DIM_WIDTH*2-1:0] cnt_ri_block_len_owh;  // 读特征图 宽高方向/矩阵A的行计数
    reg [DIM_WIDTH-1:0] cnt_ri_block_len_rs_wei;  //读权重 卷积窗口方向计数
    reg [DIM_WIDTH-1:0] cnt_ri_block_len_rs_fea;  //读特征图 卷积窗口方向计数
    reg [CNT_IC_WIDTH-1:0] cnt_ri_block_len_ic_wei;  // 读权重 输入通道方向/矩阵A的大列计数
    reg [CNT_IC_WIDTH-1:0] cnt_ri_block_len_ic_fea;// 读特征图 输入通道方向/矩阵A的大列计数
    reg [DIM_WIDTH*2-1:0] cnt_ri_block_len_ic_sel;  // 权重/矩阵B的行选择计数
    reg [CNT_OC_WIDTH-1:0] cnt_ri_block_len_oc_wei;  // 读权重 输出通道方向/矩阵D的大列计数
    reg [CNT_OC_WIDTH-1:0] cnt_ri_block_len_oc_fea;// 读特征图 输出通道方向/矩阵D的大列计数

    reg [DIM_WIDTH-1:0] cnt_ri_block_ind_ow;  // 读特征图 宽方向计数
    reg [DIM_WIDTH-1:0] cnt_ri_block_ind_oh;  // 读特征图 高方向计数
    reg [WIN_R_WIDTH-1:0] cnt_ri_total_ind_r;  // 读特征图 卷积窗口高方向计数
    reg [WIN_S_WIDTH-1:0] cnt_ri_total_ind_s;  // 读特征图 卷积窗口宽方向计数

    reg [DIM_WIDTH*2-1:0] cnt_acc_block_len_owh;// 读acc fifo 宽高方向/矩阵A的行计数
    reg [CNT_OC_WIDTH-1:0] cnt_acc_block_len_oc_fea;// 读acc fifo 输出通道方向/矩阵D的大列计数

    reg [DIM_WIDTH*2-1:0] cnt_bias2_add_block_len_owh;// 读bias2 宽高方向/矩阵A的行计数
    reg [CNT_OC_WIDTH-1:0] cnt_bias2_add_block_len_oc_fea;// 读bias2 输出通道方向/矩阵D的大列计数

    reg [DIM_WIDTH*2-1:0] cnt_wi_block_len_owh;// 写输出特征图 宽高方向/矩阵A的行计数
    reg [CNT_OC_WIDTH-1:0] cnt_wi_block_len_oc_fea;// 写输出特征图 输出通道方向/矩阵D的大列计数

    localparam DELAY_SEL_WIDTH = $clog2(NUM_DELAY_HEADS);
    wire [DELAY_SEL_WIDTH-1:0] delay_sel;
    delay_selector #(
        .NUM_DELAY_HEADS(NUM_DELAY_HEADS),
        .DELAY_SEL_WIDTH(DELAY_SEL_WIDTH)
    ) u_delay_selector (
        .is_maxpool(is_maxpool),
        .is_avgpool(is_avgpool),
        .is_stc(is_stc),
        .is_dwc(is_dwc),
        .sel(delay_sel)
    );
    control_signal_delay #(
        .GEMM_MAC_ROW_NUM   (GEMM_MAC_ROW_NUM),
        .GEMM_MAC_COL_NUM   (GEMM_MAC_COL_NUM),
        .BIAS_RAM_ADDR_WIDTH(BIAS_RAM_ADDR_WIDTH),
        .SEL_WIDTH          (SEL_WIDTH),
        .READ_DELAY_N       (READ_DELAY_N),
        .CAL_DELAY_M        (CAL_DELAY_STC),
        .NUM_DELAY_HEADS    (NUM_DELAY_HEADS),
        .CAL_DELAY_STC      (CAL_DELAY_STC),
        .CAL_DELAY_DWC      (CAL_DELAY_DWC),
        .CAL_DELAY_POOL     (CAL_DELAY_POOL),
        .MAX_CAL_DELAY_M    (MAX_CAL_DELAY_M),
        .DELAY_SEL_WIDTH    (DELAY_SEL_WIDTH)
    ) u_control_signal_delay (
        .clk                                (clk),
        .rstn                               (rstn),
        .sel                                (delay_sel),
        .is_ri_feature_write_start_pulse    (is_ri_feature_write_start_pulse),
        .mat_weight_in_ri_row_sel           (mat_weight_in_ri_row_sel),
        .bias_acci_addr                     (bias_acci_addr),
        .bias_acci_ren                      (bias_acci_ren),
        .ri_weight_pingpong                 (ri_weight_pingpong),
        .ri_row_mask_ic_fea                 (ri_row_mask_ic_fea),
        .ri_col_mask_oc_fea                 (ri_col_mask_oc_fea),
        .is_cnt_ri_block_len_rs_ic_fea_start(is_cnt_ri_block_len_rs_ic_fea_start),

        .is_ro_feature_write_start_pulse      (is_ro_feature_write_start_pulse),
        .mat_weight_in_ro_row_sel             (mat_weight_in_ro_row_sel),
        .bias_acco_addr                       (bias_acco_addr),
        .bias_acco_ren                        (bias_acco_ren),
        .ro_weight_pingpong                   (ro_weight_pingpong),
        .ro_row_mask_ic_fea                   (ro_row_mask_ic_fea),
        .ro_col_mask_oc_fea                   (ro_col_mask_oc_fea),
        .acco_col_mask_oc_fea                 (acco_col_mask_oc_fea),
        .is_cnt_acco_block_len_rs_ic_fea_start(is_cnt_acco_block_len_rs_ic_fea_start)
    );

    wire is_cnt_ri_block_len_rs_fea_start;
    wire is_cnt_ri_block_len_ic_fea_start;
    assign is_cnt_ri_block_len_rs_fea_start = (cnt_ri_block_len_rs_fea == 0);
    assign is_cnt_ri_block_len_ic_fea_start = (cnt_ri_block_len_ic_fea == 0);
    assign  is_cnt_ri_block_len_rs_ic_fea_start = is_ri_feature_load_ing & is_cnt_ri_block_len_rs_fea_start & ((is_stc && is_cnt_ri_block_len_ic_fea_start) | is_not_stc );

    wire is_cnt_ri_block_len_owh_end;
    wire is_cnt_ri_block_len_rs_wei_end;
    wire is_cnt_ri_block_len_rs_fea_end;
    wire is_cnt_ri_block_len_ic_wei_end;
    wire is_cnt_ri_block_len_ic_fea_end;
    wire is_cnt_ri_block_len_ic_sel_end;
    wire is_cnt_ri_block_len_oc_wei_end;
    wire is_cnt_ri_block_len_oc_fea_end;
    wire [DIM_WIDTH*2-1:0] cnt_ri_block_len_owh_end;
    wire [DIM_WIDTH-1:0] cnt_ri_block_len_rs_end;
    wire [CNT_IC_WIDTH-1:0] cnt_ri_block_len_ic_end;
    wire [CNT_IC_SEL_WIDTH-1:0] cnt_ri_block_len_ic_sel_end;
    wire [CNT_OC_WIDTH-1:0] cnt_ri_block_len_oc_end;

    // parameter MIN_M = (MULT_DELAY + ADD_DELAY * $clog2((GEMM_MAC_ROW_NUM)));

    assign cnt_ri_block_len_owh_end = ( (~is_dwc) && block_len_owh < cnt_ri_block_len_ic_sel_end && (is_ri_weight_load_ing)) ? cnt_ri_block_len_ic_sel_end : block_len_owh;
    assign cnt_ri_block_len_rs_end = block_len_rs;
    assign cnt_ri_block_len_ic_end = (is_not_stc)? (is_int16_reg ? block_len_ic[DIM_WIDTH-1:log2_ROW_NUM]:{1'b0,{block_len_ic[DIM_WIDTH-1:log2_ROW_NUM+1]}}) : (block_len_ic[DIM_WIDTH-1:log2_ROW_NUM]);
    assign  cnt_ri_block_len_ic_sel_end = is_cnt_ri_block_len_ic_wei_end ? {{block_len_ic[log2_ROW_NUM-1:0]}} : ({{log2_ROW_NUM{1'b1}}});
    assign cnt_ri_block_len_oc_end = is_int16_reg?(block_len_oc[DIM_WIDTH-1:log2_COL_NUM]):({1'b0,{block_len_oc[DIM_WIDTH-1:log2_COL_NUM+1]}});

    assign is_cnt_ri_block_len_owh_end = (cnt_ri_block_len_owh == cnt_ri_block_len_owh_end);
    assign is_cnt_ri_block_len_rs_wei_end = (cnt_ri_block_len_rs_wei == cnt_ri_block_len_rs_end);
    assign is_cnt_ri_block_len_rs_fea_end = (cnt_ri_block_len_rs_fea == cnt_ri_block_len_rs_end);
    assign is_cnt_ri_block_len_ic_wei_end = (cnt_ri_block_len_ic_wei == cnt_ri_block_len_ic_end);
    assign is_cnt_ri_block_len_ic_fea_end = (cnt_ri_block_len_ic_fea == cnt_ri_block_len_ic_end);
    assign is_cnt_ri_block_len_ic_sel_end = (cnt_ri_block_len_ic_sel >= cnt_ri_block_len_ic_sel_end);
    assign is_cnt_ri_block_len_oc_wei_end = (cnt_ri_block_len_oc_wei == cnt_ri_block_len_oc_end);
    assign is_cnt_ri_block_len_oc_fea_end = (cnt_ri_block_len_oc_fea == cnt_ri_block_len_oc_end);

    // acc
    wire is_cnt_acc_block_len_owh_end;
    wire is_cnt_acc_block_len_oc_fea_end;
    wire [DIM_WIDTH*2-1:0] cnt_acc_block_len_owh_end;
    wire [CNT_OC_WIDTH-1:0] cnt_acc_block_len_oc_end;

    assign cnt_acc_block_len_owh_end = block_len_owh;
    assign cnt_acc_block_len_oc_end = is_int16_reg?(block_len_oc[DIM_WIDTH-1:log2_COL_NUM]):({1'b0,{block_len_oc[DIM_WIDTH-1:log2_COL_NUM+1]}});
    assign is_cnt_acc_block_len_owh_end = (cnt_acc_block_len_owh == cnt_acc_block_len_owh_end);
    assign is_cnt_acc_block_len_oc_fea_end = (cnt_acc_block_len_oc_fea == cnt_acc_block_len_oc_end);

    //bias2 add
    wire is_cnt_bias2_add_block_len_owh_end;
    wire is_cnt_bias2_add_block_len_oc_fea_end;
    wire [DIM_WIDTH*2-1:0] cnt_bias2_add_block_len_owh_end;
    wire [CNT_OC_WIDTH-1:0] cnt_bias2_add_block_len_oc_end;

    assign cnt_bias2_add_block_len_owh_end = block_len_owh;
    assign cnt_bias2_add_block_len_oc_end = is_int16_reg?(block_len_oc[DIM_WIDTH-1:log2_COL_NUM]):({1'b0,{block_len_oc[DIM_WIDTH-1:log2_COL_NUM+1]}});
    assign is_cnt_bias2_add_block_len_owh_end = (cnt_bias2_add_block_len_owh == cnt_bias2_add_block_len_owh_end);
    assign is_cnt_bias2_add_block_len_oc_fea_end = (cnt_bias2_add_block_len_oc_fea == cnt_bias2_add_block_len_oc_end);



    // write omap
    wire is_cnt_wi_block_len_owh_end;
    wire is_cnt_wi_block_len_oc_fea_end;
    wire [DIM_WIDTH*2-1:0] cnt_wi_block_len_owh_end;
    wire [CNT_OC_WIDTH-1:0] cnt_wi_block_len_oc_end;

    assign cnt_wi_block_len_owh_end = block_len_owh;
    assign cnt_wi_block_len_oc_end = is_int16_reg?(block_len_oc[DIM_WIDTH-1:log2_COL_NUM]):({1'b0,{block_len_oc[DIM_WIDTH-1:log2_COL_NUM+1]}});
    assign is_cnt_wi_block_len_owh_end = (cnt_wi_block_len_owh == cnt_wi_block_len_owh_end);
    assign is_cnt_wi_block_len_oc_fea_end = (cnt_wi_block_len_oc_fea == cnt_wi_block_len_oc_end);




    //========== 标志信号产生 ==========
    assign is_not_first = (cnt_ri_block_len_ic_sel == (cnt_ri_block_len_ic_sel_end));
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_not_first_t <= 0;
        end else if ((cnt_ri_block_len_ic_sel == (cnt_ri_block_len_ic_sel_end - 1))) begin
            is_not_first_t <= 1;
        end else if (~is_pe_array_busy) begin
            is_not_first_t <= 0;
        end
    end


    // assign is_ri_weight_load_finish_pulse = is_cnt_ri_block_len_owh_end & is_cnt_ri_block_len_rs_wei_end & 
    //                                         is_cnt_ri_block_len_ic_wei_end & is_cnt_ri_block_len_oc_wei_end;
    assign is_ri_weight_load_finish_pulse = (~(cnt_ri_block_len_rs_end==0 && cnt_ri_block_len_ic_end==0 && cnt_ri_block_len_oc_end==0)
                                            & is_cnt_ri_block_len_owh_end & is_cnt_ri_block_len_rs_wei_end & 
                                            ((is_cnt_ri_block_len_ic_wei_end & is_stc) | is_dwc) & is_cnt_ri_block_len_oc_wei_end)
                                            || ((cnt_ri_block_len_rs_end==0 && cnt_ri_block_len_ic_end==0 && cnt_ri_block_len_oc_end==0)
                                            & ((is_cnt_ri_block_len_ic_sel_end& is_stc) | is_dwc));

    assign  is_ri_feature_load_finish_pulse = is_cnt_ri_block_len_owh_end & is_cnt_ri_block_len_rs_fea_end &
                                            is_cnt_ri_block_len_ic_fea_end & is_cnt_ri_block_len_oc_fea_end;

    // assign  is_ri_feature_write_start_pulse = is_ri_feature_load_ing & is_cnt_ri_block_len_ic_fea_end  & 
    //                                        is_cnt_ri_block_len_rs_fea_end & is_cnt_ri_block_len_owh_end;
    assign  is_ri_feature_write_start_pulse = is_ri_feature_load_ing & ((is_cnt_ri_block_len_ic_fea_end & is_stc) | is_not_stc)  & 
                                           is_cnt_ri_block_len_rs_fea_end & cnt_ri_block_len_owh==0;

    assign feature_load_finish = is_ri_feature_load_finish_pulse;
    assign feature_load_finish_t = is_ri_feature_load_finish;
    assign weight_load_finish = is_ri_weight_load_finish_pulse;
    assign weight_load_finish_t = is_ri_weight_load_finish;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_ri_weight_load_finish <= 0;
        end else if (is_pool) begin
            is_ri_weight_load_finish <= 1;
        end else begin
            if (is_ri_weight_load_finish_pulse & (~load_weight_continue)) begin
                is_ri_weight_load_finish <= 1;
            end else if (~is_pe_array_busy) begin
                is_ri_weight_load_finish <= 0;
            end
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_ri_feature_load_finish <= 0;
        end else if (is_ri_feature_load_finish_pulse & (~load_weight_continue)) begin
            is_ri_feature_load_finish <= 1;
        end else if (~pe_array_read_fea_enable) begin
            is_ri_feature_load_finish <= 0;
        end
    end

    assign is_ri_weight_load_ing  = (~is_ri_weight_load_finish) & is_pe_array_busy;
    assign is_ri_feature_load_ing = (~is_ri_feature_load_finish) & pe_array_read_fea_enable;


    wire is_wi_feature_write_ing_end_flag = is_wi_feature_write_ing & is_cnt_wi_block_len_owh_end & is_cnt_wi_block_len_oc_fea_end;
    reg is_wi_feature_write_ing_flag_ff;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_wi_feature_write_ing_flag_ff <= 0;
        end else begin
            is_wi_feature_write_ing_flag_ff <= is_wi_feature_write_ing_end_flag;
        end
    end
    wire is_wi_feature_write_ing_done = ~is_wi_feature_write_ing_end_flag & is_wi_feature_write_ing_flag_ff;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            feature_write_finish <= 0;
        end else begin
            feature_write_finish <= is_wi_feature_write_ing_done;
        end
    end

    detect_pulse_delay #(
        .DIM_WIDTH(DIM_WIDTH * 2)
    ) detect_pulse_delay (
        .clk(clk),
        .rstn(rstn),
        .depth_sub_1(block_len_owh),
        .in(is_ro_feature_write_start_pulse),
        .out(is_acc_out_ing_w)
    );
    localparam MAX_DELAY_DEPTH = 10;
    localparam ELE_ADD_DELAY = 2;
    localparam STARIC_DELAY = CAL_DELAY_STC;
    reg [$clog2(MAX_DELAY_DEPTH)-1:0] delay_depth_sub_1;
    assign delay_depth_sub_1 = is_int16_reg ? (QUAN_DELAY_Q + ELE_ADD_DELAY) : (QUAN_DELAY_Q - 1+ELE_ADD_DELAY);
    wire skip = use_quan ? 0 : 1;

    wire is_acc_out_ing_prior1;
    // 顶层的assign omap_pe_wr_data[i] = use_quan_internal ? {{(OMAP_RAM_WIDTH-QUAN_OUT_WIDTH){1'b0}},quan_relu_out[i][QUAN_OUT_WIDTH-1:0]}
    //                                                 :acc_out[i];是个组合逻辑，is_wi_feature_write_ing需要提前一个周期
    // dq_dff #(
    //     .N (STARIC_DELAY),
    //     .DW(1)
    // ) u_delay_is_acc_out_ing_prior1 (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .d(is_acc_out_ing_w),
    //     .q(is_acc_out_ing_prior1)  //提前一个周期
    // );
    localparam int STARIC_DELAY_acc_out_ing_prior1[NUM_DELAY_HEADS] = '{
        CAL_DELAY_STC,
        CAL_DELAY_DWC,
        CAL_DELAY_POOL
    };

    multi_delay_register #(
        .DATA_WIDTH(1),
        .NUM_HEADS(NUM_DELAY_HEADS),
        .MAX_DELAY(MAX_CAL_DELAY_M),
        .DELAYS(STARIC_DELAY_acc_out_ing_prior1),
        .DELAY_SEL_WIDTH(DELAY_SEL_WIDTH)
    ) u_delay_is_acc_out_ing_prior1 (
        .clk(clk),
        .rstn(rstn),
        .sel(delay_sel),
        .data_in(is_acc_out_ing_w),
        .data_out(is_acc_out_ing_prior1)
    );

    dq_dff #(
        .N (1 + 1),
        .DW(1)
    ) u_delay_is_acc_out_ing (
        .clk(clk),
        .rstn(rstn),
        .d(is_acc_out_ing_prior1),
        .q(is_acc_out_ing)
    );

    wire is_acc_out_ing_w2;

    // dq_dff #(
    //     .N (STARIC_DELAY - 1),
    //     .DW(1)
    // ) u_delay_is_acc_out_ing_w2 (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .d(is_acc_out_ing_w),
    //     .q(is_acc_out_ing_w2)
    // );
    localparam int STARIC_DELAY_SUB_1[NUM_DELAY_HEADS] = '{
        CAL_DELAY_STC - 1,
        CAL_DELAY_DWC - 1,
        CAL_DELAY_POOL - 1
    };
    multi_delay_register #(
        .DATA_WIDTH(1),
        .NUM_HEADS(NUM_DELAY_HEADS),
        .MAX_DELAY(MAX_CAL_DELAY_M - 1),
        .DELAYS(STARIC_DELAY_SUB_1)
    ) u_delay_is_acc_out_ing_w2 (
        .clk(clk),
        .rstn(rstn),
        .sel(delay_sel),
        .data_in(is_acc_out_ing_w),
        .data_out(is_acc_out_ing_w2)
    );



    reg [$clog2(MAX_DELAY_DEPTH)-1:0] delay_depth_sub_1_2;
    // assign delay_depth_sub_1_2 = is_int16_reg ? (QUAN_DELAY_Q) : (QUAN_DELAY_Q - 1);
    assign delay_depth_sub_1_2 = is_int16_reg ? (1) : (0);

    wire is_acc_out_ing_prior_n_bias_add2;

    // dq_dff #(
    //     .N (STARIC_DELAY + 1 - WRITE_ADDR_GEN_DELAY + 1 - (READ_ADDR_TO_DATA_OUT_DELAY)+QUAN_DELAY_Q - 1),
    //     .DW(1)
    // ) u_delay_is_acc_out_ing_prior_n_bias_add2 (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .d(is_acc_out_ing_w & use_bias2_add & use_quan),
    //     .q(is_acc_out_ing_prior_n_bias_add2)
    // );

    localparam  DELAY_bias_add2 = 1 - WRITE_ADDR_GEN_DELAY + 1 - (READ_ADDR_TO_DATA_OUT_DELAY)+QUAN_DELAY_Q - 1;
    parameter int STARIC_DELAY_bias_add2[NUM_DELAY_HEADS] = '{
        CAL_DELAY_STC + DELAY_bias_add2,
        CAL_DELAY_DWC + DELAY_bias_add2,
        CAL_DELAY_POOL + DELAY_bias_add2
    };
    wire use_bias2_add_w = is_acc_out_ing_w & use_bias2_add & use_quan;
    multi_delay_register #(
        .DATA_WIDTH(1),
        .NUM_HEADS(NUM_DELAY_HEADS),
        .MAX_DELAY(MAX_CAL_DELAY_M + DELAY_bias_add2),
        .DELAYS(STARIC_DELAY_bias_add2)
    ) u_delay_is_acc_out_ing_prior_n_bias_add2 (
        .clk(clk),
        .rstn(rstn),
        .sel(delay_sel),
        .data_in(use_bias2_add_w),
        .data_out(is_acc_out_ing_prior_n_bias_add2)
    );

    // configurable_shift_reg #(
    //     .MAX_DEPTH(MAX_DELAY_DEPTH),
    //     .WIDTH    (1)
    // ) u_configurable_shift_reg_bias2_add_ing (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .skip(1'b0),
    //     .din(is_acc_out_ing_prior_n_bias_add2),
    //     .depth_sub_1(delay_depth_sub_1_2),
    //     .dout(is_bias2_add_ing)
    // );

    // parameter int DELAY_is_bias2_add_ing[2] = '{0, 1};
    parameter int DELAY_is_bias2_add_ing[2] = '{1, 2};
    multi_delay_register #(
        .DATA_WIDTH(1),
        .NUM_HEADS(2),
        .MAX_DELAY(2),
        .DELAYS(DELAY_is_bias2_add_ing)
    ) u_delay_bias2_add_ing (
        .clk(clk),
        .rstn(rstn),
        .sel(is_int16_reg),
        .data_in(is_acc_out_ing_prior_n_bias_add2),
        .data_out(is_bias2_add_ing)
    );


    wire is_acc_out_ing_prior_n;

    // dq_dff #(
    //     .N (STARIC_DELAY + 1 - WRITE_ADDR_GEN_DELAY + 1),
    //     .DW(1)
    // ) u_delay_is_acc_out_ing_prior_n (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .d(is_acc_out_ing_w),
    //     .q(is_acc_out_ing_prior_n)
    // );

    localparam DELAY_prior_n = 1 - WRITE_ADDR_GEN_DELAY + 1;
    parameter int STARIC_DELAY_prior_n[NUM_DELAY_HEADS] = '{
        CAL_DELAY_STC + DELAY_prior_n,
        CAL_DELAY_DWC + DELAY_prior_n,
        CAL_DELAY_POOL + DELAY_prior_n
    };
    multi_delay_register #(
        .DATA_WIDTH(1),
        .NUM_HEADS(NUM_DELAY_HEADS),
        .MAX_DELAY(MAX_CAL_DELAY_M + DELAY_prior_n),
        .DELAYS(STARIC_DELAY_prior_n)
    ) u_delay_is_acc_out_ing_prior_n (
        .clk(clk),
        .rstn(rstn),
        .sel(delay_sel),
        .data_in(is_acc_out_ing_w),
        .data_out(is_acc_out_ing_prior_n)
    );
    configurable_shift_reg #(
        .MAX_DEPTH(MAX_DELAY_DEPTH),
        .WIDTH    (1)
    ) u_configurable_shift_reg_wi_feature_write (
        .clk(clk),
        .rstn(rstn),
        .skip(skip),
        .din(is_acc_out_ing_prior_n),//用提前WRITE_ADDR_GEN_DELAY个周期的信号产生is_wi_feature_write_ing标志位
        .depth_sub_1(delay_depth_sub_1),
        .dout(is_wi_feature_write_ing)
    );

    // parameter  DELAY_is_wi_feature_write_ing[3] = '{
    //     QUAN_DELAY_Q - 1 + ELE_ADD_DELAY,
    //     QUAN_DELAY_Q + ELE_ADD_DELAY,
    //     0
    // };
    // wire [1:0] is_wi_feature_write_ing_sel = skip ? 2'd2 : {1'b0, is_int16_reg};
    // multi_delay_register #(
    //     .DATA_WIDTH(1),
    //     .NUM_HEADS(3),
    //     .MAX_DELAY(QUAN_DELAY_Q + ELE_ADD_DELAY),
    //     .DELAYS(DELAY_is_wi_feature_write_ing)
    // ) u_delay_is_wi_feature_write_ing (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .sel(is_wi_feature_write_ing_sel),
    //     .data_in(is_acc_out_ing_prior_n),
    //     .data_out(is_wi_feature_write_ing)
    // );

    //========== 计数器 ==========

    // weight 行选择计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_len_ic_sel = 0;
        end else if (is_dwc) begin
            cnt_ri_block_len_ic_sel <= 0;
        end else if (is_ri_weight_load_ing) begin
            if (is_cnt_ri_block_len_ic_sel_end && (curr_state == S_LOAD_WEIGHT)) begin
                cnt_ri_block_len_ic_sel <= 0;
            end else if (is_cnt_ri_block_len_ic_sel_end&&((curr_state!=S_LOAD_WEIGHT&&curr_state!=S_IDLE)&&is_cnt_ri_block_len_owh_end)) begin
                cnt_ri_block_len_ic_sel <= 0;
            end else if (cnt_ri_block_len_ic_sel != (cnt_ri_block_len_ic_sel_end + 1)) begin
                cnt_ri_block_len_ic_sel <= cnt_ri_block_len_ic_sel + 1;
            end
        end else begin
            cnt_ri_block_len_ic_sel <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ri_weight_pingpong = 0;
        end else if (is_stc & is_ri_weight_load_ing) begin
            if (is_cnt_ri_block_len_ic_sel_end&&(((curr_state!=S_LOAD_WEIGHT&&curr_state!=S_IDLE)&&is_cnt_ri_block_len_owh_end)||(curr_state==S_LOAD_WEIGHT))) begin
                ri_weight_pingpong <= ~ri_weight_pingpong;
            end
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mat_weight_in_ri_row_sel[SEL_WIDTH-1:0] <= 0;
        end else if (is_dwc) begin
            mat_weight_in_ri_row_sel[SEL_WIDTH-1:0] <= 0;
        end else if (is_ri_weight_load_ing) begin
            mat_weight_in_ri_row_sel[SEL_WIDTH-1:0] <= cnt_ri_block_len_ic_sel[SEL_WIDTH-1:0];
        end else begin
            mat_weight_in_ri_row_sel[SEL_WIDTH-1:0] <= 0;
        end
    end

    // 读特征图 输出像素长度计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_len_owh <= 0;
        end else if (is_ri_feature_load_ing) begin
            if (is_cnt_ri_block_len_owh_end) begin
                cnt_ri_block_len_owh <= 0;
            end else begin
                cnt_ri_block_len_owh <= cnt_ri_block_len_owh + 1;
            end
        end else begin
            cnt_ri_block_len_owh <= 0;
        end
    end

    // 读特征图 输出像素宽度计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_ind_ow <= 0;
        end else if (is_ri_feature_load_ing) begin
            if (cnt_ri_block_ind_ow == block_len_ow) begin  // 这里有问题需要修复
                cnt_ri_block_ind_ow <= 0;
            end else begin
                cnt_ri_block_ind_ow <= cnt_ri_block_ind_ow + 1;
            end
        end else begin
            cnt_ri_block_ind_ow <= 0;
        end
    end

    // 读特征图 输出像素高度计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_ind_oh <= 0;
        end else if (is_ri_feature_load_ing) begin
            if (cnt_ri_block_ind_ow == block_len_ow) begin
                if (cnt_ri_block_ind_oh == block_len_oh) begin
                    cnt_ri_block_ind_oh <= 0;
                end else begin
                    cnt_ri_block_ind_oh <= cnt_ri_block_ind_oh + 1;
                end
            end

        end else begin
            cnt_ri_block_ind_oh <= 0;
        end
    end


    // 读权重 卷积窗口长度计数(weight)
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_len_rs_wei <= 0;
        end else if (is_ri_weight_load_ing) begin
            if (((is_cnt_ri_block_len_ic_sel_end & is_stc) | is_dwc)&&(((curr_state!=S_LOAD_WEIGHT&&curr_state!=S_IDLE)&&is_cnt_ri_block_len_owh_end)||(curr_state==S_LOAD_WEIGHT))) begin
                if (is_cnt_ri_block_len_rs_wei_end) begin
                    cnt_ri_block_len_rs_wei <= 0;
                end else begin
                    cnt_ri_block_len_rs_wei <= (cnt_ri_block_len_rs_wei + 1);
                end
            end
        end else begin
            cnt_ri_block_len_rs_wei <= 0;
        end
    end

    // 读特征图 卷积窗口长度计数(feature)
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_len_rs_fea <= 0;
        end else if (is_ri_feature_load_ing) begin
            if ((((curr_state != S_LOAD_WEIGHT && curr_state != S_IDLE) && is_cnt_ri_block_len_owh_end))) begin
                if (is_cnt_ri_block_len_rs_fea_end) begin
                    cnt_ri_block_len_rs_fea <= 0;
                end else begin
                    cnt_ri_block_len_rs_fea <= (cnt_ri_block_len_rs_fea + 1);
                end
            end
        end else begin
            cnt_ri_block_len_rs_fea <= 0;
        end
    end


    reg [WIN_S_WIDTH-1:0] ind_s_start;
    reg [WIN_R_WIDTH-1:0] ind_r_start;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ind_s_start <= 0;
            ind_r_start <= 0;
        end else if (total_rs_done || total_rs_start) begin
            ind_s_start <= 0;
            ind_r_start <= 0;
        end else if (is_ri_feature_load_ing) begin
            if ((((curr_state != S_LOAD_WEIGHT && curr_state != S_IDLE) && ((cnt_ri_block_len_owh+1) == (cnt_ri_block_len_owh_end)) // 提前一个周期
                && is_cnt_ri_block_len_rs_fea_end && is_cnt_ri_block_len_ic_fea_end && is_cnt_ri_block_len_oc_fea_end ))) begin
                if (cnt_ri_total_ind_s == total_len_s) begin
                    ind_s_start <= 0;
                    if (cnt_ri_total_ind_r == total_len_r) begin
                        ind_r_start <= 0;
                    end else begin
                        ind_r_start <= cnt_ri_total_ind_r + 1;
                    end
                end else begin
                    ind_s_start <= cnt_ri_total_ind_s + 1;
                    ind_r_start <= cnt_ri_total_ind_r;
                end

            end
        end
    end

    // 读特征图 窗口宽度计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_total_ind_s <= 0;
        end else if (total_rs_done ||total_rs_start ) begin// 当最开始或者最后时，窗口宽度和高度计数器归零
            cnt_ri_total_ind_s <= 0;
        end else if (is_ri_feature_load_ing) begin
            if ((((curr_state != S_LOAD_WEIGHT && curr_state != S_IDLE) && is_cnt_ri_block_len_owh_end))) begin

                if (is_cnt_ri_block_len_rs_fea_end) begin
                    cnt_ri_total_ind_s <= ind_s_start;
                end else if (cnt_ri_total_ind_s == total_len_s) begin
                    cnt_ri_total_ind_s <= 0;
                end else begin
                    cnt_ri_total_ind_s <= (cnt_ri_total_ind_s + 1);
                end
            end
        end
    end



    // 读特征图 窗口高度计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_total_ind_r <= 0;
        end else if (total_rs_start || total_rs_done) begin
            cnt_ri_total_ind_r <= 0;
        end else if (is_ri_feature_load_ing) begin
            if ((((curr_state != S_LOAD_WEIGHT && curr_state != S_IDLE) && is_cnt_ri_block_len_owh_end))) begin

                if (is_cnt_ri_block_len_rs_fea_end) begin
                    cnt_ri_total_ind_r <= ind_r_start;
                end else if (cnt_ri_total_ind_s == total_len_s) begin
                    if ((cnt_ri_total_ind_r == total_len_r)) begin
                        cnt_ri_total_ind_r <= 0;
                    end else begin
                        cnt_ri_total_ind_r <= (cnt_ri_total_ind_r + 1);
                    end
                end
            end
        end
    end

    // 读权重 输入通道计数(weight)
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_len_ic_wei <= 0;
        end else if (is_dwc) begin
            cnt_ri_block_len_ic_wei <= 0;
        end else if (is_ri_weight_load_ing) begin
            if (is_cnt_ri_block_len_ic_sel_end &&(((curr_state != S_LOAD_WEIGHT && curr_state != S_IDLE)
                                &&is_cnt_ri_block_len_owh_end)||(curr_state==S_LOAD_WEIGHT)) 
                                & ((cnt_ri_block_len_rs_wei == (cnt_ri_block_len_rs_end)))) begin
                if (is_cnt_ri_block_len_ic_wei_end) begin
                    cnt_ri_block_len_ic_wei <= 0;
                end else begin
                    cnt_ri_block_len_ic_wei <= (cnt_ri_block_len_ic_wei + 1);
                end
            end
        end else begin
            cnt_ri_block_len_ic_wei <= 0;
        end
    end

    // 读特征图 输入通道计数(feature)
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_len_ic_fea <= 0;
        end else if (is_ri_feature_load_ing) begin
            if ((((curr_state != S_LOAD_WEIGHT && curr_state != S_IDLE)&&is_cnt_ri_block_len_owh_end))
                        & ((cnt_ri_block_len_rs_fea == (cnt_ri_block_len_rs_end))) ) begin
                if (is_cnt_ri_block_len_ic_fea_end) begin
                    cnt_ri_block_len_ic_fea <= 0;
                end else begin
                    cnt_ri_block_len_ic_fea <= (cnt_ri_block_len_ic_fea + 1);
                end
            end
        end else begin
            cnt_ri_block_len_ic_fea <= 0;
        end
    end

    // 读权重 输出通道计数(weight)
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_len_oc_wei <= 0;
        end else if (is_ri_weight_load_ing) begin
            if (((is_cnt_ri_block_len_ic_sel_end & is_stc) | is_dwc)&&(((curr_state != S_LOAD_WEIGHT && curr_state != S_IDLE)
                        &&is_cnt_ri_block_len_owh_end)||(curr_state==S_LOAD_WEIGHT)) 
                        && ((cnt_ri_block_len_rs_wei == (cnt_ri_block_len_rs_end))) && ((is_cnt_ri_block_len_ic_wei_end & is_stc) | is_dwc)) begin
                if (is_cnt_ri_block_len_oc_wei_end) begin
                    cnt_ri_block_len_oc_wei <= 0;
                end else begin
                    cnt_ri_block_len_oc_wei <= cnt_ri_block_len_oc_wei + 1;
                end
            end
        end else begin
            cnt_ri_block_len_oc_wei <= 0;
        end
    end

    // 读特征图 输出通道计数(feature)
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_ri_block_len_oc_fea <= 0;
        end else if (is_ri_feature_load_ing) begin
            if ((((curr_state != S_LOAD_WEIGHT && curr_state != S_IDLE)&&is_cnt_ri_block_len_owh_end)) 
                     && ((cnt_ri_block_len_rs_fea == (cnt_ri_block_len_rs_end))) && ((is_stc && is_cnt_ri_block_len_ic_fea_end) |is_not_stc)) begin
                if (is_cnt_ri_block_len_oc_fea_end) begin
                    cnt_ri_block_len_oc_fea <= 0;
                end else begin
                    cnt_ri_block_len_oc_fea <= cnt_ri_block_len_oc_fea + 1;
                end
            end
        end else begin
            cnt_ri_block_len_oc_fea <= 0;
        end
    end

    // 读ACC  输出像素长度计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_acc_block_len_owh <= 0;
        end else if (is_acc_out_ing) begin
            if (is_cnt_acc_block_len_owh_end) begin
                cnt_acc_block_len_owh <= 0;
            end else begin
                cnt_acc_block_len_owh <= cnt_acc_block_len_owh + 1;
            end
        end else begin
            cnt_acc_block_len_owh <= 0;
        end
    end

    // 读ACC  输出通道计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_acc_block_len_oc_fea <= 0;
        end else if (is_acc_out_ing) begin
            if (is_cnt_acc_block_len_owh_end) begin
                if (is_cnt_acc_block_len_oc_fea_end) begin
                    cnt_acc_block_len_oc_fea <= 0;
                end else begin
                    cnt_acc_block_len_oc_fea <= cnt_acc_block_len_oc_fea + 1;
                end
            end
        end
    end


    // 读bias2  输出像素长度计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_bias2_add_block_len_owh <= 0;
        end else if (is_bias2_add_ing) begin
            if (is_cnt_bias2_add_block_len_owh_end) begin
                cnt_bias2_add_block_len_owh <= 0;
            end else begin
                cnt_bias2_add_block_len_owh <= cnt_bias2_add_block_len_owh + 1;
            end
        end else begin
            cnt_bias2_add_block_len_owh <= 0;
        end
    end

    // 读bias2  输出通道计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_bias2_add_block_len_oc_fea <= 0;
        end else if (is_bias2_add_ing) begin
            if (is_cnt_bias2_add_block_len_owh_end) begin
                if (is_cnt_bias2_add_block_len_oc_fea_end) begin
                    cnt_bias2_add_block_len_oc_fea <= 0;
                end else begin
                    cnt_bias2_add_block_len_oc_fea <= cnt_bias2_add_block_len_oc_fea + 1;
                end
            end
        end
    end

    // 写特征图  输出像素长度计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_wi_block_len_owh <= 0;
        end else if (is_wi_feature_write_ing) begin
            if (is_cnt_wi_block_len_owh_end) begin
                cnt_wi_block_len_owh <= 0;
            end else begin
                cnt_wi_block_len_owh <= cnt_wi_block_len_owh + 1;
            end
        end else begin
            cnt_wi_block_len_owh <= 0;
        end
    end

    // 写特征图  输出通道计数
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_wi_block_len_oc_fea <= 0;
        end else if (is_wi_feature_write_ing) begin
            if (is_cnt_wi_block_len_owh_end) begin
                if (is_cnt_wi_block_len_oc_fea_end) begin
                    cnt_wi_block_len_oc_fea <= 0;
                end else begin
                    cnt_wi_block_len_oc_fea <= cnt_wi_block_len_oc_fea + 1;
                end
            end
        end
    end


    //========== 控制信号产生 ==========

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            weight_pingpong <= 0;
        end else begin
            weight_pingpong <= ro_weight_pingpong;
        end
    end

    assign mat_weight_in_row_sel = mat_weight_in_ro_row_sel;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mat_row_enable_mask <= 0;
            mat_col_enable_mask <= 0;
        end else begin
            mat_row_enable_mask <= ro_row_mask_ic_fea & ({GEMM_MAC_ROW_NUM{is_stc}});
            mat_col_enable_mask <= ro_col_mask_oc_fea & ({GEMM_MAC_COL_NUM{is_stc}});
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_acc_pool_first <= 0;
        end else begin
            is_acc_pool_first <= is_cnt_acco_block_len_rs_ic_fea_start;
        end
    end
    // assign is_acc_pool_first = is_cnt_acco_block_len_rs_ic_fea_start;
    assign fifo_acc_rd_en = ~is_cnt_acco_block_len_rs_ic_fea_start || is_acc_out_ing_w2;
    assign acc_pool_out_enable = is_acc_out_ing_prior1;
    assign acc_pool_enable_mask = acco_col_mask_oc_fea | acc_col_mask_oc_fea;



    wire [log2_ROW_NUM-1:0] curr_ri_block_len_ic_fea;
    wire [log2_COL_NUM-1:0] curr_ri_block_len_oc_wei;
    wire [log2_COL_NUM-1:0] curr_ri_block_len_oc_fea;
    wire [log2_COL_NUM-1:0] curr_acc_block_len_oc_fea;
    wire [log2_COL_NUM-1:0] curr_bias2_add_block_len_oc_fea;
    wire [log2_COL_NUM-1:0] curr_wi_block_len_oc_fea;

    wire [log2_COL_NUM-1:0] curr_block_len_oc_end;
    assign curr_block_len_oc_end = is_int16_reg ? block_len_oc[log2_COL_NUM-1:0] : block_len_oc[log2_COL_NUM:1];

    assign curr_ri_block_len_ic_fea = (is_cnt_ri_block_len_ic_fea_end ? {{block_len_ic[log2_ROW_NUM-1:0]}} : ({{log2_ROW_NUM{1'b1}}}));
    assign curr_ri_block_len_oc_wei = (is_cnt_ri_block_len_oc_wei_end ? curr_block_len_oc_end : {log2_COL_NUM{1'b1}});
    assign curr_ri_block_len_oc_fea = (is_cnt_ri_block_len_oc_fea_end ? curr_block_len_oc_end : {log2_COL_NUM{1'b1}});
    assign curr_acc_block_len_oc_fea = (is_cnt_acc_block_len_oc_fea_end ? curr_block_len_oc_end : {log2_COL_NUM{1'b1}});
    assign curr_bias2_add_block_len_oc_fea = (is_cnt_bias2_add_block_len_oc_fea_end ? curr_block_len_oc_end : {log2_COL_NUM{1'b1}});
    assign curr_wi_block_len_oc_fea = (is_cnt_wi_block_len_oc_fea_end ? curr_block_len_oc_end : {log2_COL_NUM{1'b1}});


    always @(*) begin
        ri_row_mask_ic_fea = ({GEMM_MAC_ROW_NUM{is_ri_feature_load_ing}})&({GEMM_MAC_ROW_NUM{1'b1}} << (GEMM_MAC_ROW_NUM - 1 - curr_ri_block_len_ic_fea)) >> (GEMM_MAC_ROW_NUM - 1 - curr_ri_block_len_ic_fea);
        ri_col_mask_oc_wei = ({GEMM_MAC_COL_NUM{is_ri_weight_load_ing}})&({GEMM_MAC_COL_NUM{1'b1}} << (GEMM_MAC_COL_NUM - 1 - curr_ri_block_len_oc_wei)) >> (GEMM_MAC_COL_NUM - 1 - curr_ri_block_len_oc_wei);
        ri_col_mask_oc_fea = ({GEMM_MAC_COL_NUM{is_ri_feature_load_ing}})&({GEMM_MAC_COL_NUM{1'b1}} << (GEMM_MAC_COL_NUM - 1 - curr_ri_block_len_oc_fea)) >> (GEMM_MAC_COL_NUM - 1 - curr_ri_block_len_oc_fea);
        acc_col_mask_oc_fea = ({GEMM_MAC_COL_NUM{is_acc_out_ing}})&({GEMM_MAC_COL_NUM{1'b1}} << (GEMM_MAC_COL_NUM - 1 - curr_acc_block_len_oc_fea)) >> (GEMM_MAC_COL_NUM - 1 - curr_acc_block_len_oc_fea);
        bias2_add_col_mask_oc_fea = ({GEMM_MAC_COL_NUM{is_bias2_add_ing}})&({GEMM_MAC_COL_NUM{1'b1}} << (GEMM_MAC_COL_NUM - 1 - curr_bias2_add_block_len_oc_fea)) >> (GEMM_MAC_COL_NUM - 1 - curr_bias2_add_block_len_oc_fea);
        wi_col_mask_oc_fea = ({GEMM_MAC_COL_NUM{is_wi_feature_write_ing}})&({GEMM_MAC_COL_NUM{1'b1}} << (GEMM_MAC_COL_NUM - 1 - curr_wi_block_len_oc_fea)) >> (GEMM_MAC_COL_NUM - 1 - curr_wi_block_len_oc_fea);

    end
    // reg use_C_internal;
    wire is_cnt_ri_block_len_owh_lsq_end = (cnt_ri_block_len_owh <= block_len_owh);
    wire weight_ren_t =  is_ri_weight_load_ing & (is_stc &(cnt_ri_block_len_ic_sel != (cnt_ri_block_len_ic_sel_end + 1)) | (is_dwc & (cnt_ri_block_len_owh==0)));
    wire imap_ren_t = is_cnt_ri_block_len_owh_lsq_end & is_ri_feature_load_ing;
    wire bias_ren_t = is_conv & is_cnt_ri_block_len_owh_lsq_end & is_ri_feature_load_ing & is_cnt_ri_block_len_rs_ic_fea_start & use_bias_internal;
    wire bias2_ren_t = is_bias2_add_ing;
    wire omap_wen_t = is_wi_feature_write_ing;

    wire [GEMM_MAC_ROW_NUM-1:0] imap_ren_w = ({GEMM_MAC_ROW_NUM{imap_ren_t}}) & ri_row_mask_ic_fea;
    wire [GEMM_MAC_COL_NUM-1:0] weight_ren_w = ({GEMM_MAC_COL_NUM{weight_ren_t}}) & ri_col_mask_oc_wei;
    wire [GEMM_MAC_COL_NUM-1:0] bias_ren_w = ({GEMM_MAC_COL_NUM{bias_ren_t}}) & ri_col_mask_oc_fea;
    wire [GEMM_MAC_COL_NUM-1:0] bias2_ren_w = ({GEMM_MAC_COL_NUM{bias2_ren_t}}) & bias2_add_col_mask_oc_fea;
    wire [GEMM_MAC_COL_NUM-1:0] omap_wen_w = ({GEMM_MAC_COL_NUM{omap_wen_t}}) & wi_col_mask_oc_fea;


    assign bias_acci_ren = bias_ren_w;




    dq_dff #(
        .N (READ_ADDR_GEN_DELAY),
        .DW(GEMM_MAC_ROW_NUM)
    ) u_delay_imap_ren (
        .clk(clk),
        .rstn(rstn),
        .d(imap_ren_w),
        .q(imap_ren)
    );

    dq_dff #(
        .N (READ_ADDR_GEN_DELAY),
        .DW(GEMM_MAC_COL_NUM)
    ) u_delay_weight_ren (
        .clk(clk),
        .rstn(rstn),
        .d(weight_ren_w),
        .q(weight_ren)
    );

    dq_dff #(
        .N (READ_ADDR_GEN_DELAY),
        .DW(GEMM_MAC_COL_NUM)
    ) u_delay_bias_ren (
        .clk(clk),
        .rstn(rstn),
        .d(bias_acco_ren),
        .q(bias_ren)
    );

    dq_dff #(
        .N (WRITE_ADDR_GEN_DELAY),
        .DW(GEMM_MAC_COL_NUM)
    ) u_delay_bias2_ren (
        .clk(clk),
        .rstn(rstn),
        .d(bias2_ren_w),
        .q(bias2_ren)
    );

    dq_dff #(
        .N (WRITE_ADDR_GEN_DELAY),
        .DW(GEMM_MAC_COL_NUM)
    ) u_delay_omap_wen (
        .clk(clk),
        .rstn(rstn),
        .d(omap_wen_w),
        .q(omap_wen)
    );


    // reg [  IMAP_RAM_ADDR_WIDTH+1-1:0] imap_addr;
    // reg [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_addr;
    // reg [  OMAP_RAM_ADDR_WIDTH-1:0] omap_addr;

    // s:weight_w
    // r:weight_h
    // iw=ow*sx+s*dx;
    // ih=oh*sy+r*dy;
    // iwh=iw+ih*Liw;
    // iaddr=ic*Liwh+iwh;
    // oaddr/bias_addr=oc*Lowh+owh;
    // waddr=rs*Lic*Loc/pe_col+oc*Lic+ic;//输出通道优先排列

    wire is_padding_w;

    L1_imap_raddr_gen #(
        .IMAP_RAM_ADDR_WIDTH(IMAP_RAM_ADDR_WIDTH),
        .DIM_WIDTH          (DIM_WIDTH),
        .CNT_IC_WIDTH       (CNT_IC_WIDTH),
        .IMAP_DIM_WIDTH     (IMAP_DIM_WIDTH),
        .STRIDE_X_WIDTH     (STRIDE_X_WIDTH),
        .STRIDE_Y_WIDTH     (STRIDE_Y_WIDTH),
        .DILATION_X_WIDTH   (DILATION_X_WIDTH),
        .DILATION_Y_WIDTH   (DILATION_Y_WIDTH),
        .WIN_R_WIDTH        (WIN_R_WIDTH),
        .WIN_S_WIDTH        (WIN_S_WIDTH)
    ) u_L1_imap_raddr_gen (
        .clk                     (clk),
        .rstn                    (rstn),
        .is_int16                (is_int16_reg),
        .is_stc                  (is_stc),
        .en                      (is_ri_feature_load_ing),
        .L1_block_len_iwih_border(L1_block_len_iwih_border),
        .cnt_ri_block_len_ic_fea (cnt_ri_block_len_ic_fea),
        .cnt_ri_block_ind_ow     (cnt_ri_block_ind_ow),
        .cnt_ri_block_ind_oh     (cnt_ri_block_ind_oh),
        .cnt_ri_total_ind_s      (cnt_ri_total_ind_s),
        .cnt_ri_total_ind_r      (cnt_ri_total_ind_r),
        .block_len_iwh           (block_len_iwh),
        .block_len_iw            (block_len_iw),
        .stride_x                (stride_x),
        .stride_y                (stride_y),
        .dilation_x              (dilation_x),
        .dilation_y              (dilation_y),

        .imap_raddr(imap_addr),
        .cnt_ri_block_len_ic_fea_0_r(imap_ric_even_odd_flag),
        .is_padding(is_padding_w)
    );
    dq_dff #(
        .N (READ_ADDR_TO_DATA_OUT_DELAY),
        .DW(1)
    ) u_is_padding_delay (
        .clk(clk),
        .rstn(rstn),
        .d(is_padding_w),
        .q(is_padding)
    );


    wire [DIM_WIDTH-1:0] block_len_ic_true = is_dwc ? 0 : block_len_ic;
    L1_weight_raddr_gen #(
        .WEIGHT_RAM_ADDR_WIDTH(WEIGHT_RAM_ADDR_WIDTH),
        .DIM_WIDTH            (DIM_WIDTH),
        .CNT_OC_WIDTH         (CNT_OC_WIDTH),
        .CNT_IC_WIDTH         (CNT_IC_WIDTH),
        .GEMM_MAC_ROW_NUM     (GEMM_MAC_ROW_NUM),
        .SEL_WIDTH            (SEL_WIDTH),
        .WIN_R_WIDTH          (WIN_R_WIDTH),
        .WIN_S_WIDTH          (WIN_S_WIDTH)
    ) u_L1_weight_raddr_gen (
        .clk(clk),
        .rstn(rstn),
        .en(weight_ren_t),
        .cnt_ri_block_len_oc_wei(cnt_ri_block_len_oc_wei),
        .cnt_ri_block_len_rs_wei(cnt_ri_block_len_rs_wei),
        .cnt_ri_block_len_ic_wei(cnt_ri_block_len_ic_wei),
        .cnt_ri_block_len_ic_sel(cnt_ri_block_len_ic_sel[SEL_WIDTH-1:0]),
        .block_len_ic(block_len_ic_true),
        .block_len_rs(block_len_rs),

        .weight_raddr(weight_addr)
    );




    L1_bias_raddr_gen #(
        .OMAP_RAM_ADDR_WIDTH(OMAP_RAM_ADDR_WIDTH),
        .DIM_WIDTH          (DIM_WIDTH),
        .CNT_OC_WIDTH       (CNT_OC_WIDTH)
    ) u_L1_bias_raddr_gen (
        .clk(clk),
        .rstn(rstn),
        .en(bias_ren_t),
        .bias_mode_internal(bias_mode_internal),
        .cnt_ri_block_len_oc_fea(cnt_ri_block_len_oc_fea),
        .cnt_ri_block_len_owh(cnt_ri_block_len_owh),
        .block_len_owh(block_len_owh),

        .bias_acci_addr(bias_acci_addr)
    );



    assign bias_addr = bias_acco_addr;

    L1_bias2_addr_gen #(
        .BIAS2_RAM_ADDR_WIDTH(BIAS2_RAM_ADDR_WIDTH),
        .DIM_WIDTH           (DIM_WIDTH),
        .CNT_OC_WIDTH        (CNT_OC_WIDTH)
    ) u_L1_bias2_addr_gen (
        .clk                           (clk),
        .rstn                          (rstn),
        .en                            (is_bias2_add_ing),
        .cnt_bias2_add_block_len_oc_fea(cnt_bias2_add_block_len_oc_fea),
        .cnt_bias2_add_block_len_owh   (cnt_bias2_add_block_len_owh),
        .block_len_owh                 (block_len_owh),

        .bias2_addr(bias2_addr)
    );

    L1_omap_waddr_gen #(
        .OMAP_RAM_ADDR_WIDTH(OMAP_RAM_ADDR_WIDTH),
        .DIM_WIDTH          (DIM_WIDTH),
        .CNT_OC_WIDTH       (CNT_OC_WIDTH)
    ) u_L1_omap_waddr_gen (
        .clk                    (clk),
        .rstn                   (rstn),
        .en                     (is_wi_feature_write_ing),
        .cnt_wi_block_len_oc_fea(cnt_wi_block_len_oc_fea),
        .cnt_wi_block_len_owh   (cnt_wi_block_len_owh),
        .block_len_owh          (block_len_owh),

        .omap_waddr(omap_addr)
    );






endmodule
