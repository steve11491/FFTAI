# 用2018.3: 只读打开原工程 → 另存副本 → 综合
open_project -read_only project_psoc/project_psoc.xpr
puts "只读打开成功, 另存副本..."

# 另存为可写副本
save_project_as project_psoc_v2 ./project_psoc_v2 -force
close_project

# 打开副本(2018.3格式)
open_project ./project_psoc_v2/project_psoc_v2.xpr
puts "副本工程打开成功"

# 更新 ipshared 中被修复的文件
set ipshared "project_psoc_v2.srcs/sources_1/bd/design_1/ipshared/9401"
set src_ip "ip_repo/ai_fft_1.0"
set fixes [list \
    "alu/split_add.sv" "alu/split_addsub.sv" \
    "alu/split_add_equal_width.sv" \
    "alu/split_mul_true_dual_8bit.sv" \
    "alu/split_mul_simple_dual_8bit.sv" \
    "pool/split_add_tree.sv" "quan/input_scale.sv" \
]
foreach f $fixes {
    set src "$src_ip/src/$f"
    set dst "$ipshared/rtl_all/src/$f"
    if {[file exists $src] && [file exists $dst]} {
        file copy -force $src $dst
        puts "  更新: $f"
    }
}
# 更新 ai_fft_define.svh(路径修复)
file copy -force "$src_ip/src/ai_fft_define.svh" "$ipshared/src/ai_fft_define.svh"
# 更新 dma_ffto(声明顺序修复)
file copy -force "$src_ip/src/dma/dma_ffto.sv" "$ipshared/rtl_all/src/dma/dma_ffto.sv"
# 更新旋转因子表
file copy -force "$src_ip/src/fft/rotar_4096.txt" "$ipshared/rtl_all/src/fft/rotar_4096.txt"

# 重新生成 ai_fft IP
set ai_ip [get_ips -quiet *ai_fft*]
if {[llength $ai_ip] > 0} {
    puts "重新生成 ai_fft IP..."
    reset_target all $ai_ip
    generate_target all $ai_ip
}

# 重新生成 BD
set bds [get_files -quiet *.bd]
if {[llength $bds] > 0} {
    puts "重新生成 BD..."
    reset_target all $bds
    generate_target all $bds
    catch { make_wrapper -files $bds -top }
}
set_property top design_1_wrapper [current_fileset]

# 综合
puts "\n===== 综合 ====="
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
puts "综合: [get_property PROGRESS [get_runs synth_1]]%"

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: 综合失败"
    close_project
    exit 1
}

# 实现
puts "\n===== 实现 ====="
reset_run impl_1
launch_runs impl_1 -jobs 8
wait_on_run impl_1

# Bitstream
puts "\n===== Bitstream ====="
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
puts "状态: [get_property STATUS [get_runs impl_1]]"

# 结果
set bit [glob -nocomplaint project_psoc_v2.runs/impl_1/*.bit]
if {[llength $bit] > 0} {
    file mkdir output
    file copy [lindex $bit 0] output/fft_system.bit
    puts "Bitstream: output/fft_system.bit"
}

open_run impl_1
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
report_utilization -file output/util_final.rpt
report_timing_summary -file output/timing_final.rpt
puts "\nWNS: ${wns} ns"
puts "========== 2018.3 全流程完成 =========="
close_project
