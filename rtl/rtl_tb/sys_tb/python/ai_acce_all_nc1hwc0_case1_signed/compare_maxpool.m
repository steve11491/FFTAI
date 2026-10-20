close all
mat_data_in_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\mat_data_in_int8.txt');
% mat_weight_in_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\mat_weight_in_int8.txt');
mat_data_out_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\mat_data_out_int8.txt');
acc_out_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\acc_pool_out_int8.txt');
quan_relu_out_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\quan_relu_out_int8.txt');
quan_relu_out_int8_ddr = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\omap_ddr_int8.txt');

golden_mat_data_in_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_maxpool_input_matrix_int8.txt');
% golden_mat_weight_in_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_weight_matrix_int8.txt');

golden_mat_data_out_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_maxpool_output_maxtix_int8.txt');
golden_acc_out_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_maxpool_acc_maxtix_int8.txt');
golden_quan_relu_out_int8 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_quan_relu_maxtix_int8.txt');
golden_quan_relu_out_int8_ddr = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\quan_sat_relu_output_add_int8.txt');

diff_mat_data_in_int8 = mat_data_in_int8-golden_mat_data_in_int8;
% diff_mat_weight_in_int8 = mat_weight_in_int8-golden_mat_weight_in_int8;
diff_mat_data_out_int8 = mat_data_out_int8-golden_mat_data_out_int8;
diff_acc_out_int8 = acc_out_int8-golden_acc_out_int8;
diff_quan_relu_out_int8 = quan_relu_out_int8-golden_quan_relu_out_int8;
diff_quan_relu_out_int8_ddr = quan_relu_out_int8_ddr-golden_quan_relu_out_int8_ddr;


figure
nexttile,plot(diff_mat_data_in_int8),title('diff\_mat\_data\_in\_int8')
% nexttile,plot(diff_mat_weight_in_int8),title('diff\_mat\_weight\_in\_int8')
nexttile,plot(diff_mat_data_out_int8),title('diff\_mat\_data\_out\_int8')
nexttile,plot(diff_acc_out_int8),title('diff\_acc\_out\_int8')
nexttile,plot(diff_quan_relu_out_int8),title('diff\_quan\_relu\_out\_int8')
nexttile,plot(diff_quan_relu_out_int8_ddr),title('diff\_quan\_relu\_out\_int8\_ddr')
exportgraphics(gcf,'int8 maxpool对比.png','Resolution',300)

%%
mat_data_in_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\mat_data_in_int16.txt');
% mat_weight_in_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\mat_weight_in_int16.txt');
mat_data_out_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\mat_data_out_int16.txt');
acc_out_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\acc_pool_out_int16.txt');
quan_relu_out_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\quan_relu_out_int16.txt');
quan_relu_out_int16_ddr = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\pe_data\\omap_ddr_int16.txt');
golden_mat_data_in_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_maxpool_input_matrix_int16.txt');
% golden_mat_weight_in_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_weight_matrix_int16.txt');
golden_mat_data_out_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_maxpool_output_maxtix_int16.txt');
golden_acc_out_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_maxpool_acc_maxtix_int16.txt');
golden_quan_relu_out_int16 = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\tmp_quan_relu_maxtix_int16.txt');
golden_quan_relu_out_int16_ddr = load('D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_all_nc1hwc0_case1_signed\\quan_sat_relu_output_add_int16.txt');

diff_mat_data_in_int16 = mat_data_in_int16-golden_mat_data_in_int16;
% diff_mat_weight_in_int16 = mat_weight_in_int16-golden_mat_weight_in_int16;
diff_mat_data_out_int16 = mat_data_out_int16-golden_mat_data_out_int16;
diff_acc_out_int16 = acc_out_int16-golden_acc_out_int16;
diff_quan_relu_out_int16 = quan_relu_out_int16-golden_quan_relu_out_int16;

diff_quan_relu_out_int16_ddr = quan_relu_out_int16_ddr-golden_quan_relu_out_int16_ddr;

figure
nexttile,plot(diff_mat_data_in_int16),title('diff\_mat\_data\_in\_int16')
% nexttile,plot(diff_mat_weight_in_int16),title('diff\_mat\_weight\_in\_int16')
nexttile,plot(diff_mat_data_out_int16),title('diff\_mat\_data\_out\_int16')
nexttile,plot(diff_acc_out_int16),title('diff\_acc\_out\_int16')
nexttile,plot(diff_quan_relu_out_int16),title('diff\_quan\_relu\_out\_int16')
nexttile,plot(diff_quan_relu_out_int16_ddr),title('diff\_quan\_relu\_out\_int16\_ddr')
exportgraphics(gcf,'int16 maxpool对比.png','Resolution',300)