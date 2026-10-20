module fft_ram_out #(
    parameter PARALLEL = 8,
    parameter DEPTH = 512,
    parameter WIDTH = 32
) (
    input ram_clk,
    input ram_rstn,
    input ram_i_ena,
    input ram_o_ena[PARALLEL-1:0],
    input [WIDTH-1:0] ram_i_data[PARALLEL-1:0],
    input [$clog2(DEPTH)-1:0] ram_i_addr[PARALLEL-1:0],
    input [$clog2(DEPTH)-1:0] ram_o_addr[PARALLEL-1:0],
    output [WIDTH-1:0] ram_o_data[PARALLEL-1:0],
    output ram_o_vaild
);

    //RAM OUT
    wire [PARALLEL-1:0] validb;
    genvar i;
    generate
        for (i = 0; i < PARALLEL; i = i + 1) begin : RAMOUT
            com_simple_dual_port_ram_two_clock #(
                .WIDTH(WIDTH),
                .DEPTH(DEPTH)
            ) ram_o_0 (
                .clka(ram_clk),
                .clkb(ram_clk),
                .rstnb(ram_rstn),
                .wea(1'b1),
                .ena(ram_i_ena),
                .enb(ram_o_ena[i]),
                .addra(ram_i_addr[i]),
                .dina(ram_i_data[i]),
                .addrb(ram_o_addr[i]),
                .doutb(ram_o_data[i]),
                .validb(validb[i])
            );
        end
    endgenerate

    assign ram_o_vaild = |validb;

endmodule
