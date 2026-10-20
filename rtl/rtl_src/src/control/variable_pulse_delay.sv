
module variable_pulse_delay #(
    parameter DIM_WIDTH = 4
) (
    input wire clk,
    input wire rstn,
    input wire [DIM_WIDTH-1:0] m_sub_1,
    input wire in,
    output wire out
);
    //脉冲输入in延迟,m个周期，输入为(m-1)


    reg state;
    reg [DIM_WIDTH-1:0] count;
    wire is_count_end = (count == m_sub_1);

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

    assign out = is_count_end & (state == 1'b1);

endmodule
