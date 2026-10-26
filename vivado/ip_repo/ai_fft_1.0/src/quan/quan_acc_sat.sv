
// acc的40位输出截断为32位
module quan_acc_sat #(
    parameter ACC_OUT_WIDTH = 40,
    parameter QUAN_IN_WIDTH = 32
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire [ACC_OUT_WIDTH-1:0] acc_out,
    output logic [QUAN_IN_WIDTH-1:0] quan_in,
    output logic quan_in_valid
);
    // for debug
    wire [ACC_OUT_WIDTH/2-1:0] acc_out_int8[1:0];
    wire [QUAN_IN_WIDTH/2-1:0] quan_in_int8[1:0];


    assign {acc_out_int8[1], acc_out_int8[0]} = acc_out[ACC_OUT_WIDTH-1:0];
    assign {quan_in_int8[1], quan_in_int8[0]} = quan_in[QUAN_IN_WIDTH-1:0];

    // for debug

    split_dat_sat #(
        .DIN_WIDTH (ACC_OUT_WIDTH),
        .DOUT_WIDTH(QUAN_IN_WIDTH)
    ) u_split_quan_acc_sat (
        .clk(clk),
        .rstn(rstn),
        .is_int16(is_int16),
        .in_valid(in_valid),
        .din(acc_out),
        .dout(quan_in),
        .out_valid(quan_in_valid)
    );


endmodule
