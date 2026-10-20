module fft_ram_in #(
    parameter PARALLEL = 8,
    parameter DEPTH = 512,
    parameter WIDTH = 32
) (
    input ram_clk,
    input ram_rstn,
    input ram_i_ena[PARALLEL-1:0],
    input ram_o_ena,
    input [WIDTH-1:0] ram_i_data[PARALLEL-1:0],
    input [$clog2(DEPTH)-1:0] ram_i_addr[PARALLEL-1:0],
    input [$clog2(DEPTH)-1:0] ram_o_addr[PARALLEL-1:0],
    output [WIDTH-1:0] ram_o_data[PARALLEL-1:0],
    output ram_o_vaild
);


    //Block RAM
    wire [WIDTH-1:0] buff_i_data[PARALLEL-1:0];
    wire [PARALLEL-1:0] buff_i_vaild;
    genvar i;
    generate
        for (i = 0; i < PARALLEL; i = i + 1) begin : RAMIN
            com_simple_dual_port_ram_two_clock #(
                .WIDTH(WIDTH),
                .DEPTH(DEPTH)
            ) ram_i_0 (
                .clka(ram_clk),
                .clkb(ram_clk),
                .rstnb(ram_rstn),
                .wea(1'b1),
                .ena(ram_i_ena[i]),
                .enb(ram_o_ena),
                .addra(ram_i_addr[i]),
                .dina(ram_i_data[i]),
                .addrb(ram_o_addr[i]),
                .doutb(ram_o_data[i]),
                .validb(buff_i_vaild[i])
            );
        end
    endgenerate
    assign ram_o_vaild = |buff_i_vaild;

    // reg [WIDTH-1:0] ram_o_data_reg[PARALLEL-1:0];
    // reg ram_o_vaild_reg;
    // always @(posedge ram_clk)begin
    //   if(!ram_rstn)begin
    //     ram_o_vaild_reg<=1'b0;
    //   end
    //   else begin
    //     ram_o_vaild_reg <= |buff_i_vaild;
    //   end
    // end

    // integer j;
    // always@(posedge ram_clk)begin
    //   for(j=0;j<PARALLEL;j=j+1)begin
    //     ram_o_data_reg[j]<=buff_i_data[j];
    //   end
    // end

    //out
    // generate
    //   for(i=0;i<PARALLEL;i=i+1) begin
    //     assign ram_o_data[i] = ram_o_data_reg[i];
    //   end
    // endgenerate
    // assign ram_o_vaild = ram_o_vaild_reg;

endmodule
