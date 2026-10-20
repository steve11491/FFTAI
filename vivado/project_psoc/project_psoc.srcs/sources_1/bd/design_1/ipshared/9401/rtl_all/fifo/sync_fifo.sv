


//计数器法 同步FIFO    
module sync_fifo_cnt #(
    parameter WIDTH = 32,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input wire             clk,
    input wire             rstn,
    input wire             wr_en,
    input wire             rd_en,
    input wire [WIDTH-1:0] wr_data,

    output logic [WIDTH-1:0] rd_data,
    output logic rd_valid,
    output logic full,
    output logic empty,
    output logic almost_full,
    output logic almost_empty,
    output logic [ADDR_WIDTH:0] fifo_counter
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

    wire wr_en_true;
    wire rd_en_true;
    assign wr_en_true = wr_en && (!full);
    assign rd_en_true = rd_en && (!empty);
    com_simple_dual_port_ram_two_clock_rst #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH),
        .RAM_STYLE_VAL(RAM_STYLE_VAL)
    ) sdp_ram (
        .clka(clk),
        .clkb(clk),
        .rstnb(rstn),
        .wea(wr_en_true),
        .ena(wr_en_true),
        .enb(rd_en_true),
        .addra(wr_addr),
        .dina(wr_data),
        .addrb(rd_addr),
        .doutb(rd_data),
        .validb(rd_valid)
    );


    //generate  rd_addr, 产生读地址
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            rd_addr <= 'h0;
        end else if (rd_en_true) begin
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
        end else if (wr_en_true) begin
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
        end else if (!full && wr_en_true && !rd_en_true) begin
            counter <= counter + 1'b1;
        end else if (!empty && !wr_en_true && rd_en_true) begin
            counter <= counter - 1'b1;
        end else begin
            counter <= counter;
        end
    end

endmodule

// 高位扩展法 同步FIFO
module sync_fifo_ptr #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,  //高位扩展法DEPTH需要为2^N
    parameter ADDR_WIDTH = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clk,
    input rstn,
    input wr_en,
    input rd_en,
    input [WIDTH-1:0] wr_data,
    output [WIDTH-1:0] rd_data,
    output rd_valid,
    output full,
    output empty
);

    initial begin
        ap_L :
        assert (DEPTH == (2 ** ($clog2(DEPTH))))
        else $error("DEPTH has to be a power of 2");  // DEPTH必须是2的乘方
    end

    wire wr_en_true;
    wire rd_en_true;
    assign wr_en_true = wr_en && (!full);
    assign rd_en_true = rd_en && (!empty);
    wire [ADDR_WIDTH-1:0] rd_addr, wr_addr;

    reg [ADDR_WIDTH:0] rd_addr_1;  //扩展一位地址用于判断空满
    reg [ADDR_WIDTH:0] wr_addr_1;  //扩展一位地址用于判断空满

    assign wr_addr = wr_addr_1[ADDR_WIDTH-1:0];
    assign rd_addr = rd_addr_1[ADDR_WIDTH-1:0];

    com_simple_dual_port_ram_two_clock_rst #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH),
        .RAM_STYLE_VAL(RAM_STYLE_VAL)
    ) sdp_ram (
        .clka(clk),
        .clkb(clk),
        .rstnb(rstn),
        .wea(wr_en_true),
        .ena(wr_en_true),
        .enb(rd_en_true),
        .addra(wr_addr),
        .dina(wr_data),
        .addrb(rd_addr),
        .doutb(rd_data),
        .validb(rd_valid)
    );
    //读数据
    always @(posedge clk or negedge rstn) begin
        if (~rstn) rd_addr_1 <= 'h0;
        else if (rd_en_true) begin
            rd_addr_1 <= rd_addr_1 + 1'b1;
        end
    end

    //写数据
    always @(posedge clk or negedge rstn) begin
        if (~rstn) wr_addr_1 <= 'h0;
        else if (wr_en_true) begin
            wr_addr_1 <= wr_addr_1 + 1'b1;
        end
    end

    assign empty = (wr_addr_1 == rd_addr_1) ? 1 : 0;  //地址判断
    assign  full = ((wr_addr_1[ADDR_WIDTH]!=rd_addr_1[ADDR_WIDTH]) && (wr_addr_1[ADDR_WIDTH-1:0]==rd_addr_1[ADDR_WIDTH-1:0]))?1:0;

endmodule


