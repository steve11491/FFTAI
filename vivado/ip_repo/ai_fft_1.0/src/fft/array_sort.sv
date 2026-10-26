module array_sort #(
    parameter MAX_POINT = 4096,
    parameter MDC_PARALLEL = 8,
    parameter MDC_STAGE = 4,
    parameter DATA_WIDTH = 32,  //FFT data width
    parameter PEBUFF_DEPTH = 16,
    parameter RAMIO_WIDTH = $clog2(MAX_POINT / MDC_PARALLEL),
    parameter PEBUFF_CNT = $clog2(PEBUFF_DEPTH),
    parameter PEBUFF_LOOP = $clog2(MDC_PARALLEL / 2),  //Buff loop length: 2/3/4
    parameter PEBUFF_LCNT = $clog2(PEBUFF_DEPTH * 2 / MDC_PARALLEL)  //loop cnt width: 2/1/0
) (
    input clk,
    input rstn,
    input pe_o_vaild,
    input [RAMIO_WIDTH-1:0] array_sort_cnt,
    input array_sort_vaild,

    input [DATA_WIDTH-1:0] mdc_o_data[MDC_PARALLEL-1:0],


    output [DATA_WIDTH-1:0] array_sort_o[MDC_PARALLEL-1:0]


);

    reg [DATA_WIDTH-1:0] pe2ram_buff_0[MDC_PARALLEL-1:0][PEBUFF_DEPTH-1:0];
    reg [DATA_WIDTH-1:0] pe2ram_buff_1[MDC_PARALLEL-1:0][PEBUFF_DEPTH-1:0];

    integer row, col;
    generate
        if (PEBUFF_LCNT == 0) begin : BUFF0P32  //p=32
            always @(posedge clk) begin
                if (!rstn) begin
                    for (row = 0; row < MDC_PARALLEL; row = row + 1) begin
                        for (col = 0; col < PEBUFF_DEPTH; col = col + 1) begin
                            pe2ram_buff_0[row][col] <= {DATA_WIDTH{1'b0}};
                        end
                    end
                end  //PE -> RAM IN
                else if (pe_o_vaild & (array_sort_cnt[PEBUFF_CNT] | (~array_sort_vaild))) begin
                    for (row = 0; row < MDC_PARALLEL / 2; row = row + 1) begin
                        pe2ram_buff_0[(array_sort_cnt[PEBUFF_CNT-1:0]<<1)+0][row]<=mdc_o_data[row*2];
                        pe2ram_buff_0[(array_sort_cnt[PEBUFF_CNT-1:0]<<1)+1][row]<=mdc_o_data[row*2+1];
                    end
                end
            end
        end else begin : BUFF0P8
            always @(posedge clk) begin  //p=8
                if (!rstn) begin
                    for (row = 0; row < MDC_PARALLEL; row = row + 1) begin
                        for (col = 0; col < PEBUFF_DEPTH; col = col + 1) begin
                            pe2ram_buff_0[row][col] <= {DATA_WIDTH{1'b0}};
                        end
                    end
                end else if (pe_o_vaild & (array_sort_cnt[PEBUFF_CNT] | (~array_sort_vaild))) begin
                    for (row = 0; row < MDC_PARALLEL / 2; row = row + 1) begin
                        pe2ram_buff_0[(array_sort_cnt[PEBUFF_CNT-1:PEBUFF_LCNT]<<1)+0][row+(array_sort_cnt[PEBUFF_LCNT-1:0]<<PEBUFF_LOOP)]<=mdc_o_data[row*2];
                        pe2ram_buff_0[(array_sort_cnt[PEBUFF_CNT-1:PEBUFF_LCNT]<<1)+1][row+(array_sort_cnt[PEBUFF_LCNT-1:0]<<PEBUFF_LOOP)]<=mdc_o_data[row*2+1];
                    end
                end
            end
        end
    endgenerate

    generate
        if (PEBUFF_LCNT == 0) begin : BUFF1P32  //p=32
            always @(posedge clk) begin
                if (!rstn) begin
                    for (row = 0; row < MDC_PARALLEL; row = row + 1) begin
                        for (col = 0; col < PEBUFF_DEPTH; col = col + 1) begin
                            pe2ram_buff_1[row][col] <= {DATA_WIDTH{1'b0}};
                        end
                    end
                end  //PE -> RAM IN
                else if (pe_o_vaild & (~array_sort_cnt[PEBUFF_CNT]) & array_sort_vaild) begin
                    for (row = 0; row < MDC_PARALLEL / 2; row = row + 1) begin
                        pe2ram_buff_1[(array_sort_cnt[PEBUFF_CNT-1:0]<<1)+0][row]<=mdc_o_data[row*2];
                        pe2ram_buff_1[(array_sort_cnt[PEBUFF_CNT-1:0]<<1)+1][row]<=mdc_o_data[row*2+1];
                    end
                end
            end
        end else begin : BUFF1P8
            always @(posedge clk) begin  //p=8
                if (!rstn) begin
                    for (row = 0; row < MDC_PARALLEL; row = row + 1) begin
                        for (col = 0; col < PEBUFF_DEPTH; col = col + 1) begin
                            pe2ram_buff_1[row][col] <= {DATA_WIDTH{1'b0}};
                        end
                    end
                end else if (pe_o_vaild & (~array_sort_cnt[PEBUFF_CNT]) & array_sort_vaild) begin
                    for (row = 0; row < MDC_PARALLEL / 2; row = row + 1) begin
                        pe2ram_buff_1[(array_sort_cnt[PEBUFF_CNT-1:PEBUFF_LCNT]<<1)+0][row+(array_sort_cnt[PEBUFF_LCNT-1:0]<<PEBUFF_LOOP)]<=mdc_o_data[row*2];
                        pe2ram_buff_1[(array_sort_cnt[PEBUFF_CNT-1:PEBUFF_LCNT]<<1)+1][row+(array_sort_cnt[PEBUFF_LCNT-1:0]<<PEBUFF_LOOP)]<=mdc_o_data[row*2+1];
                    end
                end
            end
        end
    endgenerate

    //out
    integer p;
    reg [DATA_WIDTH-1:0] array_sort_o_reg[MDC_PARALLEL-1:0];
    always @(posedge clk) begin
        if (pe_o_vaild | array_sort_vaild) begin
            if (~array_sort_cnt[PEBUFF_CNT]) begin
                for (p = 0; p < MDC_PARALLEL; p = p + 1) begin
                    array_sort_o_reg[p] <= pe2ram_buff_0[p][array_sort_cnt[PEBUFF_CNT-1:0]];
                end
            end else begin
                for (p = 0; p < MDC_PARALLEL; p = p + 1) begin
                    array_sort_o_reg[p] <= pe2ram_buff_1[p][array_sort_cnt[PEBUFF_CNT-1:0]];
                end
            end
        end
    end

    genvar i;
    generate
        ;
        for (i = 0; i < MDC_PARALLEL; i = i + 1) begin
            assign array_sort_o[i] = array_sort_o_reg[i];
        end
    endgenerate


endmodule
