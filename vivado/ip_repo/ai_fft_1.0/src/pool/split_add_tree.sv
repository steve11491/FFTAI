
module split_add_tree_signed #(
    parameter INPUTS_NUM = 3,
    parameter IDATA_WIDTH = 32,
    parameter STAGES_NUM = $clog2(INPUTS_NUM),
    parameter INPUTS_NUM_INT = 2 ** STAGES_NUM,
    parameter ODATA_WIDTH = IDATA_WIDTH + STAGES_NUM * 2
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input logic [IDATA_WIDTH-1:0] idata[INPUTS_NUM-1:0],
    output logic [ODATA_WIDTH-1:0] odata,
    output logic out_valid
);

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



    localparam signed [ODATA_WIDTH-1:0] ZERO = {{1'b0}, {(ODATA_WIDTH - 1) {1'b0}}};


    logic signed [ODATA_WIDTH-1:0] data[STAGES_NUM:0][INPUTS_NUM_INT-1:0];

    // generating tree
    genvar stage, comparator;
    generate
        for (stage = 0; stage <= STAGES_NUM; stage++) begin : stage_gen
            localparam ST_WIDTH = IDATA_WIDTH + stage * 2;
            if (stage == 0) begin
                localparam ST_OUT_NUM = INPUTS_NUM_INT;
                // stege 0 is actually module inputs
                for (comparator = 0; comparator < ST_OUT_NUM; comparator++) begin : inputs_gen

                    always @(*) begin
                        if (comparator < INPUTS_NUM) begin
                            data[stage][comparator][IDATA_WIDTH-1:0] = idata[comparator][IDATA_WIDTH-1:0];
                        end else begin
                            data[stage][comparator][ODATA_WIDTH-1:0] = ZERO;  //会被编译器优化

                        end
                    end  // always_comb

                end  // for
            end else begin
                localparam ST_OUT_NUM = (PASS_INDEX[(stage*32-1)-:32] + 1) / 2;

                // all other stages hold adders outputs
                for (comparator = 0; comparator < ST_OUT_NUM; comparator++) begin : add_gen

                    localparam PASS = (INPUTS_NUM % 2 == 1) && (PASS_INDEX[(stage*32-1)-:32]%2==1) && (comparator ==( (PASS_INDEX[(stage*32-1)-:32]+1)/2 - 1));



                    split_add_signed #(
                        .PASS(PASS),
                        .LS_WIDTH((ST_WIDTH - 2) / 2),
                        .MS_WIDTH((ST_WIDTH - 2) / 2),
                        .WIDTH(ST_WIDTH - 2)
                    ) split_add_signed (
                        .clk      (clk),
                        .rstn     (rstn),
                        .is_int16 (is_int16),
                        .in_valid (valid[stage-1]),
                        .in1      (data[stage-1][comparator*2][ST_WIDTH-2-1:0]),
                        .in2      (data[stage-1][comparator*2+1][ST_WIDTH-2-1:0]),
                        .out      (data[stage][comparator][ST_WIDTH-1:0]),
                        .out_valid()
                    );


                end  // for

            end  // if stage
        end  // for
    endgenerate

    assign odata = data[STAGES_NUM][0];

endmodule

module split_add_signed #(
    parameter PASS = 0,
    parameter LS_WIDTH = 16,
    parameter MS_WIDTH = 16,
    parameter WIDTH = LS_WIDTH + MS_WIDTH
) (
    input wire clk,
    input wire rstn,
    input wire is_int16,
    input wire in_valid,
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    output logic [WIDTH-1+2:0] out,
    output logic out_valid
);

    // 这个模块实现了int16和int8情况下的有符号加法，
    // int16时，输入是一个int32，输出是一个int34，int8时，输入int32的低16位和高16位为2个int16，输出int34是2个int17
    // int16: 34-1:0 out;
    // int8: 34-1:17 out1; 16:0 out2
    generate
        if (PASS == 1) begin
            always @(posedge clk) begin
                if (in_valid) begin
                    if (is_int16) begin
                        out <= {{2{in1[WIDTH-1]}}, in1[WIDTH-1:0]};
                    end else begin
                        out <= {
                            {1{in1[WIDTH-1]}},
                            in1[WIDTH-1:WIDTH/2],
                            {1{in1[WIDTH/2-1]}},
                            in1[WIDTH/2-1:0]
                        };
                    end
                end
            end
        end else begin
            always @(posedge clk or negedge rstn) begin
                if (~rstn) begin
                    out_valid <= 0;
                end else begin
                    out_valid <= in_valid;
                end
            end

            // Build the less significant adder with an extra bit on the top to get
            // the carry chain onto the normal routing.  
            wire sign_bit_a = is_int16 ? 1'b0 : in1[LS_WIDTH-1];
            wire sign_bit_b = is_int16 ? 1'b0 : in2[LS_WIDTH-1];

            reg signed [LS_WIDTH-1+1:0] ls_adder1;
            reg signed [LS_WIDTH-1+1:0] ls_adder2;
            assign ls_adder1 = {sign_bit_a, in1[LS_WIDTH-1:0]};
            assign ls_adder2 = {sign_bit_b, in2[LS_WIDTH-1:0]};
            reg signed [LS_WIDTH-1+1:0] ls_adder;
            wire cross_carry = is_int16 ? ls_adder[LS_WIDTH] : 1'b0;
            always @(posedge clk or posedge rstn) begin
                if (~rstn) begin
                    ls_adder <= 0;
                end else if (in_valid) begin
                    ls_adder <= ls_adder1 + ls_adder2;
                end
            end

            // the more significant data needs to wait in1 tick for the carry
            // signal to be ready
            reg [MS_WIDTH-1:0] ms_data_a, ms_data_b;
            always @(posedge clk or posedge rstn) begin
                if (~rstn) begin
                    ms_data_a <= 0;
                    ms_data_b <= 0;
                end else if (in_valid) begin
                    ms_data_a <= in1[WIDTH-1:WIDTH-MS_WIDTH];
                    ms_data_b <= in2[WIDTH-1:WIDTH-MS_WIDTH];
                end
            end

            // Build the more significant adder with an extra low bit to incorporate
            // the carry from the split lower chain.
            wire signed [MS_WIDTH-1+2:0] ms_adder;
            wire signed [MS_WIDTH-1+1:0] ms_adder1;
            wire signed [MS_WIDTH-1+1:0] ms_adder2;
            assign ms_adder1 = {ms_data_a, cross_carry};
            assign ms_adder2 = {ms_data_b, cross_carry};
            assign ms_adder  = ms_adder1 + ms_adder2;

            wire [MS_WIDTH:0] ms_adder_o = ms_adder[MS_WIDTH+1:1];

            // collect the sum back together and register, drop the two internal bits
            // always @(*) begin
            //     if (is_int16) begin
            //         out = {ms_adder[MS_WIDTH+1], ms_adder[MS_WIDTH+1:1], ls_adder[LS_WIDTH-1:0]};
            //     end else begin
            //         out = {ms_adder[MS_WIDTH+1:1], ls_adder[LS_WIDTH-1+1:0]};
            //     end
            // end
            always @(*) begin
                out[LS_WIDTH-1:0] = ls_adder[LS_WIDTH-1:0];
                if (is_int16) begin
                    out[WIDTH-1+2:LS_WIDTH] = {ms_adder[MS_WIDTH+1], ms_adder[MS_WIDTH+1:1]};
                end else begin
                    out[WIDTH-1+2:LS_WIDTH] = {ms_adder[MS_WIDTH+1:1], ls_adder[LS_WIDTH-1+1]};
                end
            end
        end
    endgenerate

endmodule


