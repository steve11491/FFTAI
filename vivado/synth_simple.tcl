set part "xc7z045ffg676-2"
set src "./ip_repo/ai_fft_1.0"

create_project -force synth_rtl ./synth_rtl -part $part
add_files [glob $src/src/sys/*.sv $src/src/alu/*.sv $src/src/alu/*.v \
    $src/src/fft/*.sv $src/src/mdc/*.sv $src/src/mdc/*.v $src/src/dma/*.sv \
    $src/src/mem/*.sv $src/src/control/*.sv $src/src/pool/*.sv \
    $src/src/quan/*.sv $src/src/acc/*.sv $src/src/utils/*.sv \
    $src/memory/*.v $src/fifo/*.sv]
set_property include_dirs [list [file normalize $src/src]] [current_fileset]
set_property top ai_acce_top [current_fileset]
update_compile_order -fileset sources_1

file mkdir ./constraints
set fp [open ./constraints/clk.xdc w]
puts $fp "create_clock -period 10.000 -name clk \[get_ports clk\]"
close $fp
add_files -fileset constrs_1 ./constraints/clk.xdc

puts "启动综合..."
launch_runs synth_1 -jobs 8
wait_on_run synth_1
puts "综合: [get_property PROGRESS [get_runs synth_1]]%"
open_run synth_1
report_utilization
report_timing_summary
close_project
