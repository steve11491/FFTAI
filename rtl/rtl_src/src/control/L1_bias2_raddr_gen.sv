


module L1_bias2_addr_gen #(
    parameter BIAS2_RAM_ADDR_WIDTH = 12,
    parameter DIM_WIDTH = 8,
    parameter CNT_OC_WIDTH = 6
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [CNT_OC_WIDTH-1:0] cnt_bias2_add_block_len_oc_fea,
    input wire [DIM_WIDTH*2-1:0] cnt_bias2_add_block_len_owh,
    input wire [DIM_WIDTH*2-1:0] block_len_owh,
    output reg [BIAS2_RAM_ADDR_WIDTH-1:0] bias2_addr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         bias2_addr <= 0;
    //     end else if (is_bias2_add_ing) begin
    //         bias2_addr <= cnt_bias2_add_block_len_oc_fea * (block_len_owh + 1) + cnt_bias2_add_block_len_owh;
    //     end else begin
    //         bias2_addr <= 0;
    //     end
    // end

    // Stage 0 
    reg [CNT_OC_WIDTH+DIM_WIDTH*2+1-1:0] stage0_result1;
    reg [DIM_WIDTH*2-1:0] stage0_result2;

    reg en_ff;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage0_result1 <= 0;
            stage0_result2 <= 0;
        end else if (en) begin
            stage0_result1 <= cnt_bias2_add_block_len_oc_fea * (block_len_owh + 1);
            stage0_result2 <= cnt_bias2_add_block_len_owh;

        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            en_ff <= 0;

        end else begin
            en_ff <= en;
        end
    end
    // Stage 1 
    reg [CNT_OC_WIDTH+DIM_WIDTH*2+1+1-1:0] stage1_result1;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage1_result1 <= 0;
        end else if (en_ff) begin
            stage1_result1 <= stage0_result1 + stage0_result2;
        end
    end



    generate
        if (CNT_OC_WIDTH + DIM_WIDTH * 2 + 1 + 1 > BIAS2_RAM_ADDR_WIDTH) begin
            assign bias2_addr = stage1_result1[BIAS2_RAM_ADDR_WIDTH-1:0];
        end else begin
            assign bias2_addr = {
                {(BIAS2_RAM_ADDR_WIDTH - (CNT_OC_WIDTH + DIM_WIDTH * 2 + 1 + 1)) {1'b0}},
                stage1_result1[CNT_OC_WIDTH+DIM_WIDTH*2+1+1-1:0]
            };
        end
    endgenerate


endmodule
