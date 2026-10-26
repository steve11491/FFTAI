module ram_omap #(
    parameter CHANNEL_NUM = 16,
    parameter WIDTH = 40,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input wire clk,
    input wire rstn,

    input wire [1:0] ram_omap_sel[4:0],
    input wire [2:0] ram_omap_ren_sel,

    input wire [CHANNEL_NUM-1:0] pe_wr_en,
    input wire [CHANNEL_NUM-1:0] pe_rd_en,
    input wire [ADDR_WIDTH-1:0] pe_wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] pe_wr_data[CHANNEL_NUM-1:0],
    input wire [ADDR_WIDTH-1:0] pe_rd_addr[CHANNEL_NUM-1:0],
    output reg [WIDTH-1:0] pe_rd_data[CHANNEL_NUM-1:0],
    output reg [CHANNEL_NUM-1:0] pe_rd_valid,

    input wire [CHANNEL_NUM-1:0] bus_wr_en,
    input wire [CHANNEL_NUM-1:0] bus_rd_en,
    input wire [ADDR_WIDTH-1:0] bus_wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] bus_wr_data[CHANNEL_NUM-1:0],
    input wire [ADDR_WIDTH-1:0] bus_rd_addr[CHANNEL_NUM-1:0],
    output reg [WIDTH-1:0] bus_rd_data[CHANNEL_NUM-1:0],
    output reg [CHANNEL_NUM-1:0] bus_rd_valid

);

    wire [WIDTH-1:0] pe_rd_data_w[CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] pe_rd_valid_w;
    wire [WIDTH-1:0] bus_rd_data_w[CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] bus_rd_valid_w;
    pingpong_ram_dwdr #(
        .CHANNEL_NUM(CHANNEL_NUM),
        .WIDTH      (WIDTH),
        .DEPTH      (DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_pingpong_ram_dwdr (
        .clk        (clk),
        .rstn       (rstn),
        .ram_sel    (ram_omap_sel),
        .ram_ren_sel(ram_omap_ren_sel),
        .pe_wr_en   (pe_wr_en),
        .pe_rd_en   (pe_rd_en),
        .pe_wr_addr (pe_wr_addr),
        .pe_wr_data (pe_wr_data),
        .pe_rd_addr (pe_rd_addr),
        .bus_wr_en  (bus_wr_en),
        .bus_rd_en  (bus_rd_en),
        .bus_wr_addr(bus_wr_addr),
        .bus_wr_data(bus_wr_data),
        .bus_rd_addr(bus_rd_addr),

        .pe_rd_data  (pe_rd_data_w),
        .pe_rd_valid (pe_rd_valid_w),
        .bus_rd_data (bus_rd_data_w),
        .bus_rd_valid(bus_rd_valid_w)
    );

    // assign pe_rd_data   = pe_rd_data_w;
    // assign bus_rd_data  = bus_rd_data_w;
    // assign pe_rd_valid  = pe_rd_valid_w;
    // assign bus_rd_valid = bus_rd_valid_w;

    always @(posedge clk) begin
        pe_rd_data  <= pe_rd_data_w;
        bus_rd_data <= bus_rd_data_w;
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            pe_rd_valid  <= 0;
            bus_rd_valid <= 0;
        end else begin
            pe_rd_valid  <= pe_rd_valid_w;
            bus_rd_valid <= bus_rd_valid_w;
        end
    end

endmodule
