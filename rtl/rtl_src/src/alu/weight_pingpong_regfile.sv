module weight_pingpong_regfile #(
    parameter WIDTH = 16,
    parameter GEMM_MAC_ROW_NUM = 16,
    parameter GEMM_MAC_COL_NUM = 16,
    parameter SEL_WIDTH = $clog2(GEMM_MAC_ROW_NUM)
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire pingpong,
    input wire is_dwc,
    input wire [GEMM_MAC_COL_NUM-1:0] mat_col_in_valid,
    input wire [SEL_WIDTH-1:0] mat_weight_in_row_sel,
    input wire [WIDTH-1:0] mat_weight_in[GEMM_MAC_COL_NUM-1:0],
    output logic [WIDTH-1:0] mat_weight_reg[GEMM_MAC_ROW_NUM-1:0][GEMM_MAC_COL_NUM-1:0]
);


    reg [WIDTH-1:0] weight_pingpong_reg[1:0][GEMM_MAC_ROW_NUM-1:0][GEMM_MAC_COL_NUM-1:0];


    // for debug
    reg [8-1:0] mat_weight_reg_int8[GEMM_MAC_ROW_NUM-1:0][GEMM_MAC_COL_NUM*2-1:0];
    reg [8-1:0] weight_pingpong_reg_int8[1:0][GEMM_MAC_ROW_NUM-1:0][GEMM_MAC_COL_NUM*2-1:0];
    generate
        for (genvar pp = 0; pp < 2; pp = pp + 1) begin
            for (genvar row = 0; row < GEMM_MAC_ROW_NUM; row = row + 1) begin
                for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                    assign {weight_pingpong_reg_int8[pp][row][i*2+1],weight_pingpong_reg_int8[pp][row][i*2]} = weight_pingpong_reg[pp][row][i];
                end
            end
        end
        for (genvar row = 0; row < GEMM_MAC_ROW_NUM; row = row + 1) begin
            for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                assign {mat_weight_reg_int8[row][i*2+1],mat_weight_reg_int8[row][i*2]} = mat_weight_reg[row][i];
            end
        end
    endgenerate



    // for debug

    genvar i;
    generate
        for (i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            always @(posedge clk or negedge rstn) begin
                if (~rstn) begin
                    for (int pp = 0; pp < 2; pp = pp + 1) begin
                        for (int row = 0; row < GEMM_MAC_ROW_NUM; row = row + 1) begin
                            weight_pingpong_reg[pp][row][i] <= 0;
                        end
                    end
                end 
                // else if (is_group_conv) begin
                //     if (mat_col_in_valid[i]) begin
                //         weight_pingpong_reg[pingpong][mat_weight_in_row_sel][i] <= mat_weight_in[i];
                //     end else begin
                //         weight_pingpong_reg[pingpong][mat_weight_in_row_sel][i] <= 0;
                //     end
                // end 
                else begin
                    if (mat_col_in_valid[i]) begin
                        weight_pingpong_reg[pingpong][mat_weight_in_row_sel][i] <= mat_weight_in[i];
                    end
                end
            end
        end
    endgenerate

    assign mat_weight_reg = is_dwc ? weight_pingpong_reg[pingpong]:weight_pingpong_reg[~pingpong];



endmodule
