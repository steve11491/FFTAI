// 多端口fifo，多个fifo的读写行为在写入一批数据和读出该批数据的行为应该保持一致
// 例如4个fifo，以4'b1100的wr_en写入N个数据，读这N个数据必须以4'b1100的rd_en读出，写入和读出期间的wr_en和rd_en不能改变

module multi_port_fifo #(
    parameter PORT_NUM = 16,
    parameter WIDTH = 16,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input wire                clk,
    input wire                rstn,
    input wire [PORT_NUM-1:0] wr_en,
    input wire [PORT_NUM-1:0] rd_en,
    input wire [   WIDTH-1:0] wr_data[PORT_NUM-1:0],

    output wire [WIDTH-1:0] rd_data[PORT_NUM-1:0],
    output wire [PORT_NUM-1:0] rd_valid,
    output wire full,
    output wire empty,
    output wire almost_full,
    output wire almost_empty,
    output wire [ADDR_WIDTH:0] fifo_counter
);

    reg [ADDR_WIDTH-1:0] rd_addr;
    reg [ADDR_WIDTH-1:0] wr_addr;
    reg    [ADDR_WIDTH:0]  counter;         //计数器最大数值需达到16,4位2进制数最大只能表示15，故不需减1
    assign fifo_counter = counter;
    //define full and empty status
    assign full = (counter == DEPTH) ? 1 : 0;
    assign empty = (counter == 'h0) ? 1 : 0;

    assign almost_full = (counter == (DEPTH - 1)) ? 1 : 0;
    assign almost_empty = (counter == 1) ? 1 : 0;
    wire wr_en_concat;
    wire rd_en_concat;
    assign wr_en_concat = |wr_en;
    assign rd_en_concat = |rd_en;
    wire [PORT_NUM-1:0] wr_en_true;
    wire [PORT_NUM-1:0] rd_en_true;
    assign wr_en_true = (wr_en) & ({(PORT_NUM) {!full}});
    assign rd_en_true = (rd_en) & ({(PORT_NUM) {!empty}});

    genvar i;
    generate
        for (i = 0; i < PORT_NUM; i = i + 1) begin : sdp_ram_gen
            com_simple_dual_port_ram_two_clock_rst #(
                .WIDTH(WIDTH),
                .DEPTH(DEPTH),
                .RAM_STYLE_VAL(RAM_STYLE_VAL)
            ) sdp_ram (
                .clka(clk),
                .clkb(clk),
                .rstnb(rstn),
                .wea(wr_en_true[i]),
                .ena(wr_en_true[i]),
                .enb(rd_en_true[i]),
                .addra(wr_addr),
                .dina(wr_data[i]),
                .addrb(rd_addr),
                .doutb(rd_data[i]),
                .validb(rd_valid[i])
            );
        end
    endgenerate



    //generate  rd_addr, 产生读地址
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            rd_addr <= 'h0;
        end else if (rd_en_concat) begin
            if (rd_addr == (DEPTH - 1)) begin
                rd_addr <= 0;
            end else begin
                rd_addr <= rd_addr + 1'b1;
            end

        end
    end

    //generate  wr_addr, 产生写地址
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            wr_addr <= 'h0;
        end else if (wr_en_concat) begin
            if (wr_addr == (DEPTH - 1)) begin
                wr_addr <= 0;
            end else begin
                wr_addr <= wr_addr + 1'b1;
            end
        end
    end

    //counter in fifo,计录存储体中的数据长度
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            counter <= 'b0;
        end else if (!full && wr_en_concat && !rd_en_concat) begin
            counter <= counter + 1'b1;
        end else if (!empty && !wr_en_concat && rd_en_concat) begin
            counter <= counter - 1'b1;
        end else begin
            counter <= counter;
        end
    end

endmodule
