import os

import onnx
import numpy as np
import pandas as pd
import math
from onnx import numpy_helper
import struct
import sys
from onnx import shape_inference
import logging
import onnxruntime
from collections import OrderedDict
import cv2
import torch
import pandas as pd

# 加载ONNX模型
model_path = './model_quant.onnx'
model = onnx.load(model_path)


######################################run session########################################################################
def test_model_by_onnxruntime(model_onnx, img_array, self=None):
    logging.info("Test model by onnxruntime")

    input_shape = model_onnx.graph.input[0].type.tensor_type.shape.dim
    print(input_shape)
    image_shape = [x.dim_value for x in input_shape]
    image_shape_new = []
    for x in image_shape:
        if x == 0:
            image_shape_new.append(1)
        else:
            image_shape_new.append(x)
    image_shape = image_shape_new
    # print(image_shape)
    # img_array = np.array(np.random.random(image_shape), dtype=np.float32)
    img = img_array
    print("runtime of onnx \n")
    # print(img)
    for node in model_onnx.graph.node:
        for input in node.input:
            model_onnx.graph.output.extend([onnx.ValueInfoProto(name=input)])
    for node in model_onnx.graph.node:
        for output in node.output:
            model_onnx.graph.output.extend([onnx.ValueInfoProto(name=output)])
    ort_session = onnxruntime.InferenceSession(model_onnx.SerializeToString())
    ort_inputs = {}
    for i, input_ele in enumerate(ort_session.get_inputs()):
        ort_inputs[input_ele.name] = img

    outputs = [x.name for x in ort_session.get_outputs()]
    print(outputs)
    ort_outs = ort_session.run(outputs, ort_inputs)
    ort_outs = OrderedDict(zip(outputs, ort_outs))
    logging.info("Test model by onnxruntime success")
    # del model_onnx.graph.output[:]
    # model_onnx.graph.output.extend(ort_outs)
    return ort_outs


######################################write the weight of model into bin file#############################################
# 得到3*3weight
def generate_weight(weight):
    ifmch = weight.shape[1]
    outmch = weight.shape[0] / 4
    outmch = int(outmch)
    # -1其实是无所谓的意思，计算机自动帮我们计算out_channel/4等于多少
    weight = weight.reshape([-1, 4, ifmch, 9])
    if ifmch < 4:
        print(ifmch)
        tmp = np.zeros([outmch, 4, 4 - ifmch, 9]).astype(
            np.int8)  # 这里其实是在处理in_channel == 3的情况，所以补了1,4=3+1,weight的dimension0为6，6*4为24,所以这里zero矩阵的dim0也需要为6
        weight = np.append(weight, tmp, axis=2)
    weight = weight.swapaxes(1, 2)
    weight = weight.swapaxes(2, 3)
    return weight


# 1*1weight 转成3*3weight
def generate_weight_1x1(weight):
    ifmch = weight.shape[1]
    ofmch = weight.shape[0]
    weight = weight.reshape([ofmch, ifmch])
    weight_zero = np.zeros([ofmch, ifmch, 9]).astype(np.int8)
    weight_zero[:, :, 4] = weight
    weight = weight_zero
    # print(weight.shape)
    # weight = weight.swapaxes([-1, 4, ifmch, 9])
    if weight.shape[0] < 4:
        tmp = np.zeros(
            [4 - weight.shape[0], weight.shape[1], 9]).astype(np.int8)
        weight = np.append(weight, tmp, axis=0)
    weight = weight.reshape([-1, 4, ifmch, 9])
    weight = weight.swapaxes(1, 2)
    weight = weight.swapaxes(2, 3)
    return weight


onnx_weights = {}
for initializer in model.graph.initializer:
    onnx_weights[initializer.name] = numpy_helper.to_array(initializer)
    # print(onnx_weights[initializer.name])
weight_names = onnx_weights.keys()


#############################write the weight file into bin file for simulation#####################
# i = 0
def create_folder_if_not_exists(folder_path):
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)


img_path = "./000003.jpg"
ori_img = cv2.imread(img_path)
res_img = cv2.resize(ori_img, (640, 640), interpolation=cv2.INTER_LINEAR)
res_img = res_img / 255.0
img = res_img[None]  # .reshape(1, 352, 352, 3)
img = torch.from_numpy(img.transpose(0, 3, 1, 2))  # xyzw,y,z,w互换轴
# print(img)
shape = onnx.shape_inference.infer_shapes(model)
# # onnx.save(shape, shape_onnx_path)
# onnx_shape = {}
# for shape_initial in shape.graph.initializer:
#     onnx_shape[shape_initial.name] = numpy_helper.to_array(shape_initial)
#
# # print(onnx_shape)
model_layer_attribute_list = []
# conv_attribute = {'input_h': 0, 'input_w': 0, 'input_channel': 0, 'kernel_size': 0, 'stride': 0, 'padding': 0, 'group': 0,
#                   'dilation': 0, 'output_h': 0, 'output_w': 0, 'output_channel': 0}

img = img.to('cpu').float()
img = np.array(img)
onnx_output = test_model_by_onnxruntime(model, img)

onnx_weights = {}
for initializer in model.graph.initializer:
    onnx_weights[initializer.name] = numpy_helper.to_array(initializer)
    # print(onnx_weights[initializer.name])
weight_names = onnx_weights.keys()

# 创建一个列表来存储统计信息
stats = []

for key, value in onnx_output.items():
    value = np.array(value)
    print(key)
    key = key.replace("/", "_").replace(":", "_")
    str_key = './infer_output/' + str(key)

    if 'act_Relu_output' in str_key and "QuantizeLinear_Output" in str_key:
        print('{}==max=={}==min=={}====='.format(
            str_key, np.max(value) + 128, np.min(value) + 128))

    print(str_key)
    np.save(str_key, value)

    # 计算统计信息，同时处理空数组的情况
    if value.size > 0:
        max_val = np.max(value)
        min_val = np.min(value)
        mean_val = np.mean(value)
    else:
        max_val = min_val = mean_val = 'N/A'

    # 将统计信息添加到列表中
    stats.append({
        'Key': str_key,
        'Max': max_val,
        'Min': min_val,
        'Mean': mean_val
    })

# 创建DataFrame
df = pd.DataFrame(stats)

# 确保输出目录存在
os.makedirs('./infer_output/', exist_ok=True)

# 将DataFrame保存为Excel文件
excel_path = './infer_output/statistics.xlsx'
df.to_excel(excel_path, index=False)

# quan_ch0.to_csv('./infer_csv/conv0_output_ch3_ip.csv')
