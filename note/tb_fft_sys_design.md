# 2R.3 tb_fft_sys 设计笔记（已破译的全部接线事实）

来源：ai_acce_core.sv / dma_ffti.sv / mdc.sv / pe_array 系统源码阅读（P2）

## 数据通路
- FFT 核心 0 **复用 imap master**（`fft_w_data_ready[0]=imap_m_axi_wready`，2631 行）；
  多核时核 1/2/3 借 weight/bias2/omap master。=> tb 中输入输出都在 **u_axi_ram_imap**
- 总线字 64b = 2×32b 复样本，32b = `{imag[31:16], real[15:0]}`（与 fft_i_4096.txt 行格式一致）
- IFFT 模式：输入虚部取反（共轭）在 dma_ffti 内完成（`{~hi+1, lo}`）
- 预填机制：tb 直接写 `u_axi_ram_imap.mem[i]`（ai_fft_all tb 1778 行同款）

## 控制序列（main.cpp 同款，直驱 core 的 fft_* 端口）
```
fft_stage = 9/10/11/12（点数指数）；fft_sign_len = 帧数
fft_config=1 一拍 → 0（载入 sign_len、复位计数/偏移）
fft_start=1 一拍 → 0（fft_start = is_fft & is_int16 & start 由编码器产生，
  直驱 core 时给 core 的 fft_start 端口即可）
等 ffti_done_pulse/ffto_done_pulse
```
- dma_ffti：burst 读，`r_burst_len=BURST_LEN-1`，每 burst 后 offset += BURST_OFFSET，
  每帧 burst_num+1 次（burst_num 由 fft_stage 决定，core 内部算好喂 dma）
- 输出写：dma_ffto 生成写地址（偏移逻辑待读 dma_ffto.sv 确认——见下步）

## tb 架构决定（2026-10-22 补）
- dma_ffto 写偏移从 0 递增（BURST_OFFSET=256·64/8=2048B/爆）→ **就地流式覆写**（读指针在前、写指针在后）
- main.cpp 的独立 W 基址(0x3C800000)由编码器在 R/W 阶段重编程 master 地址实现
- **结论：tb 直驱 core 内部端口需同时伪造 conv 侧 DMA 编程，得不偿失。
  改为 tb_fft_sys = ai_acce_top（或 axi_full_interface_top，视 4 master 端口所在）
  + 4×axi_ram + 极简 AXI-Lite 主任务（复刻 main.cpp 寄存器序列）
  + 预填/回读 u_axi_ram_imap.mem**
- 下一步首件事：确认 4 个 M_AXI 端口所在顶层（axi_full_interface_top 176 行 vs ai_acce_top 单 M_AXI 参数）

## 验证判据
- 输出 RAM 区域内容（32b 复样本）→ python 与 **C-fl 模型**（r2mdc_model.py mode="C"）
  bit-exact 对拍；语义参考：库 fft_out_*_matlab.txt（-40dB 级）
- 回归：512/1024/2048/4096（改 fft_stage 参数重跑）+ IFFT（is_ifft_mode=1，
  期望 = C-fl IFFT 模型；r2mdc 模型需按共轭-FFT-共轭扩展，或直接用 numpy ifft·N·定点近似对拍语义）

## tb 骨架来源
ai_fft_all tb：参数段 + ai_acce_core 例化 + 4×axi_ram 接线整体复用；
删除卷积数据加载/比对段；FFT 控制驱动替换 1659-1663 的绑 0。

## RTL 特性记录
- 复位后首发交易 X1 延迟链有 X（2R.1 发现）——系统级由 fft_config 复位流程规避，观察是否复现
- fft_in_valid→fft_out_valid 的 ALU 往返延迟由 valid 握手对齐，无需 tb 处理
