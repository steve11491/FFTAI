"""从 fft_cal.m 生成 MATLAB oracle 脚本 p2_oracle_512.m：
Ns=9、x_o=库内流第0帧、截掉写文件/画图尾巴、追加中间数组 dump。"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "m", "fft_cal.m"))
DST = os.path.normpath(os.path.join(HERE, "..", "..", "software", "fft_software", "m", "p2_oracle_512.m"))
OUT = os.path.join(HERE, "oracle")
os.makedirs(OUT, exist_ok=True)

lines = open(SRC, encoding="utf-8", errors="surrogateescape").read().splitlines()

out = []
inserted = False
for i, ln in enumerate(lines):
    n = i + 1
    if ln.strip().startswith("Ns=12"):
        out.append("Ns=9; %P2 oracle")
        continue
    if n == 26 and not inserted:  # 输入 if/else 结束后，覆盖 x_o
        out.append("v_orc = load('D:/project_PLF/FFTAI/software/fft_software/txt/fft_in_rand.txt');")
        out.append("x_o = reshape(v_orc(1:2:1024),1,512);")
        out.append("debug = 0;")
        inserted = True
        out.append(ln)
        continue
    if ln.strip().startswith("%matlab fft"):  # 截断尾巴
        break
    out.append(ln)

dump = ["% ---- P2 oracle dumps ----",
        f"O = '{OUT}';"]
arrs = [("x", "x_o"),
        ("axi2ramin", "axi2ramin"),
        ("addr_out", "addr_out")]
for i in range(1, 4):
    arrs += [(f"s1i_{i}", f"reshape(pe_s1_i(1,:,:,{i}),p,N/p)"),
             (f"s1i_{i}_im", f"reshape(pe_s1_i(2,:,:,{i}),p,N/p)"),
             (f"s1o_{i}", f"reshape(pe_s1_o(1,:,:,{i}),p,N/p)"),
             (f"s1o_{i}_im", f"reshape(pe_s1_o(2,:,:,{i}),p,N/p)"),
             (f"s2o_{i}", f"reshape(pe_s2_o(1,:,:,{i}),p,N/p)"),
             (f"s2o_{i}_im", f"reshape(pe_s2_o(2,:,:,{i}),p,N/p)"),
             (f"s3o_{i}", f"reshape(pe_s3_o(1,:,:,{i}),p,N/p)"),
             (f"s4o_{i}", f"reshape(pe_s4_o(1,:,:,{i}),p,N/p)"),
             (f"pe2ri_{i}", f"reshape(pe2ramin(1,:,:,{i}),p,N/p)")]
arrs += [("ffto_re", "fft_o(1,:)"), ("ffto_im", "fft_o(2,:)")]
for name, expr in arrs:
    dump.append(f"dlmwrite([O '/{name}.txt'], {expr}, 'delimiter',' ', 'precision', 16);")
dump.append("disp('ORACLE-DONE');")
dump.append("exit;")
out += dump

open(DST, "w", encoding="utf-8", errors="surrogateescape", newline="\n").write("\n".join(out) + "\n")
print("生成", DST, f"({len(out)} 行)")
