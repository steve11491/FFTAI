


module quan_relu #(
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
    input wire quan_in_valid,
    input wire [SCALE_WIDTH-1:0] scale,
    input wire [SHIFT_WIDTH-1:0] shift,
    input wire [QUAN_IN_WIDTH-1:0] quan_in,
    output logic [QUAN_OUT_WIDTH+4-1:0] quan_relu_out,
    output logic quan_relu_out_valid
);

    logic signed [QUAN_IN_WIDTH/2:0] mul_low_int8_round;
    logic signed [QUAN_IN_WIDTH/2:0] mul_high_int8_round;
    logic signed [QUAN_IN_WIDTH:0] mul_int16_round;
    logic mul_round_valid;
    quan_scale_shift_round #(
        .QUAN_IN_WIDTH (QUAN_IN_WIDTH),
        .QUAN_OUT_WIDTH(QUAN_OUT_WIDTH),
        .SCALE_WIDTH   (SCALE_WIDTH),
        .SHIFT_WIDTH   (SHIFT_WIDTH)
    ) u_quan_scale_shift_round (
        .clk          (clk),
        .rstn         (rstn),
        .is_int16     (is_int16),
        .quan_enable  (quan_enable),
        .quan_in_valid(quan_in_valid),
        .scale        (scale),
        .shift        (shift),
        .quan_in      (quan_in),

        .mul_low_int8_round (mul_low_int8_round),
        .mul_high_int8_round(mul_high_int8_round),
        .mul_int16_round    (mul_int16_round),
        .mul_round_valid    (mul_round_valid)
    );

    logic [QUAN_OUT_WIDTH/2:0] sat_low_int8;
    logic [QUAN_OUT_WIDTH/2:0] sat_high_int8;
    logic [  QUAN_OUT_WIDTH:0] sat_int16;

    data_sat_comb #(
        .DIN_WIDTH (QUAN_IN_WIDTH / 2 + 1),
        .DOUT_WIDTH(QUAN_OUT_WIDTH / 2 + 1)
    ) u_data_sat_comb_low_int8 (
        .din (mul_low_int8_round),
        .dout(sat_low_int8)
    );

    data_sat_comb #(
        .DIN_WIDTH (QUAN_IN_WIDTH / 2 + 1),
        .DOUT_WIDTH(QUAN_OUT_WIDTH / 2 + 1)
    ) u_data_sat_comb_high_int8 (
        .din (mul_high_int8_round),
        .dout(sat_high_int8)
    );

    data_sat_comb #(
        .DIN_WIDTH (QUAN_IN_WIDTH + 1),
        .DOUT_WIDTH(QUAN_OUT_WIDTH + 1)
    ) u_data_sat_comb_int16 (
        .din (mul_int16_round),
        .dout(sat_int16)
    );


    wire signed [QUAN_OUT_WIDTH/2:0] act_low_int8;
    wire signed [QUAN_OUT_WIDTH/2:0] act_high_int8;
    wire signed [QUAN_OUT_WIDTH:0] act_int16;

    wire act_int8_valid;
    wire act_int16_valid;


    relu_ff #(
        .WIDTH(QUAN_OUT_WIDTH / 2 + 1)
    ) u_relu_ff_low_int8 (
        .clk        (clk),
        .rstn       (rstn),
        .relu_enable(relu_enable),
        .in_valid   (mul_round_valid),
        .data_in    (sat_low_int8),
        .dout       (act_low_int8),
        .out_valid  (act_int8_valid)
    );


    relu_ff #(
        .WIDTH(QUAN_OUT_WIDTH / 2 + 1)
    ) u_relu_ff_high_int8 (
        .clk        (clk),
        .rstn       (rstn),
        .relu_enable(relu_enable),
        .in_valid   (mul_round_valid),
        .data_in    (sat_high_int8),
        .dout       (act_high_int8),
        .out_valid  ()
    );

    relu_ff #(
        .WIDTH(QUAN_OUT_WIDTH + 1)
    ) u_relu_ff_int16 (
        .clk        (clk),
        .rstn       (rstn),
        .relu_enable(relu_enable),
        .in_valid   (mul_round_valid),
        .data_in    (sat_int16),
        .dout       (act_int16),
        .out_valid  (act_int16_valid)
    );

    wire act_valid;
    assign act_valid = is_int16 ? act_int16_valid : act_int8_valid;

    wire signed [QUAN_OUT_WIDTH/2+1:0] act_low_int8_add_zero_point;
    wire signed [QUAN_OUT_WIDTH/2+1:0] act_high_int8_add_zero_point;
    wire signed [  QUAN_OUT_WIDTH+1:0] act_int16_add_zero_point;

    assign act_low_int8_add_zero_point = ($signed(
        act_low_int8
    ) + $signed(
        zero_point[ZERO_POINT_WIDTH/2-1:0]
    ));

    assign act_high_int8_add_zero_point = ($signed(
        act_high_int8
    ) + $signed(
        zero_point[ZERO_POINT_WIDTH/2-1:0]
    ));

    assign act_int16_add_zero_point = ($signed(
        act_int16
    ) + $signed(
        zero_point[ZERO_POINT_WIDTH-1:0]
    ));

    // wire signed [QUAN_OUT_WIDTH/2-1:0] act_low_int8_add_zero_point_sat;
    // wire signed [QUAN_OUT_WIDTH/2-1:0] act_high_int8_add_zero_point_sat;
    // wire signed [  QUAN_OUT_WIDTH-1:0] act_int16_add_zero_point_sat;

    // data_sat_comb #(
    //     .DIN_WIDTH (QUAN_OUT_WIDTH / 2 + 2),
    //     .DOUT_WIDTH(QUAN_OUT_WIDTH / 2)
    // ) data_sat_comb_act_low_int8 (
    //     .din (act_low_int8_add_zero_point),
    //     .dout(act_low_int8_add_zero_point_sat)
    // );
    // data_sat_comb #(
    //     .DIN_WIDTH (QUAN_OUT_WIDTH / 2 + 2),
    //     .DOUT_WIDTH(QUAN_OUT_WIDTH / 2)
    // ) data_sat_comb_act_high_int8 (
    //     .din (act_high_int8_add_zero_point),
    //     .dout(act_high_int8_add_zero_point_sat)
    // );
    // data_sat_comb #(
    //     .DIN_WIDTH (QUAN_OUT_WIDTH + 2),
    //     .DOUT_WIDTH(QUAN_OUT_WIDTH)
    // ) data_sat_comb_act_int16 (
    //     .din (act_int16_add_zero_point),
    //     .dout(act_int16_add_zero_point_sat)
    // );




    // always @(posedge clk) begin
    //     if (act_valid) begin
    //         if (is_int16) begin
    //             quan_relu_out <= act_int16_add_zero_point_sat[QUAN_OUT_WIDTH-1:0];
    //         end else begin
    //             quan_relu_out <= {
    //                 act_high_int8_add_zero_point_sat[QUAN_OUT_WIDTH/2-1:0],
    //                 act_low_int8_add_zero_point_sat[QUAN_OUT_WIDTH/2-1:0]
    //             };
    //         end

    //     end
    // end


    always @(posedge clk) begin
        if (act_valid) begin
            if (is_int16) begin
                quan_relu_out <= {
                    {2{act_int16_add_zero_point[QUAN_OUT_WIDTH+1]}},
                    act_int16_add_zero_point[QUAN_OUT_WIDTH+1:0]
                };
            end else begin
                quan_relu_out <= {
                    act_high_int8_add_zero_point[QUAN_OUT_WIDTH/2+1:0],
                    act_low_int8_add_zero_point[QUAN_OUT_WIDTH/2+1:0]

                };
            end

        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            quan_relu_out_valid <= 0;
        end else begin
            quan_relu_out_valid <= act_valid;
        end
    end





endmodule

