import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'ip_query_controller.dart';

class IpQueryPage extends GetView<IpQueryController> {
  const IpQueryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return ToolPageWrapper(
      title: 'IP地址查询工具',
      titleEn: 'IP Address Query Tool',
      child: SingleChildScrollView(
        child: _QuerySection(controller: controller, isTablet: isTablet),
      ),
    );
  }
}

class _QuerySection extends StatelessWidget {
  final IpQueryController controller;
  final bool isTablet;

  const _QuerySection({required this.controller, required this.isTablet});

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
        padding: EdgeInsets.all(isTablet ? 24 : 16),
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
                  child: const Icon(Icons.public, color: Colors.blue, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'IP地址查询',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.ipInputController,
                    decoration: InputDecoration(
                      labelText: 'IP地址',
                      hintText: '请输入IP地址或点击右侧按钮查询我的IP',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.computer),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => controller.queryIp(),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isLoadingCurrent.value
                        ? null
                        : () => controller.queryCurrentIpAndSet(),
                    icon: controller.isLoadingCurrent.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('查询我的IP'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => GradientActionButton(
                  icon: controller.isLoadingQuery.value
                      ? Icons.hourglass_empty
                      : Icons.search,
                  label: '查询',
                  onPressed: controller.isLoadingQuery.value
                      ? null
                      : controller.queryIp,
                  color: Theme.of(context).primaryColor,
                  isTablet: isTablet,
                  enableAnimation: !controller.isLoadingQuery.value,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final info = controller.queryIpInfo.value;
              if (info == null) return const SizedBox.shrink();
              return _ResultCard(info: info, isTablet: isTablet);
            }),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IpInfo info;
  final bool isTablet;

  const _ResultCard({required this.info, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'IP地址',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  info.ip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoGrid(info: info, isTablet: isTablet),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final IpInfo info;
  final bool isTablet;

  const _InfoGrid({required this.info, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      _InfoItem(label: '国家', value: info.country, icon: Icons.flag),
      _InfoItem(label: '地区', value: info.region, icon: Icons.location_city),
      _InfoItem(label: '城市', value: info.city, icon: Icons.location_on),
      _InfoItem(label: '邮编', value: info.zip, icon: Icons.markunread_mailbox),
      _InfoItem(label: '时区', value: info.timezone, icon: Icons.access_time),
      _InfoItem(label: 'ISP', value: info.isp, icon: Icons.router),
      _InfoItem(label: '组织', value: info.org, icon: Icons.business),
      _InfoItem(label: 'ASN', value: info.asn, icon: Icons.dns),
      if (info.lat != 0 && info.lon != 0)
        _InfoItem(
          label: '经纬度',
          value:
              '${info.lat.toStringAsFixed(4)}, ${info.lon.toStringAsFixed(4)}',
          icon: Icons.explore,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isTablet ? 1.8 : 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 14,
                    color: AppTheme.getTextSecondaryColorFromContext(context),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextSecondaryColorFromContext(
                          context,
                        ),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  item.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
