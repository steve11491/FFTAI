


module L1_omap_waddr_gen #(
    parameter OMAP_RAM_ADDR_WIDTH = 12,
    parameter DIM_WIDTH = 8,
    parameter CNT_OC_WIDTH = 6
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [CNT_OC_WIDTH-1:0] cnt_wi_block_len_oc_fea,
    input wire [DIM_WIDTH*2-1:0] cnt_wi_block_len_owh,
    input wire [DIM_WIDTH*2-1:0] block_len_owh,
    output reg [OMAP_RAM_ADDR_WIDTH-1:0] omap_waddr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         omap_addr <= 0;
    //     end else if (is_wi_feature_write_ing) begin
    //         omap_addr <= cnt_wi_block_len_oc_fea * (block_len_owh + 1) + cnt_wi_block_len_owh;
    //     end else begin
    //         omap_addr <= 0;
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
            stage0_result1 <= cnt_wi_block_len_oc_fea * (block_len_owh + 1);
            stage0_result2 <= cnt_wi_block_len_owh;

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
        if (CNT_OC_WIDTH + DIM_WIDTH * 2 + 1 + 1 > OMAP_RAM_ADDR_WIDTH) begin
            assign omap_waddr = stage1_result1[OMAP_RAM_ADDR_WIDTH-1:0];
        end else begin
            assign omap_waddr = {
                {(OMAP_RAM_ADDR_WIDTH - (CNT_OC_WIDTH + DIM_WIDTH * 2 + 1 + 1)) {1'b0}},
                stage1_result1[CNT_OC_WIDTH+DIM_WIDTH*2+1+1-1:0]
            };
        end
    endgenerate


endmodule
