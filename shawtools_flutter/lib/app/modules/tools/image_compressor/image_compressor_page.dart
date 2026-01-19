import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'image_compressor_controller.dart';

/// 图片压缩页面
class ImageCompressorPage extends GetView<ImageCompressorController> {
  const ImageCompressorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolPageWrapper(
      title: '图片压缩工具',
      titleEn: 'Image Compressor',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUploadSection(),
            Obx(() {
              if (controller.originalBytes.value != null) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSettingsSection(),
                    const SizedBox(height: 16),
                    _buildCompressButton(),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  /// 上传区域
  Widget _buildUploadSection() {
    return Obx(() {
      if (controller.originalBytes.value == null) {
        return GestureDetector(
          onTap: controller.pickImage,
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Get.theme.primaryColor,
                width: 3,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Get.theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '点击选择图片',
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    color: Get.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '支持 JPG、PNG、WEBP',
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.textTheme.bodySmall?.color?.withOpacity(
                      0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // 显示已选择的图片
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已选择图片',
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: controller.reset,
                  icon: const Icon(Icons.close),
                  tooltip: '删除图片',
                  style: IconButton.styleFrom(
                    foregroundColor: Get.theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                controller.originalBytes.value!,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Get.theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '尺寸: ${controller.originalWidth.value}×${controller.originalHeight.value} | '
                      '大小: ${controller.originalSize.value.toStringAsFixed(2)} KB',
                      style: Get.theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 设置区域
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '压缩设置',
            style: Get.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.primaryColor,
                  Get.theme.primaryColor.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Get.theme.colorScheme.secondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Get.theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '默认仅在超过限制时缩小尺寸，始终保持原始宽高比例',
                    style: Get.theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.maxWidthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '最大宽度（像素）',
              hintText: '如 1920',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.maxHeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '最大高度（像素）',
              hintText: '如 1080',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.targetSizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '目标大小（KB）',
              hintText: '如 300',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            return DropdownButtonFormField<String>(
              initialValue: controller.selectedFormat.value,
              decoration: const InputDecoration(
                labelText: '输出格式',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'auto', child: Text('自动')),
                DropdownMenuItem(value: 'jpeg', child: Text('JPEG')),
                DropdownMenuItem(value: 'png', child: Text('PNG')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.selectedFormat.value = value;
                }
              },
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final isDisabled = controller.selectedFormat.value == 'png';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '质量',
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: isDisabled
                        ? Get.theme.disabledColor
                        : Get.theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: controller.quality.value,
                        min: 50,
                        max: 100,
                        divisions: 50,
                        label: controller.quality.value.toInt().toString(),
                        onChanged: isDisabled
                            ? null
                            : (value) {
                                controller.quality.value = value;
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 40,
                      child: Text(
                        controller.quality.value.toInt().toString(),
                        style: Get.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDisabled
                              ? Get.theme.disabledColor
                              : Get.theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            return CheckboxListTile(
              value: controller.avoidUpscale.value,
              onChanged: (value) {
                controller.avoidUpscale.value = value ?? true;
              },
              title: const Text('禁止放大（仅缩小）'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
        ],
      ),
    );
  }

  /// 压缩按钮
  Widget _buildCompressButton() {
    return Obx(() {
      final isDisabled =
          controller.isCompressing.value ||
          controller.originalBytes.value == null;
      final isTablet = MediaQuery.of(Get.context!).size.width > 600;

      if (controller.isCompressing.value) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '正在压缩...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      return GradientActionButton(
        icon: Icons.compress,
        label: '开始压缩',
        onPressed: isDisabled ? null : () => _compressAndShowResult(),
        color: isDisabled ? Get.theme.disabledColor : Get.theme.primaryColor,
        isTablet: isTablet,
        enableAnimation: !isDisabled,
      );
    });
  }

  /// 压缩并显示结果
  Future<void> _compressAndShowResult() async {
    await controller.compressImage();
    if (controller.hasCompressed.value) {
      _showResultDialog();
    }
  }

  /// 显示结果弹窗
  void _showResultDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Get.theme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '压缩完成',
                            style: Get.theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '压缩率: ${controller.compressionRate}',
                            style: Get.theme.textTheme.bodySmall?.copyWith(
                              color: Get.theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      tooltip: '关闭',
                    ),
                  ],
                ),
              ),
              // 内容区域
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 对比展示
                    Row(
                      children: [
                        Expanded(child: _buildDialogPreview(true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDialogPreview(false)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: GradientActionButton(
                            icon: Icons.refresh,
                            label: '重新选择',
                            onPressed: () {
                              Get.back();
                              controller.reset();
                            },
                            color: AppTheme.getWarningColor(
                              AppTheme.getCurrentThemeType(Get.context!),
                            ),
                            isTablet: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientActionButton(
                            icon: Icons.download,
                            label: '保存图片',
                            onPressed: () {
                              controller.saveCompressedImage();
                              Get.back();
                            },
                            color: AppTheme.getSuccessColor(
                              AppTheme.getCurrentThemeType(Get.context!),
                            ),
                            isTablet: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 弹窗中的预览卡片
  Widget _buildDialogPreview(bool isOriginal) {
    return Obx(() {
      final bytes = isOriginal
          ? controller.originalBytes.value
          : controller.compressedBytes.value;
      final width = isOriginal
          ? controller.originalWidth.value
          : controller.compressedWidth.value;
      final height = isOriginal
          ? controller.originalHeight.value
          : controller.compressedHeight.value;
      final size = isOriginal
          ? controller.originalSize.value
          : controller.compressedSize.value;

      if (bytes == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOriginal ? Get.theme.dividerColor : Get.theme.primaryColor,
            width: isOriginal ? 1 : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOriginal ? '原图' : '压缩后',
              style: Get.theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOriginal ? null : Get.theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImagePreview(bytes),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Text('$width×$height', style: Get.theme.textTheme.bodySmall),
            Text(
              '${size.toStringAsFixed(2)} KB',
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: Get.theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 显示图片预览
  void _showImagePreview(Uint8List imageBytes) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
