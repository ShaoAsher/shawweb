import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
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
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.format_paint,
              title: '转换结果',
              child: _ColorResultSection(controller: controller),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.style,
              title: '颜色预设',
              child: _ColorPresetsSection(
                controller: controller,
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ),
    );
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
        Wrap(
          spacing: isTablet ? 16 : 12,
          runSpacing: isTablet ? 16 : 12,
          children: [
            SizedBox(
              width: isTablet ? 260 : MediaQuery.of(context).size.width,
              child: TextField(
                controller: controller.hexController,
                onChanged: (_) => controller.convertFromHex(),
                decoration: const InputDecoration(
                  labelText: 'HEX 颜色值',
                  hintText: '#FF5733 或 FF5733',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: isTablet ? 120 : MediaQuery.of(context).size.width,
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
            SizedBox(
              width: isTablet ? 120 : MediaQuery.of(context).size.width,
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
            SizedBox(
              width: isTablet ? 120 : MediaQuery.of(context).size.width,
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
        Text(
          '颜色预览',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.getTextSecondaryColorFromContext(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: isTablet ? 80 : 64,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
        ),
      );
    });
  }
}

class _ColorPresetsSection extends StatelessWidget {
  final ColorConverterController controller;
  final bool isTablet;

  const _ColorPresetsSection({
    required this.controller,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final groups = controller.presetGroups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Text(
            group.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: group.colors
                .map(
                  (preset) => _ColorPresetCard(
                    controller: controller,
                    preset: preset,
                    isTablet: isTablet,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ColorPresetCard extends StatelessWidget {
  final ColorConverterController controller;
  final ColorPreset preset;
  final bool isTablet;

  const _ColorPresetCard({
    required this.controller,
    required this.preset,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => controller.applyPreset(preset),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: isTablet ? 180 : 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                color: _parseHexColor(preset.hex),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    preset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.hex,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextSecondaryColorFromContext(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
