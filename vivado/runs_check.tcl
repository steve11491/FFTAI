open_project project_psoc/project_psoc.xpr
puts "IP locked: [get_property IS_LOCKED [get_ips design_1_ai_fft_0_0]]"
puts "现有 runs: [get_runs]"
set bd [get_files *.bd]
puts "BD: $bd"
set_property top design_1_wrapper [current_fileset]
close_project
