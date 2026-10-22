"""P1.3 库内 FFT 参考输出语义校验。

fft_in_rand.txt = 409600 个实采样（100 帧 x 4096 点）。
fft_out_{N}_matlab.txt = 同一流按 N 点分帧的参考输出（复数对）。
用 numpy 理想 FFT 拟合增益 g（最小二乘），统计 round(g*ideal) 与库值的偏差：
判定"语义正确"= 增益接近简单常数（2 的幂/N 组合）且误差为小值量化噪声（|Δ| 小、dB 低）。
"""
import os

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
TXT = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "txt"))


def load(name):
    return np.loadtxt(os.path.join(TXT, name), dtype=np.float64)


def main():
    vals = load("fft_in_rand.txt")
    x = vals[0::2]
    assert np.all(vals[1::2] == 0)
    total = len(x)
    print(f"采样总数 {total}")

    for N in [512, 1024, 2048, 4096]:
        frames = total // N
        out = load(f"fft_out_{N}_matlab.txt")
        assert len(out) == frames * N * 2, (len(out), frames * N * 2)
        outc = out[0::2] + 1j * out[1::2]          # (frames*N,) complex
        outc = outc.reshape(frames, N)
        xr = x[: frames * N].reshape(frames, N)
        ideal = np.fft.fft(xr, axis=1)

        # 最小二乘复增益
        g = (outc * ideal.conj()).sum() / (np.abs(ideal) ** 2).sum()
        est = g * ideal
        err = outc - est
        exact = (np.round(est) == outc).mean() * 100
        within1 = (np.abs(err) <= 1).mean() * 100
        rms_db = 20 * np.log10(np.sqrt((np.abs(err) ** 2).mean())
                               / np.sqrt((np.abs(outc) ** 2).mean()))
        print(f"N={N:5d} 帧数={frames:4d} g={g.real:.6g}{g.imag:+.3g}j "
              f"|g|={abs(g):.6g} (≈2^{np.log2(abs(g)):+.3f}) "
              f"完全一致={exact:.3f}% |Δ|≤1={within1:.3f}% "
              f"max|Δ|={np.abs(err).max():.1f} rms={rms_db:.1f}dB")


if __name__ == "__main__":
    main()
