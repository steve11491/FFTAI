#include <sys/time.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/syscall.h>
#include <sys/socket.h>
#include <sys/mman.h>
#include <poll.h>
#include <stdio.h>
#include <string.h>
#include <bitset>
#include <thread>
#include <mutex>
#include <chrono>
#include <condition_variable>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <fcntl.h>
#include <unistd.h>
#include "file_utils.h"
#include <time.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdint>
#include <math.h>

typedef uint32_t u32;


inline void X_WriteReg(void*add_ptr, int RegOffset, u32 Data) 
{
    *(volatile unsigned long*)(add_ptr+RegOffset) = (u32)Data;
}
  
inline u32 X_ReadReg(void*add_ptr, int RegOffset)
{
    u32 Data;
    Data = *(volatile unsigned long*)(add_ptr+RegOffset);
    return Data;
}



#define XST_FAILURE -1
#define XST_SUCCESS 0


#define AI_ACCE_BASE 0x43C00000
#define imap_axi_R_BASE_ADDR 0x3C000000
#define omap_axi_W_BASE_ADDR 0x3C800000
#define fft_axi_R_BASE imap_axi_R_BASE_ADDR
#define fft_axi_W_BASE omap_axi_W_BASE_ADDR
char is_fft = 1;
char is_int16=1;
char relu_enable=0;
char use_quan_external=0;
char use_bias_external=0;
char bias_mode_external=0;
char concat_dim=0;
//fft config
char fft_config = 0;
char fft_start = 0;
int fft_core_num = 1;
int fft_sign_len = 100;
uint32_t fft_stage = 12;
int fft_data_len = fft_sign_len * 4096;
int fft_mem_size = (fft_sign_len + fft_sign_len%fft_core_num ) * 4096 * sizeof(int16_t);



// reference txt
#define FFT_BASE_PATH "/run/media/mmcblk0p1/"
#define FFT_INPUT_FILE FFT_BASE_PATH "fft_in_rand.txt"

// ????????
int SD_Init();
int SD_Transfer_read(const char *FileName, u32 DestinationAddress, u32 ByteLength);
int SD_Transfer_write(const char *FileName, u32 SourceAddress, u32 ByteLength);

void* ai_ctrl_ptr;
int16_t* fft_in_ptr;
int16_t* fft_out_ptr;
int16_t* fft_result_ptr;

void set_fft_config(void*axilite_base_addr,char is_ifft_mode,uint32_t fft_stage,uint32_t fft_len){
    fft_config = 1;
    fft_start = 0;
    // Set congig flags in slv_reg29 (fft_reg)
    uint32_t slv_reg29 = (fft_config & 0x1) |
                        ((fft_start & 0x1) << 1) |
                        ((is_ifft_mode & 0x1) << 11) |
                        (((fft_stage) & 0xf) << 12) |
                        ((fft_len & 0xffff) << 16);
    X_WriteReg(axilite_base_addr, 29 * 4, slv_reg29);
    if(X_ReadReg(axilite_base_addr, 29*4) == slv_reg29)
        printf("fft config done!\n");
    else
        printf("the acutal reg29 is %x\n", X_ReadReg(axilite_base_addr, 29*4));
}

void set_fft_config_end(void*axilite_base_addr){
    fft_config = 0;
    // Set congig flags in slv_reg29 (fft_reg)
    uint32_t slv_reg29 = X_ReadReg(axilite_base_addr, 29*4);
    slv_reg29 = 0xfffffffe & slv_reg29 ;
    X_WriteReg(axilite_base_addr, 29 * 4, slv_reg29);
    if(X_ReadReg(axilite_base_addr, 29*4) == slv_reg29)
        printf("fft config end!\n");
    else
        printf("the acutal reg29 is %x\n", X_ReadReg(axilite_base_addr, 29*4));
}

void set_fft_init(void*axilite_base_addr)
{
    // Set base addresses
    for(int i=0;i<fft_core_num;i++){
        X_WriteReg(axilite_base_addr, (1+i*2) * 4, fft_axi_R_BASE+fft_mem_size*i/fft_core_num);
        X_WriteReg(axilite_base_addr, (2+i*2) * 4, fft_axi_W_BASE+fft_mem_size*i/fft_core_num);
        if(X_ReadReg(axilite_base_addr, (1+i*2) * 4) != fft_axi_R_BASE+fft_mem_size*i/fft_core_num)
            printf("the actual fft wr addr %d reg:%x\n", i, X_ReadReg(axilite_base_addr, (1+i*2) * 4));
        if(X_ReadReg(axilite_base_addr, (2+i*2) * 4) != fft_axi_W_BASE+fft_mem_size*i/fft_core_num)
            printf("the actual fft wr addr %d reg:%x\n", i, X_ReadReg(axilite_base_addr, (2+i*2) * 4));
    }

    // Set flags in slv_reg9
    uint32_t slv_reg9 = (is_fft & 0x1) |
                        ((is_int16 & 0x1) << 1) |
                        ((relu_enable & 0x1) << 2) |
                        ((use_quan_external & 0x1) << 3) |
                        ((use_bias_external & 0x1) << 4) |
                        ((bias_mode_external & 0x1) << 5) |
                        ((concat_dim & 0x3) << 6);
    X_WriteReg(axilite_base_addr, 9 * 4, slv_reg9);
    if(X_ReadReg(axilite_base_addr, 9*4) == slv_reg9)
        printf("the reg write done!\n");
    else
        printf("the acutal reg9 is %x\n", X_ReadReg(axilite_base_addr, 9*4));

}

int set_fft_start(void*axilite_base_addr){
    fft_config = 0;
    fft_start = 1;
    // Set congig flags in slv_reg29 (fft_reg)
    uint32_t slv_reg29 = X_ReadReg(axilite_base_addr, 29*4);
    slv_reg29 = 0xfffffffe & slv_reg29 ; //set fft_config 0
    slv_reg29 = 0x2 | slv_reg29; //set fft_start 1
    X_WriteReg(axilite_base_addr, 29 * 4, slv_reg29);
    if(X_ReadReg(axilite_base_addr, 29*4) == slv_reg29)
        printf("fft start work!\n");
    else
        printf("fft start faild! the acutal reg29 is %x\n", X_ReadReg(axilite_base_addr, 29*4));
}



int main(int argc,char *argv[]){
    //run mode
    if(argc == 1){
        printf("Normal mode 4096 fft\n\r");
    }else{
        for (int i = 1; i < argc; ++i) {
            if((strcmp(argv[i],"512"))==0){
                fft_stage = 9;
            }else if((strcmp(argv[i],"1024"))==0){
                fft_stage = 10;
            }else if((strcmp(argv[i],"2048"))==0){
                fft_stage = 11;
            }else if((strcmp(argv[i],"4096"))==0){
                fft_stage = 12;
            }else{
                printf("Error mode\n\r");
                return -1;
            }
        }
    }
    int fft_stage_len = 1 << fft_stage;
    printf("FFT run mode %d, fft stage num: %d\n",fft_stage_len,fft_stage);

	//XTime tEnd, tCur;  
	u32 tUsed;
    int devmem;
	int Status;
	u32 RegValue;
    char is_ifft_mode = 0;

    struct timeval start, end;
    u32 axilite_base = AI_ACCE_BASE;

    printf("cin sign len\n");
    scanf("%d", &fft_sign_len);
    fft_data_len = fft_sign_len * fft_stage_len * 2;
    fft_mem_size = (fft_sign_len + fft_sign_len%fft_core_num) * sizeof(int16_t) * fft_stage_len * 2 ;
    printf("sign len = %d  data len = %d  mem size = %d\n",fft_sign_len,fft_data_len,fft_mem_size);

	// mmap
    devmem = open("/dev/mem", O_RDWR | O_SYNC);
    if(devmem==-1){
       printf("open /dev/mem failed\n");
       return -1;
    }

    ai_ctrl_ptr = mmap(0,4096,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,AI_ACCE_BASE); 
    printf("mmap ai_ctrl_ptr end ");
    fft_in_ptr = (int16_t*)mmap(0,fft_mem_size*2,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,fft_axi_R_BASE);
    printf("mmap fft_in_ptr end ");
    fft_out_ptr = (int16_t*)mmap(0,fft_mem_size*2,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,fft_axi_W_BASE);
    printf("mmap fft_out_ptr end ");
    fft_result_ptr = (int16_t*)malloc(fft_mem_size*2);
    printf("malloc fft_result_ptr end ");

    for(int i=0;i<fft_mem_size;i++){
        *(fft_out_ptr+i) = 0;
    }  
    printf("Setting init parameters for fft acce:\n");

    //init system
	set_fft_init(ai_ctrl_ptr);
	printf("Setting init parameters for fft acce done!\n");

	// Read input map
    Status = ReadFile<int16_t>(FFT_INPUT_FILE,fft_in_ptr,fft_data_len);
	if (Status != 0) {
		printf("Failed to read input data!\r\n");
		return XST_FAILURE;
	}

    // for(int i=0;i<12;i++){
    //     printf("the read in data[%d] is %d\n",i,fft_in_ptr[fft_data_len-1-i]);
    // }
    long long fft_ctime;
    float fft_fps;

    //compute FFT
    set_fft_config(ai_ctrl_ptr,is_ifft_mode,fft_stage,fft_sign_len);
    set_fft_config_end(ai_ctrl_ptr);
    

    printf("start compute %d point fft!!!!\n",fft_stage_len);
    set_fft_start(ai_ctrl_ptr);
    gettimeofday(&start, NULL); // get the beginning time
    do {
        RegValue = X_ReadReg(ai_ctrl_ptr, 0);
    
    } while ((RegValue & 0x8) != 0x8);  // waiting the ip compute done
    
    //Get the end time
    gettimeofday(&end, NULL);  // get the end time
    printf("compute %d ponit fft finish!!!!\n",fft_stage_len);
    
    fft_ctime = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_usec - start.tv_usec); // get the run time by microsecond
    printf("fft %d run %d loops total time is %lld us\n", fft_stage_len, fft_sign_len , fft_ctime);
    fft_fps = 1000000 / fft_ctime * fft_sign_len;
    printf("fft %d fps is %.6fk \n", fft_stage_len, fft_fps/1000);

    // Read real result & Write fpga result
    char fft_base_path[] = FFT_BASE_PATH;
    char fft_matlab_result_path[100];
    char fft_fpga_result_path[100];
    sprintf(fft_matlab_result_path,"%sfft_out_%d_matlab.txt",fft_base_path,fft_stage_len);
    sprintf(fft_fpga_result_path,"%sfft_out_%d.txt",fft_base_path,fft_stage_len);
    Status = ReadFile<int16_t>(fft_matlab_result_path,fft_result_ptr,fft_data_len);
	if (Status != 0) {
		printf("Failed to read matlab data!\r\n");
		return XST_FAILURE;
	}
    Status = WriteFile<int16_t>(fft_fpga_result_path,fft_out_ptr,fft_data_len);
	// if (Status != 0) {
	// 	printf("Failed to write fpga result!\r\n");
	// 	return XST_FAILURE;
	// }
    // for(int i=0;i<12;i++){
    //     printf("the fft_matlab_result_path[%d] is %d\n",i,fft_matlab_result_path[i]);
    // }
    // for(int i=0;i<12;i++){
    //     printf("the fft_fpga_result_path[%d] is %d\n",i,fft_fpga_result_path[i]);
    // }

    //compute rmse
    int result_increase = 1 << (15-fft_stage);
    double rmse = 0;
    for(int i=0;i<fft_data_len;i++){
        double deta = double((fft_result_ptr[i]-fft_out_ptr[i]))/result_increase;
        // if(deta-2>0.1){
        //     printf("loop %d deta = %.6f\n",i,deta);
        // }
        rmse += pow(deta,2);
    }
    rmse = sqrt(rmse / fft_data_len);
    rmse = 20*log10(rmse);
    printf("fft %d rmse is %.6f dB \n", fft_stage_len, rmse);

    printf("fft %d compute and analysis finish!!\n\r", fft_stage_len);


    // free(fft_in_ptr);
    // free(fft_out_ptr);


    //cleanup_platform();
    return 0;
}//arm-linux-gnueabihf-g++ main_v2.cpp -o fft_acce

