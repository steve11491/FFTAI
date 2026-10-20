//=================================================================================
//
// Designer: SXH
//
// Description: DC Switch FIFO
//
//=================================================================================

module dc_switch_fifo #(
    parameter FFT_STAGE     = 2,
    parameter SWITCH_WIDTH  = 32
)(
    input                       switch_clk,
    input                       switch_rstn,
    input                       switch_ena,
    input [SWITCH_WIDTH-1:0]    switch_i_0,
    input [SWITCH_WIDTH-1:0]    switch_i_1,
    output [SWITCH_WIDTH-1:0]   switch_o_0,
    output [SWITCH_WIDTH-1:0]   switch_o_1,
    output                      switch_vaild
);
localparam FIFO_LENGTH = 1 << (FFT_STAGE-1);

//ena
reg [FIFO_LENGTH-1:0] read_ena;
always@(posedge switch_clk)begin
    if(!switch_rstn)begin
        read_ena <= {FIFO_LENGTH{1'b0}};
    end
    else begin
        read_ena<={read_ena[FIFO_LENGTH-2:0],switch_ena};
    end
end


//cnt 
reg [FFT_STAGE-1:0] switch_cnt;
always @(posedge switch_clk)begin
    if(!switch_rstn)begin
        switch_cnt <= {FFT_STAGE{1'b0}};
    end
    else if(switch_ena)begin
        switch_cnt <= switch_cnt + 1;
    end
    else begin
        switch_cnt <= {FFT_STAGE{1'b0}};
    end
end

//fifo 0
wire [SWITCH_WIDTH-1:0] fifo_0_i;
wire [SWITCH_WIDTH-1:0] fifo_0_o;

sync_fifo #(
    .FIFO_DEPTH(FIFO_LENGTH),
    .FIFO_WIDTH(SWITCH_WIDTH)
)fifo_0(
    .clk(switch_clk),
    .rst_n(switch_rstn),
    .wreq(switch_ena),
    .rreq(read_ena[FIFO_LENGTH-2]),
    .wdata(fifo_0_i),
    .rdata(fifo_0_o)
);

//fifo 1
wire [SWITCH_WIDTH-1:0] fifo_1_i;
wire [SWITCH_WIDTH-1:0] fifo_1_o;

sync_fifo #(
    .FIFO_DEPTH(FIFO_LENGTH),
    .FIFO_WIDTH(SWITCH_WIDTH)
)fifo_1(
    .clk(switch_clk),
    .rst_n(switch_rstn),
    .wreq(switch_ena),
    .rreq(read_ena[FIFO_LENGTH-2]),
    .wdata(fifo_1_i),
    .rdata(fifo_1_o) 
);

//switch logic
assign fifo_0_i = switch_cnt[FFT_STAGE-1] ? fifo_1_o : switch_i_0; //switch
assign fifo_1_i = switch_i_1;
assign switch_o_0 = fifo_0_o;
assign switch_o_1 = switch_cnt[FFT_STAGE-1] ? switch_i_0 : fifo_1_o; //switch

//switch vaild
assign switch_vaild = read_ena[FIFO_LENGTH-1];

endmodule