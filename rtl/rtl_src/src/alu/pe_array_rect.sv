module pe_array_rect #(
    parameter WIDTH = 16,
    parameter DUAL_MAC_ROW_NUM = 4,
    parameter DUAL_MAC_COL_NUM = 16,
    parameter INPUTS_NUM = DUAL_MAC_ROW_NUM,
    parameter OUTPUT_NUM = DUAL_MAC_ROW_NUM * 2,
    parameter STAGES_NUM = $clog2(DUAL_MAC_ROW_NUM),
    parameter ODATA_WIDTH = WIDTH * 2 + 2 + STAGES_NUM * 2
) (
    input wire clk,
    input wire rstn,
    input wire [DUAL_MAC_ROW_NUM-1:0][1:0] in_valid[DUAL_MAC_COL_NUM-1:0],
    input wire is_fft,
    input wire is_int16,
    input wire [WIDTH-1+1:0] IN1_X2r[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1:0] W11_Wr[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1:0] W22_X1r[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1:0] W21_X1i[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1:0] W12_Wi[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1+1:0] IN2_X2i[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0],  //16
    output logic [ODATA_WIDTH-1:0] odata[DUAL_MAC_COL_NUM-1:0][1:0][OUTPUT_NUM-1:0],
    output logic [DUAL_MAC_ROW_NUM-1:0] out_valid[DUAL_MAC_COL_NUM-1:0][1:0]
);
    genvar i, j;
    // wire [DUAL_MAC_ROW_NUM-1:0] in_valid_w[DUAL_MAC_COL_NUM-1:0];
    // generate
    //     for (i = 0; i < DUAL_MAC_ROW_NUM; i = i + 1) begin
    //         for (j = 0; j < DUAL_MAC_COL_NUM; j = j + 1) begin
    //             assign in_valid_w[j][i] = in_valid[j][i];
    //         end
    //     end

    // endgenerate

    generate
        for (i = 0; i < DUAL_MAC_COL_NUM; i = i + 1) begin : pe_array_col
            pe_array_col #(
                .WIDTH           (WIDTH),
                .DUAL_MAC_ROW_NUM(DUAL_MAC_ROW_NUM),
                .INPUTS_NUM      (INPUTS_NUM),
                .OUTPUT_NUM      (OUTPUT_NUM),
                .STAGES_NUM      (STAGES_NUM),
                .ODATA_WIDTH     (ODATA_WIDTH)
            ) u_pe_array_col (
                .clk      (clk),
                .rstn     (rstn),
                .in_valid (in_valid[i]),
                .is_fft   (is_fft),
                .is_int16 (is_int16),
                .IN1_X2r  (IN1_X2r[i]),
                .W11_Wr   (W11_Wr[i]),
                .W22_X1r  (W22_X1r[i]),
                .W21_X1i  (W21_X1i[i]),
                .W12_Wi   (W12_Wi[i]),
                .IN2_X2i  (IN2_X2i[i]),
                .odata    (odata[i]),
                .out_valid(out_valid[i])
            );
        end
    endgenerate



endmodule
