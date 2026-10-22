"""2R.3 系统级 FFT 仿真：生成 512 点激励与 C-fl 模型期望。"""
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from r2mdc_model import build_twiddles, fft_model

TXT = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "txt"))
OUT = os.path.join(HERE, "sys_data")
os.makedirs(OUT, exist_ok=True)


def main():
    vals = np.loadtxt(os.path.join(TXT, "fft_in_rand.txt"), dtype=np.int64)
    xs = vals[0::2]
    x = xs[:512]
    np.savetxt(os.path.join(OUT, "sys_in_512.txt"), x, fmt="%d")

    tab = build_twiddles(9)
    y = fft_model(x, 9, tab, "C")
    with open(os.path.join(OUT, "sys_expect_512.txt"), "w", newline="\n") as f:
        for re, im in zip(y[0], y[1]):
            f.write(f"{re} {im}\n")
    print("生成 sys_in_512.txt(512 实数) + sys_expect_512.txt(C-fl 期望 512 复数)")


if __name__ == "__main__":
    main()
