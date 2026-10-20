import numpy as np
import cv2
import onnxruntime
import onnx


def preprocess(img, dst_width=640, dst_height=640):
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
    img_pre = (img_pre[..., ::-1] / 255.0).astype(np.float32)
    img_pre = img_pre.transpose(2, 0, 1)[None]
    return img_pre, IM


def iou(box1, box2):
    def area_box(box):
        return (box[2] - box[0]) * (box[3] - box[1])

    # box -> [x1,y1,x2,y2,...]
    left = max(box1[0], box2[0])
    top = max(box1[1], box2[1])
    right = min(box1[2], box2[2])
    bottom = min(box1[3], box2[3])
    cross = max(0, right - left) * max(0, bottom - top)
    union = area_box(box1) + area_box(box2) - cross
    if cross == 0 or union == 0:
        return 0
    return cross / union


def NMS(boxes, iou_thresh=0.45):
    '''
    :param boxes: decode解码排序后的boxes [n,6] 6 = x1,y1,x2,y2,conf,label
    :param iou_thresh: iou阈值
    :return: 经过NMS的boxes
    '''
    # 利用remove_flags标记需要去除的box
    remove_flags = [False] * len(boxes)
    # 保留下的box
    keep_boxes = []
    for i in range(len(boxes)):
        if remove_flags[i]:
            continue
        ibox = boxes[i]
        keep_boxes.append(ibox)
        for j in range(len(boxes)):
            if remove_flags[j]:
                continue
            jbox = boxes[j]
            # 只有同一张图片中的同一个类别的box才计算iou
            if ibox[5] != jbox[5]:
                continue
            # 计算iou,若大于阈值则标记去除
            if iou(ibox, jbox) > iou_thresh:
                remove_flags[j] = True
    return keep_boxes


def postprocess(pred, IM, iou_thresh=0.45, conf_thresh=0.2):
    '''
    :param pred: 模型推理的结果 [1,25200,nc+5] nc+5 = cx,cy,w,h,conf + nc
    :param IM: 仿射变换矩阵的逆变换，主要用来将box映射回原图
    :param iou_thresh: iou阈值
    :param cof_thresh: 置信度阈值
    :return: 经过NMS的boxes
    '''
    # 保存decode解码后的boxes
    boxes = []
    for img_id, box_id in zip(*np.where(pred[..., 4] >= conf_thresh)):
        item = pred[img_id][box_id]
        cx, cy, w, h, obj_conf = item[:5]
        label = item[5:].argmax()
        confidence = obj_conf * item[5 + label]
        if confidence < conf_thresh:
            continue
        left = cx - w * 0.5
        top = cy - h * 0.5
        right = cx + w * 0.5
        bottom = cy + h * 0.5
        boxes.append([left, top, right, bottom, confidence, img_id, label])
    # 利用IM将box映射回原图
    boxes = np.array(boxes)
    lr = boxes[..., [0, 2]]
    tb = boxes[..., [1, 3]]
    boxes[..., [0, 2]] = lr * IM[0][0] + IM[0][2]
    boxes[..., [1, 3]] = tb * IM[1][1] + IM[1][2]
    # 将boxes按照置信度高低排序
    boxes = sorted(boxes.tolist(), key=lambda x: x[4], reverse=True)
    # 将排序后的boxes作NMS
    nms_boxes = NMS(boxes, iou_thresh=iou_thresh)
    return nms_boxes


def trans_onnx(input_onnx_file_path, output_onnx_file_path):
    onnx_graph = onnx.load(input_onnx_file_path)
    estimated_graph = onnx.shape_inference.infer_shapes(onnx_graph)
    onnx.save(estimated_graph, output_onnx_file_path)


def to_numpy(tensor):
    return tensor.detach().cpu().numpy() if tensor.requires_grad else tensor.cpu().numpy()


def run_onnx(imgdata, onnx_model_path="model.onnx"):
    onnx_model = onnx.load(onnx_model_path)
    onnx.checker.check_model(onnx_model)
    sess = onnxruntime.InferenceSession(onnx_model_path)
    input_name = []
    input_feed = {}
    # get onnx output
    input_all = [node.name for node in onnx_model.graph.input]
    input_initializer = [
        node.name for node in onnx_model.graph.initializer
    ]
    net_feed_input = list(set(input_all) - set(input_initializer))
    assert (len(net_feed_input) == 1)
    pred_onnx = sess.run(
        None, {net_feed_input[0]: imgdata})
    print("outputs:")
    print(pred_onnx)
    return pred_onnx


def run_onnx_pre(imgdata, onnx_model_path="model_quant_pre.onnx"):
    onnx_model = onnx.load(onnx_model_path)
    onnx.checker.check_model(onnx_model)
    sess = onnxruntime.InferenceSession(onnx_model_path)
    input_name = []
    input_feed = {}
    # get onnx output
    input_all = [node.name for node in onnx_model.graph.input]
    input_initializer = [
        node.name for node in onnx_model.graph.initializer
    ]
    net_feed_input = list(set(input_all) - set(input_initializer))
    assert (len(net_feed_input) == 1)
    pre_onnx = sess.run(
        None, {net_feed_input[0]: imgdata})
    print("pre_onnx")
    # print(pre_onnx)
    return pre_onnx


def run_onnx_post(pre_onnx, quan=0, onnx_model_path="model_quant_post.onnx"):
    onnx_model = onnx.load(onnx_model_path)
    onnx.checker.check_model(onnx_model)
    sess = onnxruntime.InferenceSession(onnx_model_path)
    input_name = []
    input_feed = {}
    # get onnx output
    input_all = [node.name for node in onnx_model.graph.input]
    input_initializer = [
        node.name for node in onnx_model.graph.initializer
    ]
    net_feed_input = list(set(input_all) - set(input_initializer))
    assert (len(net_feed_input) == 3)
    if quan:
        post_onnx = sess.run(
            ['546'], {'/model/model.24/m.0/Conv_output_0_QuantizeLinear_Output': pre_onnx[0],
                      '/model/model.24/m.1/Conv_output_0_QuantizeLinear_Output': pre_onnx[1],
                      '/model/model.24/m.2/Conv_output_0_QuantizeLinear_Output': pre_onnx[2]})
    else:
        post_onnx = sess.run(
            ['546'], {'/model/model.24/m.0/Conv_output_0': pre_onnx[0],
                      '/model/model.24/m.1/Conv_output_0': pre_onnx[1],
                      '/model/model.24/m.2/Conv_output_0': pre_onnx[2]})
    print("post_onnx:")
    # print(post_onnx)
    return post_onnx


def run_onnx_post2(pre_onnx, quan=0, onnx_model_path="model_quant_post2.onnx"):
    onnx_model = onnx.load(onnx_model_path)
    onnx.checker.check_model(onnx_model)
    sess = onnxruntime.InferenceSession(onnx_model_path)
    input_name = []
    input_feed = {}
    # get onnx output
    input_all = [node.name for node in onnx_model.graph.input]
    input_initializer = [
        node.name for node in onnx_model.graph.initializer
    ]
    net_feed_input = list(set(input_all) - set(input_initializer))

    post_onnx = sess.run(
        ['546'], {'/model/model.1/act/Relu_output_0_QuantizeLinear_Output': pre_onnx[0],
                  '/model/model.2/m/m.0/cv1/act/Relu_output_0_QuantizeLinear_Output': pre_onnx[1]
                  })

    print("post_onnx:")
    # print(post_onnx)
    return post_onnx


def postprogress(img, pred_0, IM):
    # 后处理
    boxes = postprocess(pred_0, IM)
    for obj in boxes:
        x1, y1, x2, y2 = map(int, obj[:4])
        label = int(obj[6])
        label_name = label_names[label]
        confidence = obj[4]
        cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 0), 1, 8)
        cv2.putText(img, f"{label_name}:{confidence:.3f}", (x1, y1 - 6), 0, 1, (0, 0, 255), 2, 8)
    return img


# 缩放图像
def resize_image(img, scale):
    width = int(img.shape[1] * scale)
    height = int(img.shape[0] * scale)
    return cv2.resize(img, (width, height), interpolation=cv2.INTER_AREA)


# def add_text(img, text):
#     font = cv2.FONT_HERSHEY_SIMPLEX
#     font_scale = 1
#     font_color = (255, 255, 255)  # 白色
#     thickness = 2
#     text_size = cv2.getTextSize(text, font, font_scale, thickness)[0]
#
#     # 创建一个略大于原图的新图像，为标题留出空间
#     new_img = np.zeros((img.shape[0] + text_size[1] + 20, img.shape[1], 3), dtype=np.uint8)
#     new_img[text_size[1] + 20:, :, :] = img
#
#     # 添加文字
#     text_x = (img.shape[1] - text_size[0]) // 2
#     text_y = text_size[1] + 10
#     cv2.putText(new_img, text, (text_x, text_y), font, font_scale, font_color, thickness)
#
#     return new_img

# 在图像上添加中文文字
from PIL import Image, ImageDraw, ImageFont


# 在图像上添加中文文字
def add_text(img, text):
    # 转换颜色空间从BGR到RGB
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    pil_img = Image.fromarray(img_rgb)

    # 创建一个新的图像，为标题留出空间
    new_img = Image.new('RGB', (pil_img.width, pil_img.height + 50), color=(0, 0, 0))
    new_img.paste(pil_img, (0, 50))

    # 设置字体为宋体
    font = ImageFont.truetype("C:\Windows\Fonts\simsun.ttc", 36)
    draw = ImageDraw.Draw(new_img)

    # 获取文本大小
    left, top, right, bottom = draw.textbbox((0, 0), text, font=font)
    text_width = right - left
    text_height = bottom - top

    # 计算文本位置
    position = ((new_img.width - text_width) // 2, 10)

    # 绘制文本
    draw.text(position, text, font=font, fill=(255, 255, 255))

    # 转换回OpenCV格式
    return cv2.cvtColor(np.array(new_img), cv2.COLOR_RGB2BGR)


from psoc_preprocess import *

label_names = {
    0: "ore carrier",
    1: "bulk cargo carrier",
    2: "container ship",
    3: "general cargo ship",
    4: "passenger ship",
    5: "fishing boat"
}
path = "./hardware_output/"
bus_width = 64
# channel = [64, 64, 64]
# height = [80, 40, 20]
# width = [80, 40, 20]
# layer = [51, 58, 64]
# for i in range(3):
#     output_map_cut_nc1hwc0_read = np.fromfile(os.path.join(path, '{}_output_layer_{}.bin'.format(img_name, layer[i])),
#                                               dtype=np.int8)
#     ceil_feature_map_nchw = imap_nc1hwc0_to_nchw(output_map_cut_nc1hwc0_read, c0, 0, bus_width, channel[i],
#                                                  height[i], width[i])
#     output_map_nchw_cut = np.expand_dims(ceil_feature_map_nchw[0:33, :, :], axis=0)
#     np.save(os.path.join(path, 'final_output_map_nchw_{}.npy'.format(i)), output_map_nchw_cut)
channel = [64, 32]
height = [160, 160]
width = [160, 160]
layer = [1, 4]
for i in range(len(layer)):
    output_map_cut_nc1hwc0_read = np.fromfile(os.path.join(path, '{}_output_layer_{}.bin'.format(img_name, layer[i])),
                                              dtype=np.int8)
    ceil_feature_map_nchw = imap_nc1hwc0_to_nchw(output_map_cut_nc1hwc0_read, c0, 0, bus_width, channel[i],
                                                 height[i], width[i])
    output_map_nchw_cut = np.expand_dims(ceil_feature_map_nchw, axis=0)
    np.save(os.path.join(path, 'final_output_map_nchw_{}.npy'.format(i)), output_map_nchw_cut)

if __name__ == '__main__':

    # 预处理
    img_pre, IM = preprocess(img)
    # 模型推理
    pred_s_float = run_onnx(img_pre, "model/model.onnx")
    pred_s_quan = run_onnx(img_pre, "model/model_quant.onnx")

    pre_onnx_ai_acce = []
    for i in range(len(layer)):
        data = np.load(
            path + 'final_output_map_nchw_{}.npy'.format(i)).astype(
            np.int8)
        pre_onnx_ai_acce.append(data)
    # pred_s = run_onnx_post(pre_onnx_ai_acce, quan=1, onnx_model_path="yolov5_whole/model_quant_post.onnx")
    pred_s_ai_acce = run_onnx_post2(pre_onnx_ai_acce, quan=1, onnx_model_path="model/model_quant_post2.onnx")

    img_float = postprogress(img.copy(), pred_s_float[0], IM)
    img_quan = postprogress(img.copy(), pred_s_quan[0], IM)
    img_ai_acce = postprogress(img.copy(), pred_s_ai_acce[0], IM)

    scale_factor = 0.5

    img_float_resized = resize_image(img_float, scale_factor)
    img_quan_resized = resize_image(img_quan, scale_factor)
    img_ai_acce_resized = resize_image(img_ai_acce, scale_factor)

    img_float_labeled = add_text(img_float_resized, "浮点模型")
    img_quan_labeled = add_text(img_quan_resized, "量化模型")
    img_ai_acce_labeled = add_text(img_ai_acce_resized, "硬件模型")

    combined_image = np.hstack((img_quan_labeled, img_ai_acce_labeled))

    # 显示结果
    cv2.imshow('Combined Images', combined_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
