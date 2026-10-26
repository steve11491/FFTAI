






module dma_bias2 #(
    parameter CHANNEL_NUM = 8,
    parameter NUM_WIDTH = 10,
    parameter DIM_WIDTH = 10,
    parameter BUS_WIDTH = 32,
    parameter BUS_ADDR_WIDTH = 32,
    parameter BIAS2_WIDTH = 16,  // int16情况下的bias2位宽
    parameter BIAS2_RAM_WIDTH = 16,  //omap ram的位宽
    parameter BIAS2_RAM_ADDR_WIDTH = 10,
    parameter AOWOH_WIDTH = 20,
    parameter AOW_WIDTH = 10,
    parameter C_WIDTH = $clog2(CHANNEL_NUM * 2),
    // bias需要加1
    parameter BURST_NUM_WIDTH = $clog2(CHANNEL_NUM * 2) + DIM_WIDTH - 8 - $clog2(BUS_WIDTH / 8),
    parameter BIAS2_SCALE_WIDTH = 16,
    parameter BIAS2_SHIFT_WIDTH = 4
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire [BIAS2_SCALE_WIDTH-1:0] scale,  //int8情况下 低8位有效，int16情况下16位有效
    input wire [BIAS2_SHIFT_WIDTH-1:0] shift,

    input wire [AOWOH_WIDTH-1:0] Aowoh,  //omap的整体oc和整体ow的乘积
    input wire [  AOW_WIDTH-1:0] Aow,    //omap的整体oc

    (* mark_debug = "false"*)
    input wire [DIM_WIDTH+1-1:0] basic_oc_add1,  // int8的情况下，bias2占16位，basic_oc需要是2的倍数，int16的情况下，bias2占32位，需要是1的倍数 (32总线位宽的情况)
    (* mark_debug = "false"*) input wire [DIM_WIDTH+1-1:0] basic_ow_add1,
    (* mark_debug = "false"*) input wire [DIM_WIDTH+1-1:0] basic_oh_add1,

    input wire load_bias2_start,

    input wire [C_WIDTH-1:0] currc_end_c,  //input
    input wire [C_WIDTH-1:0] currc_not_end_c,  //input
    input wire [BURST_NUM_WIDTH-1:0] burst_num_end_c,  //input
    input wire [BURST_NUM_WIDTH-1:0] burst_num_not_end_c,  //input

    input wire [7:0] remain_burst_len_end_c,  //input
    input wire [7:0] remain_burst_len_not_end_c,  //input

    input wire [DIM_WIDTH-1:0] block_len_ow,
    input wire [DIM_WIDTH-1:0] block_len_oh,
    input wire [DIM_WIDTH-1:0] block_len_oc,
    input wire [DIM_WIDTH+1-1:0] block_len_ow_add1,
    input wire [(DIM_WIDTH+1)*2-1:0] block_len_owh_add1,

    (* mark_debug = "false"*) input wire [NUM_WIDTH-1:0] cnt_load_bias2_w,
    (* mark_debug = "false"*) input wire [NUM_WIDTH-1:0] cnt_load_bias2_h,
    (* mark_debug = "false"*) input wire [NUM_WIDTH-1:0] cnt_load_bias2_oc,

    input wire dma_bias2_arready,  //准备接收地址
    output wire init_bias2_rtx_pulse,  //开始传输地址
    output reg [BUS_ADDR_WIDTH-1:0] bias2_offset_addr,
    output wire [8-1:0] bias2_load_burst_len,
    output reg dma_bias2_rready,

    input wire din_valid,
    input wire [BUS_WIDTH-1:0] din_data,  //din_valid为高时，din有效

    output reg [BIAS2_RAM_ADDR_WIDTH-1:0] bias2_waddr,
    output wire [BIAS2_RAM_WIDTH-1:0] bias2_wdata[CHANNEL_NUM-1:0],
    output reg [CHANNEL_NUM-1:0] bias2_wen,
    output reg is_load_bias2_done,
    output reg is_load_bias2_busy
);

    // for debug
    wire [BIAS2_WIDTH-1:0] din_data_int16[BUS_WIDTH/(BIAS2_WIDTH)-1:0];
    wire [BIAS2_WIDTH/2-1:0] din_data_int8[BUS_WIDTH/(BIAS2_WIDTH/2)-1:0];
    wire [BIAS2_RAM_WIDTH/2-1:0] bias2_wdata_int8[CHANNEL_NUM*2-1:0];
    wire [BIAS2_RAM_WIDTH-1:0] bias2_wdata_int16[CHANNEL_NUM-1:0];
    generate
        for (genvar i = 0; i < BUS_WIDTH / BIAS2_WIDTH; i = i + 1) begin
            assign din_data_int16[i] = din_data[(i+1)*BIAS2_WIDTH-1:i*BIAS2_WIDTH];
        end
        for (genvar i = 0; i < BUS_WIDTH / (BIAS2_WIDTH / 2); i = i + 1) begin
            assign din_data_int8[i] = din_data[(i+1)*(BIAS2_WIDTH/2)-1:i*(BIAS2_WIDTH/2)];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign bias2_wdata_int16[i] = bias2_wdata[i];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {bias2_wdata_int8[i*2+1], bias2_wdata_int8[i*2]} = bias2_wdata[i];
        end
    endgenerate

    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
        end else begin
            is_int16_reg <= is_int16;
        end
    end

    wire [BUS_WIDTH / BIAS2_WIDTH-1:0] din_valid_w;
    wire [BUS_WIDTH-1:0] din_data_scale;
    // 输入放缩
    generate
        for (genvar i = 0; i < BUS_WIDTH / BIAS2_WIDTH; i = i + 1) begin : bias2_quan
            bias2_quan #(
                .WIDTH      (BIAS2_WIDTH),
                .SCALE_WIDTH(BIAS2_SCALE_WIDTH),
                .SHIFT_WIDTH(BIAS2_SHIFT_WIDTH)
            ) u_bias2_quan (
                .clk      (clk),
                .rstn     (rstn),
                .is_int16 (is_int16_reg),
                .in_valid (din_valid),
                .scale    (scale),
                .shift    (shift),
                .din      (din_data[BIAS2_WIDTH*(i+1)-1:BIAS2_WIDTH*i]),
                .dout     (din_data_scale[BIAS2_WIDTH*(i+1)-1:BIAS2_WIDTH*i]),
                .out_valid(din_valid_w[i])
            );
        end
    endgenerate
    wire din_valid_scale;
    assign din_valid_scale = din_valid_w[0];

    wire [  BIAS2_WIDTH-1:0] din_data_scale_int16[  BUS_WIDTH/(BIAS2_WIDTH)-1:0];
    (* mark_debug = "false"*)wire [BIAS2_WIDTH/2-1:0] din_data_scale_int8 [BUS_WIDTH/(BIAS2_WIDTH/2)-1:0];
    generate
        for (genvar i = 0; i < BUS_WIDTH / BIAS2_WIDTH; i = i + 1) begin
            assign din_data_scale_int16[i] = din_data_scale[(i+1)*BIAS2_WIDTH-1:i*BIAS2_WIDTH];
        end
        for (genvar i = 0; i < BUS_WIDTH / (BIAS2_WIDTH / 2); i = i + 1) begin
            assign din_data_scale_int8[i] = din_data_scale[(i+1)*(BIAS2_WIDTH/2)-1:i*(BIAS2_WIDTH/2)];
        end

    endgenerate

    wire bias2_mode_external = 1'b1;

    reg load_finish;
    localparam S_IDLE = 0, S_LOAD = 1;

    reg curr_state, next_state;

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
                    if (load_bias2_start) begin
                        next_state = S_LOAD;
                    end else begin
                        next_state = S_IDLE;
                    end
                end
                S_LOAD: begin
                    if (is_load_bias2_done) begin
                        next_state = S_IDLE;
                    end else begin
                        next_state = S_LOAD;
                    end
                end
                default: begin
                    next_state = S_IDLE;
                end
            endcase
        end
    end
    wire en;
    assign is_load_bias2_busy = (curr_state == S_LOAD);
    assign en = is_load_bias2_busy;


    localparam CNT_WIDTH = DIM_WIDTH;
    localparam OC_CNT = $clog2(CHANNEL_NUM * 2);
    localparam S_WIDTH = $clog2(OC_CNT) + 1;
    wire [S_WIDTH-1:0] shift_value;
    assign shift_value = is_int16_reg ? (OC_CNT - 1) : (OC_CNT);

    parameter LOW_CUT_BIT = $clog2(BUS_WIDTH / BIAS2_WIDTH);

    wire [DIM_WIDTH-1:0] shift_block_len_oc = block_len_oc >> shift_value;


    // 一次突发传输可以写多次channel_num并行度，cut_block_len_oc是突发传输的最后一段channel_num需要多少个总线传输个数，
    // is_int16_reg ? block_len_oc[OC_CNT-2:0] : block_len_oc[OC_CNT-1:0]是最后一段的长度，
    //一次总线传输可以传输$clog2(BUS_WIDTH/BIAS2_WIDTH)个（int16的情况），$clog2(BUS_WIDTH*2/BIAS2_WIDTH)个（int8的情况）
    wire [DIM_WIDTH-1:0] cut_block_len_oc = is_int16_reg ? block_len_oc[OC_CNT-2:$clog2(
        BUS_WIDTH/BIAS2_WIDTH
    )] : block_len_oc[OC_CNT-1:$clog2(
        BUS_WIDTH*2/BIAS2_WIDTH
    )];

    reg [CNT_WIDTH-1:0] cnt_dim_oc;
    reg [CNT_WIDTH-1:0] cnt_dim_ow;
    reg [CNT_WIDTH-1:0] cnt_dim_oh;

    wire is_cnt_dim_ow_end = (cnt_dim_ow == block_len_ow);
    wire is_cnt_dim_oh_end = (cnt_dim_oh == block_len_oh);
    wire is_cnt_dim_oc_end = (cnt_dim_oc == shift_block_len_oc);


    localparam MAX_L = CHANNEL_NUM * BIAS2_WIDTH / BUS_WIDTH;//需要从总线接收的数据个数，构成写入CHANNEL_NUM个通道的数据
    localparam L_SHIFT = $clog2(MAX_L);
    reg [L_SHIFT-1:0] curr_oc;
    assign curr_oc = is_cnt_dim_oc_end ? cut_block_len_oc[L_SHIFT-1:0] : (2 ** L_SHIFT - 1);


    reg [$clog2(MAX_L)-1:0] cnt_L;
    wire cnt_L_end = (cnt_L == curr_oc);
    wire cnt_L_start = (cnt_L == 0);
    wire en_true = en & din_valid_scale & (~load_finish);



    wire load_done_pulse;
    assign load_done_pulse = is_cnt_dim_oc_end && (( is_cnt_dim_ow_end && is_cnt_dim_oh_end && (bias2_mode_external == 1'b1) )||(bias2_mode_external == 1'b0)) 
                        && ((cnt_L_end && cut_block_len_oc !=0)||(din_valid_scale & cut_block_len_oc == 0) );

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            load_finish <= 0;
        end else begin
            if (load_done_pulse) begin
                load_finish <= 1;
            end else if (curr_state == S_IDLE) begin
                load_finish <= 0;
            end
        end
    end

    dq_dff #(
        .N (5),
        .DW(1)
    ) u_load_done_pulse_delay (
        .clk(clk),
        .rstn(rstn),
        .d(load_done_pulse),
        .q(load_done_pulse_delay)
    );
    assign is_load_bias2_done = load_done_pulse_delay;

    assign dma_bias2_rready   = (curr_state == S_LOAD) && (~load_finish);  // 准备接收数据包

    // 内部寄存器
    reg [BUS_WIDTH-1:0] shift_register[MAX_L-1:0];

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_L <= 0;
        end else if (en_true) begin
            if (cnt_L_end) begin
                cnt_L <= 0;
            end else begin
                cnt_L <= cnt_L + 1;
            end
        end else if (load_done_pulse) begin
            cnt_L <= 0;
        end
    end

    //移位寄存器的使能选择
    reg [MAX_L-1:0] en_sel;
    assign en_sel = ({MAX_L{1'b1}} << (MAX_L - 1 - curr_oc)) >> (MAX_L - 1 - curr_oc);

    wire [BUS_WIDTH-1:0] din_data_delay; //把后面的延迟移动到前面来，减少寄存器使用
    wire en_true_delay;
    dq_dff #(
        .N(1),  //bias2_waddr_gen的延迟是2，这里的延迟是bias2_waddr_gen的延迟-1
        .DW(BUS_WIDTH)
    ) u_din_data_delay (
        .clk(clk),
        .rstn(rstn),
        .d(din_data_scale),
        .q(din_data_delay)
    );

    dq_dff #(
        .N (1),
        .DW(1)
    ) u_en_true_delay (
        .clk(clk),
        .rstn(rstn),
        .d(en_true),
        .q(en_true_delay)
    );

    reg [$clog2(MAX_L)-1:0] cnt_L_delay;
    dq_dff #(
        .N (1),
        .DW($clog2(MAX_L))
    ) u_cnt_L_delay (
        .clk(clk),
        .rstn(rstn),
        .d(cnt_L),
        .q(cnt_L_delay)
    );


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            shift_register <= '{MAX_L{0}};
        end else if (en_true_delay) begin

            shift_register[cnt_L_delay] <= din_data_delay;
        end
    end
    // end


    reg  [CHANNEL_NUM-1:0] bias2_wen_w;
    wire [BIAS2_WIDTH-1:0] bias2_wdata_w[CHANNEL_NUM-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            localparam WIDTH_multiple = BUS_WIDTH / BIAS2_WIDTH;
            localparam INT_PART = i / WIDTH_multiple;
            localparam REMAIN_PART = i % WIDTH_multiple;
            assign bias2_wdata_w[i] = shift_register[INT_PART][BIAS2_WIDTH*(REMAIN_PART+1)-1:BIAS2_WIDTH*(REMAIN_PART)];
            assign bias2_wen_w[i] = en_sel[INT_PART];
        end
    endgenerate

    assign bias2_wdata = bias2_wdata_w;



    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_ow <= 0;
        end else if (en_true & cnt_L_end) begin
            if (is_cnt_dim_ow_end) begin
                cnt_dim_ow <= 0;
            end else begin
                cnt_dim_ow <= (cnt_dim_ow + 1);
            end
        end else if (load_done_pulse) begin
            cnt_dim_ow <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_oh <= 0;
        end else if (en_true & cnt_L_end) begin
            if (is_cnt_dim_ow_end) begin
                if (is_cnt_dim_oh_end) begin
                    cnt_dim_oh <= 0;
                end else begin
                    cnt_dim_oh <= (cnt_dim_oh + 1);
                end
            end
        end else if (load_done_pulse) begin
            cnt_dim_oh <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_oc <= 0;
        end else if (en_true & cnt_L_end) begin

            if (is_cnt_dim_ow_end & is_cnt_dim_oh_end) begin
                if (is_cnt_dim_oc_end) begin
                    cnt_dim_oc <= 0;
                end else begin
                    cnt_dim_oc <= cnt_dim_oc + 1;
                end
            end
        end else if (load_done_pulse) begin
            cnt_dim_oc <= 0;
        end
    end


    wire waddr_en = en_true & cnt_L_end;
    wire [CHANNEL_NUM-1:0] bias2_wen_w2;
    assign bias2_wen_w2 = bias2_wen_w & ({CHANNEL_NUM{waddr_en}});

    bias_waddr_gen #(
        .DIM_WIDTH          (DIM_WIDTH),
        .OMAP_RAM_ADDR_WIDTH(BIAS2_RAM_ADDR_WIDTH)
    ) u_bias2_waddr_gen (
        .clk               (clk),
        .rstn              (rstn),
        .en                (en),
        .bias_mode_external(bias2_mode_external),
        .cnt_dim_ow        (cnt_dim_ow),
        .cnt_dim_oc        (cnt_dim_oc),
        .cnt_dim_oh        (cnt_dim_oh),
        .block_len_ow_add1 (block_len_ow_add1),
        .block_len_owh_add1(block_len_owh_add1),

        .bias_waddr(bias2_waddr)
    );
    dq_dff #(
        .N(2),  //bias2_waddr_gen的延迟是2
        .DW(CHANNEL_NUM)
    ) u_bias2_wen_w2_delay (
        .clk(clk),
        .rstn(rstn),
        .d(bias2_wen_w2),
        .q(bias2_wen)
    );


    localparam ADDR_GEN_DELAY = 4;  //地址产生逻辑的延时



    wire bias2_offset_addr_fifo_wr_en;
    wire bias2_offset_addr_fifo_rd_en;
    wire [BUS_ADDR_WIDTH+8-1:0] bias2_offset_addr_fifo_wr_data;
    wire [BUS_ADDR_WIDTH+8-1:0] bias2_offset_addr_fifo_rd_data;
    wire bias2_offset_addr_fifo_rd_valid;
    wire bias2_offset_addr_fifo_almost_full;
    wire bias2_offset_addr_fifo_empty;

    localparam OFFST_ADDR_FIFO_DEPTH = ADDR_GEN_DELAY + 5;
    localparam FIFO_COUNT_WIDTH = $clog2(OFFST_ADDR_FIFO_DEPTH) + 1;
    wire [FIFO_COUNT_WIDTH-1:0] bias2_offset_addr_fifo_counter;
    assign bias2_offset_addr_fifo_almost_full = bias2_offset_addr_fifo_counter > (OFFST_ADDR_FIFO_DEPTH-ADDR_GEN_DELAY-2);



    wire [1:0] bias2_offset_addr_shift = is_int16_reg ? 1 : 0; // int16情况下，bias2为16位，占4个8bit，地址需要左移1位，int8情况下，bias2为8位，占1个8bit，地址需要左移0位



    (* mark_debug = "false"*) reg [BURST_NUM_WIDTH-1:0] cnt_dburst;
    (* mark_debug = "false"*) reg [CNT_WIDTH-1:0] cnt_doh;
    (* mark_debug = "false"*) reg [CNT_WIDTH-1:0] cnt_doc;



    wire is_cnt_doc_end = (cnt_doc == shift_block_len_oc);
    wire is_cnt_dburst_end = (cnt_dburst == (is_cnt_doc_end ? burst_num_end_c : burst_num_not_end_c));
    wire is_cnt_doh_end = (cnt_doh == ((bias2_mode_external == 1'b0) ? 0 : block_len_oh));

    (* mark_debug = "false"*)wire [C_WIDTH-1:0] currc = is_cnt_doc_end ? currc_end_c : currc_not_end_c;


    reg [8-1:0] burst_len;
    assign burst_len = is_cnt_dburst_end? (is_cnt_doc_end ? remain_burst_len_end_c : remain_burst_len_not_end_c) : 255;

    reg [8-1:0] burst_len_delay;
    dq_dff #(
        .N (ADDR_GEN_DELAY),
        .DW(8)
    ) u_burst_len_delay (
        .clk(clk),
        .rstn(rstn),
        .d(burst_len),
        .q(burst_len_delay)
    );


    wire [BUS_ADDR_WIDTH-1:0] bias2_offset_addr_write_fifo;

    bias_offset_addr_gen #(
        .NUM_WIDTH      (NUM_WIDTH),
        .DIM_WIDTH      (DIM_WIDTH),
        .BUS_ADDR_WIDTH (BUS_ADDR_WIDTH),
        .AOWOH_WIDTH    (AOWOH_WIDTH),
        .AOW_WIDTH      (AOW_WIDTH),
        .BUS_WIDTH      (BUS_WIDTH),
        .CHANNEL_NUM    (CHANNEL_NUM),
        .S_WIDTH        (S_WIDTH),
        .C_WIDTH        (C_WIDTH),
        .BURST_NUM_WIDTH(BURST_NUM_WIDTH)
    ) u_bias2_offset_addr_gen (
        .clk                   (clk),
        .rstn                  (rstn),
        .bias_mode_external    (bias2_mode_external),
        .shift_value           (shift_value),
        .Aowoh                 (Aowoh),
        .Aow                   (Aow),
        .basic_oh_add1         (basic_oh_add1),
        .basic_ow_add1         (basic_ow_add1),
        .basic_oc_add1         (basic_oc_add1),
        .cnt_load_bias_h       (cnt_load_bias2_h),
        .cnt_load_bias_w       (cnt_load_bias2_w),
        .cnt_load_bias_oc      (cnt_load_bias2_oc),
        .currc                 (currc),
        .cnt_dburst            (cnt_dburst),
        .cnt_doh               (cnt_doh),
        .cnt_doc               (cnt_doc),
        .bias_offset_addr_shift(bias2_offset_addr_shift),
        .bias_offset_addr      (bias2_offset_addr_write_fifo)
    );



    assign bias2_offset_addr_fifo_wr_data = {
        burst_len_delay[8-1:0], bias2_offset_addr_write_fifo[BUS_ADDR_WIDTH-1:0]
    };

    assign bias2_offset_addr_fifo_rd_en = (~bias2_offset_addr_fifo_empty) && (~bias2_offset_addr_fifo_rd_valid) && (~init_bias2_rtx_pulse);

    reg ar_valid;
    reg [BUS_ADDR_WIDTH-1:0] ar_addr;
    reg [8-1:0] ar_len;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ar_valid <= 1'b0;
            ar_addr  <= {BUS_ADDR_WIDTH{1'b0}};
            ar_len   <= 0;
        end else if (bias2_offset_addr_fifo_rd_valid && ~ar_valid) begin
            ar_valid <= 1'b1;
            ar_addr  <= bias2_offset_addr_fifo_rd_data[BUS_ADDR_WIDTH-1:0];
            ar_len   <= bias2_offset_addr_fifo_rd_data[BUS_ADDR_WIDTH+8-1:BUS_ADDR_WIDTH];
        end else if (dma_bias2_arready && ar_valid) begin
            ar_valid <= 1'b0;
        end
    end

    assign init_bias2_rtx_pulse = ar_valid;
    assign bias2_offset_addr = ar_addr;
    assign bias2_load_burst_len = ar_len;

    sync_fifo_cnt #(
        .WIDTH(BUS_ADDR_WIDTH + 8),
        .DEPTH(OFFST_ADDR_FIFO_DEPTH),
        .RAM_STYLE_VAL("block")
    ) fifo_bias2_offset_addr (
        .clk         (clk),
        .rstn        (rstn),
        .wr_en       (bias2_offset_addr_fifo_wr_en),
        .rd_en       (bias2_offset_addr_fifo_rd_en),
        .wr_data     (bias2_offset_addr_fifo_wr_data),
        .rd_data     (bias2_offset_addr_fifo_rd_data),
        .rd_valid    (bias2_offset_addr_fifo_rd_valid),
        .full        (),
        .empty       (bias2_offset_addr_fifo_empty),
        .almost_full (),
        .almost_empty(),
        .fifo_counter(bias2_offset_addr_fifo_counter)
    );
    reg bias2_offset_addr_gen_done_flag;
    // wire bias2_offset_addr_gen_enable = ((bias2_mode_external == 1'b1) && (~bias2_offset_addr_fifo_almost_full & ~bias2_offset_addr_gen_done_flag & (curr_state == S_LOAD)))
    //                                     ||((bias2_mode_external == 1'b0) && ~bias2_offset_addr_fifo_almost_full && load_bias2_start);// bias2_mode_external为0时只需要发起一次传输即可
    wire bias2_offset_addr_gen_enable = ( (~bias2_offset_addr_fifo_almost_full & ~bias2_offset_addr_gen_done_flag & (curr_state == S_LOAD)));

    wire bias2_offset_addr_gen_done_pulse = (((bias2_mode_external == 1'b1) & is_cnt_dburst_end & is_cnt_doh_end & is_cnt_doc_end)
                                            || ((bias2_mode_external == 1'b0) & is_cnt_dburst_end & is_cnt_doc_end))
                                             & bias2_offset_addr_gen_enable;


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            bias2_offset_addr_gen_done_flag <= 0;
        end else if (bias2_offset_addr_gen_done_pulse) begin
            bias2_offset_addr_gen_done_flag <= 1;
        end else if (curr_state == S_IDLE) begin
            bias2_offset_addr_gen_done_flag <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dburst <= 0;
        end else if (bias2_offset_addr_gen_done_pulse) begin
            cnt_dburst <= 0;
        end else if (bias2_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end) begin
                cnt_dburst <= 0;
            end else begin
                cnt_dburst <= (cnt_dburst + 1);
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_doh <= 0;
        end else if (bias2_offset_addr_gen_done_pulse) begin
            cnt_doh <= 0;
        end else if (bias2_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end) begin
                if (is_cnt_doh_end) begin
                    cnt_doh <= 0;
                end else begin
                    cnt_doh <= (cnt_doh + 1);
                end
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_doc <= 0;
        end else if (bias2_offset_addr_gen_done_pulse) begin
            cnt_doc <= 0;
        end else if (bias2_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end & is_cnt_doh_end) begin
                if (is_cnt_doc_end) begin
                    cnt_doc <= 0;
                end else begin
                    cnt_doc <= (cnt_doc + 1);
                end
            end
        end
    end


    dq_dff #(
        .N (ADDR_GEN_DELAY),
        .DW(1)
    ) u_bias2_offset_addr_gen_enable (
        .clk(clk),
        .rstn(rstn),
        .d(bias2_offset_addr_gen_enable),
        .q(bias2_offset_addr_fifo_wr_en)  //产生写地址fifo使能
    );


endmodule
