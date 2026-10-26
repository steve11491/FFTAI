module quan_sat_relu #(
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
    input wire [ZERO_POINT_WIDTH-1:0] zero_point,
    input wire in_valid,
    input wire [ACC_OUT_WIDTH-1:0] acc_out,
    input wire [SCALE_WIDTH-1:0] scale,
    input wire [SHIFT_WIDTH-1:0] shift,
    output logic [QUAN_OUT_WIDTH+4-1:0] quan_relu_out,
    output logic quan_relu_out_valid
);
    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
        end else begin
            is_int16_reg <= is_int16;
        end
    end
    reg [ZERO_POINT_WIDTH-1:0] zero_point_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            zero_point_reg <= 0;
        end else begin
            zero_point_reg <= zero_point;
        end
    end

    wire [QUAN_IN_WIDTH-1:0] quan_in;
    wire quan_in_valid;

    quan_acc_sat #(
        .ACC_OUT_WIDTH(ACC_OUT_WIDTH),
        .QUAN_IN_WIDTH(QUAN_IN_WIDTH)
    ) u_quan_acc_sat (
        .clk          (clk),
        .rstn         (rstn),
        .is_int16     (is_int16_reg),
        .in_valid     (in_valid),
        .acc_out      (acc_out),
        .quan_in      (quan_in),
        .quan_in_valid(quan_in_valid)
    );


    quan_relu #(
        .QUAN_IN_WIDTH (QUAN_IN_WIDTH),
        .QUAN_OUT_WIDTH(QUAN_OUT_WIDTH),
        .SCALE_WIDTH   (SCALE_WIDTH),
        .SHIFT_WIDTH   (SHIFT_WIDTH),
        .ZERO_POINT_WIDTH(ZERO_POINT_WIDTH)
    ) u_quan_relu (
        .clk                (clk),
        .rstn               (rstn),
        .is_int16           (is_int16_reg),
        .quan_enable        (quan_enable),
        .relu_enable        (relu_enable),
        .zero_point         (zero_point_reg),
        .quan_in_valid      (quan_in_valid),
        .scale              (scale),
        .shift              (shift),
        .quan_in            (quan_in),
        .quan_relu_out      (quan_relu_out),
        .quan_relu_out_valid(quan_relu_out_valid)
    );



endmodule
