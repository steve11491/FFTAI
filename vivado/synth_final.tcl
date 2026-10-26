# 打开副本工程 → 创建 run → 综合到 bitstream
open_project psoc_working/psoc_working.xpr
puts "=== 工程打开 ==="
set_property top design_1_wrapper [current_fileset]

# 检查并创建 run
if {[llength [get_runs -quiet synth_1]] == 0} {
    create_run -name synth_1 -flow {Vivado Synthesis 2018}
    puts "创建 synth_1 run"
}
if {[llength [get_runs -quiet impl_1]] == 0} {
    create_run -name impl_1 -flow {Vivado Implementation 2018} -parent_run synth_1
    puts "创建 impl_1 run"
}

# 确保约束
if {[llength [get_files -quiet -of [get_filesets constrs_1]]] == 0} {
    add_files -fileset constrs_1 project_psoc/project_psoc.srcs/constrs_1/new/fpga.xdc
}

# 综合
puts "\n===== 综合 ====="
launch_runs synth_1 -jobs 8
wait_on_run synth_1
set s_prog [get_property PROGRESS [get_runs synth_1]]
puts "综合: $s_prog"

if {$s_prog != "100%"} {
    puts "ERROR: 综合失败"
    # 输出错误信息
    set run_log [glob -nocomplaint psoc_working.runs/synth_1/runme.log]
    if {[llength $run_log] > 0} {
        set fp [open [lindex $run_log] r]
        foreach line [split [read $fp] "\n"] {
            if {[regexp {ERROR} $line]} { puts "  $line" }
        }
        close $fp
    }
    close_project
    exit 1
}
puts "综合成功!"

# 实现
puts "\n===== 实现 ====="
launch_runs impl_1 -jobs 8
wait_on_run impl_1
set i_prog [get_property PROGRESS [get_runs impl_1]]
puts "实现: $i_prog"

# Bitstream
if {$i_prog == "100%"} {
    puts "\n===== Bitstream ====="
    launch_runs impl_1 -to_step write_bitstream -jobs 8
    wait_on_run impl_1
}

# 结果
set bit [glob -nocomplaint psoc_working.runs/impl_1/*.bit]
if {[llength $bit] > 0} {
    file mkdir output
    file copy [lindex $bit 0] output/fft_system.bit
    puts "Bitstream: output/fft_system.bit"
}

catch { open_run impl_1
    set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
    puts "WNS: ${wns} ns"
    report_utilization -file output/util_2018.rpt
}

puts "\n========== Vivado 2018.3 全流程完成 =========="
close_project
