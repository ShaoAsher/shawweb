import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'speed_test_controller.dart' show SpeedTestController, SpeedUnit;

class SpeedTestPage extends GetView<SpeedTestController> {
  const SpeedTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return ToolPageWrapper(
      title: '网络测速工具',
      titleEn: 'Network Speed Test',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          children: [
            // 服务器信息
            Obx(
              () => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.serverInfo.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 速度单位选择
            _SpeedUnitSelector(controller: controller, isTablet: isTablet),
            const SizedBox(height: 16),
            // 开始测试按钮
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => GradientActionButton(
                  icon: controller.isTesting.value
                      ? Icons.hourglass_empty
                      : Icons.rocket_launch,
                  label: controller.isTesting.value ? '测试中...' : '开始测速',
                  onPressed: controller.isTesting.value
                      ? null
                      : controller.runSpeedTest,
                  color: Theme.of(context).primaryColor,
                  isTablet: isTablet,
                  enableAnimation: !controller.isTesting.value,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 测试结果卡片
            _TestResultsSection(controller: controller, isTablet: isTablet),
            const SizedBox(height: 24),
            // 测试摘要
            Obx(
              () => controller.showSummary.value
                  ? _SummarySection(controller: controller, isTablet: isTablet)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestResultsSection extends StatelessWidget {
  final SpeedTestController controller;
  final bool isTablet;

  const _TestResultsSection({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ResultCard(
            controller: controller,
            type: TestType.ping,
            icon: Icons.satellite_alt,
            label: '延迟 (Ping)',
            unit: 'ms',
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => _ResultCard(
              controller: controller,
              type: TestType.download,
              icon: Icons.download,
              label: '下载速度',
              unit: controller.speedUnit.value.label,
              isTablet: isTablet,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => _ResultCard(
              controller: controller,
              type: TestType.upload,
              icon: Icons.upload,
              label: '上传速度',
              unit: controller.speedUnit.value.label,
              isTablet: isTablet,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedUnitSelector extends StatelessWidget {
  final SpeedTestController controller;
  final bool isTablet;

  const _SpeedUnitSelector({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.speed, color: theme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            '速度单位:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => DropdownButtonFormField<SpeedUnit>(
                initialValue: controller.speedUnit.value,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                isExpanded: true,
                items: SpeedUnit.values.map((unit) {
                  return DropdownMenuItem<SpeedUnit>(
                    value: unit,
                    child: Text(
                      unit.label,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (unit) {
                  if (unit != null) {
                    controller.setSpeedUnit(unit);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TestType { ping, download, upload }

class _ResultCard extends StatelessWidget {
  final SpeedTestController controller;
  final TestType type;
  final IconData icon;
  final String label;
  final String unit;
  final bool isTablet;

  const _ResultCard({
    required this.controller,
    required this.type,
    required this.icon,
    required this.label,
    required this.unit,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      String value;
      String status;
      double progress;
      bool isTesting;

      switch (type) {
        case TestType.ping:
          value = controller.pingValue.value;
          status = controller.pingStatus.value;
          progress = controller.pingProgress.value;
          isTesting = controller.isPingTesting.value;
          break;
        case TestType.download:
          value = controller.downloadValue.value;
          status = controller.downloadStatus.value;
          progress = controller.downloadProgress.value;
          isTesting = controller.isDownloadTesting.value;
          break;
        case TestType.upload:
          value = controller.uploadValue.value;
          status = controller.uploadStatus.value;
          progress = controller.uploadProgress.value;
          isTesting = controller.isUploadTesting.value;
          break;
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.cardColor,
          border: Border.all(
            color: isTesting
                ? theme.primaryColor
                : theme.dividerColor.withValues(alpha: 0.3),
            width: isTesting ? 2 : 1,
          ),
          boxShadow: isTesting
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Icon(icon, size: isTablet ? 40 : 36, color: theme.primaryColor),
            const SizedBox(height: 8),
            // 标签
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // 数值 - 自适应大小和换行
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 28 : 24,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(height: 2),
            // 单位
            Text(
              unit,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // 状态
            Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // 进度条
            if (isTesting || progress > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _SummarySection extends StatelessWidget {
  final SpeedTestController controller;
  final bool isTablet;

  const _SummarySection({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: theme.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                '测试结果摘要',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isTablet ? 2.2 : 1.8,
              children: [
                _SummaryItem(
                  label: '延迟',
                  value: controller.summaryPing.value,
                  icon: Icons.satellite_alt,
                ),
                _SummaryItem(
                  label: '下载速度',
                  value: controller.summaryDownload.value,
                  icon: Icons.download,
                ),
                _SummaryItem(
                  label: '上传速度',
                  value: controller.summaryUpload.value,
                  icon: Icons.upload,
                ),
                _SummaryItem(
                  label: '测试时间',
                  value: controller.summaryTime.value,
                  icon: Icons.timer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 3,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
