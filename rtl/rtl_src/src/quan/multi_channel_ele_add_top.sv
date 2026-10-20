module multi_channel_ele_add_top #(
    parameter CHANNEL_NUM = 16,
    parameter WIDTH = 16,
    parameter QUAN_OUT_WIDTH = 20
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire use_bias2_add,
    input wire [CHANNEL_NUM-1:0] in_valid,
    input wire [CHANNEL_NUM-1:0] ele_add_mask,
    input wire [WIDTH-1:0] bias2_in[CHANNEL_NUM-1:0],
    input wire [QUAN_OUT_WIDTH+4-1:0] quan_in[CHANNEL_NUM-1:0],
    output wire [WIDTH-1:0] dout[CHANNEL_NUM-1:0],
    output wire [CHANNEL_NUM-1:0] out_valid
);

    // for debug
    (* mark_debug = "false"*) wire [WIDTH/2-1:0] bias2_int8[CHANNEL_NUM*2-1:0];
    (* mark_debug = "false"*) wire [(QUAN_OUT_WIDTH+4)/2-1:0] quan_int8[CHANNEL_NUM*2-1:0];
    (* mark_debug = "false"*) wire [WIDTH/2-1:0] dout_int8[CHANNEL_NUM*2-1:0];

    genvar ii;
    generate
        for (ii = 0; ii < CHANNEL_NUM; ii = ii + 1) begin
            assign {bias2_int8[ii*2+1], bias2_int8[ii*2]} = bias2_in[ii];
            assign {quan_int8[ii*2+1], quan_int8[ii*2]}   = quan_in[ii];
            assign {dout_int8[ii*2+1], dout_int8[ii*2]}   = dout[ii];
        end
    endgenerate


    // for debug

    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
        end else begin
            is_int16_reg <= is_int16;
        end
    end

    wire [QUAN_OUT_WIDTH+4-1:0] bias2_in_exp[CHANNEL_NUM-1:0];
    wire [QUAN_OUT_WIDTH+4-1:0] bias2_in_true[CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] in_valid_true;
    assign in_valid_true = in_valid;
    wire [QUAN_OUT_WIDTH+6-1:0] add_dout[CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] add_out_valid;
    genvar i;
    generate
        for (i = 0; i < CHANNEL_NUM; i = i + 1) begin : ele_add
            sign_bit_exp #(
                .IDATA_WIDTH(WIDTH),
                .EXP_BIT    (QUAN_OUT_WIDTH + 4 - WIDTH),
                .ODATA_WIDTH(QUAN_OUT_WIDTH + 4)
            ) u_sign_bit_exp_bias2_in (
                .is_int16(is_int16_reg),
                .idata   (bias2_in[i]),
                .odata(bias2_in_exp[i])
            );
            assign bias2_in_true[i] = use_bias2_add ? bias2_in_exp[i] : 0;
            split_add #(
                .LS_WIDTH((QUAN_OUT_WIDTH + 4) / 2),
                .MS_WIDTH((QUAN_OUT_WIDTH + 4) / 2),
                .WIDTH(QUAN_OUT_WIDTH + 4)
            ) split_add (
                .clk      (clk),
                .rstn     (rstn),
                .bypass   (1'b0),
                .is_int16 (is_int16_reg),
                .in_valid (in_valid_true[i]),
                .in1      (bias2_in_true[i]),
                .in2      (quan_in[i]),
                .out      (add_dout[i]),
                .out_valid(add_out_valid[i])
            );
        end
        for (i = 0; i < CHANNEL_NUM; i = i + 1) begin : split_dat_sat
            split_dat_sat #(
                .DIN_WIDTH (QUAN_OUT_WIDTH + 6),
                .DOUT_WIDTH(WIDTH)
            ) u_split_quan_acc_sat (
                .clk(clk),
                .rstn(rstn),
                .is_int16(is_int16_reg),
                .in_valid(add_out_valid[i]),
                .din(add_dout[i]),
                .dout(dout[i]),
                .out_valid(out_valid[i])
            );
        end
    endgenerate




endmodule
