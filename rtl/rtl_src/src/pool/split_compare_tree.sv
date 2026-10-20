
module split_compare_tree_signed #(
    parameter MODE = "MAX",
    parameter INPUTS_NUM = 9,
    parameter WIDTH = 16
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input logic [WIDTH-1:0] idata[INPUTS_NUM-1:0],
    output logic [WIDTH-1:0] odata,
    output logic out_valid
);
    localparam STAGES_NUM = $clog2(INPUTS_NUM);
    logic [STAGES_NUM:0] valid;
    assign valid[0] = in_valid;
    integer j;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (j = 1; j < STAGES_NUM; j = j + 1) begin
                valid[j] <= 0;
            end
        end else begin
            for (j = 0; j < STAGES_NUM; j = j + 1) begin
                valid[j+1] <= valid[j];
            end
        end
    end
    assign out_valid = valid[STAGES_NUM];


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
                        split_compare_max_signed #(
                            .WIDTH(WIDTH),
                            .PASS (PASS)
                        ) u_split_compare_max_signed (
                            .clk(clk),
                            .rstn(rstn),
                            .is_int16(is_int16),
                            .in_valid(valid[stage-1]),
                            .idata1(data[stage-1][comparator*2][WIDTH-1:0]),
                            .idata2(data[stage-1][comparator*2+1][WIDTH-1:0]),
                            .odata(data[stage][comparator][WIDTH-1:0])
                        );
                    end else if (MODE == "MIN") begin : min_gen
                        split_compare_min_signed #(
                            .WIDTH(WIDTH),
                            .PASS (PASS)
                        ) u_split_compare_min_signed (
                            .clk(clk),
                            .rstn(rstn),
                            .is_int16(is_int16),
                            .in_valid(valid[stage-1]),
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




module split_compare_max_signed #(
    parameter WIDTH = 16,
    parameter PASS  = 1
) (
    input clk,
    input rstn,
    input wire is_int16,
    input wire in_valid,
    input wire [WIDTH-1:0] idata1,
    input wire [WIDTH-1:0] idata2,
    output logic [WIDTH-1:0] odata,
    output logic out_valid
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid <= 0;
        end else begin
            out_valid <= in_valid;
        end
    end
    generate
        if (PASS == 1) begin
            always @(posedge clk) begin
                if (in_valid) begin
                    odata <= idata1;
                end
            end
        end else begin
            wire compare_result_low;
            wire compare_result_high;
            assign compare_result_low = ($signed(
                idata1[WIDTH/2-1:0]
            ) > $signed(
                idata2[WIDTH/2-1:0]
            ));
            assign compare_result_high = ($signed(
                idata1[WIDTH-1:WIDTH/2]
            ) > $signed(
                idata2[WIDTH-1:WIDTH/2]
            ));
            assign compare_result_int16 = ($signed(idata1[WIDTH-1:0]) > $signed(idata2[WIDTH-1:0]));
            always @(posedge clk) begin
                if (in_valid) begin
                    if (is_int16) begin
                        if (compare_result_int16) begin
                            odata <= idata1;
                        end else begin
                            odata <= idata2;
                        end
                    end else begin
                        if (compare_result_low) begin
                            odata[WIDTH/2-1:0] <= idata1[WIDTH/2-1:0];
                        end else begin
                            odata[WIDTH/2-1:0] <= idata2[WIDTH/2-1:0];
                        end
                        if (compare_result_high) begin
                            odata[WIDTH-1:WIDTH/2] <= idata1[WIDTH-1:WIDTH/2];
                        end else begin
                            odata[WIDTH-1:WIDTH/2] <= idata2[WIDTH-1:WIDTH/2];
                        end
                    end
                end
            end
        end
    endgenerate


endmodule


module split_compare_min_signed #(
    parameter WIDTH = 16,
    parameter PASS  = 1
) (
    input clk,
    input rstn,
    input wire is_int16,
    input wire in_valid,
    input wire signed [WIDTH-1:0] idata1,
    input wire signed [WIDTH-1:0] idata2,
    output logic signed [WIDTH-1:0] odata,
    output logic out_valid
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            out_valid <= 0;
        end else begin
            out_valid <= in_valid;
        end
    end
    generate
        if (PASS == 1) begin
            always @(posedge clk) begin
                if (in_valid) begin
                    odata <= idata1;
                end

            end
        end else begin
            wire compare_result_low;
            wire compare_result_high;
            assign compare_result_low = ($signed(
                idata1[WIDTH/2-1:0]
            ) > $signed(
                idata2[WIDTH/2-1:0]
            ));
            assign compare_result_high = ($signed(
                idata1[WIDTH-1:WIDTH/2]
            ) > $signed(
                idata2[WIDTH-1:WIDTH/2]
            ));
            assign compare_result_int16 = ($signed(idata1[WIDTH-1:0]) > $signed(idata2[WIDTH-1:0]));
            always @(posedge clk) begin
                if (in_valid) begin
                    if (is_int16) begin
                        if (compare_result_int16) begin
                            odata <= idata2;
                        end else begin
                            odata <= idata1;
                        end
                    end else begin
                        if (compare_result_low) begin
                            odata[WIDTH/2-1:0] <= idata2[WIDTH/2-1:0];
                        end else begin
                            odata[WIDTH/2-1:0] <= idata1[WIDTH/2-1:0];
                        end
                        if (compare_result_high) begin
                            odata[WIDTH-1:WIDTH/2] <= idata2[WIDTH-1:WIDTH/2];
                        end else begin
                            odata[WIDTH-1:WIDTH/2] <= idata1[WIDTH-1:WIDTH/2];
                        end
                    end
                end

            end
        end
    endgenerate



endmodule

