module multi_channel_acc_fifo #(
    parameter CHANNEL_NUM = 16,
    parameter ACC_WIDTH = 40,
    parameter C_WIDTH = 32,  // 矩阵C/Bias，int16情况下为int32，int8情况下为2个int16
    parameter FIFO_ACC_DEPTH = 1024,
    parameter FIFO_ACC_ADDR_WIDTH = $clog2(FIFO_ACC_DEPTH)
) (
    input  wire                   clk,
    input  wire                   rstn,
    input  wire                   is_int16,
    input  wire                   use_bias_internal,
    input  wire                   acc_out_enable,
    input  wire                   is_acc_first,
    input  wire                   fifo_acc_rd_en,
    input  wire [CHANNEL_NUM-1:0] acc_enable_mask,
    input  wire [CHANNEL_NUM-1:0] in_valid,
    input  wire [  ACC_WIDTH-1:0] acc_in           [CHANNEL_NUM-1:0],
    input  wire [  ACC_WIDTH-1:0] c_in             [CHANNEL_NUM-1:0],
    output reg  [  ACC_WIDTH-1:0] acc_out          [CHANNEL_NUM-1:0],
    output reg  [CHANNEL_NUM-1:0] out_valid
);



    wire [  ACC_WIDTH-1:0] acc_in2     [  CHANNEL_NUM-1:0];

    // for debug
    wire [ACC_WIDTH/2-1:0] acc_in_int8 [CHANNEL_NUM*2-1:0];
    wire [ACC_WIDTH/2-1:0] c_in_int8   [CHANNEL_NUM*2-1:0];
    wire [ACC_WIDTH/2-1:0] acc_in2_int8[CHANNEL_NUM*2-1:0];
    wire [ACC_WIDTH/2-1:0] acc_out_int8[CHANNEL_NUM*2-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {acc_in_int8[i*2+1], acc_in_int8[i*2]} = acc_in[i];
            assign {c_in_int8[i*2+1], c_in_int8[i*2]} = c_in[i];
            assign {acc_in2_int8[i*2+1], acc_in2_int8[i*2]} = acc_in2[i];
            assign {acc_out_int8[i*2+1], acc_out_int8[i*2]} = acc_out[i];

        end
    endgenerate



    // for debug


    logic [  ACC_WIDTH-1:0] acc_out_w         [CHANNEL_NUM-1:0];
    wire  [CHANNEL_NUM-1:0] acc_out_valid_w;


    wire                    fifo_acc_full;
    wire                    fifo_acc_empty;
    wire  [CHANNEL_NUM-1:0] fifo_acc_wr_true;
    wire  [CHANNEL_NUM-1:0] fifo_acc_rd_true;
    wire  [  ACC_WIDTH-1:0] fifo_acc_wr_data  [CHANNEL_NUM-1:0];
    wire  [  ACC_WIDTH-1:0] fifo_acc_rd_data  [CHANNEL_NUM-1:0];


    reg                     acc_out_enable_ff;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            acc_out_enable_ff <= 0;
        end else begin
            acc_out_enable_ff <= acc_out_enable;
        end
    end
    reg [CHANNEL_NUM-1:0] out_valid_ff;
    wire fifo_acc_wr_en = 1'b1;
    assign fifo_acc_wr_true = ({(CHANNEL_NUM){fifo_acc_wr_en}}) & acc_out_valid_w & (~out_valid_ff) & ({(CHANNEL_NUM) {~fifo_acc_full}});
    assign fifo_acc_rd_true = ({(CHANNEL_NUM){fifo_acc_rd_en}})  & acc_enable_mask & ({(CHANNEL_NUM) {~fifo_acc_empty}});
    assign fifo_acc_wr_data = acc_out_w;

    always @(posedge clk) begin
        acc_out <= acc_out_w;
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid_ff <= 0;
            out_valid <= 0;
        end else begin
            out_valid_ff <= in_valid & ({(CHANNEL_NUM) {acc_out_enable}});
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

    genvar i;
    generate
        for (i = 0; i < CHANNEL_NUM; i = i + 1) begin : acc_single_gen
            assign acc_in2[i] = is_acc_first ? (use_bias_internal ? c_in[i] : 0 ) : fifo_acc_rd_data[i];
            single_channel_acc #(
                .ACC_WIDTH          (ACC_WIDTH),
                .FIFO_ACC_DEPTH     (FIFO_ACC_DEPTH),
                .FIFO_ACC_ADDR_WIDTH(FIFO_ACC_ADDR_WIDTH)
            ) u_single_channel_acc (
                .clk          (clk),
                .rstn         (rstn),
                .in_valid     (in_valid[i]),
                .is_int16     (is_int16),
                .acc_in1      (acc_in[i]),
                .acc_in2      (acc_in2[i]),
                .acc_out      (acc_out_w[i]),
                .acc_out_valid(acc_out_valid_w[i])
            );
        end
    endgenerate

endmodule
