


module L1_weight_raddr_gen #(
    parameter WEIGHT_RAM_ADDR_WIDTH = 12,
    parameter DIM_WIDTH = 8,
    parameter CNT_OC_WIDTH = 6,
    parameter CNT_IC_WIDTH = 6,
    parameter GEMM_MAC_ROW_NUM = 16,
    parameter SEL_WIDTH = 16,
    parameter WIN_R_WIDTH = 2,
    parameter WIN_S_WIDTH = 2
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [CNT_OC_WIDTH-1:0] cnt_ri_block_len_oc_wei,
    input wire [DIM_WIDTH-1:0] cnt_ri_block_len_rs_wei,
    input wire [CNT_IC_WIDTH-1:0] cnt_ri_block_len_ic_wei,
    input wire [SEL_WIDTH-1:0] cnt_ri_block_len_ic_sel,
    input wire [DIM_WIDTH-1:0] block_len_ic,
    input wire [WIN_R_WIDTH*WIN_S_WIDTH-1:0] block_len_rs,
    output reg [WEIGHT_RAM_ADDR_WIDTH-1:0] weight_raddr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         weight_addr <= 0;
    //     end else if (is_ri_weight_load_ing) begin
    //         if ((cnt_ri_block_len_ic_sel != (cnt_ri_block_len_ic_sel_end + 1))) begin
    //             weight_addr <= cnt_ri_block_len_oc_wei * (block_len_ic + 1) * (block_len_rs + 1) 
    //                             + cnt_ri_block_len_rs_wei * (block_len_ic + 1)
    //                             + cnt_ri_block_len_ic_wei * GEMM_MAC_ROW_NUM
    //                             + cnt_ri_block_len_ic_sel[SEL_WIDTH-1:0];
    //         end
    //     end else begin
    //         weight_addr <= 0;
    //     end
    // end

    // Stage 0 
    reg [CNT_OC_WIDTH+DIM_WIDTH+1-1:0] stage0_result1;
    reg [DIM_WIDTH+DIM_WIDTH+1-1:0] stage0_result2;
    reg [CNT_IC_WIDTH+$clog2(GEMM_MAC_ROW_NUM)+1-1:0] stage0_result3;
    reg en_ff;
    reg en_ff2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage0_result1 <= 0;
            stage0_result2 <= 0;
            stage0_result3 <= 0;
        end else if (en) begin

            stage0_result1 <= cnt_ri_block_len_oc_wei * (block_len_ic + 1);
            stage0_result2 <= cnt_ri_block_len_rs_wei * (block_len_ic + 1);
            stage0_result3 <= cnt_ri_block_len_ic_wei * GEMM_MAC_ROW_NUM
                                + cnt_ri_block_len_ic_sel[SEL_WIDTH-1:0];
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            en_ff  <= 0;
            en_ff2 <= 0;
        end else begin
            en_ff  <= en;
            en_ff2 <= en_ff;
        end
    end
    // Stage 1 
    reg [CNT_OC_WIDTH+DIM_WIDTH+1+WIN_R_WIDTH*WIN_S_WIDTH+1-1:0] stage1_result1;
    reg [DIM_WIDTH+DIM_WIDTH+1+1-1:0] stage1_result2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage1_result1 <= 0;
            stage1_result2 <= 0;
        end else if (en_ff) begin
            stage1_result1 <= stage0_result1 * (block_len_rs + 1);
            stage1_result2 <= stage0_result2 + stage0_result3;
        end
    end
    // Stage 2 
    reg [CNT_OC_WIDTH+DIM_WIDTH+1+WIN_R_WIDTH*WIN_S_WIDTH+1+1-1:0] stage2_result1;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage2_result1 <= 0;
        end else if (en_ff2) begin
            stage2_result1 <= stage1_result1 + stage1_result2;

        end
    end


    generate
        if (CNT_OC_WIDTH+DIM_WIDTH+1+WIN_R_WIDTH*WIN_S_WIDTH+1+1 > WEIGHT_RAM_ADDR_WIDTH) begin
            assign weight_raddr = stage2_result1[WEIGHT_RAM_ADDR_WIDTH-1:0];
        end else begin
            assign weight_raddr = {
                {(WEIGHT_RAM_ADDR_WIDTH - (CNT_OC_WIDTH+DIM_WIDTH+1+WIN_R_WIDTH*WIN_S_WIDTH+1+1)) {1'b0}},
                stage2_result1[CNT_OC_WIDTH+DIM_WIDTH+1+WIN_R_WIDTH*WIN_S_WIDTH+1+1-1:0]
            };
        end
    endgenerate


endmodule
