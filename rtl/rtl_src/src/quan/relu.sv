
// module relu_sat #(
//     parameter DIN_WIDTH  = 32,
//     parameter DOUT_WIDTH = 16
// ) (
//     input wire relu_enable,
//     input wire [DIN_WIDTH-1:0] din,
//     output logic [DOUT_WIDTH-1:0] dout
// );

//     localparam [DOUT_WIDTH-1:0] POS_MAX = {{{1'b0}}, {(DOUT_WIDTH - 1) {1'b1}}};
//     localparam [DOUT_WIDTH-1:0] NEG_MAX = {{{1'b1}}, {(DOUT_WIDTH - 1) {1'b0}}};

//     wire is_pos_max;
//     wire is_neg_max;
//     wire is_neg;
//     assign is_pos_max = din[DIN_WIDTH-1] == 1'b0 && (|(din[DIN_WIDTH-2:DOUT_WIDTH-1]));
//     assign is_neg = din[DIN_WIDTH-1] == 1'b1;
//     assign is_neg_max = is_neg && (~(&(din[DIN_WIDTH-2:DOUT_WIDTH-1])));

//     always @(*) begin

//         if (is_pos_max) begin
//             dout = POS_MAX[DOUT_WIDTH-1:0];
//         end else if (is_neg) begin
//             if (relu_enable) begin
//                 dout = 0;
//             end else if (is_neg_max) begin
//                 dout = NEG_MAX[DOUT_WIDTH-1:0];
//             end else begin
//                 dout = din[DOUT_WIDTH-1:0];
//             end
//         end else begin
//             dout = din[DOUT_WIDTH-1:0];
//         end

//     end

// endmodule

// module relu_sat_signed #(
//     parameter DIN_WIDTH = 32,
//     parameter DOUT_WIDTH = 16,
//     parameter ZERO_POINT_WIDTH = 8
// ) (
//     input wire relu_enable,
//     input wire signed [ZERO_POINT_WIDTH-1:0] zero_point,
//     input wire signed [DIN_WIDTH-1:0] din,
//     output logic [DOUT_WIDTH-1:0] dout
// );

//     wire signed [DIN_WIDTH+1-1:0] din_add_zero_point;
//     assign din_add_zero_point = din + zero_point;

//     localparam [DOUT_WIDTH-1:0] POS_MAX_SIGNED = {{{1'b0}}, {(DOUT_WIDTH - 1) {1'b1}}};
//     localparam [DOUT_WIDTH-1:0] NEG_MAX_SIGNED = {{{1'b1}}, {(DOUT_WIDTH - 1) {1'b0}}};

//     wire is_neg_signed;
//     wire is_neg_max_signed;

//     assign is_pos_max_signed = din_add_zero_point[DIN_WIDTH+1-1] == 1'b0 && (|(din_add_zero_point[DIN_WIDTH+1-2:DOUT_WIDTH-1]));
//     assign is_neg_signed = din_add_zero_point[DIN_WIDTH+1-1] == 1'b1;
//     assign is_neg_max_signed = is_neg_signed && (~(&(din_add_zero_point[DIN_WIDTH+1-2:DOUT_WIDTH-1])));

//     always @(*) begin
//         if (relu_enable) begin
//             if (is_pos_max_signed) begin
//                 dout = POS_MAX_SIGNED[DOUT_WIDTH-1:0];
//             end else if (is_neg_signed) begin
//                 dout = 0;
//             end else begin
//                 dout = din_add_zero_point[DOUT_WIDTH-1:0];
//             end
//         end else begin
//             if (is_pos_max_signed) begin
//                 dout = POS_MAX_SIGNED[DOUT_WIDTH-1:0];
//             end else if (is_neg_max_signed) begin
//                 dout = NEG_MAX_SIGNED[DOUT_WIDTH-1:0];
//             end else begin
//                 dout = din_add_zero_point[DOUT_WIDTH-1:0];
//             end
//         end
//     end

// endmodule


// module relu_sat_unsigned #(
//     parameter DIN_WIDTH = 32,
//     parameter DOUT_WIDTH = 16,
//     parameter ZERO_POINT_WIDTH = 8
// ) (
//     input wire relu_enable,
//     input wire signed [ZERO_POINT_WIDTH-1:0] zero_point,
//     input wire signed [DIN_WIDTH-1:0] din,
//     output logic [DOUT_WIDTH-1:0] dout
// );

//     wire signed [DIN_WIDTH+1-1:0] din_add_zero_point;
//     assign din_add_zero_point = din + zero_point;

//     localparam [DOUT_WIDTH-1:0] POS_MAX_UNSIGNED = {{(DOUT_WIDTH) {1'b1}}};
//     localparam [DOUT_WIDTH-1:0] NEG_MAX_UNSIGNED = {{(DOUT_WIDTH) {1'b0}}};

//     localparam [DOUT_WIDTH-1:0] POS_MAX_SIGNED = {{{1'b0}}, {(DOUT_WIDTH - 1) {1'b1}}};
//     localparam [DOUT_WIDTH-1:0] NEG_MAX_SIGNED = {{{1'b1}}, {(DOUT_WIDTH - 1) {1'b0}}};


//     wire is_pos_max_unsigned;
//     wire is_neg_signed;
//     wire is_neg_max_signed;
//     assign is_pos_max_unsigned = din_add_zero_point[DIN_WIDTH+1-1] == 1'b0 && (|(din_add_zero_point[DIN_WIDTH+1-2:DOUT_WIDTH]));

//     assign is_pos_max_signed = din_add_zero_point[DIN_WIDTH+1-1] == 1'b0 && (|(din_add_zero_point[DIN_WIDTH+1-2:DOUT_WIDTH-1]));
//     assign is_neg_signed = din_add_zero_point[DIN_WIDTH+1-1] == 1'b1;
//     assign is_neg_max_signed = is_neg_signed && (~(&(din_add_zero_point[DIN_WIDTH+1-2:DOUT_WIDTH-1])));

//     always @(*) begin
//         if (relu_enable) begin
//             if (is_pos_max_unsigned) begin
//                 dout = POS_MAX_UNSIGNED[DOUT_WIDTH-1:0];
//             end else if (is_neg_signed) begin
//                 dout = 0;
//             end else begin
//                 dout = din_add_zero_point[DOUT_WIDTH-1:0];
//             end
//         end else begin
//             if (is_pos_max_signed) begin
//                 dout = POS_MAX_SIGNED[DOUT_WIDTH-1:0];
//             end else if (is_neg_max_signed) begin
//                 dout = NEG_MAX_SIGNED[DOUT_WIDTH-1:0];
//             end else begin
//                 dout = din_add_zero_point[DOUT_WIDTH-1:0];
//             end
//         end
//     end

// endmodule

module relu_ff #(
    parameter WIDTH = 16
) (
    input wire clk,
    input wire rstn,
    input wire relu_enable,
    input wire in_valid,
    input wire [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] dout,
    output logic out_valid
);
    wire relu_in_valid;
    assign relu_in_valid = in_valid;
    always @(posedge clk) begin
        if (relu_in_valid) begin
            if (relu_enable) begin
                dout <= data_in[WIDTH-1] ? 0 : data_in;
            end else begin
                dout <= data_in;
            end
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid <= 0;
        end else begin
            out_valid <= relu_in_valid;
        end
    end
endmodule

module relu_comb #(
    parameter WIDTH = 16
) (
    input wire relu_enable,
    input wire [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] dout
);

    assign dout = ((~relu_enable) || data_in[WIDTH-1]) ? 0 : data_in;

endmodule
