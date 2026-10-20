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


module tb_ctrl();
    localparam PERIOD = 10;

    parameter MAX_POINT = 4096;
    parameter MDC_PARALLEL = 8;
    parameter MDC_STAGE = 4;
    parameter DATA_WIDTH = 16;   //FFT data width
    parameter REG_WIDTH = 32;
    parameter AXI_WIDTH = 32;
    parameter AXI_NUM = 1;//only suport 4 or 1

    parameter FFT_POINT = 12;

    reg clk;
    reg rst_n;
    reg signed [DATA_WIDTH*2-1:0] data_in [MAX_POINT-1:0];  

    /******************add reg ************************/
    reg axi_i_vaild;  
    reg axi_o_ready;
    reg signed [AXI_WIDTH-1:0] axi_i_data[AXI_NUM-1:0];  
    reg signed [REG_WIDTH-1:0] fft_stag;
    reg signed [REG_WIDTH-1:0] fft_cr;

    reg axi_i_vaild_reg;  
    reg axi_o_ready_reg;  
    reg signed [AXI_WIDTH-1:0] axi_i_data_reg[AXI_NUM-1:0];  
    reg signed [REG_WIDTH-1:0] fft_stag_reg;
    reg signed [REG_WIDTH-1:0] fft_cr_reg;

    wire [AXI_WIDTH-1:0] axi_o_data[AXI_NUM-1:0];
    wire axi_i_ready;
    wire axi_o_vaild;

    /******************************************************/

    /******************add module ************************/
    fft_top#(MAX_POINT,MDC_PARALLEL,MDC_STAGE,DATA_WIDTH,AXI_WIDTH,AXI_NUM,REG_WIDTH)
    TOP(
        .clk(clk),
        .rst_n(rst_n),
        .axi_i_vaild(axi_i_vaild_reg),
        .axi_o_ready(axi_o_ready_reg),
        .axi_i_data(axi_i_data_reg),
        .fft_cr(fft_cr_reg),
        .fft_stage(FFT_POINT),//9�??10�??11�??12
        .axi_o_data(axi_o_data),
        .axi_i_ready(axi_i_ready),
        .axi_o_vaild(axi_o_vaild)
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
    integer fd_x0;     
    task task_meminit;
    begin
        fd_x0 = $fopen("E:/v/fft/m/fft_o_4096_test.txt",  "w");
        for(i=0;i<MAX_POINT;i=i+1)begin
            data_in[i] = i;
        end
    end
    endtask

    //write file
    always@(posedge clk)
    begin
        if(axi_o_vaild)begin
            $fwrite(fd_x0,"%d ",axi_o_data[0]);
        end
    end

    /******************add  logic************************/
    always@(posedge clk)
    begin
        axi_i_vaild_reg <= axi_i_vaild;
        axi_o_ready_reg <= axi_o_ready;
        fft_stag_reg<=fft_stag;
        fft_cr_reg<=fft_cr;
    end

    integer  b ;
    always@(posedge clk)
    begin
        for(b=0;b<AXI_NUM;b=b+1)begin
            axi_i_data_reg[b] <= axi_i_data[b];
        end
    end
    /******************************************************/
    
    initial
    begin	
        task_reset;	
        task_meminit;
        /******************add ops ************************/
        #5;
        axi_i_vaild = 1;
        axi_o_ready = 0;
        fft_cr=1;
        for(i=0;i<(1<<FFT_POINT);i=i+1)begin
            axi_i_data[0]=data_in[i];
            #PERIOD;
        end
        axi_i_vaild = 0;
        #100 fft_cr=2;
        #20000         
        axi_o_ready = 1;
        #50000 
        axi_o_ready = 0; 

        #200 $fclose(fd_x0);

        #100  $finish; 
        /******************************************************/
    end

endmodule
