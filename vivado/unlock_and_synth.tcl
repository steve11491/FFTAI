# 强制解锁 ai_fft IP 并运行综合
set base [file normalize [pwd]]
open_project "$base/project_psoc/project_psoc.xpr"

# 强制解锁 ai_fft IP
set ai_ip [get_ips design_1_ai_fft_0_0]
puts "IP: $ai_ip, locked=[get_property IS_LOCKED $ai_ip]"

# 方法1: 强制设置 IS_LOCKED false
catch { set_property IS_LOCKED false $ai_ip }
puts "强制解锁后: locked=[get_property IS_LOCKED $ai_ip]"

# 方法2: 重置 target 并重新生成
if {[get_property IS_LOCKED $ai_ip]} {
    puts "尝试方法2: reset + generate..."
    catch { reset_target all $ai_ip -force }
    catch { generate_target all $ai_ip }
    puts "重新生成后: locked=[get_property IS_LOCKED $ai_ip]"
}

# 方法3: 重新生成整个 BD (会重新解析所有 IP)
if {[get_property IS_LOCKED $ai_ip]} {
    puts "尝试方法3: 重写 BD..."
    set bds [get_files *.bd]
    export_ip_user_files -of_objects $bds -no_script -sync -force -quiet
    catch { reset_run synth_1 }
    catch { generate_target all $bds -force }
    puts "BD 重写后: locked=[get_property IS_LOCKED $ai_ip]"
}

# 最终状态
set final_locked [get_property IS_LOCKED $ai_ip]
puts "\n最终锁定状态: $final_locked"

if {$final_locked} {
    puts "⚠ IP 仍锁定, 尝试综合(可能失败)..."
}

# 无论如何尝试综合
puts "\n===== 综合 ====="
set_property top design_1_wrapper [current_fileset]
catch { update_compile_order -fileset sources_1 }

# 重置并运行
catch { reset_run synth_1 }
launch_runs synth_1 -jobs 8
wait_on_run synth_1
set s_prog [get_property PROGRESS [get_runs synth_1]]
puts "综合: $s_prog"

if {$s_prog == "100%"} {
    puts "综合成功! 继续 bitstream..."
    catch { reset_run impl_1 }
    launch_runs impl_1 -to_step write_bitstream -jobs 8
    wait_on_run impl_1
    set i_status [get_property STATUS [get_runs impl_1]]
    puts "实现: $i_status"
    set bit [glob -nocomplaint project_psoc.runs/impl_1/*.bit]
    if {[llength $bit] > 0} {
        file mkdir output
        file copy [lindex $bit 0] output/fft_system.bit
        puts "Bitstream: output/fft_system.bit"
    }
    # 时序
    catch { open_run impl_1
        set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
        puts "WNS: ${wns} ns"
        report_utilization -file output/util_final.rpt
    }
} else {
    puts "综合失败, 查看日志"
    set log [glob -nocomplaint project_psoc.runs/synth_1/runme.log]
    if {[llength $log] > 0} {
        set fp [open [lindex $log] r]
        foreach line [split [read $fp] "\n"] {
            if {[regexp {ERROR} $line]} { puts "  $line" }
        }
        close $fp
    }
}

close_project
