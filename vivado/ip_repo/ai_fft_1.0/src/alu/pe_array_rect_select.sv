



module pe_array_rect_select #(
    parameter WIDTH = 16,
    parameter GEMM_MAC_ROW_NUM = 16,
    parameter GEMM_MAC_COL_NUM = 16,
    parameter DW_CONV_WIN_SIZE = 3 * 3,
    parameter DUAL_MAC_ROW_NUM = GEMM_MAC_ROW_NUM / 2,
    parameter DUAL_MAC_COL_NUM = GEMM_MAC_COL_NUM / 2,
    parameter FFT_BUTTER_ROW_NUM = 4,
    parameter FFT_BUTTER_COL_NUM = DUAL_MAC_ROW_NUM * DUAL_MAC_COL_NUM / FFT_BUTTER_ROW_NUM,
    parameter ZERO_POINT = 16,

    parameter INPUTS_NUM = DUAL_MAC_ROW_NUM,
    parameter OUTPUT_NUM = DUAL_MAC_ROW_NUM * 2,
    parameter STAGES_NUM = $clog2(DUAL_MAC_ROW_NUM),
    parameter ODATA_WIDTH = WIDTH * 2 + 2 + STAGES_NUM * 2,
    parameter CAL_DELAY_M = $clog2(GEMM_MAC_ROW_NUM)  //计算阵列的延迟
) (
    input wire clk,
    input wire rstn,
    input wire is_fft,
    input wire is_int16,
    input wire is_padding,
    input wire [ZERO_POINT-1:0] zero_point_in,
    input wire [GEMM_MAC_COL_NUM-1:0] mat_col_enable_mask,
    input wire [GEMM_MAC_ROW_NUM-1:0] mat_row_enable_mask,
    input wire [WIDTH-1:0] mat_data_in[GEMM_MAC_ROW_NUM-1:0],
    input wire  [WIDTH-1:0] mat_weight_in[GEMM_MAC_ROW_NUM-1:0][GEMM_MAC_COL_NUM-1:0],//一次写入一行weight
    output logic [ODATA_WIDTH-1:0] mat_data_out[GEMM_MAC_COL_NUM-1:0],
    output logic [GEMM_MAC_COL_NUM-1:0] mat_out_valid,

    input wire [FFT_BUTTER_COL_NUM-1:0] fft_in_valid[FFT_BUTTER_ROW_NUM-1:0],
    input wire [WIDTH-1:0] X2r[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    input wire [WIDTH-1:0] X2i[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    input wire [WIDTH-1:0] Wr[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    input wire [WIDTH-1:0] Wi[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    input wire [WIDTH-1:0] X1r[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    input wire [WIDTH-1:0] X1i[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],


    output logic [ODATA_WIDTH-1:0] fft_out1_r[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    output logic [ODATA_WIDTH-1:0] fft_out1_i[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    output logic [ODATA_WIDTH-1:0] fft_out2_r[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    output logic [ODATA_WIDTH-1:0] fft_out2_i[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0],
    output logic fft_out_valid[FFT_BUTTER_ROW_NUM-1:0][FFT_BUTTER_COL_NUM-1:0]
);

    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
        end else begin
            is_int16_reg <= is_int16;
        end
    end
    // for debug

    logic [WIDTH/2-1:0] mat_data_in_int8[GEMM_MAC_ROW_NUM-1:0];
    logic [WIDTH/2-1:0] mat_weight_in_int8[GEMM_MAC_ROW_NUM-1:0][GEMM_MAC_COL_NUM*2-1:0];
    logic [ODATA_WIDTH/2-1:0] mat_data_out_int8[GEMM_MAC_COL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < GEMM_MAC_ROW_NUM; i = i + 1) begin
            assign mat_data_in_int8[i] = mat_data_in[i][WIDTH/2-1:0];
        end
        for (genvar row = 0; row < GEMM_MAC_ROW_NUM; row = row + 1) begin
            for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
                assign {mat_weight_in_int8[row][i*2+1],mat_weight_in_int8[row][i*2]} = mat_weight_in[row][i];
            end
        end
        for (genvar i = 0; i < GEMM_MAC_COL_NUM; i = i + 1) begin
            assign {mat_data_out_int8[i*2+1], mat_data_out_int8[i*2]} = mat_data_out[i];
        end
    endgenerate


    // for debug

    wire signed [ZERO_POINT-1:0] zero_point_in_signed;

    wire signed [WIDTH-1:0] mat_data_in_signed[GEMM_MAC_ROW_NUM-1:0];
    assign zero_point_in_signed = zero_point_in;
    generate
        for (genvar i = 0; i < GEMM_MAC_ROW_NUM; i = i + 1) begin
            assign mat_data_in_signed[i] = mat_data_in[i];
        end
    endgenerate



    wire [DUAL_MAC_ROW_NUM-1:0] mat_in_valid_matrix1[DUAL_MAC_COL_NUM-1:0];
    wire [DUAL_MAC_ROW_NUM-1:0] mat_in_valid_matrix2[DUAL_MAC_COL_NUM-1:0];
    wire [DUAL_MAC_ROW_NUM-1:0][1:0] in_valid[DUAL_MAC_COL_NUM-1:0];
    wire [WIDTH+1-1:0] IN1_X2r[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0];  //17
    wire [WIDTH-1:0] W11_Wr[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0];  //16
    wire [WIDTH-1:0] W22_X1r[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0];  //16
    wire [WIDTH-1:0] W21_X1i[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0];  //16
    wire [WIDTH-1:0] W12_Wi[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0];  //16
    wire [WIDTH+1-1:0] IN2_X2i[DUAL_MAC_COL_NUM-1:0][DUAL_MAC_ROW_NUM-1:0];  //17

    logic [ODATA_WIDTH-1:0] odata[DUAL_MAC_COL_NUM-1:0][1:0][OUTPUT_NUM-1:0];
    logic [DUAL_MAC_ROW_NUM-1:0] out_valid[DUAL_MAC_COL_NUM-1:0][1:0];
    wire signed [WIDTH-1+1:0] mat_data_in_add_zero_point[GEMM_MAC_ROW_NUM-1:0];

    generate
        for (genvar k = 0; k < GEMM_MAC_ROW_NUM; k = k + 1) begin
            assign mat_data_in_add_zero_point[k] = mat_data_in_signed[k] - zero_point_in_signed;
        end
    endgenerate

    genvar i, j;
    generate
        for (i = 0; i < DUAL_MAC_ROW_NUM; i = i + 1) begin
            for (j = 0; j < DUAL_MAC_COL_NUM; j = j + 1) begin
                assign mat_in_valid_matrix1[j][i] = (mat_row_enable_mask[i*2]);
                assign mat_in_valid_matrix2[j][i] = (mat_row_enable_mask[i*2+1]);
            end
        end



        for (i = 0; i < DUAL_MAC_ROW_NUM; i = i + 1) begin
            for (j = 0; j < DUAL_MAC_COL_NUM; j = j + 1) begin

                localparam i2 = i % FFT_BUTTER_ROW_NUM;
                localparam j2 = j + DUAL_MAC_COL_NUM * (i / FFT_BUTTER_ROW_NUM);

                assign in_valid[j][i][0] = is_fft ? fft_in_valid[i2][j2] : (mat_col_enable_mask[j*2]);
                assign in_valid[j][i][1] = is_fft ? fft_in_valid[i2][j2] : (mat_col_enable_mask[j*2+1]);
                assign IN1_X2r[j][i]  = is_fft ? {X2r[i2][j2][WIDTH-1],X2r[i2][j2]} : 
                                        ((mat_in_valid_matrix1[j][i] &&(~is_padding)) ? mat_data_in_add_zero_point[i*2]: {WIDTH+1{1'b0}});
                assign IN2_X2i[j][i] = is_fft ? {X2i[i2][j2][WIDTH-1],X2i[i2][j2]} : 
                                        ((mat_in_valid_matrix2[j][i]&&(~is_padding)) ? mat_data_in_add_zero_point[i*2+1] : {WIDTH+1{1'b0}});
                assign W11_Wr[j][i] = is_fft ? Wr[i2][j2] : mat_weight_in[i*2][j*2];
                assign W12_Wi[j][i] = is_fft ? Wi[i2][j2] : mat_weight_in[i*2][j*2+1];
                assign W21_X1i[j][i] = is_fft ? X1i[i2][j2] : mat_weight_in[i*2+1][j*2];
                assign W22_X1r[j][i] = is_fft ? X1r[i2][j2] : mat_weight_in[i*2+1][j*2+1];


            end
        end

    endgenerate

    wire [GEMM_MAC_COL_NUM-1:0] mat_col_enable_mask_delay;
    dq_dff #(
        .N (CAL_DELAY_M),
        .DW(GEMM_MAC_COL_NUM)
    ) u_mat_col_enable_mask_delay (
        .clk (clk),
        .rstn(rstn),
        .d   (mat_col_enable_mask),

        .q(mat_col_enable_mask_delay)
    );

    generate
        for (i = 0; i < DUAL_MAC_COL_NUM; i = i + 1) begin
            assign mat_data_out[i*2] = odata[i][0][INPUTS_NUM/2-1+INPUTS_NUM];
            assign mat_data_out[i*2+1] = odata[i][1][INPUTS_NUM/2-1+INPUTS_NUM];
            assign mat_out_valid[i*2] = (~is_fft) & (out_valid[i][0][INPUTS_NUM/2-1])&mat_col_enable_mask_delay[i*2];
            assign mat_out_valid[i*2+1] = (~is_fft) & (out_valid[i][1][INPUTS_NUM/2-1])&mat_col_enable_mask_delay[i*2+1];
        end
    endgenerate

    generate
        for (i = 0; i < FFT_BUTTER_ROW_NUM; i = i + 1) begin
            for (j = 0; j < FFT_BUTTER_COL_NUM; j = j + 1) begin
                localparam i1 = i + FFT_BUTTER_ROW_NUM * (j / DUAL_MAC_COL_NUM);
                localparam j1 = j % DUAL_MAC_COL_NUM;
                assign fft_out1_r[i][j] = odata[j1][0][i1];
                assign fft_out1_i[i][j] = odata[j1][1][i1];
                assign fft_out2_r[i][j] = odata[j1][0][i1+DUAL_MAC_ROW_NUM];
                assign fft_out2_i[i][j] = odata[j1][1][i1+DUAL_MAC_ROW_NUM];
                assign fft_out_valid[i][j] = is_fft & out_valid[j1][0][i1] & out_valid[j1][1][i1];
            end
        end
    endgenerate
    // WARNING: [VRFC 10-3705] select index 1 into 'fft_in_valid' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:235]
    // WARNING: [VRFC 10-3705] select index 1 into 'fft_in_valid' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:236]
    // WARNING: [VRFC 10-3705] select index 1 into 'X2r' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:237]
    // WARNING: [VRFC 10-3705] select index 1 into 'X2i' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:238]
    // WARNING: [VRFC 10-3705] select index 1 into 'Wr' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:239]
    // WARNING: [VRFC 10-3705] select index 1 into 'Wi' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:240]
    // WARNING: [VRFC 10-3705] select index 1 into 'X1i' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:241]
    // WARNING: [VRFC 10-3705] select index 1 into 'X1r' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:242]
    // WARNING: [VRFC 10-3705] select index 4 into 'odata' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:278]
    // WARNING: [VRFC 10-3705] select index 4 into 'odata' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:279]
    // WARNING: [VRFC 10-3705] select index 2 into 'out_valid' is out of bounds [D:/code/test/verilog/ai_engine/ai_engine/rtl/src/alu/pe_array_rect_select.sv:280]


    pe_array_rect #(
        .WIDTH           (WIDTH),
        .DUAL_MAC_ROW_NUM(DUAL_MAC_ROW_NUM),
        .DUAL_MAC_COL_NUM(DUAL_MAC_COL_NUM),
        .INPUTS_NUM      (INPUTS_NUM),
        .OUTPUT_NUM      (OUTPUT_NUM),
        .STAGES_NUM      (STAGES_NUM),
        .ODATA_WIDTH     (ODATA_WIDTH)
    ) u_pe_array_rect (
        .clk      (clk),
        .rstn     (rstn),
        .in_valid (in_valid),
        .is_fft   (is_fft),
        .is_int16 (is_int16_reg),
        .IN1_X2r  (IN1_X2r),
        .W11_Wr   (W11_Wr),
        .W22_X1r  (W22_X1r),
        .W21_X1i  (W21_X1i),
        .W12_Wi   (W12_Wi),
        .IN2_X2i  (IN2_X2i),
        .odata    (odata),
        .out_valid(out_valid)
    );




endmodule
