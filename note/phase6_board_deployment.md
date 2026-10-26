# Phase 6: 板级部署指南

## 前提条件

| 项 | 状态 |
|---|---|
| Bitstream (.bit) | 待 Vivado GUI 综合生成 |
| XSA (.xsa) | 待 Vivado GUI 导出 |
| 交叉编译程序 | ✅ `deploy/fft_test` 已编译(Linaro GCC 7.3, 静态链接) |
| 输入数据 | ✅ `deploy/fft_in_rand.txt` 等已就位 |
| 板卡 | ZC706 |
| 板上OS | PetaLinux / 任意ARM Linux |

## 步骤 1: 生成 Bitstream (GUI)

在 Vivado 2022.2 中按 `note/rtl_test_report.md` 第六节操作 BD 搭建后:
1. Flow Navigator → **Generate Bitstream**
2. File → Export → Export Hardware (含bitstream) → `fft_system.xsa`

## 步骤 2: 准备 SD 卡 (如果无 JTAG)

```
SD卡分区:
  FAT32 分区:
    BOOT.BIN  (PetaLinux boot image + bitstream)
  EXT4 分区:
    /rootfs  (PetaLinux rootfs)
    /root/fft/  (部署包)
```

如果无 PetaLinux, 可用 U-Boot + 独立bitstream 通过 JTAG 下载:
```
# xsct (Vitis Shell):
connect
targets
fpga -file fft_system.bit
# 然后通过JTAG加载ELF
con
```

## 步骤 3: 部署软件包

```bash
# SCP方式 (板上有网络):
scp -r deploy/ root@<board_ip>:/root/fft/
# 或 U盘方式:
# 将 deploy/ 目录复制到U盘, 插入板上USB口
cp -r /media/usb0/deploy /root/fft/
```

## 步骤 4: 运行 FFT 测试

```bash
cd /root/fft
chmod +x fft_test
./fft_test
```

### 预期输出 (正常时):
```
=== FFT Accelerator Test ===
mmap OK
Config: stage=9, sign_len=100
FFT start...
FFT done!
Cycles: ~842 (512点)
Peak at bin 5: 4995 (expected ~5000)
Peak at bin 507: 4997
Non-peak max: 6
=== PASS ===
```

## 步骤 5: 验证结果

| 检验项 | 方法 | 通过标准 |
|--------|------|---------|
| FFT峰值位置 | 输出txt分析 | bin5 和 bin507 |
| FFT峰值幅度 | 输出txt分析 | ≈5000 (±1%) |
| 非峰抑制 | 输出txt分析 | <100 |
| IFFT信号还原 | 相关性分析 | 增益≈1.0 |
| 与仿真一致 | diff out_512.txt vs sim结果 | bit-exact |
| 执行时间 | main.cpp计时 | ~842拍×10ns ≈ 8.42µs (512点) |

## 步骤 6: 性能评估

```
理论吞吐 = 512点 / 8.42µs = 60.8 MSPS (兆采样/秒)
4096点耗时 = 5859拍 × 10ns = 58.6µs → 69.9 MSPS
```

## 故障排查

| 症状 | 可能原因 | 解决 |
|------|---------|------|
| mmap失败 | 设备树未配置 | 检查 /proc/iomem 是否有 0x43C00000 |
| 读写寄存器全0 | bitstream未加载 | `cat /sys/devices/*fpga*/firmware` 检查 |
| FFT done不触发 | clk/rst未连接 | 用ILA/Chipscope检查 |
| 输出全X | DDR映射错误 | 检查Address Editor分配 |
| 输出错乱 | HP端口连接错误 | 确认M00→HP0直连(无互连) |
| 中断不触发 | IRQ_F2P未使能 | 检查PS7中断配置 |
