


module fft_core #(
    parameter WIDTH             = 16,
    parameter BUS_WIDTH         = 64,
    parameter FFT_STAGE_WIDTH   = 4,                                           //reg
    parameter FFT_MAX_POINT     = 4096,
    parameter FFT_CORE_COL      = 8,
    parameter FFT_CORE_ROW      = 4,
    parameter FFT_CORE_NUM      = 4,
    parameter FFT_CORE_MAX_NUM  = 4,
    parameter ARRAY_PARALLEL    = FFT_CORE_COL / 2,
    parameter BUS_DATA_NUM      = BUS_WIDTH / WIDTH / 2,
    parameter FFT_RAM_IN_NUM    = 3,
    parameter FFT_RAM_OUT_NUM   = 2,
    parameter FFT_RAM_DEPTH     = FFT_MAX_POINT / 8,
    parameter FFT_ADDR_WIDTH    = $clog2(FFT_RAM_DEPTH),
    parameter FFT_RAM_WIDTH     = WIDTH * 2,
    parameter FFTW_RAM_PARALLEL = ARRAY_PARALLEL,
    parameter FFTW_RAM_POINT    = FFT_MAX_POINT / 2,
    parameter FFTW_ADDR_WIDTH   = $clog2(FFTW_RAM_POINT / FFTW_RAM_PARALLEL),
    parameter ALU_WIDTH         = 40,
    parameter ALU_PARALLEL      = 16
) (


    input clk,
    input rstn,

    //ctl
    input fft_start,
    input [FFT_STAGE_WIDTH-1:0] fft_stage,

    //data
    // input bus_i_vaild,
    input [WIDTH*2-1:0] bus_i_data[FFT_CORE_NUM-1:0][FFT_CORE_COL-1:0],
    input [FFT_CORE_NUM-1:0] bus_i_vaild,
    input [FFT_CORE_NUM-1:0] bus_i_hask,
    output bus_i_ready,

    input [FFT_CORE_NUM-1:0] bus_o_ready,
    output [WIDTH*2-1:0] bus_o_data[FFT_CORE_NUM-1:0][BUS_DATA_NUM-1:0],
    output [FFT_CORE_NUM-1:0] bus_o_vaild,

    //Alu Port
    input [ALU_WIDTH-1:0] fft_out1_r   [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    input [ALU_WIDTH-1:0] fft_out1_i   [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    input [ALU_WIDTH-1:0] fft_out2_r   [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    input [ALU_WIDTH-1:0] fft_out2_i   [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    input                 fft_out_valid[FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],

    output [ALU_PARALLEL-1:0] fft_in_valid[FFT_CORE_ROW-1:0],
    output [       WIDTH-1:0] X2r         [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    output [       WIDTH-1:0] X2i         [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    output [       WIDTH-1:0] Wr          [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    output [       WIDTH-1:0] Wi          [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    output [       WIDTH-1:0] X1r         [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0],
    output [       WIDTH-1:0] X1i         [FFT_CORE_ROW-1:0][ALU_PARALLEL-1:0]

);


    /***********************************************************************/
    /*****************************FFT Logic*********************************/
    /***********************************************************************/

    //RAM IN
    wire [FFT_ADDR_WIDTH-1:0] ffti_wr_addr[FFT_RAM_IN_NUM-1:0][FFT_CORE_COL-1:0];
    wire [FFT_ADDR_WIDTH-1:0] ffti_rd_addr[FFT_CORE_COL-1:0];
    wire ffti_wr_ena[FFT_RAM_IN_NUM-1:0][FFT_CORE_COL-1:0];
    wire ffti_rd_ena[FFT_RAM_IN_NUM-1:0];
    wire [$clog2(FFT_RAM_IN_NUM)-1:0] ffti_wr_num;
    wire [$clog2(FFT_RAM_IN_NUM)-1:0] ffti_wb_num;
    wire [$clog2(FFT_RAM_IN_NUM)-1:0] ffti_rd_num;

    //RAM OUT
    wire [FFT_ADDR_WIDTH-1:0] ffto_wr_addr[FFT_CORE_COL-1:0];
    wire [FFT_ADDR_WIDTH-1:0] ffto_rd_addr[FFT_CORE_COL-1:0];
    wire ffto_wr_ena[FFT_RAM_OUT_NUM-1:0];
    wire ffto_rd_ena[FFT_RAM_OUT_NUM-1:0][FFT_CORE_COL-1:0];
    wire [$clog2(FFT_RAM_OUT_NUM)-1:0] ffto_wr_num;
    wire [$clog2(FFT_RAM_OUT_NUM)-1:0] ffto_rd_num;

    //ROM WEIGHT
    wire [WIDTH*2-1:0] fftw_rd_data[FFTW_RAM_PARALLEL-1:0];
    wire [FFT_ADDR_WIDTH-1:0] fftw_rd_addr;
    wire fftw_rd_ena;
    wire fftw_rd_pass;

    //FFT CORE
    wire [FFT_CORE_ROW-1:0] fft_core_out_stage;
    wire [FFT_ADDR_WIDTH-1:0] array_sort_cnt;
    wire array_sort_enable;
    wire [FFT_CORE_NUM-1:0] fft_core_vaild;
    wire [$clog2(FFT_CORE_COL)-1:0] ram2bus_cnt;

    //alu
    (* mark_debug = "false"*)
    wire [ALU_WIDTH-1:0] fft_out1_r_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [ALU_WIDTH-1:0] fft_out1_i_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [ALU_WIDTH-1:0] fft_out2_r_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [ALU_WIDTH-1:0] fft_out2_i_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire fft_out_valid_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire fft_in_valid_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [WIDTH-1:0] X2r_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [WIDTH-1:0] X2i_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [WIDTH-1:0] Wr_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [WIDTH-1:0] Wi_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [WIDTH-1:0] X1r_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    (* mark_debug = "false"*)wire [WIDTH-1:0] X1i_wire[FFT_CORE_MAX_NUM-1:0][ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];

    genvar alu_i, alu_j, alu_x;
    generate
        for (alu_i = 0; alu_i < FFT_CORE_MAX_NUM; alu_i = alu_i + 1) begin
            for (alu_j = 0; alu_j < FFT_CORE_ROW; alu_j = alu_j + 1) begin
                for (alu_x = 0; alu_x < ARRAY_PARALLEL; alu_x = alu_x + 1) begin
                    assign fft_out1_r_wire[alu_i][alu_x][alu_j] = fft_out1_r[alu_j][alu_x+ARRAY_PARALLEL*alu_i];
                    assign fft_out1_i_wire[alu_i][alu_x][alu_j] = fft_out1_i[alu_j][alu_x+ARRAY_PARALLEL*alu_i];
                    assign fft_out2_r_wire[alu_i][alu_x][alu_j] = fft_out2_r[alu_j][alu_x+ARRAY_PARALLEL*alu_i];
                    assign fft_out2_i_wire[alu_i][alu_x][alu_j] = fft_out2_i[alu_j][alu_x+ARRAY_PARALLEL*alu_i];

                    assign fft_out_valid_wire[alu_i][alu_x][alu_j] = fft_out_valid[alu_j][alu_x+ARRAY_PARALLEL*alu_i];
                    assign fft_in_valid[alu_j][alu_x+ARRAY_PARALLEL*alu_i] = fft_in_valid_wire[alu_i][alu_x][alu_j];

                    assign X2r[alu_j][alu_x+ARRAY_PARALLEL*alu_i] = X2r_wire[alu_i][alu_x][alu_j];
                    assign X2i[alu_j][alu_x+ARRAY_PARALLEL*alu_i] = X2i_wire[alu_i][alu_x][alu_j];
                    assign Wr[alu_j][alu_x+ARRAY_PARALLEL*alu_i] = Wr_wire[alu_i][alu_x][alu_j];
                    assign Wi[alu_j][alu_x+ARRAY_PARALLEL*alu_i] = Wi_wire[alu_i][alu_x][alu_j];
                    assign X1r[alu_j][alu_x+ARRAY_PARALLEL*alu_i] = X1r_wire[alu_i][alu_x][alu_j];
                    assign X1i[alu_j][alu_x+ARRAY_PARALLEL*alu_i] = X1i_wire[alu_i][alu_x][alu_j];
                end
            end
        end
    endgenerate

    //FFT MASTER CTRL
    fft_control #(
        .FFT_CORE_NUM(FFT_CORE_NUM),
        .STAGE_WIDTH (FFT_STAGE_WIDTH),

        .MAX_POINT(FFT_MAX_POINT),
        .MDC_PARALLEL(FFT_CORE_COL),
        .MDC_STAGE(FFT_CORE_ROW),
        .DATA_WIDTH(WIDTH * 2),  //FFT data width
        .RAM_IN_NUM(FFT_RAM_IN_NUM),
        .RAM_OUT_NUM(FFT_RAM_OUT_NUM),
        .BUS_DATA_WIDTH(BUS_WIDTH)

    ) fft_control_inst (
        .clk (clk),
        .rstn(rstn),

        .bus_i_vaild(bus_i_vaild),
        .bus_i_hask (bus_i_hask),
        .bus_i_ready(bus_i_ready),
        .bus_o_ready(bus_o_ready),

        .fft_start(fft_start),
        .fft_stage(fft_stage),

        .fft_core_vaild(fft_core_vaild),
        .fft_core_out_stage(fft_core_out_stage),

        .array_sort_cnt  (array_sort_cnt),
        .array_sort_vaild(array_sort_enable),

        .ram_in_addr_i(ffti_wr_addr),
        .ram_in_ena_i(ffti_wr_ena),
        .ram_in_num_i(ffti_wr_num),
        .ram_in_back_num_i(ffti_wb_num),
        .ram_in_addr_o(ffti_rd_addr),
        .ram_in_ena_o(ffti_rd_ena),
        .ram_in_num_o(ffti_rd_num),

        .ram_out_addr_i(ffto_wr_addr),
        .ram_out_ena_i (ffto_wr_ena),
        .ram_out_num_i (ffto_wr_num),
        .ram_out_addr_o(ffto_rd_addr),
        .ram_out_ena_o (ffto_rd_ena),
        .ram_out_num_o (ffto_rd_num),

        .rom_weight_addr(fftw_rd_addr),
        .rom_weight_ena (fftw_rd_ena),
        .mdc_frs_stage  (fftw_rd_pass),

        .ramout2axi_num(ram2bus_cnt)
    );

    wire [WIDTH-1:0] mdc_weight_real[ARRAY_PARALLEL-1:0];
    wire [WIDTH-1:0] mdc_weight_imag[ARRAY_PARALLEL-1:0];
    generate
        for (genvar j = 0; j < ARRAY_PARALLEL; j = j + 1) begin
            assign mdc_weight_real[j] = fftw_rd_data[j][WIDTH-1:0];
            assign mdc_weight_imag[j] = fftw_rd_data[j][2*WIDTH-1:WIDTH];
        end
    endgenerate

    //rotar buff
    wire signed [WIDTH-1:0] rotar_real[ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    wire signed [WIDTH-1:0] rotar_imag[ARRAY_PARALLEL-1:0][FFT_CORE_ROW-1:0];
    wire [FFT_CORE_NUM-1:0] array_ena;
    generate
        for (genvar ap = 0; ap < ARRAY_PARALLEL; ap = ap + 1) begin : ROTARS_LOOP
            rotars_loop #(
                .DATA_WIDTH(WIDTH)  //FFT data width
            ) rotar_loop_inst (
                .fft_clk  (clk),
                .fft_rstn (rstn),
                .fft_ena  (|array_ena),
                .fft_stage(fft_core_out_stage),

                .rotar_i_real(mdc_weight_real[ap]),
                .rotar_i_imag(mdc_weight_imag[ap]),

                .rotar_1_real(rotar_real[ap][0]),
                .rotar_1_imag(rotar_imag[ap][0]),
                .rotar_2_real(rotar_real[ap][1]),
                .rotar_2_imag(rotar_imag[ap][1]),
                .rotar_3_real(rotar_real[ap][2]),
                .rotar_3_imag(rotar_imag[ap][2]),
                .rotar_4_real(rotar_real[ap][3]),
                .rotar_4_imag(rotar_imag[ap][3])
            );
        end
    endgenerate

    //FFT RAM WEIGHT
    fft_ram_weight #(
        .PARALLEL(FFTW_RAM_PARALLEL),
        .WIDTH(2 * WIDTH),
        .MAX_POINT(FFT_MAX_POINT / 2)
    ) ram_weight_inst (
        .ram_clk (clk),
        .ram_ena (fftw_rd_ena),
        .ram_pass(fftw_rd_pass),
        .ram_addr(fftw_rd_addr),
        .ram_data(fftw_rd_data)
    );

    //FFT CORE
    generate
        for (genvar m = 0; m < FFT_CORE_NUM; m = m + 1) begin : FFT_ARRAY
            fft_array #(
                .WIDTH(WIDTH),
                .BUS_WIDTH(BUS_WIDTH),
                .FFT_STAGE_WIDTH(FFT_STAGE_WIDTH),
                .FFT_MAX_POINT(FFT_MAX_POINT),
                .FFT_CORE_COL(FFT_CORE_COL),
                .FFT_CORE_ROW(FFT_CORE_ROW),
                .FFT_RAM_IN_NUM(FFT_RAM_IN_NUM),
                .FFT_RAM_OUT_NUM(FFT_RAM_OUT_NUM),
                .ALU_WIDTH(ALU_WIDTH),
                .ALU_PARALLEL(ALU_PARALLEL)
            ) u_fft_array (
                .clk (clk),
                .rstn(rstn),

                .bus_i_data (bus_i_data[m]),
                .bus_o_vaild(bus_o_vaild[m]),
                .bus_o_data (bus_o_data[m]),

                .array_ena(array_ena[m]),
                .fft_core_vaild(fft_core_vaild[m]),
                .fft_core_out_stage(fft_core_out_stage),

                .array_sort_cnt(array_sort_cnt),
                .array_sort_enable(array_sort_enable),

                .ffti_wr_addr(ffti_wr_addr),
                .ffti_wr_ena (ffti_wr_ena),
                .ffti_wr_num (ffti_wr_num),
                .ffti_wb_num (ffti_wb_num),
                .ffti_rd_addr(ffti_rd_addr),
                .ffti_rd_ena (ffti_rd_ena),
                .ffti_rd_num (ffti_rd_num),

                .ffto_wr_addr(ffto_wr_addr),
                .ffto_wr_ena (ffto_wr_ena),
                .ffto_wr_num (ffto_wr_num),
                .ffto_rd_addr(ffto_rd_addr),
                .ffto_rd_ena (ffto_rd_ena),
                .ffto_rd_num (ffto_rd_num),

                .rotar_real(rotar_real),
                .rotar_imag(rotar_imag),

                .ram2bus_cnt(ram2bus_cnt),

                //alu
                .fft_out1_r(fft_out1_r_wire[m]),
                .fft_out1_i(fft_out1_i_wire[m]),
                .fft_out2_r(fft_out2_r_wire[m]),
                .fft_out2_i(fft_out2_i_wire[m]),
                .fft_out_valid(fft_out_valid_wire[m]),
                .fft_in_valid(fft_in_valid_wire[m]),
                .X2r(X2r_wire[m]),
                .X2i(X2i_wire[m]),
                .Wr(Wr_wire[m]),
                .Wi(Wi_wire[m]),
                .X1r(X1r_wire[m]),
                .X1i(X1i_wire[m])
            );
        end
    endgenerate




endmodule
