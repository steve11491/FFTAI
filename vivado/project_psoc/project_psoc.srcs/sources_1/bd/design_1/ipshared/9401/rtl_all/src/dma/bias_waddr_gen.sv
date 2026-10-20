

module bias_waddr_gen #(
    parameter DIM_WIDTH = 10,
    parameter OMAP_RAM_ADDR_WIDTH = 10
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire bias_mode_external,
    input wire [DIM_WIDTH-1:0] cnt_dim_ow,
    input wire [DIM_WIDTH-1:0] cnt_dim_oc,
    input wire [DIM_WIDTH-1:0] cnt_dim_oh,
    input wire [DIM_WIDTH+1-1:0] block_len_ow_add1,
    input wire [(DIM_WIDTH+1)*2-1:0] block_len_owh_add1,
    output reg [OMAP_RAM_ADDR_WIDTH-1:0] bias_waddr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         bias_waddr <= 0;
    //     end else if (en_true & cnt_L_end) begin
    //         if (bias_mode_external == 1'b1) begin
    //             bias_waddr <= cnt_dim_oc * (block_len_ow + 1) *(block_len_oh + 1)
    //                         + cnt_dim_oh * (block_len_ow + 1) + cnt_dim_ow;
    //         end else begin
    //             bias_waddr <= cnt_dim_oc;
    //         end

    //             bias_waddr <= cnt_dim_oc * (block_len_ow + 1) *(block_len_oh + 1)
    //                         + cnt_dim_oh * (block_len_ow + 1) + cnt_dim_ow;// 2024.7.1 fix 读写地址冲突


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

            stage0_result1 <= cnt_dim_oh * block_len_ow_add1;
            stage0_result2 <= cnt_dim_oc * block_len_owh_add1;
            stage0_result3 <= cnt_dim_ow;
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
        if ((DIM_WIDTH) * 3 + 3 > OMAP_RAM_ADDR_WIDTH) begin
            assign bias_waddr = stage1_result1[OMAP_RAM_ADDR_WIDTH+3-1:0];
        end else begin
            assign bias_waddr = {
                {(OMAP_RAM_ADDR_WIDTH - ((DIM_WIDTH) * 3 + 3)) {1'b0}},
                stage1_result1[(DIM_WIDTH)*3+3-1:0]
            };
        end
    endgenerate


endmodule
