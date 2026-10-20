

module omap_raddr_gen #(
    parameter DIM_WIDTH = 10,
    parameter OMAP_RAM_ADDR_WIDTH = 10
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [DIM_WIDTH-1:0] cnt_dim_ow,
    input wire [DIM_WIDTH-1:0] cnt_dim_oc,
    input wire [DIM_WIDTH-1:0] cnt_dim_oh,
    input wire [DIM_WIDTH+1-1:0] block_len_ow_add1,
    input wire [(DIM_WIDTH+1)*2-1:0] block_len_owh_add1,
    output reg [OMAP_RAM_ADDR_WIDTH-1:0] omap_raddr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         omap_raddr <= 0;
    //     end else if (ren_flag_rise_pulse) begin
    //         omap_raddr <= cnt_dim_oc * (block_len_ow + 1) * (block_len_oh + 1)
    //                         + cnt_dim_oh * (block_len_ow + 1) + cnt_dim_ow;
    //     end
    // end

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         omap_ren <= 0;
    //     end else if (ren_flag_rise_pulse) begin
    //         omap_ren <= omap_ren_w;
    //     end else begin
    //         omap_ren <= 0;
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
            assign omap_raddr = stage1_result1[OMAP_RAM_ADDR_WIDTH-1:0];
        end else begin
            assign omap_raddr = {
                {(OMAP_RAM_ADDR_WIDTH - ((DIM_WIDTH) * 3 + 3)) {1'b0}},
                stage1_result1[(DIM_WIDTH)*3+3-1:0]
            };
        end
    endgenerate


endmodule
