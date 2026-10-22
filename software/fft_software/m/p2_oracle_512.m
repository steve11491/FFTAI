clear;clc;close all;

debug=1;

c=4;%通道数可变->2\4\8\16
cp=2;%单通道并行度固定
s=4;%流水级数固定
Ns=9; %P2 oracle

p=c*cp;%总并行度->RAM个数
wc=log2(c);%RAM地址高位位宽->选择RAM块
wp=log2(cp);%块RAM地址->选择块内RAM
wa=Ns-wc-wp;%RAM地址位宽

N=2^Ns; %FFT point
tt=1:1:N;
if debug==1
    x_o=tt;
else
%     x_o = 1 + 0*tt;
%     x_o=sin(6*tt)+cos(60*tt)-cos(30*tt); %原始数据
    x_o=rand(1,N)-0.5;
%     x_o=sin(6*tt); %原始数据
    x_o=x_o/max(abs(x_o)); %归一化
end
v_orc = load('D:/project_PLF/FFTAI/software/fft_software/txt/fft_in_rand.txt');
x_o = reshape(v_orc(1:2:1024),1,512);
debug = 0;

%主控输入地址
pipeline=0; %流水级数，第几次流水

cordic = zeros(2,c,N/p,log2(N));

b=1:1:N; %DDR 顺序

%主控制器地址重排
%反比特排序
p0=(b-1).';
addro=dec2bin(p0);
addr=addro(:,Ns:-1:1);
addrc=addr(:,1:wc);
addra=addr(:,wc+1:wc+wa);
addrp=addr(:,wc+wa+1:Ns);

ts=bin2dec(addr)+1;
ts=ts.';

pc=bin2dec(addrc)+1;
pa=bin2dec(addra)+1;
pp=bin2dec(addrp)+1;

ph=(pc-1)*cp+pp;
pl=pa;

%AXI->RAM IN
ram_in=zeros(2,p,N/p);
for i=1:N/p
    for j=1:p
        ram_in(1,ph((i-1)*p+j,1),pl((i-1)*p+j,1),1)=x_o(1,j+p*(i-1));
    end
end
axi2ramin = reshape(ram_in(1,:,:),p,N/p);

% ploop=ceil(Ns/s);
ploop=3;
pe_s1_i=zeros(2,p,N/p,ploop);
pe_s1_o=zeros(2,p,N/p,ploop);
pe_s2_o=zeros(2,p,N/p,ploop);
pe_s3_o=zeros(2,p,N/p,ploop);
pe_s4_o=zeros(2,p,N/p,ploop);
pe2raminbuff=zeros(2,p,N/p,ploop);
pe2ramin=zeros(2,p,N/p,ploop);

mul_o=zeros(2,p,N/p); %MATLAB难以表示流水结构，以此进行保存

%四级流水 基2 -> [y0,y1] = Wk2*2 * [x1,-x1] + [x0,x0]
for i=1:ploop
    stage=0;    %流水内部阶段，第几级

    if i~=0
        xc = N/2^(s*pipeline)/cp;
        lc = 2^(s*pipeline)/c;
    end

    if log2(N)-4*pipeline > 4
        out_stage = 0;
    else
        out_stage = log2(N)-4*pipeline;
    end

    
    %=================================第一级============================================%
    
    %旋转因子
    for cow = 1:c
        if pipeline==0
            for j=1:N/p
                cordic(1,cow,j,pipeline*4+stage+1) = cos(2*pi*mod(j-1, 2^stage) / (2^(s*pipeline+stage+1)));
                cordic(2,cow,j,pipeline*4+stage+1) = -sin(2*pi*mod(j-1, 2^stage) / (2^(s*pipeline+stage+1)));
            end
        else
            for j=1:lc
                for n=1:xc
                    cordic(1,cow,n+(j-1)*xc,pipeline*4+stage+1) = cos(2*pi*(j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) / (2^(s*pipeline+stage+1)));
                    cordic(2,cow,n+(j-1)*xc,pipeline*4+stage+1) = -sin(2*pi*(j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) / (2^(s*pipeline+stage+1)));
                end
            end
        end
    end
    pe_s1_i(:,:,:,i) = ram_in;

    for cow = 1:c
        for j=1:(N/p) %并行度为p
            add_i_1_1(1:2,1) = pe_s1_i(:,2*cow-1,j,i);
            add_i_1_1(1:2,2) = pe_s1_i(:,2*cow-1,j,i);
            mul_i_1_1(1:2,1) = pe_s1_i(:,2*cow-0,j,i);
            mul_i_1_1(1:2,2) = -pe_s1_i(:,2*cow-0,j,i);
            Wnk_i_1_1(1:2,1) = [cordic(1,cow,j,pipeline*4+stage+1),cordic(2,cow,j,pipeline*4+stage+1)];
            Wnk_i_1_1(1:2,2) = [-cordic(2,cow,j,pipeline*4+stage+1),cordic(1,cow,j,pipeline*4+stage+1)];
    
            if debug==0
                mul_o(:,(2*cow-1):(2*cow-0),j) = Wnk_i_1_1 * mul_i_1_1 + add_i_1_1;
            else
                mul_o(:,(2*cow-1):(2*cow-0),j) = pe_s1_i(:,(2*cow-1):(2*cow-0),j,i);
            end

        end
    end

    stage = stage + 1;

        %流水重排/交叉互换
    for n=1:c
        for j=1:(N/p/2)
            pe_s1_o(:,cp*n-1,2*j-1,i) = mul_o(:,cp*n-1,2*j-1);
            pe_s1_o(:,cp*n-1,2*j-0,i) = mul_o(:,cp*n-0,2*j-1);
            pe_s1_o(:,cp*n-0,2*j-1,i) = mul_o(:,cp*n-1,2*j-0);
            pe_s1_o(:,cp*n-0,2*j-0,i) = mul_o(:,cp*n-0,2*j-0);
        end
    end

    if out_stage==1 %FFT输出
        if debug==0
            break
        end
    end


    %=================================第二级============================================%
    %旋转因子
    for cow = 1:c
        if pipeline==0
            for j=1:N/p
                cordic(1,cow,j,pipeline*4+stage+1) = cos(2*pi*mod(j-1, 2^stage) / (2^(s*pipeline+stage+1)));
                cordic(2,cow,j,pipeline*4+stage+1) = -sin(2*pi*mod(j-1, 2^stage) / (2^(s*pipeline+stage+1)));
            end
        else
            for j=1:lc
                for n=1:xc
                    cordic(1,cow,n+(j-1)*xc,pipeline*4+stage+1) = cos(2*pi*(j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) / (2^(s*pipeline+stage+1)));
                    cordic(2,cow,n+(j-1)*xc,pipeline*4+stage+1) = -sin(2*pi*(j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) / (2^(s*pipeline+stage+1)));
                end
            end
        end
    end

    for cow = 1:c
        for j=1:(N/p) %并行度为p
            add_i_1_1(1:2,1) = pe_s1_o(:,2*cow-1,j,i);
            add_i_1_1(1:2,2) = pe_s1_o(:,2*cow-1,j,i);
            mul_i_1_1(1:2,1) = pe_s1_o(:,2*cow-0,j,i);
            mul_i_1_1(1:2,2) = -pe_s1_o(:,2*cow-0,j,i);
            Wnk_i_1_1(1:2,1) = [cordic(1,cow,j,pipeline*4+stage+1),cordic(2,cow,j,pipeline*4+stage+1)];
            Wnk_i_1_1(1:2,2) = [-cordic(2,cow,j,pipeline*4+stage+1),cordic(1,cow,j,pipeline*4+stage+1)];
    
            if debug==0
                mul_o(:,(2*cow-1):(2*cow-0),j) = Wnk_i_1_1 * mul_i_1_1 + add_i_1_1;
            else
                mul_o(:,(2*cow-1):(2*cow-0),j) = pe_s1_o(:,(2*cow-1):(2*cow-0),j,i);
            end
        end
    end

    stage = stage + 1;

    %流水重排/交叉互换
    for n=1:c
        for j=1:(N/p/4)
            pe_s2_o(:,cp*n-1,4*j-3:4*j-2,i) = mul_o(:,cp*n-1,4*j-3:4*j-2);
            pe_s2_o(:,cp*n-1,4*j-1:4*j-0,i) = mul_o(:,cp*n-0,4*j-3:4*j-2);
            pe_s2_o(:,cp*n-0,4*j-3:4*j-2,i) = mul_o(:,cp*n-1,4*j-1:4*j-0);
            pe_s2_o(:,cp*n-0,4*j-1:4*j-0,i) = mul_o(:,cp*n-0,4*j-1:4*j-0);
        end
    end

    if out_stage==2 %FFT输出
        if debug==0
            break
        end
    end

    %=================================第三级============================================%
    %旋转因子
    for cow = 1:c
        if pipeline==0
            for j=1:N/p
                cordic(1,cow,j,pipeline*4+stage+1) = cos(2*pi*mod(j-1, 2^stage) / (2^(s*pipeline+stage+1)));
                cordic(2,cow,j,pipeline*4+stage+1) = -sin(2*pi*mod(j-1, 2^stage) / (2^(s*pipeline+stage+1)));
            end
        else
            for j=1:lc
                for n=1:xc
                    cordic(1,cow,n+(j-1)*xc,pipeline*4+stage+1) = cos(2*pi*(j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) / (2^(s*pipeline+stage+1)));
                    cordic(2,cow,n+(j-1)*xc,pipeline*4+stage+1) = -sin(2*pi*(j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) / (2^(s*pipeline+stage+1)));
                end
            end
        end
    end

    for cow = 1:c
        for j=1:(N/p) %并行度为p
            add_i_1_1(1:2,1) = pe_s2_o(:,2*cow-1,j,i);
            add_i_1_1(1:2,2) = pe_s2_o(:,2*cow-1,j,i);
            mul_i_1_1(1:2,1) = pe_s2_o(:,2*cow-0,j,i);
            mul_i_1_1(1:2,2) = -pe_s2_o(:,2*cow-0,j,i);
            Wnk_i_1_1(1:2,1) = [cordic(1,cow,j,pipeline*4+stage+1),cordic(2,cow,j,pipeline*4+stage+1)];
            Wnk_i_1_1(1:2,2) = [-cordic(2,cow,j,pipeline*4+stage+1),cordic(1,cow,j,pipeline*4+stage+1)];
    
            if debug==0
                mul_o(:,(2*cow-1):(2*cow-0),j) = Wnk_i_1_1 * mul_i_1_1 + add_i_1_1;
            else
                mul_o(:,(2*cow-1):(2*cow-0),j) = pe_s2_o(:,(2*cow-1):(2*cow-0),j,i);
            end
        end
    end

    stage = stage + 1;

    %流水重排/交叉互换
    for n=1:c
        for j=1:(N/p/8)
            pe_s3_o(:,cp*n-1,8*j-7:8*j-4,i) = mul_o(:,cp*n-1,8*j-7:8*j-4);
            pe_s3_o(:,cp*n-1,8*j-3:8*j-0,i) = mul_o(:,cp*n-0,8*j-7:8*j-4);
            pe_s3_o(:,cp*n-0,8*j-7:8*j-4,i) = mul_o(:,cp*n-1,8*j-3:8*j-0);
            pe_s3_o(:,cp*n-0,8*j-3:8*j-0,i) = mul_o(:,cp*n-0,8*j-3:8*j-0);
        end
    end

    if out_stage==3 %FFT输出
        if debug==0
            break
        end
    end

    %=================================第四级============================================%
    %旋转因子
    for cow = 1:c
        if pipeline==0
            for j=1:N/p
                cordic(1,cow,j,pipeline*4+stage+1) = cos(2*pi*mod(j-1, 2^stage) / (2^(s*pipeline+stage+1)));
                cordic(2,cow,j,pipeline*4+stage+1) = -sin(2*pi*mod(j-1, 2^stage) / (2^(s*pipeline+stage+1)));
            end
        else
            for j=1:lc
                for n=1:xc
                    cordic(1,cow,n+(j-1)*xc,pipeline*4+stage+1) = cos(2*pi*(j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) / (2^(s*pipeline+stage+1)));
                    cordic(2,cow,n+(j-1)*xc,pipeline*4+stage+1) = -sin(2*pi*(j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) / (2^(s*pipeline+stage+1)));
                end
            end
        end
    end

    for cow = 1:c
        for j=1:(N/p) %并行度为p
            add_i_1_1(1:2,1) = pe_s3_o(:,2*cow-1,j,i);
            add_i_1_1(1:2,2) = pe_s3_o(:,2*cow-1,j,i);
            mul_i_1_1(1:2,1) = pe_s3_o(:,2*cow-0,j,i);
            mul_i_1_1(1:2,2) = -pe_s3_o(:,2*cow-0,j,i);
            Wnk_i_1_1(1:2,1) = [cordic(1,cow,j,pipeline*4+stage+1),cordic(2,cow,j,pipeline*4+stage+1)];
            Wnk_i_1_1(1:2,2) = [-cordic(2,cow,j,pipeline*4+stage+1),cordic(1,cow,j,pipeline*4+stage+1)];
    
            if debug==0
                mul_o(:,(2*cow-1):(2*cow-0),j) = Wnk_i_1_1 * mul_i_1_1 + add_i_1_1;
            else
                mul_o(:,(2*cow-1):(2*cow-0),j) = pe_s3_o(:,(2*cow-1):(2*cow-0),j,i);
            end

        end
    end


    %流水重排/交叉互换
    for n=1:c
        for j=1:(N/p/16)
            pe_s4_o(:,cp*n-1,16*j-15:16*j-8,i) = mul_o(:,cp*n-1,16*j-15:16*j-8);
            pe_s4_o(:,cp*n-1,16*j-7:16*j-0,i) = mul_o(:,cp*n-0,16*j-15:16*j-8);
            pe_s4_o(:,cp*n-0,16*j-15:16*j-8,i) = mul_o(:,cp*n-1,16*j-7:16*j-0);
            pe_s4_o(:,cp*n-0,16*j-7:16*j-0,i) = mul_o(:,cp*n-0,16*j-7:16*j-0);
        end
    end

    if out_stage==4 %FFT输出
        if debug==0
            break
        end
    end

    %PE -> RAM IN
    %buff size:32*c
    if out_stage==1
        for n=1:p
            for j=1:N/p
                pe2raminbuff(:,mod(n-1,2)+floor(mod(j-1,16)*c/16)*2+1,floor((n-1)/2)+mod(j-1,16/c)*c+floor((j-1)/16)*16+1,i)=pe_s1_o(:,n,j,i);
            end
        end
        for j=1:N/p
            for n=1:p
                pe2ramin(:,n,mod(j-1,16)*(N/32/c)+floor((j-1)/16)+1,i)=pe2raminbuff(:,n,j,i);
            end
        end
    elseif out_stage==2
        for n=1:p
            for j=1:N/p
                pe2raminbuff(:,mod(n-1,2)+floor(mod(j-1,16)*c/16)*2+1,floor((n-1)/2)+mod(j-1,16/c)*c+floor((j-1)/16)*16+1,i)=pe_s2_o(:,n,j,i);
            end
        end
        for j=1:N/p
            for n=1:p
                pe2ramin(:,n,mod(j-1,16)*(N/32/c)+floor((j-1)/16)+1,i)=pe2raminbuff(:,n,j,i);
            end
        end
    elseif out_stage==3
        for n=1:p
            for j=1:N/p
                pe2raminbuff(:,mod(n-1,2)+floor(mod(j-1,16)*c/16)*2+1,floor((n-1)/2)+mod(j-1,16/c)*c+floor((j-1)/16)*16+1,i)=pe_s3_o(:,n,j,i);
            end
        end
        for j=1:N/p
            for n=1:p
                pe2ramin(:,n,mod(j-1,16)*(N/32/c)+floor((j-1)/16)+1,i)=pe2raminbuff(:,n,j,i);
            end
        end
    else
        for n=1:p
            for j=1:N/p
                pe2raminbuff(:,mod(n-1,2)+floor(mod(j-1,16)*c/16)*2+1,floor((n-1)/2)+mod(j-1,16/c)*c+floor((j-1)/16)*16+1,i)=pe_s4_o(:,n,j,i);
            end
        end
        for j=1:N/p
            for n=1:p
                pe2ramin(:,n,mod(j-1,16)*(N/32/c)+floor((j-1)/16)+1,i)=pe2raminbuff(:,n,j,i);
            end
        end
    end


    
    ram_in=pe2ramin(:,:,:,i);
%     end

    pipeline = pipeline + 1;
end

%PE -> RAM OUT
addr_out=zeros(p,N/p);
for row=1:c
    for n=1:lc
        for j=1:xc 
            addr_out(2*row-1,(n-1)*xc+j) = (n+(row-1)*lc)+(lc*c*(j-1));     
            addr_out(2*row-0,(n-1)*xc+j) = (n+(row-1)*lc)+(lc*c*(j-1))+N/2;       
        end
    end
end

ram_out=zeros(2,p,N/p);
fft_o=zeros(2,N);%FFT输出

%RAM OUT -> AXI
for n=1:p
    for j=1:N/p
        if debug==0
            fft_o(:,addr_out(n,j)) = mul_o(:,n,j);
        else
            if out_stage==1
                fft_o(:,addr_out(n,j)) = pe_s1_i(:,n,j,ploop);
            elseif out_stage==2
                fft_o(:,addr_out(n,j)) = pe_s1_o(:,n,j,ploop);
            elseif out_stage==3
                fft_o(:,addr_out(n,j)) = pe_s2_o(:,n,j,ploop);
            else
                fft_o(:,addr_out(n,j)) = pe_s3_o(:,n,j,ploop);
            end
        end
    end
end

for n=1:p
    for j=1:N/p
        ram_out(:,n,j) = fft_o(:,j+(n-1)*N/p);
    end
end

pe2raminbuff_last=reshape(pe2ramin(1,:,:,ploop),p,N/p);
ram_in_last = reshape(ram_in(1,:,:),p,N/p);
ramout2axi = reshape(ram_out(1,:,:),p,N/p);

% ---- P2 oracle dumps ----
O = 'D:\project_PLF\FFTAI\note\p2_scripts\oracle';
dlmwrite([O '/x.txt'], x_o, 'delimiter',' ', 'precision', 16);
dlmwrite([O '/axi2ramin.txt'], axi2ramin, 'delimiter',' ', 'precision', 16);
dlmwrite([O '/addr_out.txt'], addr_out, 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1i_1.txt'], reshape(pe_s1_i(1,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1i_1_im.txt'], reshape(pe_s1_i(2,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1o_1.txt'], reshape(pe_s1_o(1,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1o_1_im.txt'], reshape(pe_s1_o(2,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s2o_1.txt'], reshape(pe_s2_o(1,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s2o_1_im.txt'], reshape(pe_s2_o(2,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s3o_1.txt'], reshape(pe_s3_o(1,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s4o_1.txt'], reshape(pe_s4_o(1,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/pe2ri_1.txt'], reshape(pe2ramin(1,:,:,1),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1i_2.txt'], reshape(pe_s1_i(1,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1i_2_im.txt'], reshape(pe_s1_i(2,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1o_2.txt'], reshape(pe_s1_o(1,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1o_2_im.txt'], reshape(pe_s1_o(2,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s2o_2.txt'], reshape(pe_s2_o(1,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s2o_2_im.txt'], reshape(pe_s2_o(2,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s3o_2.txt'], reshape(pe_s3_o(1,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s4o_2.txt'], reshape(pe_s4_o(1,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/pe2ri_2.txt'], reshape(pe2ramin(1,:,:,2),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1i_3.txt'], reshape(pe_s1_i(1,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1i_3_im.txt'], reshape(pe_s1_i(2,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1o_3.txt'], reshape(pe_s1_o(1,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s1o_3_im.txt'], reshape(pe_s1_o(2,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s2o_3.txt'], reshape(pe_s2_o(1,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s2o_3_im.txt'], reshape(pe_s2_o(2,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s3o_3.txt'], reshape(pe_s3_o(1,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/s4o_3.txt'], reshape(pe_s4_o(1,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/pe2ri_3.txt'], reshape(pe2ramin(1,:,:,3),p,N/p), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/ffto_re.txt'], fft_o(1,:), 'delimiter',' ', 'precision', 16);
dlmwrite([O '/ffto_im.txt'], fft_o(2,:), 'delimiter',' ', 'precision', 16);
disp('ORACLE-DONE');
exit;
