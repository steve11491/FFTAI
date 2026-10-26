module pe_array_col #(
    parameter WIDTH = 16,
    parameter DUAL_MAC_ROW_NUM = 4,
    parameter INPUTS_NUM = DUAL_MAC_ROW_NUM,
    parameter OUTPUT_NUM = DUAL_MAC_ROW_NUM * 2,
    parameter STAGES_NUM = $clog2(DUAL_MAC_ROW_NUM),
    parameter ODATA_WIDTH = WIDTH * 2 + 2 + STAGES_NUM * 2
) (
    input wire clk,
    input wire rstn,
    input wire [INPUTS_NUM-1:0][1:0] in_valid,
    input wire is_fft,
    input wire is_int16,
    input wire [WIDTH+1-1:0] IN1_X2r[DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1:0] W11_Wr[DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1:0] W22_X1r[DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1:0] W21_X1i[DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH-1:0] W12_Wi[DUAL_MAC_ROW_NUM-1:0],  //16
    input wire [WIDTH+1-1:0] IN2_X2i[DUAL_MAC_ROW_NUM-1:0],  //16
    output logic [ODATA_WIDTH-1:0] odata[1:0][OUTPUT_NUM-1:0],
    output logic [INPUTS_NUM-1:0] out_valid[1:0]
);
    genvar i;

    // for debug
    wire [8-1:0] W11_int8[DUAL_MAC_ROW_NUM-1:0];  //8
    wire [8-1:0] W12_int8[DUAL_MAC_ROW_NUM-1:0];  //8
    wire [8-1:0] W13_int8[DUAL_MAC_ROW_NUM-1:0];  //8
    wire [8-1:0] W14_int8[DUAL_MAC_ROW_NUM-1:0];  //8
    wire [8-1:0] W21_int8[DUAL_MAC_ROW_NUM-1:0];  //8
    wire [8-1:0] W22_int8[DUAL_MAC_ROW_NUM-1:0];  //8
    wire [8-1:0] W23_int8[DUAL_MAC_ROW_NUM-1:0];  //8
    wire [8-1:0] W24_int8[DUAL_MAC_ROW_NUM-1:0];  //8
    generate
        for (i = 0; i < DUAL_MAC_ROW_NUM; i = i + 1) begin
            assign W11_int8[i] = W11_Wr[i][8-1:0];
            assign W12_int8[i] = W11_Wr[i][16-1:8];
            assign W13_int8[i] = W12_Wi[i][8-1:0];
            assign W14_int8[i] = W12_Wi[i][16-1:8];

            assign W21_int8[i] = W21_X1i[i][8-1:0];
            assign W22_int8[i] = W21_X1i[i][16-1:8];
            assign W23_int8[i] = W22_X1r[i][8-1:0];
            assign W24_int8[i] = W22_X1r[i][16-1:8];
        end
    endgenerate




    // 左右两个加法树，左边是虚部，编号为1，右边是实部，编号为0

    parameter IDATA_WIDTH = WIDTH * 2 + 2;
    logic [IDATA_WIDTH-1:0] X1r_d[DUAL_MAC_ROW_NUM-1:0];  //34
    logic [IDATA_WIDTH-1:0] O1_Or[DUAL_MAC_ROW_NUM-1:0];  //34
    logic [IDATA_WIDTH-1:0] O2_Oi[DUAL_MAC_ROW_NUM-1:0];  //34
    logic [IDATA_WIDTH-1:0] X1i_d[DUAL_MAC_ROW_NUM-1:0];  //34
    logic [DUAL_MAC_ROW_NUM-1:0][1:0] dual_mac_out_valid;



    wire [IDATA_WIDTH-1:0] mat_din[1:0][INPUTS_NUM-1:0];
    wire [IDATA_WIDTH-1:0] fft_din[1:0][INPUTS_NUM-1:0];

    generate
        for (i = 0; i < DUAL_MAC_ROW_NUM; i = i + 1) begin : dual_mac
            dual_mac #(
                .WIDTH(WIDTH)
            ) u_dual_mac (
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
                .X1r_d    (X1r_d[i]),
                .O1_Or    (O1_Or[i]),
                .O2_Oi    (O2_Oi[i]),
                .X1i_d    (X1i_d[i]),
                .out_valid(dual_mac_out_valid[i])
            );
            assign mat_din[0][i] = O1_Or[i];
            assign mat_din[1][i] = O2_Oi[i];
            assign fft_din[0][i] = X1r_d[i];
            assign fft_din[1][i] = X1i_d[i];
        end
    endgenerate
    wire [INPUTS_NUM-1:0][1:0] add_sub_array_tree_in_valid_w;

    assign add_sub_array_tree_in_valid_w = dual_mac_out_valid;

    wire [INPUTS_NUM-1:0] add_sub_array_tree_in_valid[1:0];
    generate
        for (i = 0; i < 2; i = i + 1) begin
            for (genvar j = 0; j < INPUTS_NUM; j = j + 1) begin
                assign add_sub_array_tree_in_valid[i][j] = add_sub_array_tree_in_valid_w[j][i];
            end
        end
    endgenerate

    generate
        for (i = 0; i < 2; i = i + 1) begin : add_sub_array_tree
            add_sub_array_tree #(
                .INPUTS_NUM (INPUTS_NUM),
                .OUTPUT_NUM (OUTPUT_NUM),
                .IDATA_WIDTH(IDATA_WIDTH),
                .STAGES_NUM (STAGES_NUM),
                .ODATA_WIDTH(ODATA_WIDTH)
            ) u_add_sub_array_tree (
                .clk      (clk),
                .rstn     (rstn),
                .is_fft   (is_fft),
                .is_int16 (is_int16),
                .in_valid (add_sub_array_tree_in_valid[i]),
                .mat_din  (mat_din[i]),
                .fft_din  (fft_din[i]),
                .odata    (odata[i]),
                .out_valid(out_valid[i])
            );
        end
    endgenerate








endmodule
