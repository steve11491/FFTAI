

module weight_waddr_gen #(
    parameter DIM_WIDTH = 10,
    parameter WEIGHT_RAM_ADDR_WIDTH = 10
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [DIM_WIDTH-1:0] cnt_dim_rs,
    input wire [DIM_WIDTH-1:0] cnt_dim_oc,
    input wire [DIM_WIDTH-1:0] cnt_dim_ic,
    input wire [DIM_WIDTH+1-1:0] block_len_ic_add1,
    input wire [(DIM_WIDTH+1)*2-1:0] block_len_icrs_add1,
    output reg [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_waddr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         weight_waddr <= 0;
    //     end else if (en_true & cnt_L_end) begin
    //         weight_waddr<=cnt_dim_oc*(block_len_ic + 1)*(block_len_rs+1)
    //                         +cnt_dim_rs*(block_len_ic + 1)+cnt_dim_ic;
    //     end
    // end




    reg [(DIM_WIDTH+1)*2-1:0] stage0_result1;
    reg [(DIM_WIDTH+1)*2+DIM_WIDTH-1:0] stage0_result2;
    reg [DIM_WIDTH-1:0] stage0_result3;
    reg en_ff;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage0_result1 <= 0;
            stage0_result2 <= 0;
            stage0_result3 <= 0;
        end else if (en) begin
            stage0_result1 <= cnt_dim_rs * block_len_ic_add1;
            stage0_result2 <= cnt_dim_oc * block_len_icrs_add1;
            stage0_result3 <= cnt_dim_ic;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            en_ff <= 0;
        end else begin
            en_ff <= en;

        end
    end

    reg [(DIM_WIDTH)*3+3-1:0] stage1_result1;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage1_result1 <= 0;
        end else if (en_ff) begin
            stage1_result1 <= stage0_result1 + stage0_result2 + stage0_result3;

        end
    end


    generate
        if (((DIM_WIDTH) * 3 + 3) > WEIGHT_RAM_ADDR_WIDTH) begin
            assign weight_waddr = stage1_result1[WEIGHT_RAM_ADDR_WIDTH-1:0];
        end else begin
            assign weight_waddr = {
                {(WEIGHT_RAM_ADDR_WIDTH - ((DIM_WIDTH) * 3 + 3)) {1'b0}},
                stage1_result1[(DIM_WIDTH)*3+3-1:0]
            };
        end
    endgenerate


endmodule
