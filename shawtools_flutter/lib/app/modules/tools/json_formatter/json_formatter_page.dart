import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'json_formatter_controller.dart';

class JsonFormatterPage extends GetView<JsonFormatterController> {
  const JsonFormatterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return ToolPageWrapper(
      title: 'JSON 格式化工具',
      titleEn: 'JSON Formatter',
      child: Column(
        children: [
          // Action Buttons
          _ActionButtons(
            controller: controller,
            isTablet: isTablet,
            onPreview: () => _showPreviewModal(context, isTablet),
          ),
          const SizedBox(height: 16),
          // Input Section (Full Screen)
          Expanded(
            child: _InputSection(controller: controller, isTablet: isTablet),
          ),
        ],
      ),
    );
  }

  void _showPreviewModal(BuildContext context, bool isTablet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _PreviewModal(controller: controller, isTablet: isTablet),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final JsonFormatterController controller;
  final bool isTablet;
  final VoidCallback onPreview;

  const _ActionButtons({
    required this.controller,
    required this.isTablet,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final themeType = AppTheme.getCurrentThemeType(context);
    return Wrap(
      spacing: isTablet ? 12 : 8,
      runSpacing: isTablet ? 12 : 8,
      children: [
        GradientActionButton(
          icon: Icons.format_align_left,
          label: '格式化',
          onPressed: controller.formatJson,
          color: Theme.of(context).primaryColor,
          isTablet: isTablet,
        ),
        GradientActionButton(
          icon: Icons.verified,
          label: '验证',
          onPressed: controller.validateJson,
          color: AppTheme.getSuccessColor(themeType),
          isTablet: isTablet,
        ),
        GradientActionButton(
          icon: Icons.compress,
          label: '压缩',
          onPressed: controller.compressJson,
          color: AppTheme.getWarningColor(themeType),
          isTablet: isTablet,
        ),
        GradientActionButton(
          icon: Icons.copy,
          label: '复制',
          onPressed: controller.copyResult,
          color: AppTheme.getSuccessColor(themeType),
          isTablet: isTablet,
        ),
        GradientActionButton(
          icon: Icons.clear,
          label: '清空',
          onPressed: controller.clearInput,
          color: AppTheme.getErrorColor(themeType),
          isTablet: isTablet,
        ),
        GradientActionButton(
          icon: Icons.visibility,
          label: '预览',
          onPressed: onPreview,
          color: AppTheme.getInfoColor(themeType),
          isTablet: isTablet,
        ),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  final JsonFormatterController controller;
  final bool isTablet;

  const _InputSection({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.code,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '编辑区域',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColorFromContext(context),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    final isValid = controller.isValid.value;
                    final successColor = AppTheme.getSuccessColorFromContext(
                      context,
                    );
                    final errorColor = AppTheme.getErrorColorFromContext(
                      context,
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isValid
                            ? successColor.withValues(alpha: 0.1)
                            : errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isValid ? '格式正确' : '未验证',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isValid ? successColor : errorColor,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Text Field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: controller.inputController,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.getTextColorFromContext(context),
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入 JSON 内容...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: AppTheme.getTextLightColorFromContext(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Stats
            Obx(
              () => controller.inputStats.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _StatItem(
                            label: '字符数',
                            value: controller.inputStats['chars'] ?? 0,
                          ),
                          const SizedBox(width: 16),
                          _StatItem(
                            label: '行数',
                            value: controller.inputStats['lines'] ?? 0,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }
}

class _PreviewModal extends StatelessWidget {
  final JsonFormatterController controller;
  final bool isTablet;

  const _PreviewModal({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.85;

    return Container(
          height: modalHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Builder(
                builder: (context) => Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.getBorderColorFromContext(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final successColor =
                                AppTheme.getSuccessColorFromContext(context);
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: successColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: successColor,
                                size: 20,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Builder(
                          builder: (context) => Text(
                            '预览区域',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColorFromContext(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: '关闭',
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Obx(() {
                  if (controller.error.value.isNotEmpty) {
                    return Builder(
                      builder: (context) {
                        final errorColor = AppTheme.getErrorColorFromContext(
                          context,
                        );
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: errorColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: errorColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.error.value,
                                    style: TextStyle(
                                      color: errorColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  if (controller.formattedJson.value.isEmpty) {
                    return Builder(
                      builder: (context) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: AppTheme.getTextLightColorFromContext(
                                context,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '请先格式化 JSON',
                              style: TextStyle(
                                color:
                                    AppTheme.getTextSecondaryColorFromContext(
                                      context,
                                    ),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final parsedJson = controller.getParsedJson();
                  if (parsedJson == null) {
                    return Builder(
                      builder: (context) => SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(
                          controller.formattedJson.value,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            height: 1.5,
                            color: AppTheme.getTextColorFromContext(context),
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _JsonTreeView(data: parsedJson, indent: 0),
                  );
                }),
              ),
              // Stats
              Obx(
                () => controller.outputStats.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _StatItem(
                              label: '字符数',
                              value: controller.outputStats['chars'] ?? 0,
                            ),
                            const SizedBox(width: 16),
                            _StatItem(
                              label: '行数',
                              value: controller.outputStats['lines'] ?? 0,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('复制'),
                              onPressed: controller.copyResult,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.getTextSecondaryColorFromContext(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _JsonTreeView extends StatefulWidget {
  final dynamic data;
  final int indent;

  const _JsonTreeView({required this.data, this.indent = 0});

  @override
  State<_JsonTreeView> createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<_JsonTreeView> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final indent = widget.indent;

    if (data == null) {
      return _JsonValue(
        value: 'null',
        type: JsonValueType.nullValue,
        indent: indent,
      );
    }

    if (data is String) {
      return _JsonValue(
        value: '"$data"',
        type: JsonValueType.string,
        indent: indent,
      );
    }

    if (data is num) {
      return _JsonValue(
        value: data.toString(),
        type: JsonValueType.number,
        indent: indent,
      );
    }

    if (data is bool) {
      return _JsonValue(
        value: data.toString(),
        type: JsonValueType.boolean,
        indent: indent,
      );
    }

    if (data is List) {
      if (data.isEmpty) {
        return Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(left: indent * 20.0),
            child: Text(
              '[]',
              style: TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.getTextColorFromContext(context),
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: EdgeInsets.only(left: indent * 20.0),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => Icon(
                      _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                      size: 18,
                      color: AppTheme.getTextSecondaryColorFromContext(context),
                    ),
                  ),
                  Text(
                    '[',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: AppTheme.getTextColorFromContext(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Builder(
                    builder: (context) => Text(
                      '${data.length} items',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppTheme.getTextSecondaryColorFromContext(
                          context,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const Text(
                    ']',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              margin: EdgeInsets.only(left: (indent + 1) * 20.0),
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppTheme.getBorderColorFromContext(context),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < data.length; i++) ...[
                    _JsonTreeView(data: data[i], indent: indent + 1),
                    if (i < data.length - 1)
                      Builder(
                        builder: (context) => Text(
                          ',',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.getTextColorFromContext(context),
                          ),
                        ),
                      ),
                  ],
                  Builder(
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(left: indent * 20.0),
                      child: Text(
                        ']',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.getTextColorFromContext(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    if (data is Map) {
      final keys = data.keys.toList();
      if (keys.isEmpty) {
        return Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(left: indent * 20.0),
            child: Text(
              '{}',
              style: TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.getTextColorFromContext(context),
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: EdgeInsets.only(left: indent * 20.0),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => Icon(
                      _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                      size: 18,
                      color: AppTheme.getTextSecondaryColorFromContext(context),
                    ),
                  ),
                  Text(
                    '{',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: AppTheme.getTextColorFromContext(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Builder(
                    builder: (context) => Text(
                      '${keys.length} keys',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppTheme.getTextSecondaryColorFromContext(
                          context,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const Text(
                    '}',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              margin: EdgeInsets.only(left: (indent + 1) * 20.0),
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppTheme.getBorderColorFromContext(context),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < keys.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) => Text(
                            '"${keys[i]}"',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              color: AppTheme.getJsonKeyColorFromContext(
                                context,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          ': ',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: AppTheme.getTextColorFromContext(context),
                          ),
                        ),
                        Expanded(
                          child: _JsonTreeView(data: data[keys[i]], indent: 0),
                        ),
                      ],
                    ),
                    if (i < keys.length - 1)
                      Builder(
                        builder: (context) => Text(
                          ',',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.getTextColorFromContext(context),
                          ),
                        ),
                      ),
                  ],
                  Builder(
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(left: indent * 20.0),
                      child: Text(
                        '}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.getTextColorFromContext(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

enum JsonValueType { string, number, boolean, nullValue }

class _JsonValue extends StatelessWidget {
  final String value;
  final JsonValueType type;
  final int indent;

  const _JsonValue({
    required this.value,
    required this.type,
    required this.indent,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case JsonValueType.string:
        color = AppTheme.getJsonStringColorFromContext(context);
        break;
      case JsonValueType.number:
        color = AppTheme.getJsonNumberColorFromContext(context);
        break;
      case JsonValueType.boolean:
        color = AppTheme.getJsonBooleanColorFromContext(context);
        break;
      case JsonValueType.nullValue:
        color = AppTheme.getJsonNullColorFromContext(context);
        break;
    }

    return Padding(
      padding: EdgeInsets.only(left: indent * 20.0),
      child: Text(
        value,
        style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: color),
      ),
    );
  }
}
