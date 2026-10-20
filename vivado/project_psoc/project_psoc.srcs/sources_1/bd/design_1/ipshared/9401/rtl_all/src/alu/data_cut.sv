module DATA_CUT #(
    parameter DIN_WIDTH  = 16,
    parameter DOUT_WIDTH = 10
) (
    input  signed     [ DIN_WIDTH-1:0] din,
    output reg signed [DOUT_WIDTH-1:0] dout
);

    localparam CUT_WIDTH = DIN_WIDTH - DOUT_WIDTH;

    always @(*) begin
        if (din[DIN_WIDTH-1 : CUT_WIDTH] == {1'b0, {(DOUT_WIDTH) {1'b1}}}) begin  // Postive max
            dout = din[DIN_WIDTH-1 : CUT_WIDTH];
        end
      else if (din[DIN_WIDTH-1 : CUT_WIDTH] == {1'b1,{(DOUT_WIDTH){1'b0}}}) begin //Negative max
            dout = {din[DIN_WIDTH-1 : CUT_WIDTH+1], 1'b1};
        end else begin  // Middle value , cut with 0.5 round
            dout = din[DIN_WIDTH-1 : CUT_WIDTH] + {{(DOUT_WIDTH - 1) {1'b0}}, din[CUT_WIDTH-1]};
        end
    end

endmodule

module split_data_cut #(
    parameter DIN_WIDTH  = 16,
    parameter DOUT_WIDTH = 10
) (
    input  wire                  is_int16,
    input       [ DIN_WIDTH-1:0] din,
    output reg  [DOUT_WIDTH-1:0] dout
);

    localparam CUT_WIDTH = DIN_WIDTH - DOUT_WIDTH;

    generate
        if (CUT_WIDTH == 0) begin
            assign dout = din;
        end else begin
            always @(*) begin
                if (is_int16) begin
                    dout = din[DOUT_WIDTH-1:0];
                end else begin
                    dout = {din[DOUT_WIDTH/2-1+DIN_WIDTH/2:DIN_WIDTH/2], din[DOUT_WIDTH/2-1:0]};
                end
            end
        end
    endgenerate


endmodule





