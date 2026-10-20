import numpy as np
import cv2
import onnxruntime
import onnx
from utils import *
import math


def preprocess_input(img, dst_width=640, dst_height=640):
    '''
    :param img: 输入的图片
    :param dst_width: 预处理后的图像宽
    :param dst_height: 预处理后的图像高
    :return: 预处理后的图片,仿射变换矩阵的逆变换矩阵IM
    '''
    scale = min((dst_width / img.shape[1]), (dst_height / img.shape[0]))
    ox = (-scale * img.shape[1] + dst_width) / 2
    oy = (-scale * img.shape[0] + dst_height) / 2
    M = np.array([
        [scale, 0, ox],
        [0, scale, oy]
    ], dtype=np.float32)
    # img_pre为仿射变换后的图即原始图像缩放到[dst_width,dst_height]
    img_pre = cv2.warpAffine(img, M, dsize=[dst_width, dst_height], flags=cv2.INTER_LINEAR,
                             borderMode=cv2.BORDER_CONSTANT, borderValue=(114, 114, 114))
    IM = cv2.invertAffineTransform(M)
    # -----------------------------------------------------------------------#
    #   需要进行的预处理
    #   1. BGR -> RGB
    #   2. /255.0
    #   3. 通道数变换 H,W,C -> C,H,W
    #   4. 添加batch维度 C,H,W -> B,C,H,W
    # -----------------------------------------------------------------------#
    img_pre = (img_pre[..., ::-1]).astype(np.float32) - 128
    img_pre = img_pre.transpose(2, 0, 1)[None]
    return img_pre, IM


def channel_exp(img_pre):
    bus_width = 64
    padding = (2, 2)
    stride = (2, 2)
    dilation = (1, 1)
    zero_point_in = -128
    _, in_channels, input_height, input_width = img_pre.shape
    out_channels, _, kernel_height, kernel_width = 32, 0, 6, 6
    weight = np.zeros((out_channels, in_channels, kernel_height, kernel_width))
    expanded_feature_map, _ = channel_expansion(
        (img_pre).reshape(in_channels, input_height, input_width),
        weight, stride, padding, dilation, zero_point_in)
    in_channels, input_height, input_width = expanded_feature_map.shape

    ic_factor = (bus_width / 8)
    oc_factor = (bus_width / 8)
    ceil_in_channels = int(math.ceil(in_channels / ic_factor) * ic_factor)
    ceil_feature_map = np.zeros(
        (ceil_in_channels, input_height, input_width))
    ceil_feature_map[0:in_channels, :, :] = expanded_feature_map.reshape(
        in_channels, input_height, input_width)
    return ceil_feature_map


output_folder = './bin_file/img/'
img_path = r"./val/002550.jpg"
img_name = os.path.splitext(os.path.basename(img_path))[0]
img = cv2.imread(img_path)
# 预处理
img_pre, IM = preprocess_input(img)
expanded_img = channel_exp(img_pre)
c0 = 32
expanded_img_nc1hwc0 = rearrange_total_imap_nc1hwc0(expanded_img, c0, is_int16=0, bus_width=64).astype(np.int8)
expanded_img_nc1hwc0_array = expanded_img_nc1hwc0.flatten()
# np.save(os.path.join(output_folder, img_name + '_input_feature_map.npy'), expanded_img)
expanded_img_nc1hwc0_array.tofile(output_folder + img_name + "_input_tensor_nc1hwc0_int8.bin")
