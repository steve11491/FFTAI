% gen_tb_small: 为 tb_mdc / tb_mdc_8p 生成输入与旋转因子数据
% fft_i_16.txt  : 16 行 x 16bit 二进制串(实数输入)
% rotar_16.txt  : 64 行 x 16bit 二进制串 (re,im 对交错, N=16 旋转因子)
% fft_i_64.txt  : 128 行 x 16bit 二进制串(tb_mdc_8p data_in[127:0])
% rotar_64.txt  : 64 行 x 16bit 二进制串 (N=64 旋转因子, k=0..31)
% 兼容 R2017a: 无 nexttile; dec2bin 前统一 mod(.,65536) 补码转无符号

% ---- fft_i_16: 确定性单音+直流混合, 16 点 ----
N = 16;
x = round(10000*cos(2*pi*(0:N-1)/N)) + 500;
fid = fopen('fft_i_16.txt', 'wt');
for i = 1:N
    wvec(fid, x(i));
end
fclose(fid);

% ---- rotar_16: 32 对 (re,im), theta=2*pi*k/16 ----
fid = fopen('rotar_16.txt', 'wt');
for k = 0:31
    th = 2*pi*k/16;
    wvec(fid, quan(cos(th)));   % re
    wvec(fid, quan(-sin(th)));  % im
end
fclose(fid);

% ---- fft_i_64: 128 个实数, 单音 ----
N = 64;
x = round(10000*cos(2*pi*5*(0:N-1)/N));
fid = fopen('fft_i_64.txt', 'wt');
for i = 1:N*2
    wvec(fid, x(mod(i-1, N)+1));  % 双份填满 128 槽
end
fclose(fid);

% ---- rotar_64: 32 对, theta=2*pi*k/64 ----
fid = fopen('rotar_64.txt', 'wt');
for k = 0:31
    th = 2*pi*k/64;
    wvec(fid, quan(cos(th)));
    wvec(fid, quan(-sin(th)));
end
fclose(fid);

disp('GEN_SMALL done');

function q = quan(v)
    if v > 2^(-15)
        q = floor(v*2^15 - 1);
    elseif v < -2^(-15)
        q = ceil(v*2^15 + 1);
    else
        q = round(v*2^15);
    end
end

function wvec(fid, v)
    u = mod(v, 65536);
    fprintf(fid, '%s\n', dec2bin(u, 16));
end

