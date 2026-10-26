






module weight_offset_addr_gen #(
    parameter NUM_WIDTH = 10,
    parameter DIM_WIDTH = 12,
    parameter BUS_ADDR_WIDTH = 32,
    parameter WICRS_WIDTH = 20,
    parameter WIC_WIDTH = 10,
    parameter BUS_WIDTH = 64,
    parameter CHANNEL_NUM = 16,
    parameter S_WIDTH = $clog2($clog2(CHANNEL_NUM * 2)) + 1,
    parameter C_WIDTH = $clog2(CHANNEL_NUM * 2),
    parameter BURST_NUM_WIDTH = 4

) (
    input wire clk,
    input wire rstn,
    input wire [S_WIDTH-1:0] shift_value,
    input wire [WICRS_WIDTH-1:0] Wicrs,
    input wire [WIC_WIDTH-1:0] Wic,
    input wire [DIM_WIDTH+1-1:0] basic_rs_add1,
    input wire [DIM_WIDTH+1-1:0] basic_ic_add1,
    input wire [DIM_WIDTH+1-1:0] basic_oc_add1,
    input wire [NUM_WIDTH-1:0] cnt_load_wei_rs,
    input wire [NUM_WIDTH-1:0] cnt_load_wei_ic,
    input wire [NUM_WIDTH-1:0] cnt_load_wei_oc,
    input wire [C_WIDTH-1:0] currc,
    input wire [BURST_NUM_WIDTH-1:0] cnt_dburst,
    input wire [DIM_WIDTH-1:0] cnt_drs,
    input wire [DIM_WIDTH-1:0] cnt_doc,
    input wire [1:0] weight_offset_addr_shift,
    output reg [BUS_ADDR_WIDTH-1:0] weight_offset_addr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         weight_offset_addr <= 0;
    //     end else begin

    // 2024.8.2 fix 突发长度可变
    //         weight_offset_addr <= (((cnt_load_wei_rs * (basic_rs+1) + cnt_drs) * Wocic)
    //                             + ((cnt_load_wei_ic * (basic_ic+1) * Woc + cnt_dic * woc )
    //                             + (cnt_load_wei_oc * (basic_oc+1))) << weight_offset_addr_shift ;

    //  weight_offset_addr <= (((cnt_load_wei_oc * (basic_oc+1) + cnt_doc << shift_value ) * Wicrs)
    //                             + ((cnt_load_wei_rs * (basic_rs+1) + cnt_drs) * (currc+1) * Wic)
    //                             + (cnt_load_wei_ic * (basic_ic+1) * (currc+1) )
    //                             + cnt_dburst * (256*BUS_WIDTH/8) >> weight_offset_addr_shift) << weight_offset_addr_shift ;

    //     end
    // end

    localparam BURST_NUM_WIDTH2 = BURST_NUM_WIDTH + $clog2((256 * BUS_WIDTH / 8));
    // Stage 0
    reg [NUM_WIDTH+DIM_WIDTH-1:0] stage0_result1;
    reg [NUM_WIDTH+DIM_WIDTH-1:0] stage0_result2;
    reg [BURST_NUM_WIDTH2-1:0] stage0_result3;
    reg [DIM_WIDTH-1:0] stage0_result4;
    reg [DIM_WIDTH-1:0] stage0_result5;
    reg [C_WIDTH+1-1:0] stage0_result6;
    reg [NUM_WIDTH+DIM_WIDTH-1:0] stage0_result7;

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
            stage0_result1 <= (cnt_load_wei_oc * (basic_oc_add1));
            stage0_result2 <= (cnt_load_wei_rs * (basic_rs_add1));
            stage0_result3 <= cnt_dburst << $clog2(256 * BUS_WIDTH / 8) >> weight_offset_addr_shift;
            stage0_result4 <= cnt_doc << shift_value;
            stage0_result5 <= cnt_drs;
            stage0_result6 <= (currc + 1);
            stage0_result7 <= (cnt_load_wei_ic * (basic_ic_add1));

        end
    end

    // Stage 10
    reg [NUM_WIDTH+DIM_WIDTH+1-1:0] stage10_result1;
    reg [NUM_WIDTH+DIM_WIDTH+1-1:0] stage10_result2;
    reg [C_WIDTH+1+WIC_WIDTH-1:0] stage10_result3;
    reg [BURST_NUM_WIDTH2-1:0] stage10_result4;
    reg [NUM_WIDTH+DIM_WIDTH+C_WIDTH+1-1:0] stage10_result5;
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
            stage10_result3 <= stage0_result6 * Wic;
            stage10_result4 <= stage0_result3;
            stage10_result5 <= stage0_result7 * stage0_result6;
        end
    end

    // Stage 1

    reg [NUM_WIDTH+DIM_WIDTH+1+WICRS_WIDTH-1:0] stage1_result1;
    reg [NUM_WIDTH+DIM_WIDTH+1+C_WIDTH+1+WIC_WIDTH-1:0] stage1_result2;
    reg [BURST_NUM_WIDTH2-1:0] stage1_result3;
    reg [NUM_WIDTH+DIM_WIDTH+C_WIDTH+1-1:0] stage1_result4;



    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage1_result1 <= 0;
            stage1_result2 <= 0;
            stage1_result3 <= 0;
            stage1_result4 <= 0;
        end else begin
            stage1_result1 <= stage10_result1 * Wicrs;
            stage1_result2 <= stage10_result2 * stage10_result3;
            stage1_result3 <= stage10_result4;
            stage1_result4 <= stage10_result5;
        end
    end

    // Stage 2
    reg [NUM_WIDTH+DIM_WIDTH+1+WICRS_WIDTH+1+4-1:0] stage2_result1;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage2_result1 <= 0;
        end else begin
            stage2_result1 <= (stage1_result1 + stage1_result2 + stage1_result3 + stage1_result4) << weight_offset_addr_shift;
        end
    end


    generate
        if (NUM_WIDTH + DIM_WIDTH + 1 + WICRS_WIDTH + 1 + 4 > BUS_ADDR_WIDTH) begin
            assign weight_offset_addr = stage2_result1[BUS_ADDR_WIDTH-1:0];
        end else begin
            assign weight_offset_addr = {
                {(BUS_ADDR_WIDTH - (NUM_WIDTH + DIM_WIDTH + 1 + WICRS_WIDTH + 1 + 4)) {1'b0}},
                stage2_result1[NUM_WIDTH+DIM_WIDTH+1+WICRS_WIDTH+1+4-1:0]
            };
        end
    endgenerate




endmodule
