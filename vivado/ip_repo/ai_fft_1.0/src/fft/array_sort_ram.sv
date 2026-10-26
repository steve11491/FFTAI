module array_sort_ram #(
    parameter MAX_POINT = 4096,
    parameter MDC_PARALLEL = 8,
    parameter MDC_STAGE = 4,
    parameter DATA_WIDTH = 32,  //FFT data width
    parameter RAMIO_WIDTH = $clog2(MAX_POINT / MDC_PARALLEL)

) (
    input clk,
    input rstn,
    input pe_o_vaild,
    input [RAMIO_WIDTH-1:0] array_sort_cnt,
    input array_sort_vaild,

    input [DATA_WIDTH-1:0] mdc_o_data[MDC_PARALLEL-1:0],


    output [DATA_WIDTH-1:0] array_sort_o[MDC_PARALLEL-1:0]


);

    localparam PEBUFF_DEPTH = 16 * 2;
    localparam PEBUFF_PARALLEL = MDC_PARALLEL / 2;
    localparam PEBUFF_CNT = $clog2(PEBUFF_DEPTH);
    localparam PEBUFF_LOOP = $clog2(MDC_PARALLEL / 2);  //Buff loop length: 2/3/4
    localparam PEBUFF_LCNT = $clog2(PEBUFF_DEPTH * 2 / MDC_PARALLEL);  //loop cnt width: 2/1/0
    localparam PEBUFF_ADDR_WIDTH = $clog2(PEBUFF_DEPTH);

    wire [PEBUFF_ADDR_WIDTH-1:0] ram_i_addr;
    wire [PEBUFF_ADDR_WIDTH-1:0] ram_o_addr[PEBUFF_PARALLEL-1:0];
    wire [DATA_WIDTH*2-1:0] ram_o_data[PEBUFF_PARALLEL-1:0];
    wire [1:0] array_sort_cnt_1_0[PEBUFF_PARALLEL-1:0];
    reg [1:0] array_sort_cnt_1_0_delay[PEBUFF_PARALLEL-1:0];

    generate
        for (genvar i = 0; i < PEBUFF_PARALLEL; i = i + 1) begin
            assign array_sort_cnt_1_0[i] = i - array_sort_cnt[1:0];
        end
    endgenerate

    always @(posedge clk) begin
        for (integer a = 0; a < PEBUFF_PARALLEL; a = a + 1) begin
            array_sort_cnt_1_0_delay[a] <= a + array_sort_cnt[1:0];
        end
    end


    assign ram_i_addr = array_sort_vaild ? {!array_sort_cnt[PEBUFF_CNT-1],array_sort_cnt[PEBUFF_CNT-2:0]} : array_sort_cnt[PEBUFF_CNT-1:0];
    generate
        for (genvar i = 0; i < PEBUFF_PARALLEL; i = i + 1) begin
            assign ram_o_addr[i] = {
                array_sort_cnt[PEBUFF_CNT-1], array_sort_cnt_1_0[i], array_sort_cnt[PEBUFF_CNT-2:2]
            };
        end
    endgenerate


    //ram
    generate
        for (genvar p = 0; p < PEBUFF_PARALLEL; p = p + 1) begin
            com_simple_dual_port_ram_two_clock #(
                .WIDTH(DATA_WIDTH * 2),
                .DEPTH(PEBUFF_DEPTH)
            ) ram_sort_0 (
                .clka(clk),
                .clkb(clk),
                .rstnb(rstn),
                .wea(1'b1),
                .ena(pe_o_vaild),
                .enb(array_sort_vaild),
                .addra(ram_i_addr),
                .dina({mdc_o_data[2*p], mdc_o_data[2*p+1]}),
                .addrb(ram_o_addr[p]),
                .doutb(ram_o_data[p]),
                .validb()
            );
        end
    endgenerate

    //out
    generate
        for (genvar i = 0; i < PEBUFF_PARALLEL; i = i + 1) begin
            assign array_sort_o[2*i] = ram_o_data[array_sort_cnt_1_0_delay[i]][DATA_WIDTH*2-1:DATA_WIDTH];
            assign array_sort_o[2*i+1] = ram_o_data[array_sort_cnt_1_0_delay[i]][DATA_WIDTH-1:0];
        end
    endgenerate


endmodule
