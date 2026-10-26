


module fft_array #(
    parameter WIDTH              = 16,
    parameter BUS_WIDTH          = 64,
    parameter FFT_STAGE_WIDTH    = 4,                                           //reg
    parameter FFT_MAX_POINT      = 4096,
    parameter FFT_CORE_COL       = 8,
    parameter FFT_CORE_ROW       = 4,
    parameter ARRAY_PARALLEL     = FFT_CORE_COL / 2,
    parameter BUS_DATA_NUM       = BUS_WIDTH / WIDTH / 2,
    parameter FFT_RAM_IN_NUM     = 3,
    parameter FFT_RAM_OUT_NUM    = 2,
    parameter FFT_RAM_DEPTH      = FFT_MAX_POINT / 8,
    parameter FFT_ADDR_WIDTH     = $clog2(FFT_RAM_DEPTH),
    parameter FFT_ARRAY_PARALLEL = 4,
    parameter FFT_RAM_WIDTH      = WIDTH * 2,
    parameter FFTW_RAM_PARALLEL  = FFT_ARRAY_PARALLEL,
    parameter FFTW_RAM_POINT     = FFT_MAX_POINT / 2,
    parameter FFTW_ADDR_WIDTH    = $clog2(FFTW_RAM_POINT / FFTW_RAM_PARALLEL),
    parameter ALU_WIDTH          = 40,
    parameter ALU_PARALLEL       = 16
) (


    input clk,
    input rstn,

    //ctl
    // input fft_start,
    // input [FFT_STAGE_WIDTH-1:0] fft_stage,

    //data
    // input bus_i_vaild,
    // output bus_i_ready,
    input [WIDTH*2-1:0] bus_i_data[FFT_CORE_COL-1:0],
    // input bus_o_ready,
    output [WIDTH*2-1:0] bus_o_data[BUS_DATA_NUM-1:0],
    output bus_o_vaild,

    //FFT control
    input [        FFT_ADDR_WIDTH-1:0] ffti_wr_addr[FFT_RAM_IN_NUM-1:0][FFT_CORE_COL-1:0],
    input [        FFT_ADDR_WIDTH-1:0] ffti_rd_addr[  FFT_CORE_COL-1:0],
    input                              ffti_wr_ena [FFT_RAM_IN_NUM-1:0][FFT_CORE_COL-1:0],
    input                              ffti_rd_ena [FFT_RAM_IN_NUM-1:0],
    input [$clog2(FFT_RAM_IN_NUM)-1:0] ffti_wr_num,
    input [$clog2(FFT_RAM_IN_NUM)-1:0] ffti_wb_num,
    input [$clog2(FFT_RAM_IN_NUM)-1:0] ffti_rd_num,

    input [         FFT_ADDR_WIDTH-1:0] ffto_wr_addr[   FFT_CORE_COL-1:0],
    input [         FFT_ADDR_WIDTH-1:0] ffto_rd_addr[   FFT_CORE_COL-1:0],
    input                               ffto_wr_ena [FFT_RAM_OUT_NUM-1:0],
    input                               ffto_rd_ena [FFT_RAM_OUT_NUM-1:0][FFT_CORE_COL-1:0],
    input [$clog2(FFT_RAM_OUT_NUM)-1:0] ffto_wr_num,
    input [$clog2(FFT_RAM_OUT_NUM)-1:0] ffto_rd_num,

    input signed [WIDTH-1:0] rotar_real[ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    input signed [WIDTH-1:0] rotar_imag[ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],

    input  [        FFT_CORE_ROW-1:0] fft_core_out_stage,
    input  [      FFT_ADDR_WIDTH-1:0] array_sort_cnt,
    input                             array_sort_enable,
    input  [$clog2(FFT_CORE_COL)-1:0] ram2bus_cnt,
    output                            fft_core_vaild,
    output                            array_ena,

    //Alu Port
    input [ALU_WIDTH-1:0] fft_out1_r   [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    input [ALU_WIDTH-1:0] fft_out1_i   [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    input [ALU_WIDTH-1:0] fft_out2_r   [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    input [ALU_WIDTH-1:0] fft_out2_i   [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    input                 fft_out_valid[ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],

    output             fft_in_valid[ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    output [WIDTH-1:0] X2r         [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    output [WIDTH-1:0] X2i         [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    output [WIDTH-1:0] Wr          [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    output [WIDTH-1:0] Wi          [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    output [WIDTH-1:0] X1r         [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0],
    output [WIDTH-1:0] X1i         [ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0]

);


    //===================>> FFT Logic <<==========================//

    //==================================WIRE=====================================//


    //RAM IN
    wire [  FFT_RAM_WIDTH-1:0] ffti_wr_data[ FFT_RAM_IN_NUM-1:0] [FFT_CORE_COL-1:0];
    wire [  FFT_RAM_WIDTH-1:0] ffti_rd_data[ FFT_RAM_IN_NUM-1:0] [FFT_CORE_COL-1:0];
    (* mark_debug = "false"*)wire [ FFT_RAM_IN_NUM-1:0] ffti_vaild;

    //RAM OUT
    wire [  FFT_RAM_WIDTH-1:0] ffto_rd_data[FFT_RAM_OUT_NUM-1:0] [FFT_CORE_COL-1:0];
    wire [FFT_RAM_OUT_NUM-1:0] ffto_vaild;

    //FFT CORE
    wire [  FFT_RAM_WIDTH-1:0] fft_core_o  [   FFT_CORE_COL-1:0];


    //RAM IN
    genvar i;
    generate
        for (i = 0; i < FFT_RAM_IN_NUM; i = i + 1) begin : TRIPLE_RAM_IN
            fft_ram_in #(
                .PARALLEL(FFT_CORE_COL),
                .DEPTH(FFT_RAM_DEPTH),
                .WIDTH(FFT_RAM_WIDTH)
            ) ram_in_inst (
                .ram_clk(clk),
                .ram_rstn(rstn),
                .ram_i_ena(ffti_wr_ena[i]),
                .ram_o_ena(ffti_rd_ena[i]),
                .ram_i_data(ffti_wr_data[i]),
                .ram_i_addr(ffti_wr_addr[i]),
                .ram_o_addr(ffti_rd_addr),
                .ram_o_data(ffti_rd_data[i]),
                .ram_o_vaild(ffti_vaild[i])
            );
        end
    endgenerate
    // //tmp logic -> dma
    // reg [WIDTH*2-1:0] bus_i_data_delay[FFT_CORE_COL-1:0];
    // integer tmp;
    // always @(posedge clk)begin
    //     for(tmp=0;tmp<FFT_CORE_COL;tmp=tmp+1)begin
    //         bus_i_data_delay[tmp] <= bus_i_data[tmp];
    //     end
    // end

    generate
        for (i = 0; i < FFT_CORE_COL; i = i + 1) begin
            assign ffti_wr_data[0][i] = (ffti_wb_num == 0) ? fft_core_o[i] : bus_i_data[i];
            assign ffti_wr_data[1][i] = (ffti_wb_num == 1) ? fft_core_o[i] : bus_i_data[i];
            assign ffti_wr_data[2][i] = fft_core_o[i];
        end
    endgenerate

    //RAM OUT
    generate
        for (i = 0; i < FFT_RAM_OUT_NUM; i = i + 1) begin : DOUBLE_RAM_OUT
            fft_ram_out #(
                .PARALLEL(FFT_CORE_COL),
                .DEPTH(FFT_RAM_DEPTH),
                .WIDTH(FFT_RAM_WIDTH)
            ) ram_out_inst (
                .ram_clk(clk),
                .ram_rstn(rstn),
                .ram_i_ena(ffto_wr_ena[i]),
                .ram_o_ena(ffto_rd_ena[i]),
                .ram_i_data(fft_core_o),
                .ram_i_addr(ffto_wr_addr),
                .ram_o_addr(ffto_rd_addr),
                .ram_o_data(ffto_rd_data[i]),
                .ram_o_vaild(ffto_vaild[i])
            );
        end
    endgenerate


    //MDC CORE
    mdc_array #(
        .DATA_WIDTH(WIDTH),
        .MAX_POINT(FFT_MAX_POINT),
        .FFTCORE_STAGE(FFT_CORE_ROW),
        .FFTCORE_PARALLEL(FFT_CORE_COL),
        .RAM_IN_NUM(FFT_RAM_IN_NUM),
        .RAM_ADDR_WIDTH(FFT_ADDR_WIDTH),
        .ALU_WIDTH(ALU_WIDTH),
        .ALU_PARALLEL(ALU_PARALLEL)
    ) mdc_array_inst (
        .clk (clk),
        .rstn(rstn),

        .fft_core_enable((|ffti_vaild)),
        .fft_core_out_stage(fft_core_out_stage),
        .array_sort_cnt(array_sort_cnt),
        .array_sort_enable(array_sort_enable),
        .ram_in_num_o(ffti_rd_num),
        .fft_core_vaild(fft_core_vaild),

        .rotar_real(rotar_real),
        .rotar_imag(rotar_imag),
        .fft_core_i_data(ffti_rd_data),
        .fft_core_o_data(fft_core_o),

        //alu
        .fft_out1_r(fft_out1_r),
        .fft_out1_i(fft_out1_i),
        .fft_out2_r(fft_out2_r),
        .fft_out2_i(fft_out2_i),
        .fft_out_valid(fft_out_valid),
        .fft_in_valid(fft_in_valid),
        .X2r(X2r),
        .X2i(X2i),
        .Wr(Wr),
        .Wi(Wi),
        .X1r(X1r),
        .X1i(X1i)
    );

    //out
    genvar bus;
    generate
        for (bus = 0; bus < BUS_DATA_NUM; bus = bus + 1) begin
            assign bus_o_data[bus] = ffto_rd_data[ffto_rd_num][ram2bus_cnt+bus];
        end
    endgenerate
    assign bus_o_vaild = |ffto_vaild;

    assign array_ena   = |ffti_vaild;

endmodule
