
module compare_tree_signed #(
    parameter MODE = "MAX",
    parameter INPUTS_NUM = 9,
    parameter WIDTH = 16
) (
    input clk,
    input rstn,
    input logic [WIDTH-1:0] idata[INPUTS_NUM-1:0],
    output logic [WIDTH-1:0] odata
);
    parameter STAGES_NUM = $clog2(INPUTS_NUM);

    function automatic [32*STAGES_NUM-1:0] PASS_INDEX_GEN;
        input integer input_num;
        integer i;
        integer temp;

        begin
            PASS_INDEX_GEN[31:0] = input_num;
            temp = input_num;

            for (i = 1; i < STAGES_NUM; i = i + 1) begin
                temp = (temp + 1) / 2;
                PASS_INDEX_GEN[((i+1)*32-1)-:32] = temp;
            end
        end
    endfunction

    parameter [32*STAGES_NUM-1:0] PASS_INDEX = PASS_INDEX_GEN(INPUTS_NUM);


    localparam INPUTS_NUM_INT = 2 ** STAGES_NUM;

    localparam signed [WIDTH-1:0] NEG_MAX = {{1'b1}, {(WIDTH - 1) {1'b0}}};
    localparam signed [WIDTH-1:0] POS_MAX = {{1'b0}, {(WIDTH - 1) {1'b1}}};

    logic signed [WIDTH-1:0] data[STAGES_NUM:0][INPUTS_NUM_INT-1:0];

    // generating tree
    genvar stage, comparator;
    generate
        for (stage = 0; stage <= STAGES_NUM; stage++) begin : stage_gen

            if (stage == 0) begin
                localparam ST_OUT_NUM = INPUTS_NUM_INT;
                // stege 0 is actually module inputs
                for (comparator = 0; comparator < ST_OUT_NUM; comparator++) begin : inputs_gen

                    always @(*) begin
                        if (comparator < INPUTS_NUM) begin
                            data[stage][comparator][WIDTH-1:0] = idata[comparator][WIDTH-1:0];
                        end else begin
                            if (MODE == "MAX") begin
                                data[stage][comparator][WIDTH-1:0] = NEG_MAX;  //会被编译器优化
                            end else if (MODE == "MIN") begin
                                data[stage][comparator][WIDTH-1:0] = POS_MAX;  //会被编译器优化
                            end

                        end
                    end  // always_comb

                end  // for
            end else begin
                localparam ST_OUT_NUM = (PASS_INDEX[(stage*32-1)-:32] + 1) / 2;

                // all other stages hold comparators outputs
                for (comparator = 0; comparator < ST_OUT_NUM; comparator++) begin : comparator_gen

                    localparam PASS = (INPUTS_NUM % 2 == 1) && (PASS_INDEX[(stage*32-1)-:32]%2==1) && (comparator ==( (PASS_INDEX[(stage*32-1)-:32]+1)/2 - 1));

                    if (MODE == "MAX") begin : max_gen
                        compare_max_signed #(
                            .WIDTH(WIDTH),
                            .PASS (PASS)
                        ) u_compare_max_signed (
                            .clk(clk),
                            .rstn(rstn),
                            .idata1(data[stage-1][comparator*2][WIDTH-1:0]),
                            .idata2(data[stage-1][comparator*2+1][WIDTH-1:0]),
                            .odata(data[stage][comparator][WIDTH-1:0])
                        );
                    end else if (MODE == "MIN") begin : min_gen
                        compare_min_signed #(
                            .WIDTH(WIDTH),
                            .PASS (PASS)
                        ) u_compare_min_signed (
                            .clk(clk),
                            .rstn(rstn),
                            .idata1(data[stage-1][comparator*2][WIDTH-1:0]),
                            .idata2(data[stage-1][comparator*2+1][WIDTH-1:0]),
                            .odata(data[stage][comparator][WIDTH-1:0])
                        );
                    end

                end  // for

            end  // if stage
        end  // for
    endgenerate

    assign odata = data[STAGES_NUM][0];

endmodule




module compare_max_signed #(
    parameter WIDTH = 16,
    parameter PASS  = 1
) (
    input clk,
    input rstn,
    input wire signed [WIDTH-1:0] idata1,
    input wire signed [WIDTH-1:0] idata2,
    output logic signed [WIDTH-1:0] odata
);


    generate
        if (PASS == 1) begin
            always @(posedge clk) begin
                odata <= idata1;
            end
        end else begin
            wire compare_result;
            assign compare_result = $signed(idata1) > $signed(idata2);
            always @(posedge clk) begin
                if (compare_result) begin
                    odata <= idata1;
                end else begin
                    odata <= idata2;
                end
            end
        end
    endgenerate


endmodule


module compare_min_signed #(
    parameter WIDTH = 16,
    parameter PASS  = 1
) (
    input clk,
    input rstn,
    input wire signed [WIDTH-1:0] idata1,
    input wire signed [WIDTH-1:0] idata2,
    output logic signed [WIDTH-1:0] odata
);


    generate
        if (PASS == 1) begin
            always @(posedge clk) begin
                odata <= idata1;
            end
        end else begin
            wire compare_result;
            assign compare_result = $signed(idata1) > $signed(idata2);
            always @(posedge clk) begin
                if (compare_result) begin
                    odata <= idata2;
                end else begin
                    odata <= idata1;
                end
            end
        end
    endgenerate


endmodule

