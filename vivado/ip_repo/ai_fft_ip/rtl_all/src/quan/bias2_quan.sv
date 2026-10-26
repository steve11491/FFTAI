

module bias2_quan #(
    parameter WIDTH = 16,
    parameter SCALE_WIDTH = 16,
    parameter SHIFT_WIDTH = 4
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire signed [SCALE_WIDTH-1:0] scale,//int8情况下 低8位有效，int16情况下16位有效
    input wire [SHIFT_WIDTH-1:0] shift,
    input wire [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    output reg out_valid
);

    wire [WIDTH/2-1:0] din_int8 [1:0];
    wire [WIDTH/2-1:0] dout_int8[1:0];
    assign din_int8[0]  = din[WIDTH/2-1:0];
    assign din_int8[1]  = din[WIDTH-1:WIDTH/2];
    assign dout_int8[0] = dout[WIDTH/2-1:0];
    assign dout_int8[1] = dout[WIDTH-1:WIDTH/2];

    localparam CONST_SHIFT_INT8 = SCALE_WIDTH / 2 - 1;
    localparam CONST_SHIFT_INT16 = SCALE_WIDTH - 1;
    localparam SHIFT_WIDTH_INT8 = SHIFT_WIDTH - 1;

    wire mul_in_valid;
    assign mul_in_valid = in_valid;
    wire [WIDTH+SCALE_WIDTH-1:0] mul_out;
    wire mul_out_valid;

    input_scale u_input_scale (
        .clk      (clk),
        .rstn     (rstn),
        .is_int16 (is_int16),
        .in_valid (mul_in_valid),
        .scale    (scale),
        .din      (din),
        .out      (mul_out),
        .out_valid(mul_out_valid)
    );
    logic signed [WIDTH/2:0] mul_low_int8_round;
    logic signed [WIDTH/2:0] mul_high_int8_round;
    logic signed [WIDTH:0] mul_int16_round;

    reg signed [WIDTH-1:0] mul_low_reg;
    reg signed [WIDTH-1:0] mul_high_reg;
    reg signed [WIDTH+SCALE_WIDTH-1:0] mul_int16_reg;

    assign mul_low_reg   = mul_out[WIDTH-1:0];
    assign mul_high_reg  = mul_out[WIDTH+SCALE_WIDTH-1:WIDTH];
    assign mul_int16_reg = mul_out[WIDTH+SCALE_WIDTH-1:0];

    // 四舍五入的判断位
    wire [2**SHIFT_WIDTH_INT8-1:0] mul_low_reg_up = mul_low_reg[2**SHIFT_WIDTH_INT8+CONST_SHIFT_INT8-2:CONST_SHIFT_INT8-1];
    wire [2**SHIFT_WIDTH_INT8-1:0] mul_high_reg_up = mul_high_reg[2**SHIFT_WIDTH_INT8+CONST_SHIFT_INT8-2:CONST_SHIFT_INT8-1];
    wire [2**SHIFT_WIDTH-1:0] mul_int16_reg_up = mul_int16_reg[2**SHIFT_WIDTH+CONST_SHIFT_INT16-2:CONST_SHIFT_INT16-1];

    wire [SHIFT_WIDTH_INT8-1:0] shift_int8 = shift[SHIFT_WIDTH_INT8-1:0];
    // wire trunc_low = mul_low_reg_up[shift_int8];
    // wire trunc_high = mul_high_reg_up[shift_int8];
    // wire trunc_int16 = mul_int16_reg_up[shift];

    wire [2**SHIFT_WIDTH-1:0] mask_int16;
    wire [2**SHIFT_WIDTH_INT8-1:0] mask_int8;
    assign mask_int16 = (1 << shift) - 1;
    assign mask_int8  = (1 << shift_int8) - 1;
    wire [2**SHIFT_WIDTH_INT8+CONST_SHIFT_INT8-1-1:0] mul_low_reg_cut_bit;
    wire [2**SHIFT_WIDTH_INT8+CONST_SHIFT_INT8-1-1:0] mul_high_reg_cut_bit;
    wire [2**SHIFT_WIDTH+CONST_SHIFT_INT16-1-1:0] mul_int16_reg_cut_bit;
    assign mul_low_reg_cut_bit = {mul_low_reg_up & mask_int8, mul_low_reg[CONST_SHIFT_INT8-1-1:0]};
    assign mul_high_reg_cut_bit = {
        mul_high_reg_up & mask_int8, mul_high_reg[CONST_SHIFT_INT8-1-1:0]
    };
    assign mul_int16_reg_cut_bit = {
        mul_int16_reg_up & mask_int16, mul_int16_reg[CONST_SHIFT_INT16-1-1:0]
    };


    wire trunc_low = mul_low_reg_up[shift_int8] & ~(mul_low_reg_up[shift_int8] & mul_low_reg[WIDTH-1] & ~(|mul_low_reg_cut_bit));
    wire trunc_high = mul_high_reg_up[shift_int8]& ~(mul_high_reg_up[shift_int8] & mul_high_reg[WIDTH-1] & ~(|mul_high_reg_cut_bit));
    wire trunc_int16 = mul_int16_reg_up[shift] & ~(mul_int16_reg_up[shift] & mul_int16_reg[WIDTH+SCALE_WIDTH-1] & ~(|mul_int16_reg_cut_bit));
    reg trunc_low_reg;
    reg trunc_high_reg;
    reg trunc_int16_reg;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            trunc_low_reg   <= 0;
            trunc_high_reg  <= 0;
            trunc_int16_reg <= 0;
        end else begin
            trunc_low_reg   <= trunc_low;
            trunc_high_reg  <= trunc_high;
            trunc_int16_reg <= trunc_int16;
        end
    end

    // 四舍五入

    // wire [SHIFT_WIDTH_INT8:0] shift_int8_true = CONST_SHIFT_INT8 + shift;
    // wire signed [WIDTH-1:0] mul_low_shift;
    // wire signed [WIDTH-1:0] mul_high_shift;
    // assign mul_low_shift  = mul_low_reg[WIDTH-1:0] >>> shift_int8_true;
    // assign mul_high_shift = mul_high_reg[WIDTH-1:0] >>> shift_int8_true;

    wire signed [WIDTH-CONST_SHIFT_INT8-1:0] mul_low_shift;
    wire signed [WIDTH-CONST_SHIFT_INT8-1:0] mul_high_shift;

    wire signed [WIDTH-CONST_SHIFT_INT8-1:0] mul_low_shift_w2;
    wire signed [WIDTH-CONST_SHIFT_INT8-1:0] mul_high_shift_w2;
    assign mul_low_shift_w2 = mul_low_reg[WIDTH-1:CONST_SHIFT_INT8];
    assign mul_high_shift_w2 = mul_high_reg[WIDTH-1:CONST_SHIFT_INT8];

    assign mul_low_shift = mul_low_shift_w2 >>> shift;
    assign mul_high_shift = mul_high_shift_w2 >>> shift;

    wire signed [WIDTH/2:0] mul_low_shift_w;
    wire signed [WIDTH/2:0] mul_high_shift_w;
    assign mul_low_shift_w  = {mul_low_shift[WIDTH/2:0]};
    assign mul_high_shift_w = {mul_high_shift[WIDTH/2:0]};


    wire mul_out_int8_valid;
    wire mul_out_int16_valid;
    assign mul_out_int8_valid  = mul_out_valid & (~is_int16);
    assign mul_out_int16_valid = mul_out_valid & (is_int16);
    // always @(posedge clk) begin
    //     if (mul_out_int8_valid) begin
    //         mul_low_int8_round <= (trunc_low==1'b1)?
    //                 ((mul_low_shift_w=={1'b0,{(WIDTH/2){1'b1}}})
    //                 ?(mul_low_shift_w):(mul_low_shift_w+1))
    //                 :(mul_low_shift_w);
    //         mul_high_int8_round <= (trunc_high==1'b1)?
    //                 ((mul_high_shift_w=={1'b0,{(WIDTH/2){1'b1}}})
    //                 ?(mul_high_shift_w):(mul_high_shift_w+1))
    //                 :(mul_high_shift_w);
    //     end
    // end
    logic signed [WIDTH/2:0] mul_low_shift_ff;
    logic signed [WIDTH/2:0] mul_high_shift_ff;

    always @(posedge clk) begin
        if (mul_out_int8_valid) begin
            mul_low_shift_ff  <= mul_low_shift_w;
            mul_high_shift_ff <= mul_high_shift_w;
        end
    end
    reg mul_out_int8_valid_ff;
    reg mul_out_int16_valid_ff;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mul_out_int8_valid_ff  <= 0;
            mul_out_int16_valid_ff <= 0;
        end else begin
            mul_out_int8_valid_ff  <= mul_out_int8_valid;
            mul_out_int16_valid_ff <= mul_out_int16_valid;
        end
    end



    always @(posedge clk) begin
        if (mul_out_int8_valid_ff) begin
            mul_low_int8_round <= (trunc_low_reg==1'b1)?
                    ((mul_low_shift_ff=={1'b0,{(WIDTH/2){1'b1}}})
                    ?(mul_low_shift_ff):(mul_low_shift_ff+1))
                    :(mul_low_shift_ff);
            mul_high_int8_round <= (trunc_high_reg==1'b1)?
                    ((mul_high_shift_ff=={1'b0,{(WIDTH/2){1'b1}}})
                    ?(mul_high_shift_ff):(mul_high_shift_ff+1))
                    :(mul_high_shift_ff);
        end
    end

    // wire [SHIFT_WIDTH:0] shift_int16_true = CONST_SHIFT_INT16 + shift;
    // wire signed [WIDTH+SCALE_WIDTH-1:0] mul_int16_shift;
    // assign mul_int16_shift = mul_int16_reg[WIDTH+SCALE_WIDTH-1:CONST_SHIFT_INT16] >>> shift_int16_true;

    wire signed [WIDTH+SCALE_WIDTH-CONST_SHIFT_INT16-1:0] mul_int16_shift;
    wire signed [WIDTH+SCALE_WIDTH-CONST_SHIFT_INT16-1:0] mul_int16_shift_w2;
    assign mul_int16_shift_w2 = mul_int16_reg[WIDTH+SCALE_WIDTH-1:CONST_SHIFT_INT16];
    assign mul_int16_shift = mul_int16_shift_w2 >>> shift;

    wire signed [WIDTH:0] mul_int16_shift_w;
    assign mul_int16_shift_w = mul_int16_shift[WIDTH:0];

    // always @(posedge clk) begin
    //     if (mul_out_int16_valid) begin
    //         mul_int16_round <= (trunc_int16==1'b1)?
    //                 ((mul_int16_shift_w=={1'b0,{(WIDTH){1'b1}}})
    //                 ?(mul_int16_shift_w):(mul_int16_shift_w+1))
    //                 :(mul_int16_shift_w);
    //     end
    // end

    logic signed [WIDTH:0] mul_int16_shift_ff;
    always @(posedge clk) begin
        if (mul_out_int16_valid) begin
            mul_int16_shift_ff <= mul_int16_shift_w;
        end
    end



    always @(posedge clk) begin
        if (mul_out_int16_valid_ff) begin
            mul_int16_round <= (trunc_int16_reg==1'b1)?
                    ((mul_int16_shift_ff=={1'b0,{(WIDTH){1'b1}}})
                    ?(mul_int16_shift_ff):(mul_int16_shift_ff+1))
                    :(mul_int16_shift_ff);

        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid <= 0;
        end else begin
            out_valid <= is_int16 ? mul_out_int16_valid_ff : mul_out_int8_valid_ff;
        end
    end

    assign dout = is_int16?{mul_int16_round[WIDTH],mul_int16_round[WIDTH-2:0]}:{mul_high_int8_round[WIDTH/2],mul_high_int8_round[WIDTH/2-2:0],
                                                                                mul_low_int8_round[WIDTH/2],mul_low_int8_round[WIDTH/2-2:0]};




endmodule





// module bias2_quan #(
//     parameter WIDTH = 16,
//     parameter SCALE_WIDTH = 16,
//     parameter SHIFT_WIDTH = 4
// ) (
//     input wire clk,
//     input wire rstn,
//     input wire is_int16,
//     input wire in_valid,
//     input wire signed [SCALE_WIDTH-1:0] scale,//int8情况下 低8位有效，int16情况下16位有效
//     input wire [SHIFT_WIDTH-1:0] shift,
//     input wire [WIDTH-1:0] din,
//     output reg [WIDTH-1:0] dout,
//     output reg out_valid
// );

//     wire [WIDTH/2-1:0] din_int8 [1:0];
//     wire [WIDTH/2-1:0] dout_int8[1:0];
//     assign din_int8[0]  = din[WIDTH/2-1:0];
//     assign din_int8[1]  = din[WIDTH-1:WIDTH/2];
//     assign dout_int8[0] = dout[WIDTH/2-1:0];
//     assign dout_int8[1] = dout[WIDTH-1:WIDTH/2];

//     localparam CONST_SHIFT_INT8 = SCALE_WIDTH / 2 - 1;
//     localparam CONST_SHIFT_INT16 = SCALE_WIDTH - 1;
//     localparam SHIFT_WIDTH_INT8 = SHIFT_WIDTH - 1;

//     wire mul_in_valid;
//     assign mul_in_valid = in_valid;
//     wire [WIDTH+SCALE_WIDTH-1:0] mul_out;
//     wire mul_out_valid;

//     input_scale u_input_scale (
//         .clk      (clk),
//         .rstn     (rstn),
//         .is_int16 (is_int16),
//         .in_valid (mul_in_valid),
//         .scale    (scale),
//         .din      (din),
//         .out      (mul_out),
//         .out_valid(mul_out_valid)
//     );
//     logic signed [WIDTH/2:0] mul_low_int8_round;
//     logic signed [WIDTH/2:0] mul_high_int8_round;
//     logic signed [WIDTH:0] mul_int16_round;

//     reg signed [WIDTH-1:0] mul_low_reg;
//     reg signed [WIDTH-1:0] mul_high_reg;
//     reg signed [WIDTH+SCALE_WIDTH-1:0] mul_int16_reg;

//     assign mul_low_reg   = mul_out[WIDTH-1:0];
//     assign mul_high_reg  = mul_out[WIDTH+SCALE_WIDTH-1:WIDTH];
//     assign mul_int16_reg = mul_out[WIDTH+SCALE_WIDTH-1:0];

//     // 四舍五入的判断位
//     wire [2**SHIFT_WIDTH_INT8-1:0] mul_low_reg_up = mul_low_reg[2**SHIFT_WIDTH_INT8+CONST_SHIFT_INT8-2:CONST_SHIFT_INT8-1];
//     wire [2**SHIFT_WIDTH_INT8-1:0] mul_high_reg_up = mul_high_reg[2**SHIFT_WIDTH_INT8+CONST_SHIFT_INT8-2:CONST_SHIFT_INT8-1];
//     wire [2**SHIFT_WIDTH-1:0] mul_int16_reg_up = mul_int16_reg[2**SHIFT_WIDTH+CONST_SHIFT_INT16-2:CONST_SHIFT_INT16-1];

//     wire [SHIFT_WIDTH_INT8-1:0] shift_int8 = shift[SHIFT_WIDTH_INT8-1:0];
//     // wire trunc_low = mul_low_reg_up[shift_int8];
//     // wire trunc_high = mul_high_reg_up[shift_int8];
//     // wire trunc_int16 = mul_int16_reg_up[shift];

//     wire [2**SHIFT_WIDTH-1:0] mask_int16;
//     wire [2**SHIFT_WIDTH_INT8-1:0] mask_int8;
//     assign mask_int16 = (1 << shift) - 1;
//     assign mask_int8  = (1 << shift_int8) - 1;
//     wire [2**SHIFT_WIDTH_INT8+CONST_SHIFT_INT8-1-1:0] mul_low_reg_cut_bit;
//     wire [2**SHIFT_WIDTH_INT8+CONST_SHIFT_INT8-1-1:0] mul_high_reg_cut_bit;
//     wire [2**SHIFT_WIDTH+CONST_SHIFT_INT16-1-1:0] mul_int16_reg_cut_bit;
//     assign mul_low_reg_cut_bit = {mul_low_reg_up & mask_int8, mul_low_reg[CONST_SHIFT_INT8-1-1:0]};
//     assign mul_high_reg_cut_bit = {
//         mul_high_reg_up & mask_int8, mul_high_reg[CONST_SHIFT_INT8-1-1:0]
//     };
//     assign mul_int16_reg_cut_bit = {
//         mul_int16_reg_up & mask_int16, mul_int16_reg[CONST_SHIFT_INT16-1-1:0]
//     };

//     wire trunc_low_w = mul_low_reg_up[shift_int8];
//     wire trunc_high_w = mul_high_reg_up[shift_int8];
//     wire trunc_int16_w = mul_int16_reg_up[shift];

//     wire trunc_low = trunc_low_w & ~(trunc_low_w & mul_low_reg[WIDTH-1] & ~(|mul_low_reg_cut_bit));
//     wire trunc_high = trunc_high_w& ~(trunc_high_w & mul_high_reg[WIDTH-1] & ~(|mul_high_reg_cut_bit));
//     wire trunc_int16 = trunc_int16_w & ~(trunc_int16_w & mul_int16_reg[WIDTH+SCALE_WIDTH-1] & ~(|mul_int16_reg_cut_bit));


//     // 四舍五入

//     // wire [SHIFT_WIDTH_INT8:0] shift_int8_true = CONST_SHIFT_INT8 + shift;
//     // wire signed [WIDTH-1:0] mul_low_shift;
//     // wire signed [WIDTH-1:0] mul_high_shift;
//     // assign mul_low_shift  = mul_low_reg[WIDTH-1:0] >>> shift_int8_true;
//     // assign mul_high_shift = mul_high_reg[WIDTH-1:0] >>> shift_int8_true;

//     wire signed [WIDTH-CONST_SHIFT_INT8-1:0] mul_low_shift;
//     wire signed [WIDTH-CONST_SHIFT_INT8-1:0] mul_high_shift;

//     wire signed [WIDTH-CONST_SHIFT_INT8-1:0] mul_low_shift_w2;
//     wire signed [WIDTH-CONST_SHIFT_INT8-1:0] mul_high_shift_w2;
//     assign mul_low_shift_w2 = mul_low_reg[WIDTH-1:CONST_SHIFT_INT8];
//     assign mul_high_shift_w2 = mul_high_reg[WIDTH-1:CONST_SHIFT_INT8];

//     assign mul_low_shift = mul_low_shift_w2 >>> shift;
//     assign mul_high_shift = mul_high_shift_w2 >>> shift;

//     wire signed [WIDTH/2:0] mul_low_shift_w;
//     wire signed [WIDTH/2:0] mul_high_shift_w;
//     assign mul_low_shift_w  = {mul_low_shift[WIDTH/2:0]};
//     assign mul_high_shift_w = {mul_high_shift[WIDTH/2:0]};


//     wire mul_out_int8_valid;
//     wire mul_out_int16_valid;
//     assign mul_out_int8_valid  = mul_out_valid & (~is_int16);
//     assign mul_out_int16_valid = mul_out_valid & (is_int16);
//     always @(posedge clk) begin
//         if (mul_out_int8_valid) begin
//             mul_low_int8_round  <= mul_low_shift_w;
//             mul_high_int8_round <= mul_high_shift_w;
//         end
//     end

//     // wire [SHIFT_WIDTH:0] shift_int16_true = CONST_SHIFT_INT16 + shift;
//     // wire signed [WIDTH+SCALE_WIDTH-1:0] mul_int16_shift;
//     // assign mul_int16_shift = mul_int16_reg[WIDTH+SCALE_WIDTH-1:CONST_SHIFT_INT16] >>> shift_int16_true;

//     wire signed [WIDTH+SCALE_WIDTH-CONST_SHIFT_INT16-1:0] mul_int16_shift;
//     wire signed [WIDTH+SCALE_WIDTH-CONST_SHIFT_INT16-1:0] mul_int16_shift_w2;
//     assign mul_int16_shift_w2 = mul_int16_reg[WIDTH+SCALE_WIDTH-1:CONST_SHIFT_INT16];
//     assign mul_int16_shift = mul_int16_shift_w2 >>> shift;

//     wire signed [WIDTH:0] mul_int16_shift_w;
//     assign mul_int16_shift_w = mul_int16_shift[WIDTH:0];

//     always @(posedge clk) begin
//         if (mul_out_int16_valid) begin
//             mul_int16_round <= mul_int16_shift_w;
//         end
//     end



//     always @(posedge clk or negedge rstn) begin
//         if (~rstn) begin
//             out_valid <= 0;
//         end else begin
//             out_valid <= mul_out_valid;
//         end
//     end

//     assign dout = is_int16?{mul_int16_round[WIDTH],mul_int16_round[WIDTH-2:0]}:{mul_high_int8_round[WIDTH/2],mul_high_int8_round[WIDTH/2-2:0],
//                                                                                 mul_low_int8_round[WIDTH/2],mul_low_int8_round[WIDTH/2-2:0]};




// endmodule
