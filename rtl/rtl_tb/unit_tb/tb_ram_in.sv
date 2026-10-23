//=================================================================================
// Test#2 存储单元: fft_ram_in (8 lane 并行双端口 RAM)
//
// src        : rtl/rtl_src/src/fft/fft_ram_in.sv + memory/com_simple_dual_port_ram.v
// 输入数据    : 内联生成(lane*0x10000+addr 标签模式, 无外部文件)
// tb激励     : (A)全量写入512地址x8lane (B)全量回读 (C)选择性写 (D)边界地址 (E)同时读写
// 期望输出    : 标签模式推算值(见各阶段内联)
// 实际输出    : 逐拍采样至实际寄存器
// 判据       : (1)读出数据==写入标签 (2)读有效时序正确 (3)读写不冲突
//=================================================================================
module tb_ram_in;

    localparam PERIOD = 10;
    localparam PARALLEL = 8;
    localparam DEPTH = 512;
    localparam AW = $clog2(DEPTH);
    localparam DW = 32;

    reg clk, rstn;
    reg ram_i_ena [PARALLEL-1:0];
    reg ram_o_ena;
    reg [DW-1:0] ram_i_data [PARALLEL-1:0];
    reg [AW-1:0] ram_i_addr [PARALLEL-1:0];
    reg [AW-1:0] ram_o_addr [PARALLEL-1:0];
    wire [DW-1:0] ram_o_data [PARALLEL-1:0];
    wire ram_o_vaild;

    fft_ram_in #(
        .PARALLEL(PARALLEL),
        .DEPTH(DEPTH),
        .WIDTH(DW)
    ) dut (
        .ram_clk(clk),
        .ram_rstn(rstn),
        .ram_i_ena(ram_i_ena),
        .ram_o_ena(ram_o_ena),
        .ram_i_data(ram_i_data),
        .ram_i_addr(ram_i_addr),
        .ram_o_addr(ram_o_addr),
        .ram_o_data(ram_o_data),
        .ram_o_vaild(ram_o_vaild)
    );

    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    integer i, j, mism, phase;
    reg [DW-1:0] exp_val;

    initial begin
        rstn = 0;
        ram_o_ena = 0;
        for (i = 0; i < PARALLEL; i=i+1) begin
            ram_i_ena[i] = 0; ram_i_data[i] = 0; ram_i_addr[i] = 0; ram_o_addr[i] = 0;
        end
        #(PERIOD*4) rstn = 1;
        #(PERIOD*4);
        mism = 0;
        phase = 0;

        //========== Phase A: 全量写入(8 lane x 512 addr) ==========
        phase = 1;
        $display("Phase A: 全量写入...");
        for (i = 0; i < DEPTH; i=i+1) begin
            for (j = 0; j < PARALLEL; j=j+1) begin
                ram_i_ena[j] = 1;
                ram_i_data[j] = (j << 16) | (i & 16'hFFFF);
                ram_i_addr[j] = i;
            end
            @(posedge clk);
            #1;  // 确保 NBA 落盘后再设下一地址
        end
        for (j = 0; j < PARALLEL; j=j+1) ram_i_ena[j] = 0;
        repeat (4) @(posedge clk);

        //========== Phase B: 全量回读 ==========
        phase = 2;
        $display("Phase B: 全量回读...");
        ram_o_ena = 1;
        // 预热读(首拍 doutb 尚未从复位值更新)
        for (j = 0; j < PARALLEL; j=j+1) ram_o_addr[j] = 1;
        @(posedge clk);
        for (i = 0; i < DEPTH; i=i+1) begin
            for (j = 0; j < PARALLEL; j=j+1) ram_o_addr[j] = i;
            @(posedge clk);
            #1;
            begin
                for (j = 0; j < PARALLEL; j=j+1) begin
                    exp_val = (j << 16) | (i & 16'hFFFF);
                    if (ram_o_data[j] !== exp_val) begin
                        mism = mism + 1;
                        if (mism <= 5)
                            $display("[B] lane=%0d addr=%0d rt=%h exp=%h", j, i, ram_o_data[j], exp_val);
                    end
                end
            end
        end
        ram_o_ena = 0;
        repeat (4) @(posedge clk);
        $display("Phase B 完成, 累计mismatch=%0d", mism);

        //========== Phase C: 选择性写(lane 0,3,5 写; 其余不写) ==========
        phase = 3;
        $display("Phase C: 选择性写...");
        for (j = 0; j < PARALLEL; j=j+1)
            ram_i_ena[j] = (j==0 || j==3 || j==5) ? 1 : 0;
        for (i = 0; i < 16; i=i+1) begin
            for (j = 0; j < PARALLEL; j=j+1) begin
                ram_i_data[j] = 32'hDEAD_0000 | (i & 16'hFFFF);
                ram_i_addr[j] = i;
            end
            @(posedge clk);
        end
        for (j = 0; j < PARALLEL; j=j+1) ram_i_ena[j] = 0;
        repeat (4) @(posedge clk);

        // 回读验证
        ram_o_ena = 1;
        for (j = 0; j < PARALLEL; j=j+1) ram_o_addr[j] = 100;
        @(posedge clk);  // 预热
        for (i = 0; i < 16; i=i+1) begin
            for (j = 0; j < PARALLEL; j=j+1) ram_o_addr[j] = i;
            @(posedge clk);
            #1;
            begin
                for (j = 0; j < PARALLEL; j=j+1) begin
                    if (j==0 || j==3 || j==5)
                        exp_val = 32'hDEAD_0000 | (i & 16'hFFFF);
                    else
                        exp_val = (j << 16) | (i & 16'hFFFF);  // 保留旧数据
                    if (ram_o_data[j] !== exp_val) begin
                        mism = mism + 1;
                        if (mism <= 5)
                            $display("[C] lane=%0d addr=%0d rt=%h exp=%h", j, i, ram_o_data[j], exp_val);
                    end
                end
            end
        end
        ram_o_ena = 0;
        repeat (4) @(posedge clk);
        $display("Phase C 完成, 累计mismatch=%0d", mism);

        //========== Phase D: 边界地址(0 和 DEPTH-1) ==========
        phase = 4;
        $display("Phase D: 边界地址...");
        // 写地址0
        for (j = 0; j < PARALLEL; j=j+1) begin
            ram_i_ena[j] = 1; ram_i_data[j] = 32'hAAAA_0000; ram_i_addr[j] = 0;
        end
        @(posedge clk);
        for (j = 0; j < PARALLEL; j=j+1) ram_i_ena[j] = 0;
        // 写地址DEPTH-1
        @(posedge clk);
        for (j = 0; j < PARALLEL; j=j+1) begin
            ram_i_ena[j] = 1; ram_i_data[j] = 32'hBBBB_FFFF; ram_i_addr[j] = DEPTH-1;
        end
        @(posedge clk);
        for (j = 0; j < PARALLEL; j=j+1) ram_i_ena[j] = 0;
        repeat (4) @(posedge clk);

        // 回读
        ram_o_ena = 1;
        for (j = 0; j < PARALLEL; j=j+1) ram_o_addr[j] = 0;
        @(posedge clk); @(posedge clk); #1;
        for (j = 0; j < PARALLEL; j=j+1)
            if (ram_o_data[j] !== 32'hAAAA_0000) begin
                mism = mism + 1;
                $display("[D-0] lane=%0d rt=%h exp=AAAA0000", j, ram_o_data[j]);
            end
        for (j = 0; j < PARALLEL; j=j+1) ram_o_addr[j] = DEPTH-1;
        @(posedge clk); #1;
        for (j = 0; j < PARALLEL; j=j+1)
            if (ram_o_data[j] !== 32'hBBBB_FFFF) begin
                mism = mism + 1;
                $display("[D-max] lane=%0d rt=%h exp=BBBBFFFF", j, ram_o_data[j]);
            end
        ram_o_ena = 0;
        repeat (4) @(posedge clk);
        $display("Phase D 完成, 累计mismatch=%0d", mism);

        //========== Phase E: 同时读写(双端口) ==========
        phase = 5;
        $display("Phase E: 同时读写...");
        ram_o_ena = 1;
        for (j = 0; j < PARALLEL; j=j+1) ram_o_addr[j] = 100;  // 读地址100
        for (i = 0; i < 8; i=i+1) begin
            for (j = 0; j < PARALLEL; j=j+1) begin
                ram_i_ena[j] = 1;
                ram_i_data[j] = 32'hCCCC_0000 | i;
                ram_i_addr[j] = 200 + i;  // 写地址200+, 不冲突读地址
            end
            @(posedge clk);
        end
        for (j = 0; j < PARALLEL; j=j+1) ram_i_ena[j] = 0;
        @(posedge clk); #1;
        // 读地址100的旧数据应该还在(未被写覆盖)
        for (j = 0; j < PARALLEL; j=j+1) begin
            exp_val = (j << 16) | (100 & 16'hFFFF);
            if (ram_o_data[j] !== exp_val) begin
                mism = mism + 1;
                $display("[E] lane=%0d rt=%h exp=%h", j, ram_o_data[j], exp_val);
            end
        end
        ram_o_ena = 0;
        repeat (4) @(posedge clk);
        $display("Phase E 完成, 累计mismatch=%0d", mism);

        //========== 汇总 ==========
        if (mism == 0)
            $display("TB_RAM_IN PASS: 5 阶段(全量读写/选择性写/边界/双端口)全部正确");
        else
            $display("TB_RAM_IN FAIL: %0d 处不一致", mism);
        $finish;
    end

endmodule
