module data_sat #(
    parameter DIN_WIDTH  = 40,
    parameter DOUT_WIDTH = 32
) (
    input wire clk,
    input wire rstn,
    input wire in_valid,
    input wire [DIN_WIDTH-1:0] din,
    output logic [DOUT_WIDTH-1:0] dout,
    output logic out_valid
);

    localparam signed [DIN_WIDTH-1:0] POS_MAX = {{{1'b0}}, {DOUT_WIDTH - 1{1'b1}}};
    localparam signed [DIN_WIDTH-1:0] NEG_MAX = {{{1'b1}}, {DOUT_WIDTH - 1{1'b0}}};

    wire is_pos;
    wire is_neg;
    assign is_pos = din[DIN_WIDTH-1] == 1'b0 && (|(din[DIN_WIDTH-2:DOUT_WIDTH-1]));
    assign is_neg = din[DIN_WIDTH-1] == 1'b1 && (~(&(din[DIN_WIDTH-2:DOUT_WIDTH-1])));

    always @(posedge clk) begin
        if (in_valid) begin
            if (is_pos) begin
                dout <= POS_MAX[DOUT_WIDTH-1:0];
            end else if (is_neg) begin
                dout <= NEG_MAX[DOUT_WIDTH-1:0];
            end else begin
                dout <= din[DOUT_WIDTH-1:0];
            end
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid <= 0;
        end else begin
            out_valid <= in_valid;
        end
    end


endmodule

module data_sat_comb #(
    parameter DIN_WIDTH  = 40,
    parameter DOUT_WIDTH = 32
) (
    input  wire  [ DIN_WIDTH-1:0] din,
    output logic [DOUT_WIDTH-1:0] dout
);

    localparam signed [DIN_WIDTH-1:0] POS_MAX = {{{1'b0}}, {DOUT_WIDTH - 1{1'b1}}};
    localparam signed [DIN_WIDTH-1:0] NEG_MAX = {{{1'b1}}, {DOUT_WIDTH - 1{1'b0}}};

    wire is_pos;
    wire is_neg;
    assign is_pos = din[DIN_WIDTH-1] == 1'b0 && (|(din[DIN_WIDTH-2:DOUT_WIDTH-1]));
    assign is_neg = din[DIN_WIDTH-1] == 1'b1 && (~(&(din[DIN_WIDTH-2:DOUT_WIDTH-1])));

    always @(*) begin
        if (is_pos) begin
            dout <= POS_MAX[DOUT_WIDTH-1:0];
        end else if (is_neg) begin
            dout <= NEG_MAX[DOUT_WIDTH-1:0];
        end else begin
            dout <= din[DOUT_WIDTH-1:0];
        end

    end

endmodule




module split_dat_sat #(
    parameter DIN_WIDTH  = 40,
    parameter DOUT_WIDTH = 32
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire [DIN_WIDTH-1:0] din,
    output logic [DOUT_WIDTH-1:0] dout,
    output logic out_valid
);

    parameter CUT_WIDTH = DIN_WIDTH - DOUT_WIDTH;  //CUT_WIDTH 为大于等于2的偶数
    initial begin
        assert_flag :
        assert (CUT_WIDTH % 2 == 0 & CUT_WIDTH >= 0)
        else $error("CUT_WIDTH % 2 == 0 & CUT_WIDTH > 0");
    end




    generate
        if (CUT_WIDTH % 2 == 0 & CUT_WIDTH > 0) begin
            localparam signed [DOUT_WIDTH-1:0] POS_MAX_INT16 = {
                {{1'b0}}, {(DOUT_WIDTH - 1) {1'b1}}
            };
            localparam signed [DOUT_WIDTH-1:0] NEG_MAX_INT16 = {
                {{1'b1}}, {(DOUT_WIDTH - 1) {1'b0}}
            };

            localparam signed [DOUT_WIDTH/2-1:0] POS_MAX_INT8 = {
                {{1'b0}}, {(DOUT_WIDTH / 2 - 1) {1'b1}}
            };
            localparam signed [DOUT_WIDTH/2-1:0] NEG_MAX_INT8 = {
                {{1'b1}}, {(DOUT_WIDTH / 2 - 1) {1'b0}}
            };

            wire is_pos_int16;
            wire is_neg_int16;
            assign is_pos_int16 = din[DIN_WIDTH-1] == 1'b0 && (|(din[DIN_WIDTH-2:DIN_WIDTH-1-CUT_WIDTH]));
            assign is_neg_int16 = din[DIN_WIDTH-1] == 1'b1 && (~(&(din[DIN_WIDTH-2:DIN_WIDTH-1-CUT_WIDTH])));

            wire is_pos_int8_1;
            wire is_pos_int8_2;
            wire is_neg_int8_1;
            wire is_neg_int8_2;
            assign is_pos_int8_1 = din[DIN_WIDTH-1] == 1'b0 && (|(din[DIN_WIDTH-2:DIN_WIDTH-1-CUT_WIDTH/2]));
            assign is_neg_int8_1 = din[DIN_WIDTH-1] == 1'b1 && (~(&(din[DIN_WIDTH-2:DIN_WIDTH-1-CUT_WIDTH/2])));
            assign is_pos_int8_2 = din[DIN_WIDTH/2-1] == 1'b0 && (|(din[DIN_WIDTH/2-2:DIN_WIDTH/2-1-CUT_WIDTH/2]));
            assign is_neg_int8_2 = din[DIN_WIDTH/2-1] == 1'b1 && (~(&(din[DIN_WIDTH/2-2:DIN_WIDTH/2-1-CUT_WIDTH/2])));
            always @(posedge clk) begin
                if (in_valid) begin
                    if (is_int16) begin
                        if (is_pos_int16) begin
                            dout <= POS_MAX_INT16[DOUT_WIDTH-1:0];
                        end else if (is_neg_int16) begin
                            dout <= NEG_MAX_INT16[DOUT_WIDTH-1:0];
                        end else begin
                            dout <= din[DOUT_WIDTH-1:0];
                        end
                    end else begin
                        if (is_pos_int8_1) begin
                            dout[DOUT_WIDTH-1:DOUT_WIDTH/2] <= POS_MAX_INT8[DOUT_WIDTH/2-1:0];
                        end else if (is_neg_int8_1) begin
                            dout[DOUT_WIDTH-1:DOUT_WIDTH/2] <= NEG_MAX_INT8[DOUT_WIDTH/2-1:0];
                        end else begin
                            dout[DOUT_WIDTH-1:DOUT_WIDTH/2] <= din[DOUT_WIDTH/2+DIN_WIDTH/2-1:DIN_WIDTH/2];
                        end
                        if (is_pos_int8_2) begin
                            dout[DOUT_WIDTH/2-1:0] <= POS_MAX_INT8[DOUT_WIDTH/2-1:0];
                        end else if (is_neg_int8_2) begin
                            dout[DOUT_WIDTH/2-1:0] <= NEG_MAX_INT8[DOUT_WIDTH/2-1:0];
                        end else begin
                            dout[DOUT_WIDTH/2-1:0] <= din[DOUT_WIDTH/2-1:0];
                        end
                    end

                end
            end
            always @(posedge clk or negedge rstn) begin
                if (~rstn) begin
                    out_valid <= 0;
                end else begin
                    out_valid <= in_valid;
                end
            end
        end else if (CUT_WIDTH == 0) begin

            assign dout      = din;
            assign out_valid = in_valid;
        end
    endgenerate



endmodule
