"""Phase 5 Step 2: 生成 IP component.xml + 复制约束和BD脚本"""
import os
import re
import shutil

BASE = os.path.dirname(os.path.abspath(__file__))
IP_DIR = os.path.join(BASE, "ip_repo", "ai_fft_1.0")

# 读取顶层端口
top_file = os.path.join(IP_DIR, "src", "sys", "ai_acce_top.sv")
with open(top_file, encoding="utf-8", errors="surrogateescape") as f:
    top_src = f.read()

# 解析端口
m = re.search(r'module\s+ai_acce_top\s*#\((.*?)\)\s*\(', top_src, re.DOTALL)
if not m:
    print("ERROR: 无法解析顶层"); exit(1)
print("顶层模块端口解析成功")

# 生成简化 component.xml
# (Vivado 可以自动从端口推断大部分内容)
xml_parts = []
xml_parts.append('<?xml version="1.0" encoding="UTF-8"?>')
xml_parts.append('<spirit:component xmlns:spirit="http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009">')
xml_parts.append('  <spirit:vendor>xilinx.com</spirit:vendor>')
xml_parts.append('  <spirit:library>user</spirit:library>')
xml_parts.append('  <spirit:name>ai_fft</spirit:name>')
xml_parts.append('  <spirit:version>1.0</spirit:version>')
xml_parts.append('  <spirit:fileSets>')
xml_parts.append('    <spirit:fileSet>')
xml_parts.append('      <spirit:name>sources</spirit:name>')

# 列出所有源文件
for root, dirs, files in os.walk(IP_DIR):
    for f in sorted(files):
        if f.endswith((".sv", ".v")):
            rel = os.path.relpath(os.path.join(root, f), IP_DIR).replace("\\", "/")
            ftype = "systemVerilogSource" if f.endswith(".sv") else "verilogSource"
            xml_parts.append(f'      <spirit:file><spirit:name>{rel}</spirit:name><spirit:fileType>{ftype}</spirit:fileType></spirit:file>')
        elif f.endswith(".svh"):
            rel = os.path.relpath(os.path.join(root, f), IP_DIR).replace("\\", "/")
            xml_parts.append(f'      <spirit:file><spirit:name>{rel}</spirit:name><spirit:fileType>systemVerilogHeader</spirit:fileType></spirit:file>')
        elif f.endswith(".txt"):
            rel = os.path.relpath(os.path.join(root, f), IP_DIR).replace("\\", "/")
            xml_parts.append(f'      <spirit:file><spirit:name>{rel}</spirit:name><spirit:fileType>text</spirit:fileType></spirit:file>')

xml_parts.append('    </spirit:fileSet>')
xml_parts.append('  </spirit:fileSets>')
xml_parts.append('  <spirit:model>')
xml_parts.append('    <spirit:views>')
xml_parts.append('      <spirit:view>')
xml_parts.append('        <spirit:name>synthesis</spirit:name>')
xml_parts.append('        <spirit:identifier>synthesis</spirit:identifier>')
xml_parts.append('        <spirit:language>systemVerilog</spirit:language>')
xml_parts.append('        <spirit:modelName>ai_acce_top</spirit:modelName>')
xml_parts.append('      </spirit:view>')
xml_parts.append('    </spirit:views>')
xml_parts.append('  </spirit:model>')
xml_parts.append('</spirit:component>')

xml = "\n".join(xml_parts)
with open(os.path.join(IP_DIR, "component.xml"), "w", encoding="utf-8", newline="\n") as f:
    f.write(xml)
print(f"component.xml: {len(xml)} bytes, {len(xml_parts)} 行")

# 复制约束
xdc_src = os.path.join(BASE, "project_psoc", "project_psoc.srcs", "constrs_1", "new", "fpga.xdc")
xdc_dst = os.path.join(BASE, "constraints", "fpga.xdc")
os.makedirs(os.path.dirname(xdc_dst), exist_ok=True)
shutil.copy2(xdc_src, xdc_dst)
print(f"约束: {xdc_dst}")

# 复制 BD 脚本
bd_src = os.path.join(BASE, "project_psoc", "project_psoc.srcs", "sources_1", "bd", "design_1", "hw_handoff", "design_1_bd.tcl")
bd_dst = os.path.join(BASE, "bd", "design_1.tcl")
os.makedirs(os.path.dirname(bd_dst), exist_ok=True)
shutil.copy2(bd_src, bd_dst)
print(f"BD脚本: {bd_dst}")

print("\n=== IP 打包完成 ===")
print(f"IP目录: {IP_DIR}")
print(f"文件数: {sum(len(files) for _, _, files in os.walk(IP_DIR))}")
