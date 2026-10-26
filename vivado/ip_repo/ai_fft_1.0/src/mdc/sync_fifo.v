//=================================================================================
//
// Designer: SXH
//
// Description: Synchronize fifo
//
//=================================================================================
module sync_fifo #(
    parameter FIFO_DEPTH = 128,
    parameter FIFO_WIDTH = 8
)(
    input                   clk,
    input                   rst_n,
    input                   wreq,
    input                   rreq,
    input                   clr,
    input  [FIFO_WIDTH-1:0] wdata,
    output [FIFO_WIDTH-1:0] rdata,
    output                  full,
    output                  empty  
);

localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] fifo_reg[FIFO_DEPTH-1:0]; //fifo reg group
reg [FIFO_WIDTH-1:0] rdata_reg;                //read data reg

//vaild
wire rvaild = ~empty;        //read fifo vaild
wire rhsck = rreq & rvaild;  //read fifo hand shack 
wire wvaild = (~full) | rhsck ;         //write fifo vaild
wire whsck = wreq & wvaild;  //write fifo hand shack

//write and read addr
reg [ADDR_WIDTH:0] rptr; //add a bit as flag bit，when addr bits same ,if msb bit same ,fifo empty
reg [ADDR_WIDTH:0] wptr; //if msb bit diffrent ,fifo full
wire [ADDR_WIDTH-1:0] raddr;
wire                          rmsb;
assign {rmsb,raddr} = rptr;
wire [ADDR_WIDTH-1:0] waddr;
wire                          wmsb;
assign {wmsb,waddr} = wptr;

//write or read addr counter
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        rptr <= {ADDR_WIDTH{1'b0}};
        rdata_reg <= {FIFO_WIDTH{1'b0}};
    end
    else if(clr)begin
        rptr <= {ADDR_WIDTH{1'b0}};
        rdata_reg <= {FIFO_WIDTH{1'b0}};
    end
    else if(rhsck)begin
        rptr <= rptr + 1;
        rdata_reg <= fifo_reg[raddr];
    end
end
assign rdata = rdata_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        wptr <= {ADDR_WIDTH{1'b0}};
    end
    else if(clr)begin
        wptr <= {ADDR_WIDTH{1'b0}};
    end
    else if(whsck)begin
        wptr <= wptr + 1;
    end
end

//clr or write fifo reg group
genvar i;
generate
    for (i=0; i<FIFO_DEPTH; i = i + 1) begin:clr_fifo
      always @(posedge clk or negedge rst_n) begin
        if(!rst_n | clr)begin
            fifo_reg[i] <= {FIFO_WIDTH{1'b0}};
        end
        else if((i==waddr)&whsck)begin
            fifo_reg[i] <= wdata;
        end
      end
    end
endgenerate

//empty and full flag
assign empty = (raddr == waddr) & (rmsb == wmsb);
assign full = (raddr == waddr) & (rmsb != wmsb);

endmodule