module delay_selector #(
    parameter NUM_DELAY_HEADS = 3,  // 延迟头的数量
    parameter DELAY_SEL_WIDTH = $clog2(NUM_DELAY_HEADS)
) (
    input wire is_maxpool,
    input wire is_avgpool,
    input wire is_stc,
    input wire is_dwc,
    output reg [DELAY_SEL_WIDTH-1:0] sel
);

    wire [DELAY_SEL_WIDTH-1:0] SEL_STC = 0;
    wire [DELAY_SEL_WIDTH-1:0] SEL_DWC = 1;
    wire [DELAY_SEL_WIDTH-1:0] SEL_POOL = 2;


    always @(*) begin
        if (is_maxpool || is_avgpool) begin
            sel = SEL_POOL;
        end else if (is_dwc) begin
            sel = SEL_DWC;
        end else if (is_stc) begin
            sel = SEL_STC;
        end else begin
            sel = SEL_POOL;
        end
    end





endmodule
