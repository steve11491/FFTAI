


module L1_bias_raddr_gen #(
    parameter OMAP_RAM_ADDR_WIDTH = 12,
    parameter DIM_WIDTH = 8,
    parameter CNT_OC_WIDTH = 6
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire bias_mode_internal,
    input wire [CNT_OC_WIDTH-1:0] cnt_ri_block_len_oc_fea,
    input wire [DIM_WIDTH*2-1:0] cnt_ri_block_len_owh,

    input wire [DIM_WIDTH*2-1:0] block_len_owh,

    output reg [OMAP_RAM_ADDR_WIDTH-1:0] bias_acci_addr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         bias_acci_addr <= 0;
    //     end else if (use_bias_internal & is_pe_array_busy) begin
    //         if (is_cnt_ri_block_len_rs_ic_fea_start) begin
    // bias_acci_addr <= cnt_ri_block_len_oc_fea * ( (block_len_owh + 1)) 
    //                                 + ( (bias_mode_internal == 0) ? 0 :cnt_ri_block_len_owh);// 2021.7.1 fix:地址读写冲突
    //         end
    //     end else begin
    //         bias_acci_addr <= 0;
    //     end
    // end

    // Stage 0 
    reg [CNT_OC_WIDTH-1:0] stage0_result1;
    reg [DIM_WIDTH*2+1-1:0] stage0_result2;
    reg [DIM_WIDTH*2-1:0] stage0_result3;
    reg en_ff;
    reg en_ff2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage0_result1 <= 0;
            stage0_result2 <= 0;
            stage0_result3 <= 0;
        end else if (en) begin
            stage0_result1 <= cnt_ri_block_len_oc_fea;
            stage0_result2 <= (block_len_owh + 1);
            stage0_result3 <= ((bias_mode_internal == 0) ? 0 : cnt_ri_block_len_owh);
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
    reg [CNT_OC_WIDTH+DIM_WIDTH*2+1-1:0] stage1_result1;
    reg [DIM_WIDTH*2-1:0] stage1_result2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage1_result1 <= 0;
            stage1_result2 <= 0;
        end else if (en_ff) begin
            stage1_result1 <= stage0_result1 * stage0_result2;
            stage1_result2 <= stage0_result3;

        end
    end
    // Stage 2 
    reg [CNT_OC_WIDTH+DIM_WIDTH*2+1-1:0] stage2_result1;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage2_result1 <= 0;
        end else if (en_ff2) begin
            stage2_result1 <= stage1_result1 + stage1_result2;

        end
    end


    generate
        if (CNT_OC_WIDTH + DIM_WIDTH * 2 + 1 > OMAP_RAM_ADDR_WIDTH) begin
            assign bias_acci_addr = stage2_result1[OMAP_RAM_ADDR_WIDTH-1:0];
        end else begin
            assign bias_acci_addr = {
                {(OMAP_RAM_ADDR_WIDTH - (CNT_OC_WIDTH + DIM_WIDTH * 2 + 1)) {1'b0}},
                stage2_result1[CNT_OC_WIDTH+DIM_WIDTH*2+1-1:0]
            };
        end
    endgenerate


endmodule
