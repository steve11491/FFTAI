clear;clc;close all;

debug=1;

c=4;%通道数可变->2\4\8\16
cp=2;%单通道并行度固定
s=4;%流水级数固定
Ns=12; %FFT级数->9\10\11\12

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

%matlab fft 
ym=fft(x_o);
yr=zeros(2,N);
yr(1,:)=real(ym);
yr(2,:)=imag(ym);

%结果对比
dyr=yr(1,:)-fft_o(1,:);
dyi=yr(2,:)-fft_o(2,:);
figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fft_o(1,:)),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fft_o(2,:)),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')

if debug==0
    fft_s1_i = reshape(pe_s1_i(1,:,:,1)*2^15,p,N/p);
    fft_s1_o = reshape(pe_s1_o(1,:,:,1)*2^14,p,N/p);
    fft_s2_o = reshape(pe_s2_o(1,:,:,1)*2^13,p,N/p);
    fft_s3_o = reshape(pe_s3_o(1,:,:,1)*2^12,p,N/p);
    fft_s4_o = reshape(pe_s4_o(1,:,:,1)*2^11,p,N/p);
    fft_s5_i = reshape(pe2ramin(1,:,:,1)*2^11,p,N/p);
    fft_s5_o = reshape(pe_s1_o(1,:,:,2)*2^10,p,N/p);
    fft_s6_o = reshape(pe_s2_o(1,:,:,2)*2^9,p,N/p);
    fft_s7_o = reshape(pe_s3_o(1,:,:,2)*2^8,p,N/p);
    fft_s8_o = reshape(pe_s4_o(1,:,:,2)*2^7,p,N/p);
    fft_s9_i = reshape(pe2ramin(1,:,:,2)*2^7,p,N/p);
    fft_s9_o = reshape(pe_s1_o(1,:,:,3)*2^6,p,N/p);
    if Ns>=10
        fft_s10_o = reshape(pe_s2_o(1,:,:,3)*2^5,p,N/p);
        if Ns>=11
            fft_s11_o = reshape(pe_s3_o(1,:,:,3)*2^4,p,N/p);
            if Ns>=12
                fft_s12_o = reshape(pe_s4_o(1,:,:,3)*2^3,p,N/p);
            end
        end
    end
else
    fft_s1_i = reshape(pe_s1_i(1,:,:,1),p,N/p);
    fft_s1_o = reshape(pe_s1_o(1,:,:,1),p,N/p);
    fft_s2_o = reshape(pe_s2_o(1,:,:,1),p,N/p);
    fft_s3_o = reshape(pe_s3_o(1,:,:,1),p,N/p);
    fft_s4_o = reshape(pe_s4_o(1,:,:,1),p,N/p);
    fft_s5_i = reshape(pe2ramin(1,:,:,1),p,N/p);
    fft_s5_o = reshape(pe_s1_o(1,:,:,2),p,N/p);
    fft_s6_o = reshape(pe_s2_o(1,:,:,2),p,N/p);
    fft_s7_o = reshape(pe_s3_o(1,:,:,2),p,N/p);
    fft_s8_o = reshape(pe_s4_o(1,:,:,2),p,N/p);
    fft_s9_i = reshape(pe2ramin(1,:,:,2),p,N/p);
    fft_s9_o = reshape(pe_s1_o(1,:,:,3),p,N/p);

    fft_s10_o = reshape(pe_s2_o(1,:,:,3),p,N/p);

    fft_s11_o = reshape(pe_s3_o(1,:,:,3),p,N/p);

    fft_s12_o = reshape(pe_s4_o(1,:,:,3),p,N/p);

end


%写入fft输入
fft_i_note = zeros(1,N*2);
fid=fopen('./fft_i_4096.txt','wt');
for i=1:N
    if x_o(1,i)>2^(-15)
        fft_i_note(1,i*2-1) = floor(x_o(1,i)*2^15-1);
    elseif x_o(1,i)<-2^(-15)
        fft_i_note(1,i*2-1) = ceil(x_o(1,i)*2^15+1);
    else
        fft_i_note(1,i*2-1) = round(x_o(1,i)*2^15);
    end
    x_bin = dec2bin(fft_i_note(1,i*2),16); %imag
    fprintf(fid,'%s',x_bin);
    x_bin = dec2bin(fft_i_note(1,i*2-1),16); %real
    fprintf(fid,'%s\n',x_bin);

end
fclose(fid);

%写入fft输出用于ifft运算
ifft_i_note = zeros(1,N*2);
fid=fopen('./ifft_i_4096.txt','wt');
for i=1:N
    if fft_o(1,i)>2^(-5)
        fft_i_note(1,i*2-1) = floor(fft_o(1,i)*2^5-1);
    elseif fft_o(1,i)<-2^(-5)
        fft_i_note(1,i*2-1) = ceil(fft_o(1,i)*2^5+1);
    else
        fft_i_note(1,i*2-1) = round(fft_o(1,i)*2^5);
    end
    if fft_o(2,i)>2^(-5)
        fft_i_note(1,i*2) = floor(fft_o(2,i)*2^5-1);
    elseif fft_o(2,i)<-2^(-5)
        fft_i_note(1,i*2) = ceil(fft_o(2,i)*2^5+1);
    else
        fft_i_note(1,i*2) = round(fft_o(2,i)*2^5);
    end
    x_bin = dec2bin(fft_i_note(1,i*2),16); %imag
    fprintf(fid,'%s',x_bin);
    x_bin = dec2bin(fft_i_note(1,i*2-1),16); %real
    fprintf(fid,'%s\n',x_bin);

end
fclose(fid);

%% 

% 写入旋转因子
co(1)=cos(2*pi*0 / 4096);
so(1)=-sin(2*pi*0 / 4096);
co(2)=cos(2*pi*256 / 4096);
so(2)=-sin(2*pi*256 / 4096);
co(3)=cos(2*pi*512 / 4096);
so(3)=-sin(2*pi*512 / 4096);
co(4)=cos(2*pi*768 / 4096);
so(4)=-sin(2*pi*768 / 4096);

for i=1:4
    if co(i)>2^(-15)
        xco = floor(co(i)*2^15-1);
    elseif co(i)<-2^(-15)
        xco = ceil(co(i)*2^15+1);
    else
        xco = round(co(i)*2^15);
    end

    if so(i)>2^(-15)
        xso = floor(so(i)*2^15-1);
    elseif so(i)<-2^(-15)
        xso = ceil(so(i)*2^15+1);
    else
        xso = round(so(i)*2^15);
    end

    c_bin = dec2bin(xco,16); %imag

    s_bin = dec2bin(xso,16); %real
end


cordic_rom = zeros(2,c,N/p);
cordic_p9 = cordic(:,:,:,9);
cordic_p10 = cordic(:,:,:,10);
cordic_p11 =  cordic(:,:,:,11);
cordic_p12 =  cordic(:,:,:,12);
for i=1:N/p/8
    cordic_rom(:,:,8*(i-1)+1)=cordic_p9(:,:,8*(i-1)+1);
    cordic_rom(:,:,8*(i-1)+2)=cordic_p10(:,:,8*(i-1)+1);
    cordic_rom(:,:,8*(i-1)+3:8*(i-1)+4)=cordic_p11(:,:,8*(i-1)+1:8*(i-1)+2);
    cordic_rom(:,:,8*(i-1)+5:8*(i-1)+8)=cordic_p12(:,:,8*(i-1)+1:8*(i-1)+4);
end

rotar_i_note = zeros(1,N);
fid=fopen('./rotar_4096_0.txt','wt');
for i=1:N/8
    if cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)>2^(-15)
        rotar_i_note(1,i*2-1) = floor(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15-1);
    elseif cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)<-2^(-15)
        rotar_i_note(1,i*2-1) = ceil(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15+1);
    else
        rotar_i_note(1,i*2-1) = round(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15);
    end

    if cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)>2^(-15)
        rotar_i_note(1,i*2) = floor(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15-1);
    elseif cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)<-2^(-15)
        rotar_i_note(1,i*2) = ceil(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15+1);
    else
        rotar_i_note(1,i*2) = round(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15);
    end

    x_bin = dec2bin(rotar_i_note(1,i*2),16); %imag
    fprintf(fid,'%s',x_bin);

    x_bin = dec2bin(rotar_i_note(1,i*2-1),16); %real
    fprintf(fid,'%s\n',x_bin);
    
end
fclose(fid);

fid=fopen('./rotar_4096_1.txt','wt');
for i=N/8+1:N/4
    if cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)>2^(-15)
        rotar_i_note(1,i*2-1) = floor(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15-1);
    elseif cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)<-2^(-15)
        rotar_i_note(1,i*2-1) = ceil(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15+1);
    else
        rotar_i_note(1,i*2-1) = round(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15);
    end

    if cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)>2^(-15)
        rotar_i_note(1,i*2) = floor(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15-1);
    elseif cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)<-2^(-15)
        rotar_i_note(1,i*2) = ceil(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15+1);
    else
        rotar_i_note(1,i*2) = round(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15);
    end

    x_bin = dec2bin(rotar_i_note(1,i*2),16); %imag
    fprintf(fid,'%s',x_bin);

    x_bin = dec2bin(rotar_i_note(1,i*2-1),16); %real
    fprintf(fid,'%s\n',x_bin);
    
end
fclose(fid);

fid=fopen('./rotar_4096_2.txt','wt');
for i=N/4+1:3*N/8
    if cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)>2^(-15)
        rotar_i_note(1,i*2-1) = floor(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15-1);
    elseif cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)<-2^(-15)
        rotar_i_note(1,i*2-1) = ceil(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15+1);
    else
        rotar_i_note(1,i*2-1) = round(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15);
    end

    if cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)>2^(-15)
        rotar_i_note(1,i*2) = floor(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15-1);
    elseif cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)<-2^(-15)
        rotar_i_note(1,i*2) = ceil(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15+1);
    else
        rotar_i_note(1,i*2) = round(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15);
    end

    x_bin = dec2bin(rotar_i_note(1,i*2),16); %imag
    fprintf(fid,'%s',x_bin);

    x_bin = dec2bin(rotar_i_note(1,i*2-1),16); %real
    fprintf(fid,'%s\n',x_bin);
    
end
fclose(fid);

fid=fopen('./rotar_4096_3.txt','wt');
for i=3*N/8+1:N/2
    if cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)>2^(-15)
        rotar_i_note(1,i*2-1) = floor(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15-1);
    elseif cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)<-2^(-15)
        rotar_i_note(1,i*2-1) = ceil(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15+1);
    else
        rotar_i_note(1,i*2-1) = round(cordic_rom(1,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15);
    end

    if cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)>2^(-15)
        rotar_i_note(1,i*2) = floor(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15-1);
    elseif cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)<-2^(-15)
        rotar_i_note(1,i*2) = ceil(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15+1);
    else
        rotar_i_note(1,i*2) = round(cordic_rom(2,floor((i-1)/(N/p))+1,mod(i-1,N/p)+1)*2^15);
    end

    x_bin = dec2bin(rotar_i_note(1,i*2),16); %imag
    fprintf(fid,'%s',x_bin);

    x_bin = dec2bin(rotar_i_note(1,i*2-1),16); %real
    fprintf(fid,'%s\n',x_bin);
    
end
fclose(fid);


%% 

%比较结果
fft_o_note_real = load("fft_o_4096_real_0.txt");
fft_o_note_imag = load("fft_o_4096_imag_0.txt");

fpga_real = fft_o_note_real/2^(15-Ns);
fpga_imag = fft_o_note_imag/2^(15-Ns);


%结果对比
dyr=yr(1,:)-fpga_real;
dyi=yr(2,:)-fpga_imag;
figure('Position',[470,200,760,637])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')

%比较结果
fft_o_note_real = load("fft_o_4096_real_1.txt");
fft_o_note_imag = load("fft_o_4096_imag_1.txt");

fpga_real = fft_o_note_real/2^(15-Ns);
fpga_imag = fft_o_note_imag/2^(15-Ns);


%结果对比
dyr=yr(1,:)-fpga_real;
dyi=yr(2,:)-fpga_imag;
% figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')


%比较结果
fft_o_note_real = load("fft_o_4096_real_2.txt");
fft_o_note_imag = load("fft_o_4096_imag_2.txt");

fpga_real = fft_o_note_real/2^(15-Ns);
fpga_imag = fft_o_note_imag/2^(15-Ns);


%结果对比
dyr=yr(1,:)-fpga_real;
dyi=yr(2,:)-fpga_imag;
% figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')

%比较结果
fft_o_note_real = load("fft_o_4096_real_3.txt");
fft_o_note_imag = load("fft_o_4096_imag_3.txt");

fpga_real = fft_o_note_real/2^(15-Ns);
fpga_imag = fft_o_note_imag/2^(15-Ns);


%结果对比
dyr=yr(1,:)-fpga_real;
dyi=yr(2,:)-fpga_imag;
% figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')

rpmr = 20*log10(rms(dyr));
rpmi = 20*log10(rms(dyi));

%% 

%比较结果
fft_o_note_real = load("fft_o_4096_real_0.txt");
fft_o_note_imag = load("fft_o_4096_imag_0.txt");

fpga_real = fft_o_note_real/2^(15-Ns);
fpga_imag = fft_o_note_imag/2^(15-Ns);


%结果对比
dyr=yr(1,:)-fpga_real;
dyi=yr(2,:)-fpga_imag;
figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_real),title('RTL仿真结果实部')
nexttile,plot(yr(1,:)),title('MATLAB仿真结果实部')
nexttile,plot(dyr),title('实部结果误差')
nexttile,plot(fpga_imag),title('RTL仿真结果虚部')
nexttile,plot(yr(2,:)),title('MATLAB仿真结果虚部')
nexttile,plot(dyi),title('虚部结果误差')

rpmr = 20*log10(rms(dyr));
rpmi = 20*log10(rms(dyi));

%% 
% 
%比较test结果
% fft_o_note_file = zeros(1,N);
fft_o_note_file = load("fft_o_4096_test.txt");

%结果对比
dyr=fft_o(1,1:length(fft_o_note_file))-fft_o_note_file-1;
figure('Position',[470,372,969,465])
nexttile,plot(dyr),title('XrealDeta')


%% 

%FPGA PS-PL执行推理

%生成二进制文件
fft_in_fpga = zeros(1,2*N);
for i=1:N
    fft_in_fpga(1,2*i) = 0;
    if x_o(1,i)>2^(-15)
        fft_in_fpga(1,2*i-1) = floor(x_o(1,i)*2^15-1);
    elseif x_o(1,i)<-2^(-15)
        fft_in_fpga(1,2*i-1) = ceil(x_o(1,i)*2^15+1);
    else
        fft_in_fpga(1,2*i-1) = round(x_o(1,i)*2^15);
    end
end
fid=fopen('./bin/fft_in_512.bin','wb');
fwrite(fid,fft_in_fpga,'int16');
fclose(fid);

%% 
%加载输入数据
Ns=9;
N=2^Ns; %FFT point
fid=fopen('./bin/fft_in_512.bin','rb');
fpga_in = fread(fid,'int16');
fpga_in_real = zeros(1,N);
% fpga_in_imag = zeros(1,N);
for i=1:N
    fpga_in_real(1,i) = fpga_in(i*2-1)/2^(15);
end

%matlab fft 
ym=fft(fpga_in_real);
yr=zeros(2,N);
yr(1,:)=real(ym);
yr(2,:)=imag(ym);

%加载结果数据
fid=fopen('./bin/fft_out_512_0.bin','rb');
fpga_result = fread(fid,'int16');
fpga_result_real = zeros(1,N);
fpga_result_imag = zeros(1,N);
for i=1:N
    fpga_result_imag(1,i) = fpga_result(i*2)/2^(15-Ns);
    fpga_result_real(1,i) = fpga_result(i*2-1)/2^(15-Ns);
end
%结果对比
dyr=yr(1,:)-fpga_result_real;
dyi=yr(2,:)-fpga_result_imag;
figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_result_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr(1,1:N)),title('XrealDeta')
nexttile,plot(fpga_result_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi(1,1:N)),title('XimgeDeta')

rpmr = 20*log10(rms(dyr(1,1:N)));
rpmi = 20*log10(rms(dyi(1,1:N)));

%% 

%加载结果数据

fid=fopen('./bin/fft_out0.bin','rb');
fpga_result = fread(fid,'int16');
fpga_result_real = zeros(1,N);
fpga_result_imag = zeros(1,N);
for i=1:N-4
    fpga_result_imag(1,i) = fpga_result(i*2+8)/2^(15-Ns);
    fpga_result_real(1,i) = fpga_result(i*2+8-1)/2^(15-Ns);
end
% for i=N/4+1:N-4
%     fpga_result_imag(1,i) = fpga_result(i*2+8)/2^(15-Ns);
%     fpga_result_real(1,i) = fpga_result(i*2+8-1)/2^(15-Ns);
% end

%结果对比
dyr=yr(1,:)-fpga_result_real;
dyi=yr(2,:)-fpga_result_imag;
figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_result_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_result_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')

rpmr = 20*log10(rms(dyr));
rpmi = 20*log10(rms(dyi));


%% 

%加载结果数据

fid=fopen('./bin/fft_out0.bin','rb');
fpga_result = fread(fid,'int16');
fpga_result_real = zeros(1,N);
fpga_result_imag = zeros(1,N);
for i=1:N
    fpga_result_imag(1,i) = fpga_result(i*2)/2^(15-Ns);
    fpga_result_real(1,i) = fpga_result(i*2-1)/2^(15-Ns);
end

%结果对比
dyr=yr(1,:)-fpga_result_real;
dyi=yr(2,:)-fpga_result_imag;
figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_result_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_result_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')

%加载结果数据

fid=fopen('./bin/fft_out1.bin','rb');
fpga_result = fread(fid,'int16');
fpga_result_real = zeros(1,N);
fpga_result_imag = zeros(1,N);
for i=1:N
    fpga_result_imag(1,i) = fpga_result(i*2)/2^(15-Ns);
    fpga_result_real(1,i) = fpga_result(i*2-1)/2^(15-Ns);
end

%结果对比
dyr=yr(1,:)-fpga_result_real;
dyi=yr(2,:)-fpga_result_imag;
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_result_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_result_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')


%加载结果数据

fid=fopen('./bin/fft_out2.bin','rb');
fpga_result = fread(fid,'int16');
fpga_result_real = zeros(1,N);
fpga_result_imag = zeros(1,N);
for i=1:N
    fpga_result_imag(1,i) = fpga_result(i*2)/2^(15-Ns);
    fpga_result_real(1,i) = fpga_result(i*2-1)/2^(15-Ns);
end

%结果对比
dyr=yr(1,:)-fpga_result_real;
dyi=yr(2,:)-fpga_result_imag;
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_result_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_result_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')


%加载结果数据

fid=fopen('./bin/fft_out3.bin','rb');
fpga_result = fread(fid,'int16');
fpga_result_real = zeros(1,N);
fpga_result_imag = zeros(1,N);
for i=1:N
    fpga_result_imag(1,i) = fpga_result(i*2)/2^(15-Ns);
    fpga_result_real(1,i) = fpga_result(i*2-1)/2^(15-Ns);
end

%结果对比
dyr=yr(1,:)-fpga_result_real;
dyi=yr(2,:)-fpga_result_imag;
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_result_real),title('Xreal')
nexttile,plot(yr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_result_imag),title('Ximge')
nexttile,plot(yr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')



%% 
% IFFT

%比较结果
ifft_o_note_real = load("ifft_o_4096_real.txt");
ifft_o_note_imag = load("ifft_o_4096_imag.txt");

fpga_real=zeros(1,64);
fpga_imag=zeros(1,64);
if Ns==9
    for n=1:32
        for i=1:8
            for j=1:2
                fpga_real(1,(n-1)*16+(i-1)*2+j) = ifft_o_note_real(1,j+64*(i-1)+2*(n-1))/2^(5);
                fpga_imag(1,(n-1)*16+(i-1)*2+j) = ifft_o_note_imag(1,j+64*(i-1)+2*(n-1))/2^(5);
            end
        end
    end
elseif Ns==10
    for n=1:128
        for i=1:4
            for j=1:2
                fpga_real(1,(n-1)*8+(i-1)*2+j) = ifft_o_note_real(1,j+256*(i-1)+2*(n-1))/2^(5);
                fpga_imag(1,(n-1)*8+(i-1)*2+j) = ifft_o_note_imag(1,j+256*(i-1)+2*(n-1))/2^(5);
            end
        end
    end
elseif Ns==11
    for n=1:512
        for i=1:2
            for j=1:2
                fpga_real(1,(n-1)*4+(i-1)*2+j) = ifft_o_note_real(1,j+1024*(i-1)+2*(n-1))/2^(5);
                fpga_imag(1,(n-1)*4+(i-1)*2+j) = ifft_o_note_imag(1,j+1024*(i-1)+2*(n-1))/2^(5);
            end
        end
    end
else
    fpga_real = ifft_o_note_real/2^(5);
    fpga_imag = ifft_o_note_imag/2^(5);
end

% Yfft=conj(ym);
% Yfft_real = real(Yfft);
% Yfft_imag = imag(Yfft);
% xm=fft(Yfft);
xm = ifft(ym);
%结果对比
xr=zeros(2,N);
xr(1,:)=real(xm);
xr(2,:)=imag(xm);
dyr=xr(1,:)-fpga_real;
dyi=xr(2,:)-fpga_imag;
figure('Position',[470,372,969,465])
% nexttile,plot(x_o),title('x')
nexttile,plot(fpga_real),title('Xreal')
nexttile,plot(xr(1,:)),title('XrealMat')
nexttile,plot(dyr),title('XrealDeta')
nexttile,plot(fpga_imag),title('Ximge')
nexttile,plot(xr(2,:)),title('XimgeMat')
nexttile,plot(dyi),title('XimgeDeta')

rpmr = 20*log10(rms(dyr));
rpmi = 20*log10(rms(dyi));
