`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: tb_basic_pe
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: compute A*B+C and FFT R2
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_basic_pe();
    localparam PERIOD = 10;

    reg clk;
    reg rst_n;

    /******************add reg ************************/
    reg signed[15:0] A[1:0][1:0] = '{'{16'd3,16'd5},'{16'd8,16'd8}};
    reg signed[15:0] B[1:0][1:0] = '{'{-16'd2,16'd6},'{16'd0,-16'd1}};
    reg signed[15:0] C[1:0][1:0] = '{'{16'd1,16'd0},'{-16'd1,-16'd1}};
    reg signed[15:0] Wk[1:0] = {16'd5,16'd25};

    reg mode;
    reg stage;
    reg acc_ena;

    reg signed[15:0] add_i_0[1:0];
    reg signed[15:0] add_i_1[1:0];
    reg signed[15:0] mul_i[1:0];
    reg signed[15:0] weight[1:0][1:0];

    wire signed[31:0] add_o[1:0];
    wire signed[31:0] mul_o[1:0];

    /******************************************************/

    /******************add module ************************/
    basic_pe #(
        .ADD_WIDTH(16),
        .MUL_WIDTH(16),
        .WEIGHT_WIDTH(16)
    ) pe_0(
        .clk(clk),
        .rstn(rst_n),
        .mode(mode), 
        .stage(stage),
        .acc_ena(acc_ena),
        .add_i_0(add_i_0),
        .add_i_1(add_i_1),
        .mul_i(mul_i),
        .weight(weight),
        .add_o(add_o),
        .mul_o(mul_o)
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

    /******************add  logic************************/

    /******************************************************/
    
    initial
    begin	
        task_reset;	
        /******************add ops ************************/
        #5
        add_i_0 = C[0];
        mul_i = A[0];
        weight = B;
        mode = 0;
        stage = 1;
        #PERIOD acc_ena = 1;
        add_i_0 = C[1];
        mul_i = A[1];
        #PERIOD acc_ena = 1;
        #PERIOD acc_ena = 0;
        #200 weight[0] = Wk;
        add_i_0 = C[0];
        mul_i = A[0];
        mode = 1;
        #PERIOD 
        mode = 0;
        /******************************************************/
    end

    //finish
    initial
    begin
        #1000
        #200         $finish; 
    end
endmodule
