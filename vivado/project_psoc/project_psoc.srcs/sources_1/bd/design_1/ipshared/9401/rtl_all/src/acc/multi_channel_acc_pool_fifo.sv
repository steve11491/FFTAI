module multi_channel_acc_pool_fifo #(
    parameter CHANNEL_NUM = 16,
    parameter ODATA_WIDTH = 40,
    parameter IMAP_WIDTH = 16,
    parameter WEIGHT_WIDTH = 16,
    parameter ACC_WIDTH = 40,
    parameter ZERO_POINT_WIDTH = 16,
    // parameter C_WIDTH = 32,  // 矩阵C/Bias，int16情况下为int32，int8情况下为2个int16
    parameter FIFO_ACC_DEPTH = 1024,
    parameter FIFO_ACC_ADDR_WIDTH = $clog2(FIFO_ACC_DEPTH)
) (
    input wire                        clk,
    input wire                        rstn,
    input wire                        is_int16,
    input wire                        is_pool,
    input wire                        pool_type,
    input wire [                 1:0] conv_type,
    input wire                        is_padding,
    input wire [ZERO_POINT_WIDTH-1:0] zero_point_in,
    input wire                        use_bias_internal,
    input wire                        acc_pool_out_enable,
    input wire                        is_acc_pool_first,
    input wire                        fifo_acc_rd_en,
    input wire [     CHANNEL_NUM-1:0] acc_pool_enable_mask,
    input wire [     CHANNEL_NUM-1:0] mat_data_out_valid,
    input wire [     ODATA_WIDTH-1:0] mat_data_out        [CHANNEL_NUM-1:0],

    input wire [WEIGHT_WIDTH-1:0] dwc_weight_in[CHANNEL_NUM-1:0],

    input  wire [CHANNEL_NUM-1:0] imap_data_out_valid,
    input  wire [ IMAP_WIDTH-1:0] imap_data_out      [CHANNEL_NUM-1:0],
    input  wire [  ACC_WIDTH-1:0] c_in               [CHANNEL_NUM-1:0],
    output reg  [  ACC_WIDTH-1:0] acc_pool_out       [CHANNEL_NUM-1:0],
    output reg  [CHANNEL_NUM-1:0] out_valid
);
    localparam STC = 0, DWC = 1;
    localparam MAX_POOL = 1'b0, AVG_POOL = 1'b1;
    wire [ CHANNEL_NUM-1:0] in_valid;
    wire [   ACC_WIDTH-1:0] acc_in            [  CHANNEL_NUM-1:0];
    wire [   ACC_WIDTH-1:0] acc_in2           [  CHANNEL_NUM-1:0];

    // for debug
    wire [IMAP_WIDTH/2-1:0] imap_data_out_int8[CHANNEL_NUM*2-1:0];
    wire [ ACC_WIDTH/2-1:0] acc_in_int8       [CHANNEL_NUM*2-1:0];
    wire [ ACC_WIDTH/2-1:0] c_in_int8         [CHANNEL_NUM*2-1:0];
    wire [ ACC_WIDTH/2-1:0] acc_in2_int8      [CHANNEL_NUM*2-1:0];
    wire [ ACC_WIDTH/2-1:0] acc_pool_out_int8 [CHANNEL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {imap_data_out_int8[i*2+1], imap_data_out_int8[i*2]} = imap_data_out[i];
            assign {acc_in_int8[i*2+1], acc_in_int8[i*2]} = acc_in[i];
            assign {c_in_int8[i*2+1], c_in_int8[i*2]} = c_in[i];
            assign {acc_in2_int8[i*2+1], acc_in2_int8[i*2]} = acc_in2[i];
            assign {acc_pool_out_int8[i*2+1], acc_pool_out_int8[i*2]} = acc_pool_out[i];

        end
    endgenerate
    // for debug

    // wire is_maxpool = (is_pool && pool_type == MAX_POOL);
    // wire is_avgpool = (is_pool && pool_type == AVG_POOL);
    // wire is_stc = (~is_pool && conv_type == STC);
    // wire is_dwc = (~is_pool && conv_type == DWC);

    // wire is_use_acc = (~is_pool) | is_avgpool;

    reg is_maxpool;
    reg is_avgpool;
    reg is_conv;
    reg is_stc;
    reg is_not_stc;
    reg is_dwc;
    reg is_use_acc;
    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_maxpool <= 0;
            is_avgpool <= 0;
            is_conv <= 0;
            is_stc <= 0;
            is_not_stc <= 0;
            is_dwc <= 0;
            is_use_acc <= 0;
            is_int16_reg <= 0;
        end else begin
            is_maxpool <= (is_pool && (pool_type == MAX_POOL));
            is_avgpool <= (is_pool && (pool_type == AVG_POOL));
            is_conv <= ~is_pool;
            is_stc <= ((~is_pool) && (conv_type == STC));
            is_not_stc <= ~((~is_pool) && (conv_type == STC));
            is_dwc <= ((~is_pool) && (conv_type == DWC));
            is_use_acc <= (~is_pool) | is_avgpool;
            is_int16_reg <= is_int16;
        end
    end


    wire [IMAP_WIDTH+2-1:0] imap_data_out_add_zeropoint[CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] imap_data_out_add_zeropoint_valid;
    wire [ZERO_POINT_WIDTH-1:0] zero_point_in_true;
    assign zero_point_in_true =is_int16_reg?(zero_point_in[ZERO_POINT_WIDTH-1:0]):({zero_point_in[ZERO_POINT_WIDTH/2-1:0],zero_point_in[ZERO_POINT_WIDTH/2-1:0]});
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin : zero_point_add_gen
            split_addsub_inv #(
                // split_addsub_xor #(
                .LS_WIDTH(IMAP_WIDTH / 2),
                .MS_WIDTH(IMAP_WIDTH / 2),
                .WIDTH(IMAP_WIDTH)
            ) u_split_add (
                .clk      (clk),
                .rstn     (rstn),
                .bypass   (1'b1),
                .is_sub   (1'b1),
                .is_int16 (is_int16_reg),
                .in_valid (imap_data_out_valid[i] & (~is_stc)),
                .in1      (imap_data_out[i]),
                .in2      (zero_point_in_true),
                .out      (imap_data_out_add_zeropoint[i]),
                .out_valid(imap_data_out_add_zeropoint_valid[i])
            );
        end
    endgenerate
    wire [(IMAP_WIDTH+2)/2-1:0] imap_data_out_add_zeropoint_int8[CHANNEL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {imap_data_out_add_zeropoint_int8[i*2+1], imap_data_out_add_zeropoint_int8[i*2]} = imap_data_out_add_zeropoint[i];
        end
    endgenerate



    localparam MAX_WIDTH = IMAP_WIDTH;
    localparam [(IMAP_WIDTH+2)-1:0] NEG_MAX_INT8_PAD = {
        {2{1'b1}}, {(IMAP_WIDTH / 2 - 1) {1'b0}}, {2{1'b1}}, {(IMAP_WIDTH / 2 - 1) {1'b0}}
    };
    localparam [(IMAP_WIDTH+2)-1:0] NEG_MAX_INT16_PAD = {{3{1'b1}}, {(IMAP_WIDTH - 1) {1'b0}}};
    reg [IMAP_WIDTH+2-1:0] imap_data_out_add_zeropoint_pad[CHANNEL_NUM-1:0];
    reg [CHANNEL_NUM-1:0] imap_data_out_add_zeropoint_pad_valid;



    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin : padding_gen
            always @(posedge clk) begin
                imap_data_out_add_zeropoint_pad[i] <= ((is_pool|is_dwc)&(is_padding|~imap_data_out_add_zeropoint_valid[i]))? (is_maxpool?(is_int16_reg ? NEG_MAX_INT16_PAD :NEG_MAX_INT8_PAD):0):imap_data_out_add_zeropoint[i];
            end
            always @(posedge clk or negedge rstn) begin
                if (~rstn) begin
                    imap_data_out_add_zeropoint_pad_valid[i] <= 0;
                end else begin
                    imap_data_out_add_zeropoint_pad_valid[i] <= imap_data_out_valid[i];
                end
            end
        end
    endgenerate


    localparam DWC_DATA_WIDTH = IMAP_WIDTH * 2;
    wire [   CHANNEL_NUM-1:0] dwc_data_out_valid;
    wire [DWC_DATA_WIDTH-1:0] dwc_data_out       [CHANNEL_NUM-1:0];

    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin : dwc_single_gen
            single_channel_dwc #(
                .WIDTH(IMAP_WIDTH)
            ) u_single_channel_dwc (
                .clk           (clk),
                .rstn          (rstn),
                .in_valid      (imap_data_out_add_zeropoint_pad_valid[i] & is_dwc),
                .is_int16      (is_int16_reg),
                .data_in1      (dwc_weight_in[i]),
                .data_in2      (imap_data_out_add_zeropoint_pad[i]),
                .data_out      (dwc_data_out[i]),
                .data_out_valid(dwc_data_out_valid[i])
            );
        end
    endgenerate



    assign in_valid = (imap_data_out_add_zeropoint_pad_valid & ({CHANNEL_NUM{is_pool}})) | (mat_data_out_valid & ({CHANNEL_NUM{is_stc}}))| (dwc_data_out_valid & ({CHANNEL_NUM{is_dwc}}));
    wire [ACC_WIDTH-1:0] acc_in_mat    [CHANNEL_NUM-1:0];
    wire [ACC_WIDTH-1:0] acc_in_dwc    [CHANNEL_NUM-1:0];
    wire [ACC_WIDTH-1:0] acc_in_avgpool[CHANNEL_NUM-1:0];
    generate

        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin : acc_in_mat_gen
            sign_bit_exp #(
                .IDATA_WIDTH(ODATA_WIDTH),
                .EXP_BIT    (ACC_WIDTH - ODATA_WIDTH),
                .ODATA_WIDTH(ACC_WIDTH)
            ) u_sign_bit_exp_acc_in_mat (
                .is_int16(is_int16_reg),
                .idata   (mat_data_out[i]),
                .odata(acc_in_mat[i])
            );
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin : acc_in_dwc_gen
            sign_bit_exp #(
                .IDATA_WIDTH(DWC_DATA_WIDTH),
                .EXP_BIT    (ACC_WIDTH - DWC_DATA_WIDTH),
                .ODATA_WIDTH(ACC_WIDTH)
            ) u_sign_bit_exp_acc_in_dwc (
                .is_int16(is_int16_reg),
                .idata   (dwc_data_out[i]),
                .odata(acc_in_dwc[i])
            );
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin : acc_in_avgpool_gen
            sign_bit_exp #(
                .IDATA_WIDTH(IMAP_WIDTH + 2),
                .EXP_BIT    (ACC_WIDTH - (IMAP_WIDTH + 2)),
                .ODATA_WIDTH(ACC_WIDTH)
            ) u_sign_bit_exp_acc_in_avgpool (
                .is_int16(is_int16_reg),
                .idata   (imap_data_out_add_zeropoint_pad[i]),
                .odata(acc_in_avgpool[i])
            );
        end
    endgenerate

    assign acc_in = is_avgpool ? acc_in_avgpool : (is_dwc ? acc_in_dwc : acc_in_mat);


    logic [  ACC_WIDTH-1:0] acc_out_w        [CHANNEL_NUM-1:0];
    wire  [CHANNEL_NUM-1:0] acc_out_valid_w;


    wire                    fifo_acc_full;
    wire                    fifo_acc_empty;
    wire  [CHANNEL_NUM-1:0] fifo_acc_wr_true;
    wire  [CHANNEL_NUM-1:0] fifo_acc_rd_true;
    wire  [  ACC_WIDTH-1:0] fifo_acc_wr_data [CHANNEL_NUM-1:0];
    wire  [  ACC_WIDTH-1:0] fifo_acc_rd_data [CHANNEL_NUM-1:0];


    reg   [CHANNEL_NUM-1:0] out_valid_ff;



    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin : acc_single_gen
            assign acc_in2[i] = is_acc_pool_first ? (((use_bias_internal==1'b0 & ~is_pool) | is_avgpool) ? 0 : c_in[i] ) : fifo_acc_rd_data[i];
            single_channel_acc #(
                .ACC_WIDTH(ACC_WIDTH)
            ) u_single_channel_acc (
                .clk          (clk),
                .rstn         (rstn),
                .in_valid     (in_valid[i] & is_use_acc),
                .is_int16     (is_int16_reg),
                .acc_in1      (acc_in[i]),
                .acc_in2      (acc_in2[i]),
                .acc_out      (acc_out_w[i]),
                .acc_out_valid(acc_out_valid_w[i])
            );
        end
    endgenerate


    wire [  MAX_WIDTH-1:0] max_in1         [  CHANNEL_NUM-1:0];
    wire [  MAX_WIDTH-1:0] max_in2         [  CHANNEL_NUM-1:0];
    wire [  MAX_WIDTH-1:0] max_out_w       [  CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] max_out_valid_w;

    wire [MAX_WIDTH/2-1:0] max_in1_int8    [CHANNEL_NUM*2-1:0];
    wire [MAX_WIDTH/2-1:0] max_in2_int8    [CHANNEL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {max_in1_int8[i*2+1], max_in1_int8[i*2]} = max_in1[i];
            assign {max_in2_int8[i*2+1], max_in2_int8[i*2]} = max_in2[i];
        end
    endgenerate

    localparam [(IMAP_WIDTH)-1:0] NEG_MAX_INT8 = {
        {{1'b1}}, {(IMAP_WIDTH / 2 - 1) {1'b0}}, {{1'b1}}, {(IMAP_WIDTH / 2 - 1) {1'b0}}
    };
    localparam [(IMAP_WIDTH)-1:0] NEG_MAX_INT16 = {{1{1'b1}}, {(IMAP_WIDTH - 1) {1'b0}}};

    // assign max_in1 = imap_data_out_add_zeropoint_pad;
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin : maxpool_single_gen
            split_data_cut #(
                .DIN_WIDTH (IMAP_WIDTH + 2),
                .DOUT_WIDTH(MAX_WIDTH)
            ) u_split_data_cut (
                .is_int16(is_int16_reg),
                .din(imap_data_out_add_zeropoint_pad[i]),
                .dout(max_in1[i])
            );
            assign max_in2[i] = is_acc_pool_first ? (is_int16_reg ? NEG_MAX_INT16 :NEG_MAX_INT8 ) : fifo_acc_rd_data[i][MAX_WIDTH-1:0];
            single_channel_maxpool #(
                .MAX_WIDTH(MAX_WIDTH)
            ) u_single_channel_maxpool (
                .clk          (clk),
                .rstn         (rstn),
                .in_valid     (in_valid[i] & is_maxpool),
                .is_int16     (is_int16_reg),
                .max_in1      (max_in1[i]),
                .max_in2      (max_in2[i]),
                .max_out      (max_out_w[i]),
                .max_out_valid(max_out_valid_w[i])
            );
        end
    endgenerate
    wire [ACC_WIDTH-1:0] max_out_w_exp[CHANNEL_NUM-1:0];
    generate

        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            sign_bit_exp #(
                .IDATA_WIDTH(MAX_WIDTH),
                .EXP_BIT    (ACC_WIDTH - MAX_WIDTH),
                .ODATA_WIDTH(ACC_WIDTH)
            ) u_sign_bit_exp_max_out_w_exp (
                .is_int16(is_int16_reg),
                .idata   (max_out_w[i]),
                .odata(max_out_w_exp[i])
            );
        end
    endgenerate
    wire [  ACC_WIDTH-1:0] acc_pool_out_w       [CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] acc_pool_out_valid_w;
    assign acc_pool_out_w = is_maxpool ? max_out_w_exp : acc_out_w;
    assign acc_pool_out_valid_w = ({CHANNEL_NUM{is_maxpool}} & max_out_valid_w) | (({CHANNEL_NUM{is_use_acc}}) & acc_out_valid_w);


    wire fifo_acc_wr_en = 1'b1;
    assign fifo_acc_wr_true = ({(CHANNEL_NUM){fifo_acc_wr_en}}) & acc_pool_out_valid_w & (~out_valid_ff) & ({(CHANNEL_NUM) {~fifo_acc_full}});
    assign fifo_acc_rd_true = ({(CHANNEL_NUM){fifo_acc_rd_en}})  & acc_pool_enable_mask & ({(CHANNEL_NUM) {~fifo_acc_empty}});

    // 允许fifo写穿
    // assign fifo_acc_rd_true = ({(CHANNEL_NUM){fifo_acc_rd_en}})  & in_valid & (({(CHANNEL_NUM) {~fifo_acc_empty}}) | (({(CHANNEL_NUM) {fifo_acc_empty}}) & fifo_acc_wr_true)  );
    // assign fifo_acc_rd_true = ({(CHANNEL_NUM){fifo_acc_rd_en}})  & in_valid & (({(CHANNEL_NUM) {~fifo_acc_empty}}) );

    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign fifo_acc_wr_data[i] = is_maxpool ? {{ACC_WIDTH-MAX_WIDTH{1'b0}},{max_out_w[i]}} : acc_out_w[i];
        end
    endgenerate


    always @(posedge clk) begin
        acc_pool_out <= acc_pool_out_w;
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid_ff <= 0;
            out_valid <= 0;
        end else begin
            out_valid_ff <= in_valid & ({(CHANNEL_NUM) {acc_pool_out_enable}});
            out_valid <= out_valid_ff;
        end
    end
    multi_port_fifo #(
        .PORT_NUM     (CHANNEL_NUM),
        .WIDTH        (ACC_WIDTH),
        .DEPTH        (FIFO_ACC_DEPTH),
        .ADDR_WIDTH   (FIFO_ACC_ADDR_WIDTH),
        .RAM_STYLE_VAL("block")
    ) u_multi_port_fifo (
        .clk         (clk),
        .rstn        (rstn),
        .wr_en       (fifo_acc_wr_true),
        .rd_en       (fifo_acc_rd_true),
        .wr_data     (fifo_acc_wr_data),
        .rd_data     (fifo_acc_rd_data),
        .rd_valid    (),
        .full        (fifo_acc_full),
        .empty       (fifo_acc_empty),
        .almost_full (),
        .almost_empty(),
        .fifo_counter()
    );

endmodule
