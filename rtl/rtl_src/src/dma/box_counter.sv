


module box_counter_top #(
    parameter DIM_W_WIDTH   = 12,
    parameter DIM_H_WIDTH   = 12,
    parameter DIM_C_WIDTH   = 12,
    parameter PADDING_WIDTH = 5
) (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire en,
    input wire [DIM_C_WIDTH-1:0] box_c,
    input wire [DIM_W_WIDTH-1:0] box_w,  //整个padding后的box宽度
    input wire [DIM_W_WIDTH-1:0] box_h,  //整个padding后的box高度
    input wire [3:0] use_padding,
    input wire [PADDING_WIDTH-1:0] padding[3:0],
    output reg [DIM_C_WIDTH-1:0] cnt_box_c,
    output reg [DIM_W_WIDTH-1:0] cnt_box_w,  // box宽度方向计数器
    output reg [DIM_H_WIDTH-1:0] cnt_box_h  // box高方向计数器

);
    reg start_r;
    reg en_r;
    reg [DIM_C_WIDTH-1:0] box_c_r;
    reg [DIM_W_WIDTH-1:0] box_w_r;  //整个padding后的box宽度
    reg [DIM_W_WIDTH-1:0] box_h_r;  //整个padding后的box高度
    reg [3:0] use_padding_r;
    reg [PADDING_WIDTH-1:0] padding_r[3:0];
    reg [DIM_C_WIDTH-1:0] cnt_box_c_r;
    reg [DIM_W_WIDTH-1:0] cnt_box_w_r;  // box宽度方向计数器
    reg [DIM_H_WIDTH-1:0] cnt_box_h_r;  // box高方向计数器



    always @(posedge clk) begin
        start_r <= start;
        en_r <= en;
        box_c_r <= box_c;
        box_w_r <= box_w;  //整个padding后的box宽度
        box_h_r <= box_h;  //整个padding后的box高度
        use_padding_r <= use_padding;

        padding_r <= padding;

        cnt_box_c <= cnt_box_c_r;
        cnt_box_w <= cnt_box_w_r;  // box宽度方向计数器
        cnt_box_h <= cnt_box_h_r;  // box高方向计数器
    end
    box_counter #(
        .DIM_W_WIDTH  (DIM_W_WIDTH),
        .DIM_H_WIDTH  (DIM_H_WIDTH),
        .PADDING_WIDTH(PADDING_WIDTH)
    ) u_box_counter (
        .clk        (clk),
        .rstn       (rstn),
        .start      (start_r),
        .en         (en_r),
        .box_c      (box_c_r),
        .box_w      (box_w_r),
        .box_h      (box_h_r),
        .use_padding(use_padding_r),
        .padding    (padding_r),

        .cnt_box_c(cnt_box_c_r),
        .cnt_box_w(cnt_box_w_r),
        .cnt_box_h(cnt_box_h_r)
    );

endmodule


module box_counter #(
    parameter DIM_W_WIDTH   = 12,
    parameter DIM_H_WIDTH   = 12,
    parameter DIM_C_WIDTH   = 12,
    parameter PADDING_WIDTH = 3
) (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire en,
    input wire [DIM_C_WIDTH-1:0] box_c,  //(没有+1的)
    input wire [DIM_W_WIDTH-1:0] box_w,  //整个padding后的box宽度(+1的)
    input wire [DIM_W_WIDTH-1:0] box_h,  //整个padding后的box高度(+1的)
    input wire [3:0] use_padding,
    input wire [PADDING_WIDTH-1:0] padding[3:0],
    output reg [DIM_C_WIDTH-1:0] cnt_box_c,
    output reg [DIM_W_WIDTH-1:0] cnt_box_w,  // box宽度方向计数器
    output reg [DIM_H_WIDTH-1:0] cnt_box_h,  // box高方向计数器
    output reg cnt_valid,
    output wire padding_done_pulse
);
    wire use_top_padding;  //顶部是否使用padding
    wire use_bottom_padding;
    wire use_left_padding;
    wire use_right_padding;
    wire [PADDING_WIDTH-1:0] top_padding;  //顶部padding的数目
    wire [PADDING_WIDTH-1:0] bottom_padding;
    wire [PADDING_WIDTH-1:0] left_padding;
    wire [PADDING_WIDTH-1:0] right_padding;

    assign use_top_padding = use_padding[3];  //顶部是否使用padding
    assign use_bottom_padding = use_padding[2];
    assign use_left_padding = use_padding[1];
    assign use_right_padding = use_padding[0];
    assign top_padding = padding[3];  //顶部padding的数目
    assign bottom_padding = padding[2];
    assign left_padding = padding[1];
    assign right_padding = padding[0];



    localparam S_IDLE = 0, S_COUNT = 1;

    reg done_pulse;
    reg start_true;
    reg curr_state, next_state;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            curr_state <= S_IDLE;
        end else begin
            curr_state <= next_state;
        end
    end

    always @(*) begin
        begin
            case (curr_state)
                S_IDLE: begin
                    if (start_true) begin
                        next_state = S_COUNT;
                    end else begin
                        next_state = S_IDLE;
                    end
                end
                S_COUNT: begin
                    if (done_pulse) begin
                        next_state = S_IDLE;
                    end else begin
                        next_state = S_COUNT;
                    end
                end
                default: begin
                    next_state = S_IDLE;
                end
            endcase
        end
    end



    wire cnt_box_w_equ_box_w = cnt_box_w == box_w;
    wire cnt_box_h_equ_box_h = cnt_box_h == box_h;
    assign start_true = start && (use_top_padding|| use_bottom_padding|| use_left_padding|| use_right_padding);
    assign done_pulse = (~start_true & start) || ((curr_state==S_COUNT) & (cnt_box_c == box_c) & 
                        ( ((~(~use_bottom_padding & use_left_padding & ~use_right_padding)) && (cnt_box_w_equ_box_w && cnt_box_h_equ_box_h))
                        || ((~use_bottom_padding & use_left_padding & ~use_right_padding) && (cnt_box_w == left_padding && cnt_box_h_equ_box_h))
                        || ((use_top_padding & ~use_bottom_padding & ~use_left_padding & ~use_right_padding) && (cnt_box_w_equ_box_w && cnt_box_h == top_padding))
                        ))  ;
    assign padding_done_pulse = done_pulse;
    wire done_pulse1 = ((~(~use_bottom_padding & use_left_padding & ~use_right_padding)) && (cnt_box_w_equ_box_w && cnt_box_h_equ_box_h));
    wire done_pulse2 = (( ~use_bottom_padding & use_left_padding & ~use_right_padding) && (cnt_box_w == left_padding && cnt_box_h_equ_box_h));
    wire done_pulse3 = ((use_top_padding & ~use_bottom_padding & ~use_left_padding & ~use_right_padding) && (cnt_box_w_equ_box_w && cnt_box_h == top_padding));


    wire en_true = en & (curr_state == S_COUNT)
                    & ((use_top_padding & top_padding != 0) || (~use_top_padding & top_padding == 0)) 
                    & ((use_bottom_padding & bottom_padding != 0) || (~use_bottom_padding & bottom_padding == 0))
                    & ((use_left_padding & left_padding != 0) || (~use_left_padding & left_padding == 0))
                    & ((use_right_padding & right_padding != 0) || ((~use_right_padding & right_padding == 0)));
    reg en_true_ff;
    assign cnt_valid = (cnt_box_w != 0) && (cnt_box_h != 0) && en_true_ff;



    wire tpbp_between_flag1 = (use_top_padding & (cnt_box_h <= top_padding))|| (use_bottom_padding & (cnt_box_h >= (box_h - (bottom_padding-1))));

    wire [DIM_W_WIDTH-1:0] box_w_sub_right_padding = box_w - (right_padding - 1);
    wire [DIM_W_WIDTH-1:0] box_h_sub_bottom_padding = box_h - (bottom_padding - 1);
    wire [DIM_W_WIDTH-1:0] cnt_box_w_add_1 = cnt_box_w + 1;
    wire [DIM_W_WIDTH-1:0] cnt_box_h_add_1 = cnt_box_h + 1;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt_box_c <= 0;
        end else if (done_pulse) begin
            cnt_box_c <= 0;
        end else if (en_true) begin
            if (cnt_box_c == box_c) begin
                cnt_box_c <= 0;
            end else begin
                cnt_box_c <= cnt_box_c + 1;
            end
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            en_true_ff <= 0;
        end else begin
            en_true_ff <= en_true;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt_box_w <= 0;
            cnt_box_h <= 0;
        end else if (done_pulse) begin
            cnt_box_w <= 0;
            cnt_box_h <= 0;
        end else if (en_true & cnt_box_c == box_c) begin
            if (use_left_padding) begin
                if (cnt_box_w < left_padding) begin
                    cnt_box_w <= cnt_box_w_add_1;
                end else if (cnt_box_w == left_padding) begin
                    if (tpbp_between_flag1) begin
                        if (cnt_box_w_equ_box_w) begin
                            cnt_box_w <= 1;
                        end else begin
                            cnt_box_w <= cnt_box_w_add_1;
                        end
                    end else begin
                        if (use_right_padding) begin
                            cnt_box_w <= box_w_sub_right_padding;
                        end else begin
                            cnt_box_w <= 1;
                        end
                    end
                end else if (cnt_box_w > left_padding && cnt_box_w < box_w_sub_right_padding) begin
                    if (tpbp_between_flag1) begin
                        if (cnt_box_w_equ_box_w) begin
                            cnt_box_w <= 1;
                        end else begin
                            cnt_box_w <= cnt_box_w_add_1;
                        end
                    end else begin
                        if (cnt_box_w_equ_box_w) begin
                            cnt_box_w <= 1;
                        end else begin
                            cnt_box_w <= cnt_box_w_add_1;
                        end
                    end
                end else if (cnt_box_w == box_w_sub_right_padding) begin
                    if (tpbp_between_flag1) begin
                        if (use_right_padding) begin
                            if (cnt_box_w_equ_box_w) begin
                                cnt_box_w <= 1;
                            end else begin
                                cnt_box_w <= cnt_box_w_add_1;
                            end
                        end else begin
                            if (cnt_box_w_equ_box_w) begin
                                cnt_box_w <= 1;
                            end else begin
                                cnt_box_w <= cnt_box_w_add_1;
                            end
                        end
                    end else begin
                        if (use_right_padding) begin
                            if (cnt_box_w_equ_box_w) begin
                                cnt_box_w <= 1;
                            end else begin
                                cnt_box_w <= cnt_box_w_add_1;
                            end
                        end else begin
                            cnt_box_w <= 1;
                        end
                    end
                end else if (cnt_box_w < box_w) begin
                    if (tpbp_between_flag1) begin
                        if (use_right_padding) begin
                            if (cnt_box_w_equ_box_w) begin
                                cnt_box_w <= 1;
                            end else begin
                                cnt_box_w <= cnt_box_w_add_1;
                            end
                        end else begin
                            if (cnt_box_w_equ_box_w) begin
                                cnt_box_w <= 1;
                            end else begin
                                cnt_box_w <= cnt_box_w_add_1;
                            end
                        end
                    end else begin
                        if (use_right_padding) begin
                            if (cnt_box_w_equ_box_w) begin
                                cnt_box_w <= 1;
                            end else begin
                                cnt_box_w <= cnt_box_w_add_1;
                            end
                        end else begin
                            cnt_box_w <= 1;
                        end
                    end
                end else if (cnt_box_w_equ_box_w) begin
                    cnt_box_w <= 1;
                end else begin
                    cnt_box_w <= 1;
                end
            end else begin
                if (use_right_padding) begin
                    if (tpbp_between_flag1) begin
                        if (cnt_box_w_equ_box_w) begin
                            if ((use_top_padding & (cnt_box_h == top_padding))) begin
                                cnt_box_w <= box_w - (right_padding - 1);
                            end else begin
                                cnt_box_w <= 1;
                            end
                        end else begin
                            if (~use_top_padding) begin
                                if (cnt_box_w == 0) begin
                                    cnt_box_w <= box_w_sub_right_padding;
                                end else if (cnt_box_w_equ_box_w) begin
                                    cnt_box_w <= box_w_sub_right_padding;
                                end else begin
                                    cnt_box_w <= cnt_box_w_add_1;
                                end
                            end else begin
                                if (cnt_box_w_equ_box_w) begin
                                    cnt_box_w <= 1;
                                end else begin
                                    cnt_box_w <= cnt_box_w_add_1;
                                end
                            end
                        end
                    end else begin
                        if (cnt_box_w == 0) begin
                            cnt_box_w <= box_w_sub_right_padding;
                        end else if (cnt_box_w_equ_box_w) begin
                            if((use_bottom_padding & (cnt_box_h == (box_h - bottom_padding)))) begin
                                cnt_box_w <= 1;
                            end else begin
                                cnt_box_w <= box_w_sub_right_padding;
                            end
                        end else begin
                            cnt_box_w <= cnt_box_w_add_1;
                        end
                    end
                end else begin
                    if (cnt_box_w == 0) begin
                        cnt_box_w <= 1;
                    end else if (tpbp_between_flag1) begin
                        if (cnt_box_w_equ_box_w) begin
                            cnt_box_w <= 1;
                        end else begin
                            cnt_box_w <= cnt_box_w_add_1;
                        end
                    end else begin
                        cnt_box_w <= 0;
                    end
                end
            end

            if (cnt_box_h == 0 && (~(use_bottom_padding & ~use_top_padding & ~use_left_padding & ~use_right_padding))) begin
                cnt_box_h <= 1;
            end else if (use_left_padding || use_right_padding) begin
                if (use_left_padding & (~use_right_padding)) begin
                    if (cnt_box_w == left_padding && (~tpbp_between_flag1)) begin
                        cnt_box_h <= cnt_box_h_add_1;
                    end else if (cnt_box_w_equ_box_w) begin
                        if (cnt_box_h_equ_box_h) begin
                            cnt_box_h <= 1;
                        end else begin
                            cnt_box_h <= cnt_box_h_add_1;
                        end
                    end
                end else begin
                    if (cnt_box_w_equ_box_w) begin
                        if (cnt_box_h_equ_box_h) begin
                            cnt_box_h <= 1;
                        end else begin
                            cnt_box_h <= cnt_box_h_add_1;
                        end
                    end
                end
            end else begin
                if (use_top_padding) begin
                    if (cnt_box_h == top_padding) begin
                        if (use_bottom_padding) begin
                            if (cnt_box_w_equ_box_w) begin
                                cnt_box_h <= box_h_sub_bottom_padding;
                            end
                        end else begin
                            if (cnt_box_w_equ_box_w) begin
                                if (cnt_box_h == top_padding) begin
                                    cnt_box_h <= 0;
                                end else begin
                                    cnt_box_h <= cnt_box_h_add_1;
                                end
                            end
                        end
                    end else begin
                        if (use_bottom_padding) begin
                            if (cnt_box_w_equ_box_w) begin
                                if (cnt_box_h_equ_box_h) begin
                                    cnt_box_h <= 1;
                                end else begin
                                    cnt_box_h <= cnt_box_h_add_1;
                                end
                            end
                        end else begin
                            if (cnt_box_w_equ_box_w) begin
                                if (cnt_box_h == top_padding) begin
                                    cnt_box_h <= 0;
                                end else begin
                                    cnt_box_h <= cnt_box_h_add_1;
                                end
                            end

                        end
                    end
                end else begin
                    if (use_bottom_padding) begin
                        if (cnt_box_h == 0) begin
                            cnt_box_h <= box_h_sub_bottom_padding;
                        end else if (cnt_box_w_equ_box_w) begin
                            if (cnt_box_h_equ_box_h) begin
                                cnt_box_h <= 0;
                            end else begin
                                cnt_box_h <= cnt_box_h_add_1;
                            end
                        end
                    end else begin
                        cnt_box_h <= 0;
                    end
                end
            end

        end
    end


endmodule
