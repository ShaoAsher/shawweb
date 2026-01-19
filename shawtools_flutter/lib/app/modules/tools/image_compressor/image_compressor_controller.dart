import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/toast_utils.dart';

/// 图片压缩控制器
class ImageCompressorController extends GetxController {
  final _picker = ImagePicker();

  // 原始图片
  Rx<File?> originalImage = Rx<File?>(null);
  Rx<Uint8List?> originalBytes = Rx<Uint8List?>(null);
  RxInt originalWidth = 0.obs;
  RxInt originalHeight = 0.obs;
  RxDouble originalSize = 0.0.obs;

  // 压缩后的图片
  Rx<Uint8List?> compressedBytes = Rx<Uint8List?>(null);
  RxInt compressedWidth = 0.obs;
  RxInt compressedHeight = 0.obs;
  RxDouble compressedSize = 0.0.obs;

  // 压缩设置
  final maxWidthController = TextEditingController();
  final maxHeightController = TextEditingController();
  final targetSizeController = TextEditingController();

  RxString selectedFormat = 'auto'.obs; // auto, jpeg, png, webp
  RxDouble quality = 92.0.obs;
  RxBool avoidUpscale = true.obs;
  RxBool isCompressing = false.obs;
  RxBool hasCompressed = false.obs;

  @override
  void onClose() {
    maxWidthController.dispose();
    maxHeightController.dispose();
    targetSizeController.dispose();
    super.onClose();
  }

  /// 选择图片
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        if (decodedImage != null) {
          originalImage.value = file;
          originalBytes.value = bytes;
          originalWidth.value = decodedImage.width;
          originalHeight.value = decodedImage.height;
          originalSize.value = bytes.length / 1024; // KB

          // 重置压缩结果
          compressedBytes.value = null;
          hasCompressed.value = false;

          ToastUtils.showSuccess('图片加载成功');
        } else {
          ToastUtils.showError('无法解析图片');
        }
      }
    } catch (e) {
      ToastUtils.showError('选择图片失败: $e');
    }
  }

  /// 压缩图片
  Future<void> compressImage() async {
    if (originalBytes.value == null) {
      ToastUtils.showError('请先选择图片');
      return;
    }

    isCompressing.value = true;

    try {
      final original = img.decodeImage(originalBytes.value!);
      if (original == null) {
        throw Exception('无法解析图片');
      }

      // 计算目标尺寸
      final targetSize = _computeTargetSize(original.width, original.height);

      // 调整尺寸
      img.Image resized = original;
      if (targetSize['width'] != original.width ||
          targetSize['height'] != original.height) {
        resized = img.copyResize(
          original,
          width: targetSize['width'],
          height: targetSize['height'],
          interpolation: img.Interpolation.linear,
        );
      }

      // 根据格式压缩
      Uint8List compressed;
      String actualFormat = selectedFormat.value;

      if (actualFormat == 'auto') {
        // 自动选择格式：检测是否有透明通道
        actualFormat = _hasAlpha(original) ? 'png' : 'jpeg';
      }

      switch (actualFormat) {
        case 'png':
          compressed = Uint8List.fromList(img.encodePng(resized, level: 6));
          break;
        case 'webp':
          compressed = Uint8List.fromList(
            img.encodeJpg(resized, quality: quality.value.toInt()),
          ); // Note: image package doesn't support WebP encoding
          break;
        case 'jpeg':
        default:
          compressed = Uint8List.fromList(
            img.encodeJpg(resized, quality: quality.value.toInt()),
          );
          break;
      }

      // 检查目标大小
      final targetSizeKB = double.tryParse(targetSizeController.text);
      if (targetSizeKB != null && targetSizeKB > 0) {
        final targetBytes = (targetSizeKB * 1024).toInt();
        if (compressed.length > targetBytes) {
          // 尝试降低质量
          compressed = await _compressToTargetSize(
            resized,
            targetBytes,
            actualFormat,
          );
        }
      }

      compressedBytes.value = compressed;
      compressedWidth.value = resized.width;
      compressedHeight.value = resized.height;
      compressedSize.value = compressed.length / 1024; // KB
      hasCompressed.value = true;

      ToastUtils.showSuccess('压缩成功！');
    } catch (e) {
      ToastUtils.showError('压缩失败: $e');
    } finally {
      isCompressing.value = false;
    }
  }

  /// 计算目标尺寸
  Map<String, int> _computeTargetSize(int width, int height) {
    final maxWidth = int.tryParse(maxWidthController.text);
    final maxHeight = int.tryParse(maxHeightController.text);

    int targetWidth = width;
    int targetHeight = height;

    if (maxWidth != null && maxWidth > 0 ||
        maxHeight != null && maxHeight > 0) {
      final scaleW = maxWidth != null && maxWidth > 0
          ? maxWidth / width
          : double.infinity;
      final scaleH = maxHeight != null && maxHeight > 0
          ? maxHeight / height
          : double.infinity;

      double scale = scaleW < scaleH ? scaleW : scaleH;
      if (scale == double.infinity) scale = 1.0;

      // 禁止放大
      if (avoidUpscale.value) {
        scale = scale > 1.0 ? 1.0 : scale;
      }

      targetWidth = (width * scale).toInt().clamp(1, width * 2);
      targetHeight = (height * scale).toInt().clamp(1, height * 2);
    }

    return {'width': targetWidth, 'height': targetHeight};
  }

  /// 检测是否有透明通道
  bool _hasAlpha(img.Image image) {
    // 简单检测：如果图片有 alpha 通道
    return image.numChannels == 4;
  }

  /// 压缩到目标大小
  Future<Uint8List> _compressToTargetSize(
    img.Image image,
    int targetBytes,
    String format,
  ) async {
    int low = 50;
    int high = quality.value.toInt();
    Uint8List? best;

    // 二分查找最佳质量
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final compressed = Uint8List.fromList(
        format == 'png'
            ? img.encodePng(image, level: 9)
            : img.encodeJpg(image, quality: mid),
      );

      if (compressed.length <= targetBytes) {
        best = compressed;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return best ?? Uint8List.fromList(img.encodeJpg(image, quality: 50));
  }

  /// 保存压缩后的图片
  Future<void> saveCompressedImage() async {
    if (compressedBytes.value == null) {
      ToastUtils.showError('没有可保存的图片');
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = selectedFormat.value == 'png' ? 'png' : 'jpg';
      final filePath = '${directory.path}/compressed_$timestamp.$ext';

      final file = File(filePath);
      await file.writeAsBytes(compressedBytes.value!);

      // 分享文件
      await Share.shareXFiles([XFile(filePath)], text: '压缩后的图片');

      ToastUtils.showSuccess('图片已保存并可分享');
    } catch (e) {
      ToastUtils.showError('保存失败: $e');
    }
  }

  /// 重置
  void reset() {
    originalImage.value = null;
    originalBytes.value = null;
    compressedBytes.value = null;
    hasCompressed.value = false;
    originalWidth.value = 0;
    originalHeight.value = 0;
    originalSize.value = 0.0;
    compressedWidth.value = 0;
    compressedHeight.value = 0;
    compressedSize.value = 0.0;
  }

  /// 获取压缩率
  String get compressionRate {
    if (originalSize.value == 0 || compressedSize.value == 0) {
      return '-';
    }
    final rate = ((1 - compressedSize.value / originalSize.value) * 100)
        .toStringAsFixed(1);
    return '$rate%';
  }
}
