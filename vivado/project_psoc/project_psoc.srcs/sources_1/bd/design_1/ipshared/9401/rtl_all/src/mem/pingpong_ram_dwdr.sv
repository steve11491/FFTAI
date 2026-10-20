module pingpong_ram_dwdr #(
    parameter CHANNEL_NUM = 16,
    parameter WIDTH = 40,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input wire clk,
    input wire rstn,

    input wire [1:0] ram_sel[4:0],
    input wire [2:0] ram_ren_sel,

    input wire [CHANNEL_NUM-1:0] pe_wr_en,
    input wire [CHANNEL_NUM-1:0] pe_rd_en,
    input wire [ADDR_WIDTH-1:0] pe_wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] pe_wr_data[CHANNEL_NUM-1:0],
    input wire [ADDR_WIDTH-1:0] pe_rd_addr[CHANNEL_NUM-1:0],
    output wire [WIDTH-1:0] pe_rd_data[CHANNEL_NUM-1:0],
    output wire [CHANNEL_NUM-1:0] pe_rd_valid,

    input wire [CHANNEL_NUM-1:0] bus_wr_en,
    input wire [CHANNEL_NUM-1:0] bus_rd_en,
    input wire [ADDR_WIDTH-1:0] bus_wr_addr[CHANNEL_NUM-1:0],
    input wire [WIDTH-1:0] bus_wr_data[CHANNEL_NUM-1:0],
    input wire [ADDR_WIDTH-1:0] bus_rd_addr[CHANNEL_NUM-1:0],
    output wire [WIDTH-1:0] bus_rd_data[CHANNEL_NUM-1:0],
    output wire [CHANNEL_NUM-1:0] bus_rd_valid

);


    wire [CHANNEL_NUM-1:0] wr_en[2:0];
    wire [CHANNEL_NUM-1:0] rd_en[2:0];
    wire [ADDR_WIDTH-1:0] wr_addr[2:0][CHANNEL_NUM-1:0];
    wire [WIDTH-1:0] wr_data[2:0][CHANNEL_NUM-1:0];
    wire [ADDR_WIDTH-1:0] rd_addr[2:0][CHANNEL_NUM-1:0];
    wire [WIDTH-1:0] rd_data[2:0][CHANNEL_NUM-1:0];
    wire [CHANNEL_NUM-1:0] rd_valid[2:0];


    reg [1:0] ram_sel_ff[1:0];
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ram_sel_ff <= {0, 0};
        end else begin
            ram_sel_ff[0] <= ram_sel[1];
            ram_sel_ff[1] <= ram_sel[3];
        end
    end

    generate
        for (genvar i = 0; i < 2; i = i + 1) begin
            for (genvar j = 0; j < CHANNEL_NUM; j = j + 1) begin
                assign {wr_en[0][j],wr_addr[0][j],wr_data[0][j]} = ram_sel[0][1]?(ram_sel[0][0]? 
                                                                    {bus_wr_en[j],bus_wr_addr[j],bus_wr_data[j]}
                                                                    : {pe_wr_en[j],pe_wr_addr[j],pe_wr_data[j]}):0;
                assign {wr_en[1][j],wr_addr[1][j],wr_data[1][j]} = ram_sel[2][1]?(ram_sel[2][0]? 
                                                                    {bus_wr_en[j],bus_wr_addr[j],bus_wr_data[j]}
                                                                    : {pe_wr_en[j],pe_wr_addr[j],pe_wr_data[j]}):0;

                assign {wr_en[2][j],wr_addr[2][j],wr_data[2][j]} = ram_sel[4][1]?(ram_sel[4][0]? 
                                                                    {bus_wr_en[j],bus_wr_addr[j],bus_wr_data[j]}
                                                                    : {pe_wr_en[j],pe_wr_addr[j],pe_wr_data[j]}):0;

                assign {rd_en[0][j],rd_addr[0][j]} = (ram_ren_sel[0]? 
                                                    {bus_rd_en[j],bus_rd_addr[j]}
                                                    : {pe_rd_en[j],pe_rd_addr[j]});
                assign {rd_en[1][j],rd_addr[1][j]} = (ram_ren_sel[1]? 
                                                    {bus_rd_en[j],bus_rd_addr[j]}
                                                    : {pe_rd_en[j],pe_rd_addr[j]});
                assign {rd_en[2][j],rd_addr[2][j]} = (ram_ren_sel[2]? 
                                                    {bus_rd_en[j],bus_rd_addr[j]}
                                                    : {pe_rd_en[j],pe_rd_addr[j]});
            end

        end
    endgenerate


    wire [1:0] pe_mux_sel;
    wire [1 + WIDTH-1:0] pe_mux_in[CHANNEL_NUM-1:0][3:0];
    wire [1 + WIDTH-1:0] pe_mux_out[CHANNEL_NUM-1:0];
    wire [1:0] bus_mux_sel;
    wire [1 + WIDTH-1:0] bus_mux_in[CHANNEL_NUM-1:0][3:0];
    wire [1 + WIDTH-1:0] bus_mux_out[CHANNEL_NUM-1:0];

    assign pe_mux_sel  = ram_sel_ff[0];
    assign bus_mux_sel = ram_sel_ff[1];
    generate

        for (genvar j = 0; j < CHANNEL_NUM; j = j + 1) begin


            assign pe_mux_in[j][0] = {rd_valid[0][j], rd_data[0][j]};
            assign pe_mux_in[j][1] = {rd_valid[1][j], rd_data[1][j]};
            assign pe_mux_in[j][2] = {rd_valid[2][j], rd_data[2][j]};
            assign pe_mux_in[j][3] = {WIDTH + 1{1'b0}};

            mux #(
                .WIDTH (1 + WIDTH),
                .NUMBER(4)
            ) pe_output_mux (
                .sel(pe_mux_sel),
                .mux_in(pe_mux_in[j]),
                .out(pe_mux_out[j])
            );

            assign {pe_rd_valid[j], pe_rd_data[j]} = pe_mux_out[j];


            assign bus_mux_in[j][0] = {rd_valid[0][j], rd_data[0][j]};
            assign bus_mux_in[j][1] = {rd_valid[1][j], rd_data[1][j]};
            assign bus_mux_in[j][2] = {rd_valid[2][j], rd_data[2][j]};
            assign bus_mux_in[j][3] = {WIDTH + 1{1'b0}};

            mux #(
                .WIDTH (1 + WIDTH),
                .NUMBER(4)
            ) bus_output_mux (
                .sel(bus_mux_sel),
                .mux_in(bus_mux_in[j]),
                .out(bus_mux_out[j])
            );

            assign {bus_rd_valid[j], bus_rd_data[j]} = bus_mux_out[j];

        end


    endgenerate

    generate
        for (genvar i = 0; i < 3; i = i + 1) begin
            multi_channel_ram_array #(
                .CHANNEL_NUM(CHANNEL_NUM),
                .WIDTH      (WIDTH),
                .DEPTH      (DEPTH),
                .ADDR_WIDTH (ADDR_WIDTH)
            ) u_multi_channel_ram_array (
                .clk    (clk),
                .rstn   (rstn),
                .wr_en  (wr_en[i]),
                .rd_en  (rd_en[i]),
                .wr_addr(wr_addr[i]),
                .wr_data(wr_data[i]),
                .rd_addr(rd_addr[i]),

                .rd_data (rd_data[i]),
                .rd_valid(rd_valid[i])
            );

        end
    endgenerate

endmodule
