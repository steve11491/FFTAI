module split_add #(
    parameter LS_WIDTH = 16,
    parameter MS_WIDTH = 16,
    parameter WIDTH = LS_WIDTH + MS_WIDTH
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire bypass,
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    output logic [WIDTH-1+2:0] out,
    output logic out_valid
);

    // 这个模块实现了int16和int8情况下的有符号加法，
    // int16时，输入是一个int32，输出是一个int34，int8时，输入int32的低16位和高16位为2个int16，输出int34是2个int17
    // int16: 34-1:0 out;
    // int8: 34-1:17 out1; 16:0 out2

    logic out_valid_w;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid_w <= 0;
        end else begin
            out_valid_w <= in_valid;
        end
    end
    assign out_valid = bypass ? in_valid : out_valid_w;

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

    reg signed [LS_WIDTH-1+1:0] ls_adder_w;
    reg signed [LS_WIDTH-1+1:0] ls_adder_reg;
    assign ls_adder_w = ls_adder1 + ls_adder2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ls_adder_reg <= 0;
        end else if (in_valid) begin
            ls_adder_reg <= ls_adder_w;
        end
    end
    assign ls_adder = bypass ? ls_adder_w : ls_adder_reg;



    // the more significant data needs to wait in1 tick for the carry
    // signal to be ready
    reg [MS_WIDTH-1:0] ms_data_a, ms_data_b;
    reg [MS_WIDTH-1:0] ms_data_a_w, ms_data_b_w;
    reg [MS_WIDTH-1:0] ms_data_a_reg, ms_data_b_reg;

    assign ms_data_a_w = in1[WIDTH-1:WIDTH-MS_WIDTH];
    assign ms_data_b_w = in2[WIDTH-1:WIDTH-MS_WIDTH];
    assign ms_data_a   = bypass ? ms_data_a_w : ms_data_a_reg;
    assign ms_data_b   = bypass ? ms_data_b_w : ms_data_b_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ms_data_a_reg <= 0;
            ms_data_b_reg <= 0;
        end else if (in_valid) begin
            ms_data_a_reg <= ms_data_a_w;
            ms_data_b_reg <= ms_data_b_w;
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
    //         out = {ms_adder[MS_WIDTH+1], ms_adder[MS_WIDTH+1:1], ls_adder[LS_WIDTH-1:0]};
    //     end else begin
    //         out = {ms_adder[MS_WIDTH+1:1], ls_adder[LS_WIDTH-1+1:0]};
    //     end
    // end
    always @(*) begin
        out[LS_WIDTH-1:0] = ls_adder[LS_WIDTH-1:0];
        if (is_int16) begin
            out[WIDTH-1+2:LS_WIDTH] = {ms_adder[MS_WIDTH+1], ms_adder[MS_WIDTH+1:1]};
        end else begin
            out[WIDTH-1+2:LS_WIDTH] = {ms_adder[MS_WIDTH+1:1], ls_adder[LS_WIDTH-1+1]};
        end
    end

endmodule

