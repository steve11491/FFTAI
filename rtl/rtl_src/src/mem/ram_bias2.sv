module ram_bias2 #(
    parameter CHANNEL_NUM = 16,
    parameter WIDTH = 40,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input wire clk,
    input wire rstn,
    input wire ram_bias2_pingpong,
    input wire [CHANNEL_NUM-1:0] rd_en,
    input wire [ADDR_WIDTH-1:0] rd_addr[CHANNEL_NUM-1:0],
    output reg [WIDTH-1:0] rd_data[CHANNEL_NUM-1:0],
    output reg [CHANNEL_NUM-1:0] rd_valid,

    input wire [CHANNEL_NUM-1:0] wr_en,
    input wire [ADDR_WIDTH-1:0] wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] wr_data[CHANNEL_NUM-1:0]

);

    logic [WIDTH/2-1:0] rd_data_int8[CHANNEL_NUM*2-1:0];
    logic [WIDTH/2-1:0] wr_data_int8[CHANNEL_NUM*2-1:0];

    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {rd_data_int8[i*2+1], rd_data_int8[i*2]} = rd_data[i][WIDTH-1:0];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {wr_data_int8[i*2+1], wr_data_int8[i*2]} = wr_data[i][WIDTH-1:0];
        end
    endgenerate
    wire [WIDTH-1:0] rd_data_w[CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] rd_valid_w;
    pingpong_ram_swsr #(
        .CHANNEL_NUM(CHANNEL_NUM),
        .WIDTH      (WIDTH),
        .DEPTH      (DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_pingpong_ram_swsr_bias2 (
        .clk     (clk),
        .rstn    (rstn),
        .pingpong(ram_bias2_pingpong),
        .rd_en   (rd_en),
        .rd_addr (rd_addr),
        .wr_en   (wr_en),
        .wr_addr (wr_addr),
        .wr_data (wr_data),

        .rd_data (rd_data_w),
        .rd_valid(rd_valid_w)

    );

    // assign rd_data  = rd_data_w;
    // assign rd_valid = rd_valid_w;
    always @(posedge clk) begin
        rd_data <= rd_data_w;
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            rd_valid <= 0;
        end else begin
            rd_valid <= rd_valid_w;
        end
    end


endmodule
