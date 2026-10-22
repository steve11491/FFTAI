"""P2.2 级内舍入约定组合枚举：在 N=512 帧0 上对库真值拟合最优组合。"""
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from r2mdc_model import (build_twiddles, build_twiddles_float, crossbar,
                         pe2ramin_repack, ram_in_map, addr_out, c, cp, s, p)

HERE = os.path.dirname(os.path.abspath(__file__))
TXT = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "txt"))

RND = {
    "fl": lambda v: np.floor(v),                                    # 往 -inf 截
    "fx": lambda v: np.fix(v),                                      # 往 0 截
    "up": lambda v: np.floor(v + 0.5),                              # half-up
    "aw": lambda v: np.where(v >= 0, np.floor(v + 0.5), np.ceil(v - 0.5)),  # MATLAB round
    "ev": lambda v: np.round(v),                                    # half-even
}
INT = {k: (lambda f: (lambda v: f(v).astype(np.int64)))(f) for k, f in RND.items()}


def butterfly_gen(data, tw, onestep, mul_r, div_r):
    wr, wi = tw
    out = data.copy()
    for cow in range(c):
        l1, l2 = 2 * cow, 2 * cow + 1
        x1r, x1i = data[0, l1], data[1, l1]
        x2r, x2i = data[0, l2], data[1, l2]
        Pr = wr[cow] * x2r - wi[cow] * x2i
        Pi = wr[cow] * x2i + wi[cow] * x2r
        if onestep:
            out[0, l1] = INT[div_r]((x1r * 32768 + Pr) / 65536.0)
            out[1, l1] = INT[div_r]((x1i * 32768 + Pi) / 65536.0)
            out[0, l2] = INT[div_r]((x1r * 32768 - Pr) / 65536.0)
            out[1, l2] = INT[div_r]((x1i * 32768 - Pi) / 65536.0)
        else:
            mr, mi = INT[mul_r](Pr / 32768.0), INT[mul_r](Pi / 32768.0)
            out[0, l1] = INT[div_r]((x1r + mr) / 2.0)
            out[1, l1] = INT[div_r]((x1i + mi) / 2.0)
            out[0, l2] = INT[div_r]((x1r - mr) / 2.0)
            out[1, l2] = INT[div_r]((x1i - mi) / 2.0)
    return out


def fft_gen(x, Ns, tabI, tabF, use_float_tw, onestep, mul_r, div_r):
    N = len(x)
    tab = tabF if use_float_tw else tabI
    ram = ram_in_map(x, Ns)
    for pipeline in range(3):
        out_stage = Ns - 4 * pipeline if 0 < Ns - 4 * pipeline <= 4 else 0
        cur = ram
        for stage in range(4):
            dim = pipeline * 4 + stage
            tw = tab[dim]
            if use_float_tw:  # 浮点旋转因子: 先 int 化乘积（P 为 float，舍入函数处理）
                pass
            mul = butterfly_gen(cur, tw, onestep, mul_r, div_r)
            if out_stage != 0 and stage + 1 == out_stage:
                return addr_out(mul, N)
            cur = crossbar(mul, stage + 1 if stage < 3 else 4)
        ram = pe2ramin_repack(cur, Ns)
    return addr_out(mul, N)


def main():
    vals = np.loadtxt(os.path.join(TXT, "fft_in_rand.txt"), dtype=np.int64)
    xs = vals[0::2]
    ref = np.loadtxt(os.path.join(TXT, "fft_out_512_matlab.txt"), dtype=np.int64)
    N = 512
    x = xs[:N]
    rr = ref[0:2 * N:2]
    ri = ref[1:2 * N:2]
    tabI = build_twiddles(9)
    tabF = build_twiddles_float(9)

    results = []
    for tw_name, tw_flag in [("表值", False), ("浮点", True)]:
        for onestep in [False, True]:
            modes = [("fl", div) for div in RND] if onestep else \
                [(mul, div) for mul in RND for div in RND]
            for mul_r, div_r in modes:
                y = fft_gen(x, 9, tabI, tabF, tw_flag, onestep, mul_r, div_r)
                okr = int((y[0] == rr).sum())
                oki = int((y[1] == ri).sum())
                w1 = int((np.abs(y[0] - rr) <= 1).sum() + (np.abs(y[1] - ri) <= 1).sum())
                results.append((okr + oki, w1, tw_name, onestep, mul_r, div_r,
                                int(np.abs(y[0] - rr).max())))
    results.sort(reverse=True)
    print("top 10 (满分 1024):")
    for r in results[:10]:
        print(f"  一致={r[0]:4d} |Δ|≤1={r[1]:4d} tw={r[2]} onestep={r[3]} mul={r[4]} div={r[5]} max|Δ|={r[6]}")


if __name__ == "__main__":
    main()
