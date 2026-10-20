

module L1_imap_raddr_gen #(
    parameter IMAP_RAM_ADDR_WIDTH = 12,
    parameter DIM_WIDTH = 8,
    parameter CNT_IC_WIDTH = 6,
    parameter IMAP_DIM_WIDTH = 10,
    parameter STRIDE_X_WIDTH = 2,
    parameter STRIDE_Y_WIDTH = 2,
    parameter DILATION_X_WIDTH = 2,
    parameter DILATION_Y_WIDTH = 2,
    parameter WIN_R_WIDTH = 2,
    parameter WIN_S_WIDTH = 2
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire is_int16,
    input wire is_stc,
    input wire [IMAP_DIM_WIDTH-1:0] L1_block_len_iwih_border[3:0],  // 0-3 right|left|bottom|top
    input wire [CNT_IC_WIDTH-1:0] cnt_ri_block_len_ic_fea,
    input wire [DIM_WIDTH-1:0] cnt_ri_block_ind_ow,
    input wire [DIM_WIDTH-1:0] cnt_ri_block_ind_oh,
    input wire [WIN_S_WIDTH-1:0] cnt_ri_total_ind_s,
    input wire [WIN_R_WIDTH-1:0] cnt_ri_total_ind_r,

    input wire [IMAP_DIM_WIDTH*2-1:0] block_len_iwh,
    input wire [  IMAP_DIM_WIDTH-1:0] block_len_iw,
    input wire [  STRIDE_X_WIDTH-1:0] stride_x,
    input wire [  STRIDE_Y_WIDTH-1:0] stride_y,
    input wire [DILATION_X_WIDTH-1:0] dilation_x,
    input wire [DILATION_Y_WIDTH-1:0] dilation_y,

    output reg [IMAP_RAM_ADDR_WIDTH-1:0] imap_raddr,
    output reg cnt_ri_block_len_ic_fea_0_r,
    output reg is_padding
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         imap_addr <= 0;
    //     end else if (is_ri_feature_load_ing) begin
    //         imap_addr <= (is_int16?cnt_ri_block_len_ic_fea:cnt_ri_block_len_ic_fea>>1)*(block_len_iwh+1)+
    //                         (cnt_ri_block_ind_ow*(stride_x)+cnt_ri_total_ind_s*(dilation_x)
    //                         +(cnt_ri_block_ind_oh*(stride_y)+cnt_ri_total_ind_r*(dilation_y+1))*(block_len_iw+1));
    //     end else begin
    //         imap_addr <= 0;
    //     end
    // end


    reg [CNT_IC_WIDTH+IMAP_DIM_WIDTH*2+1-1:0] stage0_result1;
    reg [DIM_WIDTH+STRIDE_X_WIDTH+1-1:0] stage0_result2;
    reg [DIM_WIDTH+STRIDE_Y_WIDTH+1-1:0] stage0_result3;
    reg cnt_ri_block_len_ic_fea_0_w1;
    reg en_ff;
    reg en_ff2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage0_result1 <= 0;
            stage0_result2 <= 0;
            stage0_result3 <= 0;
            cnt_ri_block_len_ic_fea_0_w1 <= 0;
        end else if (en) begin
            // stage0_result1 <= cnt_ri_block_len_ic_fea * (block_len_iwh + 1);
            // stage0_result2 <= cnt_ri_block_ind_ow*(stride_x+1)+cnt_ri_total_ind_s*(dilation_x+1);
            // stage0_result3 <= cnt_ri_block_ind_oh*(stride_y+1)+cnt_ri_total_ind_r*(dilation_y+1);

            // 标准卷积ic除以2，其他情况不除
            stage0_result1 <= ((is_int16|(~is_stc)) ? cnt_ri_block_len_ic_fea : (cnt_ri_block_len_ic_fea>>1)) * (block_len_iwh);  //这里不加1
            stage0_result2 <= cnt_ri_block_ind_ow*(stride_x)+cnt_ri_total_ind_s*(dilation_x);//这里不加1
            stage0_result3 <= cnt_ri_block_ind_oh*(stride_y)+cnt_ri_total_ind_r*(dilation_y);//这里不加1
            cnt_ri_block_len_ic_fea_0_w1 <= cnt_ri_block_len_ic_fea[0];
        end
    end
    // input wire [IMAP_DIM_WIDTH-1:0] L1_block_len_iwih_border[3:0],  // 0-3 right|left|bottom|top
    wire is_padding_w;
    assign is_padding_w = stage0_result2 < L1_block_len_iwih_border[1] || stage0_result2 > L1_block_len_iwih_border[0] 
                            || stage0_result3 < L1_block_len_iwih_border[3] ||stage0_result3 > L1_block_len_iwih_border[2];

    reg is_padding_w_ff1;
    reg is_padding_w_ff2;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_padding_w_ff1 <= 0;
            is_padding_w_ff2 <= 0;
        end else begin
            is_padding_w_ff1 <= is_padding_w;
            is_padding_w_ff2 <= is_padding_w_ff1;
        end
    end
    assign is_padding = is_padding_w_ff2;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            en_ff  <= 0;
            en_ff2 <= 0;
        end else begin
            en_ff  <= en;
            en_ff2 <= en_ff;
        end
    end

    reg [CNT_IC_WIDTH+IMAP_DIM_WIDTH*2+1+1-1:0] stage1_result1;
    reg [DIM_WIDTH+STRIDE_Y_WIDTH+IMAP_DIM_WIDTH+1-1:0] stage1_result2;
    reg cnt_ri_block_len_ic_fea_0_w2;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage1_result1 <= 0;
            stage1_result2 <= 0;
            cnt_ri_block_len_ic_fea_0_w2 <= 0;
        end else if (en_ff) begin
            stage1_result1 <= stage0_result1 + stage0_result2;
            stage1_result2 <= stage0_result3 * (block_len_iw + 1);
            cnt_ri_block_len_ic_fea_0_w2 <= cnt_ri_block_len_ic_fea_0_w1;
        end
    end

    reg [DIM_WIDTH+IMAP_DIM_WIDTH*2+1+1+1-1:0] stage2_result1;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage2_result1 <= 0;
            cnt_ri_block_len_ic_fea_0_r <= 0;
        end else if (en_ff2) begin
            stage2_result1 <= stage1_result1 + stage1_result2;
            cnt_ri_block_len_ic_fea_0_r <= cnt_ri_block_len_ic_fea_0_w2;
        end
    end


    generate
        if (DIM_WIDTH + IMAP_DIM_WIDTH * 2 + 1 + 1 + 1 > (IMAP_RAM_ADDR_WIDTH)) begin
            assign imap_raddr = stage2_result1[IMAP_RAM_ADDR_WIDTH-1:0];
        end else begin
            assign imap_raddr = {
                {((IMAP_RAM_ADDR_WIDTH) - (DIM_WIDTH + IMAP_DIM_WIDTH * 2 + 1 + 1 + 1)) {1'b0}},
                stage2_result1[DIM_WIDTH+IMAP_DIM_WIDTH*2+1+1+1-1:0]
            };
        end
    endgenerate


endmodule
