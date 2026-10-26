module com_simple_dual_port_multi_ram #(
    parameter CHANNEL_NUM = 16,
    parameter WIDTH = 40,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input wire clk,
    input wire rstn,
    input wire [CHANNEL_NUM-1:0] wr_en,
    input wire [CHANNEL_NUM-1:0] rd_en,
    input wire [ADDR_WIDTH-1:0] wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] wr_data[CHANNEL_NUM-1:0],
    input wire [ADDR_WIDTH-1:0] rd_addr[CHANNEL_NUM-1:0],
    output reg [WIDTH-1:0] rd_data[CHANNEL_NUM-1:0],
    output reg [CHANNEL_NUM-1:0] rd_valid
);

    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[CHANNEL_NUM-1:0][0:DEPTH-1];


    integer t;
    initial begin
        for (integer c = 0; c < CHANNEL_NUM; c = c + 1) begin
            for (t = 0; t < DEPTH; t = t + 1) begin
                RAM[c][t] = 0;
            end
        end
    end
    generate

        for (genvar c = 0; c < CHANNEL_NUM; c = c + 1) begin
            always @(posedge clk) begin
                if (wr_en[c]) begin
                    RAM[c][wr_addr[c]] <= wr_data[c];
                end
            end

            always @(posedge clk) begin
                if (rd_en[c]) begin
                    rd_data[c] <= RAM[c][rd_addr[c]];
                end
            end

            always @(posedge clk or negedge rstn) begin
                if (~rstn) begin
                    rd_valid[c] <= 0;
                end else begin
                    rd_valid[c] <= rd_en[c];
                end
            end
        end

    endgenerate


endmodule
