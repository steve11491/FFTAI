module multi_channel_ram_array #(
    parameter CHANNEL_NUM = 16,
    parameter WIDTH = 40,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input wire clk,
    input wire rstn,
    input wire [CHANNEL_NUM-1:0] wr_en,
    input wire [CHANNEL_NUM-1:0] rd_en,
    input wire [ADDR_WIDTH-1:0] wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] wr_data[CHANNEL_NUM-1:0],
    input wire [ADDR_WIDTH-1:0] rd_addr[CHANNEL_NUM-1:0],
    output wire [WIDTH-1:0] rd_data[CHANNEL_NUM-1:0],
    output wire [CHANNEL_NUM-1:0] rd_valid
);


    wire [  WIDTH-1:0] wr_data_int16[  CHANNEL_NUM-1:0];
    wire [WIDTH/2-1:0] wr_data_int8 [CHANNEL_NUM*2-1:0];
    wire [  WIDTH-1:0] rd_data_int16[  CHANNEL_NUM-1:0];
    wire [WIDTH/2-1:0] rd_data_int8 [CHANNEL_NUM*2-1:0];
    generate

        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign wr_data_int16[i] = wr_data[i];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {wr_data_int8[i*2+1], wr_data_int8[i*2]} = wr_data[i];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign rd_data_int16[i] = rd_data[i];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {rd_data_int8[i*2+1], rd_data_int8[i*2]} = rd_data[i];
        end
    endgenerate

    genvar i;
    generate
        for (i = 0; i < CHANNEL_NUM; i = i + 1) begin : sdp_ram_gen
            com_simple_dual_port_ram_two_clock_rst #(
                .WIDTH(WIDTH),
                .DEPTH(DEPTH),
                .RAM_STYLE_VAL("block")
            ) sdp_ram (
                .clka(clk),
                .clkb(clk),
                .rstnb(rstn),
                .wea(wr_en[i]),
                .ena(wr_en[i]),
                .enb(rd_en[i]),
                .addra(wr_addr[i]),
                .dina(wr_data[i]),
                .addrb(rd_addr[i]),
                .doutb(rd_data[i]),
                .validb(rd_valid[i])
            );

        end
    endgenerate

    // com_simple_dual_port_multi_ram #(
    //     .CHANNEL_NUM  (CHANNEL_NUM),
    //     .WIDTH        (WIDTH),
    //     .DEPTH        (DEPTH),
    //     .ADDR_WIDTH   (ADDR_WIDTH),
    //     .RAM_STYLE_VAL("block")
    // ) u_com_simple_dual_port_multi_ram (
    //     .clk    (clk),
    //     .rstn   (rstn),
    //     .wr_en  (wr_en),
    //     .rd_en  (rd_en),
    //     .wr_addr(wr_addr),
    //     .wr_data(wr_data),
    //     .rd_addr(rd_addr),

    //     .rd_data (rd_data),
    //     .rd_valid(rd_valid)
    // );

endmodule
