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
#include <math.h>
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
#include "conv_params.h"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdint>
#include "file_op.h"
#include "flops_params.h"

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

#define RESIZE_QUANTIZE_BASE_ADDR 0x40000000
#define AI_ACCE_BASE 0x43C00000

#define bias_axi_R_BASE_ADDR 0x3C000000
#define weight_axi_R_BASE_ADDR 0x3C005000
#define MAP_BASE_ADDR 0x3C700000

// #define bias_axi_R_BASE_ADDR 0x80000000
// #define weight_axi_R_BASE_ADDR 0x80005000
// #define MAP_BASE_ADDR 0x80700000

//
//#define ReferenceOutput_ADDR 0x3ff00000

#define MAX_FILENAME_LENGTH 256

// #define PATH "/run/media/mmcblk0p1/"
// #define IMG_NAME "000021"


// #define REF_INDEX 5





void* ai_ctrl_ptr;
void* resize_ctrl_ptr;
signed char* input_ptr;
signed char* weight_ptr;
int16_t* bias_ptr;
signed char* output_ptr;
signed char* reference_ptr;




typedef struct
{
    bool is_output;
    int input_bytes;
    int weight_bytes;
    int bias_bytes;
    int output_bytes;
    int imap_addr;
    int weight_addr;
    int bias_addr;
    int bias2_addr;
    int omap_addr;
    int in_channels;
    int input_width;
    int input_height;
    int out_channels;
    int output_width;
    int output_height;
    bool is_resize;
    int resize_scale_factor;
    bool is_fft;
    bool is_int16;
    bool relu_enable;
    bool use_quan_external;
    bool use_bias_external;
    bool bias_mode_external;
    bool use_bias2_add_external;
    bool is_pool;
    int pool_type;
    int conv_type;
    int left_padding;
    int right_padding;
    int top_padding;
    int bottom_padding;
    int kernel_height;
    int kernel_width;
    int stride_x;
    int stride_y;
    int dilation_x;
    int dilation_y;
    int zero_point_in;
    int zero_point_out;
    int scale;
    int shift;
    int bias2_scale;
    int bias2_shift;
    int num_oc;
    int num_ic;
    int num_rs;
    int num_ow;
    int num_oh;
    int basic_oc;
    int basic_ic;
    int basic_rs;
    int basic_ow;
    int basic_oh;
    int remain_oc;
    int remain_ic;
    int remain_rs;
    int remain_ow;
    int remain_oh;
    int basic_iw;
    int basic_ih;
    int basic_ow_sx;
    int basic_oh_sy;
    int remain_iw;
    int remain_ih;
    int Aiwih;
    int Aiw;
    int Wicrs;
    int Wic;
    int Aowoh;
    int Aow;
    int conv_add_scale;
    int conv_add_shift;
    int add_output_zero_point;
} LayerParams;

LayerParams layer_params[NUM_LAYERS];


int8_t saturate_int8(int32_t val);
void init_layer_params();
void set_conv_layer_params(void* axilite_base_addr, int layer_index);
void resize_and_quantize(int8_t *input, int8_t *output, LayerParams *params, int new_H, int new_W);
void execute_layer(void*reszie_quantize_base_ptr,void*axilite_base_ptr, int layer_index, long long *execution_time);
void add_and_quantize(int8_t *input, int8_t *output, LayerParams *params, int new_H, int new_W);

// Helper function to saturate values to int8_t range
int8_t saturate_int8(int32_t val)
{
    if (val > 127)
        return 127;
    if (val < -128)
        return -128;
    return (int8_t)val;
}

int8_t saturate_int8_2(int16_t val)
{
    if (val > 127)
        return 127;
    if (val < -128)
        return -128;
    return (int8_t)val;
}

void init_layer_params()
{
    for (int i = 0; i < NUM_LAYERS; i++)
    {
        layer_params[i].is_output = conv_params[i][0] != 0;
        layer_params[i].input_bytes = conv_params[i][1];
        layer_params[i].weight_bytes = conv_params[i][2];
        layer_params[i].bias_bytes = conv_params[i][3];
        layer_params[i].output_bytes = conv_params[i][4];
        layer_params[i].imap_addr = conv_params[i][5];
        layer_params[i].weight_addr = conv_params[i][6];
        layer_params[i].bias_addr = conv_params[i][7];
        layer_params[i].bias2_addr = conv_params[i][8];
        layer_params[i].omap_addr = conv_params[i][9];
        layer_params[i].in_channels = conv_params[i][10];
        layer_params[i].input_width = conv_params[i][11];
        layer_params[i].input_height = conv_params[i][12];
        layer_params[i].out_channels = conv_params[i][13];
        layer_params[i].output_width = conv_params[i][14];
        layer_params[i].output_height = conv_params[i][15];
        layer_params[i].is_resize = conv_params[i][16] != 0;
        layer_params[i].resize_scale_factor = conv_params[i][17];
        layer_params[i].is_fft = conv_params[i][18] != 0;
        layer_params[i].is_int16 = conv_params[i][19] != 0;
        layer_params[i].relu_enable = conv_params[i][20] != 0;
        layer_params[i].use_quan_external = conv_params[i][21] != 0;
        layer_params[i].use_bias_external = conv_params[i][22] != 0;
        layer_params[i].bias_mode_external = conv_params[i][23] != 0;
        layer_params[i].use_bias2_add_external = conv_params[i][24] != 0;
        layer_params[i].is_pool = conv_params[i][25] != 0;
        layer_params[i].pool_type = conv_params[i][26];
        layer_params[i].conv_type = conv_params[i][27];
        layer_params[i].left_padding = conv_params[i][28];
        layer_params[i].right_padding = conv_params[i][29];
        layer_params[i].top_padding = conv_params[i][30];
        layer_params[i].bottom_padding = conv_params[i][31];
        layer_params[i].kernel_height = conv_params[i][32];
        layer_params[i].kernel_width = conv_params[i][33];
        layer_params[i].stride_x = conv_params[i][34];
        layer_params[i].stride_y = conv_params[i][35];
        layer_params[i].dilation_x = conv_params[i][36];
        layer_params[i].dilation_y = conv_params[i][37];
        layer_params[i].zero_point_in = conv_params[i][38];
        layer_params[i].zero_point_out = conv_params[i][39];
        layer_params[i].scale = conv_params[i][40];
        layer_params[i].shift = conv_params[i][41];
        layer_params[i].bias2_scale = conv_params[i][42];
        layer_params[i].bias2_shift = conv_params[i][43];
        layer_params[i].num_oc = conv_params[i][44];
        layer_params[i].num_ic = conv_params[i][45];
        layer_params[i].num_rs = conv_params[i][46];
        layer_params[i].num_ow = conv_params[i][47];
        layer_params[i].num_oh = conv_params[i][48];
        layer_params[i].basic_oc = conv_params[i][49];
        layer_params[i].basic_ic = conv_params[i][50];
        layer_params[i].basic_rs = conv_params[i][51];
        layer_params[i].basic_ow = conv_params[i][52];
        layer_params[i].basic_oh = conv_params[i][53];
        layer_params[i].remain_oc = conv_params[i][54];
        layer_params[i].remain_ic = conv_params[i][55];
        layer_params[i].remain_rs = conv_params[i][56];
        layer_params[i].remain_ow = conv_params[i][57];
        layer_params[i].remain_oh = conv_params[i][58];
        layer_params[i].basic_iw = conv_params[i][59];
        layer_params[i].basic_ih = conv_params[i][60];
        layer_params[i].basic_ow_sx = conv_params[i][61];
        layer_params[i].basic_oh_sy = conv_params[i][62];
        layer_params[i].remain_iw = conv_params[i][63];
        layer_params[i].remain_ih = conv_params[i][64];
        layer_params[i].Aiwih = conv_params[i][65];
        layer_params[i].Aiw = conv_params[i][66];
        layer_params[i].Wicrs = conv_params[i][67];
        layer_params[i].Wic = conv_params[i][68];
        layer_params[i].Aowoh = conv_params[i][69];
        layer_params[i].Aow = conv_params[i][70];
        layer_params[i].conv_add_scale = conv_params[i][71];
        layer_params[i].conv_add_shift = conv_params[i][72];
        layer_params[i].add_output_zero_point = conv_params[i][73];
    }
}

void set_conv_layer_params(void* axilite_base_addr, int layer_index)
{
    LayerParams *params = &layer_params[layer_index];

    // Set base addresses
    X_WriteReg(axilite_base_addr, 1 * 4, MAP_BASE_ADDR + params->imap_addr);
    X_WriteReg(axilite_base_addr, 3 * 4, weight_axi_R_BASE_ADDR + params->weight_addr);
    X_WriteReg(axilite_base_addr, 7 * 4, bias_axi_R_BASE_ADDR + params->bias_addr);
    X_WriteReg(axilite_base_addr, 5 * 4, MAP_BASE_ADDR + params->bias2_addr);
    X_WriteReg(axilite_base_addr, 8 * 4, MAP_BASE_ADDR + params->omap_addr);

    // Set flags in slv_reg9
    uint32_t slv_reg9 = (params->is_fft ? 0x1 : 0) |
                        ((params->is_int16 ? 0x1 : 0) << 1) |
                        ((params->relu_enable ? 0x1 : 0) << 2) |
                        ((params->use_quan_external ? 0x1 : 0) << 3) |
                        ((params->use_bias_external ? 0x1 : 0) << 4) |
                        ((params->bias_mode_external ? 0x1 : 0) << 5) |
                        ((params->use_bias2_add_external ? 0x1 : 0) << 6) |
                        ((params->is_pool ? 0x1 : 0) << 7) |
                        ((params->pool_type & 0x1) << 8) |
                        ((params->conv_type & 0x3) << 9);
    X_WriteReg(axilite_base_addr, 9 * 4, slv_reg9);

    // Set padding
    uint32_t slv_reg10 = (params->right_padding & 0xFF) |
                         ((params->left_padding & 0xFF) << 8) |
                         ((params->bottom_padding & 0xFF) << 16) |
                         ((params->top_padding & 0xFF) << 24);

    X_WriteReg(axilite_base_addr, 10 * 4, slv_reg10);

    // Set kernel size, stride, and dilation
    uint32_t slv_reg11 = ((params->kernel_height - 1) & 0xFF) |
                         (((params->kernel_width - 1) & 0xFF) << 8) |
                         ((params->stride_x & 0xFF) << 16) |
                         ((params->stride_y & 0xFF) << 24);

    X_WriteReg(axilite_base_addr, 11 * 4, slv_reg11);

    uint32_t slv_reg12 = (params->dilation_x & 0xFF) |
                         ((params->dilation_y & 0xFF) << 8);
    X_WriteReg(axilite_base_addr, 12 * 4, slv_reg12);

    // Set zero points and scale
    uint32_t slv_reg13 = (params->zero_point_in & 0xFFFF) |
                         ((params->zero_point_out & 0xFFFF) << 16);
    X_WriteReg(axilite_base_addr, 13 * 4, slv_reg13);

    uint32_t slv_reg14 = (params->scale & 0xFFFF) |
                         ((params->shift & 0xFF) << 16);
    X_WriteReg(axilite_base_addr, 14 * 4, slv_reg14);

    // Set bias2 scale and shift
    uint32_t slv_reg15 = (params->bias2_scale & 0xFFFF) |
                         ((params->bias2_shift & 0xFF) << 16);
    X_WriteReg(axilite_base_addr, 15 * 4, slv_reg15);

    // Set num_oc, num_ic, num_rs, num_ow
    uint32_t slv_reg16 = ((params->num_oc - 1) & 0xFF) |
                         (((params->num_ic - 1) & 0xFF) << 8) |
                         (((params->num_rs - 1) & 0xFF) << 16) |
                         (((params->num_ow - 1) & 0xFF) << 24);
    X_WriteReg(axilite_base_addr, 16 * 4, slv_reg16);

    // Set num_oh, basic_oc, basic_ic, basic_rs
    uint32_t slv_reg17 = ((params->num_oh - 1) & 0xFF) |
                         (((params->basic_oc - 1) & 0xFF) << 8) |
                         (((params->basic_ic - 1) & 0xFF) << 16) |
                         (((params->basic_rs - 1) & 0xFF) << 24);
    X_WriteReg(axilite_base_addr, 17 * 4, slv_reg17);

    // Set basic_ow, basic_oh, remain_oc, remain_ic
    uint32_t slv_reg18 = ((params->basic_ow - 1) & 0xFF) |
                         (((params->basic_oh - 1) & 0xFF) << 8) |
                         (((params->remain_oc - 1) & 0xFF) << 16) |
                         (((params->remain_ic - 1) & 0xFF) << 24);
    X_WriteReg(axilite_base_addr, 18 * 4, slv_reg18);

    // Set remain_rs, remain_ow, remain_oh
    uint32_t slv_reg19 = ((params->remain_rs - 1) & 0xFF) |
                         (((params->remain_ow - 1) & 0xFF) << 8) |
                         (((params->remain_oh - 1) & 0xFF) << 16);
    X_WriteReg(axilite_base_addr, 19 * 4, slv_reg19);

    // Set basic_iw, basic_ih
    uint32_t slv_reg20 = ((params->basic_iw - 1) & 0xFFFF) |
                         (((params->basic_ih - 1) & 0xFFFF) << 16);
    X_WriteReg(axilite_base_addr, 20 * 4, slv_reg20);

    // Set basic_ow_sx, basic_oh_sy
    uint32_t slv_reg21 = ((params->basic_ow_sx - 1) & 0xFFFF) |
                         (((params->basic_oh_sy - 1) & 0xFFFF) << 16);
    X_WriteReg(axilite_base_addr, 21 * 4, slv_reg21);

    // Set remain_iw, remain_ih
    uint32_t slv_reg22 = ((params->remain_iw - 1) & 0xFFFF) |
                         (((params->remain_ih - 1) & 0xFFFF) << 16);
    X_WriteReg(axilite_base_addr, 22 * 4, slv_reg22);

    // Set Aiwih, Aiw, Wicrs, Wic, Aowoh, Aow
    X_WriteReg(axilite_base_addr, 23 * 4, params->Aiwih);
    X_WriteReg(axilite_base_addr, 24 * 4, params->Aiw);
    X_WriteReg(axilite_base_addr, 25 * 4, params->Wicrs);
    X_WriteReg(axilite_base_addr, 26 * 4, params->Wic);
    X_WriteReg(axilite_base_addr, 27 * 4, params->Aowoh);
    X_WriteReg(axilite_base_addr, 28 * 4, params->Aow);
}

#define C0 32


void resize_quantize_hls_software(
        int8_t* input,
        int8_t* output,
        int in_H,
        int in_W,
        int new_H,
        int new_W,
        int C,
        int16_t scale,
        int8_t shift,
        int8_t zero_point)
{

    int8_t shift_add = shift+15;
    int32_t shift_value1 = (1<<(shift_add-1));
    int c1 = (C + C0 - 1) >> 5;
    int size0 = C0 * in_H * in_W;
    int size_out =  C0 * new_H * new_W;
    int remain_c0 = (C & 31) ? (C & 31) : C0;

    for (int c1_idx = 0; c1_idx < c1; c1_idx++) {

        int c0_len = (c1_idx == (c1 - 1)) ? remain_c0 : C0;
        int base_in_idx = c1_idx * size0;
        int base_out_idx = c1_idx * size_out;

        for (int h = 0; h < new_H; h++) {

            for (int w = 0; w < new_W; w++) {

                int src_h =  (h >> 1);
                int src_w =  (w >> 1);
                int in_offset = (src_h * in_W + src_w) * c0_len;
                int out_offset = (h * new_W + w) * c0_len;

                for (int c0_idx = 0; c0_idx < c0_len; c0_idx++) {

                    int in_idx = base_in_idx + in_offset + c0_idx;
                    int out_idx = base_out_idx + out_offset + c0_idx;

                    int8_t value1 = input[in_idx];

                    int32_t rounded1;

                    rounded1 = value1 * scale;

                    rounded1 = (rounded1 + shift_value1) >>(shift_add);

                    rounded1 += zero_point;
                    output[out_idx] = saturate_int8(rounded1);
                }
            }
        }
    }
}




void execute_layer(void*reszie_quantize_base_ptr,void*axilite_base_ptr, int layer_index, long long *execution_time)
{
    LayerParams *params = &layer_params[layer_index];

    if (params->is_resize)
    {
//    	xil_printf("run software!\n");



        //int8_t *input = (map + params->imap_addr);
        //int8_t *output = (map + params->omap_addr);
        int32_t input_addr=MAP_BASE_ADDR + params->imap_addr;
        int32_t output_addr=MAP_BASE_ADDR + params->omap_addr;

        int new_H = params->input_height * params->resize_scale_factor;
        int new_W = params->input_width * params->resize_scale_factor;


        //
        X_WriteReg(reszie_quantize_base_ptr, 0x10, input_addr);
        X_WriteReg(reszie_quantize_base_ptr, 0x18, output_addr);

        //
        X_WriteReg(reszie_quantize_base_ptr, 0x20, params->input_height);
        X_WriteReg(reszie_quantize_base_ptr, 0x28, params->input_width);
        X_WriteReg(reszie_quantize_base_ptr, 0x30, new_H);
        X_WriteReg(reszie_quantize_base_ptr, 0x38, new_W);
        X_WriteReg(reszie_quantize_base_ptr, 0x40, params->out_channels);
        X_WriteReg(reszie_quantize_base_ptr, 0x48, params->scale);
        X_WriteReg(reszie_quantize_base_ptr, 0x50, params->shift);
        X_WriteReg(reszie_quantize_base_ptr, 0x58, params->zero_point_out);

        //
        X_WriteReg(reszie_quantize_base_ptr, 0x00, 0x1);  //

        //XTime tStart, tEnd;
        struct timeval start, end;
        //XTime_GetTime(&tStart);
        gettimeofday(&start, NULL); // get the beginning time
        //
        while ((X_ReadReg(reszie_quantize_base_ptr, 0x00) & 0x2) == 0) {
            //
        }
        X_WriteReg(reszie_quantize_base_ptr, 0x00, 0x00);

        //XTime_GetTime(&tEnd);
        gettimeofday(&end, NULL);  // get the end time
        *execution_time = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_usec - start.tv_usec); // get the run time by microsecond
        //printf("time elapsed is %d us\r\n",tUsed);
        //printf("total time is %lld us\n", total_time);
        //*execution_time = tEnd - tStart;
    }
    else
    {
        uintptr_t axilite_base = AI_ACCE_BASE;
//        xil_printf("run hardware!\n");
//        xil_printf("set_conv_layer_params start!\n");
        set_conv_layer_params(axilite_base_ptr, layer_index);
//        xil_printf("set_conv_layer_params done!\n");
        //XTime tStart, tEnd;
        //XTime_GetTime(&tStart);
        struct timeval start, end;
        gettimeofday(&start, NULL); // get the beginning time

        X_WriteReg(axilite_base_ptr, 0, 0x1);

        while ((X_ReadReg(axilite_base_ptr, 0) & 0x2) == 0x2)
            ;


        //XTime_GetTime(&tEnd);
        gettimeofday(&end, NULL);  // get the end time
        *execution_time = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_usec - start.tv_usec); // get the run time by microsecond
        //*execution_time = tEnd - tStart;
//        xil_printf("cal done!\n");



    }
}

// Other functions (saturate_int8, load_file, save_file) remain the same

int main(int argc, char *argv[])
{
    //init_platform();
    //Xil_DCacheDisable();
    //Xil_ICacheDisable();

    char *PATH;
    char *IMG_NAME;
    int REF_INDEX;

    if (argc < 4) {
        printf("Usage: %s <PATH> <IMG_NAME> <REF_INDEX>\n", argv[0]);
        return 1;
    }
    

    PATH = argv[1];
    IMG_NAME = argv[2];
    REF_INDEX = atoi(argv[3]);

    printf("PATH: %s\n", PATH);
    printf("IMG_NAME: %s\n", IMG_NAME);
    char INPUT_FILE[MAX_FILENAME_LENGTH];
    char WEIGHT_FILE[MAX_FILENAME_LENGTH];
    char BIAS_FILE[MAX_FILENAME_LENGTH];
    char OUTPUT_REF_FILE[MAX_FILENAME_LENGTH];
    snprintf(INPUT_FILE, MAX_FILENAME_LENGTH, "%s%s_input_tensor_nc1hwc0_int8.bin", PATH,IMG_NAME);
    snprintf(WEIGHT_FILE, MAX_FILENAME_LENGTH, "%sweight_nc1hwc0_all_int8.bin", PATH);
    snprintf(BIAS_FILE, MAX_FILENAME_LENGTH, "%sbias_nc1hwc0_all_int16.bin", PATH);
    snprintf(OUTPUT_REF_FILE, MAX_FILENAME_LENGTH, "%slayer_output_nc1hwc0_%d.bin", PATH,REF_INDEX);
    printf("INPUT_FILE: %s\n", INPUT_FILE); 
    printf("WEIGHT_FILE: %s\n", WEIGHT_FILE); 
    printf("BIAS_FILE: %s\n", BIAS_FILE); 



    int devmem;
    int Status;

    init_layer_params(); // Initialize the layer_params array

    // addr mmap
    devmem = open("/dev/mem", O_RDWR | O_SYNC);
    if(devmem==-1){
        printf("open /dev/mem failed");
        //check_ddr = false;
    }else{
        //check_ddr = true;
    }
    printf("start mmap\n");
    ai_ctrl_ptr = mmap(0,4096,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,AI_ACCE_BASE);
    resize_ctrl_ptr = mmap(0,4096,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,RESIZE_QUANTIZE_BASE_ADDR);
    input_ptr = (signed char*)mmap(0,MAP_SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,MAP_BASE_ADDR);
    weight_ptr = (signed char*)mmap(0,WEIGHT_SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,weight_axi_R_BASE_ADDR);
    bias_ptr = (int16_t*)mmap(0,BIAS_SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,bias_axi_R_BASE_ADDR);
    //output_ptr = (signed char*)mmap(0,layer_params[REF_INDEX].output_bytes,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,MAP_BASE_ADDR+layer_params[REF_INDEX].omap_addr);
    //reference_ptr = (signed char*)mmap(0,layer_params[REF_INDEX].output_bytes,PROT_READ|PROT_WRITE,MAP_SHARED,devmem,ReferenceOutput_ADDR);
    printf("end mmap\n");
    reference_ptr = (signed char *)malloc(layer_params[REF_INDEX].output_bytes);

    //
    Status = load_file(INPUT_FILE,input_ptr,layer_params[0].input_bytes);
    if (Status != 0) {
        printf("Failed to read input data from SD card!\r\n");
        return XST_FAILURE;
    } else {
        printf("SD_Transfer_read INPUT_FILE done!\n");

    }

//	for(int i=0; i < 15;i++)
//	    printf("the read imap data:%d\n", input_ptr[INPUT_SIZE-1-i]);

    // read weight

    Status = load_file(WEIGHT_FILE,weight_ptr,WEIGHT_SIZE);
    if (Status != 0) {
        printf("Failed to read weight data from SD card!\r\n");
        return XST_FAILURE;
    }else {
        printf("SD_Transfer_read WEIGHT_FILE done!\n");

    }

//    for(int i=0; i < 15;i++)
//        printf("the read weight data:%d\n", weight_ptr[i]);
    // read bias

    Status = load_file(BIAS_FILE,bias_ptr,BIAS_SIZE);
    if (Status != 0) {
        printf("Failed to read bias data from SD card!\r\n");
        return XST_FAILURE;
    }else {
        printf("SD_Transfer_read BIAS_FILE done!\n");

    }
//	xil_printf("start cal!!!!\r\n");

    uint32_t total_time_hardware = 0;
    long long total_time_all = 0;

    for (int i = 0; i < NUM_LAYERS; i++)
    {
        long long layer_time;

//        if(i==51 || i==58 || i==64){
//        	continue;
//        }
        execute_layer(resize_ctrl_ptr,ai_ctrl_ptr,i, &layer_time);


        //uint32_t tUsed = (layer_time * 1000000) / (COUNTS_PER_SECOND);

        total_time_all = total_time_all + layer_time;
        LayerParams *params = &layer_params[i];
        if (params->is_resize){
//        	xil_printf("curr_layer is resize ====== time elapsed for layer %d is %d us\r\n", i,tUsed);
            printf("curr_layer is resize ====== time elapsed for layer %d is %d us \r\n",i, layer_time);
        } else{
            total_time_hardware += layer_time;
            float curr_flops = flops_params[i];
            float curr_Performance = (float)(curr_flops/layer_time)*1000000.0;
            printf("Time elapsed for layer %d is %d us, Curr Flops: %f G , Performance: %f GOPs\r\n",i, (int)layer_time,curr_flops,curr_Performance);
        }

    }
    printf("Total hardware execution time: %d us \r\n", total_time_hardware);

    Status = load_file(OUTPUT_REF_FILE,reference_ptr,layer_params[REF_INDEX].output_bytes);
    if (Status != 0) {
        printf("Failed to read reference output from SD card!\r\n");

        return XST_FAILURE;
    }


    //
    if (strcmp(IMG_NAME, "000021") == 0) {
        int8_t *ComputedOutput = (int8_t *)(input_ptr + layer_params[REF_INDEX].omap_addr);
        //int8_t *REFOutput = (int8_t *)OMAP_REF_BASE_ADDR;
        int Mismatches = 0;
        for (int i = 0; i < layer_params[REF_INDEX].output_bytes; i++) {
            if (ComputedOutput[i] != reference_ptr[i]) {

                Mismatches++;
                if(Mismatches<100){
                    printf("ComputedOutput[%d] is %d ,REFOutput[%d] is %d\n",i,ComputedOutput[i],i,reference_ptr[i]);
                }

            }
        }
        printf("Comparison completed. Mismatches: %d out of %d\r\n", Mismatches, layer_params[REF_INDEX].output_bytes);
    }

    for (int i = 0; i < NUM_LAYERS; i++)
    {
//            if (layer_params[i].is_output)
        {
            char filename[MAX_FILENAME_LENGTH];
            snprintf(filename, MAX_FILENAME_LENGTH, "%s%s_output_layer_%d.bin", PATH,IMG_NAME, i);

            if (save_file(filename,input_ptr + layer_params[i].omap_addr,layer_params[i].output_bytes)!= XST_SUCCESS )
//                if (save_file(filename, , layer_params[i].output_bytes) != FILE_OP_SUCCESS)
            {
                printf("Failed to save output for layer %d\r\n", i);
                return -1;
            } else {
                printf("Success to save output for layer %d\r\n", i);
            }
        }
    }



    free(reference_ptr);


    //cleanup_platform();
    return 0;
}
