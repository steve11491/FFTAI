//=================================================================================
//
// Designer: SXH
//
// Description: DC Switch STAGE 1
//
//=================================================================================

module dc_switch #(
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

//cnt 
reg switch_cnt;
always @(posedge switch_clk)begin
    if(!switch_rstn)begin
        switch_cnt <= 1'b0;
    end
    else if(switch_ena)begin
        switch_cnt <= ~switch_cnt;
    end
    else begin
        switch_cnt <=1'b0;
    end
end

//fifo
wire [SWITCH_WIDTH-1:0] fifo_0_i;
wire [SWITCH_WIDTH-1:0] fifo_1_i;
reg [SWITCH_WIDTH-1:0] fifo_0;
reg [SWITCH_WIDTH-1:0] fifo_1;
reg fifo_full;

always @(posedge switch_clk)begin
    if(!switch_rstn)begin
        fifo_0 <= {SWITCH_WIDTH{1'b0}};
        fifo_full <= 1'b0;
    end
    else if (switch_ena) begin
        fifo_0 <= fifo_0_i;
        fifo_full <= 1'b1;
    end
    else begin
        fifo_0 <= {SWITCH_WIDTH{1'b0}};
        fifo_full <= 1'b0;
    end
end

always @(posedge switch_clk)begin
    if(!switch_rstn)begin
        fifo_1 <= {SWITCH_WIDTH{1'b0}};
    end
    else if (switch_ena) begin
        fifo_1 <= fifo_1_i;
    end
    else begin
        fifo_1 <= {SWITCH_WIDTH{1'b0}};
    end
end

//switch logic
assign fifo_0_i = switch_cnt ? fifo_1 : switch_i_0; //switch
assign fifo_1_i = switch_i_1;
assign switch_o_0 = fifo_0;
assign switch_o_1 = switch_cnt ? switch_i_0 : fifo_1; //switch

assign switch_vaild = fifo_full;

endmodule