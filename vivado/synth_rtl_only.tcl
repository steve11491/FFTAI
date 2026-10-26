# Phase 5-v3: 仅综合加速器 RTL (不含PS7/BD), 验证综合+时序+资源
# 加速器顶层: ai_acce_top (有独立 clk/rstn, 不依赖 PS7)

set part "xc7z045ffg676-2"
set src_dir "./ip_repo/ai_fft_1.0"

# 创建工程
create_project -force synth_rtl ./synth_rtl -part $part
puts "工程创建: $part"

# 添加所有源文件
set sv_files [glob -nocomplain \
    $src_dir/src/sys/*.sv \
    $src_dir/src/alu/*.sv \
    $src_dir/src/alu/*.v \
    $src_dir/src/fft/*.sv \
    $src_dir/src/mdc/*.sv \
    $src_dir/src/mdc/*.v \
    $src_dir/src/dma/*.sv \
    $src_dir/src/mem/*.sv \
    $src_dir/src/control/*.sv \
    $src_dir/src/pool/*.sv \
    $src_dir/src/quan/*.sv \
    $src_dir/src/acc/*.sv \
    $src_dir/memory/*.v \
    $src_dir/fifo/*.sv \
]
if {[llength $sv_files] == 0} {
    puts "ERROR: 未找到源文件!"
    exit 1
}
add_files $sv_files
puts "添加 [llength $sv_files] 个源文件"

# 添加头文件搜索路径
set_property include_dirs [list $src_dir/src] [current_fileset]

# 设置顶层
set_property top ai_acce_top [current_fileset]
puts "顶层: ai_acce_top"

# 基本时序约束(100MHz)
set xdc "create_clock -period 10.000 -name clk [get_ports clk]"
add_files -fileset constrs_1 [list [file normalize ./constraints/rtl_only.xdc]]

# 写约束文件
set fp [open ./constraints/rtl_only.xdc w]
puts $fp "create_clock -period 10.000 -name clk \[get_ports clk\]"
puts $fp "set_input_delay -clock clk 2.0 \[all_inputs\]"
puts $fp "set_output_delay -clock clk 2.0 \[all_outputs\]"
close $fp

# 综合
puts "\n===== 综合 ====="
launch_runs synth_1 -jobs 8
wait_on_run synth_1
set s_prog [get_property PROGRESS [get_runs synth_1]]
puts "综合: $s_prog%"

if {$s_prog != "100%"} {
    puts "ERROR: 综合失败!"
    # 输出错误
    set log_file [glob synth_rtl.runs/synth_1/runme.log]
    set fp [open $log_file r]
    set content [read $fp]
    close $fp
    foreach line [split $content "\n"] {
        if {[regexp {ERROR} $line]} { puts "  $line" }
    }
    exit 1
}

# 资源利用率
puts "\n===== 资源利用率 ====="
open_run synth_1
report_utilization -file output/utilization_rtl.rpt
set util [report_utilization -return_string]
foreach line [split $util "\n"] {
    if {[regexp {(Slice LUTs|Slice Registers|Block RAM Tile|DSPs|URAM)} $line]} {
        puts "  $line"
    }
}

# 实现
puts "\n===== 实现 ====="
launch_runs impl_1 -jobs 8
wait_on_run impl_1

# 时序
puts "\n===== 时序 ====="
open_run impl_1
report_timing_summary -file output/timing_rtl.rpt
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -hold]]
puts "WNS (Setup): ${wns} ns"
puts "WHS (Hold): ${whs} ns"
if {$wns < 0} {
    puts "WARNING: Setup violation"
    report_timing -sort_by slack -max_paths 5 -file output/timing_viol.rpt
}

puts "\n========== RTL-only 综合完成 =========="
close_project
