

module burst_gen_bias #(
    parameter DATA_WIDTH = 32,
    parameter CHANNEL_NUM = 16,
    parameter DIM_WIDTH = 10,
    parameter BUS_WIDTH = 64,
    parameter C_WIDTH = $clog2(CHANNEL_NUM * 2),
    parameter BURST_NUM_WIDTH = $clog2(CHANNEL_NUM * 2) + DIM_WIDTH - 8 - $clog2(BUS_WIDTH / 8) + 1
    // 如果是bias需要+1
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire bias_mode_external,
    input wire [DIM_WIDTH-1:0] block_len_c,
    input wire [DIM_WIDTH-1:0] block_len_w,

    output reg [C_WIDTH-1:0] currc_end_c,  //最后一个c方向的c数量
    output reg [C_WIDTH-1:0] currc_not_end_c,  //不是最后一个c方向的c数量

    output reg [BURST_NUM_WIDTH-1:0] burst_num_end_c,  //最后一个c方向的突发个数
    output reg [BURST_NUM_WIDTH-1:0] burst_num_not_end_c,//不是最后一个c方向的突发个数
    output reg [7:0] remain_burst_len_end_c,  //最后一个c方向的最后一块不足256的长度
    output reg [7:0] remain_burst_len_not_end_c //不是最后一个c方向的最后一块不足256的长度
);
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            currc_end_c <= 0;
            currc_not_end_c <= 0;
        end else begin
            currc_end_c <= is_int16 ? {1'b0, block_len_c[C_WIDTH-2:0]} : block_len_c[C_WIDTH-1:0];
            currc_not_end_c <= is_int16 ? CHANNEL_NUM - 1 : CHANNEL_NUM * 2 - 1;
        end
    end

    // assign currc_end_c = is_int16 ? {1'b0, block_len_c[C_WIDTH-2:0]} : block_len_c[C_WIDTH-1:0];
    // assign currc_not_end_c = is_int16 ? CHANNEL_NUM - 1 : CHANNEL_NUM * 2 - 1;

    reg [DIM_WIDTH+C_WIDTH-1:0] cw_end_c_stage0_result1;
    reg [DIM_WIDTH+1-1:0] cw_end_c_stage0_result2;
    reg [DIM_WIDTH+C_WIDTH-1:0] cw_not_end_c_stage0_result1;
    reg [DIM_WIDTH+1-1:0] cw_not_end_c_stage0_result2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cw_end_c_stage0_result1 <= 0;
            cw_end_c_stage0_result2 <= 0;
            cw_not_end_c_stage0_result1 <= 0;
            cw_not_end_c_stage0_result2 <= 0;
        end else begin
            cw_end_c_stage0_result1 <= currc_end_c * block_len_w;
            cw_end_c_stage0_result2 <= currc_end_c + block_len_w;
            cw_not_end_c_stage0_result1 <= currc_not_end_c * block_len_w;
            cw_not_end_c_stage0_result2 <= currc_not_end_c + block_len_w;

        end
    end

    reg [DIM_WIDTH+C_WIDTH-1:0] cw_end_c;
    reg [DIM_WIDTH+C_WIDTH-1:0] cw_not_end_c;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cw_end_c <= 0;
            cw_not_end_c <= 0;
        end else begin
            if (bias_mode_external == 1'b1) begin
                cw_end_c <= cw_end_c_stage0_result1 + cw_end_c_stage0_result2;
                cw_not_end_c <= cw_not_end_c_stage0_result1 + cw_not_end_c_stage0_result2;
            end else begin
                cw_end_c <= currc_end_c;
                cw_not_end_c <= currc_not_end_c;
            end
        end
    end


    localparam TMP_WIDTH_int8 = $clog2(BUS_WIDTH / (DATA_WIDTH / 2));
    localparam TMP_WIDTH_int16 = $clog2(BUS_WIDTH / (DATA_WIDTH));

    wire [7+TMP_WIDTH_int8:0] low_cw_end_c;
    assign low_cw_end_c = is_int16 ? {1'b0, cw_end_c[7+TMP_WIDTH_int16:0]} : cw_end_c[7+TMP_WIDTH_int8:0];
    wire [7:0] low_burst_len_end_c;
    assign low_burst_len_end_c = is_int16 ? {cw_end_c[7+TMP_WIDTH_int16:TMP_WIDTH_int16]} : cw_end_c[7+TMP_WIDTH_int8:TMP_WIDTH_int8];
    wire [DIM_WIDTH+C_WIDTH-1-8-TMP_WIDTH_int16:0] high_cw_end_c;
    assign high_cw_end_c = is_int16 ? cw_end_c[DIM_WIDTH+C_WIDTH-1:8+TMP_WIDTH_int16] : {1'b0, cw_end_c[DIM_WIDTH+C_WIDTH-1:8+TMP_WIDTH_int8]};

    assign remain_burst_len_end_c = low_burst_len_end_c;


    reg [DIM_WIDTH+C_WIDTH-8-1:0] tx_num_end_c;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            tx_num_end_c <= 0;
        end else begin
            tx_num_end_c <= high_cw_end_c + (|low_cw_end_c) - 1;
        end
    end

    assign burst_num_end_c = tx_num_end_c[BURST_NUM_WIDTH-1:0];

    wire [7+TMP_WIDTH_int8:0] low_cw_not_end_c;
    assign low_cw_not_end_c = is_int16 ? {1'b0, cw_not_end_c[7+TMP_WIDTH_int16:0]} : cw_not_end_c[7+TMP_WIDTH_int8:0];
    wire [7:0] low_burst_len_not_end_c;
    assign low_burst_len_not_end_c = is_int16 ? {cw_not_end_c[7+TMP_WIDTH_int16:TMP_WIDTH_int16]} : cw_not_end_c[7+TMP_WIDTH_int8:TMP_WIDTH_int8];
    wire [DIM_WIDTH+C_WIDTH-1-8-TMP_WIDTH_int16:0] high_cw_not_end_c;
    assign high_cw_not_end_c = is_int16 ? cw_not_end_c[DIM_WIDTH+C_WIDTH-1:8+TMP_WIDTH_int16] : {1'b0, cw_not_end_c[DIM_WIDTH+C_WIDTH-1:8+TMP_WIDTH_int8]};

    assign remain_burst_len_not_end_c = low_burst_len_not_end_c;

    reg [DIM_WIDTH+C_WIDTH-8-1:0] tx_num_not_end_c;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            tx_num_not_end_c <= 0;
        end else begin
            tx_num_not_end_c <= high_cw_not_end_c + (|low_cw_not_end_c) - 1;
        end
    end
    assign burst_num_not_end_c = tx_num_not_end_c[BURST_NUM_WIDTH-1:0];
endmodule
