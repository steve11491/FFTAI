# Phase 1 复现报告（FFT 轨·软件参考链闭环）

日期：2026-10-22 · 分支：main · 基线：ed7128f → P1 提交：48d04c0 / 41c2504 / ce73ccd

## 总结论

**FFT 轨 P1 全部完成**：路径闭环 ✓、旋转因子 bit-exact 闭环 ✓、参考数据闭环（生成 + 语义校验）✓。
两处方案调整均已按预案执行（见"偏差记录"）。

## 预期 vs 实际

| 步骤 | 预期 | 实际 | 判定 |
|---|---|---|---|
| P1.0 基线 | numpy/MATLAB/git 就绪 | numpy 2.4.6 ✓，git 干净 ✓，**MATLAB 实际不可用**（目录为空/残缺） | 按预案切换 numpy 路线 |
| P1.1 路径 | FFT 范围硬编码路径清零 | 34 处（fft_tb 29 + define 1 + tb 2 + 生成器 1）全部替换，grep 残留 0，py_compile 通过 | ✅ |
| P1.2 旋转因子 | 重生成与 RTL 表 bit-exact | **2048/2048 全等**（p9/p10/p11/p12 四级表 100%） | ✅ |
| P1.3 参考数据 | tb 输入文件就位 + 库内真值三方对拍 | 6 个输入/旋转因子文件生成（格式对齐 tb 数组声明）；库内真值语义破解：**增益精确 = 1/N（逐级÷2）**，与理想 FFT 残差 = 逐级舍入噪声（max\|Δ\|≈5 LSB，rms −47~−56 dB） | ✅（bit-exact 再生成确认为 P2 行为模型范畴） |
| P1.4 golden | generate_ai_fft_all 再生成 | **范围修正**：该生成器激活配置为卷积 golden（torch conv2d 交叉验证），tb 的 `is_fft=0`（2043 行）——属 YOLOv5 轨。FFT 轨系统真值 = 库内 txt + P2 行为模型 | 结案（决策记录见下） |
| P1.5 验收提交 | 3+ 提交推送 | 48d04c0（路径）/ 41c2504（旋转因子）/ ce73ccd（参考数据）/ 本报告 | ✅ |

## 关键技术结论（P1 固化的"格式契约"）

1. **旋转因子主表** `rotar_4096.txt`：2048 行 × 32b = `{im(16b), re(16b)}`，共轭因子 (−sin, cos)；
   量化 `floor(v·2¹⁵−1) / ceil(v·2¹⁵+1) / round`；结构 = p9/p10/p11/p12 级表按 8 列交错 × 4 通道拼接。
2. **输入文件**：`fft_i_N.txt` = N 行 × 32b（im=0 + re）；tb_mdc/8p 用 16b/行的简化版。
3. **库内参考输出** `fft_out_{512..4096}_matlab.txt` = 409,600 采样流（= fft_in_rand.txt，100×4096）
   按点数分帧的**逐级 ÷2 定点 FFT**，增益精确 1/N——bit-exact 复现需逐级舍入的 R2MDC 行为模型。
4. **架构参数**（MATLAB 逆向）：点数 2^9..2^12、c=4 通道、cp=2、s=4 级/流水、p=8 并行。

## 偏差与决策记录

| # | 偏差 | 决策 |
|---|---|---|
| 1 | 本机 MATLAB 不可用 | 全部参考链改 numpy 实现；以库内文件为真值对拍，判据不变 |
| 2 | `ai_fft_all` golden 生成器/tb 实为卷积模式（IP 打包名叫 ai_fft） | 归入冻结的 YOLOv5 轨；FFT 轨系统级验证走 fft_tb AXI 族 + 行为模型 |
| 3 | 库内真值 bit-exact 再生成需逐级舍入模型 | 移至 P2 首项任务（行为模型移植，兼作 Phase 2/3 仿真 golden） |

## P1 交付物

- `note/p1_scripts/`：rotar_check / rotar_port / gen_fft_inputs / check_library（4 个可复跑脚本）
- `software/fft_software/m/`：fft_i_16/64/4096、ifft_i_4096（占位）、rotar_16/64（6 个 tb 数据文件）
- 32 处路径修复（fft_tb 13 文件 + define + tb + 生成器）

## P2 入口建议

1. 移植 fft_cal.m 中段 R2MDC 行为模型 → Python（逐级舍入），对库内 4 个点数真值追求 bit-exact；
2. 以该模型为 golden 跑 tb_basic_pe → tb_mdc → tb_fft_256_axi 族单元/核心仿真。
