module single_channel_acc #(
    parameter ACC_WIDTH = 40
) (
    input  wire                 clk,
    input  wire                 rstn,
    input  wire                 in_valid,
    input  wire                 is_int16,
    input  wire [ACC_WIDTH-1:0] acc_in1,
    input  wire [ACC_WIDTH-1:0] acc_in2,
    output wire [ACC_WIDTH-1:0] acc_out,
    output wire                 acc_out_valid
);

    wire [ACC_WIDTH-1:0] acc_out_w;
    wire                 acc_out_valid_w;




    split_add_equal_width #(
        .LS_WIDTH(ACC_WIDTH / 2),
        .MS_WIDTH(ACC_WIDTH / 2),
        .WIDTH(ACC_WIDTH)
    ) split_add (
        .clk      (clk),
        .rstn     (rstn),
        .is_int16 (is_int16),
        .in_valid (in_valid),
        .in1      (acc_in1),
        .in2      (acc_in2),
        .out      (acc_out_w),
        .out_valid(acc_out_valid_w)
    );
    assign acc_out = acc_out_w;
    assign acc_out_valid = acc_out_valid_w;






endmodule
