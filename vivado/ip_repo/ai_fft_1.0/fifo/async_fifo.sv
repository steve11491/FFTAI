
module async_fifo #(
    parameter WIDTH = 16,  // FIFO数据总线位宽
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)  // FIFO存储深度(bit数，深度只能是2^n个)
) (
    // write interface
    input                  wrclk,     // 写时钟
    input                  wr_rst_n,  // 写指针复位
    input      [WIDTH-1:0] wr_data,   // 写数据总线
    input                  wr_en,     // 写使能
    output reg             wr_full,   // 写满标志

    //read interface
    input                  rdclk,     // 读时钟
    input                  rd_rst_n,  // 读指针复位
    input                  rd_en,     // 读使能
    output     [WIDTH-1:0] rd_data,   // 读数据输出
    output reg             rd_empty,  // 读空标志
    output                 rd_valid
);


    // 写时钟域信号定义
    reg     [  ADDR_WIDTH:0] wr_bin;  // 二进制写地址
    reg     [  ADDR_WIDTH:0] wr_gray;  // 格雷码写地址
    reg     [  ADDR_WIDTH:0] rd_gray_ff1;  // 格雷码读地址同步寄存器1
    reg     [  ADDR_WIDTH:0] rd_gray_ff2;  // 格雷码读地址同步寄存器2
    reg     [  ADDR_WIDTH:0] rd_bin_wr;  // 同步到写时钟域的二进制读地址


    // 读时钟域信号定义
    reg     [  ADDR_WIDTH:0] rd_bin;  // 二进制读地址
    reg     [  ADDR_WIDTH:0] rd_gray;  // 格雷码读地址
    reg     [  ADDR_WIDTH:0] wr_gray_ff1;  // 格雷码写地址同步寄存器1
    reg     [  ADDR_WIDTH:0] wr_gray_ff2;  // 格雷码写地址同步寄存器2
    reg     [  ADDR_WIDTH:0] wr_bin_rd;  // 同步到读时钟域的二进制写地址


    // 解格雷码电路循环变量
    integer                  i;
    integer                  j;


    // ram控制信号
    wire                     ram_wr_en;  // RAM写使能
    wire    [ADDR_WIDTH-1:0] ram_wr_addr;  // RAM写地址
    wire    [     WIDTH-1:0] ram_wr_data;  // RAM写数据
    wire                     ram_rd_en;  // RAM读使能
    wire    [ADDR_WIDTH-1:0] ram_rd_addr;  // RAM读地址
    wire    [     WIDTH-1:0] ram_rd_data;  // RAM读数据



    // ******************************** 写时钟域 ******************************** //
    // 二进制写地址递增
    always @(posedge wrclk or posedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_bin <= 'b0;
        end else if (wr_en == 1'b1 && wr_full == 1'b0) begin
            wr_bin <= wr_bin + 1'b1;
        end else begin
            wr_bin <= wr_bin;
        end
    end


    // 写地址：二进制转格雷码
    always @(posedge wrclk or posedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_gray <= 'b0;
        end else begin
            wr_gray <= {wr_bin[ADDR_WIDTH], wr_bin[ADDR_WIDTH:1] ^ wr_bin[ADDR_WIDTH-1:0]};
        end
    end


    // 格雷码读地址同步至写时钟域
    always @(posedge wrclk or posedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_gray_ff1 <= 'b0;
            rd_gray_ff2 <= 'b0;
        end else begin
            rd_gray_ff1 <= rd_gray;
            rd_gray_ff2 <= rd_gray_ff1;
        end
    end


    // 同步后的读地址解格雷
    always @(*) begin
        rd_bin_wr[ADDR_WIDTH] = rd_gray_ff2[ADDR_WIDTH];
        for (i = ADDR_WIDTH - 1; i >= 0; i = i - 1) rd_bin_wr[i] = rd_bin_wr[i+1] ^ rd_gray_ff2[i];
    end


    // 写时钟域产生写满标志
    always @(*) begin
        if ((wr_bin[ADDR_WIDTH] != rd_bin_wr[ADDR_WIDTH]) && (wr_bin[ADDR_WIDTH-1:0] == rd_bin_wr[ADDR_WIDTH-1:0])) begin
            wr_full = 1'b1;
        end else begin
            wr_full = 1'b0;
        end
    end


    // ******************************** 读时钟域 ******************************** //
    always @(posedge rdclk or posedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_bin <= 'b0;
        end else if (rd_en == 1'b1 && rd_empty == 1'b0) begin
            rd_bin <= rd_bin + 1'b1;
        end else begin
            rd_bin <= rd_bin;
        end
    end


    // 读地址：二进制转格雷码
    always @(posedge rdclk or posedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_gray <= 'b0;
        end else begin
            rd_gray <= {rd_bin[ADDR_WIDTH], rd_bin[ADDR_WIDTH:1] ^ rd_bin[ADDR_WIDTH-1:0]};
        end
    end


    // 格雷码写地址同步至读时钟域
    always @(posedge rdclk or posedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_gray_ff1 <= 'b0;
            wr_gray_ff2 <= 'b0;
        end else begin
            wr_gray_ff1 <= wr_gray;
            wr_gray_ff2 <= wr_gray_ff1;
        end
    end


    // 同步后的写地址解格雷
    always @(*) begin
        wr_bin_rd[ADDR_WIDTH] = wr_gray_ff2[ADDR_WIDTH];
        for (j = ADDR_WIDTH - 1; j >= 0; j = j - 1) wr_bin_rd[j] = wr_bin_rd[j+1] ^ wr_gray_ff2[j];
    end


    // 读时钟域产生读空标志
    always @(*) begin
        if (wr_bin_rd == rd_bin) rd_empty = 1'b1;
        else rd_empty = 1'b0;
    end

    // 伪双口RAM例化
    com_simple_dual_port_ram_two_clock_rst #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) sdp_ram (
        .clka(wrclk),
        .clkb(rdclk),
        .rstnb(rd_rst_n),
        .wea(ram_wr_en),
        .ena(ram_wr_en),
        .enb(ram_rd_en),
        .dina(ram_wr_data),
        .doutb(ram_rd_data),
        .addra(ram_wr_addr),
        .addrb(ram_rd_addr),
        .validb(rd_valid)
    );



    // 产生RAM读写控制信号
    assign ram_wr_en = (wr_en == 1'b1 && wr_full == 1'b0) ? 1'b1 : 1'b0;
    assign ram_wr_data = wr_data;
    assign ram_wr_addr = wr_bin[ADDR_WIDTH-1:0];

    assign ram_rd_en = (rd_en == 1'b1 && rd_empty == 1'b0) ? 1'b1 : 1'b0;
    assign rd_data = ram_rd_data;
    assign ram_rd_addr = rd_bin[ADDR_WIDTH-1:0];


endmodule
