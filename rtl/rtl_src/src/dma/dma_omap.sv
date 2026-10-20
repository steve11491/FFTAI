



module dma_omap #(
    parameter CHANNEL_NUM = 8,
    parameter NUM_WIDTH = 10,
    parameter DIM_WIDTH = 10,
    parameter BUS_WIDTH = 32,
    parameter BUS_ADDR_WIDTH = 32,
    parameter OMAP_WIDTH = 16,  // int16情况下的omap位宽
    parameter OMAP_RAM_WIDTH = 40,  //omap ram的位宽
    parameter OMAP_RAM_ADDR_WIDTH = 10,
    parameter AOWOH_WIDTH = 20,
    parameter AOW_WIDTH = 10,
    parameter C_WIDTH = $clog2(CHANNEL_NUM * 2),
    // omap需要加1
    parameter BURST_NUM_WIDTH = $clog2(CHANNEL_NUM * 2) + DIM_WIDTH - 8 - $clog2(BUS_WIDTH / 8)
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire [AOWOH_WIDTH-1:0] Aowoh,  //omap的整体oc和整体ow的乘积
    input wire [AOW_WIDTH-1:0] Aow,  //omap的整体oc

    input wire [DIM_WIDTH+1-1:0] basic_oc_add1,  // int8的情况下，omap占16位，basic_oc需要是2的倍数，int16的情况下，omap占32位，需要是1的倍数 (32总线位宽的情况)
    input wire [DIM_WIDTH+1-1:0] basic_ow_add1,
    input wire [DIM_WIDTH+1-1:0] basic_oh_add1,

    (* mark_debug = "true"*) input wire write_omap_start,

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

    input wire [NUM_WIDTH-1:0] cnt_write_omap_w,
    input wire [NUM_WIDTH-1:0] cnt_write_omap_h,
    input wire [NUM_WIDTH-1:0] cnt_write_omap_oc,

    // axi interface
    input wire dma_omap_awready,
    output wire init_omap_wtx_pulse,  //开始传输地址
    output reg [BUS_ADDR_WIDTH-1:0] omap_offset_addr,
    output wire [8-1:0] omap_write_burst_len,
    input wire dma_omap_wready,
    output wire dma_omap_wlast,


    output wire dout_valid,
    output wire [BUS_WIDTH-1:0] dout_data,

    // ram interface
    output reg [OMAP_RAM_ADDR_WIDTH-1:0] omap_raddr,
    output reg [CHANNEL_NUM-1:0] omap_ren,
    input wire [OMAP_RAM_WIDTH-1:0] omap_rdata[CHANNEL_NUM-1:0],
    input wire [CHANNEL_NUM-1:0] omap_rdata_valid,

    output reg is_write_omap_done,
    output reg is_write_omap_busy
);

    // for debug
    // 静态断言检查 BUS_WIDTH 是否小于 OMAP_WIDTH * CHANNEL_NUM
    assert #0 (BUS_WIDTH < OMAP_WIDTH * CHANNEL_NUM);

    // 静态断言检查 BUS_WIDTH 是否为2的幂
    assert #0 ((BUS_WIDTH & (BUS_WIDTH - 1)) == 0);

    wire [OMAP_WIDTH-1:0] omap_rdata_int16[CHANNEL_NUM-1:0];
    wire [OMAP_WIDTH/2-1:0] omap_rdata_int8[CHANNEL_NUM*2-1:0];
    wire [OMAP_WIDTH-1:0] dout_data_int16[BUS_WIDTH/OMAP_WIDTH-1:0];
    wire [OMAP_WIDTH/2-1:0] dout_data_int8[BUS_WIDTH/(OMAP_WIDTH/2)-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign omap_rdata_int16[i] = omap_rdata[i][OMAP_WIDTH-1:0];
            assign {omap_rdata_int8[i*2+1], omap_rdata_int8[i*2]} = omap_rdata[i][OMAP_WIDTH-1:0];
        end
        for (genvar i = 0; i < BUS_WIDTH / OMAP_WIDTH; i = i + 1) begin
            assign dout_data_int16[i] = dout_data[(i+1)*OMAP_WIDTH-1:i*OMAP_WIDTH];
        end
        for (genvar i = 0; i < BUS_WIDTH / (OMAP_WIDTH / 2); i = i + 1) begin
            assign dout_data_int8[i] = dout_data[(i+1)*(OMAP_WIDTH/2)-1:i*(OMAP_WIDTH/2)];
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




    (* mark_debug = "false"*)reg  write_all_finish;
    (* mark_debug = "true"*)wire write_out_data_done_pulse;
    (* mark_debug = "false"*)reg  write_out_data_done_flag;
    (* mark_debug = "true"*)wire write_out_addr_done_pulse;
    (* mark_debug = "false"*)reg  write_out_addr_done_flag;

    localparam S_IDLE = 0, S_WRITE_OUT = 1;

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
                    if (write_omap_start) begin
                        next_state = S_WRITE_OUT;
                    end else begin
                        next_state = S_IDLE;
                    end
                end
                S_WRITE_OUT: begin
                    if (write_all_finish) begin
                        next_state = S_IDLE;
                    end else begin
                        next_state = S_WRITE_OUT;
                    end
                end
                default: begin
                    next_state = S_IDLE;
                end
            endcase
        end
    end
    assign en = (curr_state == S_WRITE_OUT);

    assign is_write_omap_busy = en;

    localparam MAX_L = CHANNEL_NUM * OMAP_WIDTH / BUS_WIDTH;//CHANNEL_NUM个通道的数据可以构成多少个总线数据
    localparam ADDR_GEN_DELAY = 4;  //地址产生逻辑的延时
    localparam L_SHIFT = $clog2(MAX_L);
    localparam OFFST_ADDR_FIFO_DEPTH = ADDR_GEN_DELAY + 5;
    // localparam OFFST_ADDR_FIFO_DEPTH = 128;
    localparam FIFO_COUNT_WIDTH = $clog2(OFFST_ADDR_FIFO_DEPTH) + 1;
    localparam OMAP_DATA_FIFO_DEPTH = 128;
    localparam DATA_FIFO_COUNT_WIDTH = $clog2(OMAP_DATA_FIFO_DEPTH) + 1;
    localparam CNT_WIDTH = DIM_WIDTH;
    localparam OC_CNT = $clog2(CHANNEL_NUM * 2);
    localparam S_WIDTH = $clog2(OC_CNT) + 1;
    wire [S_WIDTH-1:0] shift_value;
    assign shift_value = is_int16_reg ? (OC_CNT - 1) : (OC_CNT);
    parameter LOW_CUT_BIT = $clog2(BUS_WIDTH / OMAP_WIDTH);

    wire [DIM_WIDTH-1:0] shift_block_len_oc = block_len_oc >> shift_value;


    (* mark_debug = "true"*) wire axi_wready;
    (* mark_debug = "true"*) reg axi_wvalid;
    (* mark_debug = "true"*) reg axi_wlast;
    (* mark_debug = "true"*) reg [8-1:0] write_index;
    (* mark_debug = "false"*) wire wnext;
    (* mark_debug = "true"*) wire axi_awready;
    (* mark_debug = "true"*) reg aw_valid;
    (* mark_debug = "true"*) reg [BUS_ADDR_WIDTH-1:0] aw_addr;
    assign axi_awready = dma_omap_awready;
    assign axi_wready  = dma_omap_wready;

    reg [8-1:0] burst_len;



    (* mark_debug = "false"*) reg [CNT_WIDTH-1:0] cnt_dim_oc;
    (* mark_debug = "false"*) reg [CNT_WIDTH-1:0] cnt_dim_ow;
    (* mark_debug = "false"*) reg [CNT_WIDTH-1:0] cnt_dim_oh;
    (* mark_debug = "false"*) reg [$clog2(MAX_L)-1:0] cnt_L;
    (* mark_debug = "false"*) reg [L_SHIFT-1:0] curr_oc;
    (* mark_debug = "false"*) reg omap_data_read_done_flag;
    (* mark_debug = "false"*) wire omap_data_read_enable;
    (* mark_debug = "false"*) wire omap_data_read_done_pulse;
    (* mark_debug = "true"*) wire omap_data_fifo_wr_en;
    (* mark_debug = "true"*) wire omap_data_fifo_rd_en;
    (* mark_debug = "true"*) wire [BUS_WIDTH-1:0] omap_data_fifo_wr_data;
    (* mark_debug = "true"*) wire [BUS_WIDTH-1:0] omap_data_fifo_rd_data;
    (* mark_debug = "true"*) wire omap_data_fifo_rd_valid;
    (* mark_debug = "true"*) wire omap_data_fifo_almost_full;
    (* mark_debug = "true"*) wire omap_data_fifo_empty;
    (* mark_debug = "true"*) wire [DATA_FIFO_COUNT_WIDTH-1:0] omap_data_fifo_counter;






    (* mark_debug = "true"*) wire omap_offset_addr_fifo_wr_en;
    (* mark_debug = "true"*) wire omap_offset_addr_fifo_rd_en;
    (* mark_debug = "true"*) wire [BUS_ADDR_WIDTH+8-1:0] omap_offset_addr_fifo_wr_data;
    (* mark_debug = "true"*) wire [BUS_ADDR_WIDTH+8-1:0] omap_offset_addr_fifo_rd_data;
    (* mark_debug = "true"*) wire omap_offset_addr_fifo_rd_valid;
    (* mark_debug = "true"*) wire omap_offset_addr_fifo_almost_full;
    (* mark_debug = "true"*) wire omap_offset_addr_fifo_empty;
    (* mark_debug = "false"*) reg omap_offset_addr_gen_done_flag;
    (* mark_debug = "false"*) wire omap_offset_addr_gen_enable;
    (* mark_debug = "false"*) wire omap_offset_addr_gen_done_pulse;
    (* mark_debug = "true"*) wire [FIFO_COUNT_WIDTH-1:0] omap_offset_addr_fifo_counter;

    localparam BURST_LEN_FIFO_DEPTH = 128;
    localparam BURST_LEN_FIFO_COUNT_WIDTH = $clog2(BURST_LEN_FIFO_DEPTH) + 1;
    (* mark_debug = "true"*) wire curr_burst_len_fifo_wr_en;
    (* mark_debug = "true"*) wire curr_burst_len_fifo_rd_en;
    (* mark_debug = "true"*) wire [8-1:0] curr_burst_len;
    (* mark_debug = "true"*) wire curr_burst_len_fifo_empty;
    (* mark_debug = "true"*) wire [BURST_LEN_FIFO_COUNT_WIDTH-1:0] curr_burst_len_fifo_counter;


    sync_fifo_cnt #(
        .WIDTH(8),
        .DEPTH(BURST_LEN_FIFO_DEPTH),  // todo: 这里的深度需要考虑一下？？？
        .RAM_STYLE_VAL("block")
    ) fifo_curr_burst_len (
        .clk         (clk),
        .rstn        (rstn),
        .wr_en       (curr_burst_len_fifo_wr_en),
        .rd_en       (curr_burst_len_fifo_rd_en),
        .wr_data     (omap_offset_addr_fifo_wr_data[BUS_ADDR_WIDTH+8-1:BUS_ADDR_WIDTH]),
        .rd_data     (curr_burst_len),
        .rd_valid    (),
        .full        (),
        .empty       (curr_burst_len_fifo_empty),
        .almost_full (),
        .almost_empty(),
        .fifo_counter(curr_burst_len_fifo_counter)
    );




    assign write_out_data_done_pulse = omap_data_read_done_flag && omap_data_fifo_empty && wnext && axi_wlast ;
    assign write_out_addr_done_pulse = omap_offset_addr_gen_done_flag && omap_offset_addr_fifo_empty && dma_omap_awready && aw_valid ;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            write_out_data_done_flag <= 0;
        end else begin
            if (write_out_data_done_pulse) begin
                write_out_data_done_flag <= 1;
            end else if (curr_state == S_IDLE) begin
                write_out_data_done_flag <= 0;
            end
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            write_out_addr_done_flag <= 0;
        end else begin
            if (write_out_addr_done_pulse) begin
                write_out_addr_done_flag <= 1;
            end else if (curr_state == S_IDLE) begin
                write_out_addr_done_flag <= 0;
            end
        end
    end
    assign write_all_finish   = write_out_data_done_flag & write_out_addr_done_flag;
    assign is_write_omap_done = write_all_finish;



    // 一次突发传输需要读多次channel_num并行度，cut_block_len_oc是突发传输的最后一段channel_num可以构成多少个总线传输个数，
    // is_int16_reg ? block_len_oc[OC_CNT-2:0] : block_len_oc[OC_CNT-1:0]是最后一段的长度，
    //一次总线传输可以传输$clog2(BUS_WIDTH/OMAP_WIDTH)个（int16的情况），$clog2(BUS_WIDTH*2/OMAP_WIDTH)个（int8的情况）
    wire [DIM_WIDTH-1:0] cut_block_len_oc;
    assign cut_block_len_oc = is_int16_reg ? block_len_oc[OC_CNT-2:$clog2(
        BUS_WIDTH/OMAP_WIDTH
    )] : block_len_oc[OC_CNT-1:$clog2(
        BUS_WIDTH*2/OMAP_WIDTH
    )];



    reg start_state;  // 从开始到传输的那一段时间
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            start_state <= 1'b0;
        end else if (write_omap_start) begin
            start_state <= 1'b1;
        end else if (omap_data_fifo_rd_en) begin
            start_state <= 1'b0;
        end
    end







    assign wnext = dma_omap_wready & axi_wvalid;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            axi_wvalid <= 1'b0;
        end else if (write_omap_start) begin
            axi_wvalid <= 1'b0;
        end else if (~axi_wvalid && ~omap_data_fifo_empty) begin
            axi_wvalid <= 1'b1;
        end else if (wnext && axi_wlast && ~omap_data_fifo_empty) begin
            axi_wvalid <= 1'b1;
        end else if (wnext && axi_wlast && omap_data_fifo_empty) begin
            axi_wvalid <= 1'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            axi_wlast <= 1'b0;
        end else if (write_omap_start) begin
            axi_wlast <= 1'b0;
        end else if (((write_index == curr_burst_len - 1 && curr_burst_len > 0) && wnext) || (curr_burst_len == 0 &(~start_state))) begin
            axi_wlast <= 1'b1;
        end else if (wnext) begin
            axi_wlast <= 1'b0;
        end else if (axi_wlast && curr_burst_len == 0) begin
            axi_wlast <= 1'b0;
        end
    end

    assign dma_omap_wlast = axi_wlast;


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            write_index <= 0;
        end else if ((write_omap_start)) begin
            write_index <= 0;
        end else if (wnext) begin
            if (write_index == curr_burst_len) begin
                write_index <= 0;
            end else begin
                write_index <= write_index + 1;
            end
        end
    end

    assign curr_burst_len_fifo_wr_en = omap_offset_addr_fifo_wr_en;  //dma_omap_awready && aw_valid;
    assign curr_burst_len_fifo_rd_en = (~curr_burst_len_fifo_empty) && ((omap_data_fifo_rd_en && start_state) || (wnext && axi_wlast  && ~start_state));


    //读使能的使能选择
    wire [CHANNEL_NUM-1:0] omap_ren_mask;
    reg [MAX_L-1:0] en_sel;
    wire [CHANNEL_NUM-1:0] omap_ren_w;

    wire cnt_L_end = (cnt_L == curr_oc);
    wire cnt_L_start = (cnt_L == 0);
    wire is_cnt_dim_ow_end = (cnt_dim_ow == block_len_ow);
    wire is_cnt_dim_oh_end = (cnt_dim_oh == block_len_oh);
    wire is_cnt_dim_oc_end = (cnt_dim_oc == shift_block_len_oc);

    assign omap_data_fifo_rd_en = (~axi_wvalid && ~omap_data_fifo_empty) || (~omap_data_fifo_empty && wnext) ;
    assign dout_data = omap_data_fifo_rd_data;
    assign dout_valid = axi_wvalid;
    assign omap_data_read_enable = ~omap_data_fifo_almost_full & ~omap_data_read_done_flag & (curr_state == S_WRITE_OUT);
    assign omap_data_read_done_pulse = is_cnt_dim_ow_end & is_cnt_dim_oh_end &is_cnt_dim_oc_end & cnt_L_end & omap_data_read_enable;


    assign curr_oc = is_cnt_dim_oc_end ? cut_block_len_oc[L_SHIFT-1:0] : (2 ** L_SHIFT - 1);







    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            omap_data_read_done_flag <= 0;
        end else begin
            if (omap_data_read_done_pulse) begin
                omap_data_read_done_flag <= 1;
            end else if (curr_state == S_IDLE) begin
                omap_data_read_done_flag <= 0;
            end
        end
    end



    assign en_sel = ({MAX_L{1'b1}} << (MAX_L - 1 - curr_oc)) >> (MAX_L - 1 - curr_oc);


    // 并行转串行逻辑
    reg [BUS_WIDTH-1:0] shift_register  [MAX_L-1:0];
    reg [BUS_WIDTH-1:0] shift_register_w[MAX_L-1:0];
    generate
        for (genvar i = 0; i < MAX_L; i = i + 1) begin
            for (genvar j = 0; j < BUS_WIDTH / OMAP_WIDTH; j = j + 1) begin  // 维度映射
                assign shift_register_w[i][(j+1)*OMAP_WIDTH-1:j*OMAP_WIDTH] = omap_rdata[i*(BUS_WIDTH/OMAP_WIDTH)+j][OMAP_WIDTH-1:0];
                assign omap_ren_mask[i*(BUS_WIDTH/OMAP_WIDTH)+j] = en_sel[i];
            end
        end
    endgenerate

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            shift_register <= '{MAX_L{0}};
        end else if (en & (|omap_rdata_valid)) begin
            shift_register <= shift_register_w;
        end else begin
            for (int i = 0; i < MAX_L - 1; i = i + 1) begin
                shift_register[i] <= shift_register[i+1];
            end
        end
    end



    reg [MAX_L-1:0] omap_rdata_valid_w;
    generate
        for (genvar i = 0; i < MAX_L; i = i + 1) begin
            assign omap_rdata_valid_w[i] = |(omap_rdata_valid[(i+1)*(BUS_WIDTH / OMAP_WIDTH)-1:i*(BUS_WIDTH / OMAP_WIDTH)]);
        end
    endgenerate
    reg [MAX_L-1:0] rdata_valid_delay;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            rdata_valid_delay <= 0;
        end else begin
            if (|omap_rdata_valid) begin
                rdata_valid_delay[MAX_L-1:0] <= omap_rdata_valid_w;
            end else begin
                rdata_valid_delay[MAX_L-1:0] <= ({1'b0, rdata_valid_delay[MAX_L-1:1]});
            end
        end
    end
    assign omap_data_fifo_wr_data = shift_register[0];
    assign omap_data_fifo_wr_en   = |rdata_valid_delay;

    localparam OMAP_RADDR_GEN_DELAY = 2;
    localparam READ_ADDR_TO_DATA_OUT_DELAY = 2;

    assign omap_data_fifo_almost_full = omap_data_fifo_counter > (OMAP_DATA_FIFO_DEPTH-OMAP_RADDR_GEN_DELAY-READ_ADDR_TO_DATA_OUT_DELAY-MAX_L-2);

    sync_fifo_cnt #(
        .WIDTH(BUS_WIDTH),
        .DEPTH(OMAP_DATA_FIFO_DEPTH),
        .RAM_STYLE_VAL("block")
    ) fifo_omap_data (
        .clk         (clk),
        .rstn        (rstn),
        .wr_en       (omap_data_fifo_wr_en),
        .rd_en       (omap_data_fifo_rd_en),
        .wr_data     (omap_data_fifo_wr_data),
        .rd_data     (omap_data_fifo_rd_data),
        .rd_valid    (omap_data_fifo_rd_valid),
        .full        (),
        .empty       (omap_data_fifo_empty),
        .almost_full (),
        .almost_empty(),
        .fifo_counter(omap_data_fifo_counter)
    );



    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_L <= 0;
        end else if (omap_data_read_enable) begin
            if (cnt_L_end) begin
                cnt_L <= 0;
            end else begin
                cnt_L <= cnt_L + 1;
            end
        end else if (omap_data_read_done_pulse) begin
            cnt_L <= 0;
        end
    end



    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_ow <= 0;
        end else if (omap_data_read_enable && cnt_L_end) begin
            if (is_cnt_dim_ow_end) begin
                cnt_dim_ow <= 0;
            end else begin
                cnt_dim_ow <= (cnt_dim_ow + 1);
            end
        end else if (omap_data_read_done_pulse) begin
            cnt_dim_ow <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_oh <= 0;
        end else if (omap_data_read_enable && cnt_L_end) begin
            if (is_cnt_dim_ow_end) begin
                if (is_cnt_dim_oh_end) begin
                    cnt_dim_oh <= 0;
                end else begin
                    cnt_dim_oh <= (cnt_dim_oh + 1);
                end
            end
        end else if (omap_data_read_done_pulse) begin
            cnt_dim_oh <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dim_oc <= 0;
        end else if (omap_data_read_enable && cnt_L_end) begin
            if (is_cnt_dim_ow_end & is_cnt_dim_oh_end) begin
                if (is_cnt_dim_oc_end) begin
                    cnt_dim_oc <= 0;
                end else begin
                    cnt_dim_oc <= cnt_dim_oc + 1;
                end
            end
        end else if (omap_data_read_done_pulse) begin
            cnt_dim_oc <= 0;
        end
    end

    assign omap_ren_w = omap_ren_mask & ({CHANNEL_NUM{omap_data_read_enable && cnt_L_start}});

    omap_raddr_gen #(
        .DIM_WIDTH          (DIM_WIDTH),
        .OMAP_RAM_ADDR_WIDTH(OMAP_RAM_ADDR_WIDTH)
    ) u_omap_raddr_gen (
        .clk               (clk),
        .rstn              (rstn),
        .en                (en),
        .cnt_dim_ow        (cnt_dim_ow),
        .cnt_dim_oc        (cnt_dim_oc),
        .cnt_dim_oh        (cnt_dim_oh),
        .block_len_ow_add1 (block_len_ow_add1),
        .block_len_owh_add1(block_len_owh_add1),

        .omap_raddr(omap_raddr)
    );
    dq_dff #(
        .N (OMAP_RADDR_GEN_DELAY),  //omap_raddr_gen的延迟是2
        .DW(CHANNEL_NUM)
    ) u_omap_ren_w_delay (
        .clk(clk),
        .rstn(rstn),
        .d(omap_ren_w),
        .q(omap_ren)
    );

    assign omap_offset_addr_fifo_almost_full = omap_offset_addr_fifo_counter > (OFFST_ADDR_FIFO_DEPTH-ADDR_GEN_DELAY-2);


    wire [1:0] omap_offset_addr_shift = is_int16_reg ? 1: 0; // int16情况下，omap为16位，占2个8bit，地址需要左移1位，int8情况下，omap为8位，占1个8bit，地址需要左移0位




    reg [BURST_NUM_WIDTH-1:0] cnt_dburst;
    reg [CNT_WIDTH-1:0] cnt_doh;
    reg [CNT_WIDTH-1:0] cnt_doc;

    wire is_cnt_doc_end = (cnt_doc == shift_block_len_oc);
    wire is_cnt_dburst_end = (cnt_dburst == (is_cnt_doc_end ? burst_num_end_c : burst_num_not_end_c));
    wire is_cnt_doh_end = (cnt_doh == block_len_oh);

    wire [C_WIDTH-1:0] currc = is_cnt_doc_end ? currc_end_c : currc_not_end_c;


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


    wire [BUS_ADDR_WIDTH-1:0] omap_offset_addr_write_fifo;
    omap_offset_addr_gen #(
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
    ) u_omap_offset_addr_gen (
        .clk                   (clk),
        .rstn                  (rstn),
        .shift_value           (shift_value),
        .Aowoh                 (Aowoh),
        .Aow                   (Aow),
        .basic_oh_add1         (basic_oh_add1),
        .basic_ow_add1         (basic_ow_add1),
        .basic_oc_add1         (basic_oc_add1),
        .cnt_write_omap_h      (cnt_write_omap_h),
        .cnt_write_omap_w      (cnt_write_omap_w),
        .cnt_write_omap_oc     (cnt_write_omap_oc),
        .currc                 (currc),
        .cnt_dburst            (cnt_dburst),
        .cnt_doh               (cnt_doh),
        .cnt_doc               (cnt_doc),
        .omap_offset_addr_shift(omap_offset_addr_shift),
        .omap_offset_addr      (omap_offset_addr_write_fifo)
    );

    assign omap_offset_addr_fifo_wr_data = {
        burst_len_delay[8-1:0], omap_offset_addr_write_fifo[BUS_ADDR_WIDTH-1:0]
    };

    assign omap_offset_addr_fifo_rd_en = (~omap_offset_addr_fifo_empty) && (~omap_offset_addr_fifo_rd_valid) && (~init_omap_wtx_pulse) ;

    reg [8-1:0] aw_len;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            aw_valid <= 1'b0;
            aw_addr  <= {BUS_ADDR_WIDTH{1'b0}};
            aw_len   <= 0;
        end else if (omap_offset_addr_fifo_rd_valid && ~aw_valid) begin
            aw_valid <= 1'b1;
            aw_addr  <= omap_offset_addr_fifo_rd_data[BUS_ADDR_WIDTH-1:0];
            aw_len   <= omap_offset_addr_fifo_rd_data[BUS_ADDR_WIDTH+8-1:BUS_ADDR_WIDTH];
        end else if (dma_omap_awready && aw_valid) begin
            aw_valid <= 1'b0;
        end
    end

    assign init_omap_wtx_pulse = aw_valid;
    assign omap_offset_addr = aw_addr;
    assign omap_write_burst_len = aw_len;

    sync_fifo_cnt #(
        .WIDTH(BUS_ADDR_WIDTH + 8),
        .DEPTH(OFFST_ADDR_FIFO_DEPTH),
        .RAM_STYLE_VAL("block")
    ) fifo_omap_offset_addr (
        .clk         (clk),
        .rstn        (rstn),
        .wr_en       (omap_offset_addr_fifo_wr_en),
        .rd_en       (omap_offset_addr_fifo_rd_en),
        .wr_data     (omap_offset_addr_fifo_wr_data),
        .rd_data     (omap_offset_addr_fifo_rd_data),
        .rd_valid    (omap_offset_addr_fifo_rd_valid),
        .full        (),
        .empty       (omap_offset_addr_fifo_empty),
        .almost_full (),
        .almost_empty(),
        .fifo_counter(omap_offset_addr_fifo_counter)
    );
    assign omap_offset_addr_gen_enable = ~omap_offset_addr_fifo_almost_full & ~omap_offset_addr_gen_done_flag & (curr_state == S_WRITE_OUT);
    assign omap_offset_addr_gen_done_pulse =  is_cnt_dburst_end & is_cnt_doh_end & is_cnt_doc_end & omap_offset_addr_gen_enable;


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            omap_offset_addr_gen_done_flag <= 0;
        end else if (omap_offset_addr_gen_done_pulse) begin
            omap_offset_addr_gen_done_flag <= 1;
        end else if (curr_state == S_IDLE) begin
            omap_offset_addr_gen_done_flag <= 0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_dburst <= 0;
        end else if (omap_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end) begin
                cnt_dburst <= 0;
            end else begin
                cnt_dburst <= (cnt_dburst + 1);
            end
        end else if (omap_offset_addr_gen_done_pulse) begin
            cnt_dburst <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_doh <= 0;
        end else if (omap_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end) begin
                if (is_cnt_doh_end) begin
                    cnt_doh <= 0;
                end else begin
                    cnt_doh <= (cnt_doh + 1);
                end
            end
        end else if (omap_offset_addr_gen_done_pulse) begin
            cnt_doh <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_doc <= 0;
        end else if (omap_offset_addr_gen_enable) begin
            if (is_cnt_dburst_end & is_cnt_doh_end) begin
                if (is_cnt_doc_end) begin
                    cnt_doc <= 0;
                end else begin
                    cnt_doc <= (cnt_doc + 1);
                end
            end
        end else if (omap_offset_addr_gen_done_pulse) begin
            cnt_doc <= 0;
        end
    end

    dq_dff #(
        .N (ADDR_GEN_DELAY),
        .DW(1)
    ) u_omap_offset_addr_gen_enable (
        .clk(clk),
        .rstn(rstn),
        .d(omap_offset_addr_gen_enable),
        .q(omap_offset_addr_fifo_wr_en)  //产生写地址fifo使能
    );



endmodule
