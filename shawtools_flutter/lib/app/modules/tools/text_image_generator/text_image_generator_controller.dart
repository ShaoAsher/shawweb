import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/toast_utils.dart';

/// 背景类型
enum BackgroundType { solid, gradient }

/// 预设模板
class PresetTemplate {
  final String name;
  final BackgroundType type;
  final Color solidColor;
  final Color? gradientStart;
  final Color? gradientEnd;
  final Color textColor;

  const PresetTemplate({
    required this.name,
    required this.type,
    required this.solidColor,
    this.gradientStart,
    this.gradientEnd,
    required this.textColor,
  });
}

/// 文字图片生成器控制器
class TextImageGeneratorController extends GetxController {
  final textController = TextEditingController(text: 'A');
  RxString text = 'A'.obs;

  Rx<BackgroundType> backgroundType = BackgroundType.solid.obs;
  Rx<Color> solidColor = const Color(0xFFFFFF00).obs;
  Rx<Color> gradientStartColor = const Color(0xFFFF0000).obs;
  Rx<Color> gradientEndColor = const Color(0xFF0000FF).obs;
  Rx<Color> textColor = const Color(0xFF000000).obs;

  RxBool isGenerating = false.obs;
  Rx<Uint8List?> generatedImage = Rx<Uint8List?>(null);

  // 预设模板
  final presets = <PresetTemplate>[
    const PresetTemplate(
      name: '黄底黑字',
      type: BackgroundType.solid,
      solidColor: Color(0xFFFFFF00),
      textColor: Color(0xFF000000),
    ),
    const PresetTemplate(
      name: '红底白字',
      type: BackgroundType.solid,
      solidColor: Color(0xFFFF0000),
      textColor: Color(0xFFFFFFFF),
    ),
    const PresetTemplate(
      name: '蓝底白字',
      type: BackgroundType.solid,
      solidColor: Color(0xFF0000FF),
      textColor: Color(0xFFFFFFFF),
    ),
    const PresetTemplate(
      name: '绿底白字',
      type: BackgroundType.solid,
      solidColor: Color(0xFF00FF00),
      textColor: Color(0xFF000000),
    ),
    const PresetTemplate(
      name: '紫色渐变',
      type: BackgroundType.gradient,
      solidColor: Color(0xFF9C27B0),
      gradientStart: Color(0xFF9C27B0),
      gradientEnd: Color(0xFF673AB7),
      textColor: Color(0xFFFFFFFF),
    ),
    const PresetTemplate(
      name: '橙色渐变',
      type: BackgroundType.gradient,
      solidColor: Color(0xFFFF9800),
      gradientStart: Color(0xFFFF9800),
      gradientEnd: Color(0xFFFF5722),
      textColor: Color(0xFFFFFFFF),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.onClose();
  }

  void _onTextChanged() {
    text.value = textController.text;
  }

  /// 应用预设模板
  void applyPreset(PresetTemplate preset) {
    backgroundType.value = preset.type;
    solidColor.value = preset.solidColor;
    if (preset.gradientStart != null) {
      gradientStartColor.value = preset.gradientStart!;
    }
    if (preset.gradientEnd != null) {
      gradientEndColor.value = preset.gradientEnd!;
    }
    textColor.value = preset.textColor;
    ToastUtils.showSuccess('已应用预设：${preset.name}');
  }

  /// 生成图片
  Future<void> generateImage() async {
    final inputText = textController.text.trim();
    if (inputText.isEmpty) {
      ToastUtils.showError('请输入文字');
      return;
    }

    if (inputText.length > 4) {
      ToastUtils.showError('文字最多4个字符');
      return;
    }

    isGenerating.value = true;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(1024, 1024);

      // 绘制背景
      final paint = Paint();
      if (backgroundType.value == BackgroundType.solid) {
        paint.color = solidColor.value;
        canvas.drawRect(Offset.zero & size, paint);
      } else {
        paint.shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(size.width, size.height),
          [gradientStartColor.value, gradientEndColor.value],
        );
        canvas.drawRect(Offset.zero & size, paint);
      }

      // 绘制文字
      final textPainter = TextPainter(
        text: TextSpan(
          text: inputText,
          style: TextStyle(
            color: textColor.value,
            fontSize: 400,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      final xCenter = (size.width - textPainter.width) / 2;
      final yCenter = (size.height - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(xCenter, yCenter));

      // 转换为图片
      final picture = recorder.endRecording();
      final image = await picture.toImage(1024, 1024);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      generatedImage.value = bytes;
      ToastUtils.showSuccess('图片生成成功！');
    } catch (e) {
      ToastUtils.showError('生成失败: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  /// 保存图片
  Future<void> saveImage() async {
    if (generatedImage.value == null) {
      ToastUtils.showError('请先生成图片');
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/text_image_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(generatedImage.value!);

      await Share.shareXFiles([XFile(filePath)], text: '生成的文字图片');

      ToastUtils.showSuccess('图片已保存并可分享');
    } catch (e) {
      ToastUtils.showError('保存失败: $e');
    }
  }
}
