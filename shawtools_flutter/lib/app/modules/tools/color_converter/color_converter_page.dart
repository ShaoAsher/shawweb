import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/getx_dialog_utils.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'color_converter_controller.dart';

class ColorConverterPage extends GetView<ColorConverterController> {
  const ColorConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return ToolPageWrapper(
      title: 'RGB 颜色互转工具',
      titleEn: 'RGB Color Converter',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              icon: Icons.palette,
              title: '颜色输入',
              child: _ColorInputSection(
                controller: controller,
                isTablet: isTablet,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            _SectionCard(
              icon: Icons.format_paint,
              title: '转换结果',
              child: _ColorResultSection(controller: controller),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            // 颜色预设按钮
            GradientActionButton(
              icon: Icons.style,
              label: '选择颜色预设',
              onPressed: () => _showColorPresetsDialog(context, controller),
              color: Theme.of(context).primaryColor,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPresetsDialog(
    BuildContext context,
    ColorConverterController controller,
  ) {
    GetXDialogUtils.showCupertinoModal(
      child: _ColorPresetsDialog(controller: controller),
    );
  }
}

class _ColorPresetsDialog extends StatelessWidget {
  final ColorConverterController controller;

  const _ColorPresetsDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    final groups = controller.presetGroups;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '颜色预设',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => GetXDialogUtils.close(),
                  child: const Icon(CupertinoIcons.xmark_circle_fill, size: 28),
                ),
              ],
            ),
          ),
          // 颜色列表 - 使用 ListView 显示分组
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: groups.length,
              itemBuilder: (context, groupIndex) {
                final group = groups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (groupIndex > 0) const SizedBox(height: 16),
                    // 分组标题
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        group.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // 分组颜色卡片 GridView
                    GridView.builder(
                      padding: EdgeInsets.only(top: 5, bottom: 20),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                      itemCount: group.colors.length,
                      itemBuilder: (context, index) {
                        return _ColorPresetCard(
                          controller: controller,
                          preset: group.colors[index],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPresetCard extends StatelessWidget {
  final ColorConverterController controller;
  final ColorPreset preset;

  const _ColorPresetCard({required this.controller, required this.preset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseHexColor(preset.hex);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.applyPreset(preset);
          GetXDialogUtils.close();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                preset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                preset.hex,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.getTextSecondaryColorFromContext(context),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseHexColor(String hex) {
    var value = hex.replaceFirst('#', '');
    if (value.length == 3) {
      value = value.split('').map((c) => '$c$c').join();
    }
    if (value.length != 6) {
      return Colors.transparent;
    }
    final r = int.parse(value.substring(0, 2), radix: 16);
    final g = int.parse(value.substring(2, 4), radix: 16);
    final b = int.parse(value.substring(4, 6), radix: 16);
    return Color.fromARGB(255, r, g, b);
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.cardColor, theme.cardColor.withValues(alpha: 0.92)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: theme.primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ColorInputSection extends StatelessWidget {
  final ColorConverterController controller;
  final bool isTablet;

  const _ColorInputSection({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEX 输入
        TextField(
          controller: controller.hexController,
          onChanged: (_) => controller.convertFromHex(),
          decoration: const InputDecoration(
            labelText: 'HEX 颜色值',
            hintText: '#FF5733 或 FF5733',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        // RGB 输入 - 使用 Row 紧凑布局
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.rController,
                keyboardType: TextInputType.number,
                onChanged: (_) => controller.convertFromRgb(),
                decoration: const InputDecoration(
                  labelText: 'R (0-255)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.gController,
                keyboardType: TextInputType.number,
                onChanged: (_) => controller.convertFromRgb(),
                decoration: const InputDecoration(
                  labelText: 'G (0-255)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.bController,
                keyboardType: TextInputType.number,
                onChanged: (_) => controller.convertFromRgb(),
                decoration: const InputDecoration(
                  labelText: 'B (0-255)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 颜色预览
        Text(
          '颜色预览',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.getTextSecondaryColorFromContext(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.getBorderColorFromContext(context),
            ),
          ),
          child: Obx(
            () => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: controller.previewColor.value,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 操作按钮
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            GradientActionButton(
              icon: Icons.swap_horiz,
              label: '转换',
              onPressed: controller.convert,
              color: Theme.of(context).primaryColor,
              isTablet: MediaQuery.of(context).size.width > 600,
            ),
            GradientActionButton(
              icon: Icons.clear,
              label: '清空',
              onPressed: controller.clear,
              color: AppTheme.getErrorColor(
                AppTheme.getCurrentThemeType(context),
              ),
              isTablet: MediaQuery.of(context).size.width > 600,
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorResultSection extends StatelessWidget {
  final ColorConverterController controller;

  const _ColorResultSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final text = controller.resultText.value;
      if (text.isEmpty) {
        return Text(
          '请输入颜色或选择预设进行转换。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.getTextSecondaryColorFromContext(context),
          ),
        );
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
        ),
      );
    });
  }
}
