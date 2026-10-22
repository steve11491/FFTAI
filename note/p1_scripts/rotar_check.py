"""P1.2 旋转因子闭环对拍：用 fft_cal.m 的量化约定再生成 2048 项主表，
与 rtl/rtl_src/src/fft/rotar_4096.txt 逐值比对（bit-exact 判据）。

量化约定（来自 rotar.m 注释段 / fft_cal.m 写表段）：
  v >  2^-15 : floor(v*2^15 - 1)
  v < -2^-15 : ceil(v*2^15 + 1)
  其他       : round(v*2^15)
打包：32'b = {imag(16b), real(16b)}，共轭旋转因子 im=-sin(theta), re=cos(theta)
"""
import math
import sys

RTL_TABLE = r"D:\project_PLF\FFTAI\rtl\rtl_src\src\fft\rotar_4096.txt"
N = 4096


def quant(v):
    """MATLAB 侧定点量化约定（Python 精确移植）。"""
    if v > 2.0 ** -15:
        return math.floor(v * 2.0 ** 15 - 1)
    if v < -(2.0 ** -15):
        return math.ceil(v * 2.0 ** 15 + 1)
    return round(v * 2.0 ** 15)  # MATLAB round: 四舍五入 HALF Away


def gen_word(k, denom=N):
    theta = 2.0 * math.pi * k / denom
    re = quant(math.cos(theta))
    im = quant(-math.sin(theta))
    word = ((im & 0xFFFF) << 16) | (re & 0xFFFF)
    return format(word, "032b")


def main():
    with open(RTL_TABLE) as f:
        rtl_lines = [line.strip() for line in f if line.strip()]
    total = len(rtl_lines)
    print(f"RTL 表行数: {total}")

    mismatch = []
    for k, line in enumerate(rtl_lines):
        hyp = gen_word(k)
        if hyp != line:
            mismatch.append((k, line, hyp))

    print(f"比对结果: {total - len(mismatch)}/{total} 一致, 不一致 {len(mismatch)}")
    if mismatch:
        print("前 10 处差异 (k, RTL值, 重生成值):")
        for k, rtl_v, hyp_v in mismatch[:10]:
            print(f"  k={k}: rtl={rtl_v} hyp={hyp_v}")
        sys.exit(1)
    print("PASS: 旋转因子主表 bit-exact 一致")


if __name__ == "__main__":
    main()
