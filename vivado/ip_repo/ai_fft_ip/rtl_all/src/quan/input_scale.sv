

module input_scale (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire [15:0] scale,  // weight in
    input wire [15:0] din,  // data in
    output wire [31:0] out,
    output reg out_valid
);
    // 这个模块实现了int16和int8情况下的有符号乘法，
    // scale是int16的scale，din是int16的data，或者int8的两个data



    wire [24 - 1:0] a_in;
    wire [ 8 - 1:0] b_in;
    wire [16 - 1:0] c_in;



    assign a_in[23-1:0] = is_int16 ? {{7{din[15]}}, din[15:0]} : {din[14:8], 16'b0};
    assign a_in[24-1] = din[15];
    assign b_in = is_int16 ? 8'b0 : din[7:0];
    assign c_in[15:0] = scale;

    wire [32 - 1:0] mul_dout_r;
    mul_DSP48_simple_dual_8bit_input_scale u_mul_DSP48_simple_dual_8bit_input_scale (
        .clk(clk),
        .rstn(rstn),
        .in_valid(in_valid),
        .a_in(a_in),
        .b_in(b_in),
        .c_in(c_in),
        .mul_dout_r(mul_dout_r),
        .out_valid(out_valid)
    );




    wire [15:0] mul_dout_int8_high = mul_dout_r[31:16] + (is_int16 ? 1'b0 : mul_dout_r[15]);
    assign out[15:0]  = mul_dout_r[15:0];
    assign out[31:16] = mul_dout_int8_high[15:0];


endmodule

(* USE_DSP="yes" *)
module mul_DSP48_simple_dual_8bit_input_scale (
    input wire clk,
    input wire rstn,
    input wire in_valid,
    input signed [24 - 1:0] a_in,
    input signed [8 - 1:0] b_in,
    input signed [16 - 1:0] c_in,
    output reg signed [32 - 1:0] mul_dout_r,
    output reg out_valid
);
    // 模块实现了a*c和b*c的2个8bit乘法，这种情况下2个乘法共用1个相同的乘数

    wire signed [24 - 1:0] a;
    wire signed [ 8 - 1:0] b;
    reg signed  [25 - 1:0] a_add_b_r;

    reg signed  [16 - 1:0] c_r;
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
