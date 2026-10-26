// module split_mul_true_dual_8bit (
//     input wire clk,
//     input wire rstn,
//     input wire is_int16,
//     input wire in_valid,
//     input wire [15:0] in1,  // weight in
//     input wire [15:0] in2,  // data in
//     output wire [31:0] out,
//     output reg out_valid
// );
//     // 这个模块使用2个dsp
//     // 这个模块实现了int16和int8情况下的有符号乘法，
//     // int16情况下，in1是int16的weight，int2是int16的data，int8情况下，in1的高8位和低8位是2个int8的weight，in2的高8位和低8位是2个int8的data

//     wire [16 - 1:0] a_in;
//     wire [16 - 1:0] b_in;

//     assign a_in[16-1:0] = is_int16 ? {in1[15:0]} : {{8{in1[7]}}, in1[7:0]};
//     assign b_in[16-1:0] = is_int16 ? {in2[15:0]} : {{8{in2[7]}}, in2[7:0]};


//     wire [32 - 1:0] mul_dout1;

//     mul_DSP48_one_8bit_or_one_16bit u_mul_DSP48_one_8bit_or_one_16bit (
//         .a_in(a_in),
//         .b_in(b_in),
//         .dout(mul_dout1)
//     );

//     reg signed [32 - 1:0] mul_dout_r1;
//     always @(posedge clk) begin
//         if (in_valid) begin
//             mul_dout_r1 <= mul_dout1;
//         end
//     end

//     wire [16 - 1:0] mul_dout2;
//     reg signed [16 - 1:0] mul_dout_r2;
//     mul_DSP48_one_8bit u_mul_DSP48_one_8bit (
//         .a_in(in1[15:8]),
//         .b_in(in2[15:8]),
//         .dout(mul_dout2)
//     );
//     always @(posedge clk) begin
//         if (in_valid & (~is_int16)) begin
//             mul_dout_r2 <= mul_dout2;
//         end
//     end

//     always @(posedge clk or negedge rstn) begin
//         if (~rstn) begin
//             out_valid <= 0;
//         end else begin
//             out_valid <= in_valid;
//         end
//     end


//     assign out[15:0]  = mul_dout_r1[15:0];
//     assign out[31:16] = is_int16 ? mul_dout_r1[31:16] : {mul_dout_r2[15:0]};

// endmodule


// (* USE_DSP="yes" *)
// module mul_DSP48_one_8bit_or_one_16bit (
//     input  signed [16 - 1:0] a_in,
//     input  signed [16 - 1:0] b_in,
//     output signed [32 - 1:0] dout
// );
//     // 模块实现了1个8bit乘法或者1个16bit乘法

//     wire signed [16 - 1:0] a;
//     wire signed [16 - 1:0] b;

//     wire signed [32 - 1:0] m;


//     assign a = a_in;
//     assign b = b_in;


//     assign m = a * b;

//     assign dout = {m[32-1:0]};



// endmodule


// (* USE_DSP="yes" *)
// module mul_DSP48_one_8bit (
//     input  signed [ 8 - 1:0] a_in,
//     input  signed [ 8 - 1:0] b_in,
//     output signed [16 - 1:0] dout
// );
//     // 模块实现了1个8bit乘法或者1个16bit乘法

//     wire signed [ 8 - 1:0] a;
//     wire signed [ 8 - 1:0] b;

//     wire signed [16 - 1:0] m;


//     assign a = a_in;
//     assign b = b_in;


//     assign m = a * b;

//     assign dout = {m[16-1:0]};

// endmodule


module split_mul_true_dual_8bit (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire [15:0] in1,  // weight in
    input wire [17:0] in2,  // data in
    output wire [31:0] out,
    output reg out_valid
);
    // 这个模块使用2个dsp
    // 这个模块实现了int16和int8情况下的有符号乘法，
    // int16情况下，in1是int16的weight，int2是int17的data，int8情况下，in1的高8位和低8位是2个int8的weight，in2的高9位和低9位是2个int9的data

    wire [16 - 1:0] a_in;
    wire [17 - 1:0] b_in;

    assign a_in[16-1:0] = is_int16 ? {in1[15:0]} : {{8{in1[7]}}, in1[7:0]};
    assign b_in[17-1:0] = is_int16 ? {in2[16:0]} : {{8{in2[8]}}, in2[8:0]};


    wire [32 - 1:0] mul_dout1;

    mul_DSP48_one_8bit_or_one_16bit u_mul_DSP48_one_8bit_or_one_16bit (
        .a_in(a_in),
        .b_in(b_in),
        .dout(mul_dout1)
    );

    reg [32 - 1:0] mul_dout_r1;
    always @(posedge clk) begin
        if (in_valid) begin
            mul_dout_r1 <= mul_dout1;
        end
    end

    wire [16 - 1:0] mul_dout2;
    reg  [16 - 1:0] mul_dout_r2;
    mul_DSP48_one_8bit u_mul_DSP48_one_8bit (
        .a_in(in1[15:8]),
        .b_in(in2[17:9]),
        .dout(mul_dout2)
    );
    always @(posedge clk) begin
        if (in_valid & (~is_int16)) begin
            mul_dout_r2 <= mul_dout2;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid <= 0;
        end else begin
            out_valid <= in_valid;
        end
    end


    assign out[15:0]  = mul_dout_r1[15:0];
    assign out[31:16] = is_int16 ? mul_dout_r1[31:16] : {mul_dout_r2[15:0]};

endmodule


(* USE_DSP="yes" *)
module mul_DSP48_one_8bit_or_one_16bit (
    input  signed [16 - 1:0] a_in,
    input  signed [17 - 1:0] b_in,
    output signed [32 - 1:0] dout
);
    // 模块实现了1个8bit乘法或者1个16bit乘法

    wire signed [16 - 1:0] a;
    wire signed [17 - 1:0] b;

    wire signed [32 - 1:0] m;


    assign a = a_in;
    assign b = b_in;


    assign m = a * b;

    assign dout = {m[32-1:0]};



endmodule


(* USE_DSP="yes" *)
module mul_DSP48_one_8bit (
    input  signed [ 8 - 1:0] a_in,
    input  signed [ 9 - 1:0] b_in,
    output signed [16 - 1:0] dout
);
    // 模块实现了1个8bit乘法或者1个16bit乘法

    wire signed [ 8 - 1:0] a;
    wire signed [ 9 - 1:0] b;

    wire signed [16 - 1:0] m;


    assign a = a_in;
    assign b = b_in;


    assign m = a * b;

    assign dout = {m[16-1:0]};

endmodule
