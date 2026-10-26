module add_sub_array_tree #(
    parameter INPUTS_NUM  = 8,
    parameter OUTPUT_NUM  = INPUTS_NUM * 2,
    parameter IDATA_WIDTH = 34,

    parameter STAGES_NUM  = $clog2(INPUTS_NUM),
    parameter ODATA_WIDTH = IDATA_WIDTH + STAGES_NUM * 2
) (
    input clk,
    input rstn,
    input wire is_fft,
    input wire is_int16,
    input wire [INPUTS_NUM-1:0] in_valid,
    input wire [IDATA_WIDTH-1:0] mat_din[INPUTS_NUM-1:0],
    input wire [IDATA_WIDTH-1:0] fft_din[INPUTS_NUM-1:0],
    output logic [ODATA_WIDTH-1:0] odata[OUTPUT_NUM-1:0],
    output logic [INPUTS_NUM-1:0] out_valid
);
    logic [ODATA_WIDTH-1:0] add_array_tree_odata[INPUTS_NUM-1:0];
    logic [INPUTS_NUM-1:0] add_array_tree_odata_valid;
    add_array_tree #(
        .INPUTS_NUM (INPUTS_NUM),
        .IDATA_WIDTH(IDATA_WIDTH),
        .STAGES_NUM (STAGES_NUM),
        .ODATA_WIDTH(ODATA_WIDTH)
    ) u_add_array_tree (
        .clk      (clk),
        .rstn     (rstn),
        .is_fft   (is_fft),
        .is_int16 (is_int16),
        .in_valid (in_valid),
        .mat_din  (mat_din),
        .fft_din  (fft_din),
        .odata    (add_array_tree_odata),
        .out_valid(add_array_tree_odata_valid)
    );

    localparam SUB_OUT_WIDTH = IDATA_WIDTH + 2;
    logic [SUB_OUT_WIDTH-1:0] sub_array_odata[INPUTS_NUM-1:0];
    logic [ODATA_WIDTH-1:0] sub_array_odata_sign_exp[INPUTS_NUM-1:0];
    logic [INPUTS_NUM-1:0] sub_array_odata_valid;
    sub_array #(
        .INPUTS_NUM (INPUTS_NUM),
        .IDATA_WIDTH(IDATA_WIDTH),
        .ODATA_WIDTH(SUB_OUT_WIDTH)
    ) u_sub_array (
        .clk      (clk),
        .rstn     (rstn),
        .is_fft   (is_fft),
        .is_int16 (is_int16),
        .in_valid (in_valid),
        .mat_din  (mat_din),
        .fft_din  (fft_din),
        .odata    (sub_array_odata),
        .out_valid(sub_array_odata_valid)
    );
    genvar i;
    generate
        for (i = 0; i < INPUTS_NUM; i = i + 1) begin
            assign sub_array_odata_sign_exp[i][ODATA_WIDTH-1:0] = {
                {(ODATA_WIDTH - SUB_OUT_WIDTH) {sub_array_odata[i][SUB_OUT_WIDTH-1]}},
                sub_array_odata[i][SUB_OUT_WIDTH-1:0]
            };
        end
    endgenerate

    assign odata[INPUTS_NUM-1:0] = sub_array_odata_sign_exp;
    assign odata[OUTPUT_NUM-1:INPUTS_NUM] = add_array_tree_odata;
    assign out_valid = is_fft?(sub_array_odata_valid&add_array_tree_odata_valid):(add_array_tree_odata_valid);

endmodule
