"""P1.2 完整移植 fft_cal.m 的旋转因子生成，与 rtl/rotar_4096.txt 对拍。

结构（fft_cal.m:96-265 + 547-558 + 560-585）：
  p9..p12 = 第9/10/11/12级旋转因子值表 (c x 512)，角度 = 2π·m/2^(4·pipeline+stage+1)
  cordic_rom(:, 8g+0) = p9(:, 8g)        rom(:,8g+1) = p10(:,8g)
  rom(:,8g+2..3) = p11(:,8g..8g+1)   rom(:,8g+4..7) = p12(:,8g..8g+3)
  主表第 k 行 = cow k//512 的 rom 列 k%512，行内容 = bin16(im)+bin16(re)
"""
import math

RTL = r"D:\project_PLF\FFTAI\rtl\rtl_src\src\fft\rotar_4096.txt"
c, cp, s, Ns = 4, 2, 4, 12
p = c * cp          # 8
N = 1 << Ns         # 4096
NP = N // p         # 512


def quant(v):
    if v > 2.0 ** -15:
        return math.floor(v * 32768.0 - 1)
    if v < -(2.0 ** -15):
        return math.ceil(v * 32768.0 + 1)
    return round(v * 32768.0)  # MATLAB round: half away from zero


# dim(0-based 0..11) -> [cow][pos] = (re, im)
tab = [[[None] * NP for _ in range(c)] for _ in range(12)]
for pipeline in range(3):
    xc = N // (1 << (s * pipeline)) // cp
    lc = (1 << (s * pipeline)) // c
    for stage in range(4):
        dim = pipeline * 4 + stage
        denom = 1 << (s * pipeline + stage + 1)
        for cow in range(c):
            if pipeline == 0:
                for j in range(NP):
                    m = j % (1 << stage)
                    ang = 2 * math.pi * m / denom
                    tab[dim][cow][j] = (math.cos(ang), -math.sin(ang))
            else:
                for j in range(lc):
                    for n in range(xc):
                        pos = n + j * xc
                        m = j + lc * (c * (n % (1 << stage)) + cow)
                        ang = 2 * math.pi * m / denom
                        tab[dim][cow][pos] = (math.cos(ang), -math.sin(ang))

p9, p10, p11, p12 = tab[8], tab[9], tab[10], tab[11]

rom = [[None] * NP for _ in range(c)]
for g in range(NP // 8):
    b, q = 8 * g, 8 * g
    for cow in range(c):
        rom[cow][b + 0] = p9[cow][q]
        rom[cow][b + 1] = p10[cow][q]
        rom[cow][b + 2] = p11[cow][q]
        rom[cow][b + 3] = p11[cow][q + 1]
        rom[cow][b + 4] = p12[cow][q]
        rom[cow][b + 5] = p12[cow][q + 1]
        rom[cow][b + 6] = p12[cow][q + 2]
        rom[cow][b + 7] = p12[cow][q + 3]

with open(RTL) as f:
    rtl = [ln.strip() for ln in f if ln.strip()]

print(f"RTL 行数 {len(rtl)}，逐行对拍中……")
stats = {}   # 来源表 -> [match, total]
diffs = []
for k in range(2048):
    cow, col = divmod(k, NP)
    src = ["p9", "p10", "p11", "p11", "p12", "p12", "p12", "p12"][col % 8]
    re_v, im_v = rom[cow][col]
    line = format((quant(im_v) & 0xFFFF) << 16 | (quant(re_v) & 0xFFFF), "032b")
    st = stats.setdefault(src, [0, 0])
    st[1] += 1
    if line == rtl[k]:
        st[0] += 1
    else:
        diffs.append((k, cow, col, src, rtl[k], line))

for src, (m, t) in stats.items():
    print(f"  {src}: {m}/{t}")
print(f"总计: {2048 - len(diffs)}/2048")
print("\n前 12 处差异 (k, cow, col, src, rtl, regen):")
for d in diffs[:12]:
    print("  ", d)
