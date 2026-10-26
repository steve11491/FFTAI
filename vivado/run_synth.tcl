# ==============================================================================
# Phase 5: Vivado 综合完整 TCL 脚本
# 用法: 在 Vivado TCL Console 中 source 此文件, 或:
#        vivado -mode batch -source run_synth.tcl
# 前提: package_ip.py 已执行(IP/约束/BD就绪)
# ==============================================================================

# ---------- 配置 ----------
set script_dir  [file dirname [file normalize [info script]]]
set proj_name   "project_fft"
set part        "xc7z045ffg676-2"
set ip_repo     "$script_dir/ip_repo"
set xdc_file    "$script_dir/constraints/fpga.xdc"
set bd_tcl      "$script_dir/bd/design_1.tcl"
set out_dir     "$script_dir/output"

file mkdir $out_dir

# ---------- 1. 创建/打开工程 ----------
if {[file exists "$script_dir/${proj_name}.xpr"]} {
    open_project "$script_dir/${proj_name}.xpr"
    puts "打开已有工程: ${proj_name}"
} else {
    create_project $proj_name "$script_dir/${proj_name}" -part $part -force
    puts "创建新工程: ${proj_name} ($part)"
}

# ---------- 2. 设置 IP 仓库 ----------
set_property ip_repo_paths $ip_repo [current_project]
update_ip_catalog
puts "IP仓库: $ip_repo"

# ---------- 3. 创建 Block Design ----------
if {[file exists $bd_tcl]} {
    # 清除旧 BD
    set bd_files [get_files -quiet *.bd]
    if {[llength $bd_files] > 0} {
        remove_files $bd_files
        file delete -force [file join [get_property DIRECTORY [current_project]] [get_property SOURCE_DIR [current_fileset]]]
    }
    # 从 TCL 重建 BD
    source $bd_tcl
    validate_bd_design
    save_bd_design
    # 添加到工程
    add_files -norecurse [get_files design_1.bd]
    generate_target all [get_files design_1.bd]
    make_wrapper -files [get_files design_1.bd] -top
    add_files -norecurse [file join [get_property DIRECTORY [current_project]] ${proj_name}.srcs sources_1 bd design_1 hdl design_1_wrapper.v]
    set_property top design_1_wrapper [current_fileset]
    puts "BD 重建完成, 顶层: design_1_wrapper"
} else {
    puts "ERROR: BD脚本不存在: $bd_tcl"
    close_project
    exit 1
}

# ---------- 4. 添加约束 ----------
if {[file exists $xdc_file]} {
    add_files -fileset constrs_1 -norecurse $xdc_file
    puts "约束已添加: $xdc_file"
} else {
    puts "WARNING: 约束文件不存在, 使用默认"
}

# ---------- 5. 综合设置 ----------
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
    -value {-flatten_hierarchy rebuilt} \
    -objects [get_runs synth_1]

# ---------- 6. 运行综合 ----------
puts "\n===== 开始综合 ====="
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1

set s_status [get_property STATUS [get_runs synth_1]]
set s_prog   [get_property PROGRESS [get_runs synth_1]]
puts "综合状态: $s_status ($s_prog%)"

if {$s_prog != "100%"} {
    puts "ERROR: 综合失败!"
    exit 1
}

# ---------- 7. 资源利用率 ----------
open_run synth_1
report_utilization -file "$out_dir/utilization_synth.rpt"
puts "\n===== 资源利用率(综合后) ====="
set util [report_utilization -return_string]
foreach line [split $util "\n"] {
    if {[regexp {(Slice LUTs|Slice Registers|Block RAM|DSPs)} $line]} {
        puts "  $line"
    }
}

# ---------- 8. 实现 ---------
puts "\n===== 开始实现 ====="
set_property strategy Performance_Explore [get_runs impl_1]
reset_run impl_1
launch_runs impl_1 -jobs 8
wait_on_run impl_1

set i_status [get_property STATUS [get_runs impl_1]]
set i_prog   [get_property PROGRESS [get_runs impl_1]]
puts "实现状态: $i_status ($i_prog%)"

# ---------- 9. 时序检查 ----------
open_run impl_1
report_timing_summary -file "$out_dir/timing_summary.rpt"

set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -hold]]
puts "\n===== 时序结果 ====="
puts "WNS (Setup): ${wns} ns"
puts "WHS (Hold):  ${whs} ns"

if {$wns < 0} {
    puts "WARNING: Setup violation! 查看详情:"
    report_timing -sort_by slack -max_paths 10 -file "$out_dir/timing_violations.rpt"
    puts "  已输出: $out_dir/timing_violations.rpt"
}

# ---------- 10. Bitstream ----------
puts "\n===== 生成 Bitstream ====="
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

set bit_file [glob -nocomplain "$script_dir/${proj_name}.runs/impl_1/*.bit"]
if {[llength $bit_file] > 0} {
    file copy -force [lindex $bit_file 0] "$out_dir/fft_system.bit"
    puts "Bitstream: $out_dir/fft_system.bit"
} else {
    puts "ERROR: Bitstream 生成失败"
}

# ---------- 11. 导出 XSA ----------
write_hw_platform -fixed -include_bit -force "$out_dir/fft_system.xsa"
puts "XSA: $out_dir/fft_system.xsa"

# ---------- 12. 最终报告 ----------
report_utilization -file "$out_dir/utilization_impl.rpt"
report_timing_summary -file "$out_dir/timing_final.rpt"

puts "\n=============================================="
puts "Phase 5 综合流程完成!"
puts "  工程:     $script_dir/${proj_name}/${proj_name}.xpr"
puts "  Bitstream: $out_dir/fft_system.bit"
puts "  XSA:       $out_dir/fft_system.xsa"
puts "  WNS:       ${wns} ns"
puts "=============================================="

close_project
