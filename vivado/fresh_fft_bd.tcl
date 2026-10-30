# 完全重新建 BD: PS7 + ai_fft, 不含 resize_quantize
set base [file normalize [pwd]]
set part "xc7z045ffg676-2"

# 1. 创建全新工程
create_project -force fft_proj ./fft_proj -part $part
puts "新工程: fft_proj"

# 2. 设置 IP 仓库(用之前 ipx::package_project 打包的)
set_property ip_repo_paths [list "$base/ip_repo_new"] [current_project]
update_ip_catalog

# 3. 创建 BD
create_bd_design "fft_sys"
puts "BD: fft_sys"

# 3a. 添加 PS7
set ps7 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7_0]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, AXI" Pcw_PRESET_BANK_0_INTRF_USED {1 0 0} Pcw_PRESET_BANK_1_INTRF_USED {0 0 0}} $ps7
puts "PS7 添加成功"

# 配置 PS7: DDR + HP 端口
set_property -dict [list \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT8JTF12864HZ-1G} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_USE_S_AXI_HP1 {1} \
    CONFIG.PCW_USE_S_AXI_HP2 {1} \
    CONFIG.PCW_USE_S_AXI_HP3 {1} \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_IRQ_F2P_INTR {1} \
    CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_BAUD_RATE {115200} \
] $ps7

# 3b. 添加 ai_fft IP
set ai_fft [create_bd_cell -type ip -vlnv xilinx.com:user:ai_fft:1.0 ai_fft_0]
puts "ai_fft 添加成功: locked=[get_property IS_LOCKED [get_ips -quiet *ai_fft*]]"

# 3c. 添加复位
set rst [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_0]

# 3d. 连接时钟
connect_bd_net [get_bd_pins $ps7/FCLK_CLK0] [get_bd_pins $ps7/M_AXI_GP0_ACLK]
connect_bd_net [get_bd_net [get_bd_pins $ps7/FCLK_CLK0]] \
    [get_bd_pins $ps7/S_AXI_HP0_ACLK] \
    [get_bd_pins $ps7/S_AXI_HP1_ACLK] \
    [get_bd_pins $ps7/S_AXI_HP2_ACLK] \
    [get_bd_pins $ps7/S_AXI_HP3_ACLK] \
    [get_bd_pins $ai_fft/clk] \
    [get_bd_pins $ai_fft/m00_axi_aclk] \
    [get_bd_pins $ai_fft/m01_axi_aclk] \
    [get_bd_pins $ai_fft/m02_axi_aclk] \
    [get_bd_pins $ai_fft/m03_axi_aclk] \
    [get_bd_pins $ai_fft/s00_axi_aclk] \
    [get_bd_pins $rst/slowest_sync_clk]
connect_bd_net [get_bd_pins $ps7/FCLK_RESET0_N] [get_bd_pins $rst/ext_reset_in]

# 3e. 连接复位
connect_bd_net [get_bd_pins $rst/peripheral_aresetn] \
    [get_bd_pins $ai_fft/m00_axi_aresetn] \
    [get_bd_pins $ai_fft/m01_axi_aresetn] \
    [get_bd_pins $ai_fft/m02_axi_aresetn] \
    [get_bd_pins $ai_fft/m03_axi_aresetn] \
    [get_bd_pins $ai_fft/rstn] \
    [get_bd_pins $ai_fft/s00_axi_aresetn]

# 3f. AXI GP0 → ai_fft S_AXI (控制)
set ic_gp [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ic_gp0]
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] $ic_gp
connect_bd_intf_net [get_bd_intf_pins $ps7/M_AXI_GP0] [get_bd_intf_pins $ic_gp0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins $ic_gp0/M00_AXI] [get_bd_intf_pins $ai_fft/S00_AXI]
connect_bd_net [get_bd_net [get_bd_pins $ps7/FCLK_CLK0]] [get_bd_pins $ic_gp0/ACLK] [get_bd_pins $ic_gp0/S00_ACLK] [get_bd_pins $ic_gp0/M00_ACLK]
connect_bd_net [get_bd_net [get_bd_pins $rst/peripheral_aresetn]] [get_bd_pins $ic_gp0/ARESETN] [get_bd_pins $ic_gp0/S00_ARESETN] [get_bd_pins $ic_gp0/M00_ARESETN]

# 3g. ai_fft M00→HP0, M01→HP1, M02→HP2, M03→HP3 (数据通道)
foreach {master slave} [list m00 S_AXI_HP0 m01 S_AXI_HP1 m02 S_AXI_HP2 m03 S_AXI_HP3] {
    connect_bd_intf_net [get_bd_intf_pins $ai_fft/${master}_AXI] [get_bd_intf_pins $ps7/$slave]
}

# 3h. 中断
connect_bd_net [get_bd_pins $ai_fft/fft_done_intr] [get_bd_pins $ps7/IRQ_F2P]

# 3i. 地址分配
assign_bd_address
puts "BD 连接完成"

# 4. 保存和生成
validate_bd_design
save_bd_design
generate_target all [get_files fft_sys.bd]
make_wrapper -files [get_files fft_sys.bd] -top
add_files -norecurse fft_proj.srcs/sources_1/bd/fft_sys/hdl/fft_sys_wrapper.v
set_property top fft_sys_wrapper [current_fileset]

# 5. 约束: PS7 FCLK_CLK0 自动派生 100MHz 时钟约束, BD 流程无需外部 xdc
#    (旧 constraints/fpga.xdc 为 YOLO 工程 design_1 层级路径, 已随旧约束目录删除)

# 6. 综合 → bitstream
puts "\n===== 综合 ====="
launch_runs synth_1 -jobs 8
wait_on_run synth_1
puts "综合: [get_property PROGRESS [get_runs synth_1]]%"

if {[get_property PROGRESS [get_runs synth_1]] == "100%"} {
    puts "综合成功! 实现 + bitstream..."
    launch_runs impl_1 -to_step write_bitstream -jobs 8
    wait_on_run impl_1
    puts "状态: [get_property STATUS [get_runs impl_1]]"
    set bit [glob -nocomplain fft_proj.runs/impl_1/*.bit]
    if {[llength $bit] > 0} {
        file mkdir output
        file copy [lindex $bit 0] output/fft_system.bit
        puts "Bitstream: output/fft_system.bit"
    }
    catch { open_run impl_1
        set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
        puts "WNS: ${wns} ns"
        report_utilization -file output/util_fft.rpt
    }
} else {
    puts "综合失败!"
}

close_project
puts "========== 完成 =========="
