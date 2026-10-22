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


module tb_ctrl_256();
    localparam PERIOD = 10;

    parameter MAX_POINT = 4096;
    parameter MDC_PARALLEL = 32;
    parameter MDC_STAGE = 4;
    parameter DATA_WIDTH = 16;   //FFT data width
    parameter REG_WIDTH = 32;
    parameter AXI_WIDTH = 64;
    parameter AXI_NUM = 4;//only suport 4 or 1

    parameter SIGN_LEN = 10;

    parameter FFT_POINT = 12;

    reg clk;
    reg rst_n;
    reg signed [DATA_WIDTH*2-1:0] data_in [MAX_POINT-1:0]; 
    reg [FFT_POINT:0] data_out_cnt; 
    reg signed [DATA_WIDTH*2-1:0] data_out [MAX_POINT-1:0];  

    /******************add reg ************************/
    reg axi_i_vaild;  
    reg axi_o_ready;
    reg signed [AXI_WIDTH-1:0] axi_i_data[AXI_NUM-1:0];  
    reg signed [REG_WIDTH-1:0] fft_cr;

    reg axi_i_vaild_reg;  
    reg axi_o_ready_reg;  
    reg signed [AXI_WIDTH-1:0] axi_i_data_reg[AXI_NUM-1:0];  
    reg signed [REG_WIDTH-1:0] fft_cr_reg;

    wire [AXI_WIDTH-1:0] axi_o_data[AXI_NUM-1:0];
    wire [REG_WIDTH-1:0] fft_sr;
    wire axi_i_ready;
    wire axi_o_vaild;

    reg [DATA_WIDTH*2-1:0] axi_data[7:0];

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
        .axi_o_data(axi_o_data),
        .fft_sr(fft_sr),
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
        fd_x0 = $fopen("D:/project_PLF/FFTAI/software/fft_software/m/fft_o_4096_test.txt",  "w");
        for(i=0;i<MAX_POINT;i=i+1)begin
            data_in[i] = i;
        end
    end
    endtask

    //write file
    always@(posedge clk)
    begin
        if(axi_o_vaild)begin 
            axi_data[0] <= axi_o_data[0][DATA_WIDTH*2-1:0];
            axi_data[1] <= axi_o_data[0][DATA_WIDTH*4-1:DATA_WIDTH*2];
            axi_data[2] <= axi_o_data[1][DATA_WIDTH*2-1:0];
            axi_data[3] <= axi_o_data[1][DATA_WIDTH*4-1:DATA_WIDTH*2];
            axi_data[4] <= axi_o_data[2][DATA_WIDTH*2-1:0];
            axi_data[5] <= axi_o_data[2][DATA_WIDTH*4-1:DATA_WIDTH*2];
            axi_data[6] <= axi_o_data[3][DATA_WIDTH*2-1:0];
            axi_data[7] <= axi_o_data[3][DATA_WIDTH*4-1:DATA_WIDTH*2];
            
            data_out[data_out_cnt] <= axi_o_data[0][DATA_WIDTH*2-1:0];
            data_out[data_out_cnt+1] <= axi_o_data[0][DATA_WIDTH*4-1:DATA_WIDTH*2];
            data_out[data_out_cnt+(1<<(FFT_POINT-2))] <= axi_o_data[1][DATA_WIDTH*2-1:0];
            data_out[data_out_cnt+1+(1<<(FFT_POINT-2))] <= axi_o_data[1][DATA_WIDTH*4-1:DATA_WIDTH*2];
            data_out[data_out_cnt+(1<<(FFT_POINT-1))] <= axi_o_data[2][DATA_WIDTH*2-1:0];
            data_out[data_out_cnt+1+(1<<(FFT_POINT-1))] <= axi_o_data[2][DATA_WIDTH*4-1:DATA_WIDTH*2];
            data_out[data_out_cnt+(1<<(FFT_POINT-2))+(1<<(FFT_POINT-1))] <= axi_o_data[3][DATA_WIDTH*2-1:0];
            data_out[data_out_cnt+1+(1<<(FFT_POINT-2))+(1<<(FFT_POINT-1))] <= axi_o_data[3][DATA_WIDTH*4-1:DATA_WIDTH*2];
        end
    end

    always@(posedge clk)
    begin
        if(axi_o_vaild)begin
            if(data_out_cnt==((1<<(FFT_POINT-2))-2))begin
                data_out_cnt <= 0;
            end
            else begin
                data_out_cnt <= data_out_cnt + 2;
            end
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
        fft_cr=(FFT_POINT<<12);
        fft_cr[1] = 1;
        #20;
        data_out_cnt = 0;
        axi_i_vaild = 1;
        axi_o_ready = 1;
        
        for(j=0;j<SIGN_LEN;j=j+1)begin
            axi_i_vaild = 1;
            for(i=0;i<(1<<(FFT_POINT-2));i=i+2)begin
                axi_i_data[0]={data_in[i+1],data_in[i]};
                axi_i_data[1]={data_in[i+1+(1<<(FFT_POINT-2))],data_in[i+(1<<(FFT_POINT-2))]};
                axi_i_data[2]={data_in[i+1+(1<<(FFT_POINT-1))],data_in[i+(1<<(FFT_POINT-1))]};
                axi_i_data[3]={data_in[i+1+(1<<(FFT_POINT-2))+(1<<(FFT_POINT-1))],data_in[i+(1<<(FFT_POINT-2))+(1<<(FFT_POINT-1))]};
                #PERIOD;
            end
            axi_i_vaild = 0;
            #50;
            while(!axi_i_ready)begin
                #PERIOD;
            end
        end

        #20000

        axi_o_ready = 0;

        for(i=0;i<(1<<(FFT_POINT));i=i+1)begin
            $fwrite(fd_x0,"%d ",data_out[i]);
            #PERIOD;
        end

        #200 $fclose(fd_x0);

        #100  $finish; 
        /******************************************************/
    end

endmodule
