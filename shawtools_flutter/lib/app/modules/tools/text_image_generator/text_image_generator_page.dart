import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'text_image_generator_controller.dart';

/// 文字图片生成器页面
class TextImageGeneratorPage extends GetView<TextImageGeneratorController> {
  const TextImageGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolPageWrapper(
      title: '文字图片生成工具',
      titleEn: 'Text Image Generator',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildPresetsSection(),
            const SizedBox(height: 16),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  /// 输入区域
  Widget _buildInputSection() {
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
            '输入配置',
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
          TextField(
            controller: controller.textController,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: '文字内容',
              hintText: '输入 1-4 个字符',
              helperText: '文字将居中显示在 1024×1024 的图片上',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '背景类型',
            style: Get.theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: RadioListTile<BackgroundType>(
                    value: BackgroundType.solid,
                    groupValue: controller.backgroundType.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.backgroundType.value = value;
                      }
                    },
                    title: const Text('单色'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<BackgroundType>(
                    value: BackgroundType.gradient,
                    groupValue: controller.backgroundType.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.backgroundType.value = value;
                      }
                    },
                    title: const Text('渐变色'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.backgroundType.value == BackgroundType.solid) {
              return _buildColorPicker(
                '背景颜色',
                controller.solidColor.value,
                (color) => controller.solidColor.value = color,
              );
            } else {
              return Column(
                children: [
                  _buildColorPicker(
                    '渐变起始颜色',
                    controller.gradientStartColor.value,
                    (color) => controller.gradientStartColor.value = color,
                  ),
                  const SizedBox(height: 12),
                  _buildColorPicker(
                    '渐变结束颜色',
                    controller.gradientEndColor.value,
                    (color) => controller.gradientEndColor.value = color,
                  ),
                ],
              );
            }
          }),
          const SizedBox(height: 16),
          Obx(() {
            return _buildColorPicker(
              '文字颜色',
              controller.textColor.value,
              (color) => controller.textColor.value = color,
            );
          }),
        ],
      ),
    );
  }

  /// 颜色选择器
  Widget _buildColorPicker(
    String label,
    Color value,
    ValueChanged<Color> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final color = await Get.dialog<Color>(
              Dialog(child: _ColorPickerDialog(initialColor: value)),
            );
            if (color != null) {
              onChanged(color);
            }
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: value,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Get.theme.dividerColor, width: 2),
            ),
            child: Center(
              child: Text(
                '#${value.value.toRadixString(16).substring(2).toUpperCase()}',
                style: TextStyle(
                  color: value.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 预设模板区域
  Widget _buildPresetsSection() {
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
            '预设模板',
            style: Get.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: controller.presets.length,
            itemBuilder: (context, index) {
              final preset = controller.presets[index];
              return InkWell(
                onTap: () => controller.applyPreset(preset),
                child: Container(
                  decoration: BoxDecoration(
                    color: preset.solidColor,
                    borderRadius: BorderRadius.circular(8),
                    gradient: preset.type == BackgroundType.gradient
                        ? LinearGradient(
                            colors: [
                              preset.gradientStart!,
                              preset.gradientEnd!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: Border.all(color: Get.theme.dividerColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          color: preset.textColor,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preset.name,
                        style: TextStyle(color: preset.textColor, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 生成按钮
  Widget _buildGenerateButton() {
    return Obx(() {
      final isTablet = MediaQuery.of(Get.context!).size.width > 600;

      if (controller.isGenerating.value) {
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
                '正在生成...',
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
        icon: Icons.auto_awesome,
        label: '生成图片',
        onPressed: () => _generateAndShowResult(),
        color: Get.theme.primaryColor,
        isTablet: isTablet,
      );
    });
  }

  /// 生成并显示结果
  Future<void> _generateAndShowResult() async {
    await controller.generateImage();
    if (controller.generatedImage.value != null) {
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
                      child: Text(
                        '生成完成',
                        style: Get.theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                    // 图片预览
                    Obx(() {
                      if (controller.generatedImage.value != null) {
                        return GestureDetector(
                          onTap: () {
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
                                        child: Image.memory(
                                          controller.generatedImage.value!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: IconButton(
                                        onPressed: () => Get.back(),
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Get.theme.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                controller.generatedImage.value!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 20),
                    // 操作按钮
                    GradientActionButton(
                      icon: Icons.download,
                      label: '保存并分享',
                      onPressed: () {
                        controller.saveImage();
                      },
                      color: AppTheme.getSuccessColor(
                        AppTheme.getCurrentThemeType(Get.context!),
                      ),
                      isTablet: false,
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
}

/// 颜色选择对话框
class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '选择颜色',
            style: Get.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _colors.length,
            itemBuilder: (context, index) {
              final color = _colors[index];
              final isSelected = selectedColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                  });
                  Get.back(result: color);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static const List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];
}
