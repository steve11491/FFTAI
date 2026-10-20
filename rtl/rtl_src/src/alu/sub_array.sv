module sub_array #(
    parameter INPUTS_NUM  = 8,
    parameter IDATA_WIDTH = 34,
    parameter ODATA_WIDTH = IDATA_WIDTH + 2
) (
    input clk,
    input rstn,
    input wire is_fft,
    input wire is_int16,
    input wire [INPUTS_NUM-1:0] in_valid,
    input wire [IDATA_WIDTH-1:0] mat_din[INPUTS_NUM-1:0],
    input wire [IDATA_WIDTH-1:0] fft_din[INPUTS_NUM-1:0],
    output logic [ODATA_WIDTH-1:0] odata[INPUTS_NUM-1:0],
    output logic [INPUTS_NUM-1:0] out_valid
);
    parameter LS_WIDTH = IDATA_WIDTH / 2;
    parameter MS_WIDTH = IDATA_WIDTH / 2;
    wire is_fft_true;
    assign is_fft_true = is_int16 & is_fft;
    genvar i;
    logic signed [ODATA_WIDTH-1:0] odata_signed[INPUTS_NUM-1:0];
    reg [INPUTS_NUM-1:0] sub_out_valid;
    generate
        for (i = 0; i < INPUTS_NUM; i = i + 1) begin : butterfly_sub
            // split_addsub #(
            //     .LS_WIDTH(LS_WIDTH),
            //     .MS_WIDTH(MS_WIDTH),
            //     .WIDTH(LS_WIDTH + MS_WIDTH)
            // ) split_sub (
            //     .clk      (clk),
            //     .rstn     (rstn),
            //     .bypass   (1'b0),
            //     .is_sub   (1'b1),
            //     .is_int16 (1'b1),
            //     .in_valid (in_valid[i] & is_fft_true),
            //     .in1      (fft_din[i]),
            //     .in2      (mat_din[i]),
            //     .out      (odata[i]),
            //     .out_valid(sub_out_valid[i])
            // );
            always @(posedge clk) begin
                if (in_valid[i] & is_fft_true) begin
                    odata[i] <= $signed(fft_din[i]) - $signed(mat_din[i]);
                end
            end
            always @(posedge clk or negedge rstn) begin
                if (~rstn) begin
                    sub_out_valid[i] <= 0;
                end else begin
                    sub_out_valid[i] <= (in_valid[i] & is_fft_true);
                end
            end

        end
    endgenerate

    // assign odata = odata_signed;
    assign out_valid = sub_out_valid;

endmodule
