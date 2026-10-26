"""Test#6: 多点数回归 — 编译一次, 按 NPOINT/STAGE 分别运行"""
import os
import subprocess
import sys

import numpy as np

SIM = "D:/project_PLF/FFTAI/sim/fft_reg"
XVLOG = "D:/Vivado2022/Vivado/2022.2/bin/xvlog.bat"
XELAB = "D:/Vivado2022/Vivado/2022.2/bin/xelab.bat"
SRC = "D:/project_PLF/FFTAI/rtl/rtl_src/src"
TB = "D:/project_PLF/FFTAI/rtl/rtl_tb/unit_tb/tb_fft_reg.sv"
MEM = "D:/project_PLF/FFTAI/rtl/rtl_src/memory"
FIFO = "D:/project_PLF/FFTAI/rtl/rtl_src/fifo"

os.makedirs(SIM, exist_ok=True)

# 编译一次(全部源)
print("编译...", flush=True)
r = subprocess.run(
    f'cmd /c "{XVLOG} -sv -i {SRC} {SRC}\\*\\*.sv {SRC}\\*\\*.v {SRC}\\*.svh {MEM}\\*.v {FIFO}\\*.sv {TB} > NUL 2>&1"',
    shell=True, cwd=SIM, timeout=300)
print(f"编译 exit={r.returncode}", flush=True)

CASES = [
    (512,  9,  "NPOINT=512",  "STAGE=9"),
    (1024, 10, "NPOINT=1024", "STAGE=10"),
    (2048, 11, "NPOINT=2048", "STAGE=11"),
    (4096, 12, "NPOINT=4096", "STAGE=12"),
]

for npoint, stage, dnp, dst in CASES:
    print(f"\n===== {npoint} 点 (stage {stage}) =====", flush=True)
    # 用 define 重编译 tb (只需重编 tb 文件)
    r = subprocess.run(
        f'cmd /c "{XVLOG} -sv -d {dnp} -d {dst} -i {SRC} {TB} > NUL 2>&1"',
        shell=True, cwd=SIM, timeout=120)

    # 运行
    r = subprocess.run(
        f'cmd /c "{XELAB} tb_fft_reg -snapshot tb_reg_{npoint} --timescale 1ns/1ps -R > run_{npoint}.log 2>&1"',
        shell=True, cwd=SIM, timeout=600)

    # 分析
    try:
        rows = []
        for ln in open(os.path.join(SIM, "out.txt")):
            if 'x' in ln: continue
            rows.append([int(v) for v in ln.split()])
        act = np.array(rows, dtype=np.int64)
        ar = act[:, 0::2].reshape(-1); ai = act[:, 1::2].reshape(-1)
        oc = ar + 1j*ai; n = len(ar)
        mag = np.abs(oc)
        top = np.argsort(mag)[::-1][:4]

        # 期望: 峰在 bin5 和 N-5
        ok_pos = (5 in top[:2]) and ((npoint-5) in top[:2] or (npoint-5) in top)
        peak1 = mag[5] if 5 < n else 0
        peak2 = mag[npoint-5] if npoint-5 < n else 0
        ok_amp = peak1 > 4000 and peak2 > 4000

        # 非峰
        mask = np.ones(n, dtype=bool)
        for k in range(-2, 3):
            if 5+k < n: mask[5+k] = False
            if npoint-5+k < n: mask[npoint-5+k] = False
        nonpeak_max = mag[mask].max() if mask.any() else 0
        ok_supp = nonpeak_max < 100

        status = "PASS" if (ok_pos and ok_amp and ok_supp) else "FAIL"
        print(f"  峰: bin5={peak1:.0f}, bin{npoint-5}={peak2:.0f} "
              f"(期望≈5000)  非峰max={nonpeak_max:.0f}  [{status}]")
        print(f"  前4大bin: {[(int(t), int(mag[t])) for t in top]}")
    except Exception as e:
        print(f"  分析失败: {e}")

print("\n回归完成")
