`include "ai_fft_define.svh"
module fft_ram_weight #(
    parameter PARALLEL = 4,  //8/2
    parameter WIDTH = 32,
    parameter MAX_POINT = 4096 / 2,
    parameter DEPTH = MAX_POINT / PARALLEL,  //MAX_POINT/PARALLEL
    parameter ADDR_WIDTH = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input ram_clk,
    input ram_ena,
    input ram_pass,
    input [ADDR_WIDTH-1:0] ram_addr,
    output [WIDTH-1:0] ram_data[PARALLEL-1:0]
);

    (*ram_style = "block" *) reg [WIDTH-1:0] ram[MAX_POINT-1:0];
    (*ram_style = "distributed " *) reg [WIDTH-1:0] ram_passreg[7:0];

    initial begin
        ram_passreg[0] <= 32'b0000000000000000_0111111111111111;
        ram_passreg[1] <= 32'b0000000000000000_0111111111111111;
        ram_passreg[2] <= 32'b0000000000000000_0111111111111111;
        ram_passreg[3] <= 32'b1010010101111111_0101101010000001;  //512
        ram_passreg[4] <= 32'b0000000000000000_0111111111111111;
        ram_passreg[5] <= 32'b1100111100000110_0111011001000000;  //256
        ram_passreg[6] <= 32'b1010010101111111_0101101010000001;  //512
        ram_passreg[7] <= 32'b1000100111000000_0011000011111010;  //768
    end

    initial  // Read the memory contents in the file
        begin
            $readmemb(`ROTAR_4096_PATH, ram);
        end

    // initial // Read the memory contents in the file
    // begin
    // $readmemb("E:/v/fft/m/rotar_4096_test.txt", ram);
    // end

    // integer ph;
    // initial begin
    //   for(ph=0;ph<MAX_POINT;ph++)begin
    //     ram[ph] <= ph;
    //   end
    // end


    reg [WIDTH-1:0] ram_data_reg[PARALLEL-1:0];
    reg ram_vaild_reg[PARALLEL-1:0];
    integer j;
    always @(posedge ram_clk) begin
        if (ram_pass) begin
            for (j = 0; j < PARALLEL; j = j + 1) begin
                ram_data_reg[j] <= ram_passreg[ram_addr[2:0]];
            end
        end else if (ram_ena) begin
            for (j = 0; j < PARALLEL; j = j + 1) begin
                ram_data_reg[j] <= ram[j*DEPTH+ram_addr];
            end
        end
    end

    genvar i;
    // generate
    //   for(i=0;i<PARALLEL;i=i+1) begin:ROM_O
    //     always@(posedge ram_clk)begin
    //       if(ram_ena)begin
    //         ram_data_reg[i]<=ram[i*DEPTH+rom_addr];
    //       end
    //     end
    //   end
    // endgenerate

    generate
        for (i = 0; i < PARALLEL; i = i + 1) begin
            assign ram_data[i] = ram_data_reg[i];
        end
    endgenerate


endmodule
