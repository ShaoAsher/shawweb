import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/getx_dialog_utils.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'json_to_model_controller.dart';

class JsonToModelPage extends GetView<JsonToModelController> {
  const JsonToModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    // 设置生成成功后的回调，用于显示弹窗
    controller.onGenerateSuccess = () => _showCodeDialog(context);

    return ToolPageWrapper(
      title: 'JSON 转 Model',
      titleEn: 'JSON to Model',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 语言选择按钮
            _LanguageSelectorButton(controller: controller, isTablet: isTablet),
            const SizedBox(height: 16),
            // JSON 输入区域
            _JsonInputSection(controller: controller, isTablet: isTablet),
            const SizedBox(height: 16),
            // 配置选项
            _OptionsSection(controller: controller, isTablet: isTablet),
            const SizedBox(height: 16),
            // 操作按钮（只保留生成按钮）
            _ActionButtons(controller: controller, isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  void _showCodeDialog(BuildContext context) {
    GetXDialogUtils.showCupertinoModal(
      child: _CodeOutputDialog(controller: controller),
    );
  }
}

class _LanguageSelectorButton extends StatelessWidget {
  final JsonToModelController controller;
  final bool isTablet;

  const _LanguageSelectorButton({
    required this.controller,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.code, color: theme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '目标语言',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.selectedLanguage.value.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => _showLanguageDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    GetXDialogUtils.showBottomSheet<void>(
      child: _LanguageSelectionContent(controller: controller),
    );
  }
}

/// 语言选择弹窗内容组件
/// 独立组件，确保关闭逻辑正确
class _LanguageSelectionContent extends StatelessWidget {
  final JsonToModelController controller;

  const _LanguageSelectionContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '选择目标语言',
            style: Get.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final language = ModelLanguage.values[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedLanguage.value == language;
                  return ListTile(
                    leading: Icon(Icons.code, color: Get.theme.primaryColor),
                    title: Text(
                      language.label,
                      style: Get.theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Get.theme.primaryColor,
                          )
                        : null,
                    onTap: () {
                      // 先关闭语言选择弹窗
                      Get.back();
                      // 延迟设置语言，确保弹窗关闭完成
                      Future.microtask(() {
                        controller.setLanguage(language);
                      });
                    },
                  );
                });
              },
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemCount: ModelLanguage.values.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _JsonInputSection extends StatelessWidget {
  final JsonToModelController controller;
  final bool isTablet;

  const _JsonInputSection({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.input, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '输入 JSON 数据',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.jsonInputController,
            maxLines: 10,
            minLines: 8,
            decoration: InputDecoration(
              hintText: '请输入 JSON 数据，例如：{"name": "张三", "age": 25}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GradientActionButton(
                icon: Icons.description,
                label: '加载示例',
                onPressed: controller.loadExample,
                color: theme.primaryColor.withValues(alpha: 0.7),
                isTablet: isTablet,
              ),
              const SizedBox(width: 12),
              GradientActionButton(
                icon: Icons.clear,
                label: '清空',
                onPressed: controller.clearInput,
                color: theme.colorScheme.error,
                isTablet: isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionsSection extends StatelessWidget {
  final JsonToModelController controller;
  final bool isTablet;

  const _OptionsSection({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '配置选项',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 紧凑布局：类名和选项在同一行
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller.classNameController,
                  decoration: InputDecoration(
                    labelText: '类名',
                    hintText: 'Model',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (controller.selectedLanguage.value ==
                          ModelLanguage.dart)
                        _CompactCheckbox(
                          label: '空安全',
                          value: controller.useNullSafety.value,
                          onChanged: (value) =>
                              controller.useNullSafety.value = value ?? true,
                        ),
                      _CompactCheckbox(
                        label: '驼峰命名',
                        value: controller.useCamelCase.value,
                        onChanged: (value) =>
                            controller.useCamelCase.value = value ?? true,
                      ),
                      _CompactCheckbox(
                        label: '添加注释',
                        value: controller.addComments.value,
                        onChanged: (value) =>
                            controller.addComments.value = value ?? false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CompactCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: value
              ? theme.primaryColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          border: Border.all(
            color: value
                ? theme.primaryColor
                : theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: value
                  ? theme.primaryColor
                  : theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: value
                    ? theme.primaryColor
                    : theme.textTheme.bodySmall?.color,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final JsonToModelController controller;
  final bool isTablet;

  const _ActionButtons({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GradientActionButton(
        icon: Icons.code,
        label: '生成 Model',
        onPressed: controller.generateModel,
        color: Theme.of(context).primaryColor,
        isTablet: isTablet,
      ),
    );
  }
}

class _CodeOutputDialog extends StatelessWidget {
  final JsonToModelController controller;

  const _CodeOutputDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // iOS 风格的标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.code_off, color: theme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '生成的代码',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => Text(
                        '(${controller.selectedLanguage.value.label})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => controller.copyCode(),
                      child: Icon(
                        Icons.copy,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => GetXDialogUtils.close(),
                      child: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 代码内容
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFF282C34)),
              child: Obx(() {
                final code = controller.generatedCode.value;
                if (code.isEmpty) {
                  return const SizedBox.shrink();
                }
                // 使用 SelectableText 直接显示代码
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Color(0xFFABB2BF),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
