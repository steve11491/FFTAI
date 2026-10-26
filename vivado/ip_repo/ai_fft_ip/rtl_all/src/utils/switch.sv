module mux #(
    parameter WIDTH = 32,
    parameter NUMBER = 4,
    parameter SELECT_W = $clog2(NUMBER)
) (
    input   logic [SELECT_W-1:0]   sel,
    input logic [WIDTH-1:0] mux_in[NUMBER-1:0],
    output  logic    [WIDTH-1:0] out
);

    assign out = mux_in[sel];

endmodule

module demux #(
    parameter WIDTH = 32,
    parameter NUMBER = 4,
    parameter SELECT_W = $clog2(NUMBER)
) (
    input logic [SELECT_W-1:0] sel,
    input logic [WIDTH-1:0] mux_in,
    output logic [WIDTH-1:0] out[NUMBER-1:0]
);

    always @(*) begin
        out[sel] = mux_in;  //latch 
    end

endmodule

module demux_ff #(
    parameter WIDTH = 32,
    parameter NUMBER = 4,
    parameter SELECT_W = $clog2(NUMBER)
) (
    input wire clk,
    input wire rstn,
    input logic [SELECT_W-1:0] sel,
    input logic [WIDTH-1:0] mux_in,
    output logic [WIDTH-1:0] out[NUMBER-1:0]
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (int i = 0; i < NUMBER; i = i + 1) begin
                out[i] <= 0;
            end
        end else begin
            out[sel] <= mux_in;
        end
    end

endmodule


module demux_ff_multi #(
    parameter WIDTH = 32,
    parameter NUMBER = 4,
    parameter L = 4,
    parameter SELECT_W = $clog2(NUMBER)
) (
    input wire clk,
    input wire rstn,
    input logic [SELECT_W-1:0] sel,
    input logic [WIDTH-1:0] mux_in[L-1:0],
    output logic [WIDTH-1:0] out[NUMBER-1:0][L-1:0]
);
    wire [SELECT_W-1:0] sel_t;
    generate
        if ((2 ** SELECT_W) > NUMBER) begin
            assign sel_t = (sel > (NUMBER - 1)) ? (NUMBER - 1) : sel;
        end else begin
            assign sel_t = sel;
        end
    endgenerate
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (int i = 0; i < NUMBER; i = i + 1) begin
                for (int j = 0; j < L; j = j + 1) begin
                    out[i][j] <= 0;
                end
            end
        end else begin
            out[sel_t] <= mux_in;
        end
    end

endmodule

module demux_ff_en_multi #(
    parameter WIDTH = 32,
    parameter NUMBER = 4,
    parameter L = 4,
    parameter SELECT_W = $clog2(NUMBER)
) (
    input wire clk,
    input wire rstn,
    input logic [SELECT_W-1:0] sel,
    input logic [WIDTH-1:0] mux_in[L-1:0],
    input logic [L-1:0] mux_in_en,
    output logic [WIDTH-1:0] out[NUMBER-1:0][L-1:0]
);
    wire [SELECT_W-1:0] sel_t;
    generate
        if ((2 ** SELECT_W) > NUMBER) begin
            assign sel_t = (sel > (NUMBER - 1)) ? (NUMBER - 1) : sel;
        end else begin
            assign sel_t = sel;
        end
    endgenerate
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (int i = 0; i < NUMBER; i = i + 1) begin
                for (int j = 0; j < L; j = j + 1) begin
                    out[i][j] <= 0;
                end
            end
        end else begin
            for (int i = 0; i < L; i = i + 1) begin
                if (mux_in_en[i]) begin
                    out[sel_t][i] <= mux_in[i];
                end
            end
        end
    end

endmodule

module demux_set #(
    parameter WIDTH = 32,
    parameter NUMBER = 4,
    parameter SET = 1'b0,
    parameter SELECT_W = $clog2(NUMBER)
) (
    input logic [SELECT_W-1:0] sel,
    input logic [WIDTH-1:0] mux_in,
    output logic [WIDTH-1:0] out[NUMBER-1:0]
);


    genvar i;

    generate
        for (i = 0; i < NUMBER; i = i + 1) begin
            assign out[i] = (sel == i) ? mux_in : {(WIDTH) {SET}};
        end
    endgenerate

endmodule

module switch_network #(
    parameter WIDTH = 32,
    parameter IN_NUMBER = 4,
    parameter OUT_NUMBER = 4,
    parameter SELECT_W = $clog2(IN_NUMBER)
) (
    input   logic [SELECT_W-1:0]   sel[OUT_NUMBER-1:0],
    input logic [WIDTH-1:0] in[IN_NUMBER-1:0],
    output  logic    [WIDTH-1:0] out[OUT_NUMBER-1:0]
);

    genvar i;
    generate
        for (i = 0; i < OUT_NUMBER; i = i + 1) begin
            mux #(
                .WIDTH (WIDTH),
                .NUMBER(IN_NUMBER)
            ) mux_u (
                .sel(sel[i]),
                .mux_in(in[IN_NUMBER-1:0]),
                .out(out[i])
            );
        end
    endgenerate



endmodule

module switch_network1 #(
    parameter IN_NUMBER  = 4,
    parameter OUT_NUMBER = 4,
    parameter SELECT_W   = $clog2(IN_NUMBER)
) (
    input  logic [SELECT_W-1:0] sel[OUT_NUMBER-1:0],
    input  logic                in [ IN_NUMBER-1:0],
    output logic                out[OUT_NUMBER-1:0]
);

    genvar i;
    generate
        for (i = 0; i < OUT_NUMBER; i = i + 1) begin
            mux #(
                .WIDTH (1),
                .NUMBER(IN_NUMBER)
            ) mux_u (
                .sel(sel[i]),
                .mux_in(in[IN_NUMBER-1:0]),
                .out(out[i])
            );
        end
    endgenerate



endmodule
