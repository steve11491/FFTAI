open_project project_psoc/project_psoc.xpr
puts "=== 工程打开成功 ==="
puts "IP数: [llength [get_ips]]"
foreach ip [get_ips] { puts "  $ip" }
puts "顶层: [get_property top [current_fileset]]"

# 另存为可写副本
save_project_as psoc_working ./psoc_working -force
close_project

# 打开副本并跑综合
open_project ./psoc_working/psoc_working.xpr
puts "\n副本打开成功, 启动综合..."

reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
puts "综合: [get_property PROGRESS [get_runs synth_1]]%"
