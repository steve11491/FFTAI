clear;clc;close all;

Ns=12; %FFT级数->9\10\11\12
N=4096; %FFT point
len=100*N;%FFT len
tt=1:1:len;
fft_in = zeros(1,len);
fft_in(1,:)=rand(1,len)-0.5;
% fft_in(1,:) = 1 + 0*tt;
fft_in(1,:)=fft_in/max(abs(fft_in(1,:))); %归一化  


%MATLAB计算FFT
%512
matlab_result_512_real = zeros(1,len);
matlab_result_512_imag = zeros(1,len);
for i=1:len/512
    matlab_result_512 = fft(fft_in(1,(i*512-511):i*512));
    matlab_result_512_real(1,(i*512-511):i*512) = real(matlab_result_512);
    matlab_result_512_imag(1,(i*512-511):i*512) = imag(matlab_result_512);
end


%1024
matlab_result_1024_real = zeros(1,len);
matlab_result_1024_imag = zeros(1,len);
for i=1:len/1024
    matlab_result_1024 = fft(fft_in(1,(i*1024-1023):i*1024));
    matlab_result_1024_real(1,(i*1024-1023):i*1024) = real(matlab_result_1024);
    matlab_result_1024_imag(1,(i*1024-1023):i*1024) = imag(matlab_result_1024);
end


%2048
matlab_result_2048_real = zeros(1,len);
matlab_result_2048_imag = zeros(1,len);
for i=1:len/2048
    matlab_result_2048 = fft(fft_in(1,(i*2048-2047):i*2048));
    matlab_result_2048_real(1,(i*2048-2047):i*2048) = real(matlab_result_2048);
    matlab_result_2048_imag(1,(i*2048-2047):i*2048) = imag(matlab_result_2048);
end

%4096
matlab_result_4096_real = zeros(1,len);
matlab_result_4096_imag = zeros(1,len);
for i=1:len/4096
    matlab_result_4096 = fft(fft_in(1,(i*4096-4095):i*4096));
    matlab_result_4096_real(1,(i*4096-4095):i*4096) = real(matlab_result_4096);
    matlab_result_4096_imag(1,(i*4096-4095):i*4096) = imag(matlab_result_4096);
end


%文件
fft_in_fpga = zeros(1,len*2);
for i=1:len
    fft_in_fpga(1,2*i) = 0;
    if fft_in(1,i)>2^(-15)
        fft_in_fpga(1,2*i-1) = floor(fft_in(1,i)*2^15-1);
    elseif fft_in(1,i)<-2^(-15)
        fft_in_fpga(1,2*i-1) = ceil(fft_in(1,i)*2^15+1);
    else
        fft_in_fpga(1,2*i-1) = round(fft_in(1,i)*2^15);
    end
end
fid=fopen('./txt/fft_in_rand.txt','w');
fprintf(fid,'%d ',fft_in_fpga);
% fwrite(fid,fft_in_fpga,'int16');
fclose(fid);

fft_512_mat = zeros(1,len*2);
for i=1:len
    if matlab_result_512_imag(1,i)>2^(-6)
        fft_512_mat(1,2*i) = floor(matlab_result_512_imag(1,i)*2^6-1);
    elseif matlab_result_512_imag(1,i)<-2^(-6)
        fft_512_mat(1,2*i) = ceil(matlab_result_512_imag(1,i)*2^6+1);
    else
        fft_512_mat(1,2*i) = round(matlab_result_512_imag(1,i)*2^6);
    end
    if matlab_result_512_real(1,i)>2^(-6)
        fft_512_mat(1,2*i-1) = floor(matlab_result_512_real(1,i)*2^6-1);
    elseif matlab_result_512_real(1,i)<-2^(-6)
        fft_512_mat(1,2*i-1) = ceil(matlab_result_512_real(1,i)*2^6+1);
    else
        fft_512_mat(1,2*i-1) = round(matlab_result_512_real(1,i)*2^6);
    end
end
fid=fopen('./txt/fft_out_512_matlab.txt','w');
fprintf(fid,'%d ',fft_512_mat);
fclose(fid);

fft_1024_mat = zeros(1,len*2);
for i=1:len
    if matlab_result_1024_imag(1,i)>2^(-5)
        fft_1024_mat(1,2*i) = floor(matlab_result_1024_imag(1,i)*2^5-1);
    elseif matlab_result_1024_imag(1,i)<-2^(-5)
        fft_1024_mat(1,2*i) = ceil(matlab_result_1024_imag(1,i)*2^5+1);
    else
        fft_1024_mat(1,2*i) = round(matlab_result_1024_imag(1,i)*2^5);
    end
    if matlab_result_1024_real(1,i)>2^(-5)
        fft_1024_mat(1,2*i-1) = floor(matlab_result_1024_real(1,i)*2^5-1);
    elseif matlab_result_1024_real(1,i)<-2^(-5)
        fft_1024_mat(1,2*i-1) = ceil(matlab_result_1024_real(1,i)*2^5+1);
    else
        fft_1024_mat(1,2*i-1) = round(matlab_result_1024_real(1,i)*2^5);
    end
end
fid=fopen('./txt/fft_out_1024_matlab.txt','w');
fprintf(fid,'%d ',fft_1024_mat);
fclose(fid);

fft_2048_mat = zeros(1,len*2);
for i=1:len
    if matlab_result_2048_imag(1,i)>2^(-4)
        fft_2048_mat(1,2*i) = floor(matlab_result_2048_imag(1,i)*2^4-1);
    elseif matlab_result_2048_imag(1,i)<-2^(-4)
        fft_2048_mat(1,2*i) = ceil(matlab_result_2048_imag(1,i)*2^4+1);
    else
        fft_2048_mat(1,2*i) = round(matlab_result_2048_imag(1,i)*2^4);
    end
    if matlab_result_2048_real(1,i)>2^(-4)
        fft_2048_mat(1,2*i-1) = floor(matlab_result_2048_real(1,i)*2^4-1);
    elseif matlab_result_2048_real(1,i)<-2^(-4)
        fft_2048_mat(1,2*i-1) = ceil(matlab_result_2048_real(1,i)*2^4+1);
    else
        fft_2048_mat(1,2*i-1) = round(matlab_result_2048_real(1,i)*2^4);
    end
end
fid=fopen('./txt/fft_out_2048_matlab.txt','w');
fprintf(fid,'%d ',fft_2048_mat);
fclose(fid);

fft_4096_mat = zeros(1,len*2);
for i=1:len
    if matlab_result_4096_imag(1,i)>2^(-3)
        fft_4096_mat(1,2*i) = floor(matlab_result_4096_imag(1,i)*2^3-1);
    elseif matlab_result_4096_imag(1,i)<-2^(-3)
        fft_4096_mat(1,2*i) = ceil(matlab_result_4096_imag(1,i)*2^3+1);
    else
        fft_4096_mat(1,2*i) = round(matlab_result_4096_imag(1,i)*2^3);
    end
    if matlab_result_4096_real(1,i)>2^(-3)
        fft_4096_mat(1,2*i-1) = floor(matlab_result_4096_real(1,i)*2^3-1);
    elseif matlab_result_4096_real(1,i)<-2^(-3)
        fft_4096_mat(1,2*i-1) = ceil(matlab_result_4096_real(1,i)*2^3+1);
    else
        fft_4096_mat(1,2*i-1) = round(matlab_result_4096_real(1,i)*2^3);
    end
end
fid=fopen('./txt/fft_out_4096_matlab.txt','w');
fprintf(fid,'%d ',fft_4096_mat);
fclose(fid);

%% 
clear;clc;close all;
N=4096; %FFT point
len=1*N;%FFT len
%加载FPGA计算输入
% fid=fopen('./bin/fft_in_rand.txt','rb');
% fpga_in = fread(fid,'int16');
fpga_in = load('./txt/fft_in_rand.txt');
fpga_in_real = zeros(1,len);
for i=1:len
    fpga_in_real(1,i) = fpga_in(i*2-1)/2^(15);
end

%加载FPGA计算输出
%512点FFT
% fid=fopen('./bin/fft_out_512.bin','rb');
% fpga_result_512 = fread(fid,'int16');
fpga_result_512 = load('./txt/fft_out_512.txt');
fpga_result_real_512 = zeros(1,len);
fpga_result_imag_512 = zeros(1,len);
for i=1:len
    fpga_result_imag_512(1,i) = fpga_result_512(i*2)/2^(15-9);
    fpga_result_real_512(1,i) = fpga_result_512(i*2-1)/2^(15-9);
end

%1024点FFT
% fid=fopen('./bin/fft_out_1024.bin','rb');
% fpga_result_1024 = fread(fid,'int16');
fpga_result_1024 = load('./txt/fft_out_1024.txt');
fpga_result_real_1024 = zeros(1,len);
fpga_result_imag_1024 = zeros(1,len);
for i=1:len
    fpga_result_imag_1024(1,i) = fpga_result_1024(i*2)/2^(15-10);
    fpga_result_real_1024(1,i) = fpga_result_1024(i*2-1)/2^(15-10);
end

%2048点FFT
% fid=fopen('./bin/fft_out_2048.bin','rb');
% fpga_result_2048 = fread(fid,'int16');
fpga_result_2048 = load('./txt/fft_out_2048.txt');
fpga_result_real_2048 = zeros(1,len);
fpga_result_imag_2048 = zeros(1,len);
for i=1:len
    fpga_result_imag_2048(1,i) = fpga_result_2048(i*2)/2^(15-11);
    fpga_result_real_2048(1,i) = fpga_result_2048(i*2-1)/2^(15-11);
end

%4096点FFT
% fid=fopen('./bin/fft_out_4096.bin','rb');
% fpga_result_4096 = fread(fid,'int16');
fpga_result_4096 = load('./txt/fft_out_4096.txt');
fpga_result_real_4096 = zeros(1,len);
fpga_result_imag_4096 = zeros(1,len);
for i=1:len
    fpga_result_imag_4096(1,i) = fpga_result_4096(i*2)/2^(15-12);
    fpga_result_real_4096(1,i) = fpga_result_4096(i*2-1)/2^(15-12);
end

%MATLAB计算FFT
%512
matlab_result_512_real = zeros(1,len);
matlab_result_512_imag = zeros(1,len);
for i=1:len/512
    matlab_result_512 = fft(fpga_in_real(1,(i*512-511):i*512));
    matlab_result_512_real(1,(i*512-511):i*512) = real(matlab_result_512);
    matlab_result_512_imag(1,(i*512-511):i*512) = imag(matlab_result_512);
end


%1024
matlab_result_1024_real = zeros(1,len);
matlab_result_1024_imag = zeros(1,len);
for i=1:len/1024
    matlab_result_1024 = fft(fpga_in_real(1,(i*1024-1023):i*1024));
    matlab_result_1024_real(1,(i*1024-1023):i*1024) = real(matlab_result_1024);
    matlab_result_1024_imag(1,(i*1024-1023):i*1024) = imag(matlab_result_1024);
end


%2048
matlab_result_2048_real = zeros(1,len);
matlab_result_2048_imag = zeros(1,len);
for i=1:len/2048
    matlab_result_2048 = fft(fpga_in_real(1,(i*2048-2047):i*2048));
    matlab_result_2048_real(1,(i*2048-2047):i*2048) = real(matlab_result_2048);
    matlab_result_2048_imag(1,(i*2048-2047):i*2048) = imag(matlab_result_2048);
end

%4096
matlab_result_4096_real = zeros(1,len);
matlab_result_4096_imag = zeros(1,len);
for i=1:len/4096
    matlab_result_4096 = fft(fpga_in_real(1,(i*4096-4095):i*4096));
    matlab_result_4096_real(1,(i*4096-4095):i*4096) = real(matlab_result_4096);
    matlab_result_4096_imag(1,(i*4096-4095):i*4096) = imag(matlab_result_4096);
end


%对比计算结果&误差分析
dr_512=matlab_result_512_real-fpga_result_real_512;
di_512=matlab_result_512_imag-fpga_result_imag_512;
dr_1024=matlab_result_1024_real-fpga_result_real_1024;
di_1024=matlab_result_1024_imag-fpga_result_imag_1024;
dr_2048=matlab_result_2048_real-fpga_result_real_2048;
di_2048=matlab_result_2048_imag-fpga_result_imag_2048;
dr_4096=matlab_result_4096_real-fpga_result_real_4096;
di_4096=matlab_result_4096_imag-fpga_result_imag_4096;
figure('Position',[470,372,969,465])
nexttile,plot(fpga_result_real_4096(1,1:len)),title('fpga result real')
nexttile,plot(fpga_result_imag_4096(1,1:len)),title('fpga result imag')
nexttile,plot(matlab_result_4096_real(1,1:len)),title('matlab result real')
nexttile,plot(matlab_result_4096_imag(1,1:len)),title('matlab result imag')
nexttile,plot(dr_512(1,1:len)),title('512点FFT计算实部误差值')
nexttile,plot(di_512(1,1:len)),title('512点FFT计算虚部误差值')
nexttile,plot(dr_1024(1,1:len)),title('1024点FFT计算实部误差值')
nexttile,plot(di_1024(1,1:len)),title('1024点FFT计算虚部误差值')
nexttile,plot(dr_2048(1,1:len)),title('2048点FFT计算实部误差值')
nexttile,plot(di_2048(1,1:len)),title('2048点FFT计算虚部误差值')
nexttile,plot(dr_4096(1,1:len)),title('4096点FFT计算实部误差值')
nexttile,plot(di_4096(1,1:len)),title('4096点FFT计算虚部误差值')

rpmr_512 = 20*log10(rms(dr_512(1,1:len)));
rpmi_512 = 20*log10(rms(di_512(1,1:len)));
rpmr_1024 = 20*log10(rms(dr_1024(1,1:len)));
rpmi_1024 = 20*log10(rms(di_1024(1,1:len)));
rpmr_2048 = 20*log10(rms(dr_2048(1,1:len)));
rpmi_2048 = 20*log10(rms(di_2048(1,1:len)));
rpmr_4096 = 20*log10(rms(dr_4096(1,1:len)));
rpmi_4096 = 20*log10(rms(di_4096(1,1:len)));

