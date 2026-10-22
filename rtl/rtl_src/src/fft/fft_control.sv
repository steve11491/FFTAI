module fft_control #(
    parameter FFT_CORE_NUM = 4,
    parameter STAGE_WIDTH = 4,
    parameter MAX_POINT = 4096,
    parameter MDC_PARALLEL = 8,
    parameter MDC_STAGE = 4,
    parameter DATA_WIDTH = 32,  //FFT ram width
    parameter RAM_DELAY = 1,
    parameter RAM_IN_NUM = 3,
    parameter RAM_OUT_NUM = 2,
    parameter BUS_DATA_WIDTH = 32,

    parameter RAMIO_WIDTH = $clog2(MAX_POINT / 8),
    parameter ROM_WIDTH = $clog2(MAX_POINT / 8),
    parameter MULTI_CHANNAL = MDC_PARALLEL / 8,
    parameter DOUBLE_RAM_IN_WIDTH = $clog2(RAM_IN_NUM),
    parameter DOUBLE_RAM_OUT_WIDTH = $clog2(RAM_OUT_NUM),
    parameter MAX_STAGE = $clog2(MAX_POINT),
    parameter BUS_DATA_NUM = BUS_DATA_WIDTH / DATA_WIDTH,
    parameter BUS_PARALLEL = $clog2(BUS_DATA_NUM),
    parameter PARALLEL_WIDTH = $clog2(MDC_PARALLEL)

) (
    input clk,
    input rstn,

    //BUS
    input [FFT_CORE_NUM-1:0] bus_i_vaild,
    input [FFT_CORE_NUM-1:0] bus_i_hask,
    input [FFT_CORE_NUM-1:0] bus_o_ready,
    output bus_i_ready,

    //REG
    input fft_start,
    input [STAGE_WIDTH-1:0] fft_stage,

    //MDC control
    input [FFT_CORE_NUM-1:0] fft_core_vaild,
    output [MDC_STAGE-1:0] fft_core_out_stage,

    //Array sort control
    output [RAMIO_WIDTH-1:0] array_sort_cnt,
    output array_sort_vaild,

    //RAM IN control
    output [RAMIO_WIDTH-1:0] ram_in_addr_i[RAM_IN_NUM-1:0][MDC_PARALLEL-1:0],
    output ram_in_ena_i[RAM_IN_NUM-1:0][MDC_PARALLEL-1:0],

    output [RAMIO_WIDTH-1:0] ram_in_addr_o[MDC_PARALLEL-1:0],
    output ram_in_ena_o[RAM_IN_NUM-1:0],

    output [DOUBLE_RAM_IN_WIDTH-1:0] ram_in_num_i,
    output [DOUBLE_RAM_IN_WIDTH-1:0] ram_in_back_num_i,
    output [DOUBLE_RAM_IN_WIDTH-1:0] ram_in_num_o,

    //RAM OUT control
    output [RAMIO_WIDTH-1:0] ram_out_addr_i[MDC_PARALLEL-1:0],
    output ram_out_ena_i[RAM_OUT_NUM-1:0],

    output [RAMIO_WIDTH-1:0] ram_out_addr_o[MDC_PARALLEL-1:0],
    output ram_out_ena_o[RAM_OUT_NUM-1:0][MDC_PARALLEL-1:0],

    output [DOUBLE_RAM_OUT_WIDTH-1:0] ram_out_num_i,
    output [DOUBLE_RAM_OUT_WIDTH-1:0] ram_out_num_o,

    //RAM Weight control
    output [ROM_WIDTH-1:0] rom_weight_addr,
    output rom_weight_ena,
    output mdc_frs_stage,

    //axi out
    output reg [PARALLEL_WIDTH-1:0] ramout2axi_num
);

    localparam MDC_CHANNAL = MDC_PARALLEL / 2;

    //anti ADDRESS
    localparam ADDR_C_WIDTH = $clog2(MDC_CHANNAL);
    localparam ADDR_H_WIDTH = $clog2(MDC_PARALLEL);  //high address -> choose ram
    localparam ADDR_L_WIDTH = $clog2(MAX_POINT) - ADDR_H_WIDTH;  //low address

    genvar i;
    integer p;

    //DATA Stream FLAG
    (* mark_debug = "false"*) wire axi2ramin_hask;
    (* mark_debug = "false"*) wire axi2ramin_end;

    (* mark_debug = "false"*) wire ramin2pe_ena;
    (* mark_debug = "false"*) reg ramin2pe_done;
    (* mark_debug = "false"*) wire ramin2pe_end;

    (* mark_debug = "false"*) reg pebuff2ramin_vaild;
    (* mark_debug = "false"*) wire pe2ramin_ena;
    (* mark_debug = "false"*) wire pe2ramin_end;

    (* mark_debug = "false"*) reg pebuff2ramout_vaild;
    (* mark_debug = "false"*) wire pe2ramout_ena;
    (* mark_debug = "false"*) reg pe2ramout_done;
    (* mark_debug = "false"*) wire pe2ramout_end;

    (* mark_debug = "false"*) wire ramout2axi_hask;
    (* mark_debug = "false"*) reg ramout2axi_done;
    (* mark_debug = "false"*) wire ramout2axi_end;

    (* mark_debug = "false"*) reg [MAX_STAGE-1:0] axi2ramin_cnt;
    (* mark_debug = "false"*) reg [RAMIO_WIDTH-1:0] ramin2pe_cnt;
    (* mark_debug = "false"*) reg [RAMIO_WIDTH-1:0] pe2ram_cnt;
    (* mark_debug = "false"*) reg [MAX_STAGE-1:0] ramout2axi_cnt;

    //ADDR
    wire [ADDR_H_WIDTH-1:0] axi2ramin_h_addr;
    wire [ADDR_L_WIDTH-1:0] axi2ramin_l_addr;
    wire [RAMIO_WIDTH-1:0] ramin2pe_addr;
    wire [RAMIO_WIDTH-1:0] pe2ramin_addr[3:0];
    wire [RAMIO_WIDTH-1:0] pe2ramout_addr[3:0];
    wire [RAMIO_WIDTH-1:0] ramout2axi_addr;

    //CTRL Stream FLAG
    reg [MAX_STAGE-1:0] ramcnt_total;
    reg [DOUBLE_RAM_IN_WIDTH-1:0] ram_in_num_i_reg;
    reg [DOUBLE_RAM_IN_WIDTH-1:0] ram_in_back_num_i_reg;
    reg [DOUBLE_RAM_IN_WIDTH-1:0] ram_in_num_o_reg;
    reg [DOUBLE_RAM_OUT_WIDTH-1:0] ram_out_num_i_reg;
    reg [DOUBLE_RAM_OUT_WIDTH-1:0] ram_out_num_o_reg;
    reg [MDC_STAGE-1:0] mdc_stage_reg;
    reg [3:0] mdc_left_stage;

    //RAM ready vaild flag
    (* mark_debug = "false"*) reg [2:0] ram_in_cnt;
    (* mark_debug = "false"*) reg [2:0] ram_out_cnt;
    (* mark_debug = "false"*) wire ram_in_empty = (ram_in_cnt == 0);
    (* mark_debug = "false"*) wire ram_in_full = (ram_in_cnt >= (RAM_IN_NUM - 1));
    wire ram_out_empty = (ram_out_cnt == 0);
    wire ram_out_full = (ram_out_cnt >= RAM_OUT_NUM);



    //1 fft sign cnt 
    always @(posedge clk) begin
        if (!rstn) begin
            ramcnt_total <= {MAX_STAGE{1'b1}};
        end else begin
            ramcnt_total <= (1 << fft_stage) - 1;
        end
    end

    //Double buff flag
    //empty flag
    always @(posedge clk) begin
        if (!rstn || !fft_start) begin
            ram_in_cnt <= 3'b0;
        end else if (axi2ramin_end) begin
            ram_in_cnt <= ram_in_cnt + 1;
        end else if (pe2ramout_end) begin
            ram_in_cnt <= ram_in_cnt - 1;
        end
    end

    always @(posedge clk) begin
        if (!rstn || !fft_start) begin
            ram_out_cnt <= 3'b0;
        end else if (pe2ramout_end) begin
            ram_out_cnt <= ram_out_cnt + 1;
        end else if (ramout2axi_end) begin
            ram_out_cnt <= ram_out_cnt - 1;
        end
    end

    //RAM IN
    reg [2:0] ram_in_change_i;  //delay 3 loop (ctrl 1 loop + ram 2 loop)
    reg [2:0] ram_in_back_change_i;  //delay 3 loop (ctrl 1 loop + ram 2 loop)
    reg [2:0] ram_in_change_o;  //delay 3 loop (ctrl 1 loop + ram 2 loop)
    always @(posedge clk) begin
        if (!rstn) begin
            ram_in_change_i <= 3'b0;
            ram_in_back_change_i <= 3'b0;
            ram_in_change_o <= 3'b0;
        end else begin
            ram_in_change_i <= {ram_in_change_i[1:0], axi2ramin_end};
            ram_in_back_change_i <= {ram_in_back_change_i[1:0], pe2ramin_end};
            ram_in_change_o <= {ram_in_change_o[1:0], ramin2pe_end};
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            ram_in_num_i_reg <= {DOUBLE_RAM_IN_WIDTH{1'b0}};
        end else if (ram_in_change_i[2]) begin
            ram_in_num_i_reg <= {ram_in_num_i_reg[1], ~ram_in_num_i_reg[0]};
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            ram_in_back_num_i_reg <= 2;
        end else if (ram_in_back_change_i[2]) begin
            if (mdc_left_stage[3:2] == 2'b01) begin  //pe first loop end
                if (ram_in_full) begin  //if ram in full 2nd axi->ram in end
                    ram_in_back_num_i_reg <= ram_in_num_i_reg;
                end else begin
                    ram_in_back_num_i_reg <= {ram_in_num_i_reg[1], ~ram_in_num_i_reg[0]};
                end
            end else begin  //pe 2nd loop end
                ram_in_back_num_i_reg <= 2;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            ram_in_num_o_reg <= {DOUBLE_RAM_IN_WIDTH{1'b0}};
        end else if (ram_in_change_o[2]) begin
            if(mdc_left_stage[3]|(mdc_left_stage[3:2]==2'b01))begin //pe first and 2nd loop start
                ram_in_num_o_reg <= ram_in_back_num_i_reg;
            end else begin  //pe 3rd loop start
                if (ram_in_full) begin  //if ram in full 2nd axi->ram in end
                    ram_in_num_o_reg <= {ram_in_num_i_reg[1], ~ram_in_num_i_reg[0]};
                end else begin
                    ram_in_num_o_reg <= ram_in_num_i_reg;
                end
            end
        end
    end

    assign ram_in_num_i = ram_in_num_i_reg;
    assign ram_in_back_num_i = ram_in_back_num_i_reg;
    assign ram_in_num_o = ram_in_num_o_reg;

    //RAM OUT
    reg [2:0] ram_out_change_i;  //delay 3 loop (ctrl 1 loop + ram 2 loop)
    reg [2:0] ram_out_change_o;  //delay 3 loop (ctrl 1 loop + ram 2 loop)
    always @(posedge clk) begin
        if (!rstn) begin
            ram_out_change_i <= 3'b0;
            ram_out_change_o <= 3'b0;
        end else begin
            ram_out_change_i <= {ram_out_change_i[1:0], pe2ramout_end};
            ram_out_change_o <= {ram_out_change_o[1:0], ramout2axi_end};
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            ram_out_num_i_reg <= {DOUBLE_RAM_OUT_WIDTH{1'b0}};
        end else if (ram_out_change_i[2]) begin
            ram_out_num_i_reg <= ~ram_out_num_i_reg;
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            ram_out_num_o_reg <= {DOUBLE_RAM_OUT_WIDTH{1'b0}};
        end else if (ram_out_change_o[2]) begin
            ram_out_num_o_reg <= ~ram_out_num_o_reg;
        end
    end

    assign ram_out_num_i = ram_out_num_i_reg;
    assign ram_out_num_o = ram_out_num_o_reg;

    //MDC STAGE
    always @(posedge clk) begin
        if (!rstn) begin
            mdc_left_stage <= 3'b0;
        end else if ((axi2ramin_end & ram_in_empty) | (pe2ramout_end & ram_in_full)) begin
            mdc_left_stage <= fft_stage - 1;
        end else if (pe2ramin_end) begin
            mdc_left_stage <= mdc_left_stage - MDC_STAGE;
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            mdc_stage_reg <= {MDC_STAGE{1'b0}};
        end else begin
            case (mdc_left_stage)
                4'b0000: begin
                    mdc_stage_reg <= 4'b0001;
                end
                4'b0001: begin
                    mdc_stage_reg <= 4'b0010;
                end
                4'b0010: begin
                    mdc_stage_reg <= 4'b0100;
                end
                4'b0011: begin
                    mdc_stage_reg <= 4'b1000;
                end
                default: begin
                    mdc_stage_reg <= 4'b0000;
                end
            endcase
        end
    end

    assign fft_core_out_stage = mdc_stage_reg;

    /***************************************************************************************/
    /******************************* STAGE CTRL ********************************************/
    /***************************************************************************************/

    //================== AXI -> RAM IN ========================//
    //CNT
    always @(posedge clk) begin
        if (!rstn) begin
            axi2ramin_cnt <= {MAX_STAGE{1'b0}};
        end else if (axi2ramin_end) begin
            axi2ramin_cnt <= {MAX_STAGE{1'b0}};
        end else if (axi2ramin_hask) begin
            axi2ramin_cnt <= axi2ramin_cnt + BUS_DATA_NUM;
        end
    end

    //FLAG
    assign axi2ramin_hask = (&bus_i_hask) & fft_start;
    assign axi2ramin_end = (axi2ramin_cnt[MAX_STAGE-1:BUS_PARALLEL]==ramcnt_total[MAX_STAGE-1:BUS_PARALLEL])&fft_start;


    //antibit sort
    wire [MAX_STAGE-1:0] antibit_cnt;
    generate
        ;
        for (i = 0; i < MAX_STAGE; i = i + 1) begin
            assign antibit_cnt[i]=(fft_stage>i)?axi2ramin_cnt[fft_stage-i-1]:{MAX_STAGE{1'b0}};
        end
    endgenerate

    wire [ADDR_C_WIDTH-1:0] axi2ramin_channal;

    assign axi2ramin_channal = antibit_cnt[fft_stage-1-:ADDR_C_WIDTH];
    assign axi2ramin_h_addr = {axi2ramin_channal, antibit_cnt[0]};
    assign axi2ramin_l_addr = (fft_stage==9)?antibit_cnt[9-ADDR_C_WIDTH-1:1]:
                        (fft_stage==10)?antibit_cnt[10-ADDR_C_WIDTH-1:1]:
                        (fft_stage==11)?antibit_cnt[11-ADDR_C_WIDTH-1:1]:
                        (fft_stage==12)?antibit_cnt[12-ADDR_C_WIDTH-1:1]:0;


    //=================== RAM IN -> PE =========================//

    //CNT
    always @(posedge clk) begin
        if (!rstn) begin
            ramin2pe_cnt <= {RAMIO_WIDTH{1'b0}};
        end else if (ramin2pe_ena) begin
            ramin2pe_cnt <= ramin2pe_cnt + 1;
        end else begin
            ramin2pe_cnt <= {RAMIO_WIDTH{1'b0}};
        end
    end

    //FLAG
    assign ramin2pe_ena = fft_start & (!ram_in_empty) & (!ramin2pe_done);
    assign ramin2pe_end = (ramin2pe_cnt == ramcnt_total[MAX_STAGE-1:PARALLEL_WIDTH]) & fft_start;
    //FIX(P2R.3): 趟边界读放行延迟——回写结束脉冲后延迟 PASS_GAP_DLY 拍再放行下一趟读,
    // 恢复 valid 链气泡使换相器 switch_cnt 在趟间复位(对齐旧版内置PE架构的自然行为),
    // 消除"读超前写+ALU重填期假有效零"导致的换相相位错锁
    localparam PASS_GAP_DLY = 10;
    reg [PASS_GAP_DLY-1:0] pe_end_dly;
    always @(posedge clk) begin
        if (!rstn) begin
            pe_end_dly <= 'b0;
        end else begin
            pe_end_dly <= {pe_end_dly[PASS_GAP_DLY-2:0], pe2ramin_end | pe2ramout_end};
        end
    end
    always @(posedge clk) begin
        if (!rstn) begin
            ramin2pe_done <= 1'b0;
        end else if (ramin2pe_end) begin
            ramin2pe_done <= 1'b1;
        end else if (pe_end_dly[PASS_GAP_DLY-1]) begin
            ramin2pe_done <= 1'b0;
        end
    end

    //ADDRESS
    assign ramin2pe_addr = ramin2pe_cnt;


    //=================== PE -> RAM IN=========================//
    localparam PEBUFF_DEPTH = 16;
    localparam PEBUFF_CNT = $clog2(PEBUFF_DEPTH);
    localparam PEBUFF_LOOP = $clog2(MDC_PARALLEL / 2);  //Buff loop length: 2/3/4
    localparam PEBUFF_LCNT = $clog2(PEBUFF_DEPTH * 2 / MDC_PARALLEL);  //loop cnt width: 2/1/0

    //CNT
    always @(posedge clk) begin
        if (!rstn) begin
            pe2ram_cnt <= {RAMIO_WIDTH{1'b0}};
        end else if (pe2ramin_ena | pebuff2ramin_vaild) begin
            if((pe2ram_cnt[PEBUFF_CNT-1:0]=={PEBUFF_CNT{1'b1}})&(~pebuff2ramin_vaild))begin //load buff loop
                pe2ram_cnt <= {RAMIO_WIDTH{1'b0}};
            end else begin
                pe2ram_cnt <= pe2ram_cnt + 1;
            end
        end else if (pe2ramout_ena | pebuff2ramout_vaild) begin
            if((pe2ram_cnt[PEBUFF_CNT-1:0]=={PEBUFF_CNT{1'b1}})&(~pebuff2ramout_vaild))begin //load buff loop
                pe2ram_cnt <= {RAMIO_WIDTH{1'b0}};
            end else begin
                pe2ram_cnt <= pe2ram_cnt + 1;
            end
        end else begin
            pe2ram_cnt <= {RAMIO_WIDTH{1'b0}};
        end
    end

    //FLAG
    assign pe2ramin_ena = fft_start & (|fft_core_vaild) & (mdc_stage_reg == 0);
    assign pe2ramin_end = (pe2ram_cnt==ramcnt_total[MAX_STAGE-1:PARALLEL_WIDTH])&pebuff2ramin_vaild;


    //ADDRESS
    wire [1:0] pe2ram_addr_1_off = pe2ram_cnt[1:0] + 1;
    wire [1:0] pe2ram_addr_2_off = pe2ram_cnt[1:0] + 2;
    wire [1:0] pe2ram_addr_3_off = pe2ram_cnt[1:0] + 3;
    assign pe2ramin_addr[0] = (pe2ram_cnt[PEBUFF_CNT-1:0]<<(fft_stage-PEBUFF_LOOP-5))+pe2ram_cnt[RAMIO_WIDTH-1:PEBUFF_CNT];
    assign pe2ramin_addr[1] = (pe2ram_cnt[PEBUFF_CNT-1:2]<<(fft_stage-PEBUFF_LOOP-3))+(pe2ram_addr_1_off<<(fft_stage-PEBUFF_LOOP-5))+pe2ram_cnt[RAMIO_WIDTH-1:PEBUFF_CNT];
    assign pe2ramin_addr[2] = (pe2ram_cnt[PEBUFF_CNT-1:2]<<(fft_stage-PEBUFF_LOOP-3))+(pe2ram_addr_2_off<<(fft_stage-PEBUFF_LOOP-5))+pe2ram_cnt[RAMIO_WIDTH-1:PEBUFF_CNT];
    assign pe2ramin_addr[3] = (pe2ram_cnt[PEBUFF_CNT-1:2]<<(fft_stage-PEBUFF_LOOP-3))+(pe2ram_addr_3_off<<(fft_stage-PEBUFF_LOOP-5))+pe2ram_cnt[RAMIO_WIDTH-1:PEBUFF_CNT];

    //=================== PE -> RAM OUT =========================//

    //FLAG
    assign pe2ramout_ena = fft_start & fft_core_vaild & (mdc_stage_reg != 0) & (!ram_out_full);
    assign pe2ramout_end = (pe2ram_cnt==ramcnt_total[MAX_STAGE-1:PARALLEL_WIDTH])&pebuff2ramout_vaild&fft_start;
    always @(posedge clk) begin
        if (!rstn) begin
            pe2ramout_done <= 1'b0;
        end else if (pe2ramout_end) begin
            pe2ramout_done <= 1'b1;
        end else if (ramout2axi_end) begin
            pe2ramout_done <= 1'b0;
        end
    end

    //ADDRESS
    assign pe2ramout_addr[0] = (pe2ram_cnt[PEBUFF_CNT-1:0]<<(fft_stage-PEBUFF_LOOP-5))+pe2ram_cnt[RAMIO_WIDTH-1:PEBUFF_CNT];
    assign pe2ramout_addr[1] = (pe2ram_cnt[PEBUFF_CNT-1:2]<<(fft_stage-PEBUFF_LOOP-3))+(pe2ram_addr_1_off<<(fft_stage-PEBUFF_LOOP-5))+pe2ram_cnt[RAMIO_WIDTH-1:PEBUFF_CNT];
    assign pe2ramout_addr[2] = (pe2ram_cnt[PEBUFF_CNT-1:2]<<(fft_stage-PEBUFF_LOOP-3))+(pe2ram_addr_2_off<<(fft_stage-PEBUFF_LOOP-5))+pe2ram_cnt[RAMIO_WIDTH-1:PEBUFF_CNT];
    assign pe2ramout_addr[3] = (pe2ram_cnt[PEBUFF_CNT-1:2]<<(fft_stage-PEBUFF_LOOP-3))+(pe2ram_addr_3_off<<(fft_stage-PEBUFF_LOOP-5))+pe2ram_cnt[RAMIO_WIDTH-1:PEBUFF_CNT];


    //=================== RAM OUT -> AXI =========================//
    //CNT
    always @(posedge clk) begin
        if (!rstn) begin
            ramout2axi_cnt <= {MAX_STAGE{1'b0}};
        end else if (ramout2axi_end) begin
            ramout2axi_cnt <= {MAX_STAGE{1'b0}};
        end else if (ramout2axi_hask) begin
            ramout2axi_cnt <= ramout2axi_cnt + BUS_DATA_NUM;
        end
    end

    //FLAG
    reg [2:0] ramout2axi_end_delay;  //ramout2axi_hask need set0 3 loops for change ram
    assign ramout2axi_hask = fft_start & (!ram_out_empty) & (&bus_o_ready);
    assign ramout2axi_end = (ramout2axi_cnt[MAX_STAGE-1:BUS_PARALLEL]==ramcnt_total[MAX_STAGE-1:BUS_PARALLEL])&fft_start;

    always @(posedge clk) begin
        if (!rstn) begin
            ramout2axi_end_delay <= 3'b0;
        end else begin
            ramout2axi_end_delay <= {ramout2axi_end_delay[1:0], ramout2axi_end};
        end
    end


    //ADDRESS
    assign ramout2axi_addr = (fft_stage == 9) ? {ramout2axi_cnt[1],ramout2axi_cnt[RAMIO_WIDTH-1:4]} :
                         (fft_stage == 10) ? ramout2axi_cnt[RAMIO_WIDTH-0:3] :
                         (fft_stage == 11) ? ramout2axi_cnt[RAMIO_WIDTH-0:2] :
                         (fft_stage == 12) ? ramout2axi_cnt[RAMIO_WIDTH-0:1] :
                         {RAMIO_WIDTH{1'b0}};


    /*************************************************************************************/
    /***************************** ARRAY SORT ********************************************/
    /*************************************************************************************/
    always @(posedge clk) begin
        if (!rstn) begin
            pebuff2ramin_vaild <= 1'b0;
        end else if (pe2ram_cnt[PEBUFF_CNT-1:0] == {PEBUFF_CNT{1'b1}}) begin
            if (pe2ramin_ena) begin
                pebuff2ramin_vaild <= 1'b1;
            end else begin
                pebuff2ramin_vaild <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            pebuff2ramout_vaild <= 1'b0;
        end else if (pe2ram_cnt[PEBUFF_CNT-1:0] == {PEBUFF_CNT{1'b1}}) begin
            if (pe2ramout_ena) begin
                pebuff2ramout_vaild <= 1'b1;
            end else begin
                pebuff2ramout_vaild <= 1'b0;
            end
        end
    end

    assign array_sort_vaild = pebuff2ramin_vaild | pebuff2ramout_vaild;
    assign array_sort_cnt   = pe2ram_cnt;

    /*************************************************************************************/
    /******************************* RAM CTRL ********************************************/
    /*************************************************************************************/

    //=======================RAM IN=============================//
    reg [RAMIO_WIDTH-1:0] ram_in_addr_i_reg[MDC_PARALLEL-1:0];
    reg [RAMIO_WIDTH-1:0] ram_in_back_addr_i_reg[MDC_PARALLEL-1:0];
    reg [MDC_PARALLEL-1:0] ram_in_ena_i_reg[RAM_IN_NUM-1:0];

    reg [RAMIO_WIDTH-1:0] ram_in_addr_o_reg;
    reg ram_in_ena_o_reg[RAM_IN_NUM-1:0];

    generate
        if (BUS_DATA_NUM == 1) begin : BUSIN32
            //ena(32bit Width)
            always @(posedge clk) begin
                if (pebuff2ramin_vaild & (ram_in_back_num_i_reg == 0)) begin
                    ram_in_ena_i_reg[0] <= {MDC_PARALLEL{1'b1}};
                end else if ((ram_in_num_i_reg == 0) & (axi2ramin_hask)) begin
                    ram_in_ena_i_reg[0] <= 1 << (axi2ramin_h_addr);
                end else begin
                    ram_in_ena_i_reg[0] <= {MDC_PARALLEL{1'b0}};
                end
            end
            always @(posedge clk) begin
                if (pebuff2ramin_vaild & (ram_in_back_num_i_reg == 1)) begin
                    ram_in_ena_i_reg[1] <= {MDC_PARALLEL{1'b1}};
                end else if ((ram_in_num_i_reg == 1) & (axi2ramin_hask)) begin
                    ram_in_ena_i_reg[1] <= 1 << (axi2ramin_h_addr);
                end else begin
                    ram_in_ena_i_reg[1] <= {MDC_PARALLEL{1'b0}};
                end
            end
        end else begin : BUSIN64
            //ena(64bit Width)
            always @(posedge clk) begin
                if (pebuff2ramin_vaild & (ram_in_back_num_i_reg == 0)) begin
                    ram_in_ena_i_reg[0] <= {MDC_PARALLEL{1'b1}};
                end else if ((ram_in_num_i_reg == 0) & (axi2ramin_hask)) begin
                    ram_in_ena_i_reg[0] <= (1 << axi2ramin_h_addr ) + (1 << (axi2ramin_h_addr + MDC_PARALLEL/2));
                end else begin
                    ram_in_ena_i_reg[0] <= {MDC_PARALLEL{1'b0}};
                end
            end
            always @(posedge clk) begin
                if (pebuff2ramin_vaild & (ram_in_back_num_i_reg == 1)) begin
                    ram_in_ena_i_reg[1] <= {MDC_PARALLEL{1'b1}};
                end else if ((ram_in_num_i_reg == 1) & (axi2ramin_hask)) begin
                    ram_in_ena_i_reg[1] <= (1 << axi2ramin_h_addr ) + (1 << (axi2ramin_h_addr + MDC_PARALLEL/2));
                end else begin
                    ram_in_ena_i_reg[1] <= {MDC_PARALLEL{1'b0}};
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (pebuff2ramin_vaild & (ram_in_back_num_i_reg == 2)) begin
            ram_in_ena_i_reg[2] <= {MDC_PARALLEL{1'b1}};
        end else begin
            ram_in_ena_i_reg[2] <= {MDC_PARALLEL{1'b0}};
        end
    end

    always @(posedge clk) begin
        if (ramin2pe_ena) begin
            if (ram_in_num_o_reg == 0) begin
                ram_in_ena_o_reg[0] <= 1'b1;
                ram_in_ena_o_reg[1] <= 1'b0;
                ram_in_ena_o_reg[2] <= 1'b0;
            end else if (ram_in_num_o_reg == 1) begin
                ram_in_ena_o_reg[0] <= 1'b0;
                ram_in_ena_o_reg[1] <= 1'b1;
                ram_in_ena_o_reg[2] <= 1'b0;
            end else begin
                ram_in_ena_o_reg[0] <= 1'b0;
                ram_in_ena_o_reg[1] <= 1'b0;
                ram_in_ena_o_reg[2] <= 1'b1;
            end
        end else begin
            ram_in_ena_o_reg[0] <= 1'b0;
            ram_in_ena_o_reg[1] <= 1'b0;
            ram_in_ena_o_reg[2] <= 1'b0;
        end
    end

    //addr
    always @(posedge clk) begin
        if (axi2ramin_hask) begin
            for (p = 0; p < MDC_PARALLEL; p = p + 1) begin
                ram_in_addr_i_reg[p] <= axi2ramin_l_addr;
            end
        end else begin
            for (p = 0; p < MDC_PARALLEL; p = p + 1) begin
                ram_in_addr_i_reg[p] <= {RAMIO_WIDTH{1'b0}};
            end
        end
    end


    always @(posedge clk) begin
        if (pebuff2ramin_vaild) begin
            for (p = 0; p < MDC_PARALLEL; p = p + 1) begin
                ram_in_back_addr_i_reg[p] <= pe2ramin_addr[p[3:1]];
            end
        end else begin
            for (p = 0; p < MDC_PARALLEL; p = p + 1) begin
                ram_in_back_addr_i_reg[p] <= {RAMIO_WIDTH{1'b0}};
            end
        end
    end

    always @(posedge clk) begin
        if (ramin2pe_ena) begin
            ram_in_addr_o_reg <= ramin2pe_addr;
        end else begin
            ram_in_addr_o_reg <= {RAMIO_WIDTH{1'b0}};
        end
    end

    //out
    generate
        ;
        for (i = 0; i < MDC_PARALLEL; i = i + 1) begin
            assign ram_in_ena_i[0][i] = ram_in_ena_i_reg[0][i];
            assign ram_in_ena_i[1][i] = ram_in_ena_i_reg[1][i];
            assign ram_in_ena_i[2][i] = ram_in_ena_i_reg[2][i];
            assign ram_in_addr_i[0][i]=(ram_in_back_num_i_reg==0)?ram_in_back_addr_i_reg[i]:ram_in_addr_i_reg[i];
            assign ram_in_addr_i[1][i]=(ram_in_back_num_i_reg==1)?ram_in_back_addr_i_reg[i]:ram_in_addr_i_reg[i];
            assign ram_in_addr_i[2][i] = ram_in_back_addr_i_reg[i];
            assign ram_in_addr_o[i] = ram_in_addr_o_reg;
        end
    endgenerate

    genvar ri;
    generate
        for (ri = 0; ri < RAM_IN_NUM; ri = ri + 1) begin
            assign ram_in_ena_o[ri] = ram_in_ena_o_reg[ri];
        end
    endgenerate

    //=======================RAM OUT=============================//
    reg [RAMIO_WIDTH-1:0] ram_out_addr_i_reg[MDC_PARALLEL-1:0];
    reg ram_out_ena_i_reg[RAM_OUT_NUM-1:0];

    reg [RAMIO_WIDTH-1:0] ram_out_addr_o_reg;
    reg [MDC_PARALLEL-1:0] ram_out_ena_o_reg[RAM_OUT_NUM-1:0];

    //ena
    always @(posedge clk) begin
        if (pebuff2ramout_vaild & (!ram_out_num_i_reg)) begin
            ram_out_ena_i_reg[0] <= 1'b1;
        end else begin
            ram_out_ena_i_reg[0] <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (pebuff2ramout_vaild & ram_out_num_i_reg) begin
            ram_out_ena_i_reg[1] <= 1'b1;
        end else begin
            ram_out_ena_i_reg[1] <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (ramout2axi_hask & (!ram_out_num_o_reg)) begin
            ram_out_ena_o_reg[0] <= {MDC_PARALLEL{1'b1}};
        end else begin
            ram_out_ena_o_reg[0] <= {MDC_PARALLEL{1'b0}};
        end
    end

    always @(posedge clk) begin
        if (ramout2axi_hask & ram_out_num_o_reg) begin
            ram_out_ena_o_reg[1] <= {MDC_PARALLEL{1'b1}};
        end else begin
            ram_out_ena_o_reg[1] <= {MDC_PARALLEL{1'b0}};
        end
    end

    //addr
    always @(posedge clk) begin
        if (pebuff2ramout_vaild) begin
            for (p = 0; p < MDC_PARALLEL; p = p + 1) begin
                ram_out_addr_i_reg[p] <= pe2ramout_addr[p[3:1]];
            end
        end else begin
            for (p = 0; p < MDC_PARALLEL; p = p + 1) begin
                ram_out_addr_i_reg[p] <= {RAMIO_WIDTH{1'b0}};
            end
        end
    end

    always @(posedge clk) begin
        if (ramout2axi_hask) begin
            ram_out_addr_o_reg <= ramout2axi_addr;
        end else begin
            ram_out_addr_o_reg <= {RAMIO_WIDTH{1'b0}};
        end
    end

    //out
    generate
        ;
        for (i = 0; i < MDC_PARALLEL; i = i + 1) begin
            assign ram_out_ena_o[0][i] = ram_out_ena_o_reg[0][i];
            assign ram_out_ena_o[1][i] = ram_out_ena_o_reg[1][i];
            assign ram_out_addr_i[i]   = ram_out_addr_i_reg[i];
            assign ram_out_addr_o[i]   = ram_out_addr_o_reg;
        end
    endgenerate

    assign ram_out_ena_i[0] = ram_out_ena_i_reg[0];
    assign ram_out_ena_i[1] = ram_out_ena_i_reg[1];


    //=======================ROM WEIGHT=============================//
    reg [ROM_WIDTH-1:0] rom_weight_addr_reg;
    reg rom_weight_ena_reg;
    reg mdc_frs_stage_reg;

    //ena
    always @(posedge clk) begin
        if (ramin2pe_ena) begin
            rom_weight_ena_reg <= 1'b1;
        end else begin
            rom_weight_ena_reg <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (ramin2pe_ena & mdc_left_stage[3]) begin
            mdc_frs_stage_reg <= 1'b1;
        end else begin
            mdc_frs_stage_reg <= 1'b0;
        end
    end


    //addr
    always @(posedge clk) begin
        if (ramin2pe_ena) begin
            if (mdc_left_stage[3] | (mdc_left_stage == 3)) begin
                rom_weight_addr_reg <= ramin2pe_cnt;
            end else begin
                case (mdc_left_stage)
                    4'b0000: begin
                        rom_weight_addr_reg <= {ramin2pe_cnt[RAMIO_WIDTH-4:0], 3'b0};
                    end
                    4'b0001: begin
                        rom_weight_addr_reg <= {
                            ramin2pe_cnt[RAMIO_WIDTH-3:1], 2'b0, ramin2pe_cnt[0]
                        };
                    end
                    4'b0010: begin
                        rom_weight_addr_reg <= {
                            ramin2pe_cnt[RAMIO_WIDTH-2:2], 1'b0, ramin2pe_cnt[1:0]
                        };
                    end
                    default: begin
                        rom_weight_addr_reg<=((ramin2pe_cnt>>mdc_left_stage)<<7)+ramin2pe_cnt[2:0];
                    end
                endcase
            end
        end
    end


    //out
    assign rom_weight_addr = rom_weight_addr_reg;
    assign rom_weight_ena  = rom_weight_ena_reg;
    assign mdc_frs_stage   = mdc_frs_stage_reg;


    wire [MAX_STAGE-1:0] axiout_cnt = ramout2axi_cnt - RAM_DELAY * BUS_DATA_NUM;
    always @(posedge clk) begin
        if ((|ram_out_ena_o_reg[0]) | (|ram_out_ena_o_reg[1])) begin
            ramout2axi_num <= (fft_stage == 9) ? {axiout_cnt[3:2],axiout_cnt[0]} :
                            (fft_stage == 10) ? axiout_cnt[2:0] :
                            (fft_stage == 11) ? {axiout_cnt[1],axiout_cnt[10],axiout_cnt[0]}  :
                            (fft_stage == 12) ? {axiout_cnt[11:10],axiout_cnt[0]} :'b0;
        end
    end


    assign bus_i_ready = !ram_in_full && &bus_i_vaild;

endmodule


