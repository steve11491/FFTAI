# ==============================================================================
# 在 Vivado 2022.2 TCL Console 中执行:
#   cd D:/project_PLF/FFTAI/vivado
#   source package_and_fix.tcl
# ==============================================================================
set base_dir [file normalize [pwd]]
puts "工作目录: $base_dir"

# ---------- 1. 创建临时工程来打包 IP ----------
puts "\n步骤1: 打包 ai_fft IP..."
create_project -force pkg_tmp ./pkg_tmp -part xc7z045ffg676-2

# 添加源文件(用 concat 合并 glob 结果)
set rtl_root "$base_dir/ip_repo/ai_fft_1.0"
set src_files {}
foreach pattern [list \
    "$rtl_root/src/sys/*.sv" \
    "$rtl_root/src/alu/*.sv" \
    "$rtl_root/src/alu/*.v" \
    "$rtl_root/src/fft/*.sv" \
    "$rtl_root/src/mdc/*.sv" \
    "$rtl_root/src/mdc/*.v" \
    "$rtl_root/src/dma/*.sv" \
    "$rtl_root/src/mem/*.sv" \
    "$rtl_root/src/control/*.sv" \
    "$rtl_root/src/pool/*.sv" \
    "$rtl_root/src/quan/*.sv" \
    "$rtl_root/src/acc/*.sv" \
    "$rtl_root/src/utils/*.sv" \
    "$rtl_root/memory/*.v" \
    "$rtl_root/fifo/*.sv" \
] {
    set matched [glob -nocomplain $pattern]
    if {[llength $matched] > 0} {
        set src_files [concat $src_files $matched]
    }
}
puts "源文件数: [llength $src_files]"

if {[llength $src_files] == 0} {
    puts "ERROR: 未找到源文件! 检查路径: $rtl_root"
    close_project
    exit 1
}

add_files $src_files
set_property include_dirs [list "$rtl_root/src"] [current_fileset]
set_property top ai_acce_top [current_fileset]

# 打包为 IP
set ip_dir "$base_dir/ip_repo_new/ai_fft_1.0"
file mkdir $ip_dir
ipx::package_project -root_dir $ip_dir \
    -name ai_fft -library user -vendor xilinx.com -version 1.0 -force
puts "IP 打包完成: $ip_dir"

# 关闭临时工程
close_project
file delete -force pkg_tmp

# ---------- 2. 打开原工程并设置 IP 仓库 ----------
puts "\n步骤2: 打开工程..."
open_project "$base_dir/project_psoc/project_psoc.xpr"

# 设置 IP 仓库指向新打包的 IP
set_property ip_repo_paths [list "$base_dir/ip_repo_new"] [current_project]
update_ip_catalog
puts "IP 仓库: $base_dir/ip_repo_new"

# ---------- 3. 修复锁定的 IP ----------
puts "\n步骤3: 升级 IP..."
set locked [get_ips -quiet -filter {IS_LOCKED}]
if {[llength $locked] > 0} {
    puts "锁定 IP: $locked"
    # 尝试升级
    catch { upgrade_ip $locked } err
    if {$err != ""} { puts "升级结果: $err" }
} else {
    puts "没有锁定 IP"
}

# 如果还有锁定的 IP(升级失败), 提示手动处理
set locked2 [get_ips -quiet -filter {IS_LOCKED}]
if {[llength $locked2] > 0} {
    puts "\n⚠ 以下 IP 仍锁定(需在 GUI 中手动处理):"
    foreach ip $locked2 { puts "  $ip" }
    puts "建议: Block Design 中右键删除 resize_quantize_0"
    puts "      对于 ai_fft, 尝试: Report IP Status → Upgrade Selected"
}

# ---------- 4. 生成 BD ----------
puts "\n步骤4: 生成 BD..."
set bds [get_files -quiet *.bd]
if {[llength $bds] > 0} {
    catch { reset_target all $bds }
    catch { generate_target all $bds }
    catch { make_wrapper -files $bds -top }
    puts "BD 已重新生成"
}

# ---------- 5. 检查就绪 ----------
puts "\n========== 脚本完成 =========="
set_property top design_1_wrapper [current_fileset]
catch { update_compile_order -fileset sources_1 }

# 最终 IP 状态
puts "IP 状态:"
foreach ip [get_ips] {
    set name [get_property NAME $ip]
    set locked_status [get_property IS_LOCKED $ip]
    puts "  $name : locked=$locked_status"
}
puts "=============================="
puts "下一步: Flow Navigator → Run Synthesis"
