

// No-Change模式的单端块RAM
module com_single_port_ram #(
    parameter WIDTH = 72,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clk,
    input rstn,
    input en,
    input we,
    input [ADDR_BIT-1:0] addr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    output reg dout_valid
);

    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[0:DEPTH-1];

    integer t;
    initial begin
        for (t = 0; t < DEPTH; t = t + 1) RAM[t] = 0;
    end

    always @(posedge clk) begin
        if (en) begin
            if (we) begin
                RAM[addr] <= din;
            end else begin
                dout <= RAM[addr];
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            dout_valid <= 0;
        end else if (en) begin
            if (we) begin
                dout_valid <= 0;
            end else begin
                dout_valid <= 1;
            end
        end else begin
            dout_valid <= 0;
        end
    end

endmodule


// 数据输出可复位的单端块RAM，Read_first
module com_single_port_ram_rf_rst #(
    parameter WIDTH = 72,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clk,
    input rstn,
    input en,
    input we,
    input [ADDR_BIT-1:0] addr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    output reg dout_valid
);

    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[0:DEPTH-1];

    integer t;
    initial begin
        for (t = 0; t < DEPTH; t = t + 1) RAM[t] = 0;
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            dout <= 0;  //输出复位
        end else if (en) begin  //块RAM使能
            if (we) begin
                RAM[addr] <= din;  //写使能
            end else begin
                dout <= RAM[addr];
            end
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            dout_valid <= 0;
        end else if (en) begin
            if (we) begin
                dout_valid <= 0;
            end else begin
                dout_valid <= 1;
            end
        end else begin
            dout_valid <= 0;
        end
    end

endmodule


// 写优先模式的单端块RAM，Wrist_first
module com_single_port_ram_wf #(
    parameter WIDTH = 72,
    parameter DEPTH = 512,
    parameter ADDR_BIT = $clog2(DEPTH),
    parameter RAM_STYLE_VAL = "block"
) (
    input clk,
    input rstn,
    input en,
    input we,
    input [ADDR_BIT-1:0] addr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    output reg dout_valid
);

    (*ram_style=RAM_STYLE_VAL*) reg [WIDTH-1:0] RAM[0:DEPTH-1];

    integer t;
    initial begin
        for (t = 0; t < DEPTH; t = t + 1) RAM[t] = 0;
    end

    always @(posedge clk) begin
        if (en) begin
            if (we) begin
                RAM[addr] <= din;
                dout <= din;
            end else begin
                dout <= RAM[addr];
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            dout_valid <= 0;
        end else if (en) begin
            if (we) begin
                dout_valid <= 1;
            end else begin
                dout_valid <= 1;
            end
        end else begin
            dout_valid <= 0;
        end
    end

endmodule



