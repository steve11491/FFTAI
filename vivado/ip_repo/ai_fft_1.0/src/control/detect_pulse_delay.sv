module detect_pulse_delay #(
    parameter DIM_WIDTH = 4
) (
    input wire clk,
    input wire rstn,
    input wire [DIM_WIDTH-1:0] depth_sub_1,
    input wire in,
    output wire out
);
    //检测in的脉冲，延迟一个周期后拉高out depth个周期，输入为(depth-1)
    //如果in一直为高，则延迟一个周期后持续拉高out
    reg state;
    reg [DIM_WIDTH-1:0] count;
    wire is_count_end = (count == depth_sub_1);
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            count <= 0;
            state <= 0;
        end else begin
            case (state)
                1'b0: begin
                    count <= 0;
                    if (in) begin
                        state <= 1'b1;
                    end
                end
                1'b1: begin
                    if (is_count_end) begin
                        if (in) begin
                            state <= 1'b1;
                        end else begin
                            state <= 1'b0;
                        end
                        count <= 0;
                    end else begin
                        count <= count + 1'b1;
                    end
                end
            endcase
        end
    end

    assign out = (state == 1'b1);

endmodule

