module control_signal_delay #(
    parameter GEMM_MAC_ROW_NUM = 16,
    parameter GEMM_MAC_COL_NUM = 16,
    parameter BIAS_RAM_ADDR_WIDTH = 10,
    parameter SEL_WIDTH = $clog2(GEMM_MAC_ROW_NUM),
    parameter READ_DELAY_N = 5,  //读取ram的延迟
    parameter CAL_DELAY_M = $clog2(GEMM_MAC_ROW_NUM) + 2,  //计算阵列的延迟
    parameter NUM_DELAY_HEADS = 3,  // 延迟头的数量
    parameter CAL_DELAY_STC = $clog2(GEMM_MAC_ROW_NUM) + 2,
    parameter CAL_DELAY_DWC = 2,
    parameter CAL_DELAY_POOL = 1,
    parameter MAX_CAL_DELAY_M = CAL_DELAY_STC,
    parameter DELAY_SEL_WIDTH = $clog2(NUM_DELAY_HEADS)
) (
    input wire clk,
    input wire rstn,
    input wire [DELAY_SEL_WIDTH-1:0] sel,  // 用于选择实际的CAL_DELAY_M

    input  wire is_ri_feature_write_start_pulse,
    output wire is_ro_feature_write_start_pulse,  // delay N

    input  wire [SEL_WIDTH-1:0] mat_weight_in_ri_row_sel,
    output wire [SEL_WIDTH-1:0] mat_weight_in_ro_row_sel,  // delay N

    input wire [BIAS_RAM_ADDR_WIDTH-1:0] bias_acci_addr,
    input wire [GEMM_MAC_COL_NUM-1:0] bias_acci_ren,
    output wire [BIAS_RAM_ADDR_WIDTH-1:0] bias_acco_addr,  // delay M
    output wire [GEMM_MAC_COL_NUM-1:0] bias_acco_ren,  // delay M

    input  wire ri_weight_pingpong,
    output wire ro_weight_pingpong,  // delay N

    input wire [GEMM_MAC_ROW_NUM-1:0] ri_row_mask_ic_fea,
    input wire [GEMM_MAC_ROW_NUM-1:0] ri_col_mask_oc_fea,


    output wire [GEMM_MAC_ROW_NUM-1:0] ro_row_mask_ic_fea,   // delay N
    output wire [GEMM_MAC_ROW_NUM-1:0] ro_col_mask_oc_fea,   // delay N
    output wire [GEMM_MAC_ROW_NUM-1:0] acco_col_mask_oc_fea, // delay N+M

    input  wire is_cnt_ri_block_len_rs_ic_fea_start,
    output wire is_cnt_acco_block_len_rs_ic_fea_start  // delay N+M

);
    localparam int DELAYS[NUM_DELAY_HEADS] = '{CAL_DELAY_STC, CAL_DELAY_DWC, CAL_DELAY_POOL};
    localparam int DELAYS_N_M[NUM_DELAY_HEADS] = '{
        CAL_DELAY_STC + READ_DELAY_N,
        CAL_DELAY_DWC + READ_DELAY_N,
        CAL_DELAY_POOL + READ_DELAY_N
    };
    dq_dff #(
        .N (READ_DELAY_N),
        .DW(1)
    ) u_delay_is_ri_feature_write_start_pulse (
        .clk(clk),
        .rstn(rstn),
        .d(is_ri_feature_write_start_pulse),
        .q(is_ro_feature_write_start_pulse)
    );



    dq_dff #(
        .N (READ_DELAY_N),
        .DW(SEL_WIDTH)
    ) u_delay_mat_weight_in_ri_row_sel (
        .clk(clk),
        .rstn(rstn),
        .d(mat_weight_in_ri_row_sel),
        .q(mat_weight_in_ro_row_sel)
    );

    // dq_dff #(
    //     .N (CAL_DELAY_M),
    //     .DW(BIAS_RAM_ADDR_WIDTH)
    // ) u_delay_bias_acci_addr (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .d(bias_acci_addr),
    //     .q(bias_acco_addr)
    // );
    multi_delay_register #(
        .DATA_WIDTH(BIAS_RAM_ADDR_WIDTH),
        .NUM_HEADS(NUM_DELAY_HEADS),
        .MAX_DELAY(MAX_CAL_DELAY_M),
        .DELAYS(DELAYS)
    ) u_delay_bias_acci_addr (
        .clk(clk),
        .rstn(rstn),
        .sel(sel),
        .data_in(bias_acci_addr),
        .data_out(bias_acco_addr)
    );

    // dq_dff #(
    //     .N (CAL_DELAY_M),
    //     .DW(GEMM_MAC_COL_NUM)
    // ) u_delay_bias_acci_ren (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .d(bias_acci_ren),
    //     .q(bias_acco_ren)
    // );
    multi_delay_register #(
        .DATA_WIDTH(GEMM_MAC_COL_NUM),
        .NUM_HEADS(NUM_DELAY_HEADS),
        .MAX_DELAY(MAX_CAL_DELAY_M),
        .DELAYS(DELAYS)
    ) u_delay_bias_acci_ren (
        .clk(clk),
        .rstn(rstn),
        .sel(sel),
        .data_in(bias_acci_ren),
        .data_out(bias_acco_ren)
    );

    dq_dff #(
        .N (READ_DELAY_N),
        .DW(1)
    ) u_delay_ri_weight_pingpong (
        .clk(clk),
        .rstn(rstn),
        .d(ri_weight_pingpong),
        .q(ro_weight_pingpong)
    );

    dq_dff #(
        .N (READ_DELAY_N),
        .DW(GEMM_MAC_ROW_NUM)
    ) u_delay_ri_row_mask_ic_fea (
        .clk(clk),
        .rstn(rstn),
        .d(ri_row_mask_ic_fea),
        .q(ro_row_mask_ic_fea)
    );

    dq_dff #(
        .N (READ_DELAY_N),
        .DW(GEMM_MAC_COL_NUM)
    ) u_delay_ri_col_mask_oc_fea (
        .clk(clk),
        .rstn(rstn),
        .d(ri_col_mask_oc_fea),
        .q(ro_col_mask_oc_fea)
    );

    // dq_dff #(
    //     .N (READ_DELAY_N + CAL_DELAY_M),
    //     .DW(GEMM_MAC_COL_NUM)
    // ) u_delay_acco_col_mask_oc_fea (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .d(ri_col_mask_oc_fea),
    //     .q(acco_col_mask_oc_fea)
    // );

    // dq_dff #(
    //     .N (READ_DELAY_N + CAL_DELAY_M),
    //     .DW(1)
    // ) u_delay_is_cnt_ri_block_len_rs_ic_fea_start (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .d(is_cnt_ri_block_len_rs_ic_fea_start),
    //     .q(is_cnt_acco_block_len_rs_ic_fea_start)
    // );

    multi_delay_register #(
        .DATA_WIDTH(GEMM_MAC_COL_NUM),
        .NUM_HEADS(NUM_DELAY_HEADS),
        .MAX_DELAY(MAX_CAL_DELAY_M + READ_DELAY_N),
        .DELAYS(DELAYS_N_M)
    ) u_delay_acco_col_mask_oc_fea (
        .clk(clk),
        .rstn(rstn),
        .sel(sel),
        .data_in(ri_col_mask_oc_fea),
        .data_out(acco_col_mask_oc_fea)
    );

    multi_delay_register #(
        .DATA_WIDTH(1),
        .NUM_HEADS(NUM_DELAY_HEADS),
        .MAX_DELAY(MAX_CAL_DELAY_M + READ_DELAY_N),
        .DELAYS(DELAYS_N_M)
    ) u_delay_is_cnt_block_len_rs_ic_fea_start (
        .clk(clk),
        .rstn(rstn),
        .sel(sel),
        .data_in(is_cnt_ri_block_len_rs_ic_fea_start),
        .data_out(is_cnt_acco_block_len_rs_ic_fea_start)
    );


endmodule
