//=================================================================================
//
// Description: BASIC FFT PE
//
//=================================================================================
// `define DEBUG

module basic_pe #(
    parameter FFT_WIDTH = 16
) (
    input clk,
    input rstn,
    input ena,
    input signed [FFT_WIDTH-1:0] add_i_real,
    input signed [FFT_WIDTH-1:0] add_i_imag,
    input signed [FFT_WIDTH-1:0] mul_i_real,
    input signed [FFT_WIDTH-1:0] mul_i_imag,
    input signed [FFT_WIDTH-1:0] Wnk_real,
    input signed [FFT_WIDTH-1:0] Wnk_imag,
    output signed [FFT_WIDTH:0] add_o_real,
    output signed [FFT_WIDTH:0] add_o_imag,
    output signed [FFT_WIDTH:0] mul_o_real,
    output signed [FFT_WIDTH:0] mul_o_imag,
    output vaild
); 

localparam DECIMAL_POINT = 15;
localparam PE_DELAY = 2;

//mult 1 stage
reg signed [FFT_WIDTH*2-1:0] mult_real;
reg signed [FFT_WIDTH*2-1:0] mult_imag;
reg mult_vaild;

always@(posedge clk)begin
    if(!rstn)begin
        mult_real <= {(FFT_WIDTH*2+1){1'b0}};
        mult_imag <= {(FFT_WIDTH*2+1){1'b0}};
        mult_vaild <= 1'b0;
    end
    else if(ena)begin
        mult_real <= Wnk_real*mul_i_real - Wnk_imag*mul_i_imag;
        mult_imag <= Wnk_real*mul_i_imag + Wnk_imag*mul_i_real;
        mult_vaild <= 1'b1;
    end
    else begin
        mult_vaild <= 1'b0;
    end
end

wire signed [FFT_WIDTH:0]mult_real_buff = mult_real[FFT_WIDTH+DECIMAL_POINT:DECIMAL_POINT];
wire signed [FFT_WIDTH:0]mult_imag_buff = mult_imag[FFT_WIDTH+DECIMAL_POINT:DECIMAL_POINT];

reg signed [FFT_WIDTH:0] add_i_real_buf;
reg signed [FFT_WIDTH:0] add_i_imag_buf;

always@(posedge clk)begin
    if(!rstn)begin
        add_i_real_buf <= {(FFT_WIDTH+1){1'b0}};
        add_i_imag_buf <= {(FFT_WIDTH+1){1'b0}};
    end
    else begin
        add_i_real_buf <= add_i_real;
        add_i_imag_buf <= add_i_imag;
    end
end

//BF 2 stage
reg signed [FFT_WIDTH:0] add_o_real_buf;
reg signed [FFT_WIDTH:0] add_o_imag_buf;
reg signed [FFT_WIDTH:0] mul_o_real_buf;
reg signed [FFT_WIDTH:0] mul_o_imag_buf;
reg bf_vaild;

always@(posedge clk)begin
    if(!rstn)begin
        add_o_real_buf <= {(FFT_WIDTH+1){1'b0}};
        add_o_imag_buf <= {(FFT_WIDTH+1){1'b0}};
        mul_o_real_buf <= {(FFT_WIDTH+1){1'b0}};
        mul_o_imag_buf <= {(FFT_WIDTH+1){1'b0}};
        bf_vaild <= 1'b0;
    end
    else if(mult_vaild)begin
        add_o_real_buf <= add_i_real_buf + mult_real_buff;
        add_o_imag_buf <= add_i_imag_buf + mult_imag_buff;
        mul_o_real_buf <= add_i_real_buf - mult_real_buff;
        mul_o_imag_buf <= add_i_imag_buf - mult_imag_buff;
        bf_vaild <= 1'b1;
    end
    else begin
        bf_vaild <= 1'b0;
    end
end

//BF 1 loop 
reg signed [FFT_WIDTH:0] add_o_real_delay[1:0];
reg signed [FFT_WIDTH:0] add_o_imag_delay[1:0];
reg signed [FFT_WIDTH:0] mul_o_real_delay[1:0];
reg signed [FFT_WIDTH:0] mul_o_imag_delay[1:0];
always @(posedge clk)begin
    add_o_real_delay[0]<=add_o_real_buf;
    add_o_imag_delay[0]<=add_o_imag_buf;
    mul_o_real_delay[0]<=mul_o_real_buf;
    mul_o_imag_delay[0]<=mul_o_imag_buf;
    add_o_real_delay[1]<=add_o_real_delay[0];
    add_o_imag_delay[1]<=add_o_imag_delay[0];
    mul_o_real_delay[1]<=mul_o_real_delay[0];
    mul_o_imag_delay[1]<=mul_o_imag_delay[0];
end


`ifdef DEBUG
    //测试逻辑没有实际功能，测试完成后需删除
    reg [FFT_WIDTH:0] add_o_real_buf_0;
    reg [FFT_WIDTH:0] add_o_imag_buf_0;
    reg [FFT_WIDTH:0] mul_o_real_buf_0;
    reg [FFT_WIDTH:0] mul_o_imag_buf_0;
    reg [FFT_WIDTH:0] add_o_real_buf_1;
    reg [FFT_WIDTH:0] add_o_imag_buf_1;
    reg [FFT_WIDTH:0] mul_o_real_buf_1;
    reg [FFT_WIDTH:0] mul_o_imag_buf_1;
    reg [FFT_WIDTH:0] add_o_real_buf_2;
    reg [FFT_WIDTH:0] add_o_imag_buf_2;
    reg [FFT_WIDTH:0] mul_o_real_buf_2;
    reg [FFT_WIDTH:0] mul_o_imag_buf_2;
    reg [FFT_WIDTH:0] add_o_real_buf_3;
    reg [FFT_WIDTH:0] add_o_imag_buf_3;
    reg [FFT_WIDTH:0] mul_o_real_buf_3;
    reg [FFT_WIDTH:0] mul_o_imag_buf_3;
    always@(posedge clk)begin
        if(!rstn)begin
            add_o_real_buf_0 <= {(FFT_WIDTH+1){1'b0}};
            add_o_imag_buf_0 <= {(FFT_WIDTH+1){1'b0}};
            mul_o_real_buf_0 <= {(FFT_WIDTH+1){1'b0}};
            mul_o_imag_buf_0 <= {(FFT_WIDTH+1){1'b0}}; 
            add_o_real_buf_1 <= {(FFT_WIDTH+1){1'b0}};
            add_o_imag_buf_1 <= {(FFT_WIDTH+1){1'b0}};
            mul_o_real_buf_1 <= {(FFT_WIDTH+1){1'b0}};
            mul_o_imag_buf_1 <= {(FFT_WIDTH+1){1'b0}};
            add_o_real_buf_2 <= {(FFT_WIDTH+1){1'b0}};
            add_o_imag_buf_2 <= {(FFT_WIDTH+1){1'b0}};
            mul_o_real_buf_2 <= {(FFT_WIDTH+1){1'b0}};
            mul_o_imag_buf_2 <= {(FFT_WIDTH+1){1'b0}};
            add_o_real_buf_3 <= {(FFT_WIDTH+1){1'b0}};
            add_o_imag_buf_3 <= {(FFT_WIDTH+1){1'b0}};
            mul_o_real_buf_3 <= {(FFT_WIDTH+1){1'b0}};
            mul_o_imag_buf_3 <= {(FFT_WIDTH+1){1'b0}};
        end
        else begin
            add_o_real_buf_0 <= add_i_real*2;
            add_o_imag_buf_0 <= add_i_imag*2;
            mul_o_real_buf_0 <= mul_i_real*2;
            mul_o_imag_buf_0 <= mul_i_imag*2; 
            add_o_real_buf_1 <= add_o_real_buf_0;
            add_o_imag_buf_1 <= add_o_imag_buf_0;
            mul_o_real_buf_1 <= mul_o_real_buf_0;
            mul_o_imag_buf_1 <= mul_o_imag_buf_0;
            add_o_real_buf_2 <= add_o_real_buf_1;
            add_o_imag_buf_2 <= add_o_imag_buf_1;
            mul_o_real_buf_2 <= mul_o_real_buf_1;
            mul_o_imag_buf_2 <= mul_o_imag_buf_1;
            add_o_real_buf_3 <= add_o_real_buf_2;
            add_o_imag_buf_3 <= add_o_imag_buf_2;
            mul_o_real_buf_3 <= mul_o_real_buf_2;
            mul_o_imag_buf_3 <= mul_o_imag_buf_2;
        end
    end

    assign add_o_real = add_o_real_buf_3;
    assign add_o_imag = add_o_imag_buf_3;
    assign mul_o_real = mul_o_real_buf_3;
    assign mul_o_imag = mul_o_imag_buf_3;
`else
    assign add_o_real = add_o_real_delay[1];
    assign add_o_imag = add_o_imag_delay[1];
    assign mul_o_real = mul_o_real_delay[1];
    assign mul_o_imag = mul_o_imag_delay[1];
`endif 

reg vaild_reg[1:0];
always @(posedge clk)begin
    vaild_reg[0] <= bf_vaild;
    vaild_reg[1] <= vaild_reg[0];
end
assign vaild = vaild_reg[1];


endmodule
