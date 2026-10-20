
module add_array_tree #(
    parameter INPUTS_NUM  = 8,
    parameter IDATA_WIDTH = 34,

    parameter STAGES_NUM  = $clog2(INPUTS_NUM),
    parameter ODATA_WIDTH = IDATA_WIDTH + STAGES_NUM * 2
) (
    input clk,
    input rstn,
    input wire is_fft,
    input wire is_int16,
    input wire [INPUTS_NUM-1:0] in_valid,
    input wire [IDATA_WIDTH-1:0] mat_din[INPUTS_NUM-1:0],
    input wire [IDATA_WIDTH-1:0] fft_din[INPUTS_NUM-1:0],
    output logic [ODATA_WIDTH-1:0] odata[INPUTS_NUM-1:0],
    output logic [INPUTS_NUM-1:0] out_valid
);

    // for debug
    // ============================================
    wire [IDATA_WIDTH/2-1:0] mat_din_int17[INPUTS_NUM*2-1:0];
    wire [ODATA_WIDTH/2-1:0] odata1;
    wire [ODATA_WIDTH/2-1:0] odata2;
    genvar d;
    generate
        for (d = 0; d < INPUTS_NUM; d = d + 1) begin
            assign {mat_din_int17[d*2+1][IDATA_WIDTH/2-1:0],mat_din_int17[d*2][IDATA_WIDTH/2-1:0]} = mat_din[d][IDATA_WIDTH-1:0];
        end
    endgenerate
    assign odata1 = odata[INPUTS_NUM/2-1][ODATA_WIDTH/2-1:0];
    assign odata2 = odata[INPUTS_NUM/2-1][ODATA_WIDTH-1:ODATA_WIDTH/2];
    // ============================================

    // 获取当前节点在二叉树的层数
    function integer get_level(input integer node);
        integer level;
        integer temp;
        begin
            level = 0;
            temp  = node;
            while (temp[0] == 1'b1) begin
                level = level + 1;
                temp  = temp >> 1;
            end
            get_level = level;
        end
    endfunction

    // 获取右节点编号
    function integer get_right(input integer node);
        integer level;
        integer right;
        begin
            level = get_level(node);
            right = node + 2 ** (level - 1);
            get_right = right;
        end

    endfunction
    // 获取左节点编号
    function integer get_left(input integer node);
        integer level;
        integer left;
        begin
            level = get_level(node);
            left = node - 2 ** (level - 1);
            get_left = left;
        end
    endfunction


    logic [ODATA_WIDTH-1:0] add_out[INPUTS_NUM-1:0];
    logic [IDATA_WIDTH+2-1:0] add_out_low[INPUTS_NUM-1:0];
    generate
        for (genvar i = 0; i < INPUTS_NUM; i = i + 1) begin
            assign add_out_low[i][IDATA_WIDTH+2-1:0] = add_out[i][IDATA_WIDTH+2-1:0];
        end
    endgenerate
    logic [ INPUTS_NUM-1:0] add_out_valid;

    // =============最后一个加法============
    logic [IDATA_WIDTH-1:0] add_in1_N;
    logic [IDATA_WIDTH-1:0] add_in2_N;
    assign add_in1_N[IDATA_WIDTH-1:0] = mat_din[INPUTS_NUM-1][IDATA_WIDTH-1:0];
    assign add_in2_N[IDATA_WIDTH-1:0] = fft_din[INPUTS_NUM-1][IDATA_WIDTH-1:0];
    // parameter LS_WIDTH = 17;
    // parameter MS_WIDTH = 17;
    split_add #(
        .LS_WIDTH(IDATA_WIDTH / 2),
        .MS_WIDTH(IDATA_WIDTH / 2),
        .WIDTH(IDATA_WIDTH)
    ) split_add_N (
        .clk      (clk),
        .rstn     (rstn),
        .bypass   (1'b0),
        .is_int16 (is_int16),
        .in_valid (in_valid[INPUTS_NUM-1]),
        .in1      (add_in1_N[IDATA_WIDTH-1:0]),
        .in2      (add_in2_N[IDATA_WIDTH-1:0]),
        .out      (add_out[INPUTS_NUM-1][IDATA_WIDTH+2-1:0]),
        .out_valid(add_out_valid[INPUTS_NUM-1])
    );
    assign odata[INPUTS_NUM-1][ODATA_WIDTH-1:0] = {
        {(ODATA_WIDTH - (IDATA_WIDTH + 2)) {add_out[INPUTS_NUM-1][IDATA_WIDTH+2-1]}},
        add_out[INPUTS_NUM-1][IDATA_WIDTH+2-1:0]
    };
    // assign odata[INPUTS_NUM-1][ODATA_WIDTH-1:0] = is_int16?{{(ODATA_WIDTH - (IDATA_WIDTH+2)) {add_out[INPUTS_NUM-1][IDATA_WIDTH+2-1]}},add_out[INPUTS_NUM-1][IDATA_WIDTH+2-1:0]}
    //                                                         :{{((ODATA_WIDTH - (IDATA_WIDTH+2))/2) {add_out[INPUTS_NUM-1][IDATA_WIDTH+2-1]}},add_out[INPUTS_NUM-1][IDATA_WIDTH+2-1:(IDATA_WIDTH+2)/2],
    //                                                         {((ODATA_WIDTH - (IDATA_WIDTH+2))/2) {add_out[INPUTS_NUM-1][(IDATA_WIDTH+2)/2-1]}},add_out[INPUTS_NUM-1][(IDATA_WIDTH+2)/2-1:0]};

    // =============奇数位置的加法============
    localparam HALF_INPUTS_NUM = INPUTS_NUM / 2;
    logic [IDATA_WIDTH-1:0] add_in1_odd[HALF_INPUTS_NUM-1:0];
    logic [IDATA_WIDTH-1:0] add_in2_odd[HALF_INPUTS_NUM-1:0];
    genvar i;
    //奇数位置的加法（1开始）
    generate
        for (i = 0; i < INPUTS_NUM; i = i + 2) begin : odd_add
            assign add_in1_odd[i/2][IDATA_WIDTH-1:0] = mat_din[i][IDATA_WIDTH-1:0];
            assign add_in2_odd[i/2][IDATA_WIDTH-1:0] = is_fft?fft_din[i][IDATA_WIDTH-1:0]:mat_din[i+1][IDATA_WIDTH-1:0];
            split_add #(
                .LS_WIDTH(17),
                .MS_WIDTH(17),
                .WIDTH(34)
            ) split_add_odd (
                .clk      (clk),
                .rstn     (rstn),
                .bypass   (1'b0),
                .is_int16 (is_int16),
                .in_valid (in_valid[i]),
                .in1      (add_in1_odd[i/2][IDATA_WIDTH-1:0]),
                .in2      (add_in2_odd[i/2][IDATA_WIDTH-1:0]),
                .out      (add_out[i][IDATA_WIDTH+2-1:0]),
                .out_valid(add_out_valid[i])
            );
            // assign odata[i][ODATA_WIDTH-1:0] = {
            //     {(ODATA_WIDTH - (IDATA_WIDTH + 2)) {add_out[i][IDATA_WIDTH+2-1]}},
            //     add_out[i][IDATA_WIDTH+2-1:0]
            // };
            // assign odata[i][ODATA_WIDTH-1:0] = is_int16?{{(ODATA_WIDTH - (IDATA_WIDTH+2)) {add_out[i][IDATA_WIDTH+2-1]}},add_out[i][IDATA_WIDTH+2-1:0]}
            //                                                 :{{((ODATA_WIDTH - (IDATA_WIDTH+2))/2) {add_out[i][IDATA_WIDTH+2-1]}},add_out[i][IDATA_WIDTH+2-1:(IDATA_WIDTH+2)/2],
            //                                                 {((ODATA_WIDTH - (IDATA_WIDTH+2))/2) {add_out[i][(IDATA_WIDTH+2)/2-1]}},add_out[i][(IDATA_WIDTH+2)/2-1:0]};
            sign_bit_exp #(
                .IDATA_WIDTH(IDATA_WIDTH + 2),
                .EXP_BIT    ((ODATA_WIDTH - (IDATA_WIDTH + 2))),
                .ODATA_WIDTH(ODATA_WIDTH)
            ) u_sign_bit_exp_odata_odd (
                .is_int16(is_int16),
                .idata   (add_out[i][IDATA_WIDTH+2-1:0]),
                .odata(odata[i][ODATA_WIDTH-1:0])
            );
        end
    endgenerate

    // =============偶数位置的加法============
    //偶数位置的加法（1开始）
    localparam ADD_DATA_IN_WIDTH = ODATA_WIDTH - 2;
    localparam ADD_DATA_OUT_WIDTH = ODATA_WIDTH;
    localparam EVEN_NUM = INPUTS_NUM / 2 - 1;
    logic [ADD_DATA_IN_WIDTH-1:0] add_in1_even[EVEN_NUM-1:0];
    logic [ADD_DATA_IN_WIDTH-1:0] add_in2_even[EVEN_NUM-1:0];
    wire [EVEN_NUM-1:0] add_in_valid_even;
    wire [EVEN_NUM-1:0] add_out_valid_even;

    wire [IDATA_WIDTH-1:0] mat_din_even[EVEN_NUM-1:0];
    wire [IDATA_WIDTH-1:0] fft_din_even[EVEN_NUM-1:0];
    wire [IDATA_WIDTH+2-1:0] add_out_odd[HALF_INPUTS_NUM-1:0];
    wire [HALF_INPUTS_NUM-1:0] add_out_valid_odd;

    wire [ADD_DATA_OUT_WIDTH-1:0] add_out_even[EVEN_NUM-1:0];

    wire [ADD_DATA_IN_WIDTH-1:0] mat_din_even_new[EVEN_NUM-1:0];
    wire [ADD_DATA_IN_WIDTH-1:0] fft_din_even_new[EVEN_NUM-1:0];


    // integer EXP_BIT;
    generate
        for (i = 0; i < HALF_INPUTS_NUM; i = i + 1) begin
            assign add_out_odd[i][IDATA_WIDTH+2-1:0] = add_out[i*2][IDATA_WIDTH+2-1:0];
            assign add_out_valid_odd[i] = add_out_valid[i*2];
        end
        // assign add_in_valid_even = is_fft ? in_valid : add_out_valid_odd[0];  //简单写法
        for (i = 0; i < EVEN_NUM; i = i + 1) begin : even_add



            //mat_din_even和fft_din_even需要扩展的符号位数
            localparam EXP_BIT = (get_level(i) + 1) * 2;
            localparam ADD_IN_BIT = IDATA_WIDTH + EXP_BIT;  //当前加法输入位宽
            localparam ADD_OUT_BIT = ADD_IN_BIT + 2;
            localparam LS_WIDTH = ADD_IN_BIT / 2;
            localparam MS_WIDTH = ADD_IN_BIT / 2;

            assign mat_din_even[i] = mat_din[i*2+1];
            assign fft_din_even[i] = fft_din[i*2+1];

            // assign mat_din_even_new[i][ADD_IN_BIT-1:0] = is_int16?{{(EXP_BIT){mat_din_even[i][IDATA_WIDTH-1]}},mat_din_even[i][IDATA_WIDTH-1:0]}
            //                                     :{{(EXP_BIT/2){mat_din_even[i][IDATA_WIDTH-1]}},mat_din_even[i][IDATA_WIDTH-1:IDATA_WIDTH/2],
            //                                     {(EXP_BIT/2){mat_din_even[i][IDATA_WIDTH/2-1]}},mat_din_even[i][IDATA_WIDTH/2-1:0]};
            // assign fft_din_even_new[i][ADD_IN_BIT-1:0] = is_int16?{{(EXP_BIT){fft_din_even[i][IDATA_WIDTH-1]}},fft_din_even[i][IDATA_WIDTH-1:0]}
            //                                     :{{(EXP_BIT/2){fft_din_even[i][IDATA_WIDTH-1]}},fft_din_even[i][IDATA_WIDTH-1:IDATA_WIDTH/2],
            //                                     {(EXP_BIT/2){fft_din_even[i][IDATA_WIDTH/2-1]}},fft_din_even[i][IDATA_WIDTH/2-1:0]};

            sign_bit_exp #(
                .IDATA_WIDTH(IDATA_WIDTH),
                .EXP_BIT    (EXP_BIT),
                .ODATA_WIDTH(ADD_IN_BIT)
            ) u_sign_bit_exp_mat_din_even (
                .is_int16(is_int16),
                .idata   (mat_din_even[i][IDATA_WIDTH-1:0]),
                .odata(mat_din_even_new[i][ADD_IN_BIT-1:0])
            );
            sign_bit_exp #(
                .IDATA_WIDTH(IDATA_WIDTH),
                .EXP_BIT    (EXP_BIT),
                .ODATA_WIDTH(ADD_IN_BIT)
            ) u_sign_bit_exp_fft_din_even (
                .is_int16(is_int16),
                .idata   (fft_din_even[i][IDATA_WIDTH-1:0]),
                .odata(fft_din_even_new[i][ADD_IN_BIT-1:0])
            );

            if ((i + 1) % 2 == 1) begin : sub_odd
                assign add_in_valid_even[i] = is_fft ? in_valid[i*2+1] : add_out_valid_odd[0];
                // 奇数情况下加法使用mat_din_even_new和fft_din_even_new
                assign add_in1_even[i][ADD_IN_BIT-1:0] = is_fft?mat_din_even_new[i][ADD_IN_BIT-1:0]:add_out_odd[i][ADD_IN_BIT-1:0];
                assign add_in2_even[i][ADD_IN_BIT-1:0] = is_fft?fft_din_even_new[i][ADD_IN_BIT-1:0]:add_out_odd[i+1][ADD_IN_BIT-1:0];
                split_add #(
                    .LS_WIDTH(LS_WIDTH),
                    .MS_WIDTH(MS_WIDTH),
                    .WIDTH(LS_WIDTH + MS_WIDTH)
                ) split_add_even_sub_odd (
                    .clk      (clk),
                    .rstn     (rstn),
                    .bypass   (1'b0),
                    .is_int16 (is_int16),
                    .in_valid (add_in_valid_even[i]),
                    .in1      (add_in1_even[i][ADD_IN_BIT-1:0]),
                    .in2      (add_in2_even[i][ADD_IN_BIT-1:0]),
                    .out      (add_out_even[i][ADD_OUT_BIT-1:0]),
                    .out_valid(add_out_valid_even[i])
                );

            end else if ((i + 1) % 2 == 0) begin : sub_odd_even
                // 偶数情况下加法左边输入使用mat_din_even_new | add_out_even，右边输入使用fft_din_even_new | add_out_even
                localparam LEFT_INDEX = get_left(i);
                localparam RIGHT_INDEX = get_right(i);
                assign add_in_valid_even[i] = is_fft ? in_valid[i*2+1] : (add_out_valid_even[LEFT_INDEX]&add_out_valid_even[RIGHT_INDEX]);
                assign add_in1_even[i][ADD_IN_BIT-1:0] = is_fft?mat_din_even_new[i][ADD_IN_BIT-1:0]:add_out_even[LEFT_INDEX][ADD_IN_BIT-1:0];
                assign add_in2_even[i][ADD_IN_BIT-1:0] = is_fft?fft_din_even_new[i][ADD_IN_BIT-1:0]:add_out_even[RIGHT_INDEX][ADD_IN_BIT-1:0];
                split_add #(
                    .LS_WIDTH(LS_WIDTH),
                    .MS_WIDTH(MS_WIDTH),
                    .WIDTH(LS_WIDTH + MS_WIDTH)
                ) split_add_even_sub_even (
                    .clk      (clk),
                    .rstn     (rstn),
                    .bypass   (1'b0),
                    .is_int16 (is_int16),
                    .in_valid (add_in_valid_even[i]),
                    .in1      (add_in1_even[i][ADD_IN_BIT-1:0]),
                    .in2      (add_in2_even[i][ADD_IN_BIT-1:0]),
                    .out      (add_out_even[i][ADD_OUT_BIT-1:0]),
                    .out_valid(add_out_valid_even[i])
                );
            end
            // assign odata[i*2+1][ODATA_WIDTH-1:0] = is_int16?{{(ODATA_WIDTH - ADD_OUT_BIT) {add_out_even[i][ADD_OUT_BIT-1]}},add_out_even[i][ADD_OUT_BIT-1:0]}
            //                                                 :{{((ODATA_WIDTH - ADD_OUT_BIT)/2) {add_out_even[i][ADD_OUT_BIT-1]}},add_out_even[i][ADD_OUT_BIT-1:ADD_OUT_BIT/2],
            //                                                 {((ODATA_WIDTH - ADD_OUT_BIT)/2) {add_out_even[i][ADD_OUT_BIT/2-1]}},add_out_even[i][ADD_OUT_BIT/2-1:0]};

            assign add_out_valid[i*2+1] = add_out_valid_even[i];
            sign_bit_exp #(
                .IDATA_WIDTH(ADD_OUT_BIT),
                .EXP_BIT    ((ODATA_WIDTH - ADD_OUT_BIT)),
                .ODATA_WIDTH(ODATA_WIDTH)
            ) u_sign_bit_exp_odata_even (
                .is_int16(is_int16),
                .idata   (add_out_even[i][ADD_OUT_BIT-1:0]),
                .odata(odata[i*2+1][ODATA_WIDTH-1:0])
            );

            // assign odata[i*2+1][ODATA_WIDTH-1:0] = {
            //     {(ODATA_WIDTH - ADD_OUT_BIT) {add_out_even[i][ADD_OUT_BIT-1]}},
            //     add_out_even[i][ADD_OUT_BIT-1:0]
            // };

        end
    endgenerate

    // assign out_valid = is_fft ? add_out_valid : add_out_valid[INPUTS_NUM/2-1];
    assign out_valid = add_out_valid;




endmodule



