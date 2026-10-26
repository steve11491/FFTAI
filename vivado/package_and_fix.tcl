# ==============================================================================
# 在 Vivado 2022.2 TCL Console 中 source 此文件
# 功能: 将 ai_acce_top RTL 重新打包为 2022.2 IP → 更新工程 → 综合
# ==============================================================================

# ---------- 1. 创建临时工程来打包 IP ----------
puts "步骤1: 打包 ai_fft IP..."
create_project -force pkg_tmp ./pkg_tmp -part xc7z045ffg676-2

# 添加源文件
add_files [list \
    [glob ip_repo/ai_fft_1.0/src/sys/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/alu/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/alu/*.v] \
    [glob ip_repo/ai_fft_1.0/src/fft/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/mdc/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/mdc/*.v] \
    [glob ip_repo/ai_fft_1.0/src/dma/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/mem/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/control/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/pool/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/quan/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/acc/*.sv] \
    [glob ip_repo/ai_fft_1.0/src/utils/*.sv] \
    [glob ip_repo/ai_fft_1.0/memory/*.v] \
    [glob ip_repo/ai_fft_1.0/fifo/*.sv] \
]
set_property include_dirs [list [file normalize ip_repo/ai_fft_1.0/src]] [current_fileset]
set_property top ai_acce_top [current_fileset]

# 打包为 IP
file mkdir ip_repo_new
ipx::package_project -root_dir [file normalize ip_repo_new/ai_fft_1.0] \
    -name ai_fft -library user -vendor xilinx.com -version 1.0 -force

puts "IP 打包完成: ip_repo_new/ai_fft_1.0"

# 关闭临时工程
close_project
file delete -force pkg_tmp

# ---------- 2. 打开原工程并设置 IP 仓库 ----------
puts "\n步骤2: 打开工程并设置 IP 仓库..."
open_project project_psoc/project_psoc.xpr

# 设置 IP 仓库指向新打包的 IP
set_property ip_repo_paths [list [file normalize ip_repo_new]] [current_project]
update_ip_catalog
puts "IP 仓库已设置, IP 目录已更新"

# ---------- 3. 修复 IP ----------
puts "\n步骤3: 升级 IP..."
# 查找需要升级的 IP
set locked_ips [get_ips -quiet -filter {IS_LOCKED}]
if {[llength $locked_ips] > 0} {
    puts "锁定的 IP: $locked_ips"
    # 升级
    upgrade_ip $locked_ips
    puts "IP 已升级"
} else {
    puts "没有锁定的 IP"
}

# ---------- 4. 删除 resize_quantize (如果还在) ----------
set rq_ip [get_ips -quiet *resize*]
if {[llength $rq_ip] > 0} {
    puts "发现 resize_quantize IP: $rq_ip"
    puts "请在 GUI 中手动删除此 IP (右键 → Delete)"
}

# ---------- 5. 重新生成 BD ----------
puts "\n步骤4: 生成 BD..."
set bd_files [get_files -quiet *.bd]
if {[llength $bd_files] > 0} {
    # 重置并重新生成
    reset_target all $bd_files
    generate_target all $bd_files
    catch { make_wrapper -files $bd_files -top }
    puts "BD 已重新生成"
}

# ---------- 6. 检查综合可行性 ----------
puts "\n步骤5: 检查综合..."
set_property top design_1_wrapper [current_fileset]
update_compile_order -fileset sources_1

puts "\n========== 准备完成! =========="
puts "请在 GUI 中检查:"
puts "  1. Sources 窗口: IP 应无锁定标记"
puts "  2. design_1.bd: 双击打开确认 BD 完整"
puts "  3. 如有 resize_quantize, 右键删除"
puts "  4. Flow Navigator → Run Synthesis"
puts "================================"
