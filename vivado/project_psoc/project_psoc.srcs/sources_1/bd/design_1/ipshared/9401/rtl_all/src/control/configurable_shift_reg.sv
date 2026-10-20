/*为一个可以通过寄存器配置的移位寄存器组,比如说设置深度depth为5,那么寄存器组就可以存储5个字节,第6个字节输入时,会顶出第1个进入的字节并将第6个字节存储在最高地址*/

// module configurable_shift_reg_en_valid #(
//     parameter MAX_DEPTH = 5,
//     parameter WIDTH = 32,
//     parameter DEPTH_WIDTH = $clog2(MAX_DEPTH) + 1,
//     parameter SRL_STYLE_VAL = "reg_srl_reg"
// ) (
//     input                    clk,
//     input                    rstn,
//     input                    en,
//     input  [      WIDTH-1:0] din,
//     input  [DEPTH_WIDTH-1:0] depth,  //必须小于MAX_DEPTH
//     output                   valid,
//     output [      WIDTH-1:0] dout
// );
//     (* srl_style=SRL_STYLE_VAL*) reg [WIDTH-1:0] sreg[0:MAX_DEPTH-1];

//     reg [DEPTH_WIDTH-1:0] cnt;

//     integer t;
//     initial begin
//         for (t = 0; t < MAX_DEPTH; t = t + 1) sreg[t] = 0;
//         cnt = 0;
//     end

//     // tail
//     assign dout  = sreg[depth-1];
//     assign valid = (en & (cnt == depth)) ? 1 : 0;
//     //head
//     always @(posedge clk or negedge rstn) begin
//         if (~rstn) begin
//             sreg[0] <= 0;
//         end else if (en) begin
//             sreg[0] <= din;
//         end else begin
//             sreg[0] <= sreg[0];
//         end
//     end
//     //body
//     genvar i;
//     generate
//         for (i = 1; i < MAX_DEPTH; i = i + 1) begin
//             always @(posedge clk or negedge rstn) begin
//                 if (~rstn) begin
//                     sreg[i] <= 0;
//                 end else if (en) begin
//                     sreg[i] <= sreg[i-1];
//                 end else begin
//                     sreg[i] <= sreg[i];
//                 end
//             end
//         end
//     endgenerate


//     always @(posedge clk or negedge rstn) begin
//         if (~rstn) begin
//             cnt <= 0;
//         end else if (en && (cnt < depth)) begin
//             cnt <= cnt + 1;
//         end else begin
//             cnt <= cnt;
//         end
//     end

// endmodule

// module configurable_shift_reg #(
//     parameter MAX_DEPTH = 5,
//     parameter WIDTH = 32,
//     parameter DEPTH_WIDTH = $clog2(MAX_DEPTH) + 1,
//     parameter SRL_STYLE_VAL = "reg_srl_reg"
// ) (
//     input                    clk,
//     input                    rstn,
//     input  [      WIDTH-1:0] din,
//     input  [DEPTH_WIDTH-1:0] depth,  //必须小于MAX_DEPTH
//     output [      WIDTH-1:0] dout
// );

//     // 输入延迟depth个周期

//     (* srl_style=SRL_STYLE_VAL*) reg [WIDTH-1:0] sreg[0:MAX_DEPTH-1];

//     reg [DEPTH_WIDTH-1:0] cnt;

//     integer t;
//     initial begin
//         for (t = 0; t < MAX_DEPTH; t = t + 1) sreg[t] = 0;
//         cnt = 0;
//     end

//     // tail
//     assign dout = sreg[depth-1];

//     //head
//     always @(posedge clk or negedge rstn) begin
//         if (~rstn) begin
//             sreg[0] <= 0;
//         end else begin
//             sreg[0] <= din;
//         end
//     end
//     //body


//     always @(posedge clk or negedge rstn) begin
//         if (~rstn) begin
//             for (int i = 1; i < MAX_DEPTH; i = i + 1) begin
//                 sreg[i] <= 0;
//             end
//         end else begin
//             for (int i = 1; i < MAX_DEPTH; i = i + 1) begin
//                 sreg[i] <= sreg[i-1];
//             end
//         end
//     end




// endmodule


module configurable_shift_reg #(
    parameter MAX_DEPTH = 5,
    parameter WIDTH = 32,
    parameter DEPTH_WIDTH = $clog2(MAX_DEPTH),
    parameter SRL_STYLE_VAL = "reg_srl_reg"
) (
    input                    clk,
    input                    rstn,
    input                    skip,
    input  [      WIDTH-1:0] din,
    input  [DEPTH_WIDTH-1:0] depth_sub_1,  // 输入延迟depth个周期,输入为depth_sub_1
    output [      WIDTH-1:0] dout
);

    // 输入延迟depth个周期

    (* srl_style=SRL_STYLE_VAL*) reg [WIDTH-1:0] sreg[0:MAX_DEPTH-1];


    // tail
    assign dout = skip ? din : sreg[depth_sub_1];

    //head
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            sreg[0] <= 0;
        end else if (~skip) begin
            sreg[0] <= din;
        end
    end
    //body


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (int i = 1; i < MAX_DEPTH; i = i + 1) begin
                sreg[i] <= 0;
            end
        end else begin
            for (int i = 1; i < MAX_DEPTH; i = i + 1) begin
                if (~skip) begin
                    sreg[i] <= sreg[i-1];
                end
            end
        end
    end




endmodule


