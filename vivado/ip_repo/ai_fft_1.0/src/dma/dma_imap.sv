

module dma_imap #(
    parameter CHANNEL_NUM = 8,
    parameter NUM_WIDTH = 10,
    parameter DIM_WIDTH = 10,
    parameter IMAP_DIM_WIDTH = DIM_WIDTH + 2,
    parameter PADDING_WIDTH = 5,
    parameter BUS_WIDTH = 32,
    parameter BUS_ADDR_WIDTH = 32,
    parameter IMAP_WIDTH = 16,
    parameter IMAP_RAM_ADDR_WIDTH = 10,
    parameter AIWIH_WIDTH = 20,
    parameter AIW_WIDTH = 10,
    parameter C_WIDTH = $clog2(CHANNEL_NUM * 2),
    // bias需要加1
    parameter BURST_NUM_WIDTH = $clog2(CHANNEL_NUM * 2) + IMAP_DIM_WIDTH - 8 - $clog2(BUS_WIDTH / 8)

) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire [3:0] padding_flag,
    input wire [PADDING_WIDTH-1:0] padding_external[3:0],

    input wire [PADDING_WIDTH-1:0] padding_internal[3:0],
    input wire [AIWIH_WIDTH-1:0] Aiwih,  //imap的整体oc和整体ic的乘积
    input wire [AIW_WIDTH-1:0] Aiw,  //imap的整体oc

    input wire [DIM_WIDTH+1-1:0] basic_ic_add1,  // int8的情况下，需要是4的倍数，int16的情况下，需要是2的倍数 (32总线位宽的情况)
    input wire [IMAP_DIM_WIDTH+1-1:0] basic_ow_sx_add1,  // int8的情况下，需要是4的倍数，int16的情况下，需要是2的倍数 (32总线位宽的情况)
    input wire [IMAP_DIM_WIDTH+1-1:0] basic_oh_sy_add1,

    input wire load_imap_start,

    input wire [C_WIDTH-1:0] currc_end_c,  //input
    input wire [C_WIDTH-1:0] currc_not_end_c,  //input
    input wire [BURST_NUM_WIDTH-1:0] burst_num_end_c,  //input
    input wire [BURST_NUM_WIDTH-1:0] burst_num_not_end_c,  //input

    input wire [7:0] remain_burst_len_end_c,  //input
    input wire [7:0] remain_burst_len_not_end_c,  //input

    input wire [IMAP_DIM_WIDTH-1:0] block_len_iw_np,
    input wire [IMAP_DIM_WIDTH-1:0] block_len_ih_np,
    input wire [DIM_WIDTH-1:0] block_len_ic,
    input wire [IMAP_DIM_WIDTH+1-1:0] block_len_iw_add1,
    input wire [(IMAP_DIM_WIDTH+1)*2-1:0] block_len_iwh_add1,



    input wire [NUM_WIDTH-1:0] cnt_load_imap_h,
    input wire [NUM_WIDTH-1:0] cnt_load_imap_w,
    input wire [NUM_WIDTH-1:0] cnt_load_imap_ic,

    input wire dma_imap_arready,  //准备接收地址
    output wire init_imap_rtx_pulse,  //开始传输地址
    output reg [BUS_ADDR_WIDTH-1:0] imap_offset_addr,
    output wire [8-1:0] imap_load_burst_len,
    output reg dma_imap_rready,

    input wire din_valid,
    input wire [BUS_WIDTH-1:0] din_data,  //din_valid为高时，din有效

    output reg [IMAP_RAM_ADDR_WIDTH-1:0] imap_waddr,
    output wire [IMAP_WIDTH-1:0] imap_wdata[CHANNEL_NUM-1:0],
    output reg [CHANNEL_NUM-1:0] imap_wen,
    output reg is_load_imap_done,
    output reg is_load_imap_busy
);

    // for debug
    // 静态断言检查 BUS_WIDTH 是否小于 IMAP_WIDTH * CHANNEL_NUM
    assert #0 (BUS_WIDTH < IMAP_WIDTH * CHANNEL_NUM);

    // 静态断言检查 BUS_WIDTH 是否为2的幂
    assert #0 ((BUS_WIDTH & (BUS_WIDTH - 1)) == 0);


    wire [16-1:0] din_data_int16[BUS_WIDTH/16-1:0];
    wire [8-1:0] din_data_int8[BUS_WIDTH/8-1:0];
    reg [IMAP_WIDTH-1:0] imap_wdata_int16[CHANNEL_NUM-1:0];
    reg [IMAP_WIDTH/2-1:0] imap_wdata_int8[CHANNEL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < BUS_WIDTH / 16; i = i + 1) begin
            assign din_data_int16[i] = din_data[(i+1)*16-1:i*16];
        end
        for (genvar i = 0; i < BUS_WIDTH / 8; i = i + 1) begin
            assign din_data_int8[i] = din_data[(i+1)*8-1:i*8];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign imap_wdata_int16[i] = imap_wdata[i];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {imap_wdata_int8[i*2+1], imap_wdata_int8[i*2]} = imap_wdata[i];
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
                    if (load_imap_start) begin
                        next_state = S_LOAD;
                    end else begin
                        next_state = S_IDLE;
                    end
                end
                S_LOAD: begin
                    if (is_load_imap_done) begin
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
    assign is_load_imap_busy = (curr_state == S_LOAD);
    assign en = is_load_imap_busy;


    localparam CNT_WIDTH = IMAP_DIM_WIDTH;
    localparam IC_CNT = $clog2(CHANNEL_NUM * 2);
    localparam S_WIDTH = $clog2(IC_CNT) + 1;
    wire [S_WIDTH-1:0] shift_value;
    assign shift_value = is_int16_reg ? (IC_CNT - 1) : (IC_CNT);


    wire [DIM_WIDTH-1:0] shift_block_len_ic = block_len_ic >> shift_value;

    // 一次突发传输可以写多次channel_num并行度，cut_block_len_ic是突发传输的最后一段channel_num需要多少个总线传输个数，
    // is_int16_reg ? block_len_ic[IC_CNT-2:0] : block_len_ic[IC_CNT-1:0]是最后一段的长度，
    //一次总线传输可以传输$clog2(BUS_WIDTH/IMAP_WIDTH)个（int16的情况），$clog2(BUS_WIDTH*2/IMAP_WIDTH)个（int8的情况）
    wire [DIM_WIDTH-1:0] cut_block_len_ic = is_int16_reg ? block_len_ic[IC_CNT-2:$clog2(
        BUS_WIDTH/IMAP_WIDTH
    )] : block_len_ic[IC_CNT-1:$clog2(
        BUS_WIDTH*2/IMAP_WIDTH
    )];

    reg [DIM_WIDTH-1:0] cnt_dim_ic;
    reg [CNT_WIDTH-1:0] cnt_dim_iw;
    reg [CNT_WIDTH-1:0] cnt_dim_ih;

    wire is_cnt_dim_iw_end = (cnt_dim_iw == block_len_iw_np);
    wire is_cnt_dim_ih_end = (cnt_dim_ih == block_len_ih_np);
    wire is_cnt_dim_ic_end = (cnt_dim_ic == shift_block_len_ic);


    localparam MAX_L = CHANNEL_NUM * IMAP_WIDTH / BUS_WIDTH;
    localparam L_SHIFT = $clog2(MAX_L);
    reg [L_SHIFT-1:0] curr_ic;
    assign curr_ic = is_cnt_dim_ic_end ? cut_block_len_ic[L_SHIFT-1:0] : (2 ** L_SHIFT - 1);


    reg [$clog2(MAX_L)-1:0] cnt_L;
    wire cnt_L_end = (cnt_L == curr_ic);
    wire cnt_L_start = (cnt_L == 0);
    wire en_true = en & din_valid & (~load_finish);





    wire load_done_pulse;
    assign load_done_pulse = is_cnt_dim_ic_end & is_cnt_dim_iw_end & is_cnt_dim_ih_end & ((cnt_L_end & cut_block_len_ic !=0)||(din_valid & cut_block_len_ic ==0));
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
    assign is_load_imap_done = load_done_pulse_delay;

    assign dma_imap_rready   = (curr_state == S_LOAD) && (~load_finish);  // 准备接收数据包

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

    //写使能的使能选择
    reg [MAX_L-1:0] en_sel;
    assign en_sel = ({MAX_L{1'b1}} << (MAX_L - 1 - curr_ic)) >> (MAX_L - 1 - curr_ic);

    wire [BUS_WIDTH-1:0] din_data_delay; //把后面的延迟移动到前面来，减少寄存器使用
    wire en_true_delay;
    dq_dff #(
        .N(1),  //imap_waddr_gen的延迟是2，这里的延迟是imap_waddr_gen的延迟-1
        .DW(BUS_WIDTH)
    ) u_din_data_delay (
        .clk(clk),
        .rstn(rstn),
        .d(din_data),
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


    // 输出逻辑

    reg [CHANNEL_NUM-1:0] imap_wen_w;
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            localparam WIDTH_multiple = BUS_WIDTH / IMAP_WIDTH;
            localparam INT_PART = i / WIDTH_multiple;
            localparam REMAIN_PART = i % WIDTH_multiple;
            assign imap_wdata[i] = shift_register[INT_PART][IMAP_WIDTH*(REMAIN_PART+1)-1:IMAP_WIDTH*(REMAIN_PART)];
            assign imap_wen_w[i] = en_sel[INT_PART];
        end
    endgenerate




    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_iw <= 0;
        end else if (en_true & cnt_L_end) begin
            if (is_cnt_dim_iw_end) begin
                cnt_dim_iw <= 0;
            end else begin
                cnt_dim_iw <= (cnt_dim_iw + 1);
            end
        end else if (load_done_pulse) begin
            cnt_dim_iw <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_ih <= 0;
        end else if (en_true & cnt_L_end) begin
            if (is_cnt_dim_iw_end) begin
                if (is_cnt_dim_ih_end) begin
                    cnt_dim_ih <= 0;
                end else begin
                    cnt_dim_ih <= (cnt_dim_ih + 1);
                end
            end
        end else if (load_done_pulse) begin
            cnt_dim_ih <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_ic <= 0;
        end else if (en_true & cnt_L_end) begin
            if (is_cnt_dim_iw_end & is_cnt_dim_ih_end) begin
                if (is_cnt_dim_ic_end) begin
                    cnt_dim_ic <= 0;
                end else begin
                    cnt_dim_ic <= cnt_dim_ic + 1;
                end
            end
        end else if (load_done_pulse) begin
            cnt_dim_ic <= 0;
        end
    end


    wire waddr_en = en_true & cnt_L_end;
    wire [CHANNEL_NUM-1:0] imap_wen_w2;
    assign imap_wen_w2 = imap_wen_w & ({CHANNEL_NUM{waddr_en}});

    imap_waddr_gen #(
        .DIM_WIDTH          (DIM_WIDTH),
        .IMAP_RAM_ADDR_WIDTH(IMAP_RAM_ADDR_WIDTH),
        .IMAP_DIM_WIDTH     (IMAP_DIM_WIDTH),
        .PADDING_WIDTH      (PADDING_WIDTH)
    ) u_imap_waddr_gen (
        .clk               (clk),
        .rstn              (rstn),
        .en                (waddr_en),
        .padding           (padding_internal),
        .cnt_dim_ih        (cnt_dim_ih),
        .cnt_dim_ic        (cnt_dim_ic),
        .cnt_dim_iw        (cnt_dim_iw),
        .block_len_iw_add1 (block_len_iw_add1),
        .block_len_iwh_add1(block_len_iwh_add1),

        .imap_waddr(imap_waddr)
    );

    dq_dff #(
        .N(2),  //imap_waddr_gen的延迟是2
        .DW(CHANNEL_NUM)
    ) u_imap_wen_w2_delay (
        .clk(clk),
        .rstn(rstn),
        .d(imap_wen_w2),
        .q(imap_wen)
    );







    localparam ADDR_GEN_DELAY = 4;  //地址产生逻辑的延时


    wire imap_offset_addr_fifo_wr_en;
    wire imap_offset_addr_fifo_rd_en;
    wire [BUS_ADDR_WIDTH+8-1:0] imap_offset_addr_fifo_wr_data;
    wire [BUS_ADDR_WIDTH+8-1:0] imap_offset_addr_fifo_rd_data;
    wire imap_offset_addr_fifo_rd_valid;
    wire imap_offset_addr_fifo_almost_full;
    wire imap_offset_addr_fifo_empty;

    localparam OFFST_ADDR_FIFO_DEPTH = ADDR_GEN_DELAY + 5;
    localparam FIFO_COUNT_WIDTH = $clog2(OFFST_ADDR_FIFO_DEPTH) + 1;
    wire [FIFO_COUNT_WIDTH-1:0] imap_offset_addr_fifo_counter;
    assign imap_offset_addr_fifo_almost_full = imap_offset_addr_fifo_counter > (OFFST_ADDR_FIFO_DEPTH-ADDR_GEN_DELAY-2);



    wire [1:0] imap_offset_addr_shift = is_int16_reg ? 1 : 0; // int16情况下，imap为16bit，占2个8bit，地址需要左移1位，int8情况下，imap为8bit，占1个8bit，地址需要左移0位






    reg [BURST_NUM_WIDTH-1:0] cnt_dburst;
    reg [CNT_WIDTH-1:0] cnt_dih;
    reg [DIM_WIDTH-1:0] cnt_dic;



    wire is_cnt_dic_end = (cnt_dic == shift_block_len_ic);
    wire is_cnt_dburst_end = (cnt_dburst == (is_cnt_dic_end ? burst_num_end_c : burst_num_not_end_c));
    wire is_cnt_dih_end = (cnt_dih == block_len_ih_np);

    wire [C_WIDTH-1:0] currc = is_cnt_dic_end ? currc_end_c : currc_not_end_c;


    reg [8-1:0] burst_len;
    assign burst_len = is_cnt_dburst_end? (is_cnt_dic_end ? remain_burst_len_end_c : remain_burst_len_not_end_c) : 255;


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

    wire [BUS_ADDR_WIDTH-1:0] imap_offset_addr_write_fifo;

    imap_offset_addr_gen #(
        .NUM_WIDTH      (NUM_WIDTH),
        .DIM_WIDTH      (DIM_WIDTH),
        .IMAP_DIM_WIDTH (IMAP_DIM_WIDTH),
        .BUS_ADDR_WIDTH (BUS_ADDR_WIDTH),
        .AIWIH_WIDTH    (AIWIH_WIDTH),
        .AIW_WIDTH      (AIW_WIDTH),
        .BUS_WIDTH      (BUS_WIDTH),
        .CHANNEL_NUM    (CHANNEL_NUM),
        .S_WIDTH        (S_WIDTH),
        .C_WIDTH        (C_WIDTH),
        .BURST_NUM_WIDTH(BURST_NUM_WIDTH),
        .PADDING_WIDTH  (PADDING_WIDTH)
    ) u_imap_offset_addr_gen (
        .clk                   (clk),
        .rstn                  (rstn),
        .shift_value           (shift_value),
        .padding_flag          (padding_flag),
        .padding_external      (padding_external),
        .Aiwih                 (Aiwih),
        .Aiw                   (Aiw),
        .basic_oh_sy_add1      (basic_oh_sy_add1),
        .basic_ow_sx_add1      (basic_ow_sx_add1),
        .basic_ic_add1         (basic_ic_add1),
        .cnt_load_imap_h       (cnt_load_imap_h),
        .cnt_load_imap_w       (cnt_load_imap_w),
        .cnt_load_imap_ic      (cnt_load_imap_ic),
        .currc                 (currc),
        .cnt_dburst            (cnt_dburst),
        .cnt_dih               (cnt_dih),
        .cnt_dic               (cnt_dic),
        .imap_offset_addr_shift(imap_offset_addr_shift),

        .imap_offset_addr(imap_offset_addr_write_fifo)
    );

    assign imap_offset_addr_fifo_wr_data = {
        burst_len_delay[8-1:0], imap_offset_addr_write_fifo[BUS_ADDR_WIDTH-1:0]
    };

    assign imap_offset_addr_fifo_rd_en = (~imap_offset_addr_fifo_empty) &&(~imap_offset_addr_fifo_rd_valid)&& (~init_imap_rtx_pulse);

    reg ar_valid;
    reg [BUS_ADDR_WIDTH-1:0] ar_addr;
    reg [8-1:0] ar_len;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ar_valid <= 1'b0;
            ar_addr  <= {BUS_ADDR_WIDTH{1'b0}};
            ar_len   <= 0;
        end else if (imap_offset_addr_fifo_rd_valid && ~ar_valid) begin
            ar_valid <= 1'b1;
            ar_addr  <= imap_offset_addr_fifo_rd_data[BUS_ADDR_WIDTH-1:0];
            ar_len   <= imap_offset_addr_fifo_rd_data[BUS_ADDR_WIDTH+8-1:BUS_ADDR_WIDTH];
        end else if (dma_imap_arready && ar_valid) begin
            ar_valid <= 1'b0;
        end
    end

    assign init_imap_rtx_pulse = ar_valid;
    assign imap_offset_addr = ar_addr;
    assign imap_load_burst_len = ar_len;

    sync_fifo_cnt #(
        .WIDTH(BUS_ADDR_WIDTH + 8),
        .DEPTH(OFFST_ADDR_FIFO_DEPTH),
        .RAM_STYLE_VAL("block")
    ) fifo_imap_offset_addr (
        .clk         (clk),
        .rstn        (rstn),
        .wr_en       (imap_offset_addr_fifo_wr_en),
        .rd_en       (imap_offset_addr_fifo_rd_en),
        .wr_data     (imap_offset_addr_fifo_wr_data),
        .rd_data     (imap_offset_addr_fifo_rd_data),
        .rd_valid    (imap_offset_addr_fifo_rd_valid),
        .full        (),
        .empty       (imap_offset_addr_fifo_empty),
        .almost_full (),
        .almost_empty(),
        .fifo_counter(imap_offset_addr_fifo_counter)
    );
    reg imap_offset_addr_gen_done_flag;
    wire imap_offset_addr_gen_enable = ~imap_offset_addr_fifo_almost_full & ~imap_offset_addr_gen_done_flag & (curr_state == S_LOAD);

    wire imap_offset_addr_gen_done_pulse = is_cnt_dburst_end & is_cnt_dih_end & is_cnt_dic_end & imap_offset_addr_gen_enable;


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            imap_offset_addr_gen_done_flag <= 0;
        end else if (imap_offset_addr_gen_done_pulse) begin
            imap_offset_addr_gen_done_flag <= 1;
        end else if (curr_state == S_IDLE) begin
            imap_offset_addr_gen_done_flag <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dburst <= 0;
        end else if (imap_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end) begin
                cnt_dburst <= 0;
            end else begin
                cnt_dburst <= (cnt_dburst + 1);
            end
        end else if (imap_offset_addr_gen_done_pulse) begin
            cnt_dburst <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dih <= 0;
        end else if (imap_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end) begin
                if (is_cnt_dih_end) begin
                    cnt_dih <= 0;
                end else begin
                    cnt_dih <= (cnt_dih + 1);
                end
            end
        end else if (imap_offset_addr_gen_done_pulse) begin
            cnt_dih <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dic <= 0;
        end else if (imap_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end & is_cnt_dih_end) begin
                if (is_cnt_dic_end) begin
                    cnt_dic <= 0;
                end else begin
                    cnt_dic <= (cnt_dic + 1);
                end
            end
        end else if (imap_offset_addr_gen_done_pulse) begin
            cnt_dic <= 0;
        end
    end

    dq_dff #(
        .N (ADDR_GEN_DELAY),
        .DW(1)
    ) u_imap_offset_addr_gen_enable (
        .clk(clk),
        .rstn(rstn),
        .d(imap_offset_addr_gen_enable),
        .q(imap_offset_addr_fifo_wr_en)  //产生写地址fifo使能
    );





endmodule




