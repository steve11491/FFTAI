module mdc_array#(
    parameter DATA_WIDTH            = 16,   //FFT data width
    parameter MAX_POINT             = 4096,

    parameter FFTCORE_STAGE         = 4,
    parameter FFTCORE_PARALLEL      = 8,
    parameter MDC_PARALLEL          = 2,
    parameter ARRAY_PARALLEL        = FFTCORE_PARALLEL/MDC_PARALLEL, 

    parameter RAM_IN_NUM            = 3,
    parameter RAM_ADDR_WIDTH        = 9,

    parameter ALU_WIDTH             = 40,    //ALU out width, ALU_WIDTH > 2*DATA_WIDTH
    parameter ALU_PARALLEL          = 16
)(
    input clk,
    input rstn,

    //Control
    input                                                   fft_core_enable,
    input [FFTCORE_STAGE-1:0]                               fft_core_out_stage,
    input [RAM_ADDR_WIDTH-1:0]                              array_sort_cnt,
    input                                                   array_sort_enable,
    input [$clog2(RAM_IN_NUM)-1:0]                          ram_in_num_o,
    output                                                  fft_core_vaild,

    //Data
    input signed [DATA_WIDTH-1:0] rotar_real[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    input signed [DATA_WIDTH-1:0] rotar_imag[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],

    input [DATA_WIDTH*2-1:0]                                fft_core_i_data[RAM_IN_NUM-1:0][FFTCORE_PARALLEL-1:0],
    output [DATA_WIDTH*2-1:0]                               fft_core_o_data[FFTCORE_PARALLEL-1:0], 

    //Alu Port
    input [ALU_WIDTH-1:0]                                   fft_out1_r[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    input [ALU_WIDTH-1:0]                                   fft_out1_i[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    input [ALU_WIDTH-1:0]                                   fft_out2_r[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    input [ALU_WIDTH-1:0]                                   fft_out2_i[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    input                                                   fft_out_valid[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],

    output                                                 fft_in_valid[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    output [DATA_WIDTH-1:0]                                 X2r[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    output [DATA_WIDTH-1:0]                                 X2i[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    output [DATA_WIDTH-1:0]                                 Wr[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    output [DATA_WIDTH-1:0]                                 Wi[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    output [DATA_WIDTH-1:0]                                 X1r[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0],
    output [DATA_WIDTH-1:0]                                 X1i[ARRAY_PARALLEL-1:0][FFTCORE_STAGE-1:0]

);

//==================================WIRE=====================================//

wire array_vaild;
assign fft_core_vaild = array_vaild;

//mdc
wire signed [DATA_WIDTH-1:0]                               mdc_real_i[ARRAY_PARALLEL-1:0][1:0];
wire signed [DATA_WIDTH-1:0]                               mdc_real_o[ARRAY_PARALLEL-1:0][1:0];
wire signed [DATA_WIDTH-1:0]                               mdc_imag_i[ARRAY_PARALLEL-1:0][1:0];
wire signed [DATA_WIDTH-1:0]                               mdc_imag_o[ARRAY_PARALLEL-1:0][1:0];


//array sort
wire [DATA_WIDTH*2-1:0]                             array_sort_i[FFTCORE_PARALLEL-1:0];
wire [DATA_WIDTH*2-1:0]                             array_sort_o[FFTCORE_PARALLEL-1:0];

//================================================Moudle==========================================//
localparam PE_DELAY = 4; //PE delay loop

//ena
reg mdc_ena;

//vaild
wire [ARRAY_PARALLEL-1:0]mdc_vaild;
assign  array_vaild = &mdc_vaild;  

//data in
reg signed [DATA_WIDTH-1:0] mdc_real_i_reg[ARRAY_PARALLEL-1:0][MDC_PARALLEL-1:0];
reg signed [DATA_WIDTH-1:0] mdc_imag_i_reg[ARRAY_PARALLEL-1:0][MDC_PARALLEL-1:0];


genvar ap;
//4 * 2-MDC FFT
generate
    for(ap=0;ap<ARRAY_PARALLEL;ap=ap+1)begin:R2MDC
        mdc #(
            .DATA_WIDTH(DATA_WIDTH),
            .ALU_WIDTH(ALU_WIDTH),
            .MDC_STAGE(FFTCORE_STAGE),
            .MDC_PARALLEL(MDC_PARALLEL)
        ) mdc_inst(
            .mdc_clk(clk),
            .mdc_rstn(rstn),
            .mdc_ena(mdc_ena),
            .mdc_stage(fft_core_out_stage),
            .rotar_real(rotar_real[ap]),
            .rotar_imag(rotar_imag[ap]),

            .data_i_real(mdc_real_i_reg[ap]),
            .data_i_imag(mdc_imag_i_reg[ap]),
            .data_o_real(mdc_real_o[ap]),
            .data_o_imag(mdc_imag_o[ap]),
            .mdc_vaild(mdc_vaild[ap]),

            //alu
            .fft_out1_r(fft_out1_r[ap]),
            .fft_out1_i(fft_out1_i[ap]),
            .fft_out2_r(fft_out2_r[ap]),
            .fft_out2_i(fft_out2_i[ap]),
            .fft_out_valid(fft_out_valid[ap]),

            .fft_in_valid(fft_in_valid[ap]),
            .X2r(X2r[ap]),
            .X2i(X2i[ap]),
            .Wr(Wr[ap]),
            .Wi(Wi[ap]),
            .X1r(X1r[ap]),
            .X1i(X1i[ap])
        );
    end
endgenerate

//delay 1 loop
always @(posedge clk)begin
    if(!rstn)begin
        mdc_ena<=1'b0;
    end
    else if(fft_core_enable)begin
        mdc_ena<=1'b1;
    end
    else begin
        mdc_ena<=1'b0;
    end
end

always @(posedge clk)begin
    for(integer i=0;i<ARRAY_PARALLEL;i=i+1)begin
        for(integer j=0;j<MDC_PARALLEL;j=j+1)begin
            mdc_real_i_reg[i][j] <= mdc_real_i[i][j];
            mdc_imag_i_reg[i][j] <= mdc_imag_i[i][j];
        end
    end
end


array_sort_ram#(
    .MAX_POINT(MAX_POINT),
    .MDC_PARALLEL(FFTCORE_PARALLEL),
    .MDC_STAGE(FFTCORE_STAGE),
    .DATA_WIDTH(DATA_WIDTH*2)
)array_sort_ram_inst(
    .clk(clk),
    .rstn(rstn),
    .pe_o_vaild(array_vaild),
    .array_sort_cnt(array_sort_cnt),
    .array_sort_vaild(array_sort_enable),
    .mdc_o_data(array_sort_i),

    .array_sort_o(array_sort_o)
); 


//================================================Logic==========================================//
//MDC I/O/W
generate
    for(genvar j=0;j<ARRAY_PARALLEL;j=j+1)begin
        assign mdc_real_i[j][0]=fft_core_i_data[ram_in_num_o][j*2][DATA_WIDTH-1:0];
        assign mdc_imag_i[j][0]=fft_core_i_data[ram_in_num_o][j*2][2*DATA_WIDTH-1:DATA_WIDTH];
        assign mdc_real_i[j][1]=fft_core_i_data[ram_in_num_o][j*2+1][DATA_WIDTH-1:0];
        assign mdc_imag_i[j][1]=fft_core_i_data[ram_in_num_o][j*2+1][2*DATA_WIDTH-1:DATA_WIDTH];
    end
endgenerate


generate
    for(genvar j=0;j<ARRAY_PARALLEL;j=j+1)begin
        assign array_sort_i[j*2]={mdc_imag_o[j][0],mdc_real_o[j][0]};
        assign array_sort_i[j*2+1]={mdc_imag_o[j][1],mdc_real_o[j][1]};
    end
endgenerate

generate
    for(genvar j=0;j<FFTCORE_PARALLEL;j=j+1)begin
        assign fft_core_o_data[j] = array_sort_o[j];
    end
endgenerate



endmodule