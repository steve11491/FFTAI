FFT 板级部署包 (ZC706)
========================

文件清单:
  fft_test        — ARM交叉编译的FFT测试程序(静态链接)
  fft_in_rand.txt — 409600采样随机输入流(100帧×4096点)
  fft_i_4096.txt  — 4096点FFT输入(调试用)
  ifft_i_4096.txt — 4096点IFFT输入(调试用)

使用方法:
  1. 将bitstream烧写到ZC706板
  2. 通过SCP/U盘将本目录复制到板上
  3. 板上Linux终端执行:
     chmod +x fft_test
     ./fft_test

寄存器映射(0x43C00000基地址):
  reg9  [0]=is_fft, [1]=is_int16
  reg1  = 核0读基地址 (0x3C000000)
  reg2  = 核0写基地址 (0x3C800000)
  reg29 [0]=config, [1]=start(保持), [12:15]=stage, [16:31]=sign_len, [11]=is_ifft

编译信息:
  工具链: Linaro GCC 7.3.1 (arm-linux-gnueabihf)
  链接方式: -static(静态链接, 无运行时依赖)
  源码: software/fft_software/cpp/main.cpp
