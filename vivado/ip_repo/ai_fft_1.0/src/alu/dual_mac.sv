


module dual_mac #(
    parameter WIDTH = 16
) (
    input wire clk,
    input wire rstn,
    input wire [1:0] in_valid,
    input wire is_fft,
    input wire is_int16,
    input wire [WIDTH+1-1:0] IN1_X2r,  //17
    input wire [WIDTH-1:0] W11_Wr,  //16
    input wire [WIDTH-1:0] W22_X1r,  //16
    input wire [WIDTH-1:0] W21_X1i,  //16
    input wire [WIDTH-1:0] W12_Wi,  //16
    input wire [WIDTH+1-1:0] IN2_X2i,  //17
    output logic [WIDTH*2+2-1:0] X1r_d,  //34
    output logic [WIDTH*2+2-1:0] O1_Or,  //34
    output logic [WIDTH*2+2-1:0] O2_Oi,  //34
    output logic [WIDTH*2+2-1:0] X1i_d,  //34
    output logic [1:0] out_valid
);
    localparam BYPASS = 1'b1;
    localparam REG_IN = 1'b1;




    // for debug
    //===============================
    wire [ 8-1:0] W11_int8;  //8
    wire [ 8-1:0] W12_int8;  //8
    wire [ 8-1:0] W13_int8;  //8
    wire [ 8-1:0] W14_int8;  //8
    wire [ 8-1:0] W21_int8;  //8
    wire [ 8-1:0] W22_int8;  //8
    wire [ 8-1:0] W23_int8;  //8
    wire [ 8-1:0] W24_int8;  //8

    wire [17-1:0] O1_int17;  //17
    wire [17-1:0] O2_int17;  //17
    wire [17-1:0] O3_int17;  //17
    wire [17-1:0] O4_int17;  //17

    assign W11_int8 = W11_Wr[8-1:0];
    assign W12_int8 = W11_Wr[16-1:8];
    assign W13_int8 = W12_Wi[8-1:0];
    assign W14_int8 = W12_Wi[16-1:8];

    assign W21_int8 = W21_X1i[8-1:0];
    assign W22_int8 = W21_X1i[16-1:8];
    assign W23_int8 = W22_X1r[8-1:0];
    assign W24_int8 = W22_X1r[16-1:8];

    assign O1_int17 = O1_Or[17-1:0];
    assign O2_int17 = O1_Or[34-1:17];
    assign O3_int17 = O2_Oi[17-1:0];
    assign O4_int17 = O2_Oi[34-1:17];
    //===============================

    reg is_int16_reg;
    reg is_fft_reg;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            is_int16_reg <= 0;
            is_fft_reg   <= 0;
        end else begin
            is_int16_reg <= is_int16;
            is_fft_reg   <= is_fft;
        end
    end



    reg [WIDTH+1-1:0] IN1_X2r_w;
    reg [WIDTH-1:0] W11_Wr_w;
    reg [WIDTH-1:0] W22_X1r_w;
    reg [WIDTH-1:0] W21_X1i_w;
    reg [WIDTH-1:0] W12_Wi_w;
    reg [WIDTH+1-1:0] IN2_X2i_w;

    reg [1:0] in_valid_d;

    generate
        if (REG_IN == 1'b1) begin
            always @(posedge clk) begin
                if (in_valid) begin
                    IN1_X2r_w <= IN1_X2r;
                    W11_Wr_w  <= W11_Wr;
                    W22_X1r_w <= W22_X1r;
                    W21_X1i_w <= W21_X1i;
                    W12_Wi_w  <= W12_Wi;
                    IN2_X2i_w <= IN2_X2i;
                end
            end
            always @(posedge clk or negedge rstn) begin
                if (~rstn) begin
                    in_valid_d <= 0;
                end else begin
                    in_valid_d <= in_valid;
                end
            end
        end else begin
            assign IN1_X2r_w  = IN1_X2r;
            assign W11_Wr_w   = W11_Wr;
            assign W22_X1r_w  = W22_X1r;
            assign W21_X1i_w  = W21_X1i;
            assign W12_Wi_w   = W12_Wi;
            assign IN2_X2i_w  = IN2_X2i;
            assign in_valid_d = in_valid;
        end
    endgenerate



    wire [WIDTH-1:0] W_tmp[1:0];
    assign W_tmp[0] = is_fft_reg ? W11_Wr_w : W22_X1r_w;
    assign W_tmp[1] = is_fft_reg ? W12_Wi_w : W21_X1i_w;

    logic [WIDTH-1:0] split_mul_in1[3:0];  // weight in
    logic [WIDTH+1-1:0] split_mul_in2[3:0];  // data in
    logic [WIDTH*2-1:0] split_mul_out[3:0];
    logic [3:0] split_mul_out_valid;




    assign split_mul_in2[0] = IN1_X2r_w;
    assign split_mul_in2[1] = IN2_X2i_w;
    assign split_mul_in2[2] = IN2_X2i_w;
    assign split_mul_in2[3] = IN1_X2r_w;

    assign split_mul_in1[0] = W11_Wr_w;
    assign split_mul_in1[1] = W_tmp[1];
    assign split_mul_in1[2] = W_tmp[0];
    assign split_mul_in1[3] = W12_Wi_w;


    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : mul_gen
            split_mul_simple_dual_8bit u_split_mul_simple_dual_8bit (
                .clk      (clk),
                .rstn     (rstn),
                .in_valid (in_valid_d[i/2]),
                .is_int16 (is_int16_reg),
                .in1      (split_mul_in1[i]),
                .in2      (split_mul_in2[i]),
                .out      (split_mul_out[i]),
                .out_valid(split_mul_out_valid[i])
            );
        end
    endgenerate

    wire [1:0] split_add_out_valid;
    wire is_sub;
    assign is_sub = is_fft_reg;
    parameter LS_WIDTH = WIDTH;
    parameter MS_WIDTH = WIDTH;
    split_addsub_inv #(
        .LS_WIDTH(LS_WIDTH),
        .MS_WIDTH(MS_WIDTH),
        .WIDTH(LS_WIDTH + MS_WIDTH)
    ) u_split_addsub_inv (
        .clk      (clk),
        .rstn     (rstn),
        .bypass   (BYPASS),
        .is_sub   (is_sub),
        .is_int16 (is_int16_reg),
        .in_valid (split_mul_out_valid[0] & split_mul_out_valid[1]),
        .in1      (split_mul_out[0]),
        .in2      (split_mul_out[1]),
        .out      (O1_Or),
        .out_valid(split_add_out_valid[0])
    );

    split_add #(
        .LS_WIDTH(LS_WIDTH),
        .MS_WIDTH(MS_WIDTH),
        .WIDTH(LS_WIDTH + MS_WIDTH)
    ) u_split_add (
        .clk      (clk),
        .rstn     (rstn),
        .bypass   (BYPASS),
        .is_int16 (is_int16_reg),
        .in_valid (split_mul_out_valid[2] & split_mul_out_valid[3]),
        .in1      (split_mul_out[2]),
        .in2      (split_mul_out[3]),
        .out      (O2_Oi),
        .out_valid(split_add_out_valid[1])
    );
    assign out_valid = split_add_out_valid;

    reg [WIDTH-1:0] X1r_delay1;
    reg [WIDTH-1:0] X1i_delay1;
    reg [WIDTH-1:0] X1r_delay2;
    reg [WIDTH-1:0] X1i_delay2;
    reg [WIDTH-1:0] X1r_delay3;
    reg [WIDTH-1:0] X1i_delay3;

    generate
        if (BYPASS == 1'b0 && REG_IN == 1'b1) begin

            assign X1r_delay1 = W22_X1r_w;
            assign X1i_delay1 = W21_X1i_w;
            always @(posedge clk) begin
                if ((&in_valid_d) && is_fft) begin
                    X1r_delay2 <= X1r_delay1;
                    X1i_delay2 <= X1i_delay1;
                end
            end
            always @(posedge clk) begin
                if ((&split_mul_out_valid) && is_fft_reg) begin
                    X1r_delay3 <= X1r_delay2;
                    X1i_delay3 <= X1i_delay2;
                end
            end
        end else if (BYPASS == 1'b0 && REG_IN == 1'b0) begin

            always @(posedge clk) begin
                if ((&in_valid) && is_fft_reg) begin
                    X1r_delay2 <= W22_X1r;
                    X1i_delay2 <= W21_X1i;
                end
            end

            always @(posedge clk) begin
                if ((&split_mul_out_valid) && is_fft_reg) begin
                    X1r_delay3 <= X1r_delay2;
                    X1i_delay3 <= X1i_delay2;
                end
            end
        end else if (BYPASS == 1'b1 && REG_IN == 1'b1) begin

            assign X1r_delay2 = W22_X1r_w;
            assign X1i_delay2 = W21_X1i_w;
            always @(posedge clk) begin
                if ((&in_valid_d) && is_fft_reg) begin
                    X1r_delay3 <= X1r_delay2;
                    X1i_delay3 <= X1i_delay2;
                end
            end
        end else if (BYPASS == 1'b1 && REG_IN == 1'b0) begin
            always @(posedge clk) begin
                if ((&in_valid) && is_fft_reg) begin
                    X1r_delay3 <= W22_X1r;
                    X1i_delay3 <= W21_X1i;
                end

            end
        end
    endgenerate

    reg [WIDTH-1:0] X1r_delay4;
    reg [WIDTH-1:0] X1i_delay4;
    // assign X1r_delay4 = X1r_delay3;
    // assign X1i_delay4 = X1i_delay3;
    always @(posedge clk) begin
        X1r_delay4 <= X1r_delay3;
        X1i_delay4 <= X1i_delay3;
    end


    // assign X1r_d = {{(WIDTH * 2 + 2 - WIDTH) {X1r_delay4[WIDTH-1]}}, X1r_delay4[WIDTH-1:0]};
    // assign X1i_d = {{(WIDTH * 2 + 2 - WIDTH) {X1i_delay4[WIDTH-1]}}, X1i_delay4[WIDTH-1:0]};
    assign X1r_d = {
        {(WIDTH * 2 + 2 - WIDTH + 15) {X1r_delay4[WIDTH-1]}}, X1r_delay4[WIDTH-1:0], 15'b0
    };
    assign X1i_d = {
        {(WIDTH * 2 + 2 - WIDTH + 15) {X1i_delay4[WIDTH-1]}}, X1i_delay4[WIDTH-1:0], 15'b0
    };



endmodule



