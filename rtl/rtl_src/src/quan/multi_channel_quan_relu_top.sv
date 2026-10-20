module multi_channel_quan_relu_top #(
    parameter CHANNEL_NUM = 16,
    parameter ACC_OUT_WIDTH = 40,
    parameter QUAN_IN_WIDTH = 32,
    parameter QUAN_OUT_WIDTH = 16,
    parameter SCALE_WIDTH = 16,
    parameter SHIFT_WIDTH = 4,
    parameter ZERO_POINT_WIDTH = 16
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire quan_enable,
    input wire relu_enable,
    input wire [ZERO_POINT_WIDTH-1:0] zero_point_out,
    input wire [CHANNEL_NUM-1:0] quan_relu_enable_mask,
    input wire [CHANNEL_NUM-1:0] in_valid,
    input wire [ACC_OUT_WIDTH-1:0] acc_out[CHANNEL_NUM-1:0],
    input wire [SCALE_WIDTH-1:0] scale,
    input wire [SHIFT_WIDTH-1:0] shift,
    output wire [QUAN_OUT_WIDTH+4-1:0] quan_relu_out[CHANNEL_NUM-1:0],
    output wire [CHANNEL_NUM-1:0] quan_relu_out_valid
);

    // for debug
    wire [ACC_OUT_WIDTH/2-1:0] quan_in_int8[CHANNEL_NUM*2-1:0];
    wire [(QUAN_OUT_WIDTH+4)/2-1:0] quan_out_int8[CHANNEL_NUM*2-1:0];

    genvar ii;
    generate
        for (ii = 0; ii < CHANNEL_NUM; ii = ii + 1) begin
            assign {quan_in_int8[ii*2+1], quan_in_int8[ii*2]}   = acc_out[ii];
            assign {quan_out_int8[ii*2+1], quan_out_int8[ii*2]} = quan_relu_out[ii];
        end
    endgenerate
    // for debug

    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
        end else begin
            is_int16_reg <= is_int16;
        end
    end

    wire [CHANNEL_NUM-1:0] in_valid_true;
    assign in_valid_true = in_valid & quan_relu_enable_mask;
    genvar i;
    generate
        for (i = 0; i < CHANNEL_NUM; i = i + 1) begin : quan_sat_relu
            quan_sat_relu #(
                .ACC_OUT_WIDTH (ACC_OUT_WIDTH),
                .QUAN_IN_WIDTH (QUAN_IN_WIDTH),
                .QUAN_OUT_WIDTH(QUAN_OUT_WIDTH),
                .SCALE_WIDTH   (SCALE_WIDTH),
                .SHIFT_WIDTH   (SHIFT_WIDTH),
                .ZERO_POINT_WIDTH(ZERO_POINT_WIDTH)
            ) u_quan_sat_relu (
                .clk                (clk),
                .rstn               (rstn),
                .is_int16           (is_int16_reg),
                .quan_enable        (quan_enable),
                .relu_enable        (relu_enable),
                .zero_point         (zero_point_out),
                .in_valid           (in_valid_true[i]),
                .acc_out            (acc_out[i]),
                .scale              (scale),
                .shift              (shift),
                .quan_relu_out      (quan_relu_out[i]),
                .quan_relu_out_valid(quan_relu_out_valid[i])
            );
        end


    endgenerate


endmodule
