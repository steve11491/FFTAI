// module multi_delay_register #(
//     parameter DATA_WIDTH = 1,
//     parameter NUM_HEADS = 4,  // 延迟头的数量
//     parameter DELAY_SEL_WIDTH = $clog2(NUM_HEADS),
//     parameter NUM_HEADS_EXP = 2 ** DELAY_SEL_WIDTH,
//     parameter MAX_DELAY = 16,  // 最大延迟值
//     parameter int DELAYS[NUM_HEADS] = '{1, 2, 4, 8}  // 每个延迟头的具体延迟值
// ) (
//     input  wire                       clk,      // 时钟信号
//     input  wire                       rstn,     // 低电平有效的复位信号
//     input  wire [DELAY_SEL_WIDTH-1:0] sel,      // 选择信号,用于选择输出哪个延迟头
//     input  wire [     DATA_WIDTH-1:0] data_in,  // 输入数据
//     output wire [     DATA_WIDTH-1:0] data_out  // 输出数据
// );

//     // 声明延迟寄存器数组
//     logic [DATA_WIDTH-1:0] delay_reg[MAX_DELAY:0];

//     // 实现延迟逻辑
//     always @(posedge clk or negedge rstn) begin
//         if (~rstn) begin
//             // 复位所有延迟寄存器
//             for (int i = 0; i < MAX_DELAY; i++) begin
//                 delay_reg[i] <= '0;
//             end
//         end else begin
//             // 移位操作
//             for (int i = MAX_DELAY; i > 0; i--) begin
//                 delay_reg[i] <= delay_reg[i-1];
//             end

//         end
//     end
//     assign delay_reg[0] = data_in;
//     // 根据选择信号输出相应的延迟数据
//     logic [DATA_WIDTH-1:0] delay_reg_sel[NUM_HEADS_EXP-1:0];
//     generate
//         for (genvar i = 0; i < NUM_HEADS_EXP; i = i + 1) begin
//             if (i < NUM_HEADS) begin
//                 assign delay_reg_sel[i] = delay_reg[DELAYS[i]];
//             end else begin
//                 assign delay_reg_sel[i] = delay_reg[DELAYS[0]];
//             end

//         end
//     endgenerate

//     assign data_out = delay_reg_sel[sel];



// endmodule


module multi_delay_register #(
    parameter DATA_WIDTH = 1,
    parameter NUM_HEADS = 4,  // 延迟头的数量
    parameter DELAY_SEL_WIDTH = $clog2(NUM_HEADS),
    parameter NUM_HEADS_EXP = 2 ** DELAY_SEL_WIDTH,
    parameter MAX_DELAY = 16,  // 最大延迟值
    parameter int DELAYS[NUM_HEADS] = '{1, 2, 4, 8}  // 每个延迟头的具体延迟值
) (
    input  wire                       clk,      // 时钟信号
    input  wire                       rstn,     // 低电平有效的复位信号
    input  wire [DELAY_SEL_WIDTH-1:0] sel,      // 选择信号,用于选择输出哪个延迟头
    input  wire [     DATA_WIDTH-1:0] data_in,  // 输入数据
    output wire [     DATA_WIDTH-1:0] data_out  // 输出数据
);

    // 声明延迟寄存器数组
    wire [DATA_WIDTH-1:0] delay_reg[NUM_HEADS-1:0];

    generate
        for (genvar i = 0; i < NUM_HEADS; i = i + 1) begin
            dq_dff #(
                .N (DELAYS[i]),
                .DW(DATA_WIDTH)
            ) u_delay (
                .clk(clk),
                .rstn(rstn),
                .d(data_in),
                .q(delay_reg[i])
            );
        end
    endgenerate

    assign data_out = delay_reg[sel];



endmodule
