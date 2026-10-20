

module quan_scale_shift_round #(
    parameter QUAN_IN_WIDTH = 32,
    parameter QUAN_OUT_WIDTH = 16,
    parameter SCALE_WIDTH = 16,
    parameter SHIFT_WIDTH = 4
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire quan_enable,
    input wire quan_in_valid,
    input wire signed [SCALE_WIDTH-1:0] scale,
    input wire [SHIFT_WIDTH-1:0] shift,
    input wire [QUAN_IN_WIDTH-1:0] quan_in,
    output logic signed [QUAN_IN_WIDTH/2:0] mul_low_int8_round,
    output logic signed [QUAN_IN_WIDTH/2:0] mul_high_int8_round,
    output logic signed [QUAN_IN_WIDTH:0] mul_int16_round,
    output logic mul_round_valid
);
    localparam CONST_SHIFT = SCALE_WIDTH - 1;

    wire signed [QUAN_IN_WIDTH/2+1-1:0] quan_in_low;
    assign quan_in_low = {
        is_int16 ? 1'b0 : quan_in[QUAN_IN_WIDTH/2-1], quan_in[QUAN_IN_WIDTH/2-1:0]
    };
    wire signed [QUAN_IN_WIDTH/2-1:0] quan_in_high;
    assign quan_in_high = quan_in[QUAN_IN_WIDTH-1:QUAN_IN_WIDTH/2];
    wire mul_in_valid;
    assign mul_in_valid = quan_enable & quan_in_valid;
    reg signed [QUAN_IN_WIDTH/2+SCALE_WIDTH-1:0] mul_low_reg;
    reg signed [QUAN_IN_WIDTH/2+SCALE_WIDTH-1:0] mul_high_reg;
    reg signed [QUAN_IN_WIDTH*2/2+SCALE_WIDTH-1:0] mul_int16_reg;

    // 四舍五入的判断位
    wire [2**SHIFT_WIDTH-1:0] mul_low_reg_up = mul_low_reg[2**SHIFT_WIDTH+CONST_SHIFT-2:CONST_SHIFT-1];
    wire [2**SHIFT_WIDTH-1:0] mul_high_reg_up = mul_high_reg[2**SHIFT_WIDTH+CONST_SHIFT-2:CONST_SHIFT-1];
    wire [2**SHIFT_WIDTH-1:0] mul_int16_reg_up = mul_int16_reg[2**SHIFT_WIDTH+CONST_SHIFT-2:CONST_SHIFT-1];

    wire [2**SHIFT_WIDTH-1:0] mul_low_reg_up_add1 = mul_low_reg[2**SHIFT_WIDTH+CONST_SHIFT-2+1:CONST_SHIFT-1+1];
    wire [2**SHIFT_WIDTH-1:0] mul_high_reg_up_add1 = mul_high_reg[2**SHIFT_WIDTH+CONST_SHIFT-2+1:CONST_SHIFT-1+1];
    wire [2**SHIFT_WIDTH-1:0] mul_int16_reg_up_add1 = mul_int16_reg[2**SHIFT_WIDTH+CONST_SHIFT-2+1:CONST_SHIFT-1+1];

    wire [SHIFT_WIDTH:0] shift_true = CONST_SHIFT + shift;


    wire [2**SHIFT_WIDTH-1:0] mask;
    assign mask = (1 << shift) - 1;
    wire [2**SHIFT_WIDTH+CONST_SHIFT-1-1:0] mul_low_reg_cut_bit;
    wire [2**SHIFT_WIDTH+CONST_SHIFT-1-1:0] mul_high_reg_cut_bit;
    wire [2**SHIFT_WIDTH+CONST_SHIFT-1-1:0] mul_int16_reg_cut_bit;
    assign mul_low_reg_cut_bit   = {mul_low_reg_up & mask, mul_low_reg[CONST_SHIFT-1-1:0]};
    assign mul_high_reg_cut_bit  = {mul_high_reg_up & mask, mul_high_reg[CONST_SHIFT-1-1:0]};
    assign mul_int16_reg_cut_bit = {mul_int16_reg_up & mask, mul_int16_reg[CONST_SHIFT-1-1:0]};

    wire trunc_low_w = mul_low_reg_up[shift];
    wire trunc_high_w = mul_high_reg_up[shift];
    wire trunc_int16_w = mul_int16_reg_up[shift];
    wire mul_low_reg_cut_bit_or = ~(|mul_low_reg_cut_bit);
    wire mul_high_reg_cut_bit_or = ~(|mul_high_reg_cut_bit);
    wire mul_int16_reg_cut_bit_or = ~(|mul_int16_reg_cut_bit);

    //==========================================================
    // 这样有问题
    // wire trunc_low = mul_low_reg_up[shift];
    // wire trunc_high = mul_high_reg_up[shift];
    // wire trunc_int16 = mul_int16_reg_up[shift];
    //==========================================================

    // Round Half to pos inf: 被截断的最高位为1进位，（这种情况需要排除：是正数并且被截断的部分（除最高位外）全0）
    //==========================================================
    wire a = (trunc_low_w & mul_low_reg[QUAN_IN_WIDTH/2+SCALE_WIDTH-1] & ~(|mul_low_reg_cut_bit));
    wire b = (trunc_high_w & mul_high_reg[QUAN_IN_WIDTH/2+SCALE_WIDTH-1] & ~(|mul_high_reg_cut_bit));
    wire c = (trunc_int16_w & mul_int16_reg[QUAN_IN_WIDTH*2/2+SCALE_WIDTH-1] & ~(|mul_int16_reg_cut_bit));

    wire trunc_low = trunc_low_w & ~(trunc_low_w & mul_low_reg[QUAN_IN_WIDTH/2+SCALE_WIDTH-1] & ~(|mul_low_reg_cut_bit));
    wire trunc_high = trunc_high_w& ~(trunc_high_w & mul_high_reg[QUAN_IN_WIDTH/2+SCALE_WIDTH-1] & ~(|mul_high_reg_cut_bit));
    wire trunc_int16 = trunc_int16_w & ~(trunc_int16_w & mul_int16_reg[QUAN_IN_WIDTH*2/2+SCALE_WIDTH-1] & ~(|mul_int16_reg_cut_bit));
    //==========================================================

    // Round Half to Even：被截断的最高位为1进位，（这种情况需要排除：留下的部分的最低位为0（偶数）并且被截断的部分（除最高位外）全0）
    //==========================================================
    //Python3中的round()函数采用了'四舍六入五成双'的策略，不同于Python2的简单四舍五入。这种策略在统计上更为公平，可以减少舍入误差。
    // 当数字的最后一位是5时，如果前一位是奇数则进位，如果是偶数则不进位。
    // mul_low_reg_up_add1[shift]是1，那么小数点前1位是奇数
    // 如果前一位是奇数则进位，如果是偶数则不进位

    // wire a = (~(~mul_low_reg_up_add1[shift] & (~(|mul_low_reg_cut_bit))));
    // wire b = (~(~mul_high_reg_up_add1[shift] & (~(|mul_high_reg_cut_bit))));
    // wire c = (~(~mul_int16_reg_up_add1[shift] & (~(|mul_int16_reg_cut_bit))));


    // wire trunc_low = mul_low_reg_up[shift] & (~(~mul_low_reg_up_add1[shift] & (~(|mul_low_reg_cut_bit))));
    // wire trunc_high = mul_high_reg_up[shift]  &  (~(~mul_high_reg_up_add1[shift]&(~(|mul_high_reg_cut_bit))));
    // wire trunc_int16 = mul_int16_reg_up[shift] &  (~(~mul_int16_reg_up_add1[shift]&(~(|mul_int16_reg_cut_bit))));

    //==========================================================

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

    logic mul_out_valid;
    always @(posedge clk) begin
        if (mul_in_valid) begin
            mul_low_reg  <= quan_in_low * scale;
            mul_high_reg <= quan_in_high * scale;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mul_out_valid <= 0;
        end else begin
            mul_out_valid <= mul_in_valid;
        end
    end


    logic signed [QUAN_IN_WIDTH/2+SCALE_WIDTH-1:0] mul_low_shift;
    logic signed [QUAN_IN_WIDTH/2+SCALE_WIDTH-1:0] mul_high_shift;

    // 四舍五入


    assign mul_low_shift  = mul_low_reg >>> shift_true;
    assign mul_high_shift = mul_high_reg >>> shift_true;

    logic signed [QUAN_IN_WIDTH/2:0] mul_low_shift_w;
    logic signed [QUAN_IN_WIDTH/2:0] mul_high_shift_w;
    assign mul_low_shift_w  = {mul_low_shift[QUAN_IN_WIDTH/2:0]};
    assign mul_high_shift_w = {mul_high_shift[QUAN_IN_WIDTH/2:0]};

    wire mul_out_int8_valid;
    wire mul_out_int16_valid;
    assign mul_out_int8_valid  = mul_out_valid & (~is_int16);
    assign mul_out_int16_valid = mul_out_valid & (is_int16);
    logic signed [QUAN_IN_WIDTH/2:0] mul_low_shift_ff;
    logic signed [QUAN_IN_WIDTH/2:0] mul_high_shift_ff;

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
                    ((mul_low_shift_ff=={1'b0,{(QUAN_IN_WIDTH/2){1'b1}}})
                    ?(mul_low_shift_ff):(mul_low_shift_ff+1))
                    :(mul_low_shift_ff);
            mul_high_int8_round <= (trunc_high_reg==1'b1)?
                    ((mul_high_shift_ff=={1'b0,{(QUAN_IN_WIDTH/2){1'b1}}})
                    ?(mul_high_shift_ff):(mul_high_shift_ff+1))
                    :(mul_high_shift_ff);
        end
    end
    reg mul_round_valid_int8;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mul_round_valid_int8 <= 0;
        end else begin
            mul_round_valid_int8 <= mul_out_int8_valid_ff;
        end
    end

    reg mul_round_valid_int16;
    reg mul_round_valid_w;
    always @(posedge clk) begin
        if (mul_out_int16_valid) begin
            // mul_int16_reg <= ((mul_high_reg << (QUAN_IN_WIDTH/2-CONST_SHIFT)) >>> shift) + mul_low_shift;
            mul_int16_reg <= ((mul_high_reg << (QUAN_IN_WIDTH / 2))) + mul_low_reg;
        end
    end
    logic signed [QUAN_IN_WIDTH*2/2+SCALE_WIDTH-1:0] mul_int16_shift;
    logic signed [QUAN_IN_WIDTH:0] mul_int16_shift_w;
    assign mul_int16_shift   = mul_int16_reg >>> shift_true;
    assign mul_int16_shift_w = mul_int16_shift[QUAN_IN_WIDTH:0];

    logic signed [QUAN_IN_WIDTH:0] mul_int16_shift_ff;
    always @(posedge clk) begin
        if (mul_out_int16_valid_ff) begin
            mul_int16_shift_ff <= mul_int16_shift_w;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mul_round_valid_w <= 0;
        end else begin
            mul_round_valid_w <= mul_out_int16_valid_ff;
        end
    end


    always @(posedge clk) begin
        if (mul_round_valid_w) begin
            mul_int16_round <= (trunc_int16_reg==1'b1)?
                    ((mul_int16_shift_ff=={1'b0,{(QUAN_IN_WIDTH){1'b1}}})
                    ?(mul_int16_shift_ff):(mul_int16_shift_ff+1))
                    :(mul_int16_shift_ff);

        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mul_round_valid_int16 <= 0;
        end else begin
            mul_round_valid_int16 <= mul_round_valid_w;
        end
    end
    assign mul_round_valid = is_int16 ? mul_round_valid_int16 : mul_round_valid_int8;





endmodule
