



module dma_weight #(
    parameter CHANNEL_NUM = 8,
    parameter NUM_WIDTH = 10,
    parameter DIM_WIDTH = 10,
    parameter BUS_WIDTH = 32,
    parameter BUS_ADDR_WIDTH = 32,
    parameter WEIGHT_WIDTH = 16,
    parameter WEIGHT_RAM_ADDR_WIDTH = 10,
    parameter WICRS_WIDTH = 20,
    parameter WIC_WIDTH = 10,
    parameter C_WIDTH = $clog2(CHANNEL_NUM * 2),
    // bias需要加1
    parameter BURST_NUM_WIDTH = $clog2(CHANNEL_NUM * 2) + DIM_WIDTH - 8 - $clog2(BUS_WIDTH / 8)

) (
    input wire clk,
    input wire rstn,
    input wire is_int16,

    input wire [WICRS_WIDTH-1:0] Wicrs,  //weight的整体oc和整体ic的乘积
    input wire [  WIC_WIDTH-1:0] Wic,    //weight的整体oc

    input wire [DIM_WIDTH+1-1:0] basic_oc_add1,  // int8的情况下，需要是4的倍数，int16的情况下，需要是2的倍数 (32总线位宽的情况)
    input wire [DIM_WIDTH+1-1:0] basic_ic_add1,  // int8的情况下，需要是4的倍数，int16的情况下，需要是2的倍数 (32总线位宽的情况)
    input wire [DIM_WIDTH+1-1:0] basic_rs_add1,

    input wire load_weight_start,

    input wire [C_WIDTH-1:0] currc_end_c,  //input
    input wire [C_WIDTH-1:0] currc_not_end_c,  //input
    input wire [BURST_NUM_WIDTH-1:0] burst_num_end_c,  //input
    input wire [BURST_NUM_WIDTH-1:0] burst_num_not_end_c,  //input

    input wire [7:0] remain_burst_len_end_c,  //input
    input wire [7:0] remain_burst_len_not_end_c,  //input

    input wire [DIM_WIDTH-1:0] block_len_ic,
    input wire [DIM_WIDTH-1:0] block_len_rs,
    input wire [DIM_WIDTH-1:0] block_len_oc,
    input wire [DIM_WIDTH+1-1:0] block_len_ic_add1,
    input wire [(DIM_WIDTH+1)*2-1:0] block_len_icrs_add1,


    input wire [NUM_WIDTH-1:0] cnt_load_wei_rs,
    input wire [NUM_WIDTH-1:0] cnt_load_wei_ic,
    input wire [NUM_WIDTH-1:0] cnt_load_wei_oc,

    input wire dma_weight_arready,  //准备接收地址
    output wire init_weight_rtx_pulse,  //开始传输地址
    output reg [BUS_ADDR_WIDTH-1:0] weight_offset_addr,
    output wire [8-1:0] weight_load_burst_len,
    output reg dma_weight_rready,

    input wire din_valid,
    input wire [BUS_WIDTH-1:0] din_data,  //din_valid为高时，din有效

    output reg [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_waddr,
    output wire [WEIGHT_WIDTH-1:0] weight_wdata[CHANNEL_NUM-1:0],
    output reg [CHANNEL_NUM-1:0] weight_wen,
    output reg is_load_weight_done,
    output reg is_load_weight_busy
);

    // for debug
    wire [16-1:0] din_data_int16[BUS_WIDTH/16-1:0];
    wire [8-1:0] din_data_int8[BUS_WIDTH/8-1:0];
    reg [WEIGHT_WIDTH-1:0] weight_wdata_int16[CHANNEL_NUM-1:0];
    reg [WEIGHT_WIDTH/2-1:0] weight_wdata_int8[CHANNEL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < BUS_WIDTH / 16; i = i + 1) begin
            assign din_data_int16[i] = din_data[(i+1)*16-1:i*16];
        end
        for (genvar i = 0; i < BUS_WIDTH / 8; i = i + 1) begin
            assign din_data_int8[i] = din_data[(i+1)*8-1:i*8];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign weight_wdata_int16[i] = weight_wdata[i];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {weight_wdata_int8[i*2+1], weight_wdata_int8[i*2]} = weight_wdata[i];
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
    // reg load_done;
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
                    if (load_weight_start) begin
                        next_state = S_LOAD;
                    end else begin
                        next_state = S_IDLE;
                    end
                end
                S_LOAD: begin
                    if (is_load_weight_done) begin
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
    assign is_load_weight_busy = (curr_state == S_LOAD);
    assign en = is_load_weight_busy;

    localparam CNT_WIDTH = DIM_WIDTH;
    localparam OC_CNT = $clog2(CHANNEL_NUM * 2);
    localparam S_WIDTH = $clog2(OC_CNT) + 1;
    wire [S_WIDTH-1:0] shift_value;
    assign shift_value = is_int16_reg ? (OC_CNT - 1) : (OC_CNT);


    wire [DIM_WIDTH-1:0] shift_block_len_oc = block_len_oc >> shift_value;

    // 一次突发传输可以写多次channel_num并行度，cut_block_len_oc是突发传输的最后一段channel_num需要多少个总线传输个数，
    // is_int16_reg ? block_len_oc[OC_CNT-2:0] : block_len_oc[OC_CNT-1:0]是最后一段的长度，
    //一次总线传输可以传输$clog2(BUS_WIDTH/WEIGHT_WIDTH)个（int16的情况），$clog2(BUS_WIDTH*2/WEIGHT_WIDTH)个（int8的情况）
    wire [DIM_WIDTH-1:0] cut_block_len_oc = is_int16_reg ? block_len_oc[OC_CNT-2:$clog2(
        BUS_WIDTH/WEIGHT_WIDTH
    )] : block_len_oc[OC_CNT-1:$clog2(
        BUS_WIDTH*2/WEIGHT_WIDTH
    )];

    reg [CNT_WIDTH-1:0] cnt_dim_oc;
    reg [CNT_WIDTH-1:0] cnt_dim_ic;
    reg [CNT_WIDTH-1:0] cnt_dim_rs;

    wire is_cnt_dim_ic_end = (cnt_dim_ic == block_len_ic);
    wire is_cnt_dim_rs_end = (cnt_dim_rs == block_len_rs);
    wire is_cnt_dim_oc_end = (cnt_dim_oc == shift_block_len_oc);


    localparam MAX_L = CHANNEL_NUM * WEIGHT_WIDTH / BUS_WIDTH;
    localparam L_SHIFT = $clog2(MAX_L);
    reg [L_SHIFT-1:0] curr_oc;
    assign curr_oc = is_cnt_dim_oc_end ? cut_block_len_oc[L_SHIFT-1:0] : (2 ** L_SHIFT - 1);


    reg [$clog2(MAX_L)-1:0] cnt_L;
    wire cnt_L_end = (cnt_L == curr_oc);
    wire cnt_L_start = (cnt_L == 0);
    wire en_true = en & din_valid & (~load_finish);





    wire load_done_pulse;
    assign load_done_pulse = is_cnt_dim_oc_end & is_cnt_dim_ic_end & is_cnt_dim_rs_end & ((cnt_L_end & cut_block_len_oc !=0)||(din_valid & cut_block_len_oc ==0));
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
    assign is_load_weight_done = load_done_pulse_delay;

    assign dma_weight_rready   = (curr_state == S_LOAD) && (~load_finish);  // 准备接收数据包

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
    assign en_sel = ({MAX_L{1'b1}} << (MAX_L - 1 - curr_oc)) >> (MAX_L - 1 - curr_oc);

    wire [BUS_WIDTH-1:0] din_data_delay; //把后面的延迟移动到前面来，减少寄存器使用
    wire en_true_delay;
    dq_dff #(
        .N(1),  //weight_waddr_gen的延迟是2，这里的延迟是weight_waddr_gen的延迟-1
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
    // assign weight_wdata = shift_register;
    reg [CHANNEL_NUM-1:0] weight_wen_w;
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            localparam WIDTH_multiple = BUS_WIDTH / WEIGHT_WIDTH;
            localparam INT_PART = i / WIDTH_multiple;
            localparam REMAIN_PART = i % WIDTH_multiple;
            assign weight_wdata[i] = shift_register[INT_PART][WEIGHT_WIDTH*(REMAIN_PART+1)-1:WEIGHT_WIDTH*(REMAIN_PART)];
            assign weight_wen_w[i] = en_sel[INT_PART];
        end
    endgenerate




    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_ic <= 0;
        end else if (en_true & cnt_L_end) begin
            if (is_cnt_dim_ic_end) begin
                cnt_dim_ic <= 0;
            end else begin
                cnt_dim_ic <= (cnt_dim_ic + 1);
            end
        end else if (load_done_pulse) begin
            cnt_dim_ic <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_rs <= 0;
        end else if (en_true & cnt_L_end) begin
            if (is_cnt_dim_ic_end) begin
                if (is_cnt_dim_rs_end) begin
                    cnt_dim_rs <= 0;
                end else begin
                    cnt_dim_rs <= (cnt_dim_rs + 1);
                end
            end
        end else if (load_done_pulse) begin
            cnt_dim_rs <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_oc <= 0;
        end else if (en_true & cnt_L_end) begin
            if (is_cnt_dim_ic_end & is_cnt_dim_rs_end) begin
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
    wire [CHANNEL_NUM-1:0] weight_wen_w2;
    assign weight_wen_w2 = weight_wen_w & ({CHANNEL_NUM{waddr_en}});

    weight_waddr_gen #(
        .DIM_WIDTH            (DIM_WIDTH),
        .WEIGHT_RAM_ADDR_WIDTH(WEIGHT_RAM_ADDR_WIDTH)
    ) u_weight_waddr_gen (
        .clk                (clk),
        .rstn               (rstn),
        .en                 (waddr_en),
        .cnt_dim_rs         (cnt_dim_rs),
        .cnt_dim_oc         (cnt_dim_oc),
        .cnt_dim_ic         (cnt_dim_ic),
        .block_len_ic_add1  (block_len_ic_add1),
        .block_len_icrs_add1(block_len_icrs_add1),

        .weight_waddr(weight_waddr)
    );

    dq_dff #(
        .N(2),  //weight_waddr_gen的延迟是2
        .DW(CHANNEL_NUM)
    ) u_weight_wen_w2_delay (
        .clk(clk),
        .rstn(rstn),
        .d(weight_wen_w2),
        .q(weight_wen)
    );







    localparam ADDR_GEN_DELAY = 4;  //地址产生逻辑的延时


    wire weight_offset_addr_fifo_wr_en;
    wire weight_offset_addr_fifo_rd_en;
    wire [BUS_ADDR_WIDTH+8-1:0] weight_offset_addr_fifo_wr_data;
    wire [BUS_ADDR_WIDTH+8-1:0] weight_offset_addr_fifo_rd_data;
    wire weight_offset_addr_fifo_rd_valid;
    wire weight_offset_addr_fifo_almost_full;
    wire weight_offset_addr_fifo_empty;

    localparam OFFST_ADDR_FIFO_DEPTH = ADDR_GEN_DELAY + 5;
    localparam FIFO_COUNT_WIDTH = $clog2(OFFST_ADDR_FIFO_DEPTH) + 1;
    wire [FIFO_COUNT_WIDTH-1:0] weight_offset_addr_fifo_counter;
    assign weight_offset_addr_fifo_almost_full = weight_offset_addr_fifo_counter > (OFFST_ADDR_FIFO_DEPTH-ADDR_GEN_DELAY-2);

    wire [1:0] weight_offset_addr_shift = is_int16_reg ? 1 : 0; // int16情况下，weight为16bit，占2个8bit，地址需要左移1位，int8情况下，weight为8bit，占1个8bit，地址需要左移0位



    reg [BURST_NUM_WIDTH-1:0] cnt_dburst;
    reg [CNT_WIDTH-1:0] cnt_drs;
    reg [CNT_WIDTH-1:0] cnt_doc;



    wire is_cnt_doc_end = (cnt_doc == shift_block_len_oc);
    wire is_cnt_dburst_end = (cnt_dburst == (is_cnt_doc_end ? burst_num_end_c : burst_num_not_end_c));
    wire is_cnt_drs_end = (cnt_drs == block_len_rs);

    wire [C_WIDTH-1:0] currc = is_cnt_doc_end ? currc_end_c : currc_not_end_c;


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

    wire [BUS_ADDR_WIDTH-1:0] weight_offset_addr_write_fifo;

    weight_offset_addr_gen #(
        .NUM_WIDTH      (NUM_WIDTH),
        .DIM_WIDTH      (DIM_WIDTH),
        .BUS_ADDR_WIDTH (BUS_ADDR_WIDTH),
        .WICRS_WIDTH    (WICRS_WIDTH),
        .WIC_WIDTH      (WIC_WIDTH),
        .BUS_WIDTH      (BUS_WIDTH),
        .CHANNEL_NUM    (CHANNEL_NUM),
        .S_WIDTH        (S_WIDTH),
        .C_WIDTH        (C_WIDTH),
        .BURST_NUM_WIDTH(BURST_NUM_WIDTH)
    ) u_weight_offset_addr_gen (
        .clk                     (clk),
        .rstn                    (rstn),
        .shift_value             (shift_value),
        .Wicrs                   (Wicrs),
        .Wic                     (Wic),
        .basic_rs_add1           (basic_rs_add1),
        .basic_ic_add1           (basic_ic_add1),
        .basic_oc_add1           (basic_oc_add1),
        .cnt_load_wei_rs         (cnt_load_wei_rs),
        .cnt_load_wei_ic         (cnt_load_wei_ic),
        .cnt_load_wei_oc         (cnt_load_wei_oc),
        .currc                   (currc),
        .cnt_dburst              (cnt_dburst),
        .cnt_drs                 (cnt_drs),
        .cnt_doc                 (cnt_doc),
        .weight_offset_addr_shift(weight_offset_addr_shift),

        .weight_offset_addr(weight_offset_addr_write_fifo)
    );

    assign weight_offset_addr_fifo_wr_data = {
        burst_len_delay[8-1:0], weight_offset_addr_write_fifo[BUS_ADDR_WIDTH-1:0]
    };

    assign weight_offset_addr_fifo_rd_en = (~weight_offset_addr_fifo_empty) &&(~weight_offset_addr_fifo_rd_valid)&& (~init_weight_rtx_pulse);

    reg ar_valid;
    reg [BUS_ADDR_WIDTH-1:0] ar_addr;
    reg [8-1:0] ar_len;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ar_valid <= 1'b0;
            ar_addr  <= {BUS_ADDR_WIDTH{1'b0}};
            ar_len   <= 0;
        end else if (weight_offset_addr_fifo_rd_valid && ~ar_valid) begin
            ar_valid <= 1'b1;
            ar_addr  <= weight_offset_addr_fifo_rd_data[BUS_ADDR_WIDTH-1:0];
            ar_len   <= weight_offset_addr_fifo_rd_data[BUS_ADDR_WIDTH+8-1:BUS_ADDR_WIDTH];
        end else if (dma_weight_arready && ar_valid) begin
            ar_valid <= 1'b0;
        end
    end

    assign init_weight_rtx_pulse = ar_valid;
    assign weight_offset_addr = ar_addr;
    assign weight_load_burst_len = ar_len;

    // assign weight_offset_addr = weight_offset_addr_fifo_rd_data;
    // assign init_weight_rtx_pulse = weight_offset_addr_fifo_rd_valid;
    sync_fifo_cnt #(
        .WIDTH(BUS_ADDR_WIDTH + 8),
        .DEPTH(OFFST_ADDR_FIFO_DEPTH),
        .RAM_STYLE_VAL("block")
    ) fifo_weight_offset_addr (
        .clk         (clk),
        .rstn        (rstn),
        .wr_en       (weight_offset_addr_fifo_wr_en),
        .rd_en       (weight_offset_addr_fifo_rd_en),
        .wr_data     (weight_offset_addr_fifo_wr_data),
        .rd_data     (weight_offset_addr_fifo_rd_data),
        .rd_valid    (weight_offset_addr_fifo_rd_valid),
        .full        (),
        .empty       (weight_offset_addr_fifo_empty),
        .almost_full (),
        .almost_empty(),
        .fifo_counter(weight_offset_addr_fifo_counter)
    );
    reg weight_offset_addr_gen_done_flag;
    wire weight_offset_addr_gen_enable = ~weight_offset_addr_fifo_almost_full & ~weight_offset_addr_gen_done_flag & (curr_state == S_LOAD);
    wire weight_offset_addr_gen_done_pulse = is_cnt_dburst_end & is_cnt_drs_end & is_cnt_doc_end & weight_offset_addr_gen_enable;


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            weight_offset_addr_gen_done_flag <= 0;
        end else if (weight_offset_addr_gen_done_pulse) begin
            weight_offset_addr_gen_done_flag <= 1;
        end else if (curr_state == S_IDLE) begin
            weight_offset_addr_gen_done_flag <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dburst <= 0;
        end else if (weight_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end) begin
                cnt_dburst <= 0;
            end else begin
                cnt_dburst <= (cnt_dburst + 1);
            end
        end else if (weight_offset_addr_gen_done_pulse) begin
            cnt_dburst <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_drs <= 0;
        end else if (weight_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end) begin
                if (is_cnt_drs_end) begin
                    cnt_drs <= 0;
                end else begin
                    cnt_drs <= (cnt_drs + 1);
                end
            end
        end else if (weight_offset_addr_gen_done_pulse) begin
            cnt_drs <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_doc <= 0;
        end else if (weight_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end & is_cnt_drs_end) begin
                if (is_cnt_doc_end) begin
                    cnt_doc <= 0;
                end else begin
                    cnt_doc <= (cnt_doc + 1);
                end
            end
        end else if (weight_offset_addr_gen_done_pulse) begin
            cnt_doc <= 0;
        end
    end

    dq_dff #(
        .N (ADDR_GEN_DELAY),
        .DW(1)
    ) u_weight_offset_addr_gen_enable (
        .clk(clk),
        .rstn(rstn),
        .d(weight_offset_addr_gen_enable),
        .q(weight_offset_addr_fifo_wr_en)  //产生写地址fifo使能
    );





endmodule




