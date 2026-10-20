import torch.nn as nn
import torch
import numpy as np
import math
import os
import cv2
from torch.nn import functional as F
from utils import *

np.random.seed(0)
model_src_path = "D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\conv_data\\yolov5_whole\\infer_output\\"

path = "D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\conv_data\\model_data_export_signed\\model1_conv\\"

###########################conv1########################################
input_tensor_golden_int8 = np.load(
    model_src_path + "input.1_QuantizeLinear_Output.npy").astype(float)
bias_golden_int8 = np.load(
    model_src_path + "model.model.0.conv.bias_quantized.npy").astype(float)
kernel_golden_int8 = np.load(
    model_src_path + "model.model.0.conv.weight_quantized.npy").astype(float)
output_quan_golden_int8 = np.load(
    model_src_path + "_model_model.0_act_Relu_output_0_QuantizeLinear_Output.npy").astype(float)

Scale_weight = 0.11180746555328369
Scale_input = 0.003921568859368563
Scale_output = 0.28952258825302124

print("input_tensor_golden.shape:", input_tensor_golden_int8.shape)
print("kernel_golden.shape:", kernel_golden_int8.shape)
batch_size, in_channels, input_height, input_width = input_tensor_golden_int8.shape
out_channels, _, kernel_height, kernel_width = kernel_golden_int8.shape
input_tensor_golden_reshape = input_tensor_golden_int8.reshape(
    in_channels, input_height, input_width)
bias_golden_reshape = bias_golden_int8.reshape(out_channels, 1, 1)

padding = (2, 2)
stride = (2, 2)
dilation = (1, 1)

zero_point_in = -128
zero_point_out = -128

input_tensor_pt_int8 = torch.tensor((input_tensor_golden_int8 - zero_point_in))
kernel_pt_int8 = torch.tensor(kernel_golden_int8)
bias_pt_int8 = torch.tensor(bias_golden_int8)
output_pt_int8 = F.conv2d(input_tensor_pt_int8, kernel_pt_int8, bias_pt_int8, dilation=dilation, stride=stride,
                          padding=padding)
output_pt_int8 = output_pt_int8.detach().numpy()
output_pt_relu_int8 = output_pt_int8

scale_fp32 = Scale_input * Scale_weight / Scale_output
scale_int8, shift_int8 = frexp_int16(scale_fp32)
output_pt_quan_round_int8 = round_func(
    output_pt_relu_int8 * scale_int8 * (2 ** (-15 - shift_int8)))
output_pt_quan_int8 = relu_func(output_pt_quan_round_int8) + zero_point_out

output_diff_int8 = output_pt_quan_int8 - output_quan_golden_int8
print('output_diff_int8:', np.max(np.abs(output_diff_int8)))
print('1 done')

############################conv2#######################################

# input_tensor_golden_int8 = np.load(
#     model_src_path + "_model_model.0_act_Relu_output_0_QuantizeLinear_Output.npy").astype(float)
input_tensor_golden_int8 = output_pt_quan_int8

bias_golden_int8 = np.load(
    model_src_path + "model.model.1.conv.bias_quantized.npy").astype(float)
kernel_golden_int8 = np.load(
    model_src_path + "model.model.1.conv.weight_quantized.npy").astype(float)
output_quan_golden_int8 = np.load(
    model_src_path + "_model_model.1_act_Relu_output_0_QuantizeLinear_Output.npy").astype(float)

Scale_weight = 0.01198944915086031
Scale_input = 0.28952258825302124
Scale_output = 0.5187371969223022
zero_point_in = -128
zero_point_out = -128

print("input_tensor_golden.shape:", input_tensor_golden_int8.shape)
print("kernel_golden.shape:", kernel_golden_int8.shape)
_, in_channels, input_height, input_width = input_tensor_golden_int8.shape
out_channels, _, kernel_height, kernel_width = kernel_golden_int8.shape

padding = (1, 1)
stride = (2, 2)
dilation = (1, 1)

input_tensor_pt_int8 = torch.tensor((input_tensor_golden_int8.astype(float) - zero_point_in))
kernel_pt_int8 = torch.tensor(kernel_golden_int8)
bias_pt_int8 = torch.tensor(bias_golden_int8)
output_pt_int8 = F.conv2d(input_tensor_pt_int8, kernel_pt_int8, bias_pt_int8, dilation=dilation, stride=stride,
                          padding=padding)
output_pt_int8 = output_pt_int8.detach().numpy()
output_pt_relu_int8 = output_pt_int8

scale_fp32 = Scale_input * Scale_weight / Scale_output
scale_int8, shift_int8 = frexp_int16(scale_fp32)

bias2_scale_fp32_int8 = 0.49
bias2_scale_int8, bias2_shift_int8 = frexp_int8(bias2_scale_fp32_int8)
bias2_scale_int16, bias2_shift_int16 = frexp_int16(bias2_scale_fp32_int8)
print('bias2_scale_int8, bias2_shift_int8:',
      bias2_scale_int8, bias2_shift_int8)
print('bias2_scale_int16, bias2_shift_int16:',
      bias2_scale_int16, bias2_shift_int16)

output_pt_quan_round_int8 = round_func(
    output_pt_relu_int8 * scale_int8 * (2 ** (-15 - shift_int8)))
# output_pt_quan_round_int8 = round_func(
#     output_pt_relu_int8 * scale_fp32)
output_pt_quan_int8 = relu_func(output_pt_quan_round_int8) + zero_point_out

output_diff_int8 = output_pt_quan_int8 - output_quan_golden_int8
print('output_diff_int8:', np.max(np.abs(output_diff_int8)))
print('2 done')
output_width = (input_width + 2 *
                padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
output_height = (input_height + 2 *
                 padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1

bus_width = 64

block_ic = 16
block_oc = 16
basic_ow = 10
basic_oh = 10
basic_ic = 32
basic_oc = 64
basic_rs = 9
bias_mode = 0
use_bias = 1
bias_mode = 0
use_relu = 1
use_bias2_add = 0
is_pool = 0
# pool_type = "avgpool"
pool_type = "maxpool"
# conv_type = "dwc"
conv_type = "stc"

ic_factor = (bus_width / 8)
oc_factor = (bus_width / 8)
ceil_in_channels = int(math.ceil(in_channels / ic_factor) * ic_factor)
ceil_feature_map = np.zeros(
    (ceil_in_channels, input_height, input_width))
ceil_feature_map[0:in_channels, :, :] = input_tensor_golden_int8.reshape(
    in_channels, input_height, input_width)

ceil_out_channels = int(math.ceil(out_channels / oc_factor) * oc_factor)
ceil_kernel = np.zeros(
    (ceil_out_channels, ceil_in_channels, kernel_height, kernel_width))
ceil_kernel[0:out_channels, 0:in_channels, :, :] = kernel_golden_int8

ceil_bias = np.zeros((ceil_out_channels, 1, 1))
ceil_bias[0:out_channels, :, :] = bias_golden_int8.reshape(out_channels, 1, 1)

ceil_output_pt_quan_round_int8 = np.zeros(
    (ceil_out_channels, output_height, output_width))
ceil_output_pt_quan_round_int8[0:out_channels, :, :] = output_pt_quan_round_int8.reshape(out_channels, output_height,
                                                                                         output_width)
in_channels = ceil_in_channels
out_channels = ceil_out_channels
bias2 = np.zeros((out_channels, output_height, output_width))
print('input_width:', input_width)
print('input_height:', input_height)
print('output_width:', output_width)
print('output_height:', output_height)

num_ow = math.ceil(output_width / basic_ow)
num_oh = math.ceil(output_height / basic_oh)
num_oc = math.ceil(out_channels / basic_oc)
num_ic = math.ceil(in_channels / basic_ic)
num_rs = math.ceil(kernel_height * kernel_width / basic_rs)

basic_iw = (basic_ow - 1) * stride[1] + (kernel_width - 1) * dilation[1] + 1
basic_ih = (basic_oh - 1) * stride[0] + (kernel_height - 1) * dilation[0] + 1

basic_ow_sx = (basic_ow) * stride[1]
basic_oh_sy = (basic_oh) * stride[0]

remain_ow = basic_ow if output_width % basic_ow == 0 else output_width % basic_ow
remain_oh = basic_oh if output_height % basic_oh == 0 else output_height % basic_oh
remain_oc = basic_oc if out_channels % basic_oc == 0 else out_channels % basic_oc
remain_ic = basic_ic if in_channels % basic_ic == 0 else in_channels % basic_ic
remain_rs = basic_rs if (
                                kernel_height * kernel_width) % basic_rs == 0 else (
                                                                                           kernel_height * kernel_width) % basic_rs

remain_ih = (input_height + padding[0] * 2) - basic_oh_sy * (num_oh - 1)
remain_iw = (input_width + padding[1] * 2) - basic_ow_sx * (num_ow - 1)
if not is_pool:
    if conv_type == "stc":
        assert remain_ow * remain_oh >= block_ic
    elif conv_type == "dwc":
        assert remain_ow * remain_oh >= 3
assert block_ic == block_oc

print('basic_iw:', basic_iw)
print('basic_ih:', basic_ih)
print('basic_ow_sx:', basic_ow_sx)
print('basic_oh_sy:', basic_oh_sy)
print('remain_ih:', remain_ih)
print('remain_iw:', remain_iw)

print('    parameter In_channels = {};'.format(in_channels))
print('    parameter Input_height = {};'.format(input_height))
print('    parameter Input_width = {};'.format(input_width))
print('    parameter Out_channels = {};'.format(out_channels))
print('    parameter Kernel_height = {};'.format(kernel_height))
print('    parameter Kernel_width = {};'.format(kernel_width))
print('    parameter Padding_x = {};'.format(padding[1]))
print('    parameter Padding_y = {};'.format(padding[0]))
print('    parameter Stride_x = {};'.format(stride[1]))
print('    parameter Stride_y = {};'.format(stride[0]))
print('    parameter Dilation_x = {};'.format(dilation[1]))
print('    parameter Dilation_y = {};'.format(dilation[0]))
print('    parameter Basic_ow = {};'.format(basic_ow))
print('    parameter Basic_oh = {};'.format(basic_oh))
print('    parameter Basic_ic = {};'.format(basic_ic))
print('    parameter Basic_oc = {};'.format(basic_oc))
print('    parameter Basic_rs = {};'.format(basic_rs))
print('    parameter USE_BIAS = {};'.format(use_bias))
print('    parameter LOAD_BIAS_MODE = {};'.format(bias_mode))
print('    parameter USE_RELU = {};'.format(use_relu))
print('    parameter USE_BIAS2_ADD = {};'.format(use_bias2_add))
print('    parameter IS_POOL = {};'.format(is_pool))
if pool_type == "maxpool":
    print('    parameter POOL_TYPE = MAX_POOL;')
else:
    print('    parameter POOL_TYPE = AVG_POOL;')
if conv_type == "stc":
    print('    parameter CONV_TYPE = STC;')
elif conv_type == "dwc":
    print('    parameter CONV_TYPE = DWC;')
print('    parameter Scale_int8 = {};'.format(scale_int8))
print('    parameter Shift_int8 = {};'.format(shift_int8))
print('    parameter ZERO_POINT_IN = {};'.format(zero_point_in))
print('    parameter ZERO_POINT_OUT = {};'.format(zero_point_out))

assert (basic_ow_sx * (num_ow - 1) + remain_iw) == (
        input_width + padding[1] * 2), "(basic_ow_sx*(num_ow-1)+remain_iw)  == input_width+left_padding+right_padding"
assert (basic_oh_sy * (num_oh - 1) + remain_ih) == (
        input_height + padding[0] * 2), "(basic_oh_sy*(num_oh-1)+remain_ih)  == input_height+top_padding+bottom_padding"
imap_depth = 2 ** 11
weight_depth = 2 ** 11
omap_depth = 2 ** 11
fifo_depth = 2 ** 10
# case for int8
for _ in range(1):
    assert in_channels % (
            bus_width / 8) == 0, "in_channels must be divisible by bus_width/8"
    assert out_channels % (
            bus_width / 8) == 0, "out_channels must be divisible by bus_width/8"

    assert basic_ic % (
            bus_width / 8) == 0, "basic_ic must be divisible by bus_width/8"
    assert basic_oc % (
            bus_width / 8) == 0, "basic_oc must be divisible by bus_width/8"
    assert basic_iw * basic_ih * \
           math.ceil(basic_ic / (block_ic * 2)) < imap_depth
    assert basic_ow * basic_oh * \
           math.ceil(basic_oc / (block_oc * 2)) < omap_depth
    if conv_type == "stc":
        assert basic_rs * basic_ic * \
               math.ceil(basic_oc / (block_oc * 2)) < weight_depth
    elif conv_type == "dwc":
        assert basic_rs * 1 * \
               math.ceil(basic_oc / (block_oc * 2)) < weight_depth
    assert basic_ow * basic_oh < fifo_depth

    assert (basic_ic % (block_ic * 2) == 0 or basic_ic == in_channels)
    assert (basic_oc % (block_oc * 2) == 0 or basic_oc == out_channels)

    input_tensor = ceil_feature_map
    kernel = ceil_kernel
    bias = ceil_bias
    # input_tensor.transpose(1, 2, 0).astype(np.int8).tofile(
    #     path + "model0_conv_input_tensor_int8.bin")
    # kernel.transpose(2, 3, 1, 0).astype(np.int8).tofile(
    #     path + "model0_conv_kernel_int8.bin")
    # bias.transpose(1, 2, 0).astype(np.int16).tofile(
    #     path + "model0_conv_bias_int16.bin")

    if is_pool:
        output = pool_total(input_tensor=input_tensor, bias2=(round_func(bias2 * bias2_scale_int8 *
                                                                         (2 ** (-7 - bias2_shift_int8)))),
                            padding=padding, stride=stride, dilation=dilation, kernel_height=kernel_height,
                            kernel_width=kernel_width, pool_type=pool_type,
                            basic_ow=basic_ow,
                            basic_oh=basic_oh,
                            basic_oc=basic_oc,
                            block_ic=block_ic,
                            block_oc=block_oc * 2,
                            scale=scale_int8,
                            shift=shift_int8,
                            zero_point=0,
                            is_int16=0,
                            use_relu=use_relu,
                            savefile=1, path=path, name="_int8")

    else:
        output, max_acc_value = conv_total(input_tensor=input_tensor - zero_point_in, kernel=kernel, bias=bias,
                                           bias2=(round_func(bias2 * bias2_scale_int8 *
                                                             (2 ** (-7 - bias2_shift_int8)))),
                                           padding=padding, stride=stride, dilation=dilation,
                                           basic_ow=basic_ow,
                                           basic_oh=basic_oh,
                                           basic_ic=basic_ic,
                                           basic_oc=basic_oc,
                                           basic_rs=basic_rs,
                                           block_ic=block_ic,
                                           block_oc=block_oc * 2,
                                           scale=scale_int8,
                                           shift=shift_int8,
                                           zero_point=zero_point_out,
                                           is_int16=0,
                                           bias_mode=bias_mode,
                                           use_relu=use_relu,
                                           conv_type=conv_type,
                                           savefile=1, path=path, name="_int8")
        print('max_acc_value int8:', max_acc_value)
        print('max_acc_value int8 bit:', math.ceil(math.log2(max_acc_value)) + 1)

    quan_output = (round_func(output * scale_int8 *
                              (2 ** (-15 - shift_int8))))

    if use_relu:
        quan_relu_output = relu_func(quan_output) + zero_point_out
        # quan_sat_relu_output = saturate_int8_func(quan_relu_output)
        quan_sat_relu_output = quan_relu_output
    else:
        quan_relu_output = quan_output + zero_point_out
        # quan_sat_relu_output = saturate_int8_func(quan_relu_output)
        quan_sat_relu_output = quan_relu_output

    if use_bias2_add:
        # quan_sat_relu_output_add = saturate_int8_func(quan_sat_relu_output + (round_func(bias2 * bias2_scale_int8 *
        #                                                                                 (2 ** (
        #                                                                                         -7 - bias2_shift_int8)))))

        quan_sat_relu_output_add = saturate_int8_func(
            quan_sat_relu_output + round_func((bias2 * bias2_scale_int8 * (2 ** (-7 - bias2_shift_int8)))))
    else:
        quan_sat_relu_output_add = saturate_int8_func(quan_sat_relu_output)

    diff_quan_sat_relu_output = quan_sat_relu_output_add - output_quan_golden_int8
    print('np.max(np.abs(diff_quan_sat_relu_output)):',
          np.max(np.abs(diff_quan_sat_relu_output)))

    # print('output int8=========================================\n', output)
    np.savetxt(path + "input_tensor_int8.txt",
               rearrange_total_imap_nc1hwc0(input_tensor, c0=block_oc * 2, is_int16=0, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "kernel_int8.txt",
               rearrange_total_kernel_nc1hwc0(
                   kernel, c0=block_oc * 2, is_int16=0, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "bias_int8.txt",
               rearrange_total_bias_nc1hwc0(bias, c0=block_oc * 2, is_int16=0, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "bias2_int8.txt",
               rearrange_total_imap_nc1hwc0(bias2, c0=block_oc * 2, is_int16=0, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "output_int8.txt",
               rearrange_total_imap_nc1hwc0(output, c0=block_oc * 2, is_int16=0, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "quan_output_int8.txt",
               rearrange_total_imap_nc1hwc0(quan_output, c0=block_oc * 2, is_int16=0, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "quan_relu_output_int8.txt",
               rearrange_total_imap_nc1hwc0(
                   quan_relu_output, c0=block_oc * 2, is_int16=0, bus_width=bus_width),
               fmt="%d")
    np.savetxt(path + "quan_sat_relu_output_int8.txt",
               rearrange_total_imap_nc1hwc0(
                   quan_sat_relu_output, c0=block_oc * 2, is_int16=0, bus_width=bus_width),
               fmt="%d")
    np.savetxt(path + "quan_sat_relu_output_add_int8.txt",
               rearrange_total_imap_nc1hwc0(
                   quan_sat_relu_output_add, c0=block_oc * 2, is_int16=0, bus_width=bus_width),
               fmt="%d")
