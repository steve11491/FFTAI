module pingpong_ram_swsr #(
    parameter CHANNEL_NUM = 16,
    parameter WIDTH = 40,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input wire clk,
    input wire rstn,

    input wire pingpong,


    input wire [CHANNEL_NUM-1:0] rd_en,
    input wire [ADDR_WIDTH-1:0] rd_addr[CHANNEL_NUM-1:0],
    output wire [WIDTH-1:0] rd_data[CHANNEL_NUM-1:0],
    output wire [CHANNEL_NUM-1:0] rd_valid,

    input wire [CHANNEL_NUM-1:0] wr_en,
    input wire [ADDR_WIDTH-1:0] wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] wr_data[CHANNEL_NUM-1:0]

);

    // 单读单写pingpong_ram

    wire [CHANNEL_NUM-1:0] ram_wr_en[1:0];
    wire [CHANNEL_NUM-1:0] ram_rd_en[1:0];
    wire [ADDR_WIDTH-1:0] ram_wr_addr[1:0][CHANNEL_NUM-1:0];
    wire [WIDTH-1:0] ram_wr_data[1:0][CHANNEL_NUM-1:0];
    wire [ADDR_WIDTH-1:0] ram_rd_addr[1:0][CHANNEL_NUM-1:0];
    wire [WIDTH-1:0] ram_rd_data[1:0][CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] ram_rd_valid[1:0];

    wire [0:0] wdemux_sel;
    wire [1 + ADDR_WIDTH  + WIDTH-1:0] wdemux_in[CHANNEL_NUM-1:0];
    wire [1 + ADDR_WIDTH  + WIDTH-1:0] wdemux_out[CHANNEL_NUM-1:0][1:0];
    assign wdemux_sel[0] = pingpong;

    wire [0:0] rdemux_sel;
    wire [1 + ADDR_WIDTH -1:0] rdemux_in[CHANNEL_NUM-1:0];
    wire [1 + ADDR_WIDTH -1:0] rdemux_out[CHANNEL_NUM-1:0][1:0];
    assign rdemux_sel[0] = ~pingpong;

    reg [0:0] mux_sel;
    wire [1 + WIDTH-1:0] mux_in[CHANNEL_NUM-1:0][1:0];
    wire [1 + WIDTH-1:0] mux_out[CHANNEL_NUM-1:0];


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mux_sel[0] <= 0;
        end else begin
            mux_sel[0] <= ~pingpong;  //读有一拍延迟，这个选择信号打一拍
        end
    end

    generate

        for (genvar j = 0; j < CHANNEL_NUM; j = j + 1) begin : demux_mux_gen
            assign wdemux_in[j] = {wr_en[j], wr_addr[j], wr_data[j]};
            assign rdemux_in[j] = {rd_en[j], rd_addr[j]};


            demux_set #(
                .WIDTH(1 + ADDR_WIDTH + WIDTH),
                .NUMBER(2),
                .SET(1'b0),
                .SELECT_W(1)
            ) input_wdemux (
                .sel(wdemux_sel),
                .mux_in(wdemux_in[j]),
                .out(wdemux_out[j])
            );

            assign {ram_wr_en[0][j], ram_wr_addr[0][j], ram_wr_data[0][j]} = wdemux_out[j][0];
            assign {ram_wr_en[1][j], ram_wr_addr[1][j], ram_wr_data[1][j]} = wdemux_out[j][1];

            demux_set #(
                .WIDTH(1 + ADDR_WIDTH),
                .NUMBER(2),
                .SET(1'b0),
                .SELECT_W(1)
            ) input_rdemux (
                .sel(rdemux_sel),
                .mux_in(rdemux_in[j]),
                .out(rdemux_out[j])
            );

            assign {ram_rd_en[0][j], ram_rd_addr[0][j]} = rdemux_out[j][0];
            assign {ram_rd_en[1][j], ram_rd_addr[1][j]} = rdemux_out[j][1];


            assign mux_in[j][0] = {ram_rd_valid[0][j], ram_rd_data[0][j]};
            assign mux_in[j][1] = {ram_rd_valid[1][j], ram_rd_data[1][j]};

            mux #(
                .WIDTH(1 + WIDTH),
                .NUMBER(2),
                .SELECT_W(1)
            ) output_mux (
                .sel(mux_sel),
                .mux_in(mux_in[j]),
                .out(mux_out[j])
            );

            assign {rd_valid[j], rd_data[j]} = mux_out[j];


        end

    endgenerate

    generate
        for (genvar i = 0; i < 2; i = i + 1) begin : pingpong_ram_array_gen
            multi_channel_ram_array #(
                .CHANNEL_NUM(CHANNEL_NUM),
                .WIDTH      (WIDTH),
                .DEPTH      (DEPTH),
                .ADDR_WIDTH (ADDR_WIDTH)
            ) u_multi_channel_ram_array (
                .clk    (clk),
                .rstn   (rstn),
                .wr_en  (ram_wr_en[i]),
                .rd_en  (ram_rd_en[i]),
                .wr_addr(ram_wr_addr[i]),
                .wr_data(ram_wr_data[i]),
                .rd_addr(ram_rd_addr[i]),

                .rd_data (ram_rd_data[i]),
                .rd_valid(ram_rd_valid[i])
            );

        end
    endgenerate

endmodule
