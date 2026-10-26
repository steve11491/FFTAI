# Phase 5 v2: 直接打开原工程 + 升级 IP + 综合
set proj "project_psoc/project_psoc.xpr"

# 打开工程(自动触发 IP 升级检查)
open_project $proj
puts "工程已打开"

# 检查 IP 状态
set ip_status [report_ip_status -return_string]
puts "IP Status:\n$ip_status"

# 升级所有需要升级的 IP
upgrade_ip [get_ips]

# 刷新 BD
set bd_files [get_files *.bd]
if {[llength $bd_files] > 0} {
    puts "BD: $bd_files"
    # 验证 BD
    catch { validate_bd_design } bd_err
    if {$bd_err != ""} {
        puts "BD 验证警告: $bd_err"
    }
    # 生成输出
    generate_target all $bd_files
    catch { make_wrapper -files $bd_files -top }
    # 设置顶层
    set_property top design_1_wrapper [current_fileset]
}

# 确保约束
if {[llength [get_files -quiet *.xdc]] == 0} {
    add_files -fileset constrs_1 -norecurse constraints/fpga.xdc
}

# 综合
puts "\n===== 开始综合 ====="
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
set s_prog [get_property PROGRESS [get_runs synth_1]]
puts "综合: $s_prog%"

if {$s_prog != "100%"} {
    puts "ERROR: 综合失败"
    exit 1
}

# 资源利用率
open_run synth_1
report_utilization -file output/utilization_synth.rpt
puts "\n===== 资源利用率 ====="
set util [report_utilization -return_string]
foreach line [split $util "\n"] {
    if {[regexp {(Slice LUTs|Slice Registers|Block RAM|DSPs)} $line]} {
        puts "  $line"
    }
}

# 实现
puts "\n===== 开始实现 ====="
reset_run impl_1
launch_runs impl_1 -jobs 8
wait_on_run impl_1

# 时序
open_run impl_1
report_timing_summary -file output/timing_summary.rpt
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -hold]]
puts "\n===== 时序 ====="
puts "WNS: ${wns} ns  WHS: ${whs} ns"

# Bitstream
if {$wns >= 0} {
    puts "\n===== 生成 Bitstream ====="
    launch_runs impl_1 -to_step write_bitstream -jobs 8
    wait_on_run impl_1
    set bit [glob -nocomplain project_psoc.runs/impl_1/*.bit]
    if {[llength $bit] > 0} {
        file copy [lindex $bit 0] output/fft_system.bit
        puts "Bitstream: output/fft_system.bit"
    }
    write_hw_platform -fixed -include_bit -force output/fft_system.xsa
    puts "XSA: output/fft_system.xsa"
} else {
    puts "WARNING: 时序违例, 跳过 bitstream"
    report_timing -sort_by slack -max_paths 10 -file output/timing_violations.rpt
}

puts "\n========== Phase 5 完成 =========="
close_project
