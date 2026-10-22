"""P1.3 生成 fft_tb 各仿真所需的输入/旋转因子文件 -> software/fft_software/m/

文件格式（依据 tb 数组声明与 fft_cal.m 写表约定）：
  fft_i_16.txt   16 行 x 16b   （tb_mdc: data_in[15:0]）
  fft_i_64.txt   128 行 x 16b  （tb_mdc_8p: data_in[127:0]）
  fft_i_4096.txt 4096 行 x 32b （tb_fft/tb_fft_256: data_in[4095:0] 32b，行=bin16(im)+bin16(re)）
  ifft_i_4096.txt 4096 行 x 32b（占位：理想FFT线性缩放；P2 行为模型移植后替换）
  rotar_16.txt   64 行 x 16b   （tb_mdc rotar_in[63:0]，re/im 交错对）
  rotar_64.txt   64 行 x 16b   （tb_mdc_8p rotar_in[63:0]）

输入数据源：库内 fft_in_rand.txt 第 0 帧的前 N 个采样（int16 已量化，直接使用不再重量化）。
旋转因子量化约定同 P1.2（floor(v*2^15-1) / ceil(v*2^15+1) / round）。
"""
import math
import os

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
M_DIR = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "m"))
TXT = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "txt"))


def quant(v):
    if v > 2.0 ** -15:
        return math.floor(v * 32768.0 - 1)
    if v < -(2.0 ** -15):
        return math.ceil(v * 32768.0 + 1)
    return round(v * 32768.0)


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

    # --- fft_i_16 / fft_i_64：16b 实数/行 ---
    write_lines("fft_i_16.txt", [b16(v) for v in stream[:16]])
    write_lines("fft_i_64.txt", [b16(v) for v in stream[:128]])

    # --- fft_i_4096：32b = im(0)+re ---
    frame0 = stream[:4096].astype(float)
    write_lines("fft_i_4096.txt",
                [b16(0) + b16(v) for v in stream[:4096]])

    # --- ifft_i_4096：占位（理想 FFT 缩放至 int16，P2 替换为行为模型版本）---
    X = np.fft.fft(frame0)
    g = 30000.0 / np.abs(X).max()
    re_i = np.round((X * g).real).astype(int)
    im_i = np.round((X * g).imag).astype(int)
    write_lines("ifft_i_4096.txt",
                [b16(im) + b16(re) for re, im in zip(re_i, im_i)])

    # --- rotar_16 / rotar_64：re,im 交错 64 行 x 16b ---
    # 约定：rotar_NN.txt 第 k 对 = (cos(2πk/M), -sin(2πk/M))，M=32/64，k=0..31
    for name, M in [("rotar_16.txt", 32), ("rotar_64.txt", 64)]:
        lines = []
        for k in range(32):
            theta = 2 * math.pi * k / M
            lines.append(b16(quant(math.cos(theta))))    # re
            lines.append(b16(quant(-math.sin(theta))))   # im
        write_lines(name, lines)


if __name__ == "__main__":
    main()
