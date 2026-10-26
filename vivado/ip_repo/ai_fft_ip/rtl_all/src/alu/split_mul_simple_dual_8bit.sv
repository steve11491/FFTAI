

module split_mul_simple_dual_8bit (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire [15:0] in1,  // weight in
    input wire [16:0] in2,  // data in
    output wire [31:0] out,
    output reg out_valid
);
    // 这个模块实现了int16和int8情况下的有符号乘法，
    // int16情况下，in1是int16的weight，int2是int17的data，int8情况下，in1的高8位和低8位是2个int8的weight，in2的低9位有效，是int8的data



    wire [24 - 1:0] a_in;
    wire [ 8 - 1:0] b_in;
    wire [17 - 1:0] c_in;



    assign a_in[23-1:0] = is_int16 ? {{7{in1[15]}}, in1[15:0]} : {in1[14:8], 16'b0};
    assign a_in[24-1] = in1[15];
    assign b_in = is_int16 ? 8'b0 : in1[7:0];

    assign c_in[16:9] = is_int16 ? in2[16:9] : {7{in2[8]}};
    assign c_in[8:0] = in2[8:0];

    wire [32 - 1:0] mul_dout_r;
    mul_DSP48_simple_dual_8bit u_mul_DSP48_simple_dual_8bit (
        .clk(clk),
        .rstn(rstn),
        .in_valid(in_valid),
        .a_in(a_in),
        .b_in(b_in),
        .c_in(c_in),
        .mul_dout_r(mul_dout_r),
        .out_valid(out_valid)
    );




    wire signed [15:0] mul_dout_int8_high = mul_dout_r[31:16] + (is_int16 ? 1'b0 : mul_dout_r[15]);
    assign out[15:0]  = mul_dout_r[15:0];
    assign out[31:16] = mul_dout_int8_high[15:0];


endmodule


(* USE_DSP="yes" *)
module mul_DSP48_simple_dual_8bit (
    input wire clk,
    input wire rstn,
    input wire in_valid,
    input signed [24 - 1:0] a_in,
    input signed [8 - 1:0] b_in,
    input signed [17 - 1:0] c_in,
    output reg signed [32 - 1:0] mul_dout_r,
    output reg out_valid
);
    // 模块实现了a*c和b*c的2个8bit乘法，这种情况下2个乘法共用1个相同的乘数

    wire signed [24 - 1:0] a;
    wire signed [ 8 - 1:0] b;
    reg signed  [25 - 1:0] a_add_b_r;

    reg signed  [17 - 1:0] c_r;
    wire signed [32 - 1:0] m;

    assign a = a_in;
    assign b = b_in;
    reg in_valid_w;
    // assign a_add_b_r = a + b;
    // assign c_r = c_in;
    // assign in_valid_w=in_valid;

    always @(posedge clk) begin
        if (in_valid) begin
            a_add_b_r <= a + b;
            c_r <= c_in;
        end
    end
    always @(posedge clk or posedge rstn) begin
        if (~rstn) begin
            in_valid_w <= 0;
        end else begin
            in_valid_w <= in_valid;
        end

    end
    assign m = a_add_b_r * c_r;

    wire [32 - 1:0] mul_dout;
    assign mul_dout = {m[32-1:0]};


    always @(posedge clk) begin
        if (in_valid_w) begin
            mul_dout_r <= mul_dout;
        end

    end
    always @(posedge clk or posedge rstn) begin
        if (~rstn) begin
            out_valid <= 0;
        end else begin
            out_valid <= in_valid_w;
        end

    end

endmodule

