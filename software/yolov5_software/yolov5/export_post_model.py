import onnx
from onnx import shape_inference
import onnx.utils

# 定义新模型的输入
input_names = [
    "/model/model.24/m.0/Conv_output_0_QuantizeLinear_Output",
    "/model/model.24/m.1/Conv_output_0_QuantizeLinear_Output",
    "/model/model.24/m.2/Conv_output_0_QuantizeLinear_Output"
]

# 获取原始模型的输出
output_names = ['546']

# 提取子模型
onnx.utils.extract_model("model_quant.onnx", 'model_quant_pre.onnx', ['input.1'], input_names)

onnx.utils.extract_model("model_quant.onnx", 'model_quant_post.onnx', input_names, output_names)

# 定义新模型的输入
input_names = [
    "/model/model.24/m.0/Conv_output_0",
    "/model/model.24/m.1/Conv_output_0",
    "/model/model.24/m.2/Conv_output_0"
]

# 获取原始模型的输出
output_names = ['546']

# 提取子模型
onnx.utils.extract_model("model.onnx", 'model_pre.onnx', ['input.1'], input_names)

onnx.utils.extract_model("model.onnx", 'model_post.onnx', input_names, output_names)

# 定义新模型的输入
input_names = [
    "/model/model.1/act/Relu_output_0_QuantizeLinear_Output",
    "/model/model.2/m/m.0/cv1/act/Relu_output_0_QuantizeLinear_Output"
]

# 获取原始模型的输出
output_names = ['546']

# 提取子模型
onnx.utils.extract_model("model_quant.onnx", 'model_quant_pre2.onnx', ['input.1'], input_names)

onnx.utils.extract_model("model_quant.onnx", 'model_quant_post2.onnx', input_names, output_names)
