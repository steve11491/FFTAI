//=================================================================================
// Test#4: mdc 单实例 (2 并行 R2MDC, 4 级蝶形流水)
//
// src: mdc/mdc.sv + dc_switch.v + dc_switch_fifo.v + sync_fifo.v
// 行为级 ALU: 蝶形计算模型(与 pe_array_col 同算术), 延迟可调
//
// 输入数据: mdc_stim.txt (16点单音, DIT配对)
// tb激励: 8 拍喂入 16 个样本(2/拍), 旋转因子按 fft_in_valid 自动同步
// 期望输出: mdc_expect.txt (浮点 FFT / N, 位反序)
// 实际输出: sim/unit_mdc/mdc_out.txt
//=================================================================================
module tb_mdc;

    localparam PERIOD = 10;
    localparam DW = 16;       // data width
    localparam AW = 40;       // ALU width
    localparam STAGE = 4;     // butterfly stages
    localparam ALU_DLY = 5;   // behavioral ALU pipeline delay
    localparam NIN = 8;       // input clocks (16 samples / 2 per clock)

    reg clk, rstn;
    reg mdc_ena;
    reg [3:0] mdc_stage;
    reg signed [DW-1:0] rotar_real [STAGE-1:0];
    reg signed [DW-1:0] rotar_imag [STAGE-1:0];
    reg signed [DW-1:0] di_real [1:0];
    reg signed [DW-1:0] di_imag [1:0];
    wire signed [DW-1:0] do_real [1:0];
    wire signed [DW-1:0] do_imag [1:0];
    wire mdc_vaild;

    // ALU interface (mdc → ALU)
    wire fft_in_valid [STAGE-1:0];
    wire [DW-1:0] X2r [STAGE-1:0];
    wire [DW-1:0] X2i [STAGE-1:0];
    wire [DW-1:0] Wr  [STAGE-1:0];
    wire [DW-1:0] Wi  [STAGE-1:0];
    wire [DW-1:0] X1r [STAGE-1:0];
    wire [DW-1:0] X1i [STAGE-1:0];

    // ALU interface (ALU → mdc) — 行为级模型驱动
    reg [AW-1:0] fft_out1_r [STAGE-1:0];
    reg [AW-1:0] fft_out1_i [STAGE-1:0];
    reg [AW-1:0] fft_out2_r [STAGE-1:0];
    reg [AW-1:0] fft_out2_i [STAGE-1:0];
    reg fft_out_valid [STAGE-1:0];

    mdc #(
        .DATA_WIDTH(DW),
        .ALU_WIDTH(AW),
        .MDC_STAGE(STAGE),
        .MDC_PARALLEL(2)
    ) dut (
        .mdc_clk(clk), .mdc_rstn(rstn), .mdc_ena(mdc_ena),
        .mdc_stage(mdc_stage),
        .rotar_real(rotar_real), .rotar_imag(rotar_imag),
        .data_i_real(di_real), .data_i_imag(di_imag),
        .data_o_real(do_real), .data_o_imag(do_imag),
        .mdc_vaild(mdc_vaild),
        .fft_out1_r(fft_out1_r), .fft_out1_i(fft_out1_i),
        .fft_out2_r(fft_out2_r), .fft_out2_i(fft_out2_i),
        .fft_out_valid(fft_out_valid),
        .fft_in_valid(fft_in_valid),
        .X2r(X2r), .X2i(X2i), .Wr(Wr), .Wi(Wi),
        .X1r(X1r), .X1i(X1i)
    );

    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    //========== 行为级 ALU ==========
    // 每级独立: 数据流水 ALU_DLY 拍, 末拍组合逻辑计算蝶形
    genvar s;
    generate
        for (s = 0; s < STAGE; s = s + 1) begin : BALU
            // 流水线寄存器
            reg [ALU_DLY-1:0] vld_sr;
            reg signed [DW-1:0] x1r_p [ALU_DLY-1:0];
            reg signed [DW-1:0] x1i_p [ALU_DLY-1:0];
            reg signed [DW-1:0] x2r_p [ALU_DLY-1:0];
            reg signed [DW-1:0] x2i_p [ALU_DLY-1:0];
            reg signed [DW-1:0] wr_p  [ALU_DLY-1:0];
            reg signed [DW-1:0] wi_p  [ALU_DLY-1:0];

            always @(posedge clk) begin
                if (!rstn) begin
                    vld_sr <= 'b0;
                end else begin
                    vld_sr <= {vld_sr[ALU_DLY-2:0], fft_in_valid[s]};
                    x1r_p[0] <= X1r[s];  x1i_p[0] <= X1i[s];
                    x2r_p[0] <= X2r[s];  x2i_p[0] <= X2i[s];
                    wr_p[0]  <= Wr[s];   wi_p[0]  <= Wi[s];
                    for (integer d = 1; d < ALU_DLY; d = d + 1) begin
                        x1r_p[d] <= x1r_p[d-1]; x1i_p[d] <= x1i_p[d-1];
                        x2r_p[d] <= x2r_p[d-1]; x2i_p[d] <= x2i_p[d-1];
                        wr_p[d]  <= wr_p[d-1];  wi_p[d]  <= wi_p[d-1];
                    end
                end
            end

            // 末拍组合计算: 与 Test#1 验证的 C-fl 算术一致
            wire signed [AW-1:0] p_re = wr_p[ALU_DLY-1] * x2r_p[ALU_DLY-1]
                                      - wi_p[ALU_DLY-1] * x2i_p[ALU_DLY-1];
            wire signed [AW-1:0] p_im = wr_p[ALU_DLY-1] * x2i_p[ALU_DLY-1]
                                      + wi_p[ALU_DLY-1] * x2r_p[ALU_DLY-1];

            always @(posedge clk) begin
                if (!rstn) begin
                    fft_out1_r[s] <= 0; fft_out1_i[s] <= 0;
                    fft_out2_r[s] <= 0; fft_out2_i[s] <= 0;
                    fft_out_valid[s] <= 0;
                end else begin
                    fft_out_valid[s] <= vld_sr[ALU_DLY-1];
                    fft_out2_r[s] <= {{(AW-DW-15){x1r_p[ALU_DLY-1][DW-1]}}, x1r_p[ALU_DLY-1], 15'b0} + p_re;
                    fft_out2_i[s] <= {{(AW-DW-15){x1i_p[ALU_DLY-1][DW-1]}}, x1i_p[ALU_DLY-1], 15'b0} + p_im;
                    fft_out1_r[s] <= {{(AW-DW-15){x1r_p[ALU_DLY-1][DW-1]}}, x1r_p[ALU_DLY-1], 15'b0} - p_re;
                    fft_out1_i[s] <= {{(AW-DW-15){x1i_p[ALU_DLY-1][DW-1]}}, x1i_p[ALU_DLY-1], 15'b0} - p_im;
                end
            end
        end
    endgenerate

    //========== 旋转因子自动同步 ==========
    // 每级维护一个计数器, fft_in_valid[s] 有效时递增
    // twiddle = W_{2^(s+1)}^{cnt % 2^s} (量化)
    integer tw_cnt [STAGE-1:0];
    always @(posedge clk) begin
        if (!rstn) begin
            for (integer k = 0; k < STAGE; k = k + 1) tw_cnt[k] <= 0;
        end else begin
            for (integer k = 0; k < STAGE; k = k + 1) begin
                if (fft_in_valid[k]) tw_cnt[k] <= tw_cnt[k] + 1;
                else tw_cnt[k] <= 0;  // 复位(间隙时归零)
            end
        end
    end

    // 旋转因子查找表 (硬编码 W_2^0 .. W_16^7)
    function [31:0] get_twiddle(input integer stage, input integer cnt);
        integer k, N, idx;
        real angle;
        begin
            N = 1 << (stage + 1);  // 2, 4, 8, 16
            idx = cnt % (N >> 1);  // k mod N/2
            angle = 2.0 * 3.14159265358979 * idx / N;
            // 量化: floor(v*2^15-1) / ceil(v*2^15+1) / round
            begin : qt
                real c, s_;
                integer cr, ci_;
                c = $cos(angle); s_ = -$sin(angle);
                if (c > 0.0000305) cr = $floor(c * 32768.0 - 1.0);
                else if (c < -0.0000305) cr = $ceil(c * 32768.0 + 1.0);
                else cr = (c >= 0) ? $floor(c * 32768.0 + 0.5) : $ceil(c * 32768.0 - 0.5);
                if (s_ > 0.0000305) ci_ = $floor(s_ * 32768.0 - 1.0);
                else if (s_ < -0.0000305) ci_ = $ceil(s_ * 32768.0 + 1.0);
                else ci_ = (s_ >= 0) ? $floor(s_ * 32768.0 + 0.5) : $ceil(s_ * 32768.0 - 0.5);
                get_twiddle = {(ci_ & 16'hFFFF), (cr & 16'hFFFF)};
            end
        end
    endfunction

    always @(*) begin
        for (integer k = 0; k < STAGE; k = k + 1) begin
            {rotar_imag[k], rotar_real[k]} = get_twiddle(k, tw_cnt[k]);
        end
    end

    //========== 主测试流程 ==========
    integer fi, fo, i, out_cnt;
    integer mism;
    reg signed [DW-1:0] stim_r0 [NIN-1:0], stim_i0 [NIN-1:0];
    reg signed [DW-1:0] stim_r1 [NIN-1:0], stim_i1 [NIN-1:0];
    reg signed [DW-1:0] out_r0 [63:0], out_i0 [63:0];
    reg signed [DW-1:0] out_r1 [63:0], out_i1 [63:0];

    // 输出采样
    always @(posedge clk) begin
        if (mdc_vaild && out_cnt < 64) begin
            out_r0[out_cnt] <= do_real[0];
            out_i0[out_cnt] <= do_imag[0];
            out_r1[out_cnt] <= do_real[1];
            out_i1[out_cnt] <= do_imag[1];
            out_cnt <= out_cnt + 1;
        end
    end

    initial begin
        rstn = 0; mdc_ena = 0; mdc_stage = 4'b0000;
        di_real[0] = 0; di_real[1] = 0; di_imag[0] = 0; di_imag[1] = 0;
        out_cnt = 0; mism = 0;
        for (i = 0; i < STAGE; i=i+1) begin
            rotar_real[i] = 0; rotar_imag[i] = 0;
        end

        // 读激励
        fi = $fopen("D:/project_PLF/FFTAI/rtl/rtl_tb/unit_tb/mdc_stim.txt", "r");
        if (!fi) begin $error("open stim fail"); $finish; end
        for (i = 0; i < NIN; i=i+1)
            $fscanf(fi, "%d %d %d %d", stim_r0[i], stim_i0[i], stim_r1[i], stim_i1[i]);
        $fclose(fi);

        #(PERIOD*4) rstn = 1;
        #(PERIOD*4);

        // 驱动 8 拍输入
        for (i = 0; i < NIN; i=i+1) begin
            mdc_ena = 1;
            di_real[0] = stim_r0[i]; di_imag[0] = stim_i0[i];
            di_real[1] = stim_r1[i]; di_imag[1] = stim_i1[i];
            @(posedge clk);
        end
        mdc_ena = 0;

        // 等待流水线排空
        repeat (100) @(posedge clk);

        // 输出结果
        fo = $fopen("D:/project_PLF/FFTAI/sim/unit_mdc/mdc_out.txt", "w");
        $display("TB_MDC: 共采集 %0d 拍输出", out_cnt);
        for (i = 0; i < out_cnt; i=i+1) begin
            $fwrite(fo, "%0d %0d %0d %0d\n", out_r0[i], out_i0[i], out_r1[i], out_i1[i]);
            if (i < 8)
                $display("  拍%0d: 路0=(%0d,%0d) 路1=(%0d,%0d)", i,
                    out_r0[i], out_i0[i], out_r1[i], out_i1[i]);
        end
        $fclose(fo);
        $display("TB_MDC done: 请用 python 对拍 mdc_expect.txt");
        $finish;
    end

endmodule
