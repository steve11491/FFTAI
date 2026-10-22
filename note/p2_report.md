# Phase 2 中期报告（FFT 轨·RTL 行为模型与仿真）

日期：2026-10-22 · 提交：89fe24f 及本报告 · 状态：P2.0-P2.2 完成，P2.3 工具链就绪 + 重大发现，P2.4 方案已定型

## 完成项

| 项 | 结果 |
|---|---|
| P2.0 MATLAB | R2017a (9.2.0) 以 `-wait -nodesktop -nosplash -logfile -r` 方式可用 |
| P2.1 数据流移植 | Python 模型 vs MATLAB oracle（实跑 fft_cal.m 改造版）：**全部 12 级 + 输出映射 1e-10 一致** |
| P2.2 RTL 算术 | 全链解码：dual_mac 精确 17b×16b 乘积 → split_addsub 精确加减（>>1 为进位拼接抵消，非舍入）→ X1 逻辑左移 15 → 加/减树 → **`acc[31:16]` 截位**。级内算术 = `floor((x1·2¹⁵±P)/2¹⁶)`（C-fl） |
| P2.2 库真值定位 | 58 组合 + 贪心逐级拟合（平台 522/1024）证明库 txt 非本 RTL 舍入变体 → **定为语义级参考**（C-fl vs 库：4 点数 rms −40~−50dB、max\|Δ\|≤8）；RTL 仿真 golden = C-fl 模型。与作者 dB 容忍方法论一致 |
| P2.3 工具链 | xvlog/xelab/xsim (2022.2) 编译验证通过 |

## P2.3 重大发现：fft_tb 族陈旧

- `tb_basic_pe` 期望的端口/参数（mode/stage/acc_ena/MUL_WIDTH...）当前任何模块都没有
- `tb_mdc` 实例化 `r2_mdc`、`tb_fft_256_axi` 实例化 `fft_top` —— **这两个模块在当前 RTL 中不存在**（现有：basic_pe/mdc/fft_core/fft_control/fft_array/mdc_array）
- 结论：单元级 tb 族是旧版 RTL 遗留，**不能直接跑**；`sys_tb/ai_fft_all` 的 FFT 控制被硬绑 0（1659-1663 行），当前配置跑的是卷积模式

## FFT 控制寄存器语义（已破解，ai_acce_instr_encoder.sv:1047-1051）

```
fft_config   = reg29[0]
fft_start    = is_fft & is_int16 & reg29[1]
fft_stage    = reg29[12+:4]      (9/10/11/12 -> 512/1024/2048/4096 点)
fft_sign_len = reg29[31-:16]     (帧数, 与 main.cpp fft_sign_len=100 对应)
每核读写地址 = reg(1+2i) / reg(2+2i)  (main.cpp:121-122)
```

## P2.4 方案（下一步执行）

新建系统级 tb `tb_fft_sys_512.sv`（方案 A，推荐）：
1. 实例化 **ai_acce_top**（含指令编码器，最贴近板级真实路径）+ 4× axi_ram DDR 模型（沿用 ai_fft_all tb 的 RAM 模板）
2. AXI-Lite BFM 按 main.cpp 寄存器序列驱动：写地址寄存器 → reg29 配置(fft_stage=9, sign_len=1) → config=1→0 → start=1 → 等 done
3. 预填输入 RAM = 库内流第 0 帧；回读输出 RAM → txt
4. Python 对拍：输出 vs **C-fl 模型 bit-exact**（这才是 RTL 功能验证的判据）；vs 库真值语义级(dB)

此 tb 同时是 Phase 6 板级一致性的预演（同一条寄存器流）。

## 遗留

- ifft_i_4096.txt 仍为理想 FFT 占位（P2.4 做 IFFT 模式时用 C-fl 模型重新生成）
- 陈旧 tb 不修复（属原作者历史；新 tb 替代其职责）
