clear;clc;close all;

c=4;%通道数可变->2\4\8\16
cp=2;%单通道并行度固定
s=4;%流水级数固定
Ns=12; %FFT级数->9\10\11\12

p=c*cp;%总并行度->RAM个数
wc=log2(c);%RAM地址高位位宽->选择RAM块
wp=log2(cp);%块RAM地址->选择块内RAM
wa=Ns-wc-wp;%RAM地址位宽

N=2^Ns; %FFT point
Nm=4096;

%主控输入地址
pipeline=0; %流水级数，第几次流水

cordic = zeros(c,N/p,12);

% ploop=ceil(Ns/s);
ploop=3;

%四级流水 基2 -> [y0,y1] = Wk2*2 * [x1,-x1] + [x0,x0]
for i=1:ploop
    stage=0;    %流水内部阶段，第几级

    if i~=0
        xc = N/2^(s*pipeline)/cp;
        lc = 2^(s*pipeline)/c;
    end

%     if log2(N)-4*pipeline > 4
%         out_stage = 0;
%     else
%         out_stage = log2(N)-4*pipeline;
%     end

    out_stage = 0;

    
    %=================================第一级============================================%
    
    %旋转因子
    for cow = 1:c
        if pipeline==0
            for j=1:N/p
                cordic(cow,j,pipeline*4+stage+1) = mod(j-1, 2^stage) * Nm / (2^(s*pipeline+stage+1));
            end
        else
            for j=1:lc
                for n=1:xc
                    cordic(cow,n+(j-1)*xc,pipeline*4+stage+1) = (j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) * Nm / (2^(s*pipeline+stage+1));
                end
            end
        end
    end

    stage = stage + 1;

    if out_stage==1 %FFT输出
        break
    end


    %=================================第二级============================================%
    %旋转因子
    for cow = 1:c
        if pipeline==0
            for j=1:N/p
                cordic(cow,j,pipeline*4+stage+1) = mod(j-1, 2^stage) * Nm / (2^(s*pipeline+stage+1));
            end
        else
            for j=1:lc
                for n=1:xc
                    cordic(cow,n+(j-1)*xc,pipeline*4+stage+1) = (j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) * Nm / (2^(s*pipeline+stage+1));
                end
            end
        end
    end

    stage = stage + 1;

    if out_stage==2 %FFT输出
        break
    end

    %=================================第三级============================================%
    %旋转因子
    for cow = 1:c
        if pipeline==0
            for j=1:N/p
                cordic(cow,j,pipeline*4+stage+1) = mod(j-1, 2^stage) * Nm / (2^(s*pipeline+stage+1));
            end
        else
            for j=1:lc
                for n=1:xc
                    cordic(cow,n+(j-1)*xc,pipeline*4+stage+1) = (j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) * Nm / (2^(s*pipeline+stage+1));
                end
            end
        end
    end

    stage = stage + 1;

    if out_stage==3 %FFT输出
        break
    end

    %=================================第四级============================================%
    %旋转因子
    for cow = 1:c
        if pipeline==0
            for j=1:N/p
                cordic(cow,j,pipeline*4+stage+1) = mod(j-1, 2^stage) * Nm / (2^(s*pipeline+stage+1));
            end
        else
            for j=1:lc
                for n=1:xc
                    cordic(cow,n+(j-1)*xc,pipeline*4+stage+1) = (j-1+lc*(c*mod(n-1,2^stage)+(cow-1))) * Nm / (2^(s*pipeline+stage+1));
                end
            end
        end
    end


    if out_stage==4 %FFT输出
        break
    end

    pipeline = pipeline + 1;
end

cordic_np1 = cordic(:,:,1);
cordic_np2 = cordic(:,:,2);
cordic_np3 = cordic(:,:,3);
cordic_np4 = cordic(:,:,4);
cordic_np5 = cordic(:,:,5);
cordic_np6 = cordic(:,:,6);
cordic_np7 = cordic(:,:,7);
cordic_np8 = cordic(:,:,8);
cordic_np9 = cordic(:,:,9);
cordic_np10 = cordic(:,:,10);
cordic_np11 =  cordic(:,:,11);
cordic_np12 =  cordic(:,:,12);
% if Ns>=10
%     cordic_np10 = cordic(:,:,10);
%     if Ns>=11
%         cordic_np11 =  cordic(:,:,11);
%         if Ns>=12
%             cordic_np12 =  cordic(:,:,12);
%         end
%     end
% end

cordic_rom = zeros(c,N/p);
det=N/512;
for i=1:N/p/8
    cordic_rom(:,det*(i-1)+1)=cordic_np9(:,det*(i-1)+1);
    if Ns>=10
        cordic_rom(:,det*(i-1)+2)=cordic_np10(:,det*(i-1)+1);
        if Ns>=11
            cordic_rom(:,det*(i-1)+3:det*(i-1)+4)=cordic_np11(:,det*(i-1)+1:det*(i-1)+2);
            if Ns>=12
                cordic_rom(:,det*(i-1)+5:det*(i-1)+8)=cordic_np12(:,det*(i-1)+1:det*(i-1)+4);
            end
        end
    end
end

% 写入第一轮输入数据
% rotar_i_note = zeros(1,N);
% fid=fopen('./rotar_4096_test.txt','wt');
% for i=1:N/2
% %     if cordic_rom(1,i)>2^(-15)
% %         rotar_i_note(1,i*2-1) = floor(cordic_rom(1,i)*2^15-1);
% %     elseif cordic_rom(1,i)<-2^(-15)
% %         rotar_i_note(1,i*2-1) = ceil(cordic_rom(1,i)*2^15+1);
% %     else
% %         rotar_i_note(1,i*2-1) = round(cordic_rom(1,i)*2^15);
% %     end
%     rotar_i_note(1,i*2-1) = round(cordic_rom(floor((i-1)/(N/p))+1,mod(i-1,N/p)+1));
%     x_bin = dec2bin(rotar_i_note(1,i*2-1),32); %real
%     fprintf(fid,'%s\n',x_bin);
% %     x_bin = dec2bin(rotar_i_note(1,i*2),16); %imag
% %     fprintf(fid,'%s\n',x_bin);
% end
% fclose(fid);



