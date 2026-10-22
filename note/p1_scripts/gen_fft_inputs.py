"""P1.3 生成 FFT 系统仿真所需输入文件 -> software/fft_software/m/

（fft_tb 旧 tb 族已于 P2 删除，16/64 点小文件不再生成）
  fft_i_4096.txt 4096 行 x 32b（bin16(im)+bin16(re)，输入流第 0 帧）
  ifft_i_4096.txt 4096 行 x 32b（占位：理想FFT线性缩放；待 C-fl 模型重生成）
"""
import math
import os

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
M_DIR = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "m"))
TXT = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "txt"))


def b16(v):
    return format(int(v) & 0xFFFF, "016b")


def load_stream():
    """fft_in_rand.txt: 're 0 re 0 ...' 交错，取偶数位实部。"""
    vals = np.loadtxt(os.path.join(TXT, "fft_in_rand.txt"), dtype=np.int64)
    re = vals[0::2]
    assert np.all(vals[1::2] == 0), "虚部位非 0"
    return re  # 409600 个 int16 采样


def write_lines(name, lines):
    path = os.path.join(M_DIR, name)
    with open(path, "w", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    print(f"{name}: {len(lines)} 行 -> {path}")


def main():
    os.makedirs(M_DIR, exist_ok=True)
    stream = load_stream()
    print(f"输入流采样数: {len(stream)}")

    # --- fft_i_4096：32b = im(0)+re ---
    frame0 = stream[:4096].astype(float)
    write_lines("fft_i_4096.txt",
                [b16(0) + b16(v) for v in stream[:4096]])

    # --- ifft_i_4096：占位（理想 FFT 缩放至 int16，P2R.3 IFFT 模式时用 C-fl 模型重生成）---
    X = np.fft.fft(frame0)
    g = 30000.0 / np.abs(X).max()
    re_i = np.round((X * g).real).astype(int)
    im_i = np.round((X * g).imag).astype(int)
    write_lines("ifft_i_4096.txt",
                [b16(im) + b16(re) for re, im in zip(re_i, im_i)])


if __name__ == "__main__":
    main()
