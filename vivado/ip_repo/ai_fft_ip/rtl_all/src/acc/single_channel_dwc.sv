module single_channel_dwc #(
    parameter WIDTH = 16
) (
    input  wire               clk,
    input  wire               rstn,
    input  wire               in_valid,
    input  wire               is_int16,
    input  wire [  WIDTH-1:0] data_in1,
    input  wire [WIDTH+2-1:0] data_in2,
    output wire [WIDTH*2-1:0] data_out,
    output wire               data_out_valid
);


    wire [WIDTH*2-1:0] data_out_w;
    wire               data_out_valid_w;



    wire [  WIDTH-1:0] data_in          [1:0];
    assign data_in[0] = data_in1;
    assign data_in[1] = data_in2;

    split_mul_true_dual_8bit u_split_mul_true_dual_8bit (
        .clk     (clk),
        .rstn    (rstn),
        .is_int16(is_int16),
        .in_valid(in_valid),
        .in1     (data_in1),
        .in2     (data_in2),

        .out      (data_out_w),
        .out_valid(data_out_valid_w)
    );
    assign data_out = data_out_w;
    assign data_out_valid = data_out_valid_w;






endmodule
