`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: tb_mdc_8p
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


module tb_mdc_8p();
    localparam PERIOD = 10;

    reg clk;
    reg rst_n;
    wire signed [15:0] data_note[15:0];
    reg signed [15:0] data_in [127:0];  

    /******************add reg ************************/
    localparam DATA_WIDTH = 16;
    reg signed [15:0] rotar_in [63:0];

    reg ena;
    reg [3:0] fft_stage;
    reg signed [15:0] rotar_1_1_real;
    reg signed [15:0] rotar_1_1_imag;
    reg signed [15:0] rotar_1_2_real;
    reg signed [15:0] rotar_1_2_imag;
    reg signed [15:0] rotar_1_3_real;
    reg signed [15:0] rotar_1_3_imag;
    reg signed [15:0] rotar_1_4_real;
    reg signed [15:0] rotar_1_4_imag;
    reg [2*DATA_WIDTH-1:0] data_i[8-1:0];

    reg ena_reg;
    reg [3:0] fft_stage_reg;
    reg signed [15:0] rotar_1_1_real_reg;
    reg signed [15:0] rotar_1_1_imag_reg;
    reg signed [15:0] rotar_1_2_real_reg;
    reg signed [15:0] rotar_1_2_imag_reg;
    reg signed [15:0] rotar_1_3_real_reg;
    reg signed [15:0] rotar_1_3_imag_reg;
    reg signed [15:0] rotar_1_4_real_reg;
    reg signed [15:0] rotar_1_4_imag_reg;
    reg [2*DATA_WIDTH-1:0] data_i_reg[8-1:0];

    wire mdc_vaild;

    /******************************************************/

    /******************add module ************************/
    r2_mdc_8p#(16)mdc_p0(
        .fft_clk(clk),
        .fft_rstn(rst_n),
        .fft_ena(ena_reg),
        .fft_stage(fft_stage_reg),

        .rotar_1_real(rotar_1_1_real_reg),
        .rotar_1_imag(rotar_1_1_imag_reg),
        .rotar_2_real(rotar_1_2_real_reg),
        .rotar_2_imag(rotar_1_2_imag_reg),
        .rotar_3_real(rotar_1_3_real_reg),
        .rotar_3_imag(rotar_1_3_imag_reg),
        .rotar_4_real(rotar_1_4_real_reg),
        .rotar_4_imag(rotar_1_4_imag_reg),

        .real_i_1(data_i_reg[0][2*DATA_WIDTH-1:DATA_WIDTH]),
        .imag_i_1(data_i_reg[0][DATA_WIDTH-1:0]),
        .real_i_2(data_i_reg[1][2*DATA_WIDTH-1:DATA_WIDTH]),
        .imag_i_2(data_i_reg[1][DATA_WIDTH-1:0]),
        .real_i_3(data_i_reg[2][2*DATA_WIDTH-1:DATA_WIDTH]),
        .imag_i_3(data_i_reg[2][DATA_WIDTH-1:0]),
        .real_i_4(data_i_reg[3][2*DATA_WIDTH-1:DATA_WIDTH]),
        .imag_i_4(data_i_reg[3][DATA_WIDTH-1:0]),
        .real_i_5(data_i_reg[4][2*DATA_WIDTH-1:DATA_WIDTH]),
        .imag_i_5(data_i_reg[4][DATA_WIDTH-1:0]),
        .real_i_6(data_i_reg[5][2*DATA_WIDTH-1:DATA_WIDTH]),
        .imag_i_6(data_i_reg[5][DATA_WIDTH-1:0]),
        .real_i_7(data_i_reg[6][2*DATA_WIDTH-1:DATA_WIDTH]),
        .imag_i_7(data_i_reg[6][DATA_WIDTH-1:0]),
        .real_i_8(data_i_reg[7][2*DATA_WIDTH-1:DATA_WIDTH]),
        .imag_i_8(data_i_reg[7][DATA_WIDTH-1:0]),

        .real_o_1(data_note[0]),
        .imag_o_1(data_note[1]),
        .real_o_2(data_note[2]),
        .imag_o_2(data_note[3]),
        .real_o_3(data_note[4]),
        .imag_o_3(data_note[5]),
        .real_o_4(data_note[6]),
        .imag_o_4(data_note[7]),
        .real_o_5(data_note[8]),
        .imag_o_5(data_note[9]),
        .real_o_6(data_note[10]),
        .imag_o_6(data_note[11]),
        .real_o_7(data_note[12]),
        .imag_o_7(data_note[13]),
        .real_o_8(data_note[14]),
        .imag_o_8(data_note[15]),

        .fft_vaild(mdc_vaild)
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
        $readmemb("E:/v/fft/m/fft_i_64.txt",data_in);
        $readmemb("E:/v/fft/m/rotar_64.txt",rotar_in);
        fd_x0 = $fopen("E:/v/fft/m/fft_o_64_real.txt",  "w");
        fd_x1 = $fopen("E:/v/fft/m/fft_o_64_imag.txt",  "w");
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
            $fwrite(fd_x0,"%d ",data_note[0]);
            $fwrite(fd_x0,"%d ",data_note[2]);
            $fwrite(fd_x0,"%d ",data_note[4]);
            $fwrite(fd_x0,"%d ",data_note[6]);
            $fwrite(fd_x0,"%d ",data_note[8]);
            $fwrite(fd_x0,"%d ",data_note[10]);
            $fwrite(fd_x0,"%d ",data_note[12]);
            $fwrite(fd_x0,"%d ",data_note[14]);

            $fwrite(fd_x1,"%d ",data_note[1]);
            $fwrite(fd_x1,"%d ",data_note[3]);
            $fwrite(fd_x1,"%d ",data_note[5]);
            $fwrite(fd_x1,"%d ",data_note[7]);
            $fwrite(fd_x1,"%d ",data_note[9]);
            $fwrite(fd_x1,"%d ",data_note[11]);
            $fwrite(fd_x1,"%d ",data_note[13]);
            $fwrite(fd_x1,"%d ",data_note[15]);
        end
    end

    /******************add  logic************************/
    integer j;
    always@(posedge clk)
    begin
        ena_reg <= ena;
        fft_stage_reg<=fft_stage;
        rotar_1_1_real_reg<=rotar_1_1_real;
        rotar_1_1_imag_reg<=rotar_1_1_imag;
        rotar_1_2_real_reg<=rotar_1_2_real;
        rotar_1_2_imag_reg<=rotar_1_2_imag;
        rotar_1_3_real_reg<=rotar_1_3_real;
        rotar_1_3_imag_reg<=rotar_1_3_imag;
        rotar_1_4_real_reg<=rotar_1_4_real;
        rotar_1_4_imag_reg<=rotar_1_4_imag;
        for(j=0;j<8;j=j+1)begin
            data_i_reg[j]<=data_i[j];
        end
    end
    /******************************************************/
    
    
    integer  i ;
    initial
    begin	
        task_reset;	
        task_meminit;
        /******************add ops ************************/
        #5 ena = 0;
        fft_stage = 4'b0010;
        // fft_stage = 4'b1000;
        #PERIOD ena = 1;
        for(i=0;i<8;i=i+1)begin
            data_i[0]={data_in[4*i],data_in[4*i+1]};
            data_i[1]={data_in[4*i+2],data_in[4*i+3]};
            data_i[2]={data_in[4*i+32],data_in[4*i+33]};
            data_i[3]={data_in[4*i+34],data_in[4*i+35]};
            data_i[4]={data_in[4*i+64],data_in[4*i+65]};
            data_i[5]={data_in[4*i+66],data_in[4*i+67]};
            data_i[6]={data_in[4*i+96],data_in[4*i+97]};
            data_i[7]={data_in[4*i+98],data_in[4*i+99]};
            rotar_1_1_real=rotar_in[8*i];
            rotar_1_1_imag=rotar_in[8*i+1];
            rotar_1_2_real=rotar_in[8*i+2];
            rotar_1_2_imag=rotar_in[8*i+3];
            rotar_1_3_real=rotar_in[8*i+4];
            rotar_1_3_imag=rotar_in[8*i+5];
            rotar_1_4_real=rotar_in[8*i+6];
            rotar_1_4_imag=rotar_in[8*i+7];
            #PERIOD;
        end
        ena = 0;

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
