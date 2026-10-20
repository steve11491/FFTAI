//=================================================================================
//
// Designer: SXH
//
// Description: R2MDC DIT-FFT design module (INT/ 16 FFT/ 2 parallel)
//

//
//=================================================================================

module mdc #(
    parameter DATA_WIDTH = 16,   //FFT data width
    parameter ALU_WIDTH = 40,    //ALU out width, ALU_WIDTH > 2*DATA_WIDTH
    parameter MDC_STAGE = 4,
    parameter MDC_PARALLEL = 2
)(
    input mdc_clk,
    input mdc_rstn,
    input mdc_ena,
    input [3:0] mdc_stage,
    input signed [DATA_WIDTH-1:0] rotar_real[MDC_STAGE-1:0],
    input signed [DATA_WIDTH-1:0] rotar_imag[MDC_STAGE-1:0],

    input signed [DATA_WIDTH-1:0] data_i_real[MDC_PARALLEL-1:0],
    input signed [DATA_WIDTH-1:0] data_i_imag[MDC_PARALLEL-1:0],
    output reg signed [DATA_WIDTH-1:0] data_o_real[MDC_PARALLEL-1:0],
    output reg signed [DATA_WIDTH-1:0] data_o_imag[MDC_PARALLEL-1:0],
    output reg mdc_vaild,

    //alu
    input [ALU_WIDTH-1:0] fft_out1_r[MDC_STAGE-1:0],
    input [ALU_WIDTH-1:0] fft_out1_i[MDC_STAGE-1:0],
    input [ALU_WIDTH-1:0] fft_out2_r[MDC_STAGE-1:0],
    input [ALU_WIDTH-1:0] fft_out2_i[MDC_STAGE-1:0],
    input fft_out_valid[MDC_STAGE-1:0],

    output fft_in_valid [MDC_STAGE-1:0],
    output [DATA_WIDTH-1:0] X2r[MDC_STAGE-1:0],
    output [DATA_WIDTH-1:0] X2i[MDC_STAGE-1:0],
    output [DATA_WIDTH-1:0] Wr[MDC_STAGE-1:0],
    output [DATA_WIDTH-1:0] Wi[MDC_STAGE-1:0],
    output [DATA_WIDTH-1:0] X1r[MDC_STAGE-1:0],
    output [DATA_WIDTH-1:0] X1i[MDC_STAGE-1:0]
);

localparam RESULT_WIDTH = DATA_WIDTH + 1;


(* mark_debug = "false"*)wire pe_ena[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire signed [DATA_WIDTH-1:0] add_i_real[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire signed [DATA_WIDTH-1:0] add_i_imag[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire signed [DATA_WIDTH-1:0] mul_i_real[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire signed [DATA_WIDTH-1:0] mul_i_imag[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire signed [RESULT_WIDTH-1:0] add_o_real[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire signed [RESULT_WIDTH-1:0] add_o_imag[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire signed [RESULT_WIDTH-1:0] mul_o_real[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire signed [RESULT_WIDTH-1:0] mul_o_imag[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire switch_ena[MDC_STAGE-1:0];
wire signed [2*DATA_WIDTH-1:0] switch_i_0[MDC_STAGE-1:0];
wire signed [2*DATA_WIDTH-1:0] switch_i_1[MDC_STAGE-1:0];
// wire signed [2*DATA_WIDTH-1:0] switch_i_alu_0[MDC_STAGE-1:0];
// wire signed [2*DATA_WIDTH-1:0] switch_i_alu_1[MDC_STAGE-1:0];
wire signed [2*DATA_WIDTH-1:0] switch_o_0[MDC_STAGE-1:0];
wire signed [2*DATA_WIDTH-1:0] switch_o_1[MDC_STAGE-1:0];
(* mark_debug = "false"*)wire switch_vaild[MDC_STAGE-1:0];

genvar s;
//FFT basic pe
// generate
//     for(s=0;s<MDC_STAGE;s=s+1)begin:BASIC_PE
//         basic_pe #(DATA_WIDTH) pe_inst(
//             .clk(mdc_clk),
//             .rstn(mdc_rstn),
//             .ena(pe_ena[s]),
//             .add_i_real(add_i_real[s]),
//             .add_i_imag(add_i_imag[s]),
//             .mul_i_real(mul_i_real[s]),
//             .mul_i_imag(mul_i_imag[s]),
//             .Wnk_real(rotar_real[s]),
//             .Wnk_imag(rotar_imag[s]),
//             .add_o_real(add_o_real[s]),
//             .add_o_imag(add_o_imag[s]),
//             .mul_o_real(mul_o_real[s]),
//             .mul_o_imag(mul_o_imag[s])
//             // .vaild(switch_ena[s])
//         );  
//     end
// endgenerate

//FIFO Switch
dc_switch #(
    .SWITCH_WIDTH(DATA_WIDTH*2)
) dc_switch_inst_0(
    .switch_clk(mdc_clk),
    .switch_rstn(mdc_rstn),
    .switch_ena(switch_ena[0]),
    .switch_i_0(switch_i_0[0]),
    .switch_i_1(switch_i_1[0]),
    .switch_o_0(switch_o_0[0]),
    .switch_o_1(switch_o_1[0]),
    .switch_vaild(switch_vaild[0])
);
generate
    for(s=1;s<MDC_STAGE;s=s+1)begin:dc_switch_inst
        dc_switch_fifo #(
            .FFT_STAGE(s+1),
            .SWITCH_WIDTH(DATA_WIDTH*2)
        ) dc_switch_fifo_inst(
            .switch_clk(mdc_clk),
            .switch_rstn(mdc_rstn),
            .switch_ena(switch_ena[s]),
            .switch_i_0(switch_i_0[s]),
            .switch_i_1(switch_i_1[s]),
            .switch_o_0(switch_o_0[s]),
            .switch_o_1(switch_o_1[s]),
            .switch_vaild(switch_vaild[s])
        );
    end
endgenerate

assign pe_ena[0] = mdc_ena;
assign add_i_real[0] = data_i_real[0];
assign add_i_imag[0] = data_i_imag[0];
assign mul_i_real[0] = data_i_real[1];
assign mul_i_imag[0] = data_i_imag[1];
generate
    for(s=1;s<MDC_STAGE;s=s+1)begin
        assign pe_ena[s] = switch_vaild[s-1];
        assign add_i_imag[s] = switch_o_0[s-1][DATA_WIDTH*2-1:DATA_WIDTH];
        assign add_i_real[s] = switch_o_0[s-1][DATA_WIDTH-1:0];
        assign mul_i_imag[s] = switch_o_1[s-1][DATA_WIDTH*2-1:DATA_WIDTH];
        assign mul_i_real[s] = switch_o_1[s-1][DATA_WIDTH-1:0];
        end
endgenerate
// generate
//     for(s=0;s<MDC_STAGE;s=s+1)begin
//         assign switch_i_0[s] = {add_o_imag[s][RESULT_WIDTH-1:RESULT_WIDTH-DATA_WIDTH],add_o_real[s][RESULT_WIDTH-1:RESULT_WIDTH-DATA_WIDTH]};
//         assign switch_i_1[s] = {mul_o_imag[s][RESULT_WIDTH-1:RESULT_WIDTH-DATA_WIDTH],mul_o_real[s][RESULT_WIDTH-1:RESULT_WIDTH-DATA_WIDTH]};
//     end
// endgenerate

//alu
generate
    for(s=0;s<MDC_STAGE;s=s+1)begin
        assign X1r[s] = add_i_real[s];
        assign X1i[s] = add_i_imag[s];
        assign X2r[s] = mul_i_real[s];
        assign X2i[s] = mul_i_imag[s];
        assign Wr[s]  = rotar_real[s];
        assign Wi[s]  = rotar_imag[s];
        assign fft_in_valid[s]  = pe_ena[s];
        assign switch_ena[s]  = fft_out_valid[s];
        assign switch_i_0[s] = {fft_out2_i[s][2*DATA_WIDTH-1:DATA_WIDTH], fft_out2_r[s][2*DATA_WIDTH-1:DATA_WIDTH]};
        assign switch_i_1[s] = {fft_out1_i[s][2*DATA_WIDTH-1:DATA_WIDTH], fft_out1_r[s][2*DATA_WIDTH-1:DATA_WIDTH]};
    end
endgenerate


always@(posedge mdc_clk)begin
    if(!mdc_rstn)begin
        mdc_vaild<=1'b0;
        data_o_real[0]<={DATA_WIDTH{1'b0}};
        data_o_real[1]<={DATA_WIDTH{1'b0}};
        data_o_imag[0]<={DATA_WIDTH{1'b0}};
        data_o_imag[1]<={DATA_WIDTH{1'b0}};
    end
    else begin
        case(mdc_stage)
            4'b0000:begin
                mdc_vaild<=switch_vaild[3];
                data_o_imag[0]<=switch_o_0[3][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_imag[1]<=switch_o_1[3][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_real[0]<=switch_o_0[3][DATA_WIDTH-1:0];
                data_o_real[1]<=switch_o_1[3][DATA_WIDTH-1:0];
            end
            4'b0001:begin
                mdc_vaild<=switch_vaild[0];
                data_o_imag[0]<=switch_o_0[0][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_imag[1]<=switch_o_1[0][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_real[0]<=switch_o_0[0][DATA_WIDTH-1:0];
                data_o_real[1]<=switch_o_1[0][DATA_WIDTH-1:0];
            end
            4'b0010:begin
                mdc_vaild<=switch_vaild[1];
                data_o_imag[0]<=switch_o_0[1][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_imag[1]<=switch_o_1[1][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_real[0]<=switch_o_0[1][DATA_WIDTH-1:0];
                data_o_real[1]<=switch_o_1[1][DATA_WIDTH-1:0];
            end
            4'b0100:begin
                mdc_vaild<=switch_vaild[2];
                data_o_imag[0]<=switch_o_0[2][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_imag[1]<=switch_o_1[2][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_real[0]<=switch_o_0[2][DATA_WIDTH-1:0];
                data_o_real[1]<=switch_o_1[2][DATA_WIDTH-1:0];
            end
            4'b1000:begin
                mdc_vaild<=switch_vaild[3];
                data_o_imag[0]<=switch_o_0[3][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_imag[1]<=switch_o_1[3][DATA_WIDTH*2-1:DATA_WIDTH];
                data_o_real[0]<=switch_o_0[3][DATA_WIDTH-1:0];
                data_o_real[1]<=switch_o_1[3][DATA_WIDTH-1:0];
            end
            default :begin
                mdc_vaild<=1'b0;
                data_o_real[0]<={DATA_WIDTH{1'b0}};
                data_o_real[1]<={DATA_WIDTH{1'b0}};
                data_o_imag[0]<={DATA_WIDTH{1'b0}};
                data_o_imag[1]<={DATA_WIDTH{1'b0}};
            end
        endcase
    end
end

// assign  switch_1_1_i_real[0] = switch_1_1_i_real_alu[0];
// assign  switch_1_1_i_imag[0] = switch_1_1_i_imag_alu[0];
// assign  switch_1_1_i_real[1] = switch_1_1_i_real_alu[1];
// assign  switch_1_1_i_imag[1] = switch_1_1_i_imag_alu[1];
// assign  switch_1_2_i_real[0] = switch_1_2_i_real_alu[0];
// assign  switch_1_2_i_imag[0] = switch_1_2_i_imag_alu[0];
// assign  switch_1_2_i_real[1] = switch_1_2_i_real_alu[1];
// assign  switch_1_2_i_imag[1] = switch_1_2_i_imag_alu[1];
// assign  switch_1_3_i_real[0] = switch_1_3_i_real_alu[0];
// assign  switch_1_3_i_imag[0] = switch_1_3_i_imag_alu[0];
// assign  switch_1_3_i_real[1] = switch_1_3_i_real_alu[1];
// assign  switch_1_3_i_imag[1] = switch_1_3_i_imag_alu[1];
// assign  switch_1_4_i_real[0] = switch_1_4_i_real_alu[0];
// assign  switch_1_4_i_imag[0] = switch_1_4_i_imag_alu[0];
// assign  switch_1_4_i_real[1] = switch_1_4_i_real_alu[1];
// assign  switch_1_4_i_imag[1] = switch_1_4_i_imag_alu[1];

// //alu
// assign X1r[0] = real_i_0;
// assign X1i[0] = imag_i_0;
// assign X1r[1] = switch_1_1_o_real[0];
// assign X1i[1] = switch_1_1_o_imag[0];
// assign X1r[2] = switch_1_2_o_real[0];
// assign X1i[2] = switch_1_2_o_imag[0];
// assign X1r[3] = switch_1_3_o_real[0];
// assign X1i[3] = switch_1_3_o_imag[0];

// assign X2r[0] = real_i_1;
// assign X2i[0] = imag_i_1;
// assign X2r[1] = switch_1_1_o_real[1];
// assign X2i[1] = switch_1_1_o_imag[1];
// assign X2r[2] = switch_1_2_o_real[1];
// assign X2i[2] = switch_1_2_o_imag[1];
// assign X2r[3] = switch_1_3_o_real[1];
// assign X2i[3] = switch_1_3_o_imag[1];

// assign Wr[0] = rotar_1_1_real;
// assign Wi[0] = rotar_1_1_imag;
// assign Wr[1] = rotar_1_2_real;
// assign Wi[1] = rotar_1_2_imag;
// assign Wr[2] = rotar_1_3_real;
// assign Wi[2] = rotar_1_3_imag;
// assign Wr[3] = rotar_1_4_real;
// assign Wi[3] = rotar_1_4_imag;

// assign fft_in_valid[0] = mdc_ena;
// assign fft_in_valid[1] = switch_1_vaild;
// assign fft_in_valid[2] = switch_2_vaild;
// assign fft_in_valid[3] = switch_3_vaild;

// assign switch_1_ena = fft_out_valid[0];
// assign switch_2_ena = fft_out_valid[1];
// assign switch_3_ena = fft_out_valid[2];
// assign switch_4_ena = fft_out_valid[3];

// assign  switch_1_1_i_real_alu[0] = fft_out2_r[0][2*DATA_WIDTH-1:DATA_WIDTH]; //add o
// assign  switch_1_1_i_imag_alu[0] = fft_out2_i[0][2*DATA_WIDTH-1:DATA_WIDTH]; 
// assign  switch_1_1_i_real_alu[1] = fft_out1_r[0][2*DATA_WIDTH-1:DATA_WIDTH]; //sub o
// assign  switch_1_1_i_imag_alu[1] = fft_out1_i[0][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_2_i_real_alu[0] = fft_out2_r[1][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_2_i_imag_alu[0] = fft_out2_i[1][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_2_i_real_alu[1] = fft_out1_r[1][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_2_i_imag_alu[1] = fft_out1_i[1][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_3_i_real_alu[0] = fft_out2_r[2][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_3_i_imag_alu[0] = fft_out2_i[2][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_3_i_real_alu[1] = fft_out1_r[2][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_3_i_imag_alu[1] = fft_out1_i[2][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_4_i_real_alu[0] = fft_out2_r[3][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_4_i_imag_alu[0] = fft_out2_i[3][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_4_i_real_alu[1] = fft_out1_r[3][2*DATA_WIDTH-1:DATA_WIDTH];
// assign  switch_1_4_i_imag_alu[1] = fft_out1_i[3][2*DATA_WIDTH-1:DATA_WIDTH];

endmodule