// module L2toL1_pe_param_reg #(
//     parameter DIM_WIDTH = 10,
//     parameter IMAP_DIM_WIDTH = 12,
//     parameter WIN_R_WIDTH = 2,
//     parameter WIN_S_WIDTH = 2,
//     parameter STRIDE_X_WIDTH = 1,
//     parameter STRIDE_Y_WIDTH = 1,
//     parameter DILATION_X_WIDTH = 1,
//     parameter DILATION_Y_WIDTH = 1
// ) (
//     input wire clk,
//     input wire rstn,
//     input wire is_cnt_cal_ic_end,
//     input wire is_cnt_cal_oc_end,
//     input wire is_cnt_cal_rs_end,
//     input wire is_cnt_cal_w_end,
//     input wire is_cnt_cal_h_end,



//     input wire [DIM_WIDTH-1:0] basic_ow,  // 输出特征图块宽度
//     input wire [DIM_WIDTH-1:0] basic_oh,  // 输出特征图块高度
//     input wire [DIM_WIDTH-1:0] basic_oc,  // 需要是4的倍数
//     input wire [DIM_WIDTH-1:0] basic_ic,  // 需要是4的倍数
//     input wire [DIM_WIDTH-1:0] basic_rs,

//     input wire [IMAP_DIM_WIDTH-1:0] basic_iw,
//     input wire [IMAP_DIM_WIDTH-1:0] basic_ih,

//     input wire [DIM_WIDTH-1:0] remain_ow,  // 输出特征图块宽度
//     input wire [DIM_WIDTH-1:0] remain_oh,  // 输出特征图块高度
//     input wire [DIM_WIDTH-1:0] remain_oc,
//     input wire [DIM_WIDTH-1:0] remain_ic,
//     input wire [DIM_WIDTH-1:0] remain_rs,

//     input wire [IMAP_DIM_WIDTH-1:0] remain_iw,
//     input wire [IMAP_DIM_WIDTH-1:0] remain_ih,


//     input wire L2_pe_array_start,
//     input wire L2_total_rs_start,
//     input wire L2_total_rs_done,
//     input wire L2_use_bias_internal,
//     input wire L2_bias_mode_internal,
//     input wire L2_use_quan_internal,

//     output reg [DIM_WIDTH*2-1:0] L1_block_len_owh,  // 输出特征图平铺长度
//     output reg [DIM_WIDTH-1:0] L1_block_len_ic,  // 输入通道平铺长度
//     output reg [DIM_WIDTH-1:0] L1_block_len_oc,  //输出通道平铺长度
//     output reg [WIN_R_WIDTH*WIN_S_WIDTH-1:0] L1_block_len_rs,  //窗口平铺长度

//     output reg [IMAP_DIM_WIDTH*2-1:0] L1_block_len_iwh,  // 输入特征图平铺长度
//     output reg [IMAP_DIM_WIDTH-1:0] L1_block_len_iw,  // 输入特征图块宽度
//     output reg [IMAP_DIM_WIDTH-1:0] L1_block_len_ih,  // 输入特征图块高度
//     output reg [DIM_WIDTH-1:0] L1_block_len_ow,  // 输出特征图块宽度
//     output reg [DIM_WIDTH-1:0] L1_block_len_oh,  // 输出特征图块高度

//     output wire L1_pe_array_start,
//     output wire L1_total_rs_start,
//     output wire L1_total_rs_done,
//     output wire L1_use_bias_internal,
//     output wire L1_bias_mode_internal,
//     output wire L1_use_quan_internal
// );
//     localparam DELAY = 2;
//     reg [DELAY-1:0] pe_array_start;
//     reg [DELAY-1:0] total_rs_start;
//     reg [DELAY-1:0] total_rs_done;
//     reg [DELAY-1:0] use_bias_internal;
//     reg [DELAY-1:0] bias_mode_internal;
//     reg [DELAY-1:0] use_quan_internal;
//     always @(posedge clk) begin
//         for (int i = 0; i < DELAY - 1; i = i + 1) begin
//             pe_array_start[i+1] <= pe_array_start[i];
//             total_rs_start[i+1] <= total_rs_start[i];
//             total_rs_done[i+1] <= total_rs_done[i];
//             use_bias_internal[i+1] <= use_bias_internal[i];
//             bias_mode_internal[i+1] <= bias_mode_internal[i];
//             use_quan_internal[i+1] <= use_quan_internal[i];
//         end
//         pe_array_start[0] <= L2_pe_array_start;
//         total_rs_start[0] <= L2_total_rs_start;
//         total_rs_done[0] <= L2_total_rs_done;
//         use_bias_internal[0] <= L2_use_bias_internal;
//         bias_mode_internal[0] <= L2_bias_mode_internal;
//         use_quan_internal[0] <= L2_use_quan_internal;
//     end

//     assign L1_pe_array_start = pe_array_start[DELAY-1];
//     assign L1_total_rs_start = total_rs_start[DELAY-1];
//     assign L1_total_rs_done = total_rs_done[DELAY-1];
//     assign L1_use_bias_internal = use_bias_internal[DELAY-1];
//     assign L1_bias_mode_internal = bias_mode_internal[DELAY-1];
//     assign L1_use_quan_internal = use_quan_internal[DELAY-1];

//     reg [DIM_WIDTH-1:0] L1_block_len_ic_ff1;
//     reg [DIM_WIDTH-1:0] L1_block_len_oc_ff1;
//     reg [WIN_R_WIDTH*WIN_S_WIDTH-1:0] L1_block_len_rs_ff1;
//     reg [DIM_WIDTH+1-1:0] L1_block_len_ow_ff1;
//     reg [DIM_WIDTH+1-1:0] L1_block_len_oh_ff1;

//     reg [IMAP_DIM_WIDTH+1-1:0] L1_block_len_iw_ff1;
//     reg [IMAP_DIM_WIDTH+1-1:0] L1_block_len_ih_ff1;

//     always @(posedge clk) begin
//         L1_block_len_ic_ff1 <= is_cnt_cal_ic_end ? remain_ic : basic_ic;
//         L1_block_len_oc_ff1 <= is_cnt_cal_oc_end ? remain_oc : basic_oc;
//         L1_block_len_rs_ff1 <= is_cnt_cal_rs_end ? remain_rs : basic_rs;
//         L1_block_len_ow_ff1 <= (is_cnt_cal_w_end ? remain_ow : basic_ow) + 1;
//         L1_block_len_oh_ff1 <= (is_cnt_cal_h_end ? remain_oh : basic_oh) + 1;
//         L1_block_len_iw_ff1 <= (is_cnt_cal_w_end ? remain_iw : basic_iw) + 1;
//         L1_block_len_ih_ff1 <= (is_cnt_cal_h_end ? remain_ih : basic_ih) + 1;
//     end



//     always @(posedge clk) begin
//         L1_block_len_owh <= L1_block_len_ow_ff1 * L1_block_len_oh_ff1 - 1;
//         L1_block_len_iwh <= L1_block_len_iw_ff1 * L1_block_len_ih_ff1 ;//这里不减去1，L1_control里面不加1
//         L1_block_len_ic <= L1_block_len_ic_ff1;
//         L1_block_len_oc <= L1_block_len_oc_ff1;
//         L1_block_len_rs <= L1_block_len_rs_ff1;
//         L1_block_len_ow <= L1_block_len_ow_ff1 - 1;
//         L1_block_len_oh <= L1_block_len_oh_ff1 - 1;
//         L1_block_len_iw <= L1_block_len_iw_ff1 - 1;
//         L1_block_len_ih <= L1_block_len_ih_ff1 - 1;
//     end






// endmodule



module L2toL1_pe_param_reg #(
    parameter NUM_WIDTH = 10,
    parameter DIM_WIDTH = 10,
    parameter IMAP_DIM_WIDTH = 12,
    parameter WIN_R_WIDTH = 2,
    parameter WIN_S_WIDTH = 2,
    parameter STRIDE_X_WIDTH = 1,
    parameter STRIDE_Y_WIDTH = 1,
    parameter DILATION_X_WIDTH = 1,
    parameter DILATION_Y_WIDTH = 1,
    parameter PADDING_WIDTH = 5
) (
    input wire clk,
    input wire rstn,

    input wire [NUM_WIDTH-1:0] cnt_cal_w,
    input wire [NUM_WIDTH-1:0] cnt_cal_h,
    input wire [NUM_WIDTH-1:0] cnt_cal_oc,
    input wire [NUM_WIDTH-1:0] cnt_cal_ic,
    input wire [NUM_WIDTH-1:0] cnt_cal_rs,

    input wire is_cnt_cal_ic_end,
    input wire is_cnt_cal_oc_end,
    input wire is_cnt_cal_rs_end,
    input wire is_cnt_cal_w_end,
    input wire is_cnt_cal_h_end,



    input wire [DIM_WIDTH-1:0] basic_ow,  // 输出特征图块宽度
    input wire [DIM_WIDTH-1:0] basic_oh,  // 输出特征图块高度
    input wire [DIM_WIDTH-1:0] basic_oc,  // 需要是4的倍数
    input wire [DIM_WIDTH-1:0] basic_ic,  // 需要是4的倍数
    input wire [DIM_WIDTH-1:0] basic_rs,

    input wire [IMAP_DIM_WIDTH-1:0] basic_iw,
    input wire [IMAP_DIM_WIDTH-1:0] basic_ih,

    input wire [DIM_WIDTH-1:0] remain_ow,  // 输出特征图块宽度
    input wire [DIM_WIDTH-1:0] remain_oh,  // 输出特征图块高度
    input wire [DIM_WIDTH-1:0] remain_oc,
    input wire [DIM_WIDTH-1:0] remain_ic,
    input wire [DIM_WIDTH-1:0] remain_rs,

    input wire [IMAP_DIM_WIDTH-1:0] remain_iw,
    input wire [IMAP_DIM_WIDTH-1:0] remain_ih,


    input wire L2_pe_array_start,
    input wire L2_total_rs_start,
    input wire L2_total_rs_done,
    input wire L2_use_bias_internal,
    input wire L2_bias_mode_internal,
    input wire L2_use_quan_internal,
    input wire [3:0] use_padding_external,
    input wire [PADDING_WIDTH-1:0] padding_external[3:0],

    output reg [DIM_WIDTH*2-1:0] L1_block_len_owh,  // 输出特征图平铺长度
    output reg [DIM_WIDTH-1:0] L1_block_len_ic,  // 输入通道平铺长度
    output reg [DIM_WIDTH-1:0] L1_block_len_oc,  //输出通道平铺长度
    output reg [WIN_R_WIDTH*WIN_S_WIDTH-1:0] L1_block_len_rs,  //窗口平铺长度

    output reg [IMAP_DIM_WIDTH*2-1:0] L1_block_len_iwh,  // 输入特征图平铺长度
    output reg [IMAP_DIM_WIDTH-1:0] L1_block_len_iw,  // 输入特征图块宽度
    output reg [IMAP_DIM_WIDTH-1:0] L1_block_len_ih,  // 输入特征图块高度
    output reg [DIM_WIDTH-1:0] L1_block_len_ow,  // 输出特征图块宽度
    output reg [DIM_WIDTH-1:0] L1_block_len_oh,  // 输出特征图块高度
    output reg [IMAP_DIM_WIDTH-1:0] L1_block_len_iwih_border[3:0],  // 0-3 right|left|bottom|top

    output wire L1_pe_array_start,
    output wire L1_total_rs_start,
    output wire L1_total_rs_done,
    output wire L1_use_bias_internal,
    output wire L1_bias_mode_internal,
    output wire L1_use_quan_internal
);
    localparam DELAY = 2;
    reg [DELAY-1:0] pe_array_start;
    reg [DELAY-1:0] total_rs_start;
    reg [DELAY-1:0] total_rs_done;
    reg [DELAY-1:0] use_bias_internal;
    reg [DELAY-1:0] bias_mode_internal;
    reg [DELAY-1:0] use_quan_internal;
    always @(posedge clk) begin
        for (int i = 0; i < DELAY - 1; i = i + 1) begin
            pe_array_start[i+1] <= pe_array_start[i];
            total_rs_start[i+1] <= total_rs_start[i];
            total_rs_done[i+1] <= total_rs_done[i];
            use_bias_internal[i+1] <= use_bias_internal[i];
            bias_mode_internal[i+1] <= bias_mode_internal[i];
            use_quan_internal[i+1] <= use_quan_internal[i];
        end
        pe_array_start[0] <= L2_pe_array_start;
        total_rs_start[0] <= L2_total_rs_start;
        total_rs_done[0] <= L2_total_rs_done;
        use_bias_internal[0] <= L2_use_bias_internal;
        bias_mode_internal[0] <= L2_bias_mode_internal;
        use_quan_internal[0] <= L2_use_quan_internal;
    end

    assign L1_pe_array_start = pe_array_start[DELAY-1];
    assign L1_total_rs_start = total_rs_start[DELAY-1];
    assign L1_total_rs_done = total_rs_done[DELAY-1];
    assign L1_use_bias_internal = use_bias_internal[DELAY-1];
    assign L1_bias_mode_internal = bias_mode_internal[DELAY-1];
    assign L1_use_quan_internal = use_quan_internal[DELAY-1];

    reg [DIM_WIDTH-1:0] L1_block_len_ic_ff1;
    reg [DIM_WIDTH-1:0] L1_block_len_oc_ff1;
    reg [WIN_R_WIDTH*WIN_S_WIDTH-1:0] L1_block_len_rs_ff1;
    reg [DIM_WIDTH+1-1:0] L1_block_len_ow_ff1;
    reg [DIM_WIDTH+1-1:0] L1_block_len_oh_ff1;

    reg [IMAP_DIM_WIDTH+1-1:0] L1_block_len_iw_ff1;
    reg [IMAP_DIM_WIDTH+1-1:0] L1_block_len_ih_ff1;

    always @(posedge clk) begin
        L1_block_len_ic_ff1 <= is_cnt_cal_ic_end ? remain_ic : basic_ic;
        L1_block_len_oc_ff1 <= is_cnt_cal_oc_end ? remain_oc : basic_oc;
        L1_block_len_rs_ff1 <= is_cnt_cal_rs_end ? remain_rs : basic_rs;
        L1_block_len_ow_ff1 <= (is_cnt_cal_w_end ? remain_ow : basic_ow) + 1;
        L1_block_len_oh_ff1 <= (is_cnt_cal_h_end ? remain_oh : basic_oh) + 1;
        L1_block_len_iw_ff1 <= (is_cnt_cal_w_end ? remain_iw : basic_iw) + 1;
        L1_block_len_ih_ff1 <= (is_cnt_cal_h_end ? remain_ih : basic_ih) + 1;
    end

    wire [3:0] padding_flag = {cnt_cal_h == 0, is_cnt_cal_h_end, cnt_cal_w == 0, is_cnt_cal_w_end};
    reg [PADDING_WIDTH-1:0] padding_internal[3:0];  // 0-3 right|left|bottom|top
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (int i = 0; i < 4; i = i + 1) begin
                padding_internal[i] <= 0;
            end
        end else begin
            for (int i = 0; i < 4; i = i + 1) begin
                padding_internal[i] <=  (padding_flag[i] ? use_padding_external[i] : 0) ? padding_external[i] : 0;
            end
        end
    end



    always @(posedge clk) begin
        L1_block_len_iwih_border[0] <= L1_block_len_iw_ff1 - 1 - padding_internal[0];//right border
        L1_block_len_iwih_border[1] <= padding_internal[1];  //left border
        L1_block_len_iwih_border[2] <= L1_block_len_ih_ff1 - 1 - padding_internal[2];//bottom border
        L1_block_len_iwih_border[3] <= padding_internal[3];  //top border
    end



    always @(posedge clk) begin
        L1_block_len_owh <= L1_block_len_ow_ff1 * L1_block_len_oh_ff1 - 1;
        L1_block_len_iwh <= L1_block_len_iw_ff1 * L1_block_len_ih_ff1 ;//这里不减去1，L1_control里面不加1
        L1_block_len_ic <= L1_block_len_ic_ff1;
        L1_block_len_oc <= L1_block_len_oc_ff1;
        L1_block_len_rs <= L1_block_len_rs_ff1;
        L1_block_len_ow <= L1_block_len_ow_ff1 - 1;
        L1_block_len_oh <= L1_block_len_oh_ff1 - 1;
        L1_block_len_iw <= L1_block_len_iw_ff1 - 1;
        L1_block_len_ih <= L1_block_len_ih_ff1 - 1;
    end






endmodule
