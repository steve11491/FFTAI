
module split_add_equal_width #(
    parameter LS_WIDTH = 16,
    parameter MS_WIDTH = 16,
    parameter WIDTH = LS_WIDTH + MS_WIDTH
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    output logic [WIDTH-1:0] out,
    output logic out_valid
);

    // 这个模块实现了int16和int8情况下的有符号加法(输入输出等宽,使用截断)，
    // int16时，输入是一个int32，输出是一个int32，int8时，输入int32的低16位和高16位为2个int16，输出int34是2个int16
    // int16: 32-1:0 out;
    // int8: 32-1:16 out1; 15:0 out2

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid <= 0;
        end else begin
            out_valid <= in_valid;
        end
    end

    // Build the less significant adder with an extra bit on the top to get
    // the carry chain onto the normal routing.  
    wire sign_bit_a = is_int16 ? 1'b0 : in1[LS_WIDTH-1];
    wire sign_bit_b = is_int16 ? 1'b0 : in2[LS_WIDTH-1];

    reg signed [LS_WIDTH-1+1:0] ls_adder1;
    reg signed [LS_WIDTH-1+1:0] ls_adder2;
    assign ls_adder1 = {sign_bit_a, in1[LS_WIDTH-1:0]};
    assign ls_adder2 = {sign_bit_b, in2[LS_WIDTH-1:0]};
    reg signed [LS_WIDTH-1+1:0] ls_adder;
    wire cross_carry = is_int16 ? ls_adder[LS_WIDTH] : 1'b0;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ls_adder <= 0;
        end else if (in_valid) begin
            ls_adder <= ls_adder1 + ls_adder2;
        end
    end

    // the more significant data needs to wait in1 tick for the carry
    // signal to be ready
    reg [MS_WIDTH-1:0] ms_data_a, ms_data_b;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ms_data_a <= 0;
            ms_data_b <= 0;
        end else if (in_valid) begin
            ms_data_a <= in1[WIDTH-1:WIDTH-MS_WIDTH];
            ms_data_b <= in2[WIDTH-1:WIDTH-MS_WIDTH];
        end
    end

    // Build the more significant adder with an extra low bit to incorporate
    // the carry from the split lower chain.
    wire signed [MS_WIDTH-1+2:0] ms_adder;
    wire signed [MS_WIDTH-1+1:0] ms_adder1;
    wire signed [MS_WIDTH-1+1:0] ms_adder2;
    assign ms_adder1 = {ms_data_a, cross_carry};
    assign ms_adder2 = {ms_data_b, cross_carry};
    assign ms_adder  = ms_adder1 + ms_adder2;

    wire [MS_WIDTH:0] ms_adder_o = ms_adder[MS_WIDTH+1:1];

    // collect the sum back together and register, drop the two internal bits
    // always @(*) begin
    //     if (is_int16) begin
    //         out = {ms_adder[MS_WIDTH+1], ms_adder[MS_WIDTH+1-2:1], ls_adder[LS_WIDTH-1:0]};
    //     end else begin
    //         out = {ms_adder[MS_WIDTH+1],ms_adder[MS_WIDTH+1-2:1], ls_adder[LS_WIDTH-1+1],ls_adder[LS_WIDTH-1+1-2:0]};
    //     end
    // end
    always @(*) begin
        out[LS_WIDTH-2:0] = ls_adder[LS_WIDTH-2:0];
        out[LS_WIDTH-1] = is_int16 ? ls_adder[LS_WIDTH-1] : ls_adder[LS_WIDTH];
        out[WIDTH-1:LS_WIDTH] = {ms_adder[MS_WIDTH+1], ms_adder[MS_WIDTH+1-2:1]};
    end

endmodule
