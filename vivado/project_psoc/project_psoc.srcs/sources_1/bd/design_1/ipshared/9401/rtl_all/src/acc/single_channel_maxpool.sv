module single_channel_maxpool #(
    parameter MAX_WIDTH = 16
) (
    input  wire                 clk,
    input  wire                 rstn,
    input  wire                 in_valid,
    input  wire                 is_int16,
    input  wire [MAX_WIDTH-1:0] max_in1,
    input  wire [MAX_WIDTH-1:0] max_in2,
    output wire [MAX_WIDTH-1:0] max_out,
    output wire                 max_out_valid
);


    wire [MAX_WIDTH-1:0] max_out_w;
    wire                 max_out_valid_w;



    wire [MAX_WIDTH-1:0] max_in          [1:0];
    assign max_in[0] = max_in1;
    assign max_in[1] = max_in2;

    split_compare_tree_signed #(
        .MODE      ("MAX"),
        .INPUTS_NUM(2),
        .WIDTH     (MAX_WIDTH)
    ) u_split_compare_tree_signed (
        .clk      (clk),
        .rstn     (rstn),
        .is_int16 (is_int16),
        .in_valid (in_valid),
        .idata    (max_in),
        .odata    (max_out_w),
        .out_valid(max_out_valid_w)
    );
    assign max_out = max_out_w;
    assign max_out_valid = max_out_valid_w;






endmodule
