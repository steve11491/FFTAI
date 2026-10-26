# 从零创建 2018.3 工程 + BD TCL 重建
set part "xc7z045ffg676-2"

# 1. 创建全新工程
create_project -force psoc_2018 ./psoc_2018 -part $part
puts "新工程: psoc_2018 ($part)"

# 2. 设置 IP 仓库(指向 ipshared 的原始 IP 打包)
#    ai_fft IP 在 ipshared/9401/ 有完整 2018.3 结构
set ip_repo "./ip_repo"
file mkdir $ip_repo
# 把 ipshared/9401 的上级作为 IP 仓库(利用缓存)
# 直接用 BD TCL 中的 VLNV 查找已注册的 IP
# 不需要额外设置 — BD TCL 自带 IP 创建

# 3. 先添加 ai_fft IP(手动创建, 不依赖 IP 仓库)
#    把 ipshared/9401 的结构复制到正确位置
set ipshared_src "project_psoc/project_psoc.srcs/sources_1/bd/design_1/ipshared"
if {[file exists $ipshared_src]} {
    # 方案B: 直接 source BD TCL(它内含所有 IP 创建命令)
    puts "方案B: 直接 source BD TCL..."
}

# 4. Source BD TCL(在 2018.3 下版本检查通过)
source bd/design_1.tcl
puts "BD 创建成功"

# 5. 保存并生成
validate_bd_design
save_bd_design
generate_target all [get_files design_1.bd]
make_wrapper -files [get_files design_1.bd] -top
add_files -norecurse psoc_2018.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v
set_property top design_1_wrapper [current_fileset]

# 6. 约束
add_files -fileset constrs_1 constraints/fpga.xdc

# 7. 综合
puts "\n===== 综合 ====="
launch_runs synth_1 -jobs 8
wait_on_run synth_1
puts "综合: [get_property PROGRESS [get_runs synth_1]]%"

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "综合失败!"
    close_project
    exit 1
}
puts "综合成功!"

# 8. 实现 + Bitstream
puts "\n===== 实现 ====="
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
puts "状态: [get_property STATUS [get_runs impl_1]]"

set bit [glob -nocomplaint psoc_2018.runs/impl_1/*.bit]
if {[llength $bit] > 0} {
    file mkdir output
    file copy [lindex $bit 0] output/fft_system.bit
    puts "Bitstream: output/fft_system.bit"
}

open_run impl_1
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
puts "\nWNS: ${wns} ns"
puts "========== 2018.3 全新工程流程完成 =========="
close_project
