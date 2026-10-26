



module ram_imap #(
    parameter CHANNEL_NUM = 16,
    parameter WIDTH = 16,
    parameter DEPTH = 1024 * 2,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire is_imap_all_read,  //是否分成奇偶区别
    input wire ram_imap_pingpong,
    input wire imap_ric_even_odd_flag,  // 读奇偶标志
    input wire [CHANNEL_NUM-1:0] rd_en,
    input wire [ADDR_WIDTH-1:0] rd_addr[CHANNEL_NUM-1:0],
    output reg [WIDTH-1:0] rd_data[CHANNEL_NUM-1:0],
    output reg [CHANNEL_NUM-1:0] rd_valid,

    // input wire imap_wic_even_odd_flag,  // 写奇偶标志
    input wire [CHANNEL_NUM-1:0] wr_en,
    input wire [ADDR_WIDTH-1:0] wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] wr_data[CHANNEL_NUM-1:0]

);

    logic [WIDTH/2-1:0] rd_data_int8[  CHANNEL_NUM-1:0];
    logic [WIDTH/2-1:0] wr_data_int8[CHANNEL_NUM*2-1:0];

    generate
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign rd_data_int8[i] = rd_data[i][WIDTH/2-1:0];
        end
        for (genvar i = 0; i < CHANNEL_NUM; i = i + 1) begin
            assign {wr_data_int8[i*2+1], wr_data_int8[i*2]} = {
                wr_data[i][WIDTH-1:WIDTH/2], wr_data[i][WIDTH/2-1:0]
            };
        end
    endgenerate

    reg is_int16_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
        end else begin
            is_int16_reg <= is_int16;
        end
    end
    wire [WIDTH-1:0] imap_rd_data[CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] imap_read_valid;

    wire [CHANNEL_NUM-1:0] imap_ren;
    assign imap_ren = rd_en;
    wire [CHANNEL_NUM/2-1:0] imap_ren_pack;
    generate
        for (genvar i = 0; i < CHANNEL_NUM / 2; i = i + 1) begin
            assign imap_ren_pack[i] = |(imap_ren[(i+1)*2-1:i*2]);
        end
    endgenerate

    wire [CHANNEL_NUM-1:0] imap_ren_odd_even;  // 根据奇偶生成不同的imap_ren
    assign imap_ren_odd_even = (is_int16_reg || is_imap_all_read) ? imap_ren : ((imap_ric_even_odd_flag == 1'b0) ? (
        {{CHANNEL_NUM/2{1'b0}},imap_ren_pack[CHANNEL_NUM/2-1:0]}) :
        ({imap_ren_pack[CHANNEL_NUM/2-1:0],{CHANNEL_NUM/2{1'b0}}}));

    wire [ADDR_WIDTH-1:0] rd_addr_true[CHANNEL_NUM-1:0];
    wire [ADDR_WIDTH-1:0] wr_addr_true[CHANNEL_NUM-1:0];
    assign rd_addr_true = rd_addr;
    assign wr_addr_true = wr_addr;


    wire [CHANNEL_NUM-1:0] imap_wen;
    assign imap_wen = wr_en;

    wire [CHANNEL_NUM-1:0] imap_wen_odd_even;  // 根据奇偶生成不同的imap_wen
    assign imap_wen_odd_even = wr_en;


    wire [WIDTH-1:0] imap_wr_data[CHANNEL_NUM-1:0];
    assign imap_wr_data = wr_data;


    pingpong_ram_swsr #(
        .CHANNEL_NUM(CHANNEL_NUM),
        .WIDTH      (WIDTH),
        .DEPTH      (DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_pingpong_ram_swsr_imap (
        .clk     (clk),
        .rstn    (rstn),
        .pingpong(ram_imap_pingpong),
        .rd_en   (imap_ren_odd_even),
        .rd_addr (rd_addr_true),
        .wr_en   (imap_wen_odd_even),
        .wr_addr (wr_addr_true),
        .wr_data (imap_wr_data),

        .rd_data (imap_rd_data),
        .rd_valid()
    );



    reg [WIDTH-1:0] imap_rd_data_even[CHANNEL_NUM-1:0];
    reg [WIDTH-1:0] imap_rd_data_odd [CHANNEL_NUM-1:0];
    generate
        for (genvar i = 0; i < CHANNEL_NUM / 2; i = i + 1) begin
            assign {imap_rd_data_odd[i*2+1], imap_rd_data_odd[i*2]} = {
                {WIDTH / 2{imap_rd_data[i][WIDTH-1]}},
                imap_rd_data[i][WIDTH-1:WIDTH/2],
                {WIDTH / 2{imap_rd_data[i][WIDTH/2-1]}},
                imap_rd_data[i][WIDTH/2-1:0]
            };

            assign {imap_rd_data_even[i*2+1], imap_rd_data_even[i*2]} = {
                {WIDTH / 2{imap_rd_data[i+CHANNEL_NUM/2][WIDTH-1]}},
                imap_rd_data[i+CHANNEL_NUM/2][WIDTH-1:WIDTH/2],
                {WIDTH / 2{imap_rd_data[i+CHANNEL_NUM/2][WIDTH/2-1]}},
                imap_rd_data[i+CHANNEL_NUM/2][WIDTH/2-1:0]
            };

        end
    endgenerate

    localparam READ_ADDR_TO_DATA_OUT_DELAY = 1;
    wire imap_ric_even_odd_flag_ff;
    dq_dff #(
        .N (READ_ADDR_TO_DATA_OUT_DELAY),
        .DW(1)
    ) u_delay_imap_ric_even_odd_flag (
        .clk(clk),
        .rstn(rstn),
        .d(imap_ric_even_odd_flag),
        .q(imap_ric_even_odd_flag_ff)
    );
    dq_dff #(
        .N (READ_ADDR_TO_DATA_OUT_DELAY),
        .DW(CHANNEL_NUM)
    ) u_delay_imap_read_valid (
        .clk(clk),
        .rstn(rstn),
        .d(rd_en),
        .q(imap_read_valid)
    );
    // assign rd_data = is_int16 ? imap_rd_data : ((imap_ric_even_odd_flag_ff == 1'b0) ? imap_rd_data_odd : imap_rd_data_even);
    // assign rd_valid = imap_read_valid;
    always @(posedge clk) begin
        rd_data <= (is_int16_reg||is_imap_all_read) ? imap_rd_data : ((imap_ric_even_odd_flag_ff == 1'b0) ? imap_rd_data_odd : imap_rd_data_even);
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            rd_valid <= 0;
        end else begin
            rd_valid <= imap_read_valid;
        end
    end




endmodule
