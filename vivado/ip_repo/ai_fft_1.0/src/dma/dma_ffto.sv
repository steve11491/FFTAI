

module dma_ffto #(
    parameter DATA_WIDTH = 32,
    parameter BUS_WIDTH = 32,
    parameter BUS_ADDR_WIDTH = 32,

    parameter FFT_SIGNLEN_WIDTH = 16,
    parameter FFT_CORE_COL = 8,
    parameter FFT_CORE_NUM = 1,

    parameter BUS_DATA_NUM = BUS_WIDTH / DATA_WIDTH
    
) (
    input clk,
    input rstn,

    //CTL
    input is_fft,
    input fft_config,
    input fft_start,
    input [3:0] burst_num, //depend on fft stage
    input [FFT_SIGNLEN_WIDTH-1:0]fft_sign_len,

    //STA
    output ffto_done_pulse,

    //BUS Write Channal
    input w_addr_ready,
    output w_addr_valid,  
    output [BUS_ADDR_WIDTH-1:0] w_offset_addr,
    output [8-1:0] w_burst_len,

    input w_data_ready,
    output reg [BUS_WIDTH-1:0] w_data,
    output w_data_valid,
    output w_data_wlast,

    //BUS Read Channal(no use)
    input r_addr_ready,
    output r_addr_valid,  
    output [BUS_ADDR_WIDTH-1:0] r_offset_addr,
    output [8-1:0] r_burst_len,

    output r_data_ready,
    input [BUS_WIDTH-1:0] r_data,
    input r_data_valid,
    input r_data_rlast,

    //FFT RAM OUT Data
    output ffto_wready,
    input ffto_wvaild,
    input [DATA_WIDTH-1:0]ffto_data[BUS_DATA_NUM-1:0]

);

localparam FIFO_DEPTH = 256;
localparam DATA_FIFO_COUNT_WIDTH = $clog2(FIFO_DEPTH)+1;
localparam BURST_LEN = 256;//AXI4 MAX BURST
localparam BURST_OFFSET = BURST_LEN * BUS_WIDTH / 8;
localparam BURST_CNT_WIDTH = $clog2(BURST_LEN);
localparam RAMOUT_DELAY = 2; //delay 2 loops

/*************************RAM -> FIFO************************/
//===================Control======================//
(* mark_debug = "true"*)wire w_fifo_hask = ffto_wvaild ;
//burst len cnt+
(* mark_debug = "true"*)reg[BURST_CNT_WIDTH-1:0] wfifo_burst_cnt;
always @(posedge clk)begin
    if(!rstn)begin
        wfifo_burst_cnt<='b0;
    end
    else if(w_fifo_hask)begin
        wfifo_burst_cnt<=wfifo_burst_cnt+1;
    end
end


(* mark_debug = "true"*)wire [DATA_FIFO_COUNT_WIDTH-1:0]ffto_data_fifo_counter;
assign ffto_wready = (ffto_data_fifo_counter < (FIFO_DEPTH - RAMOUT_DELAY)); //ffto_data_fifo full

//===================FIFO======================//
(* mark_debug = "true"*)wire ffto_data_fifo_wr_en;
(* mark_debug = "true"*)wire ffto_data_fifo_rd_en;
(* mark_debug = "false"*)wire [BUS_WIDTH-1:0]ffto_data_fifo_wr_data;
(* mark_debug = "false"*)wire [BUS_WIDTH-1:0]ffto_data_fifo_rd_data;
(* mark_debug = "true"*)wire ffto_data_fifo_rd_valid;
(* mark_debug = "true"*)wire ffto_data_fifo_empty;
(* mark_debug = "true"*)wire ffto_data_fifo_full;
sync_fifo_cnt #(
    .WIDTH(BUS_WIDTH),
    .DEPTH(FIFO_DEPTH),
    .RAM_STYLE_VAL("block")
) fifo_ffto_data (
    .clk         (clk),
    .rstn        (rstn),
    .wr_en       (ffto_data_fifo_wr_en),
    .rd_en       (ffto_data_fifo_rd_en),
    .wr_data     (ffto_data_fifo_wr_data),
    .rd_data     (ffto_data_fifo_rd_data),
    .rd_valid    (ffto_data_fifo_rd_valid),
    .full        (ffto_data_fifo_full),
    .empty       (ffto_data_fifo_empty),
    .almost_full (),
    .almost_empty(),
    .fifo_counter(ffto_data_fifo_counter)
);



/*************************FIFO -> AXI************************/

//===================Control======================//
(* mark_debug = "true"*)reg bus_w_data_valid;
(* mark_debug = "true"*)reg wtx_activate;
(* mark_debug = "true"*)wire r_fifo_hask = w_data_ready & wtx_activate & bus_w_data_valid;
//burst len cnt+
(* mark_debug = "true"*)reg[BURST_CNT_WIDTH-1:0] rfifo_burst_cnt;
always @(posedge clk)begin
    if(!rstn || &rfifo_burst_cnt)begin
        rfifo_burst_cnt<='b0;
    end
    else if(r_fifo_hask)begin
        rfifo_burst_cnt<=rfifo_burst_cnt+1;
    end
end
//burst times cnt+
(* mark_debug = "true"*)reg[3:0] w_burst_cnt; 
always @(posedge clk)begin
    if(!rstn || fft_config || w_burst_cnt == burst_num)begin
        w_burst_cnt <= 4'b0;
    end
    else if(fft_start && &rfifo_burst_cnt)begin
        w_burst_cnt <= w_burst_cnt + 1;
    end
end

//fft sign in cnt-
(* mark_debug = "true"*)reg [FFT_SIGNLEN_WIDTH-1:0] fft_sign_cnt;
always @(posedge clk)begin
    if(!rstn )begin
        fft_sign_cnt <= 'b0;
    end
    else if(fft_config)begin
        fft_sign_cnt <= fft_sign_len;
    end
    else if (fft_start && w_burst_cnt == burst_num && fft_sign_cnt != 0) begin
        if(fft_sign_cnt > FFT_CORE_NUM)begin
            fft_sign_cnt <= fft_sign_cnt - FFT_CORE_NUM;
        end
        else begin
            fft_sign_cnt <= 'b0;
        end
    end
end

//====================State=======================//
(* mark_debug = "true"*)reg [FFT_SIGNLEN_WIDTH-1:0]fft_sign_left_cnt;
always @(posedge clk)begin
    fft_sign_left_cnt <= fft_sign_cnt;
end
assign ffto_done_pulse = (fft_sign_cnt == 0)&(fft_sign_left_cnt != 0);

//====================BUS Flag===================//
//READ ADDR Channal
(* mark_debug = "true"*)wire init_wtx_pulse;
(* mark_debug = "true"*)reg wtx_vaild;
assign init_wtx_pulse = wtx_vaild && w_addr_ready;
always @(posedge clk)begin
    if(!rstn || init_wtx_pulse || fft_config)begin
        wtx_vaild <= 1'b0;
    end
    else if (fft_start && fft_sign_cnt != 0 && !wtx_activate && w_burst_cnt != burst_num) begin
        wtx_vaild <= 1'b1;
    end
end
always @(posedge clk)begin
    if(!rstn )begin
        wtx_activate <= 1'b0;
    end
    else if(init_wtx_pulse)begin
        wtx_activate <= 1'b1;
    end
    else if(&rfifo_burst_cnt)begin
        wtx_activate <= 1'b0;
    end
end

(* mark_debug = "true"*)reg [BUS_ADDR_WIDTH-1:0] offset_addr;
always @(posedge clk)begin
    if(!rstn || fft_config || fft_sign_cnt == 0)begin
        offset_addr <= 'b0;
    end
    else if (init_wtx_pulse) begin
        offset_addr <= offset_addr + BURST_OFFSET;
    end
end

assign w_addr_valid = wtx_vaild;
assign w_burst_len = BURST_LEN - 1;
assign w_offset_addr = offset_addr;

//READ DATA Channal
//delay 5 loop ,because w_data_ready error
(* mark_debug = "true"*)reg [3:0] bus_w_data_delay;
always @(posedge clk)begin
    if(!rstn || !fft_start || bus_w_data_delay == 4)begin
        bus_w_data_delay<=1'b0;
    end
    else if(bus_w_data_delay != 0 || &rfifo_burst_cnt)begin
        bus_w_data_delay<=bus_w_data_delay+1;
    end
end
always @(posedge clk)begin
    if(!rstn || fft_config || (ffto_data_fifo_empty && r_fifo_hask) || &rfifo_burst_cnt)begin
        bus_w_data_valid<=1'b0;
    end
    else if (!bus_w_data_valid && !ffto_data_fifo_empty && bus_w_data_delay == 0) begin
        bus_w_data_valid<=1'b1;
    end
end
assign w_data_wlast = &rfifo_burst_cnt;
assign w_data_valid = bus_w_data_valid;

//===================DATA PATH===================//

//FIFO 
assign ffto_data_fifo_wr_en = w_fifo_hask;
assign ffto_data_fifo_rd_en = (r_fifo_hask && !(&rfifo_burst_cnt)) || (!bus_w_data_valid && !ffto_data_fifo_empty && bus_w_data_delay == 0);
generate
    for(genvar n=0; n<BUS_DATA_NUM ; n=n+1)begin
        assign ffto_data_fifo_wr_data[DATA_WIDTH*(n+1)-1:DATA_WIDTH*n] = ffto_data[n];
    end
endgenerate

//AXI
assign w_data = ffto_data_fifo_rd_data;
    

endmodule




