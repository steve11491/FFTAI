//=================================================================================
// tb_asort: array_sort 单元级对比——新版(RAM) vs 旧版(寄存器), 8并行度
// 激励: 标签数据 mdc_o_data[l] = l*4096 + t; 波形: 16拍填充(vaild=0,cnt=0..15)
//       + 64拍flush(vaild=1,cnt=0..63), pe_o_vaild全程=1 (系统实测形态)
//=================================================================================
module tb_asort;

    localparam PERIOD = 10;
    localparam integer FILL_LEN = 14;  // 扫描参数
    reg clk, rstn;
    reg pe_o_vaild;
    reg [8:0] array_sort_cnt;
    reg array_sort_vaild;
    reg [31:0] din [7:0];
    wire [31:0] o_new [7:0];
    wire [31:0] o_old [7:0];

    array_sort_ram #(
        .MAX_POINT(4096),
        .MDC_PARALLEL(8),
        .MDC_STAGE(4),
        .DATA_WIDTH(32)
    ) u_new (
        .clk(clk), .rstn(rstn),
        .pe_o_vaild(pe_o_vaild),
        .array_sort_cnt(array_sort_cnt),
        .array_sort_vaild(array_sort_vaild),
        .mdc_o_data(din),
        .array_sort_o(o_new)
    );

    array_sort #(
        .MAX_POINT(4096),
        .MDC_PARALLEL(8),
        .MDC_STAGE(4),
        .DATA_WIDTH(32)
    ) u_old (
        .clk(clk), .rstn(rstn),
        .pe_o_vaild(pe_o_vaild),
        .array_sort_cnt(array_sort_cnt),
        .array_sort_vaild(array_sort_vaild),
        .mdc_o_data(din),
        .array_sort_o(o_old)
    );

    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    integer fo, l, t;
    initial begin
        rstn = 0; pe_o_vaild = 0; array_sort_vaild = 0; array_sort_cnt = 0;
        for (l = 0; l < 8; l=l+1) din[l] = 0;
        #(PERIOD*2) rstn = 1;
        #(PERIOD*2);
        fo = $fopen("D:/project_PLF/FFTAI/sim/fft_sys/asort_cmp.txt", "w");
        for (t = 0; t < 30+64+4; t=t+1) begin
            pe_o_vaild = (t < FILL_LEN + 34);  // 输入在flush结束前30拍停止(系统实测形态)
            for (l = 0; l < 8; l=l+1) din[l] = l*4096 + t;
            if (t < FILL_LEN) begin
                array_sort_vaild = 0;
                array_sort_cnt = t % 16;      // 填充期 mod16 循环(系统同款)
            end else begin
                array_sort_vaild = 1;
                array_sort_cnt = t - FILL_LEN;
            end
            @(posedge clk);
            #1;
            $fwrite(fo, "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
                t, o_new[0], o_new[1], o_new[2], o_new[3], o_new[4], o_new[5], o_new[6], o_new[7],
                o_old[0], o_old[1], o_old[2], o_old[3],
                o_old[4], o_old[5], o_old[6], o_old[7]);
        end
        $fclose(fo);
        $display("TB_ASORT done");
        $finish;
    end

endmodule
