`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: tb_demo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_ram_i();
    localparam PERIOD = 10;

    reg clk;
    reg rst_n;
    reg signed [31:0] data_in [7:0][511:0];  

    /******************add reg ************************/
    reg ram_i_ena;  
    reg ram_o_ena;  
    reg signed [31:0] ram_i_data[7:0];  
    reg signed [8:0] ram_i_addr[7:0];
    reg signed [8:0] ram_o_addr[7:0];

    reg ram_i_ena_reg;  
    reg ram_o_ena_reg;  
    reg signed [31:0] ram_i_data_reg[7:0];  
    reg signed [8:0] ram_i_addr_reg[7:0];
    reg signed [8:0] ram_o_addr_reg[7:0];

    wire signed [31:0] ram_o_data[7:0];  
    wire ram_o_vaild;

    /******************************************************/

    /******************add module ************************/
    fft_ram_in#(8,512,32)fft_ram_in_0(
        .ram_clk(clk),
        .ram_rstn(rst_n),
        .ram_i_ena(ram_i_ena_reg),
        .ram_o_ena(ram_o_ena_reg),
        .ram_i_data(ram_i_data_reg),
        .ram_i_addr(ram_i_addr_reg),
        .ram_o_addr(ram_o_addr_reg),
        .ram_o_data(ram_o_data),
        .ram_o_vaild(ram_o_vaild)
    );
    /******************************************************/

    //clk
    initial                                                
    begin                                                  
        clk = 0;
        forever #(PERIOD/2)
        clk = ~clk;
    end                                                    

    //reset
    task task_reset;
    begin
        rst_n = 1'b0;
        repeat(2) @(negedge clk)
        rst_n = 1'b1;
    end
    endtask

    //
    integer i,j;
    task task_meminit;
    begin
        for(i=0;i<512;i=i+1)begin
            for(j=0;j<8;j=j+1)begin
                data_in[j][i] = i*10+j;
            end
        end
    end
    endtask

    /******************add  logic************************/
    always@(posedge clk)
    begin
        ram_i_ena_reg <= ram_i_ena;
        ram_o_ena_reg <= ram_o_ena;
        ram_i_data_reg<=ram_i_data;
        ram_i_addr_reg<=ram_i_addr;
        ram_o_addr_reg<=ram_o_addr;
    end
    /******************************************************/
    
    initial
    begin	
        task_reset;	
        task_meminit;
        /******************add ops ************************/
        #5;
        ram_i_ena = 1;
        ram_o_ena = 0;
        for(i=0;i<512;i=i+1)begin
            for(j=0;j<8;j=j+1)begin
                ram_i_data[j]=data_in[j][i];
                ram_i_addr[j]=i;
            end
            #PERIOD;
        end
        ram_i_ena = 0;
        ram_o_ena = 1;
        for(i=0;i<512;i=i+1)begin
            for(j=0;j<8;j=j+1)begin
                ram_o_addr[j]=i;
            end
            #PERIOD;
        end
        #200         $finish; 
        /******************************************************/
    end

endmodule
