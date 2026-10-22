//=================================================================================
// tb_bfly: 2R.1 蝶形单元验证——驱动 pe_array_col（4 行完整蝶形计算列）
//
// 激励/期望: note/p2_scripts/bfly_data/{stim,expect}.txt（python 固定种子生成, C-fl 算术）
// 实际输出: sim/bfly/actual.txt（第5-8列为 [31:16] 切割值 int16 语义, 供 python 复核）
// 采样: 固定延迟（odata 寄存器保持至下一个 valid，无竞态）
//=================================================================================
module tb_bfly;

    localparam PERIOD = 10;
    localparam WIDTH = 16;
    localparam ROWS = 4;
    localparam ODATA_WIDTH = 38;
    localparam NVEC = 64;
    localparam LAT = 12;   // 固定采样延迟（>流水深度）

    reg clk, rstn;
    reg [ROWS-1:0][1:0] in_valid;
    reg is_fft, is_int16;

    reg signed [WIDTH:0]    IN1_X2r [ROWS-1:0];
    reg signed [WIDTH:0]    IN2_X2i [ROWS-1:0];
    reg signed [WIDTH-1:0]  W11_Wr  [ROWS-1:0];
    reg signed [WIDTH-1:0]  W12_Wi  [ROWS-1:0];
    reg signed [WIDTH-1:0]  W21_X1i [ROWS-1:0];
    reg signed [WIDTH-1:0]  W22_X1r [ROWS-1:0];

    wire signed [ODATA_WIDTH-1:0] odata [1:0][2*ROWS-1:0];
    wire [ROWS-1:0] out_valid [1:0];

    pe_array_col #(
        .WIDTH           (WIDTH),
        .DUAL_MAC_ROW_NUM(ROWS),
        .INPUTS_NUM      (ROWS),
        .OUTPUT_NUM      (2*ROWS),
        .STAGES_NUM      (2),
        .ODATA_WIDTH     (ODATA_WIDTH)
    ) dut (
        .clk(clk), .rstn(rstn),
        .in_valid(in_valid),
        .is_fft(is_fft), .is_int16(is_int16),
        .IN1_X2r(IN1_X2r), .IN2_X2i(IN2_X2i),
        .W11_Wr(W11_Wr), .W12_Wi(W12_Wi),
        .W21_X1i(W21_X1i), .W22_X1r(W22_X1r),
        .odata(odata), .out_valid(out_valid)
    );

    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    reg signed [WIDTH-1:0] stim [NVEC-1:0][5:0];
    reg signed [ODATA_WIDTH-1:0] expd [NVEC-1:0][7:0];

    task load_files;
        integer f, i, j, code;
        begin
            f = $fopen("D:/project_PLF/FFTAI/note/p2_scripts/bfly_data/stim.txt", "r");
            if (!f) begin $error("open stim fail"); $finish; end
            for (i = 0; i < NVEC; i=i+1)
                code = $fscanf(f, "%d %d %d %d %d %d",
                    stim[i][0], stim[i][1], stim[i][2], stim[i][3], stim[i][4], stim[i][5]);
            $fclose(f);
            f = $fopen("D:/project_PLF/FFTAI/note/p2_scripts/bfly_data/expect.txt", "r");
            if (!f) begin $error("open expect fail"); $finish; end
            for (i = 0; i < NVEC; i=i+1)
                for (j = 0; j < 8; j=j+1) code = $fscanf(f, "%d", expd[i][j]);
            $fclose(f);
        end
    endtask

    integer fo, v, r, mism;
    initial begin
        rstn = 0; is_fft = 1; is_int16 = 1;
        for (r = 0; r < ROWS; r=r+1) begin
            in_valid[r] = 2'b00;
            IN1_X2r[r] = 0; IN2_X2i[r] = 0;
            W11_Wr[r] = 0; W12_Wi[r] = 0; W21_X1i[r] = 0; W22_X1r[r] = 0;
        end
        load_files;
        #(PERIOD*2) rstn = 1;
        #(PERIOD*2);
        // 预热：首发交易 X1 延迟链未冲满会产生 X，驱动一次假向量后再正式验证
        for (r = 0; r < ROWS; r=r+1) begin
            W22_X1r[r] = 0; W21_X1i[r] = 0; IN1_X2r[r] = 0; IN2_X2i[r] = 0;
            W11_Wr[r] = 0; W12_Wi[r] = 0; in_valid[r] = 2'b11;
        end
        @(posedge clk);
        for (r = 0; r < ROWS; r=r+1) in_valid[r] = 2'b00;
        repeat (LAT) @(posedge clk);
        fo = $fopen("D:/project_PLF/FFTAI/sim/bfly/actual.txt", "w");
        mism = 0;
        for (v = 0; v < NVEC; v=v+1) begin
            for (r = 0; r < ROWS; r=r+1) begin
                W22_X1r[r] = stim[v][0];  W21_X1i[r] = stim[v][1];
                IN1_X2r[r] = stim[v][2];  IN2_X2i[r] = stim[v][3];
                W11_Wr[r]  = stim[v][4];  W12_Wi[r]  = stim[v][5];
                in_valid[r] = 2'b11;
            end
            @(posedge clk);
            for (r = 0; r < ROWS; r=r+1) in_valid[r] = 2'b00;
            repeat (LAT) @(posedge clk);
            // odata[0][*]=实部: [0..3]=sub(X1*2^15-P) [4..7]=add; odata[1][*]=虚部
            $fwrite(fo, "%0d %0d %0d %0d %0d %0d %0d %0d\n",
                $signed(odata[0][0]), $signed(odata[0][4]),
                $signed(odata[1][0]), $signed(odata[1][4]),
                $signed(odata[0][0][31:16]), $signed(odata[0][4][31:16]),
                $signed(odata[1][0][31:16]), $signed(odata[1][4][31:16]));
            if ($signed(odata[0][0]) !== expd[v][0] || $signed(odata[0][4]) !== expd[v][1] ||
                $signed(odata[1][0]) !== expd[v][2] || $signed(odata[1][4]) !== expd[v][3]) begin
                mism = mism + 1;
                if (mism <= 5)
                    $display("[VEC %0d] MISMATCH rt=(%0d %0d %0d %0d) exp=(%0d %0d %0d %0d)",
                        v, $signed(odata[0][0]), $signed(odata[0][4]),
                        $signed(odata[1][0]), $signed(odata[1][4]),
                        expd[v][0], expd[v][1], expd[v][2], expd[v][3]);
            end
        end
        $fclose(fo);
        if (mism == 0)
            $display("TB_BFLY PASS: %0d/%0d 组 bit-exact", NVEC, NVEC);
        else
            $display("TB_BFLY FAIL: %0d/%0d 组不一致", mism, NVEC);
        $finish;
    end

endmodule
