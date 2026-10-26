module data_sat_comb #(
    parameter DIN_WIDTH  = 32,
    parameter DOUT_WIDTH = 16
) (
    input  wire  [ DIN_WIDTH-1:0] din,
    output logic [DOUT_WIDTH-1:0] dout
);

    localparam signed [DOUT_WIDTH-1:0] POS_MAX = {{{1'b0}}, {DOUT_WIDTH - 1{1'b1}}};
    localparam signed [DOUT_WIDTH-1:0] NEG_MAX = {{{1'b1}}, {DOUT_WIDTH - 1{1'b0}}};

    wire is_pos;
    wire is_neg;
    assign is_pos = din[DIN_WIDTH-1] == 1'b0 && (|(din[DIN_WIDTH-2:DOUT_WIDTH-1]));
    assign is_neg = din[DIN_WIDTH-1] == 1'b1 && (~(&(din[DIN_WIDTH-2:DOUT_WIDTH-1])));

    always @(*) begin

        if (is_pos) begin
            dout = POS_MAX[DOUT_WIDTH-1:0];
        end else if (is_neg) begin
            dout = NEG_MAX[DOUT_WIDTH-1:0];
        end else begin
            dout = din[DOUT_WIDTH-1:0];
        end

    end

endmodule


// module data_sat_comb #(
//     parameter DIN_WIDTH  = 40,
//     parameter DOUT_WIDTH = 32
// ) (
//     input  wire  [ DIN_WIDTH-1:0] din,
//     output logic [DOUT_WIDTH-1:0] dout
// );

//     localparam signed [DIN_WIDTH-1:0] POS_MAX = {{{1'b0}}, {DOUT_WIDTH - 1{1'b1}}};
//     localparam signed [DIN_WIDTH-1:0] NEG_MAX = {{{1'b1}}, {DOUT_WIDTH - 1{1'b0}}};

//     wire is_pos;
//     wire is_neg;
//     assign is_pos = din[DIN_WIDTH-1] == 1'b0 && (|(din[DIN_WIDTH-2:DOUT_WIDTH-1]));
//     assign is_neg = din[DIN_WIDTH-1] == 1'b1 && (~(&(din[DIN_WIDTH-2:DOUT_WIDTH-1])));

//     always @(*) begin
//         if (is_pos) begin
//             dout <= POS_MAX[DOUT_WIDTH-1:0];
//         end else if (is_neg) begin
//             dout <= NEG_MAX[DOUT_WIDTH-1:0];
//         end else begin
//             dout <= din[DOUT_WIDTH-1:0];
//         end

//     end

// endmodule
