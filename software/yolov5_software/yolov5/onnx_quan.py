import os
import numpy as np
import time

import torch
import torch.nn as nn
from PIL import Image
import onnxruntime
from onnxruntime.quantization import quantize_static, CalibrationDataReader, QuantFormat, QuantType
import cv2


# from utils.experimental import attempt_load
# from utils.google_utils import attempt_download


class DataReader(CalibrationDataReader):
    def __init__(self, calibration_image_folder, augmented_model_path=None):
        self.image_folder = calibration_image_folder
        self.augmented_model_path = augmented_model_path
        self.preprocess_flag = True
        self.enum_data_dicts = []
        self.datasize = 0

    def get_next(self):
        if self.preprocess_flag:
            self.preprocess_flag = False
            session = onnxruntime.InferenceSession(self.augmented_model_path, None)
            (_, _, height, width) = session.get_inputs()[0].shape
            nhwc_data_list = proprocess_func(self.image_folder, height, width, size_limit=0)
            input_name = session.get_inputs()[0].name
            self.datasize = len(nhwc_data_list)
            self.enum_data_dicts = iter([{input_name: nhwc_data} for nhwc_data in nhwc_data_list])
        return next(self.enum_data_dicts, None)


device = "cpu"


def proprocess_func(images_folder, height, width, size_limit=0):
    image_names = os.listdir(images_folder)
    if size_limit > 0 and len(image_names) >= size_limit:
        batch_filenames = [image_names[i] for i in range(size_limit)]
    else:
        batch_filenames = image_names
    unconcatenated_batch_data = []
    for image_name in batch_filenames:
        # print(image_name)
        image_filepath = images_folder + '/' + image_name
        # pillow_img = Image.new("L", (width, height))
        # pillow_img.paste(Image.open(image_filepath).resize((width, height)))
        # pillow_img.resize((352,352), 0)
        # pillow_img = pillow_img.reshape(1, height, width, 3)
        # input_data = np.float32(pillow_img)/255.
        # input_data = input_data[np.newaxis, np.newaxis, :, :]
        # cv2
        pillow_img = cv2.imread(image_filepath)
        pillow_img = cv2.resize(pillow_img, (width, height), interpolation=cv2.INTER_LINEAR)
        pillow_img = pillow_img.reshape(1, height, width, 3)
        pillow_img = torch.from_numpy(pillow_img.transpose(0, 3, 1, 2))  # xyzw,y,z,w互换轴
        pillow_img = pillow_img.to(device).float() / 255.0
        # print("before forward:\n")
        input_data = np.array(pillow_img, dtype=np.float32)
        # print(input_data)
        # nhwc_data = np.expand_dims(input_data, axis=0)
        # nchw_data = nhwc_data.transpose(())
        unconcatenated_batch_data.append(input_data)
    batch_data = np.concatenate(np.expand_dims(unconcatenated_batch_data, axis=0), axis=0)
    return batch_data


def benchmark(model_path):
    """
    用于测试速度
    :param model_path:
    :return:
    """
    session = onnxruntime.InferenceSession(model_path)
    input_name = session.get_inputs()[0].name

    total = 0.0
    runs = 10
    input_data = np.zeros((1, 3, 640, 640), np.float32)  # 随便输入一个假数据，注意shape要与模型一致，我这里是灰度图输入所以(1,1)，三通道图为(1,3)
    # warming up
    _ = session.run([], {input_name: input_data})
    for i in range(runs):
        start = time.perf_counter()
        _ = session.run([], {input_name: input_data})
        end = (time.perf_counter() - start) * 1000
        total += end
        print(f"{end:.2f}ms")
    total /= runs
    print(f"Avg: {total:.2f}ms")


def load_quant_model(float_model_name, quant_model_name):
    model = attempt_load(float_model_name, map_location='cpu')
    quant = torch.quantization.QuantStub()
    dequant = torch.quantization.DeQuantStub()
    quant_model = nn.Sequential(quant, model, dequant)

    quant_model = quant_model.to('cpu')
    quant_model.qconfig = torch.quantization.default_qconfig
    quant_model = torch.quantization.prepare(quant_model, inplace=False)
    quant_model = torch.quantization.convert(quant_model, inplace=False)

    state_dict_t = torch.load(quant_model_name)
    quant_model.load_state_dict(state_dict_t)
    quant_model = quant_model.to('cpu')
    return quant_model


def main():
    input_model_path = './model.onnx'  # 输入onnx模型
    output_model_path = './model_quant_int.onnx'  # 输出模型名
    calibration_dataset_path = './val'  # 校准数据集图像地址
    # 用于校准数据加载,注意这个方法里面需要做图像一些操作,与pytorch训练的时候加载数据操作一致
    dr = DataReader(calibration_dataset_path, input_model_path)
    # 开始量化
    quantize_static(input_model_path,
                    output_model_path,
                    dr,
                    quant_format=QuantFormat.QDQ,
                    per_channel=False,
                    nodes_to_exclude=['/model/model.24/Mul_3', '/model/model.24/Mul_5', '/model.24/Concat_1', '/model.24/Mul_9',
                                      '/model/model.24/Mul_11', '/model/model.24/Concat_3', '/model.24/Mul_15', '/model.24/Mul_17',
                                      '/model/model.24/Concat_5', '/model/model.24/Reshape_1', '/model.24/Reshape_3',
                                      '/model/model.24/Reshape_5', '/model/model.24/Concat_6'],
                    reduce_range = True,
                    activation_type=QuantType.QInt8,
                    weight_type=QuantType.QInt8,
                    optimize_model = True)
    # float_model = "best.pth"
    # quan_model = "best_quan.pth"
    # load_quant_model(float_model, quan_model)
    print("量化完成")
    print("float32测试")
    benchmark(input_model_path)
    print("int8测试")
    benchmark(output_model_path)


if __name__ == "__main__":
    main()
