

module dma_ffti #(
    parameter DATA_WIDTH = 32,
    parameter BUS_WIDTH = 32,
    parameter BUS_ADDR_WIDTH = 32,

    parameter FFT_SIGNLEN_WIDTH = 16,
    parameter FFT_CORE_COL = 8,
    parameter FFT_CORE_NUM = 1
    
) (
    input clk,
    input rstn,

    //CTL
    input is_fft,
    input fft_config,
    input fft_start,
    input is_ifft_mode,
    input [3:0] burst_num, //depend on fft stage
    input [FFT_SIGNLEN_WIDTH-1:0]fft_sign_len,

    //STA
    output ffti_done_pulse,

    //BUS Write Channal(no use)
    input w_addr_ready,
    output w_addr_valid,  
    output [BUS_ADDR_WIDTH-1:0] w_offset_addr,
    output [8-1:0] w_burst_len,

    input w_data_ready,
    output reg [BUS_WIDTH-1:0] w_data,
    output w_data_valid,
    output w_data_wlast,

    //BUS Read Channal
    input r_addr_ready,
    output r_addr_valid,  
    output [BUS_ADDR_WIDTH-1:0] r_offset_addr,
    output [8-1:0] r_burst_len,

    output r_data_ready,
    input [BUS_WIDTH-1:0] r_data,
    input r_data_valid,
    input r_data_rlast,

    //FFT RAM IN Data
    input ffti_rready,
    output ffti_rvaild, 
    output ffti_rhask, //before ffti_data 1 loop
    output reg [DATA_WIDTH-1:0]ffti_data[FFT_CORE_COL-1:0]

);

localparam FIFO_DEPTH = 2048;
localparam DATA_FIFO_COUNT_WIDTH = $clog2(FIFO_DEPTH)+1;
localparam BUS_DATA_NUM = BUS_WIDTH / DATA_WIDTH;
localparam BURST_LEN = 256;//AXI4 MAX BURST
localparam BURST_OFFSET = BURST_LEN * BUS_WIDTH / 8;

//pulse
wire r_data_rlast_pulse;
(* mark_debug = "true"*)reg r_data_rlast_delay;
always @(posedge clk)begin
    r_data_rlast_delay <= r_data_rlast;
end
assign r_data_rlast_pulse = r_data_rlast && !r_data_rlast_delay;

//===================FIFO======================//
(* mark_debug = "true"*)wire ffti_data_fifo_wr_en;
(* mark_debug = "true"*)wire ffti_data_fifo_rd_en;
(* mark_debug = "true"*)wire [BUS_WIDTH-1:0]ffti_data_fifo_wr_data;
(* mark_debug = "true"*)wire [BUS_WIDTH-1:0]ffti_data_fifo_rd_data;
(* mark_debug = "true"*)wire ffti_data_fifo_rd_valid;
(* mark_debug = "true"*)wire ffti_data_fifo_empty;
(* mark_debug = "true"*)wire ffti_data_fifo_full;
(* mark_debug = "true"*)wire [DATA_FIFO_COUNT_WIDTH-1:0]ffti_data_fifo_counter;
sync_fifo_cnt #(
    .WIDTH(BUS_WIDTH),
    .DEPTH(FIFO_DEPTH),
    .RAM_STYLE_VAL("block")
) fifo_ffti_data (
    .clk         (clk),
    .rstn        (rstn),
    .wr_en       (ffti_data_fifo_wr_en),
    .rd_en       (ffti_data_fifo_rd_en),
    .wr_data     (ffti_data_fifo_wr_data),
    .rd_data     (ffti_data_fifo_rd_data),
    .rd_valid    (ffti_data_fifo_rd_valid),
    .full        (),
    .empty       (ffti_data_fifo_empty),
    .almost_full (ffti_data_fifo_full),
    .almost_empty(),
    .fifo_counter(ffti_data_fifo_counter)
);

//===================Control======================//
//burst cnt+
(* mark_debug = "true"*)reg[3:0] r_burst_cnt;
always @(posedge clk)begin
    if(!rstn || fft_config || r_burst_cnt == burst_num)begin
        r_burst_cnt <= 4'b0;
    end
    else if(fft_start && r_data_rlast_pulse)begin
        r_burst_cnt <= r_burst_cnt + 1;
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
    else if (fft_start && r_burst_cnt == burst_num && fft_sign_cnt != 0) begin
        if(fft_sign_cnt > FFT_CORE_NUM)begin
            fft_sign_cnt <= fft_sign_cnt - FFT_CORE_NUM;
        end
        else begin
            fft_sign_cnt <= 'b0;
        end
    end
end

//====================State=======================//
reg [FFT_SIGNLEN_WIDTH-1:0]fft_sign_left_cnt;
always @(posedge clk)begin
    fft_sign_left_cnt <= fft_sign_cnt;
end
assign ffti_done_pulse = (fft_sign_cnt == 0)&(fft_sign_left_cnt != 0);

//====================BUS Flag===================//
//READ ADDR Channal
(* mark_debug = "true"*)wire init_rtx_pulse;
(* mark_debug = "true"*)reg rtx_vaild;
(* mark_debug = "true"*)reg rtx_activate;
assign init_rtx_pulse = rtx_vaild && r_addr_ready;
always @(posedge clk)begin
    if(!rstn || fft_config || init_rtx_pulse || ffti_data_fifo_full)begin
        rtx_vaild <= 1'b0;
    end
    else if (fft_start && fft_sign_cnt != 0 && !rtx_activate && r_burst_cnt != burst_num) begin
        rtx_vaild <= 1'b1;
    end
end
always @(posedge clk)begin
    if(!rstn )begin
        rtx_activate <= 1'b0;
    end
    else if(init_rtx_pulse)begin
        rtx_activate <= 1'b1;
    end
    else if(r_data_rlast_pulse)begin
        rtx_activate <= 1'b0;
    end
end

(* mark_debug = "true"*)reg [BUS_ADDR_WIDTH-1:0] offset_addr;
always @(posedge clk)begin
    if(!rstn || fft_config || fft_sign_cnt == 0)begin
        offset_addr <= 'b0;
    end
    else if (init_rtx_pulse) begin
        offset_addr <= offset_addr + BURST_OFFSET;
    end
end

assign r_addr_valid = rtx_vaild;
assign r_burst_len = BURST_LEN - 1;
assign r_offset_addr = offset_addr;

//READ DATA Channal
assign r_data_ready = rtx_activate && (ffti_data_fifo_counter < (FIFO_DEPTH-1));

//===================DATA PATH===================//
(* mark_debug = "true"*)wire r_data_hask = r_data_valid && rtx_activate && (ffti_data_fifo_counter < (BURST_LEN-1));
(* mark_debug = "true"*)wire [DATA_WIDTH-1:0] r_data_c[BUS_DATA_NUM-1:0];
generate
    for(genvar n=0; n<BUS_DATA_NUM ; n=n+1)begin
        assign r_data_c[n] = ffti_data_fifo_rd_data[DATA_WIDTH*(n+1)-1:DATA_WIDTH*n];
    end
endgenerate
always@(posedge clk)begin
    for(integer i=0; i<FFT_CORE_COL/BUS_DATA_NUM; i=i+1)begin
        for(integer j=0; j<BUS_DATA_NUM; j=j+1)begin
            ffti_data[i+j*FFT_CORE_COL/BUS_DATA_NUM] <= !is_ifft_mode ? r_data_c[j]:
            {~r_data_c[j][DATA_WIDTH-1:DATA_WIDTH/2]+1,r_data_c[j][DATA_WIDTH/2-1:0]}; 
        end
    end
end


//
assign ffti_data_fifo_wr_data = r_data;
assign ffti_data_fifo_wr_en = r_data_hask;
assign ffti_data_fifo_rd_en =  ffti_rready && !ffti_data_fifo_empty;

assign ffti_rvaild = !ffti_data_fifo_empty;
assign ffti_rhask = ffti_data_fifo_rd_valid;

endmodule




