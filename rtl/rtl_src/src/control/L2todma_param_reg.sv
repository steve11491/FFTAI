module L2todma_param_reg #(
    parameter IMAP_DIM_WIDTH = 10,
    parameter DIM_WIDTH = 8,
    parameter PADDING_WIDTH = 5,
    parameter NUM_WIDTH = 8,
    parameter WEIGHT_WIDTH = 16,
    parameter IMAP_WIDTH = 16,
    parameter OMAP_WIDTH = 16,
    parameter BIAS_WIDTH = 32,
    parameter CHANNEL_NUM = 16,
    parameter BUS_WIDTH = 64,
    parameter C_WIDTH = $clog2(CHANNEL_NUM * 2),
    parameter BURST_NUM_WIDTH_IMAP = $clog2(
        CHANNEL_NUM * 2
    ) + IMAP_DIM_WIDTH - 8 - $clog2(
        BUS_WIDTH / 8
    ),
    parameter BURST_NUM_WIDTH = $clog2(CHANNEL_NUM * 2) + DIM_WIDTH - 8 - $clog2(BUS_WIDTH / 8)
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire is_dwc,
    input wire L2_load_imap_start,
    input wire is_cnt_load_imap_w_end,
    input wire is_cnt_load_imap_h_end,
    input wire is_cnt_load_imap_ic_end,

    input wire L2_load_weight_start,
    input wire is_cnt_load_wei_rs_end,
    input wire is_cnt_load_wei_ic_end,
    input wire is_cnt_load_wei_oc_end,

    input wire L2_load_bias_start,
    input wire L2_load_bias2_start,
    input wire is_cnt_load_bias_w_end,
    input wire is_cnt_load_bias_h_end,
    input wire is_cnt_load_bias_oc_end,

    input wire L2_write_omap_start,
    input wire is_cnt_write_omap_w_end,
    input wire is_cnt_write_omap_h_end,
    input wire is_cnt_write_omap_oc_end,

    input wire [DIM_WIDTH-1:0] basic_ow,  // 输出特征图块宽度
    input wire [DIM_WIDTH-1:0] basic_oh,  // 输出特征图块高度
    input wire [DIM_WIDTH-1:0] basic_oc,  // 需要是4的倍数
    input wire [DIM_WIDTH-1:0] basic_ic,  // 需要是4的倍数
    input wire [DIM_WIDTH-1:0] basic_rs,


    input wire [IMAP_DIM_WIDTH-1:0] basic_iw,
    input wire [IMAP_DIM_WIDTH-1:0] basic_ih,
    input wire [IMAP_DIM_WIDTH-1:0] basic_ow_sx,
    input wire [IMAP_DIM_WIDTH-1:0] basic_oh_sy,

    input wire [DIM_WIDTH-1:0] remain_ow,  // 输出特征图块宽度
    input wire [DIM_WIDTH-1:0] remain_oh,  // 输出特征图块高度
    input wire [DIM_WIDTH-1:0] remain_oc,
    input wire [DIM_WIDTH-1:0] remain_ic,
    input wire [DIM_WIDTH-1:0] remain_rs,

    input wire [IMAP_DIM_WIDTH-1:0] remain_iw,
    input wire [IMAP_DIM_WIDTH-1:0] remain_ih,

    input wire [              3:0] use_padding_external,
    input wire [PADDING_WIDTH-1:0] padding_external    [3:0],
    input wire [    NUM_WIDTH-1:0] cnt_load_imap_h,
    input wire [    NUM_WIDTH-1:0] cnt_load_imap_w,
    input wire                     bias_mode_external,


    output reg load_imap_start,
    output reg load_weight_start,
    output reg load_bias_start,
    output reg load_bias2_start,
    output reg write_omap_start,



    output reg [IMAP_DIM_WIDTH-1:0] imap_block_len_iw_np,
    output reg [IMAP_DIM_WIDTH-1:0] imap_block_len_ih_np,
    output wire [DIM_WIDTH-1:0] imap_block_len_ic,
    output reg [IMAP_DIM_WIDTH+1-1:0] imap_block_len_iw_add1,
    output reg [(IMAP_DIM_WIDTH+1)*2-1:0] imap_block_len_iwh_add1,

    output wire [3:0] padding_flag,
    output reg [PADDING_WIDTH-1:0] padding_internal[3:0],


    output wire [DIM_WIDTH-1:0] weight_block_len_ic,
    output wire [DIM_WIDTH-1:0] weight_block_len_rs,
    output wire [DIM_WIDTH-1:0] weight_block_len_oc,
    output reg [DIM_WIDTH+1-1:0] weight_block_len_ic_add1,
    output reg [(DIM_WIDTH+1)*2-1:0] weight_block_len_icrs_add1,


    output wire [DIM_WIDTH-1:0] bias_block_len_ow,
    output wire [DIM_WIDTH-1:0] bias_block_len_oh,
    output wire [DIM_WIDTH-1:0] bias_block_len_oc,
    output reg [DIM_WIDTH+1-1:0] bias_block_len_ow_add1,
    output reg [(DIM_WIDTH+1)*2-1:0] bias_block_len_owh_add1,


    output wire [DIM_WIDTH-1:0] omap_block_len_ow,
    output wire [DIM_WIDTH-1:0] omap_block_len_oh,
    output wire [DIM_WIDTH-1:0] omap_block_len_oc,
    output reg [DIM_WIDTH+1-1:0] omap_block_len_ow_add1,
    output reg [(DIM_WIDTH+1)*2-1:0] omap_block_len_owh_add1,


    output reg [C_WIDTH-1:0] imap_currc_end_c,
    output reg [C_WIDTH-1:0] imap_currc_not_end_c,
    output reg [BURST_NUM_WIDTH_IMAP-1:0] imap_burst_num_end_c,
    output reg [BURST_NUM_WIDTH_IMAP-1:0] imap_burst_num_not_end_c,
    output reg [7:0] imap_remain_burst_len_end_c,
    output reg [7:0] imap_remain_burst_len_not_end_c,

    output reg [C_WIDTH-1:0] weight_currc_end_c,  //最后一个c方向的c数量
    output reg [C_WIDTH-1:0] weight_currc_not_end_c,  //不是最后一个c方向的c数量
    output reg [BURST_NUM_WIDTH-1:0] weight_burst_num_end_c,  //最后一个c方向的突发个数
    output reg [BURST_NUM_WIDTH-1:0] weight_burst_num_not_end_c,//不是最后一个c方向的突发个数
    output reg [7:0] weight_remain_burst_len_end_c,  //最后一个c方向的最后一块不足256的长度
    output reg [7:0] weight_remain_burst_len_not_end_c, //不是最后一个c方向的最后一块不足256的长

    output reg [C_WIDTH-1:0] bias_currc_end_c,
    output reg [C_WIDTH-1:0] bias_currc_not_end_c,
    output reg [BURST_NUM_WIDTH+1-1:0] bias_burst_num_end_c,
    output reg [BURST_NUM_WIDTH+1-1:0] bias_burst_num_not_end_c,
    output reg [7:0] bias_remain_burst_len_end_c,
    output reg [7:0] bias_remain_burst_len_not_end_c,

    output reg [C_WIDTH-1:0] bias2_currc_end_c,
    output reg [C_WIDTH-1:0] bias2_currc_not_end_c,
    output reg [BURST_NUM_WIDTH-1:0] bias2_burst_num_end_c,
    output reg [BURST_NUM_WIDTH-1:0] bias2_burst_num_not_end_c,
    output reg [7:0] bias2_remain_burst_len_end_c,
    output reg [7:0] bias2_remain_burst_len_not_end_c,

    output reg [C_WIDTH-1:0] omap_currc_end_c,
    output reg [C_WIDTH-1:0] omap_currc_not_end_c,
    output reg [BURST_NUM_WIDTH-1:0] omap_burst_num_end_c,
    output reg [BURST_NUM_WIDTH-1:0] omap_burst_num_not_end_c,
    output reg [7:0] omap_remain_burst_len_end_c,
    output reg [7:0] omap_remain_burst_len_not_end_c,


    output reg [DIM_WIDTH+1-1:0] basic_ow_add1,
    output reg [DIM_WIDTH+1-1:0] basic_oh_add1,
    output reg [DIM_WIDTH+1-1:0] basic_oc_add1,
    output reg [DIM_WIDTH+1-1:0] basic_ic_add1,
    output reg [DIM_WIDTH+1-1:0] basic_rs_add1,
    output reg [IMAP_DIM_WIDTH+1-1:0] basic_ow_sx_add1,
    output reg [IMAP_DIM_WIDTH+1-1:0] basic_oh_sy_add1

);

    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
        end else begin
            is_int16_reg <= is_int16;

        end
    end

    localparam DELAY = 5;

    reg [DELAY-1:0] load_imap_start_ff;
    reg [DELAY-1:0] load_weight_start_ff;
    reg [DELAY-1:0] load_bias_start_ff;
    reg [DELAY-1:0] load_bias2_start_ff;
    reg [DELAY-1:0] write_omap_start_ff;
    always @(posedge clk) begin
        for (int i = 0; i < DELAY - 1; i = i + 1) begin
            load_imap_start_ff[i+1]   <= load_imap_start_ff[i];
            load_imap_start_ff[i+1]   <= load_imap_start_ff[i];
            load_weight_start_ff[i+1] <= load_weight_start_ff[i];
            load_bias_start_ff[i+1]   <= load_bias_start_ff[i];
            load_bias2_start_ff[i+1]  <= load_bias2_start_ff[i];
            write_omap_start_ff[i+1]  <= write_omap_start_ff[i];
        end
        load_imap_start_ff[0]   <= L2_load_imap_start;
        load_weight_start_ff[0] <= L2_load_weight_start;
        load_bias_start_ff[0]   <= L2_load_bias_start;
        load_bias2_start_ff[0]  <= L2_load_bias2_start;
        write_omap_start_ff[0]  <= L2_write_omap_start;
    end
    assign load_imap_start   = load_imap_start_ff[DELAY-1];
    assign load_weight_start = load_weight_start_ff[DELAY-1];
    assign load_bias_start   = load_bias_start_ff[DELAY-1];
    assign load_bias2_start  = load_bias2_start_ff[DELAY-1];
    assign write_omap_start  = write_omap_start_ff[DELAY-1];


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            basic_ow_add1 <= 0;
            basic_oh_add1 <= 0;
            basic_oc_add1 <= 0;
            basic_ic_add1 <= 0;
            basic_rs_add1 <= 0;
            basic_ow_sx_add1 <= 0;
            basic_oh_sy_add1 <= 0;
        end else begin
            basic_ow_add1 <= basic_ow + 1;
            basic_oh_add1 <= basic_oh + 1;
            basic_oc_add1 <= basic_oc + 1;
            basic_ic_add1 <= basic_ic + 1;
            basic_rs_add1 <= basic_rs + 1;
            basic_ow_sx_add1 <= basic_ow_sx + 1;
            basic_oh_sy_add1 <= basic_oh_sy + 1;
        end
    end


    assign weight_block_len_ic = is_dwc ? 0 : (is_cnt_load_wei_ic_end ? remain_ic : basic_ic);
    assign weight_block_len_rs = is_cnt_load_wei_rs_end ? remain_rs : basic_rs;
    assign weight_block_len_oc = is_cnt_load_wei_oc_end ? remain_oc : basic_oc;

    reg [DIM_WIDTH+1-1:0] weight_block_len_rs_add1;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            weight_block_len_ic_add1 <= 0;
            weight_block_len_rs_add1 <= 0;
        end else begin
            weight_block_len_ic_add1 <= weight_block_len_ic + 1;
            weight_block_len_rs_add1 <= weight_block_len_rs + 1;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            weight_block_len_icrs_add1 <= 0;
        end else begin
            weight_block_len_icrs_add1 <= weight_block_len_ic_add1 * weight_block_len_rs_add1;
        end
    end




    burst_gen #(
        .DATA_WIDTH     (WEIGHT_WIDTH),
        .CHANNEL_NUM    (CHANNEL_NUM),
        .DIM_WIDTH      (DIM_WIDTH),
        .BUS_WIDTH      (BUS_WIDTH),
        .C_WIDTH        (C_WIDTH),
        .BURST_NUM_WIDTH(BURST_NUM_WIDTH)
    ) u_weight_burst_gen (
        .clk        (clk),
        .rstn       (rstn),
        .is_int16   (is_int16_reg),
        .block_len_c(weight_block_len_oc),
        .block_len_w(weight_block_len_ic),

        .currc_end_c               (weight_currc_end_c),
        .currc_not_end_c           (weight_currc_not_end_c),
        .burst_num_end_c           (weight_burst_num_end_c),
        .burst_num_not_end_c       (weight_burst_num_not_end_c),
        .remain_burst_len_end_c    (weight_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(weight_remain_burst_len_not_end_c)
    );




    assign padding_flag = {
        cnt_load_imap_h == 0, is_cnt_load_imap_h_end, cnt_load_imap_w == 0, is_cnt_load_imap_w_end
    };

    wire [IMAP_DIM_WIDTH-1:0] imap_block_len_iw;
    wire [IMAP_DIM_WIDTH-1:0] imap_block_len_ih;
    assign imap_block_len_ic = is_cnt_load_imap_ic_end ? remain_ic : basic_ic;
    assign imap_block_len_iw = is_cnt_load_imap_w_end ? remain_iw : basic_iw;  //整体计数器
    assign imap_block_len_ih = is_cnt_load_imap_h_end ? remain_ih : basic_ih;

    reg [IMAP_DIM_WIDTH+1-1:0] imap_block_len_ih_add1;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            imap_block_len_iw_add1 <= 0;
            imap_block_len_ih_add1 <= 0;
        end else begin
            imap_block_len_iw_add1 <= imap_block_len_iw + 1;
            imap_block_len_ih_add1 <= imap_block_len_ih + 1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            imap_block_len_iwh_add1 <= 0;
        end else begin
            imap_block_len_iwh_add1 <= imap_block_len_iw_add1 * imap_block_len_ih_add1;
        end
    end

    reg [3:0] use_padding_internal;


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            use_padding_internal <= 0;
        end else begin
            for (int i = 0; i < 4; i = i + 1) begin
                if (padding_flag[i]) begin
                    use_padding_internal[i] <= use_padding_external[i];
                end else begin
                    use_padding_internal[i] <= 0;
                end
            end
        end
    end
    generate
        for (genvar i = 0; i < 4; i = i + 1) begin
            assign padding_internal[i] = use_padding_internal[i] ? padding_external[i] : 0;
        end
    endgenerate

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            imap_block_len_iw_np <= 0;
        end else begin
            case (padding_flag[1:0])
                2'b00: imap_block_len_iw_np <= basic_iw;
                2'b01: imap_block_len_iw_np <= remain_iw - padding_external[0];  //-right_padding
                2'b10: imap_block_len_iw_np <= basic_iw - padding_external[1];  //-left_padding
                2'b11: begin
                    imap_block_len_iw_np<=remain_iw-padding_external[0]-padding_external[1];//-right_padding-left_padding
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            imap_block_len_ih_np <= 0;
        end else begin
            case (padding_flag[3:2])
                2'b00: imap_block_len_ih_np <= basic_ih;
                2'b01: imap_block_len_ih_np <= remain_ih - padding_external[2];  //-bottom_padding
                2'b10: imap_block_len_ih_np <= basic_ih - padding_external[3];  //-top_padding
                2'b11: begin
                    imap_block_len_ih_np<=remain_ih-padding_external[2]-padding_external[3];//-bottom_padding-top_padding
                end
            endcase

        end
    end


    burst_gen_imap #(
        .DATA_WIDTH          (IMAP_WIDTH),
        .CHANNEL_NUM         (CHANNEL_NUM),
        .DIM_WIDTH           (DIM_WIDTH),
        .IMAP_DIM_WIDTH      (IMAP_DIM_WIDTH),
        .BUS_WIDTH           (BUS_WIDTH),
        .C_WIDTH             (C_WIDTH),
        .BURST_NUM_WIDTH_IMAP(BURST_NUM_WIDTH_IMAP)
    ) u_burst_gen_imap (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16_reg),
        .block_len_c               (imap_block_len_ic),
        .block_len_w               (imap_block_len_iw_np),
        .currc_end_c               (imap_currc_end_c),
        .currc_not_end_c           (imap_currc_not_end_c),
        .burst_num_end_c           (imap_burst_num_end_c),
        .burst_num_not_end_c       (imap_burst_num_not_end_c),
        .remain_burst_len_end_c    (imap_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(imap_remain_burst_len_not_end_c)
    );



    assign bias_block_len_ow = is_cnt_load_bias_w_end ? remain_ow : basic_ow;
    assign bias_block_len_oh = is_cnt_load_bias_h_end ? remain_oh : basic_oh;
    assign bias_block_len_oc = is_cnt_load_bias_oc_end ? remain_oc : basic_oc;

    reg [DIM_WIDTH+1-1:0] bias_block_len_oh_add1;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            bias_block_len_ow_add1 <= 0;
            bias_block_len_oh_add1 <= 0;
        end else begin
            bias_block_len_ow_add1 <= bias_block_len_ow + 1;
            bias_block_len_oh_add1 <= bias_block_len_oh + 1;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            bias_block_len_owh_add1 <= 0;
        end else begin
            bias_block_len_owh_add1 <= bias_block_len_ow_add1 * bias_block_len_oh_add1;
        end
    end


    burst_gen_bias #(
        .DATA_WIDTH     (BIAS_WIDTH),
        .CHANNEL_NUM    (CHANNEL_NUM),
        .DIM_WIDTH      (DIM_WIDTH),
        .BUS_WIDTH      (BUS_WIDTH),
        .C_WIDTH        (C_WIDTH),
        .BURST_NUM_WIDTH(BURST_NUM_WIDTH + 1)
    ) u_bias_burst_gen (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16_reg),
        .bias_mode_external        (bias_mode_external),
        .block_len_c               (bias_block_len_oc),
        .block_len_w               (bias_block_len_ow),
        .currc_end_c               (bias_currc_end_c),
        .currc_not_end_c           (bias_currc_not_end_c),
        .burst_num_end_c           (bias_burst_num_end_c),
        .burst_num_not_end_c       (bias_burst_num_not_end_c),
        .remain_burst_len_end_c    (bias_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(bias_remain_burst_len_not_end_c)
    );

    burst_gen #(
        .DATA_WIDTH     (IMAP_WIDTH),
        .CHANNEL_NUM    (CHANNEL_NUM),
        .DIM_WIDTH      (DIM_WIDTH),
        .BUS_WIDTH      (BUS_WIDTH),
        .C_WIDTH        (C_WIDTH),
        .BURST_NUM_WIDTH(BURST_NUM_WIDTH)
    ) u_bias2_burst_gen (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16_reg),
        .block_len_c               (bias_block_len_oc),
        .block_len_w               (bias_block_len_ow),
        .currc_end_c               (bias2_currc_end_c),
        .currc_not_end_c           (bias2_currc_not_end_c),
        .burst_num_end_c           (bias2_burst_num_end_c),
        .burst_num_not_end_c       (bias2_burst_num_not_end_c),
        .remain_burst_len_end_c    (bias2_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(bias2_remain_burst_len_not_end_c)
    );

    assign omap_block_len_ow = is_cnt_write_omap_w_end ? remain_ow : basic_ow;
    assign omap_block_len_oh = is_cnt_write_omap_h_end ? remain_oh : basic_oh;
    assign omap_block_len_oc = is_cnt_write_omap_oc_end ? remain_oc : basic_oc;

    reg [DIM_WIDTH+1-1:0] omap_block_len_oh_add1;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            omap_block_len_ow_add1 <= 0;
            omap_block_len_oh_add1 <= 0;
        end else begin
            omap_block_len_ow_add1 <= omap_block_len_ow + 1;
            omap_block_len_oh_add1 <= omap_block_len_oh + 1;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            omap_block_len_owh_add1 <= 0;
        end else begin
            omap_block_len_owh_add1 <= omap_block_len_ow_add1 * omap_block_len_oh_add1;
        end
    end

    burst_gen #(
        .DATA_WIDTH     (OMAP_WIDTH),
        .CHANNEL_NUM    (CHANNEL_NUM),
        .DIM_WIDTH      (DIM_WIDTH),
        .BUS_WIDTH      (BUS_WIDTH),
        .C_WIDTH        (C_WIDTH),
        .BURST_NUM_WIDTH(BURST_NUM_WIDTH)
    ) u_omap_burst_gen (
        .clk                       (clk),
        .rstn                      (rstn),
        .is_int16                  (is_int16_reg),
        .block_len_c               (omap_block_len_oc),
        .block_len_w               (omap_block_len_ow),
        .currc_end_c               (omap_currc_end_c),
        .currc_not_end_c           (omap_currc_not_end_c),
        .burst_num_end_c           (omap_burst_num_end_c),
        .burst_num_not_end_c       (omap_burst_num_not_end_c),
        .remain_burst_len_end_c    (omap_remain_burst_len_end_c),
        .remain_burst_len_not_end_c(omap_remain_burst_len_not_end_c)
    );





endmodule
