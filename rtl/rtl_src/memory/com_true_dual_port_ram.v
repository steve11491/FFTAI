// 带有两个写端口的双端块RAM
module com_true_dual_port_ram #(
    parameter WIDTH = 32,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clka,
    input clkb,
    input ena,
    input enb,
    input wea,
    input web,
    input [ADDR_BIT-1:0] addra,
    input [ADDR_BIT-1:0] addrb,
    input [WIDTH-1:0] dina,
    input [WIDTH-1:0] dinb,
    output reg [WIDTH-1:0] douta,
    output reg [WIDTH-1:0] doutb
);

    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[0:DEPTH-1];

    integer t;
    initial begin
        for (t = 0; t < DEPTH; t = t + 1) RAM[t] = 0;
    end

    always @(posedge clka)  //端口1
        if (ena) begin
            if (wea) RAM[addra] <= dina;
            douta <= RAM[addra];
        end

    always @(posedge clkb)  //端口2
        if (enb) begin
            if (web) RAM[addrb] <= dinb;
            doutb <= RAM[addrb];
        end

endmodule


// 带有输出寄存器的块RAM
module com_true_dual_port_ram_pipeline #(
    parameter WIDTH = 72,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clka,
    input clkb,
    input ena,
    input enb,
    input wea,
    input web,
    input [ADDR_BIT-1:0] addra,
    input [ADDR_BIT-1:0] addrb,
    input [WIDTH-1:0] dina,
    input [WIDTH-1:0] dinb,
    output reg [WIDTH-1:0] douta,
    output reg [WIDTH-1:0] doutb
);

    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[0:DEPTH-1];

    integer t;
    initial begin
        for (t = 0; t < DEPTH; t = t + 1) RAM[t] = 0;
    end

    reg [WIDTH-1:0] douta_t;
    reg [WIDTH-1:0] doutb_t;

    always @(posedge clka) begin
        if (wea) RAM[addra] <= dina;
        douta_t <= RAM[addra];
    end

    always @(posedge clka) begin
        if (web) RAM[addrb] <= dinb;
        doutb_t <= RAM[addrb];
    end
    always @(posedge clka) if (ena) douta <= douta_t;

    always @(posedge clkb) if (enb) doutb <= doutb_t;

endmodule
