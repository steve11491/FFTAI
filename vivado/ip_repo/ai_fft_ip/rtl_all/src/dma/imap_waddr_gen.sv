

module imap_waddr_gen #(
    parameter DIM_WIDTH = 10,
    parameter IMAP_DIM_WIDTH = DIM_WIDTH + 2,
    parameter IMAP_RAM_ADDR_WIDTH = 10,
    parameter PADDING_WIDTH = 5
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [PADDING_WIDTH-1:0] padding[3:0],

    input wire [IMAP_DIM_WIDTH-1:0] cnt_dim_ih,
    input wire [DIM_WIDTH-1:0] cnt_dim_ic,
    input wire [IMAP_DIM_WIDTH-1:0] cnt_dim_iw,
    input wire [IMAP_DIM_WIDTH+1-1:0] block_len_iw_add1,
    input wire [(IMAP_DIM_WIDTH+1)*2-1:0] block_len_iwh_add1,
    output reg [IMAP_RAM_ADDR_WIDTH-1:0] imap_waddr
);

    // always @(posedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         imap_waddr <= 0;
    //     end else if (en_true & cnt_L_end) begin
    //         imap_waddr<=cnt_dim_ic*(block_len_iw + 1)*(block_len_ih+1)
    //                         +(cnt_dim_ih+padding[3])*(block_len_iw + 1)+(cnt_dim_iw+padding[1]);
    //     end
    // end




    reg [(IMAP_DIM_WIDTH)*2+2-1:0] stage0_result1;
    reg [(IMAP_DIM_WIDTH)*2+2+DIM_WIDTH-1:0] stage0_result2;
    reg [IMAP_DIM_WIDTH-1:0] stage0_result3;
    reg en_ff;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage0_result1 <= 0;
            stage0_result2 <= 0;
            stage0_result3 <= 0;
        end else if (en) begin
            stage0_result1 <= (cnt_dim_ih + padding[3]) * block_len_iw_add1;
            stage0_result2 <= cnt_dim_ic * block_len_iwh_add1;
            stage0_result3 <= cnt_dim_iw + padding[1];
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            en_ff <= 0;
        end else begin
            en_ff <= en;

        end
    end

    reg [(IMAP_DIM_WIDTH)*2+2+IMAP_DIM_WIDTH+1-1:0] stage1_result1;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            stage1_result1 <= 0;
        end else if (en_ff) begin
            stage1_result1 <= stage0_result1 + stage0_result2 + stage0_result3;
        end
    end




    generate
        if (((IMAP_DIM_WIDTH) * 2 + 2 + IMAP_DIM_WIDTH + 1) > IMAP_RAM_ADDR_WIDTH) begin
            assign imap_waddr = stage1_result1[IMAP_RAM_ADDR_WIDTH-1:0];
        end else begin
            assign imap_waddr = {
                {(IMAP_RAM_ADDR_WIDTH - ((IMAP_DIM_WIDTH) * 2 + 2 + IMAP_DIM_WIDTH + 1)) {1'b0}},
                stage1_result1[(IMAP_DIM_WIDTH)*2+2+IMAP_DIM_WIDTH+1-1:0]
            };
        end
    endgenerate


endmodule
