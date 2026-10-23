"""Test#1 蝶形单元: 生成激励与期望 (固定种子, 可复现)

RTL 算术(从 pe_array_col/dual_mac/add_sub_array_tree 源码解码):
  P_re = Wr*X2r - Wi*X2i          (split_addsub_inv, is_sub)
  P_im = Wr*X2i + Wi*X2r          (split_add)
  acc_sub = X1*2^15 - P           (sub_array: fft_din - mat_din)
  acc_add = X1*2^15 + P           (add_array_tree)
  odata[mat][i<4]=acc_sub, [i+4]=acc_add  (mat0=实部, mat1=虚部)
旋转因子量化约定(与 RTL rotar_4096.txt bit-exact 同源):
  v>2^-15: floor(v*2^15-1); v<-2^-15: ceil(v*2^15+1); else round(v*2^15)
"""
import math
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
NVEC = 64


def quant(v):
    if v > 2.0 ** -15:
        return math.floor(v * 32768.0 - 1)
    if v < -(2.0 ** -15):
        return math.ceil(v * 32768.0 + 1)
    return round(v * 32768.0)


def cut16(x):
    c = (x >> 16) & 0xFFFF
    return c - 65536 if c >= 32768 else c


def expect(v):
    x1r, x1i, x2r, x2i, wr, wi = v
    pre = wr * x2r - wi * x2i
    pim = wr * x2i + wi * x2r
    sr, ar = x1r * 32768 - pre, x1r * 32768 + pre
    si, ai = x1i * 32768 - pim, x1i * 32768 + pim
    return sr, ar, si, ai, cut16(sr), cut16(ar), cut16(si), cut16(ai)


def main():
    rng = random.Random(42)
    vecs = []
    # 48 组随机: X1/X2 int16 全域, W 取真实旋转因子量化值(角度均匀)
    for _ in range(48):
        k = rng.randint(0, 4095)
        th = 2 * math.pi * k / 4096
        vecs.append((rng.randint(-32768, 32767), rng.randint(-32768, 32767),
                     rng.randint(-32768, 32767), rng.randint(-32768, 32767),
                     quant(math.cos(th)), quant(-math.sin(th))))
    # 8 组极值: X1/X2/W 打满正负满量程
    for x1 in (32767, -32768):
        for x2 in (32767, -32768):
            for w in (32767, -32768):
                vecs.append((x1, x1, x2, x2, w, w))
    # 8 组角度扫描(确定性)
    for k in range(0, 4096, 512):
        th = 2 * math.pi * k / 4096
        vecs.append((rng.randint(-32768, 32767), rng.randint(-32768, 32767),
                     rng.randint(-32768, 32767), rng.randint(-32768, 32767),
                     quant(math.cos(th)), quant(-math.sin(th))))
    vecs = vecs[:NVEC]

    with open(os.path.join(HERE, "bfly_stim.txt"), "w", newline="\n") as f:
        for v in vecs:
            f.write(" ".join(str(x) for x in v) + "\n")
    with open(os.path.join(HERE, "bfly_expect.txt"), "w", newline="\n") as f:
        for v in vecs:
            f.write(" ".join(str(x) for x in expect(v)) + "\n")
    print(f"生成 {NVEC} 组 -> bfly_stim.txt + bfly_expect.txt")


if __name__ == "__main__":
    main()
