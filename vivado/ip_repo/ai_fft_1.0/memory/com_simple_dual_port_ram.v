// 单时钟控制，伪双端块RAM
module com_simple_dual_port_ram_one_clock #(
    parameter WIDTH = 32,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clk,
    input rstn,
    input wea,
    input ena,
    input enb,
    input [ADDR_BIT-1:0] addra,
    input [WIDTH-1:0] dina,

    input [ADDR_BIT-1:0] addrb,
    output reg [WIDTH-1:0] doutb,
    output reg validb
);
    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[0:DEPTH-1];
    // (*ram_style="registers"*) reg [WIDTH-1:0] RAM[0:DEPTH-1];

    integer t;
    initial begin
        for (t = 0; t < DEPTH; t = t + 1) RAM[t] = 0;
    end

    always @(posedge clk) begin
        if (ena) begin
            if (wea) begin
                RAM[addra] <= dina;
            end
        end
    end

    always @(posedge clk) begin
        if (enb) begin
            doutb <= RAM[addrb];
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            validb <= 0;
        end else begin
            validb <= enb;
        end
    end
endmodule


// 双时钟控制，伪双端块RAM
module com_simple_dual_port_ram_two_clock #(
    parameter WIDTH = 32,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clka,
    input clkb,
    input rstnb,
    input wea,
    input ena,
    input enb,
    input [ADDR_BIT-1:0] addra,
    input [WIDTH-1:0] dina,
    input [ADDR_BIT-1:0] addrb,
    output reg [WIDTH-1:0] doutb,
    output reg validb
);
    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[0:DEPTH-1];

    integer t;
    initial begin
        for (t = 0; t < DEPTH; t = t + 1) RAM[t] = 0;
    end

    always @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                RAM[addra] <= dina;
            end
        end
    end

    always @(posedge clkb) begin
        if (enb) begin
            doutb <= RAM[addrb];
        end
    end

    always @(posedge clkb or negedge rstnb) begin
        if (~rstnb) begin
            validb <= 0;
        end else begin
            validb <= enb;
        end
    end
endmodule


// 双时钟控制，带输出rst，伪双端块RAM
module com_simple_dual_port_ram_two_clock_rst #(
    parameter WIDTH = 32,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clka,
    input clkb,
    input rstnb,
    input ena,
    input wea,
    input enb,
    input [ADDR_BIT-1:0] addra,
    input [WIDTH-1:0] dina,

    input [ADDR_BIT-1:0] addrb,
    output reg [WIDTH-1:0] doutb,
    output reg validb
);
    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[0:DEPTH-1];
    // (*ram_style="registers"*) reg [WIDTH-1:0] RAM[0:DEPTH-1];

    integer t;
    initial begin
        for (t = 0; t < DEPTH; t = t + 1) RAM[t] = 0;
    end

    always @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                RAM[addra] <= dina;
            end
        end
    end

    always @(posedge clkb) begin
        if (enb) begin
            doutb <= RAM[addrb];
        end
    end

    always @(posedge clkb or negedge rstnb) begin
        if (~rstnb) begin
            validb <= 0;
        end else begin
            validb <= enb;
        end
    end

endmodule


