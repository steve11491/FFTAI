import torch.nn as nn
import torch
import numpy as np
import math
import os
import torch.nn.functional as F


def frexp_int16(x):
    """
    将小数 x 分解成 int16 范围内的尾数和 0-15 范围内的指数。

    参数:
    x (float): 需要分解的小数,范围为 (-1, 1)。

    返回:
    signed int16, unsigned int4: 分解后的尾数和指数。
    """
    # 将小数 x 放缩到 [-1, 1) 的范围
    x_scaled = max(-1.0, min(x, 1.0 - 1e-15))

    # 计算指数值
    # print('log2:', math.log2(abs(x_scaled)))
    shift = math.ceil(abs((math.log2(abs(x_scaled))))) - 1
    # print('shift:', shift)
    if shift > 15:
        scale_int16 = round(x_scaled / (2 ** (-30)))
        shift = 15
    else:
        # 计算尾数值
        scale_int16 = round(x_scaled / (2 ** (-15 - shift)))
    if scale_int16 >= 2**15-1:
        scale_int16 = 2**15-1
    elif scale_int16 <= -2**15:
        scale_int16 = -2**15
    return scale_int16, shift


def frexp_int8(x):
    """
    将小数 x 分解成 int8 范围内的尾数和 0-7 范围内的指数。

    参数:
    x (float): 需要分解的小数,范围为 (-1, 1)。

    返回:
    signed int8, unsigned int3: 分解后的尾数和指数。
    """
    # 将小数 x 放缩到 [-1, 1) 的范围
    x_scaled = max(-1.0, min(x, 1.0 - 1e-6))

    # 计算指数值
    # print('log2:', math.log2(abs(x_scaled)))
    shift = math.ceil(abs((math.log2(abs(x_scaled))))) - 1
    print('shift:', shift)
    if shift > 7:
        scale_int8 = round(x_scaled / (2 ** (-14)))
        shift = 7
    else:
        # 计算尾数值
        scale_int8 = round(x_scaled / (2 ** (-7 - shift)))
    if scale_int8 >= 2**7-1:
        scale_int8 = 2**7-1
    elif scale_int8 <= -2**7:
        scale_int8 = -2**7
    return scale_int8, shift


def frexp_intn(x, n):
    """
    将小数 x 分解成 intn 范围内的尾数和 0-n-1 范围内的指数。

    参数:
    x (float): 需要分解的小数,范围为 (-1, 1)。

    返回:
    signed intn, unsigned int(log2(n): 分解后的尾数和指数。
    """
    # 将小数 x 放缩到 [-1, 1) 的范围
    x_scaled = max(-1.0, min(x, 1.0 - 1e-6))

    # 计算指数值
    # print('log2:', math.log2(abs(x_scaled)))
    shift = math.ceil(abs((math.log2(abs(x_scaled))))) - 1
    print('shift:', shift)
    if shift > (n - 1):
        scale_intn = round(x_scaled / (2 ** float(-2 * (n - 1))))
        shift = n - 1
    else:
        # 计算尾数值
        scale_intn = round(x_scaled / (2 ** float(-(n - 1) - shift)))
    if scale_intn >= 2**(n-1)-1:
        scale_intn = 2**(n-1)-1
    elif scale_intn <= -2**(n-1):
        scale_intn = -2**(n-1)
    return scale_intn, shift


def saturate_int32(x):
    if x > 2147483647:
        return 2147483647
    elif x < -2147483648:
        return -2147483648
    else:
        return x


def saturate_int16(x):
    """
    将 int32 整数 x 饱和截断到 int16 的范围内。

    参数:
    x (int): 需要被截断的 int32 整数。

    返回:
    int: 截断后的 int16 整数。
    """
    if x > 32767:
        return 32767.0
    elif x < -32768:
        return -32768.0
    else:
        return x


def saturate_int8(x):
    """
    将 int16 整数 x 饱和截断到 int8 的范围内。

    参数:
    x (int): 需要被截断的 int32 整数。

    返回:
    int: 截断后的 int16 整数。
    """
    if x > 127:
        return 127.0
    elif x < -128:
        return -128.0
    else:
        return x


def saturate_uint8(x):
    """
    将 int16 整数 x 饱和截断到 int8 的范围内。

    参数:
    x (int): 需要被截断的 int32 整数。

    返回:
    int: 截断后的 int16 整数。
    """
    if x > 255:
        return 255.0
    elif x < 0:
        return 0.0
    else:
        return x


def relu(x):
    if x > 0.0:
        return x
    else:
        return 0.0


saturate_int32_fun = np.vectorize(saturate_int32)
saturate_int16_func = np.vectorize(saturate_int16)
saturate_int8_func = np.vectorize(saturate_int8)
saturate_uint8_func = np.vectorize(saturate_uint8)
relu_func = np.vectorize(relu)


def conv2d_b(input_tensor, kernel, bias, padding=(0, 0), stride=(1, 1), dilation=(1, 1)):
    """
    3D convolution operation with bias

    Args:
    input_tensor (np.ndarray): Input tensor of shape (batch_size, in_channels, height, width)
    kernel (np.ndarray): Convolutional kernel of shape (out_channels, in_channels, kernel_height, kernel_width)
    bias (np.ndarray): Bias tensor of shape (out_channels,)
    padding (tuple): Padding (height, width)
    stride (tuple): Stride (height, width)
    dilation (tuple): Dilation (height, width)

    Returns:
    np.ndarray: Output tensor of shape (batch_size, out_channels, output_height, output_width)
    """
    batch_size, in_channels, input_height, input_width = input_tensor.shape
    out_channels, _, kernel_height, kernel_width = kernel.shape

    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1

    output = np.zeros((batch_size, out_channels, output_height, output_width))

    for b in range(batch_size):
        for oc in range(out_channels):
            for h in range(output_height):
                for w in range(output_width):
                    for ic in range(in_channels):
                        for r in range(kernel_height):
                            for s in range(kernel_width):

                                input_w = w * stride[1] - \
                                    padding[1] + s * dilation[1]
                                input_h = h * stride[0] - \
                                    padding[0] + r * dilation[0]
                                if (input_h >= 0 and input_h < input_height and
                                        input_w >= 0 and input_w < input_width):
                                    # print(
                                    #     input_tensor[b, ic, input_h, input_w])
                                    # print(kernel[oc, ic, r, s])
                                    output[b, oc, h, w] += (input_tensor[b, ic, input_h, input_w] *
                                                            kernel[oc, ic, r, s])
            output[b, oc] += bias[oc]  # 添加偏置项

    return output


def test_conv2d_random():
    # 随机生成输入张量
    batch_size = 1
    in_channels = 3
    input_height = 7
    input_width = 8

    # 随机生成卷积核
    out_channels = 2
    kernel_height = 3
    kernel_width = 4

    # 随机生成卷积参数
    padding = (0, 2)
    stride = (2, 1)
    dilation = (1, 2)
    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1
    print(output_width)
    print(output_height)

    input_tensor = np.random.randn(
        batch_size, in_channels, input_height, input_width)

    kernel = np.random.randn(out_channels, in_channels,
                             kernel_height, kernel_width)

    # 随机生成偏置项
    bias = np.random.randn(out_channels, 1, 1)

    # 计算卷积结果
    output = conv2d_b(input_tensor, kernel, bias, padding, stride, dilation)

    # 使用PyTorch计算卷积结果
    input_tensor_pt = torch.tensor(input_tensor)
    kernel_pt = torch.tensor(kernel)
    bias_pt = torch.tensor(bias.reshape(out_channels))
    conv2d_pt = nn.Conv2d(in_channels, out_channels, (kernel_height, kernel_width),
                          stride=stride, padding=padding, dilation=dilation, bias=True)
    conv2d_pt.weight.data = kernel_pt
    conv2d_pt.bias.data = bias_pt
    output_pt = conv2d_pt(input_tensor_pt)
    output_pt = output_pt.detach().numpy()

    print('output=========================================\n', output)
    print('output_pt=========================================\n', output_pt)

    # 验证输出结果是否与PyTorch结果相同
    assert np.allclose(output, output_pt, rtol=1e-5,
                       atol=1e-8), "Conv2D output does not match PyTorch output"

    print("Conv2D random test passed!")


def conv2d(input_tensor, kernel, bias, padding=(0, 0), stride=(1, 1), dilation=(1, 1)):
    """
    3D convolution operation with bias

    Args:
    input_tensor (np.ndarray): Input tensor of shape (batch_size, in_channels, height, width)
    kernel (np.ndarray): Convolutional kernel of shape (out_channels, in_channels, kernel_height, kernel_width)
    bias (np.ndarray): Bias tensor of shape (out_channels,)
    padding (tuple): Padding (height, width)
    stride (tuple): Stride (height, width)
    dilation (tuple): Dilation (height, width)

    Returns:
    np.ndarray: Output tensor of shape (batch_size, out_channels, output_height, output_width)
    """
    in_channels, input_height, input_width = input_tensor.shape
    out_channels, _, kernel_height, kernel_width = kernel.shape

    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1

    output = np.zeros((out_channels, output_height, output_width))

    for oc in range(out_channels):
        for h in range(output_height):
            for w in range(output_width):
                for ic in range(in_channels):
                    for r in range(kernel_height):
                        for s in range(kernel_width):

                            input_w = w * stride[1] - \
                                padding[1] + s * dilation[1]
                            input_h = h * stride[0] - \
                                padding[0] + r * dilation[0]
                            if (input_h >= 0 and input_h < input_height and
                                    input_w >= 0 and input_w < input_width):
                                output[oc, h, w] += (input_tensor[ic, input_h, input_w] *
                                                     kernel[oc, ic, r, s])
        output[oc] += bias[oc]  # 添加偏置项

    return output


def conv2d_matmul(input_tensor, kernel, bias, padding=(0, 0), stride=(1, 1), dilation=(1, 1), block_ic=4, block_oc=4,
                  savefile=0, path='./', name="_int16", remove_file=1):
    """
    3D convolution operation with bias

    Args:
    input_tensor (np.ndarray): Input tensor of shape (batch_size, in_channels, height, width)
    kernel (np.ndarray): Convolutional kernel of shape (out_channels, in_channels, kernel_height, kernel_width)
    bias (np.ndarray): Bias tensor of shape (out_channels,)
    padding (tuple): Padding (height, width)
    stride (tuple): Stride (height, width)
    dilation (tuple): Dilation (height, width)

    Returns:
    np.ndarray: Output tensor of shape (batch_size, out_channels, output_height, output_width)
    """

    # in_channels, input_height, input_width = input_tensor.shape
    # out_channels, _, kernel_height, kernel_width = kernel.shape
    # ceil_out_channels = math.ceil(out_channels/block_c)*block_c

    in_channels, input_height, input_width = input_tensor.shape
    ceil_in_channels = math.ceil(in_channels / block_ic) * block_ic
    ceil_feature_map = np.zeros(
        (ceil_in_channels, input_height + 2 * padding[0], input_width + 2 * padding[1]))
    ceil_feature_map[0:in_channels, padding[0]:padding[0] +
                     input_height, padding[1]:padding[1] + input_width] = input_tensor

    out_channels, in_channels, kernel_height, kernel_width = kernel.shape
    ceil_out_channels = math.ceil(out_channels / block_oc) * block_oc
    ceil_kernel = np.zeros(
        (ceil_out_channels, ceil_in_channels, kernel_height, kernel_width))
    ceil_kernel[0:out_channels, 0:in_channels, :, :] = kernel

    ceil_bias = np.zeros((ceil_out_channels, 1, 1))
    ceil_bias[0:out_channels, :, :] = bias

    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1

    ceil_output = np.zeros((ceil_out_channels, output_height, output_width))
    # print('ceil_feature_map:', ceil_feature_map)
    # print('ceil_feature_map.shape:', ceil_feature_map.shape)
    # print('ceil_kernel:', ceil_kernel)
    # print('ceil_kernel.shape:', ceil_kernel.shape)
    try:
        if remove_file:
            os.remove(path + "tmp_input_matrix" + name + ".txt")
            os.remove(path + "tmp_weight_matrix" + name + ".txt")
            os.remove(path + "tmp_output_maxtix" + name + ".txt")
            os.remove(path + "tmp_acc_maxtix" + name + ".txt")
    except:
        pass
    for oc in range(ceil_out_channels // block_oc):
        i = 0
        for ic in range(ceil_in_channels // block_ic):
            for r in range(kernel_height):
                for s in range(kernel_width):
                    index = np.arange(block_ic)
                    input_oc = np.arange(block_oc) + oc * block_oc
                    input_ic = np.arange(block_ic) + ic * block_ic
                    output_w = np.arange(output_width)
                    output_h = np.arange(output_height)
                    input_w = output_w * \
                        stride[1] + s * dilation[1]
                    input_h = output_h * \
                        stride[0] + r * dilation[0]

                    weight_matrix = ceil_kernel[np.ix_(input_oc, input_ic, [r], [s])].reshape(
                        block_oc, block_ic).transpose(1, 0)

                    # print('weight_matrix:', weight_matrix)
                    # print('weight_matrix.shape:', weight_matrix.shape)

                    # print("input_w:", input_w)
                    # print("input_h:", input_h)
                    # print("input_ic:", input_ic)

                    input_matrix = ceil_feature_map[np.ix_(input_ic, input_h, input_w)].reshape(
                        block_ic, output_height * output_width).transpose(1, 0)
                    # print('input_matrix:', input_matrix)
                    # print('input_matrix.shape:', input_matrix.shape)
                    output_maxtix = input_matrix.dot(weight_matrix)
                    # print('output_maxtix:', output_maxtix)
                    # print('output_maxtix.shape:', output_maxtix.shape)

                    if savefile:
                        with open(path + "tmp_input_matrix" + name + ".txt", "a") as f:
                            np.savetxt(f, input_matrix,
                                       fmt="%d", delimiter=' ')

                        with open(path + "tmp_weight_matrix" + name + ".txt", "a") as f:
                            np.savetxt(
                                f, weight_matrix[index[(input_ic + 1) <= in_channels], :], fmt="%d", delimiter=' ')
                            # np.savetxt(f, weight_matrix, fmt="%d", delimiter=' ')

                        with open(path + "tmp_output_maxtix" + name + ".txt", "a") as f:
                            np.savetxt(f, output_maxtix,
                                       fmt="%d", delimiter=' ')

                    bias_vector = ceil_bias[input_oc, :, :].reshape(block_oc)
                    # print('bias_vector:', bias_vector)
                    # print('bias_vector.shape:', bias_vector.shape)
                    if i == 0:
                        output_maxtix = output_maxtix + bias_vector
                        i = i + 1

                    # print('output_maxtix:', output_maxtix)
                    # print('output_maxtix.shape:', output_maxtix.shape)
                    output_matrix_tran = output_maxtix.transpose(1, 0).reshape(
                        block_oc, output_height, output_width)
                    # print('output_matrix_tran:', output_matrix_tran)
                    # print('output_matrix_tran.shape:',
                    #       output_matrix_tran.shape)
                    # print('ceil_output:', ceil_output)
                    # print('ceil_output.shape:', ceil_output.shape)
                    # print('ceil_output[np.ix_(input_oc, input_h, input_w)]:', ceil_output[np.ix_(
                    #     input_oc, output_h, output_w)])
                    # print('ceil_output[np.ix_(input_oc, input_h, input_w)].shape:',
                    #       ceil_output[np.ix_(input_oc, output_h, output_w)].shape)

                    ceil_output[np.ix_(input_oc, output_h,
                                       output_w)] += output_matrix_tran

                    acc_matrix = ceil_output[np.ix_(input_oc, output_h, output_w)].reshape(
                        block_oc, output_height * output_width).transpose(1, 0)

                    with open(path + "tmp_acc_maxtix" + name + ".txt", "a") as f:
                        np.savetxt(f, acc_matrix,
                                   fmt="%d", delimiter=' ')
    # for oc in range(ceil_out_channels):
    #     ceil_output[oc] += ceil_bias[oc]  # 添加偏置项

    output = ceil_output[0:out_channels, :, :]
    return output


def test_conv2d_matmul_random():
    # 随机生成输入张量
    batch_size = 1
    in_channels = 4
    input_height = 10
    input_width = 10

    # 随机生成卷积核
    out_channels = 4
    kernel_height = 3
    kernel_width = 2

    # 随机生成卷积参数
    padding = (1, 3)
    stride = (1, 2)
    dilation = (2, 1)

    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1
    print(output_width)
    print(output_height)

    input_tensor = np.random.randn(
        in_channels, input_height, input_width)

    kernel = np.random.randn(
        out_channels, in_channels,
        kernel_height, kernel_width)

    # 随机生成偏置项
    bias = np.random.randn(
        out_channels, 1, 1)

    # 计算卷积结果
    output = conv2d(input_tensor, kernel, bias, padding, stride, dilation)

    # 使用PyTorch计算卷积结果

    output_matmul = conv2d_matmul(
        input_tensor, kernel, bias, padding, stride, dilation)

    input_tensor_b = input_tensor.reshape(
        1, in_channels, input_height, input_width)

    # print('input_tensor:', input_tensor)
    # print('input_tensor_b:', input_tensor_b)

    input_tensor_pt = torch.tensor(input_tensor_b)
    kernel_pt = torch.tensor(kernel)
    bias_pt = torch.tensor(bias.reshape(out_channels))
    conv2d_pt = nn.Conv2d(in_channels, out_channels, (kernel_height, kernel_width),
                          stride=stride, padding=padding, dilation=dilation, bias=True)
    conv2d_pt.weight.data = kernel_pt
    conv2d_pt.bias.data = bias_pt
    output_pt = conv2d_pt(input_tensor_pt)
    output_pt = output_pt.detach().numpy()

    print('output=========================================\n', output)
    print('output_matmul=========================================\n', output_matmul)
    print('output_pt=========================================\n', output_pt)

    # 验证输出结果是否与PyTorch结果相同
    assert np.allclose(output_pt, output_matmul, rtol=1e-5,
                       atol=1e-8), "Conv2D output does not match PyTorch output"

    print("Conv2D random test passed!")


def conv2d_matmul_b(input_tensor, kernel, bias, padding=(0, 0), stride=(1, 1), dilation=(1, 1),
                    output_height=0, output_width=0,
                    kernel_height=3, kernel_width=3, r_start=0, s_start=0, block_ic=4, block_oc=4,
                    bias_mode=0,
                    savefile=0, path='./', name="_int16", remove_file=1):
    """
    3D convolution operation with bias

    Args:
    input_tensor (np.ndarray): Input tensor of shape (batch_size, in_channels, height, width)
    kernel (np.ndarray): Convolutional kernel of shape (out_channels, in_channels, kernel_height, kernel_width)
    bias (np.ndarray): Bias tensor of shape (out_channels,)
    padding (tuple): Padding (height, width)
    stride (tuple): Stride (height, width)
    dilation (tuple): Dilation (height, width)

    Returns:
    np.ndarray: Output tensor of shape (batch_size, out_channels, output_height, output_width)
    """

    # in_channels, input_height, input_width = input_tensor.shape
    # out_channels, _, kernel_height, kernel_width = kernel.shape
    # ceil_out_channels = math.ceil(out_channels/block_c)*block_c

    in_channels, input_height, input_width = input_tensor.shape
    ceil_in_channels = math.ceil(in_channels / block_ic) * block_ic
    ceil_feature_map = np.zeros(
        (ceil_in_channels, input_height + 2 * padding[0], input_width + 2 * padding[1]))
    ceil_feature_map[0:in_channels, padding[0]:padding[0] +
                     input_height, padding[1]:padding[1] + input_width] = input_tensor

    out_channels, in_channels, rs_len = kernel.shape
    ceil_out_channels = math.ceil(out_channels / block_oc) * block_oc
    ceil_kernel = np.zeros(
        (ceil_out_channels, ceil_in_channels, rs_len))
    ceil_kernel[0:out_channels, 0:in_channels, :] = kernel

    if bias_mode == 1:
        ceil_bias = np.zeros((ceil_out_channels, output_height, output_width))
    else:
        ceil_bias = np.zeros((ceil_out_channels, 1, 1))
    ceil_bias[0:out_channels, :, :] = bias

    # output_width = (
    #     input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    # output_height = (
    #     input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1

    ceil_output = np.zeros((ceil_out_channels, output_height, output_width))
    # print('ceil_feature_map:', ceil_feature_map)
    # print('ceil_feature_map.shape:', ceil_feature_map.shape)
    # print('ceil_kernel:', ceil_kernel)
    # print('ceil_kernel.shape:', ceil_kernel.shape)
    try:
        if remove_file:
            os.remove(path + "tmp_input_matrix" + name + ".txt")
            os.remove(path + "tmp_weight_matrix" + name + ".txt")
            os.remove(path + "tmp_output_maxtix" + name + ".txt")
            os.remove(path + "tmp_acc_maxtix" + name + ".txt")
    except:
        pass
    s = s_start
    r = r_start
    for oc in range(ceil_out_channels // block_oc):
        i = 0
        for ic in range(ceil_in_channels // block_ic):
            # for r in range(kernel_height):
            #     for s in range(kernel_width):
            s = s_start
            r = r_start
            rs_start = r_start * kernel_width + s_start
            for rs in range(rs_len):
                curr_rs = rs_start + rs
                s = curr_rs % kernel_width
                r = curr_rs // kernel_width

                index = np.arange(block_ic)
                input_oc = np.arange(block_oc) + oc * block_oc
                input_ic = np.arange(block_ic) + ic * block_ic
                output_w = np.arange(output_width)
                output_h = np.arange(output_height)

                input_w = output_w * \
                    stride[1] + s * dilation[1]
                input_h = output_h * \
                    stride[0] + r * dilation[0]

                weight_matrix_ = ceil_kernel[:, :, rs].reshape(
                    ceil_out_channels, ceil_in_channels)
                weight_matrix = weight_matrix_[
                    np.ix_(input_oc, input_ic)].transpose(1, 0)
                # weight_matrix = ceil_kernel[np.ix_(input_oc, input_ic), rs].reshape(
                #     block_oc, block_ic).transpose(1, 0)

                # print('weight_matrix:', weight_matrix)
                # print('weight_matrix.shape:', weight_matrix.shape)

                # print("input_w:", input_w)
                # print("input_h:", input_h)
                # print("input_ic:", input_ic)

                input_matrix = ceil_feature_map[np.ix_(input_ic, input_h, input_w)].reshape(
                    block_ic, output_height * output_width).transpose(1, 0)
                # print('input_matrix:', input_matrix)
                # print('input_matrix.shape:', input_matrix.shape)
                output_maxtix = input_matrix.dot(weight_matrix)
                # print('output_maxtix:', output_maxtix)
                # print('output_maxtix.shape:', output_maxtix.shape)

                if savefile:
                    with open(path + "tmp_input_matrix" + name + ".txt", "a") as f:
                        np.savetxt(f, input_matrix,
                                   fmt="%d", delimiter=' ')

                    with open(path + "tmp_weight_matrix" + name + ".txt", "a") as f:
                        np.savetxt(
                            f, weight_matrix[index[(input_ic + 1) <= in_channels], :], fmt="%d", delimiter=' ')
                        # np.savetxt(f, weight_matrix, fmt="%d", delimiter=' ')

                    with open(path + "tmp_output_maxtix" + name + ".txt", "a") as f:
                        np.savetxt(f, output_maxtix,
                                   fmt="%d", delimiter=' ')
                if bias_mode == 1:
                    bias_vector = ceil_bias[input_oc, :, :].reshape(
                        block_oc, output_height * output_width).transpose(1, 0)  # matrix
                else:
                    bias_vector = ceil_bias[input_oc, :, :].reshape(block_oc)
                # print('bias_vector:', bias_vector)
                # print('bias_vector.shape:', bias_vector.shape)
                if i == 0:
                    output_maxtix = output_maxtix + bias_vector
                    i = i + 1

                # print('output_maxtix:', output_maxtix)
                # print('output_maxtix.shape:', output_maxtix.shape)
                output_matrix_tran = output_maxtix.transpose(1, 0).reshape(
                    block_oc, output_height, output_width)
                # print('output_matrix_tran:', output_matrix_tran)
                # print('output_matrix_tran.shape:',
                #       output_matrix_tran.shape)
                # print('ceil_output:', ceil_output)
                # print('ceil_output.shape:', ceil_output.shape)
                # print('ceil_output[np.ix_(input_oc, input_h, input_w)]:', ceil_output[np.ix_(
                #     input_oc, output_h, output_w)])
                # print('ceil_output[np.ix_(input_oc, input_h, input_w)].shape:',
                #       ceil_output[np.ix_(input_oc, output_h, output_w)].shape)

                ceil_output[np.ix_(input_oc, output_h,
                                   output_w)] += output_matrix_tran
                # acc_matrix = ceil_output[np.ix_(input_oc, output_h, output_w)].reshape(
                #     block_oc, output_height * output_width).transpose(1, 0)

                # with open(path + "tmp_acc_maxtix" + name + ".txt", "a") as f:
                #     np.savetxt(f, acc_matrix,
                #                fmt="%d", delimiter=' ')

    # for oc in range(ceil_out_channels):
    #     ceil_output[oc] += ceil_bias[oc]  # 添加偏置项

    output = ceil_output[0:out_channels, :, :]
    if (s == kernel_width - 1):
        s = 0
        if (r == kernel_height - 1):
            r = 0
        else:
            r = r + 1
    else:
        s = s + 1
        r = r

    return output, s, r


def maxpool_tile(input_tensor, padding=(0, 0), stride=(1, 1), dilation=(1, 1),
                 output_height=0, output_width=0,
                 kernel_height=3, kernel_width=3, block_ic=4, block_oc=4,
                 is_int16=0,
                 savefile=0, path='./', name="_int16", remove_file=1):
    out_channels, input_height, input_width = input_tensor.shape
    ceil_out_channels = math.ceil(out_channels / block_ic) * block_ic
    ceil_feature_map = np.zeros(
        (ceil_out_channels, input_height + 2 * padding[0], input_width + 2 * padding[1]))
    ceil_feature_map[0:out_channels, padding[0]:padding[0] +
                     input_height, padding[1]:padding[1] + input_width] = input_tensor
    if is_int16:
        ceil_output = -32768 * \
            np.ones((ceil_out_channels, output_height, output_width))
    else:
        ceil_output = -128 * \
            np.ones((ceil_out_channels, output_height, output_width))
    try:
        if remove_file:
            os.remove(path + "tmp_maxpool_input_matrix" + name + ".txt")
            os.remove(path + "tmp_maxpool_output_maxtix" + name + ".txt")
    except:
        pass

    for oc in range(ceil_out_channels // block_oc):
        for r in range(kernel_height):
            for s in range(kernel_width):
                input_oc = np.arange(block_oc) + oc * block_oc
                output_w = np.arange(output_width)
                output_h = np.arange(output_height)

                input_w = output_w * \
                    stride[1] + s * dilation[1]
                input_h = output_h * \
                    stride[0] + r * dilation[0]

                input_matrix = ceil_feature_map[np.ix_(input_oc, input_h, input_w)].reshape(
                    block_oc, output_height * output_width).transpose(1, 0)
                last_max_matrix = ceil_output[np.ix_(input_oc, output_h, output_w)].reshape(
                    block_oc, output_height * output_width).transpose(1, 0)
                output_maxtix = np.maximum(input_matrix, last_max_matrix)

                if savefile:
                    with open(path + "tmp_maxpool_input_matrix" + name + ".txt", "a") as f:
                        np.savetxt(f, input_matrix,
                                   fmt="%d", delimiter=' ')
                    with open(path + "tmp_maxpool_output_maxtix" + name + ".txt", "a") as f:
                        np.savetxt(f, output_maxtix,
                                   fmt="%d", delimiter=' ')

                output_matrix_tran = output_maxtix.transpose(1, 0).reshape(
                    block_oc, output_height, output_width)

                ceil_output[np.ix_(input_oc, output_h,
                                   output_w)] = output_matrix_tran

    output = ceil_output[0:out_channels, :, :]

    return output


def avgpool_tile(input_tensor, padding=(0, 0), stride=(1, 1), dilation=(1, 1),
                 output_height=0, output_width=0,
                 kernel_height=3, kernel_width=3, block_ic=4, block_oc=4,
                 is_int16=0,
                 savefile=0, path='./', name="_int16", remove_file=1):
    out_channels, input_height, input_width = input_tensor.shape
    ceil_out_channels = math.ceil(out_channels / block_ic) * block_ic
    ceil_feature_map = np.zeros(
        (ceil_out_channels, input_height + 2 * padding[0], input_width + 2 * padding[1]))
    ceil_feature_map[0:out_channels, padding[0]:padding[0] +
                     input_height, padding[1]:padding[1] + input_width] = input_tensor

    ceil_output = 0 * \
        np.ones((ceil_out_channels, output_height, output_width))
    try:
        if remove_file:
            os.remove(path + "tmp_avgpool_input_matrix" + name + ".txt")
            os.remove(path + "tmp_avgpool_output_maxtix" + name + ".txt")
    except:
        pass

    for oc in range(ceil_out_channels // block_oc):
        for r in range(kernel_height):
            for s in range(kernel_width):
                input_oc = np.arange(block_oc) + oc * block_oc
                output_w = np.arange(output_width)
                output_h = np.arange(output_height)

                input_w = output_w * \
                    stride[1] + s * dilation[1]
                input_h = output_h * \
                    stride[0] + r * dilation[0]

                input_matrix = ceil_feature_map[np.ix_(input_oc, input_h, input_w)].reshape(
                    block_oc, output_height * output_width).transpose(1, 0)
                last_matrix = ceil_output[np.ix_(input_oc, output_h, output_w)].reshape(
                    block_oc, output_height * output_width).transpose(1, 0)
                output_maxtix = input_matrix + last_matrix

                if savefile:
                    with open(path + "tmp_avgpool_input_matrix" + name + ".txt", "a") as f:
                        np.savetxt(f, input_matrix,
                                   fmt="%d", delimiter=' ')
                    with open(path + "tmp_avgpool_output_maxtix" + name + ".txt", "a") as f:
                        np.savetxt(f, output_maxtix,
                                   fmt="%d", delimiter=' ')

                output_matrix_tran = output_maxtix.transpose(1, 0).reshape(
                    block_oc, output_height, output_width)

                ceil_output[np.ix_(input_oc, output_h,
                                   output_w)] = output_matrix_tran

    output = ceil_output[0:out_channels, :, :]

    return output


def conv2d_matmul_total(input_tensor, kernel, bias, bias2,
                        padding=(0, 0), stride=(1, 1), dilation=(1, 1),
                        basic_ow=10,
                        basic_oh=5,
                        basic_ic=16,
                        basic_oc=32,
                        basic_rs=9,
                        block_ic=4,
                        block_oc=4,
                        savefile=0,
                        scale=16777,
                        shift=9,
                        zero_point=-128,
                        is_int16=0,
                        bias_mode=0,
                        use_relu=1,
                        path='./', name="_int16"):
    in_channels, input_height, input_width = input_tensor.shape
    feature_map = np.zeros(
        (in_channels, input_height + 2 * padding[0], input_width + 2 * padding[1]))
    feature_map[0:in_channels, padding[0]:padding[0] +
                input_height, padding[1]:padding[1] + input_width] = input_tensor

    out_channels, _, kernel_height, kernel_width = kernel.shape
    weight = kernel.reshape(out_channels, in_channels,
                            kernel_height * kernel_width)
    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1

    output = np.zeros((out_channels, output_height, output_width))
    try:
        os.remove(path + "tmp_input_matrix" + name + ".txt")
        os.remove(path + "tmp_weight_matrix" + name + ".txt")
        os.remove(path + "tmp_output_maxtix" + name + ".txt")
        os.remove(path + "tmp_acc_maxtix" + name + ".txt")
        os.remove(path + "tmp_quan_relu_maxtix" + name + ".txt")
        os.remove(path + "tmp_bias2_maxtix" + name + ".txt")
        os.remove(path + "tmp_quan_relu_bias2_add_maxtix" + name + ".txt")
    except:
        pass

    left_padding = padding[1]
    right_padding = padding[1]
    top_padding = padding[0]
    bottom_padding = padding[0]
    input_height_p = input_height + 2 * padding[0]
    input_width_p = input_width + 2 * padding[1]

    num_ow = math.ceil(output_width / basic_ow)
    num_oh = math.ceil(output_height / basic_oh)
    num_oc = math.ceil(out_channels / basic_oc)
    num_ic = math.ceil(in_channels / basic_ic)
    num_rs = math.ceil(kernel_height * kernel_width / basic_rs)

    basic_iw = (basic_ow - 1) * stride[1] + \
        (kernel_width - 1) * dilation[1] + 1
    basic_ih = (basic_oh - 1) * stride[0] + \
        (kernel_height - 1) * dilation[0] + 1

    basic_ow_sx = (basic_ow) * stride[1]
    basic_oh_sy = (basic_oh) * stride[0]

    remain_ow = basic_ow if output_width % basic_ow == 0 else output_width % basic_ow
    remain_oh = basic_oh if output_height % basic_oh == 0 else output_height % basic_oh
    remain_oc = basic_oc if out_channels % basic_oc == 0 else out_channels % basic_oc
    remain_ic = basic_ic if in_channels % basic_ic == 0 else in_channels % basic_ic
    remain_rs = basic_rs if (
        kernel_height * kernel_width) % basic_rs == 0 else (
        kernel_height * kernel_width) % basic_rs

    remain_ih = (input_height + top_padding + bottom_padding) - \
        basic_oh_sy * (num_oh - 1)
    remain_iw = (input_width + left_padding + right_padding) - \
        basic_ow_sx * (num_ow - 1)

    s, r = 0, 0
    for oc in range(num_oc):
        for oh in range(num_oh):
            for ow in range(num_ow):
                i = 0
                for ic in range(num_ic):
                    s, r = 0, 0
                    for rs in range(num_rs):
                        curr_rs = remain_rs if rs == num_rs - 1 else basic_rs
                        curr_ic = remain_ic if ic == num_ic - 1 else basic_ic
                        curr_oh = remain_oh if oh == num_oh - 1 else basic_oh
                        curr_ow = remain_ow if ow == num_ow - 1 else basic_ow
                        curr_oc = remain_oc if oc == num_oc - 1 else basic_oc
                        curr_ih = remain_ih if oh == num_oh - 1 else basic_ih
                        curr_iw = remain_iw if ow == num_ow - 1 else basic_iw

                        rs_index = np.arange(curr_rs) + basic_rs * rs
                        ic_index = np.arange(curr_ic) + basic_ic * ic
                        oh_index = np.arange(curr_oh) + basic_oh * oh
                        ow_index = np.arange(curr_ow) + basic_ow * ow
                        oc_index = np.arange(curr_oc) + basic_oc * oc
                        ih_index = np.arange(curr_ih) + basic_oh_sy * oh
                        iw_index = np.arange(curr_iw) + basic_ow_sx * ow

                        imap_cube = feature_map[np.ix_(
                            ic_index, ih_index, iw_index)]
                        weight_cube = weight[np.ix_(
                            oc_index, ic_index, rs_index)]
                        # print('bias', bias.shape)
                        # print('oc_index', oc_index)
                        # print('oh_index', oh_index)
                        # print('ow_index', ow_index)
                        if i == 0:
                            if bias_mode == 1:
                                bias_cube = bias[np.ix_(
                                    oc_index, oh_index, ow_index)]
                            else:
                                bias_cube = bias[oc_index, :, :]
                            i = i + 1
                        else:
                            if bias_mode == 1:
                                bias_cube = np.zeros(
                                    (curr_oc, curr_oh, curr_ow))
                            else:
                                bias_cube = np.zeros((curr_oc, 1, 1))

                        # r = (rs*basic_rs) // kernel_width
                        # s = (rs*basic_rs) % kernel_width
                        # print('s={},r={}'.format(s, r))
                        # print('imap_cube:', imap_cube)
                        # print('weight_cube:', weight_cube)
                        # print('bias_cube:', bias_cube)
                        omap_cube, s, r = conv2d_matmul_b(input_tensor=imap_cube, kernel=weight_cube, bias=bias_cube,
                                                          padding=(0, 0),
                                                          output_height=curr_oh, output_width=curr_ow,
                                                          kernel_height=kernel_height, kernel_width=kernel_width,
                                                          r_start=r, s_start=s,
                                                          stride=stride,
                                                          dilation=dilation,
                                                          block_ic=block_ic,
                                                          block_oc=block_oc,
                                                          bias_mode=bias_mode,
                                                          savefile=savefile, path=path, name=name, remove_file=0)

                        output[np.ix_(oc_index, oh_index, ow_index)
                               ] += omap_cube

                        acc_matrix = rearrange_feature_map(
                            output[np.ix_(oc_index, oh_index, ow_index)], block_oc)
                        bias2_matrix = rearrange_feature_map(
                            bias2[np.ix_(oc_index, oh_index, ow_index)], block_oc)

                        with open(path + "tmp_acc_maxtix" + name + ".txt", "a") as f:
                            np.savetxt(f, acc_matrix,
                                       fmt="%d", delimiter=' ')
                        if rs == num_rs - 1 and ic == num_ic - 1:
                            quan_output = (
                                np.around(acc_matrix * scale * (2 ** (-15 - shift))))
                            if use_relu:
                                quan_relu_output = relu_func(
                                    quan_output) + zero_point
                            else:
                                quan_relu_output = quan_output + zero_point
                            if is_int16:
                                quan_relu_matrix = saturate_int16_func(
                                    quan_relu_output)
                                quan_relu_matrix_bias2_add = saturate_int16_func(
                                    quan_relu_matrix + bias2_matrix)

                            else:
                                quan_relu_matrix = saturate_int8_func(
                                    quan_relu_output)
                                quan_relu_matrix_bias2_add = saturate_int16_func(
                                    quan_relu_matrix + bias2_matrix)

                            with open(path + "tmp_quan_relu_maxtix" + name + ".txt", "a") as f:
                                np.savetxt(f, quan_relu_matrix,
                                           fmt="%d", delimiter=' ')
                            with open(path + "tmp_bias2_maxtix" + name + ".txt", "a") as f:
                                np.savetxt(f, bias2_matrix,
                                           fmt="%d", delimiter=' ')
                            with open(path + "tmp_quan_relu_bias2_add_maxtix" + name + ".txt", "a") as f:
                                np.savetxt(f, bias2_matrix,
                                           fmt="%d", delimiter=' ')
    return output


def pool_total(input_tensor, bias2,
               padding=(0, 0), stride=(1, 1), dilation=(1, 1), kernel_height=3, kernel_width=3, pool_type="maxpool",
               basic_ow=10,
               basic_oh=5,
               basic_oc=32,
               block_ic=4,
               block_oc=4,
               savefile=0,
               scale=16777,
               shift=9,
               zero_point=0,
               is_int16=0,
               use_relu=1,
               path='./', name="_int16"):
    out_channels, input_height, input_width = input_tensor.shape
    feature_map = np.zeros(
        (out_channels, input_height + 2 * padding[0], input_width + 2 * padding[1]))
    feature_map[0:out_channels, padding[0]:padding[0] +
                input_height, padding[1]:padding[1] + input_width] = input_tensor

    # out_channels, _, kernel_height, kernel_width = kernel.shape
    # weight = kernel.reshape(out_channels, in_channels,
    #                         kernel_height * kernel_width)
    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1

    output = np.zeros((out_channels, output_height, output_width))
    try:
        if pool_type == "maxpool":
            os.remove(path + "tmp_maxpool_input_matrix" + name + ".txt")
            os.remove(path + "tmp_maxpool_output_maxtix" + name + ".txt")
            os.remove(path + "tmp_maxpool_acc_maxtix" + name + ".txt")
        else:
            os.remove(path + "tmp_avgpool_input_matrix" + name + ".txt")
            os.remove(path + "tmp_avgpool_output_maxtix" + name + ".txt")
            os.remove(path + "tmp_avgpool_acc_maxtix" + name + ".txt")
        os.remove(path + "tmp_quan_relu_maxtix" + name + ".txt")
        os.remove(path + "tmp_bias2_maxtix" + name + ".txt")
        os.remove(path + "tmp_quan_relu_bias2_add_maxtix" + name + ".txt")
    except:
        pass

    left_padding = padding[1]
    right_padding = padding[1]
    top_padding = padding[0]
    bottom_padding = padding[0]
    input_height_p = input_height + 2 * padding[0]
    input_width_p = input_width + 2 * padding[1]

    num_ow = math.ceil(output_width / basic_ow)
    num_oh = math.ceil(output_height / basic_oh)
    num_oc = math.ceil(out_channels / basic_oc)

    basic_iw = (basic_ow - 1) * stride[1] + \
        (kernel_width - 1) * dilation[1] + 1
    basic_ih = (basic_oh - 1) * stride[0] + \
        (kernel_height - 1) * dilation[0] + 1

    basic_ow_sx = (basic_ow) * stride[1]
    basic_oh_sy = (basic_oh) * stride[0]

    remain_ow = basic_ow if output_width % basic_ow == 0 else output_width % basic_ow
    remain_oh = basic_oh if output_height % basic_oh == 0 else output_height % basic_oh
    remain_oc = basic_oc if out_channels % basic_oc == 0 else out_channels % basic_oc

    remain_ih = (input_height + top_padding + bottom_padding) - \
        basic_oh_sy * (num_oh - 1)
    remain_iw = (input_width + left_padding + right_padding) - \
        basic_ow_sx * (num_ow - 1)

    for oc in range(num_oc):
        for oh in range(num_oh):
            for ow in range(num_ow):

                curr_oh = remain_oh if oh == num_oh - 1 else basic_oh
                curr_ow = remain_ow if ow == num_ow - 1 else basic_ow
                curr_oc = remain_oc if oc == num_oc - 1 else basic_oc
                curr_ih = remain_ih if oh == num_oh - 1 else basic_ih
                curr_iw = remain_iw if ow == num_ow - 1 else basic_iw

                oh_index = np.arange(curr_oh) + basic_oh * oh
                ow_index = np.arange(curr_ow) + basic_ow * ow
                oc_index = np.arange(curr_oc) + basic_oc * oc
                ih_index = np.arange(curr_ih) + basic_oh_sy * oh
                iw_index = np.arange(curr_iw) + basic_ow_sx * ow

                imap_cube = feature_map[np.ix_(
                    oc_index, ih_index, iw_index)]
                if pool_type == "maxpool":
                    omap_cube = maxpool_tile(input_tensor=imap_cube,
                                             padding=(0, 0),
                                             output_height=curr_oh, output_width=curr_ow,
                                             kernel_height=kernel_height, kernel_width=kernel_width,
                                             stride=stride,
                                             dilation=dilation,
                                             block_ic=block_ic,
                                             block_oc=block_oc,
                                             is_int16=is_int16,
                                             savefile=savefile, path=path, name=name, remove_file=0)
                else:
                    omap_cube = avgpool_tile(input_tensor=imap_cube,
                                             padding=(0, 0),
                                             output_height=curr_oh, output_width=curr_ow,
                                             kernel_height=kernel_height, kernel_width=kernel_width,
                                             stride=stride,
                                             dilation=dilation,
                                             block_ic=block_ic,
                                             block_oc=block_oc,
                                             is_int16=is_int16,
                                             savefile=savefile, path=path, name=name, remove_file=0)

                output[np.ix_(oc_index, oh_index, ow_index)
                       ] = omap_cube

                acc_matrix = rearrange_feature_map(
                    output[np.ix_(oc_index, oh_index, ow_index)], block_oc)
                bias2_matrix = rearrange_feature_map(
                    bias2[np.ix_(oc_index, oh_index, ow_index)], block_oc)

                if pool_type == "maxpool":
                    with open(path + "tmp_maxpool_acc_maxtix" + name + ".txt", "a") as f:
                        np.savetxt(f, acc_matrix,
                                   fmt="%d", delimiter=' ')
                else:
                    with open(path + "tmp_avgpool_acc_maxtix" + name + ".txt", "a") as f:
                        np.savetxt(f, acc_matrix,
                                   fmt="%d", delimiter=' ')

                quan_output = (
                    np.around(acc_matrix * scale * (2 ** (-15 - shift))))
                if use_relu:
                    quan_relu_output = relu_func(
                        quan_output) + zero_point
                else:
                    quan_relu_output = quan_output + zero_point
                if is_int16:
                    quan_relu_matrix = saturate_int16_func(
                        quan_relu_output)
                    quan_relu_matrix_bias2_add = saturate_int16_func(
                        quan_relu_matrix + bias2_matrix)

                else:
                    quan_relu_matrix = saturate_int8_func(
                        quan_relu_output)
                    quan_relu_matrix_bias2_add = saturate_int16_func(
                        quan_relu_matrix + bias2_matrix)

                with open(path + "tmp_quan_relu_maxtix" + name + ".txt", "a") as f:
                    np.savetxt(f, quan_relu_matrix,
                               fmt="%d", delimiter=' ')
                with open(path + "tmp_bias2_maxtix" + name + ".txt", "a") as f:
                    np.savetxt(f, bias2_matrix,
                               fmt="%d", delimiter=' ')
                with open(path + "tmp_quan_relu_bias2_add_maxtix" + name + ".txt", "a") as f:
                    np.savetxt(f, bias2_matrix,
                               fmt="%d", delimiter=' ')
    return output


def test_conv2d_matmul_total_random():
    # 随机生成输入张量
    batch_size = 1
    # in_channels = 32
    # input_height = 30
    # input_width = 20

    # # 随机生成卷积核
    # out_channels = 64
    # kernel_height = 3
    # kernel_width = 4

    # # 随机生成卷积参数
    # padding = (2, 3)
    # stride = (1, 2)
    # dilation = (2, 1)

    # basic_ow = 10
    # basic_oh = 6
    # basic_ic = 16
    # basic_oc = 32
    # basic_rs = 9
    # block_ic = 8
    # block_oc = 4

    in_channels = 128
    input_height = 80
    input_width = 80

    # 随机生成卷积核
    out_channels = 33
    kernel_height = 1
    kernel_width = 1

    # 随机生成卷积参数
    padding = (0, 0)
    stride = (1, 1)
    dilation = (1, 1)

    block_ic = 16
    block_oc = 32
    basic_ow = 20
    basic_oh = 20
    basic_ic = 32
    basic_oc = 32
    basic_rs = 1

    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1
    print(output_width)
    print(output_height)

    input_tensor = np.random.randn(
        in_channels, input_height, input_width)

    kernel = np.random.randn(
        out_channels, in_channels,
        kernel_height, kernel_width)

    # 随机生成偏置项
    bias = np.random.randn(
        out_channels, 1, 1)
    print('input_tensor:', input_tensor)
    print('kernel:', kernel)
    print('bias:', bias)

    # # 计算卷积结果
    # output = conv2d(input_tensor, kernel, bias, padding, stride, dilation)

    # # 使用PyTorch计算卷积结果

    output_matmul = conv2d_matmul(
        input_tensor, kernel, bias, padding, stride, dilation, block_ic, block_oc)

    output_matmul_total = conv2d_matmul_total(
        input_tensor, kernel, bias, padding, stride, dilation,
        basic_ow,
        basic_oh,
        basic_ic,
        basic_oc,
        basic_rs,
        block_ic,
        block_oc)

    input_tensor_b = input_tensor.reshape(
        1, in_channels, input_height, input_width)

    # print('input_tensor:', input_tensor)
    # print('input_tensor_b:', input_tensor_b)

    input_tensor_pt = torch.tensor(input_tensor_b)
    kernel_pt = torch.tensor(kernel)
    bias_pt = torch.tensor(bias.reshape(out_channels))
    conv2d_pt = nn.Conv2d(in_channels, out_channels, (kernel_height, kernel_width),
                          stride=stride, padding=padding, dilation=dilation, bias=True)
    conv2d_pt.weight.data = kernel_pt
    conv2d_pt.bias.data = bias_pt
    output_pt = conv2d_pt(input_tensor_pt)
    output_pt = output_pt.detach().numpy()

    # print('output=========================================\n', output)
    print('output_matmul=========================================\n', output_matmul)
    print('output_matmul_total=========================================\n',
          output_matmul_total)
    print('output_pt=========================================\n', output_pt)

    # 验证输出结果是否与PyTorch结果相同
    assert np.allclose(output_pt, output_matmul, rtol=1e-5,
                       atol=1e-8), "Conv2D output does not match PyTorch output"
    # assert np.allclose(output_matmul, output_matmul_total, rtol=1e-5,
    #                    atol=1e-8), "Conv2D output does not match PyTorch output"

    print("Conv2D random test passed!")


def test_conv2d_matmul_total_matmul_random():
    # 随机生成输入张量
    batch_size = 1
    in_channels = 32
    input_height = 1
    input_width = 20

    # 随机生成卷积核
    out_channels = 64
    kernel_height = 1
    kernel_width = 1

    # 随机生成卷积参数
    padding = (0, 0)
    stride = (1, 1)
    dilation = (1, 1)

    basic_ow = 10
    basic_oh = 1
    basic_ic = 16
    basic_oc = 32
    basic_rs = 1
    block_ic = 8
    block_oc = 4

    output_width = (
        input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
    output_height = (
        input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1
    print(output_width)
    print(output_height)

    input_tensor = np.random.randn(
        in_channels, input_height, input_width)

    kernel = np.random.randn(
        out_channels, in_channels,
        kernel_height, kernel_width)

    # 随机生成偏置项
    bias = np.random.randn(
        out_channels, output_height, output_width)
    print('input_tensor:', input_tensor.shape)
    print('kernel:', kernel.shape)
    print('bias:', bias.shape)

    input_tensor_matrix = input_tensor.reshape(
        in_channels, input_height * input_width).transpose(1, 0)
    kernel_matrix = kernel.reshape(out_channels, in_channels).transpose(1, 0)
    bias_matrix = bias.reshape(
        out_channels, output_height * output_width).transpose(1, 0)
    print('input_tensor_matrix:', input_tensor_matrix.shape)
    print('kernel_matrix:', kernel_matrix.shape)
    print('bias_matrix:', bias_matrix.shape)
    output_matmul_numpy = input_tensor_matrix.dot(kernel_matrix) + bias_matrix
    output_matmul_numpy_reshape = output_matmul_numpy.transpose(1, 0).reshape(
        out_channels, output_height, output_width)
    output_matmul_total = conv2d_matmul_total(
        input_tensor, kernel, bias, padding, stride, dilation,
        basic_ow,
        basic_oh,
        basic_ic,
        basic_oc,
        basic_rs,
        block_ic,
        block_oc,
        bias_mode=1)

    # print('output_matmul=========================================\n', output_matmul_numpy_reshape)
    # print('output_matmul_total=========================================\n',
    #       output_matmul_total)

    assert np.allclose(output_matmul_numpy_reshape, output_matmul_total, rtol=1e-5,
                       atol=1e-8), "Conv2D output does not match PyTorch output"

    print("matmul random test passed!")


def rearrange_feature_map(feature_map, block_c):
    """
    将三维特征图重排为二维数组

    Args:
    feature_map (np.ndarray): 三维特征图,形状为(channel, height, width )
    block_c (int): 通道方向的分块大小

    Returns:
    np.ndarray: 重排后的二维数组,形状为(height * width * math.ceil(channels / block_c), block_c)
    """
    channels, height, width = feature_map.shape
    ceil_channels = math.ceil(channels / block_c) * block_c
    ceil_feature_map = np.zeros((ceil_channels, height, width))
    ceil_feature_map[0:channels, :, :] = feature_map
    # assert channels % block_c == 0, "Channels must be divisible by block_c"

    # 计算重排后的行数
    num_rows = height * width * math.ceil(channels / block_c)

    # 重塑特征图为二维数组
    reshaped_feature_map = ceil_feature_map.reshape(
        ceil_channels, height * width)
    # print(reshaped_feature_map)
    rearranged_feature_map = np.zeros((block_c, num_rows))
    for i in range(ceil_channels // block_c):
        rearranged_feature_map[:, height * width * i: height * width *
                               (i + 1)] = reshaped_feature_map[block_c * i:block_c * (i + 1), :]

    return rearranged_feature_map.T


def test_rearrange_feature_map():
    # 创建一个示例特征图
    in_channels = 8
    input_height = 3
    input_width = 4
    input_tensor = np.random.randint(-128, 128, size=(
        in_channels, input_height, input_width))
    print("Original feature map:")
    print(input_tensor)

    # 设定通道方向的分块大小
    block_c = 4

    # 调用重排函数
    rearranged_feature_map = rearrange_feature_map(input_tensor, block_c)
    print("\nRearranged feature map:")
    print(rearranged_feature_map)


def rearrange_kernel(kernel, block_c):
    """
    将四维权重重排为二维数组

    Args:
    kernel (np.ndarray): 四维权重,形状为(out_channels, in_channels, kernel_height, kernel_width)
    block_c (int): 通道方向的分块大小

    Returns:
    np.ndarray: 重排后的二维数组,形状为(kernel_height * kernel_width * out_channels * in_channels // block_c, block_c)
    """
    out_channels, in_channels, kernel_height, kernel_width = kernel.shape
    ceil_out_channels = math.ceil(out_channels / block_c) * block_c
    # assert out_channels % block_c == 0, "Channels must be divisible by block_c"
    ceil_kernel = np.zeros(
        (ceil_out_channels, in_channels, kernel_height, kernel_width))
    ceil_kernel[0:out_channels, :, :, :] = kernel

    win_rs = kernel_height * kernel_width
    weight = ceil_kernel.reshape(ceil_out_channels, in_channels,
                                 kernel_height * kernel_width)

    # 计算重排后的行数
    # print('weight:===========================\n', weight)
    # print('weight0:', weight[0:2, :, 0])
    num_rows = win_rs * ceil_out_channels * in_channels // block_c
    rs_row = in_channels * math.ceil(out_channels / block_c)

    rearranged_kernel = np.zeros((num_rows, block_c))
    for rs in range(win_rs):
        rs_rows = rs * rs_row
        for i in range(ceil_out_channels // block_c):
            rearranged_kernel[(in_channels * i) +
                              rs_rows:(in_channels * (i + 1)) + rs_rows, :] = weight[block_c * i:block_c * (i + 1), :,
                                                                                     rs].T

    return rearranged_kernel


def test_rearrange_kernel():
    in_channels = 2

    out_channels = 8
    kernel_height = 2
    kernel_width = 2
    kernel = np.random.randint(-128, 128, size=(out_channels, in_channels,
                                                kernel_height, kernel_width))
    print("Original kernel:")
    print(kernel)

    # 设定通道方向的分块大小
    block_c = 4

    # 调用重排函数
    rearranged_kernel = rearrange_kernel(kernel, block_c)
    print("\nRearranged kernel:")
    print(rearranged_kernel)


def rearrange_kernel_new(kernel, block_c):
    """
    将四维权重重排为二维数组

    Args:
    kernel (np.ndarray): 四维权重,形状为(out_channels, in_channels, kernel_height, kernel_width)
    block_c (int): 通道方向的分块大小

    Returns:
    np.ndarray: 重排后的二维数组,形状为(kernel_height * kernel_width * out_channels * in_channels // block_c, block_c)
    """
    out_channels, in_channels, kernel_height, kernel_width = kernel.shape
    ceil_out_channels = math.ceil(out_channels / block_c) * block_c
    # assert out_channels % block_c == 0, "Channels must be divisible by block_c"
    ceil_kernel = np.zeros(
        (ceil_out_channels, in_channels, kernel_height, kernel_width))
    ceil_kernel[0:out_channels, :, :, :] = kernel
    ceil_kernel = ceil_kernel.transpose(0, 2, 3, 1)
    win_rs = kernel_height * kernel_width
    weight = ceil_kernel.reshape(
        ceil_out_channels, kernel_height * kernel_width * in_channels)

    # 计算重排后的行数
    # print('weight:===========================\n', weight)
    # print('weight0:', weight[0:2, :, 0])
    num_rows = win_rs * ceil_out_channels * in_channels // block_c

    rearranged_kernel = np.zeros((block_c, num_rows))

    for i in range(ceil_out_channels // block_c):
        rearranged_kernel[:, (in_channels * kernel_height * kernel_width * i):(in_channels *
                                                                               kernel_height * kernel_width * (
                                                                                   i + 1))] = weight[
            block_c * i:block_c * (
                i + 1),
            :]

    return rearranged_kernel.T


def test_rearrange_kernel_new():
    in_channels = 2

    out_channels = 8
    kernel_height = 2
    kernel_width = 2
    kernel = np.random.randint(-128, 128, size=(out_channels, in_channels,
                                                kernel_height, kernel_width))
    print("Original kernel:")
    print(kernel)

    # 设定通道方向的分块大小
    block_c = 4

    # 调用重排函数
    rearranged_kernel = rearrange_kernel_new(kernel, block_c)
    print("\nRearranged kernel:")
    print(rearranged_kernel)


def rearrange_total_kernel(kernel, is_int16=0, bus_width=32):
    block_c = 0
    if is_int16:
        block_c = bus_width // 16
    else:
        block_c = bus_width // 8

    out_channels, in_channels, kernel_height, kernel_width = kernel.shape
    ceil_out_channels = math.ceil(out_channels / block_c) * block_c
    # assert out_channels % block_c == 0, "Channels must be divisible by block_c"
    ceil_kernel = np.zeros(
        (ceil_out_channels, in_channels, kernel_height, kernel_width))
    ceil_kernel[0:out_channels, :, :, :] = kernel

    win_rs = kernel_height * kernel_width
    weight = ceil_kernel.reshape(ceil_out_channels, in_channels,
                                 kernel_height * kernel_width)

    # 计算重排后的行数
    # print('weight:===========================\n', weight)
    # print('weight0:', weight[0:2, :, 0])
    num_rows = win_rs * ceil_out_channels * in_channels // block_c
    rs_row = in_channels * math.ceil(out_channels / block_c)
    oc_num = ceil_out_channels // block_c

    rearranged_kernel = np.zeros((num_rows, block_c))
    for rs in range(win_rs):
        rs_rows = rs * rs_row
        for ic in range(in_channels):
            for oc in range(oc_num):
                rearranged_kernel[rs_rows + ic * oc_num + oc,
                                  :] = weight[block_c * oc:block_c * (oc + 1), ic, rs].T

    return rearranged_kernel


def rearrange_total_kernel_nc1hwc0(kernel, c0, is_int16=0, bus_width=32):
    block_c = 0
    if is_int16:
        block_c = bus_width // 16
    else:
        block_c = bus_width // 8

    out_channels, in_channels, kernel_height, kernel_width = kernel.shape
    ceil_out_channels = math.ceil(out_channels / block_c) * block_c
    # assert out_channels % block_c == 0, "Channels must be divisible by block_c"
    ceil_kernel = np.zeros(
        (ceil_out_channels, in_channels, kernel_height, kernel_width))
    ceil_kernel[0:out_channels, :, :, :] = kernel
    win_rs = kernel_height * kernel_width
    num_rows = win_rs * ceil_out_channels * in_channels // block_c
    rearranged_kernel = np.zeros((num_rows, block_c))

    c1_num = math.ceil(ceil_out_channels / c0)
    basic_c0 = c0
    remain_c0 = basic_c0 if ceil_out_channels % basic_c0 == 0 else ceil_out_channels % basic_c0

    basic_num_rows = win_rs * basic_c0 * in_channels // block_c
    remain_num_rows = win_rs * remain_c0 * in_channels // block_c

    for c1 in range(math.ceil(ceil_out_channels / c0)):
        curr_c0 = remain_c0 if c1 == c1_num - 1 else basic_c0
        curr_num_rows = remain_num_rows if c1 == c1_num - 1 else basic_num_rows

        c_index = np.arange(curr_c0) + basic_c0 * c1
        num_rows_index = np.arange(curr_num_rows) + basic_num_rows * c1

        kernel_part = ceil_kernel[c_index, :, :, :]
        rearranged_kernel[num_rows_index, :] = rearrange_total_kernel(
            kernel_part, is_int16=is_int16, bus_width=bus_width)

    return rearranged_kernel


def test_rearrange_total_kernel_nc1hwc0():
    in_channels = 2

    out_channels = 8
    kernel_height = 2
    kernel_width = 2
    kernel = np.random.randint(-128, 128, size=(out_channels, in_channels,
                                                kernel_height, kernel_width))
    print("Original kernel:")
    print(kernel)

    # 调用重排函数
    block_oc = 4
    rearranged_kernel = rearrange_total_kernel_nc1hwc0(
        kernel, c0=block_oc, is_int16=0, bus_width=32)
    print("\nRearranged kernel:")
    print(rearranged_kernel)


def rearrange_total_imap(imap, is_int16=0, bus_width=32):
    block_c = 0
    if is_int16:
        block_c = bus_width // 16
    else:
        block_c = bus_width // 8

    in_channels, height, width = imap.shape
    ceil_in_channels = math.ceil(in_channels / block_c) * block_c
    # print('ceil_in_channels:', ceil_in_channels)
    # assert out_channels % block_c == 0, "Channels must be divisible by block_c"
    ceil_imap = np.zeros(
        (ceil_in_channels, height, width))
    ceil_imap[0:in_channels, :, :] = imap
    # print('ceil_imap[0:in_channels, 0, 0]', ceil_imap[0:in_channels, 0, 0])

    num_rows = height * ceil_in_channels * width // block_c
    h_row = width * math.ceil(ceil_in_channels / block_c)
    ic_num = ceil_in_channels // block_c

    rearranged_imap = np.zeros((num_rows, block_c))
    for h in range(height):
        h_rows = h * h_row
        for w in range(width):
            for ic in range(ic_num):
                rearranged_imap[h_rows + w * ic_num + ic,
                                :] = ceil_imap[block_c * ic:block_c * (ic + 1), h, w].T

    return rearranged_imap


def rearrange_total_imap_nc1hwc0(imap, c0, is_int16=0, bus_width=32):
    block_c = 0
    if is_int16:
        block_c = bus_width // 16
    else:
        block_c = bus_width // 8

    in_channels, height, width = imap.shape
    ceil_in_channels = math.ceil(in_channels / block_c) * block_c
    # print('ceil_in_channels:', ceil_in_channels)
    # assert out_channels % block_c == 0, "Channels must be divisible by block_c"
    ceil_imap = np.zeros(
        (ceil_in_channels, height, width))
    ceil_imap[0:in_channels, :, :] = imap

    num_rows = height * ceil_in_channels * width // block_c
    rearranged_imap = np.zeros((num_rows, block_c))

    c1_num = math.ceil(ceil_in_channels / c0)
    basic_c0 = c0
    remain_c0 = basic_c0 if ceil_in_channels % basic_c0 == 0 else ceil_in_channels % basic_c0

    basic_num_rows = height * basic_c0 * width // block_c
    remain_num_rows = height * remain_c0 * width // block_c

    for c1 in range(math.ceil(ceil_in_channels / c0)):
        curr_c0 = remain_c0 if c1 == c1_num - 1 else basic_c0
        curr_num_rows = remain_num_rows if c1 == c1_num - 1 else basic_num_rows

        c_index = np.arange(curr_c0) + basic_c0 * c1
        num_rows_index = np.arange(curr_num_rows) + basic_num_rows * c1

        # print("ceil_imap.shpae:", ceil_imap.shape)
        # print("c_index.shpae:", c_index.shape)
        # print("c_index:", c_index)
        # print('num_rows_index:',curr_num_rows)
        imap_part = ceil_imap[c_index, :, :]
        rearranged_imap[num_rows_index, :] = rearrange_total_imap(
            imap_part, is_int16=is_int16, bus_width=bus_width)

    return rearranged_imap


def rearrange_total_bias(bias, is_int16=0, bus_width=32):
    block_c = 0
    if is_int16:
        block_c = bus_width // 32  # int16时 bias为int32
    else:
        block_c = bus_width // 16  # int8时 bias为int16

    out_channels, height, width = bias.shape
    ceil_out_channels = math.ceil(out_channels / block_c) * block_c
    # assert out_channels % block_c == 0, "Channels must be divisible by block_c"
    ceil_imap = np.zeros(
        (ceil_out_channels, height, width))
    ceil_imap[0:out_channels, :, :] = bias

    num_rows = height * ceil_out_channels * width // block_c
    h_row = width * math.ceil(ceil_out_channels / block_c)
    ic_num = ceil_out_channels // block_c

    rearranged_bias = np.zeros((num_rows, block_c))
    for h in range(height):
        h_rows = h * h_row
        for w in range(width):
            for ic in range(ic_num):
                rearranged_bias[h_rows + w * ic_num + ic,
                                :] = ceil_imap[block_c * ic:block_c * (ic + 1), h, w].T

    return rearranged_bias


def rearrange_total_bias_nc1hwc0(bias, c0, is_int16=0, bus_width=32):
    block_c = 0
    if is_int16:
        block_c = bus_width // 32  # int16时 bias为int32
    else:
        block_c = bus_width // 16  # int8时 bias为int16

    out_channels, height, width = bias.shape
    ceil_out_channels = math.ceil(out_channels / block_c) * block_c

    ceil_bias = np.zeros(
        (ceil_out_channels, height, width))
    ceil_bias[0:out_channels, :, :] = bias

    num_rows = height * ceil_out_channels * width // block_c
    rearranged_bias = np.zeros((num_rows, block_c))

    c1_num = math.ceil(ceil_out_channels / c0)
    basic_c0 = c0
    remain_c0 = basic_c0 if ceil_out_channels % basic_c0 == 0 else ceil_out_channels % basic_c0

    basic_num_rows = height * basic_c0 * width // block_c
    remain_num_rows = height * remain_c0 * width // block_c

    for c1 in range(math.ceil(ceil_out_channels / c0)):
        curr_c0 = remain_c0 if c1 == c1_num - 1 else basic_c0
        curr_num_rows = remain_num_rows if c1 == c1_num - 1 else basic_num_rows

        c_index = np.arange(curr_c0) + basic_c0 * c1
        num_rows_index = np.arange(curr_num_rows) + basic_num_rows * c1

        bias_part = ceil_bias[c_index, :, :]
        rearranged_bias[num_rows_index, :] = rearrange_total_bias(
            bias_part, is_int16=is_int16, bus_width=bus_width)

    return rearranged_bias


def test_rearrange_total_imap():
    # 创建一个示例特征图
    in_channels = 5
    input_height = 3
    input_width = 2
    input_tensor = np.random.randint(-128, 128, size=(
        in_channels, input_height, input_width))
    print("Original feature map:")
    print(input_tensor)

    # 设定通道方向的分块大小
    block_c = 4

    # 调用重排函数
    rearranged_feature_map = rearrange_total_imap(
        input_tensor, is_int16=0)
    print("\nRearranged feature map:")
    print(rearranged_feature_map)


np.random.seed(0)
path = "D:\\code\\test\\verilog\\ai_engine\\ai_engine\\rtl\\tb\\sys\\python\\ai_acce_maxpool_nc1hwc0_case1_signed\\"

# bus_width = 64
# in_channels = 32
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 3
# kernel_width = 4
# padding = (1, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 1)
# dilation = (1, 2)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 5
# basic_ic = 16
# basic_oc = 32
# basic_rs = 9
# bias_mode = 0


# bus_width = 64
# in_channels = 8
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 3
# kernel_width = 4
# padding = (1, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 1)
# dilation = (1, 2)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 5
# basic_ic = 8
# basic_oc = 32
# basic_rs = 9
# bias_mode = 0

# bus_width = 64
# in_channels = 8
# input_height = 20
# input_width = 20
# out_channels = 8
# kernel_height = 3
# kernel_width = 4
# padding = (1, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 1)
# dilation = (1, 2)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 5
# basic_ic = 8
# basic_oc = 8
# basic_rs = 9
# bias_mode = 0


# bus_width = 64
# in_channels = 64
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 3
# kernel_width = 3
# padding = (2, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 2)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 6
# basic_oh = 6
# basic_ic = 32
# basic_oc = 64
# basic_rs = 9
# bias_mode = 0


# bus_width = 64
# in_channels = 32
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 3
# kernel_width = 3
# padding = (2, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 2)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 6
# basic_oh = 6
# basic_ic = 32
# basic_oc = 32
# basic_rs = 9
# bias_mode = 0


# 一次性全部加载weight的情况下omap ram会发生bias写和omap读的冲突
# bus_width = 64
# in_channels = 32
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 3
# kernel_width = 3
# padding = (2, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 2)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 6
# basic_oh = 6
# basic_ic = 32
# basic_oc = 64
# basic_rs = 9
# bias_mode = 0


# bus_width = 64
# in_channels = 32
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 3
# kernel_width = 3
# padding = (2, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 2)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 11
# basic_oh = 11
# basic_ic = 32
# basic_oc = 32
# basic_rs = 9
# bias_mode = 0

# bus_width = 64
# in_channels = 32
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (2, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 2)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 12
# basic_oh = 12
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# bias_mode = 0


# bus_width = 64
# in_channels = 32
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 20
# basic_oh = 20
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# bias_mode = 0


# bus_width = 64
# in_channels = 32
# input_height = 40
# input_width = 40
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 1)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# bias_mode = 0


# bus_width = 64
# in_channels = 32
# input_height = 40
# input_width = 40
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 1)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 1
# bias_mode = 1
# use_relu = 1


# bus_width = 64
# in_channels = 32
# input_height = 40
# input_width = 40
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 1)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 0
# bias_mode = 1
# use_relu = 1


# bus_width = 64
# in_channels = 32
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 1
# bias_mode = 0
# use_relu = 1

# bus_width = 64
# in_channels = 32
# input_height = 20
# input_width = 20
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 1
# bias_mode = 0
# use_relu = 1


# bus_width = 64
# in_channels = 64
# input_height = 40
# input_width = 40
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 1
# bias_mode = 1
# use_relu = 1


# bus_width = 64
# in_channels = 32
# input_height = 40
# input_width = 40
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 1
# bias_mode = 1
# use_relu = 1


# bus_width = 64
# in_channels = 32
# input_height = 40
# input_width = 40
# out_channels = 64
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 64
# basic_rs = 1
# use_bias = 1
# bias_mode = 1
# use_relu = 1

# bus_width = 64
# in_channels = 32
# input_height = 40
# input_width = 40
# out_channels = 40
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 10
# basic_oh = 10
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 1
# bias_mode = 0
# use_relu = 1


# bus_width = 64
# in_channels = 128
# input_height = 80
# input_width = 80
# out_channels = 40
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 20
# basic_oh = 20
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 1
# bias_mode = 0
# use_relu = 1

# bus_width = 64
# in_channels = 8
# input_height = 80
# input_width = 80
# out_channels = 32
# kernel_height = 6
# kernel_width = 6
# padding = (2, 2)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 2)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 20
# basic_oh = 20
# basic_ic = 8
# basic_oc = 32
# basic_rs = 18
# use_bias = 1
# bias_mode = 0
# use_relu = 1


# bus_width = 64
# in_channels = 24
# input_height = 80
# input_width = 80
# out_channels = 32
# kernel_height = 6
# kernel_width = 1
# padding = (2, 1)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 20
# basic_oh = 20
# basic_ic = 24
# basic_oc = 32
# basic_rs = 6
# use_bias = 1
# bias_mode = 0
# use_relu = 1

# bus_width = 64
# in_channels = 32
# input_height = 80
# input_width = 80
# out_channels = 64
# kernel_height = 3
# kernel_width = 3
# padding = (1, 1)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (2, 2)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 15
# basic_oh = 15
# basic_ic = 32
# basic_oc = 40
# basic_rs = 9
# use_bias = 1
# bias_mode = 0
# use_relu = 1


# bus_width = 64
# in_channels = 72
# input_height = 10
# input_width = 10
# out_channels = 72
# kernel_height = 1
# kernel_width = 1
# padding = (0, 0)  # (padding_y,padding_x)
# left_padding = padding[1]
# right_padding = padding[1]
# top_padding = padding[0]
# bottom_padding = padding[0]
# stride = (1, 1)
# dilation = (1, 1)
# block_ic = 16
# block_oc = 16
# basic_ow = 5
# basic_oh = 5
# basic_ic = 32
# basic_oc = 32
# basic_rs = 1
# use_bias = 1
# bias_mode = 0
# use_relu = 1


bus_width = 64
in_channels = 64
input_height = 12
input_width = 10
out_channels = 64
kernel_height = 3
kernel_width = 3
padding = (0, 0)  # (padding_y,padding_x)
left_padding = padding[1]
right_padding = padding[1]
top_padding = padding[0]
bottom_padding = padding[0]
stride = (1, 1)
dilation = (1, 1)
block_ic = 16
block_oc = 16
basic_ow = 5
basic_oh = 6
basic_ic = 32
basic_oc = 32
basic_rs = 9
use_bias = 0
bias_mode = 0
use_relu = 0
use_bias2_add = 0

is_pool = 1
pool_type = "maxpool"

if is_pool:
    assert use_bias == 0
    assert in_channels == out_channels
    assert basic_rs == kernel_height * kernel_width
    if pool_type == "maxpool":
        scale_fp32_int8 = 1
        scale_fp32_int16 = 1
    elif pool_type == "avgpool":
        scale_fp32_int8 = 1 / (kernel_height * kernel_width)
        scale_fp32_int16 = 1 / (kernel_height * kernel_width)

    zero_point_in = 0
    zero_point_out = 0
else:
    scale_fp32_int8 = 0.001
    scale_fp32_int16 = 0.000001
    zero_point_in = -128
    zero_point_out = -128

bias2_scale_fp32_int8 = 0.49
bias2_scale_int8, bias2_shift_int8 = frexp_int8(bias2_scale_fp32_int8)
bias2_scale_int16, bias2_shift_int16 = frexp_int16(bias2_scale_fp32_int8)
print('bias2_scale_int8, bias2_shift_int8:',
      bias2_scale_int8, bias2_shift_int8)
print('bias2_scale_int16, bias2_shift_int16:',
      bias2_scale_int16, bias2_shift_int16)

scale_int8, shift_int8 = frexp_int16(scale_fp32_int8)
print('scale_int8, shift_int8:', scale_int8, shift_int8)

scale_int16, shift_int16 = frexp_int16(scale_fp32_int16)
print('scale_int16, shift_int16:', scale_int16, shift_int16)

input_height_p = input_height + 2 * padding[0]
input_width_p = input_width + 2 * padding[1]
output_width = (
    input_width + 2 * padding[1] - dilation[1] * (kernel_width - 1) - 1) // stride[1] + 1
output_height = (
    input_height + 2 * padding[0] - dilation[0] * (kernel_height - 1) - 1) // stride[0] + 1

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

remain_ih = (input_height + top_padding + bottom_padding) - \
    basic_oh_sy * (num_oh - 1)
remain_iw = (input_width + left_padding + right_padding) - \
    basic_ow_sx * (num_ow - 1)

if not is_pool:
    assert remain_ow * remain_oh >= block_ic
assert block_ic == block_oc

print('basic_iw:', basic_iw)
print('basic_ih:', basic_ih)
print('basic_ow_sx:', basic_ow_sx)
print('basic_oh_sy:', basic_oh_sy)
print('remain_ih:', remain_ih)
print('remain_iw:', remain_iw)

assert (basic_ow_sx * (num_ow - 1) +
        remain_iw) == (
    input_width + left_padding + right_padding), "(basic_ow_sx*(num_ow-1)+remain_iw)  == input_width+left_padding+right_padding"

assert (basic_oh_sy * (num_oh - 1) +
        remain_ih) == (
    input_height + top_padding + bottom_padding), "(basic_oh_sy*(num_oh-1)+remain_ih)  == input_height+top_padding+bottom_padding"

imap_depth = 2 ** 11
weight_depth = 2 ** 11
omap_depth = 2 ** 11
fifo_depth = 2 ** 10

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
print('    parameter Scale_int8 = {};'.format(scale_int8))
print('    parameter Shift_int8 = {};'.format(shift_int8))
print('    parameter Scale_int16 = {};'.format(scale_int16))
print('    parameter Shift_int16 = {};'.format(shift_int16))
print('    parameter ZERO_POINT_IN = {};'.format(zero_point_in))
print('    parameter ZERO_POINT_OUT = {};'.format(zero_point_out))

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
    assert basic_rs * basic_ic * \
        math.ceil(basic_oc / (block_oc * 2)) < weight_depth
    assert basic_ow * basic_oh < fifo_depth

    assert (basic_ic % (block_ic * 2) == 0 or basic_ic == in_channels)
    assert (basic_oc % (block_oc * 2) == 0 or basic_oc == out_channels)

    input_tensor = np.random.randint(-128, 127, size=(
        in_channels, input_height, input_width))
    kernel = np.random.randint(-128, 128, size=(out_channels, in_channels,
                                                kernel_height, kernel_width))
    kernel_reshape = kernel.reshape(out_channels, in_channels,
                                    kernel_height * kernel_width)
    if bias_mode == 1:
        if use_bias:
            bias = np.random.randint(-32768, 32767,
                                     size=(out_channels, output_height, output_width))
        else:
            bias = np.zeros((out_channels, output_height, output_width))
    else:
        if use_bias:
            bias = np.random.randint(-32768, 32767,
                                     size=(out_channels, 1, 1))
        else:
            bias = np.zeros((out_channels, 1, 1))
    if use_bias2_add:
        bias2 = np.random.randint(-64, 63,
                                  size=(out_channels, output_height, output_width))
    else:
        bias2 = np.zeros((out_channels, output_height, output_width))

    print('input_tensor[:, 0, 0]', input_tensor[:, 0, 0])
    print('kernel_reshape[:, 0, 0]', kernel_reshape[:, 0, 0])

    if is_pool:
        output = pool_total(input_tensor=input_tensor, bias2=(np.around(bias2 * bias2_scale_int8 *
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
        output = conv2d_matmul_total(input_tensor=input_tensor - zero_point_in, kernel=kernel, bias=bias,
                                     bias2=(np.around(bias2 * bias2_scale_int8 *
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
                                     savefile=1, path=path, name="_int8")
    sat_data = output.astype(np.float64)
    quan_output = (np.around(sat_data * scale_int8 *
                             (2 ** (-15 - shift_int8))))

    # 使用 PyTorch 标准池化函数
    if is_pool:
        if pool_type == "maxpool":
            torch_pool_result = F.max_pool2d(torch.tensor(input_tensor.astype(float)), kernel_size=(
                kernel_height, kernel_width), stride=stride, padding=padding, dilation=dilation)
        else:
            torch_avgpool_result = F.avg_pool2d(torch.tensor(input_tensor.astype(float)), kernel_size=(
                kernel_height, kernel_width), stride=stride, padding=padding, dilation=dilation)
    max_diff = np.max(np.abs(output - torch_pool_result.detach().numpy()))
    print('max_diff:', max_diff)

    if use_relu:
        quan_relu_output = relu_func(quan_output) + zero_point_out
        quan_sat_relu_output = saturate_int8_func(quan_relu_output)
    else:
        quan_relu_output = quan_output + zero_point_out
        quan_sat_relu_output = saturate_int8_func(quan_relu_output)

    if use_bias2_add:
        quan_sat_relu_output_add = saturate_int8_func(quan_sat_relu_output + (np.around(bias2 * bias2_scale_int8 *
                                                                                        (2 ** (
                                                                                            -7 - bias2_shift_int8)))))
    else:
        quan_sat_relu_output_add = quan_sat_relu_output

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

# case for int16 -32768~ +32767
for _ in range(1):
    assert in_channels % (
        bus_width / 16) == 0, "in_channels must be divisible by bus_width/16"
    assert out_channels % (
        bus_width / 16) == 0, "out_channels must be divisible by bus_width/16"

    assert basic_ic % (
        bus_width / 16) == 0, "basic_ic must be divisible by bus_width/16"
    assert basic_oc % (
        bus_width / 16) == 0, "basic_oc must be divisible by bus_width/16"
    assert basic_iw * basic_ih * math.ceil(basic_ic / (block_ic)) < imap_depth
    assert basic_ow * basic_oh * math.ceil(basic_oc / (block_oc)) < omap_depth
    assert basic_rs * basic_ic * \
        math.ceil(basic_oc / (block_oc)) < weight_depth

    assert basic_ow * basic_oh < fifo_depth

    assert (basic_ic % (block_ic) == 0 or basic_ic == in_channels)
    assert (basic_oc % (block_oc) == 0 or basic_oc == out_channels)

    input_tensor = np.random.randint(-32768, 32767, size=(
        in_channels, input_height, input_width))
    kernel = np.random.randint(-32768, 32767, size=(out_channels, in_channels,
                                                    kernel_height, kernel_width))
    if bias_mode == 1:
        if use_bias:
            bias = np.random.randint(-32768, 32767,
                                     size=(out_channels, output_height, output_width))
        else:
            bias = np.zeros((out_channels, output_height, output_width))
    else:
        if use_bias:
            bias = np.random.randint(-32768, 32767,
                                     size=(out_channels, 1, 1))
        else:
            bias = np.zeros((out_channels, 1, 1))

    if use_bias2_add:
        bias2 = np.random.randint(-32768, 32767,
                                  size=(out_channels, output_height, output_width))
    else:
        bias2 = np.zeros((out_channels, output_height, output_width))

    if is_pool:
        output = pool_total(input_tensor=input_tensor, bias2=(np.around(bias2 * bias2_scale_int16 *
                                                                        (2 ** (-7 - bias2_shift_int16)))),
                            padding=padding, stride=stride, dilation=dilation, kernel_height=kernel_height,
                            kernel_width=kernel_width, pool_type=pool_type,
                            basic_ow=basic_ow,
                            basic_oh=basic_oh,
                            basic_oc=basic_oc,
                            block_ic=block_ic,
                            block_oc=block_oc,
                            scale=scale_int8,
                            shift=shift_int8,
                            zero_point=0,
                            is_int16=1,
                            use_relu=use_relu,
                            savefile=1, path=path, name="_int16")
    else:
        output = conv2d_matmul_total(input_tensor=input_tensor - zero_point_in, kernel=kernel, bias=bias,
                                     bias2=(np.around(bias2 * bias2_scale_int16 *
                                                      (2 ** (-15 - bias2_shift_int16)))),
                                     padding=padding, stride=stride, dilation=dilation,
                                     basic_ow=basic_ow,
                                     basic_oh=basic_oh,
                                     basic_ic=basic_ic,
                                     basic_oc=basic_oc,
                                     basic_rs=basic_rs,
                                     block_ic=block_ic,
                                     block_oc=block_oc,
                                     scale=scale_int16,
                                     shift=shift_int16,
                                     zero_point=zero_point_out,
                                     is_int16=1,
                                     bias_mode=bias_mode,
                                     use_relu=use_relu,
                                     savefile=1, path=path, name="_int16")

    sat_data = output.astype(np.float64)
    quan_output = (np.around(sat_data * scale_int16 *
                             (2 ** (-15 - shift_int16))))

    if use_relu:
        quan_relu_output = relu_func(quan_output) + zero_point_out
        quan_sat_relu_output = saturate_int16_func(quan_relu_output)
    else:
        quan_relu_output = quan_output + zero_point_out
        quan_sat_relu_output = saturate_int16_func(quan_relu_output)

    if use_bias2_add:
        quan_sat_relu_output_add = saturate_int16_func(quan_sat_relu_output + (np.around(bias2 * bias2_scale_int16 *
                                                                                         (2 ** (
                                                                                             -15 - bias2_shift_int16)))))
    else:
        quan_sat_relu_output_add = quan_sat_relu_output
    # print('output int16=========================================\n', output)
    np.savetxt(path + "input_tensor_int16.txt",
               rearrange_total_imap_nc1hwc0(input_tensor, c0=block_oc, is_int16=1, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "kernel_int16.txt",
               rearrange_total_kernel_nc1hwc0(
                   kernel, c0=block_oc, is_int16=1, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "bias_int16.txt",
               rearrange_total_bias_nc1hwc0(bias, c0=block_oc, is_int16=1, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "bias2_int16.txt",
               rearrange_total_imap_nc1hwc0(bias2, c0=block_oc, is_int16=1, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "output_int16.txt",
               rearrange_total_imap_nc1hwc0(output, c0=block_oc, is_int16=1, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "quan_output_int16.txt",
               rearrange_total_imap_nc1hwc0(quan_output, c0=block_oc, is_int16=1, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "quan_relu_output_int16.txt",
               rearrange_total_imap_nc1hwc0(quan_relu_output, c0=block_oc, is_int16=1, bus_width=bus_width), fmt="%d")
    np.savetxt(path + "quan_sat_relu_output_int16.txt",
               rearrange_total_imap_nc1hwc0(
                   quan_sat_relu_output, c0=block_oc, is_int16=1, bus_width=bus_width),
               fmt="%d")
    np.savetxt(path + "quan_sat_relu_output_add_int16.txt",
               rearrange_total_imap_nc1hwc0(
                   quan_sat_relu_output_add, c0=block_oc, is_int16=1, bus_width=bus_width),
               fmt="%d")
# test_conv2d_matmul_total_random()
# test_conv2d_matmul_total_matmul_random()
# test_rearrange_total_kernel_nc1hwc0()
