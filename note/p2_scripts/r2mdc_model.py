"""P2.1 R2MDC 定点行为模型（fft_cal.m 数据流 1:1 移植 + 4 种级内定点算术候选）。

数据：x (N,) int16 实输入 -> (2, p, N/p) 复数阵列，逐级蝶形+交叉互换，输出自然序 (增益 1/N)。
级内算术候选：
  A: m=floor(P/2^15);  y=floor((x1±m)/2)      两步截位
  B: m=round(P/2^15);  y=round((x1±m)/2)      两步舍入
  C: y=floor((x1*2^15±P)/2^16)                一步截位（ALU 宽位累加单次 cut）
  D: y=round((x1*2^15±P)/2^16)                一步舍入
"""
import math
import os

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
TXT = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "txt"))

c, cp, s = 4, 2, 4
p = c * cp


def quant(v):
    if v > 2.0 ** -15:
        return math.floor(v * 32768.0 - 1)
    if v < -(2.0 ** -15):
        return math.ceil(v * 32768.0 + 1)
    return round(v * 32768.0)


def build_twiddles(Ns):
    """tab[dim][cow] = (wr[NP], wi[NP]) int（与 P1.2 主表同源同值）。"""
    N = 1 << Ns
    NP = N // p
    tab = [[None] * c for _ in range(12)]
    for pipeline in range(3):
        xc = N // (1 << (s * pipeline)) // cp
        lc = (1 << (s * pipeline)) // c
        for stage in range(4):
            dim = pipeline * 4 + stage
            denom = 1 << (s * pipeline + stage + 1)
            wr_t = np.zeros((c, NP), dtype=np.int64)
            wi_t = np.zeros((c, NP), dtype=np.int64)
            for cow in range(c):
                if pipeline == 0:
                    for j in range(NP):
                        m = j % (1 << stage)
                        ang = 2 * math.pi * m / denom
                        wr_t[cow, j] = quant(math.cos(ang))
                        wi_t[cow, j] = quant(-math.sin(ang))
                else:
                    for j in range(lc):
                        for n in range(xc):
                            pos = n + j * xc
                            m = j + lc * (c * (n % (1 << stage)) + cow)
                            ang = 2 * math.pi * m / denom
                            wr_t[cow, pos] = quant(math.cos(ang))
                            wi_t[cow, pos] = quant(-math.sin(ang))
            tab[dim] = (wr_t, wi_t)
    return tab


def ram_in_map(x, Ns):
    """输入比特重排 -> (2, p, N/p)。"""
    N = len(x)
    wc, wp = 2, 1                      # c=4, cp=2
    wa = Ns - wc - wp
    NP = N // p
    idx = np.arange(N)
    pc = np.zeros(N, dtype=np.int64)
    pa = np.zeros(N, dtype=np.int64)
    pp = np.zeros(N, dtype=np.int64)
    for k in range(wc):
        pc += ((idx >> k) & 1) << (wc - 1 - k)
    for k in range(wa):
        pa += ((idx >> (wc + k)) & 1) << (wa - 1 - k)
    for k in range(Ns - wc - wa):
        pp += ((idx >> (wc + wa + k)) & 1) << (Ns - 1 - wc - wa - k)
    ph = pc * cp + pp
    pl = pa
    ram = np.zeros((2, p, NP), dtype=x.dtype)
    ram[0, ph, pl] = x                 # re = x, im = 0
    return ram


def build_twiddles_float(Ns):
    """浮点旋转因子表（oracle 数据流比对用，无量化）。"""
    N = 1 << Ns
    NP = N // p
    tab = [[None] * c for _ in range(12)]
    for pipeline in range(3):
        xc = N // (1 << (s * pipeline)) // cp
        lc = (1 << (s * pipeline)) // c
        for stage in range(4):
            dim = pipeline * 4 + stage
            denom = 1 << (s * pipeline + stage + 1)
            wr_t = np.zeros((c, NP))
            wi_t = np.zeros((c, NP))
            for cow in range(c):
                if pipeline == 0:
                    for j in range(NP):
                        m = j % (1 << stage)
                        ang = 2 * math.pi * m / denom
                        wr_t[cow, j] = math.cos(ang)
                        wi_t[cow, j] = -math.sin(ang)
                else:
                    for j in range(lc):
                        for n in range(xc):
                            pos = n + j * xc
                            m = j + lc * (c * (n % (1 << stage)) + cow)
                            ang = 2 * math.pi * m / denom
                            wr_t[cow, pos] = math.cos(ang)
                            wi_t[cow, pos] = -math.sin(ang)
            tab[dim] = (wr_t, wi_t)
    return tab


def butterfly(data, tw, mode):
    """data (2,p,NP)。lane 2cow/2cow+1 = x1/x2。返回蝶形后 (2,p,NP)。"""
    NP = data.shape[2]
    wr, wi = tw
    out = data.copy()
    for cow in range(c):
        l1, l2 = 2 * cow, 2 * cow + 1
        x1r, x1i = data[0, l1], data[1, l1]
        x2r, x2i = data[0, l2], data[1, l2]
        if mode == "F":
            Pr = wr[cow] * x2r - wi[cow] * x2i
            Pi = wr[cow] * x2i + wi[cow] * x2r
            out[0, l1] = x1r + Pr
            out[1, l1] = x1i + Pi
            out[0, l2] = x1r - Pr
            out[1, l2] = x1i - Pi
            continue
        Pr = wr[cow] * x2r - wi[cow] * x2i
        Pi = wr[cow] * x2i + wi[cow] * x2r
        if mode == "C":
            out[0, l1] = (x1r * 32768 + Pr) >> 16
            out[1, l1] = (x1i * 32768 + Pi) >> 16
            out[0, l2] = (x1r * 32768 - Pr) >> 16
            out[1, l2] = (x1i * 32768 - Pi) >> 16
        elif mode == "D":
            out[0, l1] = np.floor((x1r * 32768 + Pr) / 65536.0 + 0.5).astype(np.int64)
            out[1, l1] = np.floor((x1i * 32768 + Pi) / 65536.0 + 0.5).astype(np.int64)
            out[0, l2] = np.floor((x1r * 32768 - Pr) / 65536.0 + 0.5).astype(np.int64)
            out[1, l2] = np.floor((x1i * 32768 - Pi) / 65536.0 + 0.5).astype(np.int64)
        elif mode == "A":
            mr, mi = Pr >> 15, Pi >> 15
            out[0, l1] = (x1r + mr) >> 1
            out[1, l1] = (x1i + mi) >> 1
            out[0, l2] = (x1r - mr) >> 1
            out[1, l2] = (x1i - mi) >> 1
        else:  # B
            mr = np.floor(Pr / 32768.0 + 0.5).astype(np.int64)
            mi = np.floor(Pi / 32768.0 + 0.5).astype(np.int64)
            out[0, l1] = np.floor((x1r + mr) / 2.0 + 0.5).astype(np.int64)
            out[1, l1] = np.floor((x1i + mi) / 2.0 + 0.5).astype(np.int64)
            out[0, l2] = np.floor((x1r - mr) / 2.0 + 0.5).astype(np.int64)
            out[1, l2] = np.floor((x1i - mi) / 2.0 + 0.5).astype(np.int64)
    return out


def crossbar(data, k):
    """第 k 级交叉互换（k=1..4 -> 2/4/8/16 宽块内半交换，lane 对 a=2n,b=2n+1）。"""
    NP = data.shape[2]
    blk = 1 << k
    h = blk // 2
    out = data.copy()
    for n in range(c):
        a, b = 2 * n, 2 * n + 1
        for j0 in range(NP // blk):
            base = j0 * blk
            out[:, a, base + h:base + blk] = data[:, b, base:base + h]
            out[:, b, base:base + h] = data[:, a, base + h:base + blk]
    return out


def pe2ramin_repack(data, Ns):
    """pipeline 间重排（out_stage==0 分支）。"""
    NP = data.shape[2]
    N = NP * p
    buff = np.zeros_like(data)
    for n in range(p):
        for j in range(NP):
            r = (n % 2) + ((j % 16) * c // 16) * 2
            col = (n // 2) + (j % (16 // c)) * c + (j // 16) * 16
            buff[:, r, col] = data[:, n, j]
    out = np.zeros_like(data)
    for j in range(NP):
        col = (j % 16) * (N // 32 // c) + (j // 16)
        out[:, :, col] = buff[:, :, j]
    return out


def fft_model(x, Ns, tab, mode="C"):
    N = len(x)
    ram = ram_in_map(x, Ns)
    mul = None
    for pipeline in range(3):
        out_stage = Ns - 4 * pipeline if 0 < Ns - 4 * pipeline <= 4 else 0
        cur = ram
        for stage in range(4):
            dim = pipeline * 4 + stage
            mul = butterfly(cur, tab[dim], mode)
            if out_stage != 0 and stage + 1 == out_stage:
                return addr_out(mul, N)          # fft_o = 最后蝶形输出
            if stage < 3:
                cur = crossbar(mul, stage + 1)
            else:
                cur = crossbar(mul, 4)
        ram = pe2ramin_repack(cur, Ns)
    return addr_out(mul, N)


def addr_out(mul, N):
    lc = 256 // c
    xc = N // 512
    fft_o = np.zeros((2, N), dtype=mul.dtype)
    for row in range(c):
        for n in range(lc):
            for j in range(xc):
                a0 = (n + row * lc) + (lc * c * j)
                fft_o[:, a0] = mul[:, 2 * row, n * xc + j]
                fft_o[:, a0 + N // 2] = mul[:, 2 * row + 1, n * xc + j]
    return fft_o


def main():
    vals = np.loadtxt(os.path.join(TXT, "fft_in_rand.txt"), dtype=np.int64)
    x_stream = vals[0::2]
    ref = np.loadtxt(os.path.join(TXT, "fft_out_512_matlab.txt"), dtype=np.int64)
    N = 512
    frames = 4
    for mode in ["A", "B", "C", "D"]:
        tab = build_twiddles(9)
        okr = oki = 0
        maxd = 0
        for f in range(frames):
            x = x_stream[f * N:(f + 1) * N]
            y = fft_model(x, 9, tab, mode)
            rr = ref[(f * N) * 2:(f + 1) * N * 2:2]
            ri = ref[(f * N) * 2 + 1:(f + 1) * N * 2:2]
            okr += int((y[0] == rr).sum())
            oki += int((y[1] == ri).sum())
            maxd = max(maxd, int(np.abs(y[0] - rr).max()), int(np.abs(y[1] - ri).max()))
        print(f"mode {mode}: re {okr}/{frames*N} im {oki}/{frames*N} 一致, max|Δ|={maxd}")


if __name__ == "__main__":
    main()
