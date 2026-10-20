//使用块RAM资源实现ROM
module com_simple_port_rom #(
    parameter WIDTH = 32,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clk,
    input en,
    input [ADDR_BIT-1:0] addr,
    output [WIDTH-1:0] dout
);

    (*rom_style = "block" *) reg [WIDTH-1:0] data;

    always @(posedge clk) begin
        if (en)
            case (addr)
                'd0: data <= 32'd1;
                'd1: data <= 32'd1;
                'd2: data <= 32'd1;
                'd32: data <= 32'd1;
                default: data <= 32'd1;
            endcase
    end

    assign dout = data;

endmodule
