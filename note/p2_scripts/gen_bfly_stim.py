"""2R.1 蝶形单元验证：生成 pe_array_col 的激励与期望（C-fl 算术，python int 精确）。

RTL 语义（已从源码解码）：
  P_re = Wr·X2r − Wi·X2i        (split_addsub_inv, is_sub)
  P_im = Wr·X2i + Wi·X2r        (split_add)
  acc_sub = X1·2^15 − P         (sub_array: fft_din − mat_din)
  acc_add = X1·2^15 + P         (add_array_tree)
  odata[mat][i<4] = acc_sub, odata[mat][i+4] = acc_add   (mat0=实部, mat1=虚部)
  mdc 消费值 = acc[31:16] = floor(acc/2^16)
"""
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "bfly_data")
os.makedirs(OUT, exist_ok=True)

sys.path.insert(0, HERE)
from r2mdc_model import build_twiddles  # 复用真实旋转因子表值

NVEC = 64


def gen_vectors():
    tab = build_twiddles(12)
    wr_tab = np.concatenate([tab[d][0].ravel() for d in range(12)])
    wi_tab = np.concatenate([tab[d][1].ravel() for d in range(12)])
    rng = np.random.default_rng(42)

    vecs = []
    # 48 组随机：X1/X2 int16 全域随机，W 取真实旋转因子表值
    for _ in range(48):
        k = rng.integers(0, len(wr_tab))
        vecs.append((int(rng.integers(-32768, 32768)), int(rng.integers(-32768, 32768)),
                     int(rng.integers(-32768, 32768)), int(rng.integers(-32768, 32768)),
                     int(wr_tab[k]), int(wi_tab[k])))
    # 8 组极值：X1/X2 打满 ±32767
    for x1 in (32767, -32768):
        for x2 in (32767, -32768):
            for w in (32767, -32768):
                vecs.append((x1, x1, x2, x2, w, w))
    # 8 组 W 均匀角度扫描（表值）
    for k in np.linspace(0, len(wr_tab) - 1, 8):
        vecs.append((int(rng.integers(-32768, 32768)), int(rng.integers(-32768, 32768)),
                     int(rng.integers(-32768, 32768)), int(rng.integers(-32768, 32768)),
                     int(wr_tab[int(k)]), int(wi_tab[int(k)])))
    return vecs[:NVEC]


def expect(v):
    x1r, x1i, x2r, x2i, wr, wi = v
    pre = wr * x2r - wi * x2i
    pim = wr * x2i + wi * x2r
    sub_r = x1r * 32768 - pre
    add_r = x1r * 32768 + pre
    sub_i = x1i * 32768 - pim
    add_i = x1i * 32768 + pim
    return sub_r, add_r, sub_i, add_i


def main():
    vecs = gen_vectors()
    with open(os.path.join(OUT, "stim.txt"), "w", newline="\n") as f:
        for v in vecs:
            f.write(" ".join(str(x) for x in v) + "\n")
    with open(os.path.join(OUT, "expect.txt"), "w", newline="\n") as f:
        for v in vecs:
            sr, ar, si, ai = expect(v)
            # 每行: acc_sub_re acc_add_re acc_sub_im acc_add_im + 四个 [31:16] 切割值(int16 语义)
            def cut16(x):
                c = (x >> 16) & 0xFFFF
                return c - 65536 if c >= 32768 else c
            f.write(f"{sr} {ar} {si} {ai} {cut16(sr)} {cut16(ar)} {cut16(si)} {cut16(ai)}\n")
    print(f"生成 {len(vecs)} 组: {OUT}/stim.txt + expect.txt")
    # 自检：acc 是否落在 38 位符号范围
    mx = max(max(abs(x) for x in expect(v)) for v in vecs)
    print(f"max|acc| = {mx} (38b signed 范围 {2**37})")


if __name__ == "__main__":
    main()
