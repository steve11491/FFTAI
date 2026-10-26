



module imap_offset_addr_gen #(
    parameter NUM_WIDTH = 10,
    parameter DIM_WIDTH = 12,
    parameter IMAP_DIM_WIDTH = DIM_WIDTH + 2,
    parameter BUS_ADDR_WIDTH = 32,
    parameter AIWIH_WIDTH = 20,
    parameter AIW_WIDTH = 10,
    parameter BUS_WIDTH = 64,
    parameter CHANNEL_NUM = 16,
    parameter S_WIDTH = $clog2($clog2(CHANNEL_NUM * 2)) + 1,
    parameter C_WIDTH = $clog2(CHANNEL_NUM * 2),
    parameter BURST_NUM_WIDTH = 4,
    parameter PADDING_WIDTH = 5

) (
    input wire clk,
    input wire rstn,
    input wire [S_WIDTH-1:0] shift_value,
    input wire [3:0] padding_flag,
    input wire [PADDING_WIDTH-1:0] padding_external[3:0],

    input wire [AIWIH_WIDTH-1:0] Aiwih,
    input wire [AIW_WIDTH-1:0] Aiw,
    input wire [IMAP_DIM_WIDTH+1-1:0] basic_oh_sy_add1,
    input wire [IMAP_DIM_WIDTH+1-1:0] basic_ow_sx_add1,
    input wire [DIM_WIDTH+1-1:0] basic_ic_add1,
    input wire [NUM_WIDTH-1:0] cnt_load_imap_h,
    input wire [NUM_WIDTH-1:0] cnt_load_imap_w,
    input wire [NUM_WIDTH-1:0] cnt_load_imap_ic,
    input wire [C_WIDTH-1:0] currc,
    input wire [BURST_NUM_WIDTH-1:0] cnt_dburst,
    input wire [IMAP_DIM_WIDTH-1:0] cnt_dih,
    input wire [DIM_WIDTH-1:0] cnt_dic,
    input wire [1:0] imap_offset_addr_shift,
    output reg [BUS_ADDR_WIDTH-1:0] imap_offset_addr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         imap_offset_addr <= 0;
    //     end else begin
    //         imap_offset_addr <= (((cnt_load_imap_h * (basic_oh_sy+1) + cnt_dih - padding_external[3]) * Aiciw)
    //                             + ((cnt_load_imap_w * (basic_ow_sx+1)  - padding_external[1]) * Aic + cnt_diw * aic)
    //                             + (cnt_load_imap_ic * (basic_ic+1))) << imap_offset_addr_shift ;

    //  imap_offset_addr <= (((cnt_load_imap_ic * (basic_ic+1) + cnt_dic << shift_value ) * Aiwih)
    //                             + ((cnt_load_imap_h * (basic_oh_sy+1) + cnt_dih - padding_external[3]) * (currc+1) * Aiw)
    //                             + ((cnt_load_imap_w * (basic_ow_sx+1) - padding_external[1] ) * (currc+1) )
    //                             + cnt_dburst * (256*BUS_WIDTH/8) >> imap_offset_addr_shift) << imap_offset_addr_shift ;

    //     end
    // end

    wire [PADDING_WIDTH-1:0] top_padding_external;
    assign top_padding_external = (padding_flag[3] ? {PADDING_WIDTH{1'b0}} : {padding_external[3][PADDING_WIDTH-1:0]});
    wire [PADDING_WIDTH-1:0] left_padding_external;
    assign left_padding_external = (padding_flag[1] ? {PADDING_WIDTH{1'b0}} : { padding_external[1][PADDING_WIDTH-1:0]});


    localparam BURST_NUM_WIDTH2 = BURST_NUM_WIDTH + $clog2((256 * BUS_WIDTH / 8));
    // Stage 0
    reg [NUM_WIDTH+DIM_WIDTH-1:0] stage0_result1;
    reg [NUM_WIDTH+IMAP_DIM_WIDTH-1:0] stage0_result2;
    reg [BURST_NUM_WIDTH2-1:0] stage0_result3;
    reg [DIM_WIDTH-1:0] stage0_result4;
    reg [DIM_WIDTH-1:0] stage0_result5;
    reg [C_WIDTH+1-1:0] stage0_result6;
    reg [NUM_WIDTH+IMAP_DIM_WIDTH-1:0] stage0_result7;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage0_result1 <= 0;
            stage0_result2 <= 0;
            stage0_result3 <= 0;
            stage0_result4 <= 0;
            stage0_result5 <= 0;
            stage0_result6 <= 0;
            stage0_result7 <= 0;
        end else begin
            stage0_result1 <= cnt_load_imap_ic * basic_ic_add1;
            stage0_result2 <= cnt_load_imap_h * basic_oh_sy_add1 - top_padding_external;
            stage0_result3 <= cnt_dburst << $clog2(256 * BUS_WIDTH / 8) >> imap_offset_addr_shift;
            stage0_result4 <= cnt_dic << shift_value;
            stage0_result5 <= cnt_dih;
            stage0_result6 <= (currc + 1);
            stage0_result7 <= cnt_load_imap_w * basic_ow_sx_add1 - left_padding_external;

        end
    end

    // Stage 10
    reg [NUM_WIDTH+DIM_WIDTH+1-1:0] stage10_result1;
    reg [NUM_WIDTH+IMAP_DIM_WIDTH+1-1:0] stage10_result2;
    reg [C_WIDTH+1+AIW_WIDTH-1:0] stage10_result3;
    reg [BURST_NUM_WIDTH2-1:0] stage10_result4;
    reg [NUM_WIDTH+IMAP_DIM_WIDTH+C_WIDTH+1-1:0] stage10_result5;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage10_result1 <= 0;
            stage10_result2 <= 0;
            stage10_result3 <= 0;
            stage10_result4 <= 0;
            stage10_result5 <= 0;
        end else begin
            stage10_result1 <= (stage0_result1 + stage0_result4);
            stage10_result2 <= stage0_result2 + stage0_result5;
            stage10_result3 <= stage0_result6 * Aiw;
            stage10_result4 <= stage0_result3;
            stage10_result5 <= stage0_result7 * stage0_result6;
        end
    end

    // Stage 1

    reg [NUM_WIDTH+DIM_WIDTH+1+AIWIH_WIDTH-1:0] stage1_result1;
    reg [NUM_WIDTH+IMAP_DIM_WIDTH+1+C_WIDTH+1+AIW_WIDTH-1:0] stage1_result2;
    reg [BURST_NUM_WIDTH2-1:0] stage1_result3;
    reg [NUM_WIDTH+IMAP_DIM_WIDTH+C_WIDTH+1-1:0] stage1_result4;



    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage1_result1 <= 0;
            stage1_result2 <= 0;
            stage1_result3 <= 0;
            stage1_result4 <= 0;
        end else begin
            stage1_result1 <= stage10_result1 * Aiwih;
            stage1_result2 <= stage10_result2 * stage10_result3;
            stage1_result3 <= stage10_result4;
            stage1_result4 <= stage10_result5;
        end
    end

    // Stage 2
    reg [NUM_WIDTH+IMAP_DIM_WIDTH+1+AIWIH_WIDTH+1+4-1:0] stage2_result1;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage2_result1 <= 0;
        end else begin
            stage2_result1 <= (stage1_result1 + stage1_result2 + stage1_result3 + stage1_result4) << imap_offset_addr_shift;
        end
    end


    generate
        if (NUM_WIDTH + IMAP_DIM_WIDTH + 1 + AIWIH_WIDTH + 1 + 4 > BUS_ADDR_WIDTH) begin
            assign imap_offset_addr = stage2_result1[BUS_ADDR_WIDTH-1:0];
        end else begin
            assign imap_offset_addr = {
                {(BUS_ADDR_WIDTH - (NUM_WIDTH + IMAP_DIM_WIDTH + 1 + AIWIH_WIDTH + 1 + 4)) {1'b0}},
                stage2_result1[NUM_WIDTH+IMAP_DIM_WIDTH+1+AIWIH_WIDTH+1+4-1:0]
            };
        end
    endgenerate




endmodule
