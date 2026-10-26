# Phase 5: 用 Vivado 2018.3 打开原工程 + 全流程 (综合→实现→bit→XSA)
# 注意: ai_fft IP 的 RTL 已更新(修复6个文件的复位极性), 需要刷新 IP

set proj "project_psoc/project_psoc.xpr"

# 1. 打开工程
open_project $proj
puts "工程打开: $proj"

# 2. 刷新 ai_fft IP 的源码
#    (BD 引用的 ai_fft_0 使用 ipshared/9401 中的文件)
#    直接更新 ipshared 目录中的关键文件
set ipshared "project_psoc.srcs/sources_1/bd/design_1/ipshared/9401"
set fixed_files [list \
    "rtl_all/src/alu/split_add.sv" \
    "rtl_all/src/alu/split_addsub.sv" \
    "rtl_all/src/alu/split_add_equal_width.sv" \
    "rtl_all/src/alu/split_mul_true_dual_8bit.sv" \
    "rtl_all/src/pool/split_add_tree.sv" \
    "rtl_all/src/quan/input_scale.sv" \
    "rtl_all/src/alu/split_mul_simple_dual_8bit.sv" \
    "src/ai_fft_define.svh" \
    "rtl_all/src/dma/dma_ffto.sv" \
]
foreach f $fixed_files {
    set src_file "ip_repo/ai_fft_1.0/[string map {rtl_all/ ""} $f]"
    set dst_file "$ipshared/$f"
    if {[file exists $src_file] && [file exists $dst_file]} {
        file copy -force $src_file $dst_file
        puts "  更新: $f"
    }
}

# 3. 重置并重新生成 ai_fft IP 的综合产物
set ai_fft_ip [get_ips -quiet design_1_ai_fft_0_0]
if {[llength $ai_fft_ip] > 0} {
    puts "重置 IP: design_1_ai_fft_0_0"
    reset_target all $ai_fft_ip
    generate_target all $ai_fft_ip
}

# 4. 重置并重新生成 BD 输出
set bd_files [get_files -quiet *.bd]
if {[llength $bd_files] > 0} {
    puts "重新生成 BD"
    reset_target all $bd_files
    generate_target all $bd_files
    # 确保顶层 wrapper 存在
    catch { make_wrapper -files $bd_files -top }
}
set_property top design_1_wrapper [current_fileset]

# 5. 约束
if {[llength [get_files -quiet *.xdc]] == 0} {
    add_files -fileset constrs_1 project_psoc.srcs/constrs_1/new/fpga.xdc
}

# 6. 综合
puts "\n===== 综合 ====="
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
set s_prog [get_property PROGRESS [get_runs synth_1]]
puts "综合: $s_prog% ($ {[get_property STATUS [get_runs synth_1]]} )"

if {$s_prog != "100%"} {
    puts "ERROR: 综合失败"
    exit 1
}

# 7. 实现
puts "\n===== 实现 ====="
reset_run impl_1
launch_runs impl_1 -jobs 8
wait_on_run impl_1
set i_prog [get_property PROGRESS [get_runs impl_1]]
puts "实现: $i_prog%"

# 8. Bitstream
puts "\n===== Bitstream ====="
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# 9. 检查结果
set run_status [get_property STATUS [get_runs impl_1]]
puts "最终状态: $run_status"

set bit_files [glob -nocomplaint "project_psoc.runs/impl_1/*.bit"]
if {[llength $bit_files] > 0} {
    file mkdir output
    file copy [lindex $bit_files 0] output/fft_system.bit
    puts "Bitstream: output/fft_system.bit"
} else {
    puts "WARNING: Bitstream 未生成"
}

# 10. 时序
open_run impl_1
report_timing_summary -file output/timing_2018.rpt
report_utilization -file output/util_2018.rpt

set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -hold]]
puts "\n===== 结果 ====="
puts "WNS: ${wns} ns"
puts "WHS: ${whs} ns"

puts "\n========== Vivado 2018.3 全流程完成 =========="
close_project
