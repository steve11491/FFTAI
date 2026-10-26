module convpool_L2_control #(
    parameter WIDTH = 16,
    parameter C_WIDTH = 32,
    parameter GEMM_MAC_ROW_NUM = 32,
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
    parameter int CAL_DELAY_STC = $clog2(GEMM_MAC_ROW_NUM) + 2,
    parameter int CAL_DELAY_DWC = 2,
    parameter int CAL_DELAY_POOL = 1,
    parameter int MAX_CAL_DELAY_M = CAL_DELAY_STC,
    parameter QUAN_DELAY_Q = 4,  // 量化的延迟：int8:4。int16:5
    parameter MAX_BLOCK_DIM = 128,
    parameter MAX_NUM_DIM = 128,
    parameter NUM_WIDTH = $clog2(MAX_NUM_DIM),
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
    input wire       clk,
    input wire       rstn,
    input wire       is_int16,
    input wire       is_matmul,
    input wire       is_pool,
    input wire       pool_type,
    input wire [1:0] conv_type,
    input wire       mat_core_start,


    input wire [NUM_WIDTH-1:0] num_ow,
    input wire [NUM_WIDTH-1:0] num_oh,
    input wire [NUM_WIDTH-1:0] num_oc,
    input wire [NUM_WIDTH-1:0] num_ic,
    input wire [NUM_WIDTH-1:0] num_rs,

    input wire is_pe_array_busy,
    input wire is_load_weight_busy,
    input wire is_load_bias_busy,
    input wire is_load_imap_busy,
    input wire is_load_bias2_busy,
    input wire is_write_omap_busy,

    input wire is_pe_array_done,
    input wire is_load_weight_done,
    input wire is_load_bias_done,
    input wire is_load_imap_done,
    input wire is_load_bias2_done,
    input wire is_write_omap_done,



    output reg load_weight_start,
    output reg load_bias_start,
    output reg load_bias2_start,
    output reg load_imap_start,
    output reg write_omap_start,

    input wire use_bias_external,
    input wire bias_mode_external,
    input wire use_bias2_add_external,
    input wire use_quan_external,

    output reg ram_weight_pingpong,
    output reg ram_imap_pingpong,
    (*MAX_FANOUT = 128 *) output reg ram_bias2_pingpong,
    output [1:0] ram_omap_sel[4:0],
    output reg [2:0] ram_omap_ren_sel,

    output reg pe_array_start,
    output reg total_rs_start,
    output reg total_rs_done,
    output reg use_bias_internal,
    output reg bias_mode_internal,
    (*MAX_FANOUT = 128 *) output reg use_quan_internal,


    output wire is_cnt_cal_w_end,
    output wire is_cnt_cal_h_end,
    output wire is_cnt_cal_oc_end,
    output wire is_cnt_cal_ic_end,
    output wire is_cnt_cal_rs_end,

    output wire is_cnt_load_bias_w_end,
    output wire is_cnt_load_bias_h_end,
    output wire is_cnt_load_bias_oc_end,

    output wire is_cnt_load_wei_rs_end,
    output wire is_cnt_load_wei_ic_end,
    output wire is_cnt_load_wei_oc_end,

    output wire is_cnt_load_imap_w_end,
    output wire is_cnt_load_imap_h_end,
    output wire is_cnt_load_imap_ic_end,

    output wire is_cnt_write_omap_w_end,
    output wire is_cnt_write_omap_h_end,
    output wire is_cnt_write_omap_oc_end,

    output reg [NUM_WIDTH-1:0] cnt_cal_w,
    output reg [NUM_WIDTH-1:0] cnt_cal_h,
    output reg [NUM_WIDTH-1:0] cnt_cal_oc,
    output reg [NUM_WIDTH-1:0] cnt_cal_ic,
    output reg [NUM_WIDTH-1:0] cnt_cal_rs,

    output reg [NUM_WIDTH-1:0] cnt_load_bias_w,
    output reg [NUM_WIDTH-1:0] cnt_load_bias_h,
    output reg [NUM_WIDTH-1:0] cnt_load_bias_oc,

    output reg [NUM_WIDTH-1:0] cnt_load_wei_rs,
    output reg [NUM_WIDTH-1:0] cnt_load_wei_ic,
    output reg [NUM_WIDTH-1:0] cnt_load_wei_oc,

    output reg [NUM_WIDTH-1:0] cnt_load_imap_w,
    output reg [NUM_WIDTH-1:0] cnt_load_imap_h,
    output reg [NUM_WIDTH-1:0] cnt_load_imap_ic,

    output reg [NUM_WIDTH-1:0] cnt_write_omap_w,
    output reg [NUM_WIDTH-1:0] cnt_write_omap_h,
    output reg [NUM_WIDTH-1:0] cnt_write_omap_oc,


    output reg  layer_done,
    output wire is_mat_core_busy,
    output wire is_mat_core_ready


);


    localparam STC = 0, DWC = 1;
    localparam MAX_POOL = 1'b0, AVG_POOL = 1'b1;
    // wire is_maxpool = (is_pool && pool_type == MAX_POOL);
    // wire is_avgpool = (is_pool && pool_type == AVG_POOL);
    // wire is_conv = ~is_pool;
    // wire is_stc = (~is_pool && conv_type == STC);
    // wire is_dwc = (~is_pool && conv_type == DWC);

    // wire is_use_acc = (~is_pool) | is_avgpool;

    reg is_maxpool;
    reg is_avgpool;
    reg is_conv;
    reg is_stc;
    reg is_not_stc;
    reg is_dwc;
    reg is_use_acc;
    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_maxpool <= 0;
            is_avgpool <= 0;
            is_conv <= 0;
            is_stc <= 0;
            is_not_stc <= 0;
            is_dwc <= 0;
            is_use_acc <= 0;
            is_int16_reg <= 0;
        end else begin
            is_maxpool <= (is_pool && (pool_type == MAX_POOL));
            is_avgpool <= (is_pool && (pool_type == AVG_POOL));
            is_conv <= ~is_pool;
            is_stc <= ((~is_pool) && (conv_type == STC));
            is_not_stc <= ~((~is_pool) && (conv_type == STC));
            is_dwc <= ((~is_pool) && (conv_type == DWC));
            is_use_acc <= (~is_pool) | is_avgpool;
            is_int16_reg <= is_int16;
        end
    end


    reg load_in_first_done;
    reg layer_done_true;
    assign layer_done = layer_done_true;
    reg [2:0] curr_state, next_state;
    parameter S_IDLE = 0, S_LOAD = 1, S_LOAD_CAL = 2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            curr_state <= S_IDLE;
        end else begin
            curr_state <= next_state;
        end
    end
    always @(*) begin
        begin
            case (curr_state)
                S_IDLE: begin
                    if (mat_core_start) begin
                        next_state = S_LOAD;
                    end else begin
                        next_state = S_IDLE;
                    end
                end
                S_LOAD: begin
                    if (load_in_first_done) begin
                        next_state = S_LOAD_CAL;
                    end else begin
                        next_state = S_LOAD;
                    end
                end
                S_LOAD_CAL: begin
                    if (layer_done_true) begin
                        next_state = S_IDLE;
                    end else begin
                        next_state = S_LOAD_CAL;
                    end
                end
                default: begin
                    next_state = S_IDLE;
                end
            endcase

        end
    end
    assign is_mat_core_busy  = curr_state != S_IDLE;
    assign is_mat_core_ready = curr_state == S_IDLE;

    wire is_busy_w;
    reg  is_busy_ff;
    assign is_busy_w = is_pe_array_busy|is_load_weight_busy|is_load_bias_busy|is_load_imap_busy|is_load_bias2_busy|is_write_omap_busy;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_busy_ff <= 0;
        end else begin
            is_busy_ff <= is_busy_w;
        end
    end

    wire period_done_fall_pulse;
    assign period_done_fall_pulse = is_busy_ff & (~is_busy_w);// 完成一个阶段的下降沿脉冲
    assign load_in_first_done = period_done_fall_pulse;



    // reg [NUM_WIDTH-1:0] cnt_load_bias_w;
    // reg [NUM_WIDTH-1:0] cnt_load_bias_h;
    // reg [NUM_WIDTH-1:0] cnt_load_bias_oc;

    // reg [NUM_WIDTH-1:0] cnt_load_wei_rs;
    // reg [NUM_WIDTH-1:0] cnt_load_wei_ic;

    // reg [NUM_WIDTH-1:0] cnt_load_wei_oc;
    // reg [NUM_WIDTH-1:0] cnt_load_imap_w;
    // reg [NUM_WIDTH-1:0] cnt_load_imap_h;
    // reg [NUM_WIDTH-1:0] cnt_load_imap_ic;
    assign cnt_load_imap_w = cnt_load_bias_w;
    assign cnt_load_imap_h = cnt_load_bias_h;
    assign cnt_load_imap_ic = (is_not_stc) ? cnt_load_bias_oc : cnt_load_wei_ic;
    assign cnt_load_wei_oc = cnt_load_bias_oc;

    // reg [NUM_WIDTH-1:0] cnt_write_omap_w;
    // reg [NUM_WIDTH-1:0] cnt_write_omap_h;
    // reg [NUM_WIDTH-1:0] cnt_write_omap_oc;

    // reg [NUM_WIDTH-1:0] cnt_cal_w;
    // reg [NUM_WIDTH-1:0] cnt_cal_h;
    // reg [NUM_WIDTH-1:0] cnt_cal_oc;
    // reg [NUM_WIDTH-1:0] cnt_cal_ic;
    // reg [NUM_WIDTH-1:0] cnt_cal_rs;


    assign is_cnt_load_bias_w_end = (cnt_load_bias_w == num_ow);
    assign is_cnt_load_bias_h_end = (cnt_load_bias_h == num_oh);
    assign is_cnt_load_bias_oc_end = (cnt_load_bias_oc == num_oc);

    assign is_cnt_load_wei_rs_end = (is_conv & (cnt_load_wei_rs == num_rs)) || is_pool;
    assign is_cnt_load_wei_ic_end = (cnt_load_wei_ic == num_ic);
    assign is_cnt_load_wei_oc_end = is_cnt_load_bias_oc_end;

    assign is_cnt_load_imap_w_end = is_cnt_load_bias_w_end;
    assign is_cnt_load_imap_h_end = is_cnt_load_bias_h_end;
    assign is_cnt_load_imap_ic_end = (is_not_stc) ? is_cnt_load_bias_oc_end : is_cnt_load_wei_ic_end;

    assign is_cnt_write_omap_w_end = (cnt_write_omap_w == num_ow);
    assign is_cnt_write_omap_h_end = (cnt_write_omap_h == num_oh);
    assign is_cnt_write_omap_oc_end = (cnt_write_omap_oc == num_oc);

    assign is_cnt_cal_w_end = (cnt_cal_w == num_ow);
    assign is_cnt_cal_h_end = (cnt_cal_h == num_oh);
    assign is_cnt_cal_oc_end = (cnt_cal_oc == num_oc);
    assign is_cnt_cal_ic_end = (cnt_cal_ic == num_ic);
    assign is_cnt_cal_rs_end = (is_conv & (cnt_cal_rs == num_rs)) || is_pool;


    wire is_weight_load_finish_pulse;
    wire is_imap_load_finish_pulse;
    wire is_bias_load_finish_pulse;
    wire is_omap_write_finish_pulse;
    wire is_cal_finish_pulse;

    reg is_weight_load_finish;
    reg is_imap_load_finish;
    reg is_bias_load_finish;
    reg is_omap_write_finish;
    reg is_cal_finish;

    wire is_weight_load_ing;
    wire is_imap_load_ing;
    wire is_bias_load_ing;
    wire is_omap_write_ing;
    wire is_load_ing;
    wire is_cal_ing;

    wire is_core_busy = curr_state != S_IDLE;
    wire is_pe_array_enable = (curr_state != S_IDLE) & (curr_state != S_LOAD);
    assign is_weight_load_ing = (~is_weight_load_finish) & is_core_busy;
    assign is_imap_load_ing = (~is_imap_load_finish) & is_core_busy;
    assign is_bias_load_ing = (~is_bias_load_finish) & is_core_busy;
    assign is_omap_write_ing = (~is_omap_write_finish) & is_core_busy;
    assign is_cal_ing = (~is_cal_finish) & is_pe_array_enable;

    //    reg is_weight_load_ing_period;  // = is_weight_load_ing;
    //     reg is_imap_load_ing_period;  //= (cnt_load_wei_rs == 0) & is_core_busy;
    //     assign is_weight_load_ing_period = is_weight_load_ing;
    //     assign is_imap_load_ing_period   = (cnt_load_wei_rs == 0) & is_core_busy;

    //     // always @(*) begin
    //     //     if (num_rs == 0 && num_ic == 0 && num_oc == 0) begin
    //     //         is_weight_load_ing_period = (curr_state == S_LOAD);
    //     //     end else if (num_rs == 0 && num_ic == 0) begin
    //     //         is_weight_load_ing_period = (curr_state == S_LOAD) || (cnt_load_imap_w ==0 && cnt_load_imap_h == 0);
    //     //     end else begin
    //     //         is_weight_load_ing_period = is_weight_load_ing;
    //     //     end
    //     // end

    //     // always @(*) begin
    //     //     if (num_ic == 0 && num_ow == 0 && num_oh == 0) begin
    //     //         is_imap_load_ing_period = (curr_state == S_LOAD);
    //     //     end else begin
    //     //         is_imap_load_ing_period = (cnt_load_wei_rs == 0) & is_core_busy;
    //     //     end
    //     // end

    wire is_weight_load_ing_period = is_weight_load_ing;
    wire is_imap_load_ing_period = (cnt_load_wei_rs == 0) & is_core_busy;
    wire is_bias_load_ing_period = (cnt_load_wei_rs == 0) & (cnt_load_wei_ic == 0) & is_core_busy;
    reg is_omap_write_ing_period;
    wire is_cal_ing_period = is_cal_ing;

    wire is_weight_load_period_done = is_weight_load_ing_period & period_done_fall_pulse;
    wire is_imap_load_period_done = is_imap_load_ing_period & period_done_fall_pulse;
    wire is_bias_load_period_done = is_bias_load_ing_period & period_done_fall_pulse;
    wire is_omap_write_period_done = is_omap_write_ing_period & period_done_fall_pulse;
    wire is_cal_period_done = is_cal_ing_period & period_done_fall_pulse;

    assign is_load_ing = is_weight_load_ing;

    assign is_weight_load_finish_pulse = is_cnt_load_wei_rs_end & ((is_cnt_load_wei_ic_end & is_stc) | is_dwc) & is_cnt_load_wei_oc_end
                                         & is_cnt_load_bias_w_end & is_cnt_load_bias_h_end & is_weight_load_period_done 
                                         & (~is_weight_load_finish);

    assign is_imap_load_finish_pulse =  is_cnt_load_imap_w_end & is_cnt_load_imap_h_end & is_cnt_load_imap_ic_end 
                                        & ((is_cnt_load_wei_oc_end & is_stc) | is_not_stc) & is_imap_load_period_done & (~is_imap_load_finish);

    assign is_bias_load_finish_pulse = is_cnt_load_bias_w_end & is_cnt_load_bias_h_end & is_cnt_load_bias_oc_end
                                         & is_bias_load_period_done & (~is_bias_load_finish);

    assign is_omap_write_finish_pulse = is_cnt_write_omap_w_end & is_cnt_write_omap_h_end & is_cnt_write_omap_oc_end
                                         & is_omap_write_period_done & (~is_omap_write_finish);

    assign is_cal_finish_pulse = is_cnt_cal_w_end  & is_cnt_cal_h_end & is_cnt_cal_oc_end 
                                        & is_cnt_cal_ic_end & ((is_conv & is_cnt_cal_rs_end) | is_pool) & is_cal_period_done & (~is_cal_finish);

    assign layer_done_true = is_omap_write_finish_pulse;


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_weight_load_finish <= 0;
        end else if (is_weight_load_finish_pulse) begin
            is_weight_load_finish <= 1;
        end else if (~is_core_busy) begin
            is_weight_load_finish <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_imap_load_finish <= 0;
        end else if (is_imap_load_finish_pulse) begin
            is_imap_load_finish <= 1;
        end else if (~is_core_busy) begin
            is_imap_load_finish <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_bias_load_finish <= 0;
        end else if (is_bias_load_finish_pulse) begin
            is_bias_load_finish <= 1;
        end else if (~is_core_busy) begin
            is_bias_load_finish <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_omap_write_finish <= 1;  //这里比较特殊
        end else if (is_omap_write_finish_pulse) begin
            is_omap_write_finish <= 1;
        end else if (is_pe_array_enable & period_done_fall_pulse & ((is_cnt_cal_rs_end & ((is_cnt_cal_ic_end & is_stc) | is_dwc)) || is_pool)) begin
            is_omap_write_finish <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_cal_finish <= 0;
        end else if (is_cal_finish_pulse) begin
            is_cal_finish <= 1;
        end else if (~is_core_busy) begin
            is_cal_finish <= 0;
        end
    end




    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_omap_write_ing_period <= 0;
        end else begin
            case (curr_state)
                S_LOAD_CAL: begin
                    if (is_conv) begin
                        if( period_done_fall_pulse & is_cnt_cal_rs_end
                                 & ((is_cnt_cal_ic_end & is_stc) | is_dwc) & (~is_omap_write_finish_pulse)) begin
                            is_omap_write_ing_period <= 1;
                        end else if (period_done_fall_pulse) begin
                            is_omap_write_ing_period <= 0;
                        end
                    end else begin
                        if (period_done_fall_pulse & (~is_omap_write_finish_pulse)) begin
                            is_omap_write_ing_period <= 1;
                        end else if (period_done_fall_pulse) begin
                            is_omap_write_ing_period <= 0;
                        end
                    end

                end
                default: begin
                    is_omap_write_ing_period <= 0;
                end
            endcase
        end
    end

    // load计数器

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_load_wei_rs <= 0;
        end else if (is_conv & is_load_ing) begin
            if (period_done_fall_pulse) begin
                if (is_cnt_load_wei_rs_end) begin
                    cnt_load_wei_rs <= 0;
                end else begin
                    cnt_load_wei_rs <= cnt_load_wei_rs + 1;
                end
            end
        end else begin
            cnt_load_wei_rs <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_load_wei_ic <= 0;
        end else if (is_stc & is_load_ing) begin
            if (period_done_fall_pulse & is_cnt_load_wei_rs_end) begin
                if (is_cnt_load_wei_ic_end) begin
                    cnt_load_wei_ic <= 0;
                end else begin
                    cnt_load_wei_ic <= cnt_load_wei_ic + 1;
                end
            end
        end else begin
            cnt_load_wei_ic <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_load_bias_w <= 0;
        end else if (is_conv) begin
            if (is_load_ing) begin
                if (period_done_fall_pulse & is_cnt_load_wei_rs_end & ((is_cnt_load_wei_ic_end & is_stc) | is_dwc)) begin
                    if (is_cnt_load_bias_w_end) begin
                        cnt_load_bias_w <= 0;
                    end else begin
                        cnt_load_bias_w <= cnt_load_bias_w + 1;
                    end
                end
            end
        end else if (is_pool) begin
            if (is_bias_load_ing) begin
                if (period_done_fall_pulse) begin
                    if (is_cnt_load_bias_w_end) begin
                        cnt_load_bias_w <= 0;
                    end else begin
                        cnt_load_bias_w <= cnt_load_bias_w + 1;
                    end
                end
            end
        end else begin
            cnt_load_bias_w <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_load_bias_h <= 0;
        end else if (is_conv) begin
            if (is_load_ing) begin
                if (period_done_fall_pulse & is_cnt_load_wei_rs_end & ((is_cnt_load_wei_ic_end & is_stc) | is_dwc)
                                    &is_cnt_load_bias_w_end) begin
                    if (is_cnt_load_bias_h_end) begin
                        cnt_load_bias_h <= 0;
                    end else begin
                        cnt_load_bias_h <= cnt_load_bias_h + 1;
                    end
                end
            end

        end else if (is_pool) begin
            if (is_bias_load_ing) begin
                if (period_done_fall_pulse & is_cnt_load_bias_w_end) begin
                    if (is_cnt_load_bias_h_end) begin
                        cnt_load_bias_h <= 0;
                    end else begin
                        cnt_load_bias_h <= cnt_load_bias_h + 1;
                    end
                end
            end
        end else begin
            cnt_load_bias_h <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_load_bias_oc <= 0;
        end else if (is_conv) begin
            if (is_load_ing) begin
                if (period_done_fall_pulse & is_cnt_load_wei_rs_end & ((is_cnt_load_wei_ic_end & is_stc) | is_dwc)
                        & is_cnt_load_bias_w_end & is_cnt_load_bias_h_end) begin
                    if (is_cnt_load_bias_oc_end) begin
                        cnt_load_bias_oc <= 0;
                    end else begin
                        cnt_load_bias_oc <= cnt_load_bias_oc + 1;
                    end
                end
            end

        end else if (is_pool) begin
            if (is_bias_load_ing) begin
                if (period_done_fall_pulse & is_cnt_load_bias_w_end & is_cnt_load_bias_h_end) begin
                    if (is_cnt_load_bias_oc_end) begin
                        cnt_load_bias_oc <= 0;
                    end else begin
                        cnt_load_bias_oc <= cnt_load_bias_oc + 1;
                    end
                end
            end
        end else begin
            cnt_load_bias_oc <= 0;
        end
    end

    // cal计数器
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_cal_rs <= 0;
        end else if (is_conv & is_cal_ing) begin
            if (period_done_fall_pulse) begin
                if (is_cnt_cal_rs_end) begin
                    cnt_cal_rs <= 0;
                end else begin
                    cnt_cal_rs <= cnt_cal_rs + 1;
                end
            end
        end else begin
            cnt_cal_rs <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_cal_ic <= 0;
        end else if (is_cal_ing) begin
            if (is_conv) begin
                if (period_done_fall_pulse & is_cnt_cal_rs_end & (is_stc | (is_cnt_cal_w_end & is_cnt_cal_h_end & is_dwc))) begin
                    if (is_cnt_cal_ic_end) begin
                        cnt_cal_ic <= 0;
                    end else begin
                        cnt_cal_ic <= cnt_cal_ic + 1;
                    end
                end
            end else begin
                if (period_done_fall_pulse & is_cnt_cal_w_end & is_cnt_cal_h_end) begin
                    if (is_cnt_cal_ic_end) begin
                        cnt_cal_ic <= 0;
                    end else begin
                        cnt_cal_ic <= cnt_cal_ic + 1;
                    end
                end
            end

        end else begin
            cnt_cal_ic <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_cal_w <= 0;
        end else if (is_cal_ing) begin
            if (is_conv) begin
                if (period_done_fall_pulse & is_cnt_cal_rs_end & ((is_cnt_cal_ic_end & is_stc) | is_dwc)) begin
                    if (is_cnt_cal_w_end) begin
                        cnt_cal_w <= 0;
                    end else begin
                        cnt_cal_w <= cnt_cal_w + 1;
                    end
                end
            end else begin
                if (period_done_fall_pulse) begin
                    if (is_cnt_cal_w_end) begin
                        cnt_cal_w <= 0;
                    end else begin
                        cnt_cal_w <= cnt_cal_w + 1;
                    end
                end
            end

        end else begin
            cnt_cal_w <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_cal_h <= 0;
        end else if (is_cal_ing) begin
            if (is_conv) begin
                if (period_done_fall_pulse & is_cnt_cal_rs_end & ((is_cnt_cal_ic_end & is_stc) | is_dwc)
                                    &is_cnt_cal_w_end) begin
                    if (is_cnt_cal_h_end) begin
                        cnt_cal_h <= 0;
                    end else begin
                        cnt_cal_h <= cnt_cal_h + 1;
                    end
                end
            end else begin
                if (period_done_fall_pulse & is_cnt_cal_w_end) begin
                    if (is_cnt_cal_h_end) begin
                        cnt_cal_h <= 0;
                    end else begin
                        cnt_cal_h <= cnt_cal_h + 1;
                    end
                end
            end

        end else begin
            cnt_cal_h <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_cal_oc <= 0;
        end else if (is_cal_ing) begin
            if (is_conv) begin
                if (period_done_fall_pulse & is_cnt_cal_rs_end & ((is_cnt_cal_ic_end & is_stc) | is_dwc) 
                        & is_cnt_cal_w_end & is_cnt_cal_h_end) begin
                    if (is_cnt_cal_oc_end) begin
                        cnt_cal_oc <= 0;
                    end else begin
                        cnt_cal_oc <= cnt_cal_oc + 1;
                    end
                end
            end else begin
                if (period_done_fall_pulse & is_cnt_cal_w_end & is_cnt_cal_h_end) begin
                    if (is_cnt_cal_oc_end) begin
                        cnt_cal_oc <= 0;
                    end else begin
                        cnt_cal_oc <= cnt_cal_oc + 1;
                    end
                end
            end

        end else begin
            cnt_cal_oc <= 0;
        end
    end

    // write 计数器

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_write_omap_w <= 0;
        end else if (is_omap_write_ing) begin
            if (is_omap_write_period_done) begin
                if (is_cnt_write_omap_w_end) begin
                    cnt_write_omap_w <= 0;
                end else begin
                    cnt_write_omap_w <= cnt_write_omap_w + 1;
                end
            end
        end else begin
            cnt_write_omap_w <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_write_omap_h <= 0;
        end else if (is_omap_write_ing) begin
            if (is_omap_write_period_done & is_cnt_write_omap_w_end) begin
                if (is_cnt_write_omap_h_end) begin
                    cnt_write_omap_h <= 0;
                end else begin
                    cnt_write_omap_h <= cnt_write_omap_h + 1;
                end
            end
        end else begin
            cnt_write_omap_h <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_write_omap_oc <= 0;
        end else if (is_omap_write_ing) begin
            if (is_omap_write_period_done & is_cnt_write_omap_w_end & is_cnt_write_omap_h_end) begin
                if (is_cnt_write_omap_oc_end) begin
                    cnt_write_omap_oc <= 0;
                end else begin
                    cnt_write_omap_oc <= cnt_write_omap_oc + 1;
                end
            end
        end else begin
            cnt_write_omap_oc <= 0;
        end
    end


    // reg ram_weight_pingpong;
    // reg ram_imap_pingpong;
    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         ram_weight_pingpong <= 0;
    //     end else if (is_weight_load_period_done) begin
    //         ram_weight_pingpong <= ~ram_weight_pingpong;
    //     end
    // end

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         ram_imap_pingpong <= 0;
    //     end else if (is_imap_load_period_done) begin
    //         ram_imap_pingpong <= ~ram_imap_pingpong;
    //     end
    // end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ram_weight_pingpong <= 0;
        end else if (is_conv & is_weight_load_period_done) begin
            if (num_rs == 0 && ((num_ic == 0 & is_stc) | is_dwc) && num_oc == 0) begin
                if (curr_state == S_LOAD) begin
                    ram_weight_pingpong <= ~ram_weight_pingpong; // 这个时候只需要最开始反转一下就行
                end
            end else if (num_rs == 0 && ((num_ic == 0 & is_stc) | is_dwc)) begin
                if ((curr_state == S_LOAD) || (cnt_load_imap_w == 0 && cnt_load_imap_h == 0)) begin
                    ram_weight_pingpong <= ~ram_weight_pingpong; // 开始迭代下一个oc_num的时候
                end
            end else begin
                ram_weight_pingpong <= ~ram_weight_pingpong;
            end

        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ram_imap_pingpong <= 0;
        end else if (is_imap_load_period_done) begin
            if (num_ic == 0 && num_ow == 0 && num_oh == 0) begin
                if (curr_state == S_LOAD) begin
                    ram_imap_pingpong <= ~ram_imap_pingpong;// 这个时候只需要最开始反转一下就行,其他时候保持
                end
            end else begin
                ram_imap_pingpong <= ~ram_imap_pingpong;
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ram_bias2_pingpong <= 0;
        end else if (is_bias_load_period_done & use_bias2_add_external) begin
            ram_bias2_pingpong <= ~ram_bias2_pingpong;
        end
    end

    // 2024.7.12 fix 当num_rs == 0 && num_ic == 0的时候bias写与omap读 写后读的问题解决

    reg [2:0] omap_ram_wsel_135;  // omap sram的135选择器的选择信号
    reg [1:0] omap_ram_rsel_24[1:0];


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            omap_ram_rsel_24[0] <= 2'b00;
            omap_ram_rsel_24[1] <= 2'b00;
        end else if (mat_core_start) begin
            if ((num_rs == 0 && ((num_ic == 0 && is_stc) || is_dwc) && is_conv) || is_pool) begin
                omap_ram_rsel_24[0] <= 2'b10;  //复位值为2
                omap_ram_rsel_24[1] <= 2'b00;  //复位值为0
            end else begin
                omap_ram_rsel_24[0] <= 2'b01;  //复位值为1
                omap_ram_rsel_24[1] <= 2'b00;  //复位值为0
            end
        end else if (curr_state != S_IDLE) begin
            if ((num_rs == 0 && ((num_ic == 0 && is_stc) || is_dwc) && is_conv) || is_pool) begin
                if (is_bias_load_period_done) begin
                    if (omap_ram_rsel_24[0] == 2'b10) begin
                        omap_ram_rsel_24[0] <= 2'b00;
                    end else begin
                        omap_ram_rsel_24[0] <= omap_ram_rsel_24[0] + 1'b1;
                    end
                end
                if (is_omap_write_period_done) begin
                    if (omap_ram_rsel_24[1] == 2'b10) begin
                        omap_ram_rsel_24[1] <= 2'b00;
                    end else begin
                        omap_ram_rsel_24[1] <= omap_ram_rsel_24[1] + 1'b1;
                    end
                end
            end else begin
                if (is_bias_load_period_done) begin
                    omap_ram_rsel_24[0][0] <= ~omap_ram_rsel_24[0][0];
                end
                if (is_omap_write_period_done) begin
                    omap_ram_rsel_24[1][0] <= ~omap_ram_rsel_24[1][0];
                end
            end
        end else begin
            omap_ram_rsel_24[0] <= 2'b00;
            omap_ram_rsel_24[1] <= 2'b00;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            omap_ram_wsel_135 <= 3'b001;
        end else if (curr_state != S_IDLE) begin
            if ((num_rs == 0 && ((num_ic == 0 && is_stc) || is_dwc) && is_conv) || is_pool) begin
                if (is_bias_load_period_done || is_cal_period_done) begin
                    if (omap_ram_wsel_135[0] == 1'b1 && omap_ram_wsel_135[2] == 1'b0) begin
                        omap_ram_wsel_135[0] <= 1'b0;
                    end else if (omap_ram_wsel_135[0] == 1'b0 && omap_ram_wsel_135[2] == 1'b1) begin
                        omap_ram_wsel_135[0] <= 1'b1;
                    end

                    if (omap_ram_wsel_135[1] == 1'b1 && omap_ram_wsel_135[0] == 1'b0) begin
                        omap_ram_wsel_135[1] <= 1'b0;
                    end else if (omap_ram_wsel_135[1] == 1'b0 && omap_ram_wsel_135[0] == 1'b1) begin
                        omap_ram_wsel_135[1] <= 1'b1;
                    end

                    if (omap_ram_wsel_135[2] == 1'b1 && omap_ram_wsel_135[1] == 1'b0) begin
                        omap_ram_wsel_135[2] <= 1'b0;
                    end else if (omap_ram_wsel_135[2] == 1'b0 && omap_ram_wsel_135[1] == 1'b1) begin
                        omap_ram_wsel_135[2] <= 1'b1;
                    end
                end
            end else begin
                if (is_bias_load_period_done) begin
                    omap_ram_wsel_135[0] <= ~omap_ram_wsel_135[0];
                end
                if (is_bias_load_period_done) begin
                    omap_ram_wsel_135[1] <= ~omap_ram_wsel_135[1];
                end
                omap_ram_wsel_135[2] <= 1'b0;
            end
        end else begin
            omap_ram_wsel_135 <= 3'b001;
        end
    end


    reg [4:0] omap_ram_sel_enable;// omap sram的5个选择器的使能信号，omap_ram_sel_enable=0时选择器选到全0

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            omap_ram_sel_enable <= 5'b00000;
        end else if (curr_state != S_IDLE) begin
            if ((num_rs == 0 && ((num_ic == 0 && is_stc) || is_dwc) && is_conv) || is_pool) begin
                if (omap_ram_wsel_135[0] == 1) begin
                    omap_ram_sel_enable[0] <= 1;
                end else if (is_bias_load_period_done && omap_ram_wsel_135[0] == 0) begin
                    omap_ram_sel_enable[0] <= ~(omap_ram_sel_enable[0]);
                end

                if (omap_ram_wsel_135[1] == 1) begin
                    omap_ram_sel_enable[2] <= 1;
                end else if (is_bias_load_period_done && omap_ram_wsel_135[1] == 0) begin
                    omap_ram_sel_enable[2] <= ~(omap_ram_sel_enable[2]);
                end

                if (is_cal_ing_period && omap_ram_wsel_135[2] == 1) begin
                    omap_ram_sel_enable[4] <= 1;
                end else if (is_cal_ing_period && is_bias_load_period_done && omap_ram_wsel_135[2] == 0 ) begin
                    omap_ram_sel_enable[4] <= ~(omap_ram_sel_enable[4]);
                end
                omap_ram_sel_enable[1] <= is_cal_ing_period;
                omap_ram_sel_enable[3] <= is_omap_write_ing_period;

            end else begin
                if (is_bias_load_ing_period && (~is_bias_load_period_done)) begin
                    omap_ram_sel_enable[0] <= 1;
                end else if (is_bias_load_period_done && omap_ram_wsel_135[0] == 0) begin
                    omap_ram_sel_enable[0] <= 0;
                end

                if (is_bias_load_ing_period && (~is_bias_load_period_done) && omap_ram_wsel_135[1] == 1 && omap_ram_sel_enable[2] == 0 ) begin
                    omap_ram_sel_enable[2] <= 1;
                end else if(is_bias_load_period_done && omap_ram_wsel_135[1] == 0 && omap_ram_sel_enable[2] == 1) begin
                    omap_ram_sel_enable[2] <= 0;
                end

                omap_ram_sel_enable[1] <= is_cal_ing_period;
                omap_ram_sel_enable[3] <= is_omap_write_ing_period;
                omap_ram_sel_enable[4] <= 1'b0;
            end

        end else begin
            omap_ram_sel_enable <= 5'b00000;
        end
    end

    // reg [1:0] ram_omap_sel[4:0];
    generate
        for (genvar j = 0; j < 5; j = j + 1) begin
            if (j == 0 || j == 2 || j == 4) begin
                assign ram_omap_sel[j][0] = omap_ram_wsel_135[j/2];
                assign ram_omap_sel[j][1] = omap_ram_sel_enable[j];
            end else begin
                assign ram_omap_sel[j]=(omap_ram_sel_enable[j]==1'b1) ? omap_ram_rsel_24[j/2] : 2'b11;
            end
        end
    endgenerate




    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ram_omap_ren_sel <= 3'b001;
        end else if (mat_core_start) begin
            if ((num_rs == 0 && ((num_ic == 0 && is_stc) || is_dwc) && is_conv) || is_pool) begin
                ram_omap_ren_sel <= 3'b011;
            end else begin
                ram_omap_ren_sel <= 3'b001;
            end
        end else if (curr_state != S_IDLE) begin
            if ((num_rs == 0 && ((num_ic == 0 && is_stc) || is_dwc) && is_conv) || is_pool) begin
                if (is_bias_load_period_done) begin
                    ram_omap_ren_sel <= {
                        ram_omap_ren_sel[1], ram_omap_ren_sel[0], ram_omap_ren_sel[2]
                    };
                end
            end else begin
                if (is_bias_load_period_done) begin
                    ram_omap_ren_sel <= {
                        ram_omap_ren_sel[2], ram_omap_ren_sel[0], ram_omap_ren_sel[1]
                    };
                end
            end

        end else begin
            ram_omap_ren_sel <= 3'b001;
        end
    end





    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            pe_array_start <= 0;
        end else begin
            case (curr_state)
                S_LOAD, S_LOAD_CAL: begin
                    if ((~is_cal_finish) & period_done_fall_pulse & (~is_cal_finish_pulse)) begin
                        pe_array_start <= 1;
                    end else begin
                        pe_array_start <= 0;
                    end
                end
                default: begin
                    pe_array_start <= 0;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            load_weight_start <= 0;
        end else if (is_conv) begin
            case (curr_state)
                S_IDLE: begin
                    if (next_state == S_LOAD) begin
                        load_weight_start <= 1;
                    end else begin
                        load_weight_start <= 0;
                    end
                end
                S_LOAD, S_LOAD_CAL: begin
                    if((~is_weight_load_finish) & period_done_fall_pulse
                                 & (~is_weight_load_finish_pulse)) begin
                        if (num_rs == 0 && ((num_ic == 0 && is_stc) || is_dwc) && num_oc == 0) begin //如果缓存存下所有权重，则后续都不需要加载
                            load_weight_start <= 0;
                        end else if (num_rs == 0 && ((num_ic == 0 && is_stc) || is_dwc)) begin
                            // 如果缓存能存下输入通道ic_num分块的一整个cube，则同属于一个ic_num的不同wh分块的imap可以共用这个权重,
                            // 只有当imap迭代到w和h最后的时候才发起下一次传输
                            if(is_cnt_load_imap_w_end & is_cnt_load_imap_h_end & ((is_cnt_load_imap_ic_end & is_stc) | is_dwc))  begin
                                load_weight_start <= 1;
                            end else begin
                                load_weight_start <= 0;
                            end
                        end else begin
                            load_weight_start <= 1;
                        end
                    end else begin
                        load_weight_start <= 0;
                    end

                end
                default: begin
                    load_weight_start <= 0;
                end
            endcase
        end else begin
            load_weight_start <= 0;
        end
    end



    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            load_imap_start <= 0;
        end else begin
            case (curr_state)
                S_IDLE: begin
                    if (next_state == S_LOAD) begin
                        load_imap_start <= 1;
                    end else begin
                        load_imap_start <= 0;
                    end
                end
                S_LOAD, S_LOAD_CAL: begin
                    if((~is_imap_load_finish) & period_done_fall_pulse 
                                   & is_cnt_load_wei_rs_end & (~is_imap_load_finish_pulse)) begin
                        if (num_ic == 0 && num_ow == 0 && num_oh == 0) begin
                            load_imap_start <= 0;//如果缓存能存下所有特征图，则后续都不需要加载
                        end else begin
                            load_imap_start <= 1;
                        end
                    end else begin
                        load_imap_start <= 0;
                    end
                end
                default: begin
                    load_imap_start <= 0;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            load_bias_start <= 0;
        end else if (is_conv) begin
            case (curr_state)
                S_IDLE: begin
                    if (next_state == S_LOAD & use_bias_external) begin
                        load_bias_start <= 1;
                    end else begin
                        load_bias_start <= 0;
                    end
                end
                S_LOAD, S_LOAD_CAL: begin
                    if((~is_bias_load_finish) & period_done_fall_pulse & is_cnt_load_wei_rs_end
                                 & ((is_cnt_load_wei_ic_end & is_stc) | is_dwc) & (~is_bias_load_finish_pulse) & use_bias_external) begin
                        if (num_oc == 0 && num_ow == 0 && num_oh == 0) begin//如果缓存能存下所有bias，则后续都不需要加载
                            load_bias_start <= 0;
                        end else begin
                            load_bias_start <= 1;
                        end

                    end else begin
                        load_bias_start <= 0;
                    end
                end
                default: begin
                    load_bias_start <= 0;
                end
            endcase
        end else begin
            load_bias_start <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            load_bias2_start <= 0;
        end else begin
            case (curr_state)
                S_IDLE: begin
                    if (next_state == S_LOAD & use_bias2_add_external) begin
                        load_bias2_start <= 1;
                    end else begin
                        load_bias2_start <= 0;
                    end
                end
                S_LOAD, S_LOAD_CAL: begin
                    if((~is_bias_load_finish) & period_done_fall_pulse & is_cnt_load_wei_rs_end
                                 & ((is_stc & is_cnt_load_wei_ic_end) | is_not_stc) & (~is_bias_load_finish_pulse) & use_bias2_add_external) begin
                        if (num_oc == 0 && num_ow == 0 && num_oh == 0) begin//如果缓存能存下所有bias，则后续都不需要加载
                            load_bias2_start <= 0;
                        end else begin
                            load_bias2_start <= 1;
                        end

                    end else begin
                        load_bias2_start <= 0;
                    end
                end
                default: begin
                    load_bias2_start <= 0;
                end
            endcase
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            write_omap_start <= 0;
        end else begin
            case (curr_state)
                S_LOAD_CAL: begin
                    if (is_conv) begin
                        if( period_done_fall_pulse & is_cnt_cal_rs_end
                                 & ((is_cnt_cal_ic_end & is_stc) | is_dwc) & (~is_omap_write_finish_pulse)) begin
                            write_omap_start <= 1;
                        end else begin
                            write_omap_start <= 0;
                        end
                    end else begin
                        if (period_done_fall_pulse & (~is_omap_write_finish_pulse)) begin
                            write_omap_start <= 1;
                        end else begin
                            write_omap_start <= 0;
                        end
                    end

                end
                default: begin
                    write_omap_start <= 0;
                end
            endcase
        end
    end



    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            total_rs_start <= 0;
        end else begin
            case (curr_state)
                S_LOAD, S_LOAD_CAL: begin
                    if((~is_weight_load_finish) & period_done_fall_pulse & (cnt_load_wei_rs==0)
                                  & (~is_weight_load_finish_pulse)) begin
                        total_rs_start <= 1;
                    end else begin
                        total_rs_start <= 0;
                    end
                end
                default: begin
                    total_rs_start <= 0;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            total_rs_done <= 0;
        end else begin
            case (curr_state)
                S_LOAD, S_LOAD_CAL: begin
                    if ((~is_weight_load_finish) & period_done_fall_pulse & is_cnt_cal_rs_end) begin
                        total_rs_done <= 1;
                    end else begin
                        total_rs_done <= 0;
                    end
                end
                default: begin
                    total_rs_done <= 0;
                end
            endcase
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            use_bias_internal <= 0;
        end else begin
            case (curr_state)
                S_LOAD_CAL: begin
                    if (((cnt_cal_rs == 0) & (((cnt_cal_ic == 0) & is_stc) | is_dwc))) begin
                        use_bias_internal <= use_bias_external; //开始的时候use_bias_internal==use_bias_external
                    end else begin
                        use_bias_internal <= 1;// 其他情况下，use_bias_internal=1，即每个点都需要加上bias，这里的bias是上一次的部分和
                    end
                end
                default: begin
                    use_bias_internal <= use_bias_external;
                end
            endcase
        end
    end



    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            bias_mode_internal <= 1;
        end else begin
            case (curr_state)
                S_LOAD_CAL: begin
                    if (((cnt_cal_rs == 0) & (((cnt_cal_ic == 0) & is_stc) | is_dwc))) begin
                        bias_mode_internal <= bias_mode_external; //开始的时候bias_mode_internal==bias_mode_external
                    end else begin
                        bias_mode_internal <= 1;// 其他情况下，bias_mode_internal=1，即每个点都需要加上bias，这里的bias是上一次的部分和
                    end
                end
                default: begin
                    bias_mode_internal <= bias_mode_external;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            use_quan_internal <= 0;
        end else begin
            case (curr_state)
                S_LOAD_CAL: begin
                    if ((is_cnt_cal_rs_end & ((is_cnt_cal_ic_end & is_stc) | is_dwc)) | is_pool) begin
                        use_quan_internal <= use_quan_external;
                    end else begin
                        use_quan_internal <= 0;
                    end
                end
                default: begin
                    use_quan_internal <= use_quan_external;
                end
            endcase
        end
    end









endmodule
