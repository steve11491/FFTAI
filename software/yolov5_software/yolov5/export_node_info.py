# import onnx
# from onnx import numpy_helper
# import numpy as np
# import pandas as pd
#
#
# def get_initializer_value(model, name):
#     for initializer in model.graph.initializer:
#         if initializer.name == name:
#             return numpy_helper.to_array(initializer)
#     return None
#
#
# def find_quantization_params(model, node_name, is_input=True):
#     target_node = None
#     for n in model.graph.node:
#         if is_input and n.op_type == 'DequantizeLinear' and n.output[0] == node_name:
#             target_node = n
#             break
#         elif not is_input and n.op_type == 'QuantizeLinear' and n.input[0] == node_name:
#             target_node = n
#             break
#
#     if target_node:
#         scale = get_initializer_value(model, target_node.input[1])
#         zero_point = get_initializer_value(model, target_node.input[2])
#         return scale, zero_point
#     return None, None
#
#
# def extract_node_info(model_path):
#     model = onnx.load(model_path)
#     graph = model.graph
#
#     node_info = []
#
#     for node in graph.node:
#         if node.op_type in ['Conv', 'MaxPool', 'AveragePool', 'Concat', 'Add', 'Resize']:
#             info = {
#                 'name': node.name,
#                 'op_type': node.op_type,
#                 'input_names': [input for input in node.input],
#                 'output_names': [output for output in node.output],
#                 'input_scale': [],
#                 'input_zero_point': [],
#                 'output_scale': None,
#                 'output_zero_point': None
#             }
#
#             # 获取输入的scale和zero_point
#             if node.op_type == 'Conv':
#                 # 对于Conv，只获取第一个输入（特征图）的量化参数
#                 input_scale, input_zero_point = find_quantization_params(model, node.input[0])
#                 info['input_scale'].append(input_scale.item() if input_scale is not None else None)
#                 info['input_zero_point'].append(input_zero_point.item() if input_zero_point is not None else None)
#
#                 # 添加权重和偏置的量化参数
#                 weight_scale, weight_zero_point = find_quantization_params(model, node.input[1])
#                 info['weight_scale'] = weight_scale.item() if weight_scale is not None else None
#                 info['weight_zero_point'] = weight_zero_point.item() if weight_zero_point is not None else None
#
#                 if len(node.input) > 2:
#                     bias_scale, bias_zero_point = find_quantization_params(model, node.input[2])
#                     info['bias_scale'] = bias_scale.item() if bias_scale is not None else None
#                     info['bias_zero_point'] = bias_zero_point.item() if bias_zero_point is not None else None
#             else:
#                 # 对于其他类型的节点，获取所有输入的量化参数
#                 for input_name in node.input:
#                     input_scale, input_zero_point = find_quantization_params(model, input_name)
#                     info['input_scale'].append(input_scale.item() if input_scale is not None else None)
#                     info['input_zero_point'].append(input_zero_point.item() if input_zero_point is not None else None)
#
#             # 获取输出的scale和zero_point
#             output_scale, output_zero_point = find_quantization_params(model, node.output[0], is_input=False)
#             info['output_scale'] = output_scale.item() if output_scale is not None else None
#             info['output_zero_point'] = output_zero_point.item() if output_zero_point is not None else None
#
#             node_info.append(info)
#
#     return node_info
#
#
# def save_to_excel(node_info, output_path):
#     df = pd.DataFrame(node_info)
#
#     # 展开input_scale和input_zero_point列
#     max_inputs = max(len(info['input_scale']) for info in node_info)
#     for i in range(max_inputs):
#         df[f'input_scale_{i}'] = df['input_scale'].apply(lambda x: x[i] if i < len(x) else None)
#         df[f'input_zero_point_{i}'] = df['input_zero_point'].apply(lambda x: x[i] if i < len(x) else None)
#
#     # 删除原始的input_scale和input_zero_point列
#     df = df.drop(columns=['input_scale', 'input_zero_point'])
#
#     df.to_excel(output_path, index=False)
#
#
# # 使用函数
# model_path = 'model_quant.onnx'
# output_path = 'node_quantization_info.xlsx'
#
# node_info = extract_node_info(model_path)
# save_to_excel(node_info, output_path)

#
# import onnx
# from onnx import numpy_helper
# import numpy as np
# import pandas as pd
#
#
# def get_initializer_value(model, name):
#     for initializer in model.graph.initializer:
#         if initializer.name == name:
#             return numpy_helper.to_array(initializer)
#     return None
#
#
# def find_quantization_params(model, node_name, is_input=True):
#     target_node = None
#     for n in model.graph.node:
#         if is_input and n.op_type == 'DequantizeLinear' and n.output[0] == node_name:
#             target_node = n
#             break
#         elif not is_input and n.op_type == 'QuantizeLinear' and n.input[0] == node_name:
#             target_node = n
#             break
#
#     if target_node:
#         scale = get_initializer_value(model, target_node.input[1])
#         zero_point = get_initializer_value(model, target_node.input[2])
#         return scale, zero_point
#     return None, None
#
#
# def get_shape(model, name):
#     for input in model.graph.input:
#         if input.name == name:
#             return [dim.dim_value for dim in input.type.tensor_type.shape.dim]
#     for output in model.graph.output:
#         if output.name == name:
#             return [dim.dim_value for dim in output.type.tensor_type.shape.dim]
#     for value_info in model.graph.value_info:
#         if value_info.name == name:
#             return [dim.dim_value for dim in value_info.type.tensor_type.shape.dim]
#     return None
#
#
# def extract_node_info(model_path):
#     model = onnx.load(model_path)
#     graph = model.graph
#
#     node_info = []
#
#     for node in graph.node:
#         if node.op_type in ['Conv', 'MaxPool', 'AveragePool', 'Concat', 'Add', 'Resize']:
#             info = {
#                 'name': node.name,
#                 'op_type': node.op_type,
#                 'input_names': [input for input in node.input],
#                 'output_names': [output for output in node.output],
#                 'input_shape': get_shape(model, node.input[0]),
#                 'output_shape': get_shape(model, node.output[0]),
#                 'input_scale': [],
#                 'input_zero_point': [],
#                 'output_scale': None,
#                 'output_zero_point': None
#             }
#
#             # 获取特定属性
#             if node.op_type in ['Conv', 'MaxPool', 'AveragePool']:
#                 for attr in node.attribute:
#                     if attr.name in ['kernel_shape', 'strides', 'pads', 'dilations']:
#                         info[attr.name] = list(attr.ints)
#                     elif attr.name == 'group':
#                         info[attr.name] = attr.i
#
#             elif node.op_type == 'Resize':
#                 for attr in node.attribute:
#                     if attr.name in ['mode', 'coordinate_transformation_mode']:
#                         info[attr.name] = attr.s.decode('utf-8')
#
#             elif node.op_type == 'Concat':
#                 for attr in node.attribute:
#                     if attr.name == 'axis':
#                         info[attr.name] = attr.i
#
#             # 获取输入的scale和zero_point
#             if node.op_type == 'Conv':
#                 # 对于Conv，只获取第一个输入（特征图）的量化参数
#                 input_scale, input_zero_point = find_quantization_params(model, node.input[0])
#                 info['input_scale'].append(input_scale.item() if input_scale is not None else None)
#                 info['input_zero_point'].append(input_zero_point.item() if input_zero_point is not None else None)
#
#                 # 添加权重和偏置的量化参数
#                 weight_scale, weight_zero_point = find_quantization_params(model, node.input[1])
#                 info['weight_scale'] = weight_scale.item() if weight_scale is not None else None
#                 info['weight_zero_point'] = weight_zero_point.item() if weight_zero_point is not None else None
#
#                 if len(node.input) > 2:
#                     bias_scale, bias_zero_point = find_quantization_params(model, node.input[2])
#                     info['bias_scale'] = bias_scale.item() if bias_scale is not None else None
#                     info['bias_zero_point'] = bias_zero_point.item() if bias_zero_point is not None else None
#             else:
#                 # 对于其他类型的节点，获取所有输入的量化参数
#                 for input_name in node.input:
#                     input_scale, input_zero_point = find_quantization_params(model, input_name)
#                     info['input_scale'].append(input_scale.item() if input_scale is not None else None)
#                     info['input_zero_point'].append(input_zero_point.item() if input_zero_point is not None else None)
#
#             # 获取输出的scale和zero_point
#             output_scale, output_zero_point = find_quantization_params(model, node.output[0], is_input=False)
#             info['output_scale'] = output_scale.item() if output_scale is not None else None
#             info['output_zero_point'] = output_zero_point.item() if output_zero_point is not None else None
#
#             node_info.append(info)
#
#     return node_info
#
#
# def save_to_excel(node_info, output_path):
#     df = pd.DataFrame(node_info)
#
#     # 展开input_scale和input_zero_point列
#     max_inputs = max(len(info['input_scale']) for info in node_info)
#     for i in range(max_inputs):
#         df[f'input_scale_{i}'] = df['input_scale'].apply(lambda x: x[i] if i < len(x) else None)
#         df[f'input_zero_point_{i}'] = df['input_zero_point'].apply(lambda x: x[i] if i < len(x) else None)
#
#     # 删除原始的input_scale和input_zero_point列
#     df = df.drop(columns=['input_scale', 'input_zero_point'])
#
#     df.to_excel(output_path, index=False)
#
#
# # 使用函数
# model_path = 'model_quant.onnx'
# output_path = 'node_info.xlsx'
#
# node_info = extract_node_info(model_path)
# save_to_excel(node_info, output_path)


import onnx
from onnx import numpy_helper
import numpy as np
import pandas as pd


def get_initializer_value(model, name):
    for initializer in model.graph.initializer:
        if initializer.name == name:
            return numpy_helper.to_array(initializer)
    return None


def find_quantization_params(model, node_name, is_input=True):
    target_node = None
    for i, n in enumerate(model.graph.node):
        if is_input and n.op_type == 'DequantizeLinear' and n.output[0] == node_name:
            target_node = n
            break
        elif not is_input:
            if n.op_type == 'QuantizeLinear' and n.input[0] == node_name:
                target_node = n
                break
            # 处理卷积后接ReLU的情况
            if n.op_type == 'Conv' and n.output[0] == node_name:
                # 检查下一个节点是否为ReLU
                if i + 1 < len(model.graph.node) and model.graph.node[i + 1].op_type == 'Relu':
                    # 查找ReLU之后的QuantizeLinear节点
                    for j in range(i + 2, len(model.graph.node)):
                        if model.graph.node[j].op_type == 'QuantizeLinear':
                            target_node = model.graph.node[j]
                            break
                    if target_node:
                        break

    if target_node:
        data = get_initializer_value(model, target_node.input[0])
        scale = get_initializer_value(model, target_node.input[1])
        zero_point = get_initializer_value(model, target_node.input[2])
        return scale, zero_point, data
    return None, None, None


def get_node_by_output(model, output_name):
    for node in model.graph.node:
        if output_name in node.output:
            return node
    return None


def get_shape(model, name):
    for value_info in model.graph.value_info:
        if value_info.name == name:
            return [dim.dim_value if dim.dim_value != 0 else None for dim in value_info.type.tensor_type.shape.dim]
    for input in model.graph.input:
        if input.name == name:
            return [dim.dim_value if dim.dim_value != 0 else None for dim in input.type.tensor_type.shape.dim]
    for output in model.graph.output:
        if output.name == name:
            return [dim.dim_value if dim.dim_value != 0 else None for dim in output.type.tensor_type.shape.dim]
    return None


def trace_input_shape(model, input_name):
    node = get_node_by_output(model, input_name)
    if node and node.op_type == 'DequantizeLinear':
        node = get_node_by_output(model, node.input[0])
        if node and node.op_type == 'QuantizeLinear':
            return get_shape(model, node.input[0])
    return get_shape(model, input_name)


def extract_node_info(model_path):
    model = onnx.load(model_path)
    graph = model.graph

    node_info = []

    for node in graph.node:
        if node.op_type in ['Conv', 'MaxPool', 'AveragePool', 'Concat', 'Add', 'Resize']:
            info = {
                'name': node.name,
                'op_type': node.op_type,
                'input_names': [input for input in node.input],
                'output_names': [output for output in node.output],
                'input_shapes': [],
                'output_shape': None,
                'input_scale': [],
                'input_zero_point': [],
                'output_scale': None,
                'output_zero_point': None
            }

            # 获取输入形状
            if node.op_type in ['Conv', 'MaxPool', 'AveragePool', 'Resize']:
                info['input_shapes'].append(trace_input_shape(model, node.input[0]))
            elif node.op_type in ['Concat', 'Add']:
                for input_name in node.input:
                    info['input_shapes'].append(trace_input_shape(model, input_name))

            # 获取输出形状
            info['output_shape'] = trace_input_shape(model, node.output[0])

            # 获取特定属性
            if node.op_type in ['Conv', 'MaxPool', 'AveragePool']:
                for attr in node.attribute:
                    if attr.name in ['kernel_shape', 'strides', 'pads', 'dilations']:
                        info[attr.name] = list(attr.ints)
                    elif attr.name == 'group':
                        info[attr.name] = attr.i

            elif node.op_type == 'Resize':
                for attr in node.attribute:
                    if attr.name in ['mode', 'coordinate_transformation_mode']:
                        info[attr.name] = attr.s.decode('utf-8')

            elif node.op_type == 'Concat':
                for attr in node.attribute:
                    if attr.name == 'axis':
                        info[attr.name] = attr.i

            # 获取输入的scale和zero_point
            if node.op_type == 'Conv':
                # 对于Conv，只获取第一个输入（特征图）的量化参数
                print(node.input[0])
                input_scale, input_zero_point, _ = find_quantization_params(model, node.input[0])
                info['input_scale'].append(input_scale.item() if input_scale is not None else None)
                info['input_zero_point'].append(input_zero_point.item() if input_zero_point is not None else None)

                # 添加权重和偏置的量化参数
                weight_scale, weight_zero_point, weight = find_quantization_params(model, node.input[1])
                info['weight_scale'] = weight_scale.item() if weight_scale is not None else None
                info['weight_zero_point'] = weight_zero_point.item() if weight_zero_point is not None else None

                np.save('./infer_output_data/' + str(node.name.replace('/', '_')) + '_weight', weight)

                if len(node.input) > 2:
                    bias_scale, bias_zero_point, bias = find_quantization_params(model, node.input[2])
                    info['bias_scale'] = bias_scale.item() if bias_scale is not None else None
                    info['bias_zero_point'] = bias_zero_point.item() if bias_zero_point is not None else None
                    np.save('./infer_output_data/' + str(node.name.replace('/', '_')) + '_bias', bias)
            else:
                # 对于其他类型的节点，获取所有输入的量化参数
                for input_name in node.input:
                    input_scale, input_zero_point, _ = find_quantization_params(model, input_name)
                    info['input_scale'].append(input_scale.item() if input_scale is not None else None)
                    info['input_zero_point'].append(input_zero_point.item() if input_zero_point is not None else None)

            # 获取输出的scale和zero_point
            output_scale, output_zero_point, _ = find_quantization_params(model, node.output[0], is_input=False)
            info['output_scale'] = output_scale.item() if output_scale is not None else None
            info['output_zero_point'] = output_zero_point.item() if output_zero_point is not None else None

            node_info.append(info)

    return node_info


def save_to_excel(node_info, output_path):
    df = pd.DataFrame(node_info)

    # 展开input_shapes列
    max_inputs = max(len(info['input_shapes']) for info in node_info)
    for i in range(max_inputs):
        df[f'input_shape_{i}'] = df['input_shapes'].apply(lambda x: x[i] if i < len(x) else None)

    # 展开input_scale和input_zero_point列
    for i in range(max_inputs):
        df[f'input_scale_{i}'] = df['input_scale'].apply(lambda x: x[i] if i < len(x) else None)
        df[f'input_zero_point_{i}'] = df['input_zero_point'].apply(lambda x: x[i] if i < len(x) else None)

    # 删除原始的input_shapes, input_scale和input_zero_point列
    df = df.drop(columns=['input_shapes', 'input_scale', 'input_zero_point'])

    df.to_excel(output_path, index=False)


# 使用函数
model_path = 'model_quant.onnx'
output_path = 'node_info.xlsx'
# model_path = 'quantized_1.onnx'
# output_path = 'node_info_quantized_1.xlsx'
node_info = extract_node_info(model_path)
save_to_excel(node_info, output_path)
