`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: tb_mdc
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


module tb_mdc();
    localparam PERIOD = 10;

    reg clk;
    reg rst_n;
    reg signed [15:0] data_note[3:0];
    reg signed [15:0] data_in [15:0];  

    /******************add reg ************************/
    reg signed [15:0] rotar_in [63:0];

    reg mdc_ena;
    reg signed [15:0] rotar_1_1_real;
    reg signed [15:0] rotar_1_1_imag;
    reg signed [15:0] rotar_1_2_real;
    reg signed [15:0] rotar_1_2_imag;
    reg signed [15:0] rotar_1_3_real;
    reg signed [15:0] rotar_1_3_imag;
    reg signed [15:0] rotar_1_4_real;
    reg signed [15:0] rotar_1_4_imag;
    reg signed [15:0] real_i_0;
    reg signed [15:0] real_i_1;
    wire signed [15:0] real_o_0;
    wire signed [15:0] imag_o_0;
    wire signed [15:0] real_o_1;
    wire signed [15:0] imag_o_1;
    wire mdc_vaild;

    /******************************************************/

    /******************add module ************************/
    r2_mdc #(16)mdc_0(
        .mdc_clk(clk),
        .mdc_rstn(rst_n),
        .mdc_ena(mdc_ena),
        .rotar_1_1_real(rotar_1_1_real),
        .rotar_1_1_imag(rotar_1_1_imag),
        .rotar_1_2_real(rotar_1_2_real),
        .rotar_1_2_imag(rotar_1_2_imag),
        .rotar_1_3_real(rotar_1_3_real),
        .rotar_1_3_imag(rotar_1_3_imag),
        .rotar_1_4_real(rotar_1_4_real),
        .rotar_1_4_imag(rotar_1_4_imag),
        .real_i_0(real_i_0),
        .imag_i_0(16'b0),
        .real_i_1(real_i_1),
        .imag_i_1(16'b0),
        .real_o_0(real_o_0),
        .imag_o_0(imag_o_0),
        .real_o_1(real_o_1),
        .imag_o_1(imag_o_1),
        .mdc_vaild(mdc_vaild)
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

    //read file
    integer fd_x0;    
    integer fd_x1;    
    task task_meminit;
    begin
        $readmemb("D:/project_PLF/FFTAI/software/fft_software/m/fft_i_16.txt",data_in);
        $readmemb("D:/project_PLF/FFTAI/software/fft_software/m/rotar_16.txt",rotar_in);
        fd_x0 = $fopen("D:/project_PLF/FFTAI/software/fft_software/m/fft_o_16_real.txt",  "w");
        fd_x1 = $fopen("D:/project_PLF/FFTAI/software/fft_software/m/fft_o_16_imag.txt",  "w");
        if (! fd_x0) begin
            $display("--- iii --- Failed to open file Z_fir");
        end
        else begin
            $display("--- iii --- Z_fir has been opened successfully.");
        end
    end
    endtask

    //write file
    always@(posedge clk)
    begin
        if(mdc_vaild)begin
            data_note[0] = real_o_0;
            data_note[1] = real_o_1;
            data_note[2] = imag_o_0;
            data_note[3] = imag_o_1;
            $fwrite(fd_x0,"%d ",data_note[0]);
            $fwrite(fd_x0,"%d ",data_note[1]);
            $fwrite(fd_x1,"%d ",data_note[2]);
            $fwrite(fd_x1,"%d ",data_note[3]);
        end
    end

    /******************add  logic************************/

    /******************************************************/
    
    
    integer  i ;
    initial
    begin	
        task_reset;	
        task_meminit;
        /******************add ops ************************/
        #5 mdc_ena = 0;
        #PERIOD mdc_ena = 1;
        for (i=0; i<2; i=i+1) begin
            real_i_0 = data_in[i*2];
            real_i_1 = data_in[i*2+1];
            rotar_1_1_real = rotar_in[i*2];
            rotar_1_1_imag = rotar_in[i*2+1];
            #PERIOD;
        end
        for (i=2; i<5; i=i+1) begin
            real_i_0 = data_in[i*2];
            real_i_1 = data_in[i*2+1];
            rotar_1_1_real = rotar_in[i*2];
            rotar_1_1_imag = rotar_in[i*2+1];
            rotar_1_2_real = rotar_in[16+(i-2)*2];
            rotar_1_2_imag = rotar_in[16+(i-2)*2+1];
            #PERIOD;
        end
        for (i=5; i<8; i=i+1) begin
            real_i_0 = data_in[i*2];
            real_i_1 = data_in[i*2+1];
            rotar_1_1_real = rotar_in[i*2];
            rotar_1_1_imag = rotar_in[i*2+1];
            rotar_1_2_real = rotar_in[16+(i-2)*2];
            rotar_1_2_imag = rotar_in[16+(i-2)*2+1];
            rotar_1_3_real = rotar_in[32+(i-5)*2];
            rotar_1_3_imag = rotar_in[32+(i-5)*2+1];
            #PERIOD;
        end
        mdc_ena = 0;
        for (i=8; i<10; i=i+1) begin
            rotar_1_2_real = rotar_in[16+(i-2)*2];
            rotar_1_2_imag = rotar_in[16+(i-2)*2+1];
            rotar_1_3_real = rotar_in[32+(i-5)*2];
            rotar_1_3_imag = rotar_in[32+(i-5)*2+1];
            #PERIOD;
        end
        for (i=10; i<13; i=i+1) begin
            rotar_1_3_real = rotar_in[32+(i-5)*2];
            rotar_1_3_imag = rotar_in[32+(i-5)*2+1];
            rotar_1_4_real = rotar_in[48+(i-10)*2];
            rotar_1_4_imag = rotar_in[48+(i-10)*2+1];
            #PERIOD;
        end
        for (i=13; i<18; i=i+1) begin
            rotar_1_4_real = rotar_in[48+(i-10)*2];
            rotar_1_4_imag = rotar_in[48+(i-10)*2+1];
            #PERIOD;
        end
        #200 $fclose(fd_x0);
        $fclose(fd_x1);
        #200 $finish;
        /******************************************************/
    end

    // //finish
    // initial
    // begin
    //     #1000010000  $fclose(fd_x);
    //     #200         $finish; 
    // end
endmodule
