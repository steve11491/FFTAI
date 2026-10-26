//=================================================================================
// Test#3: dc_switch(第1级换相器) + dc_switch_fifo(第2~4级换相器)
//
// src: mdc/dc_switch.v(2位置切换) + mdc/dc_switch_fifo.v(FIFO延迟切换) + mdc/sync_fifo.v
//
// 换相器在R2MDC中的作用: 蝶形运算后, 两路数据的顺序需要按级数周期性交换.
//   第1级: 每2拍交换一次(dc_switch, 1拍FIFO)
//   第2级: 每4拍交换一次(dc_switch_fifo, 2拍FIFO)
//   第3级: 每8拍交换一次(dc_switch_fifo, 4拍FIFO)
//   第4级: 每16拍交换一次(dc_switch_fifo, 8拍FIFO)
//
// tb激励: 给两路输入各打标签(A=0xA000+i, B=0xB000+i), 使能若干拍后检查输出
// 判据: 输出序列与手工推导的交换模式一致
//=================================================================================
module tb_switch;

    localparam PERIOD = 10;

    reg clk, rstn;

    //========== dc_switch (第1级: 2位置切换, 无FIFO) ==========
    reg        s1_ena;
    reg [31:0] s1_i_0, s1_i_1;
    wire [31:0] s1_o_0, s1_o_1;
    wire        s1_vaild;

    dc_switch #(.SWITCH_WIDTH(32)) u_s1 (
        .switch_clk(clk), .switch_rstn(rstn), .switch_ena(s1_ena),
        .switch_i_0(s1_i_0), .switch_i_1(s1_i_1),
        .switch_o_0(s1_o_0), .switch_o_1(s1_o_1),
        .switch_vaild(s1_vaild)
    );

    //========== dc_switch_fifo 第2级 (FFT_STAGE=2, FIFO深度=2) ==========
    reg        s2_ena;
    reg [31:0] s2_i_0, s2_i_1;
    wire [31:0] s2_o_0, s2_o_1;
    wire        s2_vaild;

    dc_switch_fifo #(.FFT_STAGE(2), .SWITCH_WIDTH(32)) u_s2 (
        .switch_clk(clk), .switch_rstn(rstn), .switch_ena(s2_ena),
        .switch_i_0(s2_i_0), .switch_i_1(s2_i_1),
        .switch_o_0(s2_o_0), .switch_o_1(s2_o_1),
        .switch_vaild(s2_vaild)
    );

    //========== dc_switch_fifo 第3级 (FFT_STAGE=3, FIFO深度=4) ==========
    reg        s3_ena;
    reg [31:0] s3_i_0, s3_i_1;
    wire [31:0] s3_o_0, s3_o_1;
    wire        s3_vaild;

    dc_switch_fifo #(.FFT_STAGE(3), .SWITCH_WIDTH(32)) u_s3 (
        .switch_clk(clk), .switch_rstn(rstn), .switch_ena(s3_ena),
        .switch_i_0(s3_i_0), .switch_i_1(s3_i_1),
        .switch_o_0(s3_o_0), .switch_o_1(s3_o_1),
        .switch_vaild(s3_vaild)
    );

    //========== dc_switch_fifo 第4级 (FFT_STAGE=4, FIFO深度=8) ==========
    reg        s4_ena;
    reg [31:0] s4_i_0, s4_i_1;
    wire [31:0] s4_o_0, s4_o_1;
    wire        s4_vaild;

    dc_switch_fifo #(.FFT_STAGE(4), .SWITCH_WIDTH(32)) u_s4 (
        .switch_clk(clk), .switch_rstn(rstn), .switch_ena(s4_ena),
        .switch_i_0(s4_i_0), .switch_i_1(s4_i_1),
        .switch_o_0(s4_o_0), .switch_o_1(s4_o_1),
        .switch_vaild(s4_vaild)
    );

    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    //========== 测试主流程 ==========
    integer i, mism;
    reg [31:0] act_0, act_1;  // 每拍采样
    integer fo;

    // 采样: 在使能期间每拍记录4个模块的输出
    reg [31:0] log_s1_0[63:0], log_s1_1[63:0];
    reg [31:0] log_s2_0[63:0], log_s2_1[63:0];
    reg [31:0] log_s3_0[63:0], log_s3_1[63:0];
    reg [31:0] log_s4_0[63:0], log_s4_1[63:0];
    integer samp_cnt;

    always @(posedge clk) begin
        if (s1_ena && samp_cnt < 64) begin
            log_s1_0[samp_cnt] <= s1_o_0;
            log_s1_1[samp_cnt] <= s1_o_1;
            log_s2_0[samp_cnt] <= s2_o_0;
            log_s2_1[samp_cnt] <= s2_o_1;
            log_s3_0[samp_cnt] <= s3_o_0;
            log_s3_1[samp_cnt] <= s3_o_1;
            log_s4_0[samp_cnt] <= s4_o_0;
            log_s4_1[samp_cnt] <= s4_o_1;
            samp_cnt <= samp_cnt + 1;
        end
    end

    initial begin
        rstn = 0;
        s1_ena = 0; s1_i_0 = 0; s1_i_1 = 0;
        s2_ena = 0; s2_i_0 = 0; s2_i_1 = 0;
        s3_ena = 0; s3_i_0 = 0; s3_i_1 = 0;
        s4_ena = 0; s4_i_0 = 0; s4_i_1 = 0;
        samp_cnt = 0;
        mism = 0;
        #(PERIOD*4) rstn = 1;
        #(PERIOD*4);

        // 驱动 32 拍标签数据
        // 路0: 0xA0000000+i (i=拍号), 路1: 0xB0000000+i
        // 所有4个模块同时驱动相同标签(独立验证)
        for (i = 0; i < 32; i=i+1) begin
            s1_ena = 1; s1_i_0 = 32'hA000_0000 + i; s1_i_1 = 32'hB000_0000 + i;
            s2_ena = 1; s2_i_0 = 32'hA000_0000 + i; s2_i_1 = 32'hB000_0000 + i;
            s3_ena = 1; s3_i_0 = 32'hA000_0000 + i; s3_i_1 = 32'hB000_0000 + i;
            s4_ena = 1; s4_i_0 = 32'hA000_0000 + i; s4_i_1 = 32'hB000_0000 + i;
            @(posedge clk);
        end
        s1_ena = 0; s2_ena = 0; s3_ena = 0; s4_ena = 0;

        // 等待排空
        repeat (32) @(posedge clk);

        //========== 分析输出 ==========
        fo = $fopen("D:/project_PLF/FFTAI/sim/unit_switch/switch_log.txt", "w");

        $display("\n=== dc_switch (第1级, 2拍周期) ===");
        $display("拍 | o_0(路0输出)    o_1(路1输出)    | 期望模式");
        for (i = 0; i < 20; i=i+1) begin
            $fwrite(fo, "S1 %0d %h %h\n", i, log_s1_0[i], log_s1_1[i]);
            if (i < 8)
                $display("%2d | %h  %h", i, log_s1_0[i], log_s1_1[i]);
        end

        $display("\n=== dc_switch_fifo 第2级 (4拍周期, FIFO=2) ===");
        for (i = 0; i < 20; i=i+1) begin
            $fwrite(fo, "S2 %0d %h %h\n", i, log_s2_0[i], log_s2_1[i]);
            if (i < 12)
                $display("%2d | %h  %h", i, log_s2_0[i], log_s2_1[i]);
        end

        $display("\n=== dc_switch_fifo 第3级 (8拍周期, FIFO=4) ===");
        for (i = 0; i < 24; i=i+1) begin
            $fwrite(fo, "S3 %0d %h %h\n", i, log_s3_0[i], log_s3_1[i]);
            if (i < 12)
                $display("%2d | %h  %h", i, log_s3_0[i], log_s3_1[i]);
        end

        $display("\n=== dc_switch_fifo 第4级 (16拍周期, FIFO=8) ===");
        for (i = 0; i < 32; i=i+1) begin
            $fwrite(fo, "S4 %0d %h %h\n", i, log_s4_0[i], log_s4_1[i]);
            if (i < 12)
                $display("%2d | %h  %h", i, log_s4_0[i], log_s4_1[i]);
        end

        $fclose(fo);
        $display("\nTB_SWITCH done: 输出已保存, 请用python分析交换模式");
        $finish;
    end

endmodule
