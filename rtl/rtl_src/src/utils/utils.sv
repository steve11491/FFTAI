
module dq_dff #(
    parameter N  = 1,
    parameter DW = 12
) (
    input wire clk,
    input wire rstn,
    input wire [DW-1:0] d,
    output wire [DW-1:0] q
);
    generate

        if (N == 0) begin
            assign q = d;
        end else if (N > 0) begin
            // (* SRL_STYLE="srl"*) 
            reg [DW-1:0] d_sreg[N-1:0];
            integer j;
            always @(posedge clk or negedge rstn) begin
                if (~rstn) begin
                    for (j = 0; j < N; j = j + 1) begin
                        d_sreg[j] <= 0;
                    end
                end else begin
                    for (j = 0; j < N - 1; j = j + 1) begin
                        d_sreg[j+1] <= d_sreg[j];
                    end
                    d_sreg[0] <= d;
                end
            end
            assign q = d_sreg[N-1];
        end
    endgenerate


endmodule


module dq_dff_vector #(
    parameter N = 1,
    parameter L = 4
) (
    input wire clk,
    input wire rstn,
    input wire [L-1:0] d,
    output wire [L-1:0] q
);
    genvar i;
    generate
        for (i = 0; i < L; i = i + 1) begin
            dq_dff #(
                .N (N),
                .DW(1)
            ) dq_dff (
                .clk(clk),
                .rstn(rstn),
                .d(d[i]),
                .q(q[i])
            );
        end
    endgenerate

endmodule

module dq_dff_array #(
    parameter N  = 1,
    parameter DW = 12,
    parameter L  = 4
) (
    input wire clk,
    input wire rstn,
    input wire [DW-1:0] d[L-1:0],
    output wire [DW-1:0] q[L-1:0]
);
    genvar i;
    generate
        for (i = 0; i < L; i = i + 1) begin
            dq_dff #(
                .N (N),
                .DW(DW)
            ) dq_dff (
                .clk(clk),
                .rstn(rstn),
                .d(d[i]),
                .q(q[i])
            );
        end
    endgenerate

endmodule


module dff #(
    parameter N  = 1,
    parameter DW = 12
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [DW-1:0] d,
    output wire [DW-1:0] q
);
    reg [DW-1:0] d_sreg[N-1:0];
    integer j;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (j = 0; j < N; j = j + 1) begin
                d_sreg[j] <= 0;
            end
        end else if (en) begin
            for (j = 0; j < N - 1; j = j + 1) begin
                d_sreg[j+1] <= d_sreg[j];
            end
            d_sreg[0] <= d;
        end
    end
    assign q = d_sreg[N-1];

endmodule



module dff_valid #(
    parameter N  = 1,
    parameter DW = 12
) (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [DW-1:0] d,
    output wire [DW-1:0] q,
    output wire valid
);

    reg valid_reg[N-1:0];
    integer j;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (j = 0; j < N; j = j + 1) begin
                valid_reg[j] <= 0;
            end
        end else begin
            for (j = 0; j < N - 1; j = j + 1) begin
                valid_reg[j+1] <= valid_reg[j];
            end
            valid_reg[0] <= en;
        end
    end
    assign valid = valid_reg[N-1];

    reg [DW-1:0] d_sreg[N-1:0];
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (j = 0; j < N; j = j + 1) begin
                d_sreg[j] <= 0;
            end
            // end else if (en) begin
        end else begin
            for (j = 0; j < N - 1; j = j + 1) begin
                d_sreg[j+1] <= d_sreg[j];
            end
            d_sreg[0] <= d;
        end
    end
    assign q = d_sreg[N-1];

endmodule
