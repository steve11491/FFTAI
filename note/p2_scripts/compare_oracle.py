"""Python 浮点模型 vs MATLAB oracle 逐级比对，定位数据流移植的第一处分歧。"""
import os

import numpy as np

from r2mdc_model import (addr_out, build_twiddles_float, crossbar,
                         pe2ramin_repack, ram_in_map, butterfly, c, s)

HERE = os.path.dirname(os.path.abspath(__file__))
ORC = os.path.join(HERE, "oracle")
Ns = 9
N = 1 << Ns
NP = N // 8


def ld(name):
    return np.loadtxt(os.path.join(ORC, name + ".txt"))


def cmp_arr(label, mine, ref, tol=1e-9):
    m = np.asarray(mine, dtype=float).reshape(-1)
    r = np.asarray(ref, dtype=float).reshape(-1)
    d = np.abs(m - r)
    n_bad = int((d > tol).sum())
    tag = "OK " if n_bad == 0 else "DIFF"
    print(f"[{tag}] {label}: max|Δ|={d.max():.3g} 不一致 {n_bad}/{d.size}")
    if n_bad:
        i0 = int(np.argmax(d > tol))
        print(f"       首处 [{i0}]: mine={m[i0]} oracle={r[i0]}")
    return n_bad == 0


def main():
    x = ld("x").reshape(1, -1)[0]
    tab = build_twiddles_float(Ns)
    ram = ram_in_map(x.astype(np.float64), Ns)

    ok = True
    ok &= cmp_arr("ram_in(vs s1i_1)", ram[0], ld("s1i_1"))
    ok &= cmp_arr("axi2ramin", ram[0], ld("axi2ramin"))

    cur = ram
    outs = {1: "s1o", 2: "s2o", 3: "s3o", 4: "s4o"}
    for pipeline in range(1, 4):
        out_stage = Ns - 4 * (pipeline - 1)
        out_stage = out_stage if 0 < out_stage <= 4 else 0
        for stage in range(1, 5):
            dim = (pipeline - 1) * 4 + (stage - 1)
            mul = butterfly(cur, tab[dim], "F")
            if out_stage != 0 and stage == out_stage:
                y = addr_out(mul, N)
                ok &= cmp_arr("fft_o re", y[0], ld("ffto_re").reshape(1, -1))
                ok &= cmp_arr("fft_o im", y[1], ld("ffto_im").reshape(1, -1))
                print("\n结论:", "数据流一致" if ok else "存在分歧（见上方首个 DIFF）")
                return
            cur = crossbar(mul, stage)
            if pipeline < 3 or True:
                ok &= cmp_arr(f"{outs[stage]}_{pipeline}", cur[0], ld(f"{outs[stage]}_{pipeline}"))
                im_f = f"{outs[stage]}_{pipeline}_im"
                if os.path.exists(os.path.join(ORC, im_f + ".txt")):
                    ok &= cmp_arr(f"{im_f}", cur[1], ld(im_f))
        cur = pe2ramin_repack(cur, Ns)
        ok &= cmp_arr(f"pe2ramin_{pipeline}", cur[0], ld(f"pe2ri_{pipeline}"))
    print("意外结束（未命中 out_stage 分支）")


if __name__ == "__main__":
    main()
