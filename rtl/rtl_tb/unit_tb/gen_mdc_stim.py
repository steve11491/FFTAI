"""Test#4 mdc: 生成 16 点 FFT 输入激励与期望输出

输入: x[n] = round(10000*cos(2*pi*3*n/16)), n=0..15 (单音, 频率 bin 3)
DIT 输入顺序: 路0=x[t], 路1=x[t+8], t=0..7 (第一级蝶形配对)

期望输出: 4 级 R2MDC 流水线结果(位反序)
用 r2mdc_model 的逻辑计算(单管线 4 级, C-fl 量化)
"""
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, "..", "..", "..", "note", "p2_scripts")))
from r2mdc_model import build_twiddles, butterfly, crossbar, pe2ramin_repack, quant


def tw16(k):
    """W_{16}^k = (cos(2πk/16), -sin(2πk/16)) 量化"""
    return quant(math.cos(2*math.pi*k/16)), quant(-math.sin(2*math.pi*k/16))


def main():
    N = 16
    # 生成输入
    x = np.round(10000 * np.cos(2 * np.pi * 3 * np.arange(N) / N)).astype(int)
    np.savetxt(os.path.join(HERE, "mdc_in_16.txt"), x, fmt="%d")

    # DIT 输入配对: clock t: 路0=x[t], 路1=x[t+8]
    # 每行: real_0 imag_0 real_1 imag_1
    with open(os.path.join(HERE, "mdc_stim.txt"), "w", newline="\n") as f:
        for t in range(8):
            f.write(f"{x[t]} 0 {x[t+8]} 0\n")

    # 期望输出: 用浮点 FFT 计算理论值, 除以 N (4 级每级除2)
    X = np.fft.fft(x.astype(float)) / N
    # 位反序输出
    br = [int(format(i, "04b")[::-1], 2) for i in range(N)]
    X_br = X[br]
    with open(os.path.join(HERE, "mdc_expect.txt"), "w", newline="\n") as f:
        for i in range(N):
            f.write(f"{X_br[i].real:.2f} {X_br[i].imag:.2f}\n")

    print(f"输入: 16 点单音 bin3, 峰值≈{10000*16/2/16:.0f}")
    print(f"期望输出前 4 值: {[f'({X_br[i].real:.1f},{X_br[i].imag:.1f})' for i in range(4)]}")


if __name__ == "__main__":
    main()
