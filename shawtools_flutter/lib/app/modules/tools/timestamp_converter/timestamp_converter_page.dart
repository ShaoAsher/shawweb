import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../widgets/tool_page_wrapper.dart';
import 'timestamp_converter_controller.dart';

class TimestampConverterPage extends GetView<TimestampConverterController> {
  const TimestampConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return ToolPageWrapper(
      title: '时间戳转换工具',
      titleEn: 'Timestamp Converter',
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(
                context,
              ).textTheme.bodyLarge?.color,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.schedule), text: '时间戳转日期'),
                Tab(icon: Icon(Icons.event), text: '日期转时间戳'),
                Tab(icon: Icon(Icons.access_time_filled_rounded), text: '当前时间'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: _SectionCard(
                      icon: Icons.schedule,
                      title: '时间戳转日期',
                      child: _TimestampToDateSection(
                        controller: controller,
                        isTablet: isTablet,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: _SectionCard(
                      icon: Icons.event,
                      title: '日期转时间戳',
                      child: _DateToTimestampSection(
                        controller: controller,
                        isTablet: isTablet,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: _SectionCard(
                      icon: Icons.access_time_filled_rounded,
                      title: '当前时间',
                      child: _CurrentTimeSection(
                        controller: controller,
                        isTablet: isTablet,
                      ),
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

class _TimestampToDateSection extends StatelessWidget {
  final TimestampConverterController controller;
  final bool isTablet;

  const _TimestampToDateSection({
    required this.controller,
    required this.isTablet,
  });

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
              width: isTablet ? 260 : double.infinity,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: controller.setTimestampInput,
                decoration: const InputDecoration(
                  labelText: '时间戳',
                  hintText: '输入时间戳（秒或毫秒）',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: isTablet ? 220 : double.infinity,
              child: Obx(
                () => InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '时间戳类型',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.timestampType.value,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'auto', child: Text('自动识别')),
                        DropdownMenuItem(
                          value: 'second',
                          child: Text('秒（10位）'),
                        ),
                        DropdownMenuItem(
                          value: 'millisecond',
                          child: Text('毫秒（13位）'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          controller.setTimestampType(v);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: isTablet ? 220 : double.infinity,
          child: ElevatedButton(
            onPressed: controller.convertTimestamp,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
            ),
            child: const Text('转换为日期'),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final items = controller.timestampResults;
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }
          return _ResultGrid(items: items);
        }),
        const SizedBox(height: 4),
        Text(
          '点击任意结果可复制值到剪贴板。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _DateToTimestampSection extends StatelessWidget {
  final TimestampConverterController controller;
  final bool isTablet;

  const _DateToTimestampSection({
    required this.controller,
    required this.isTablet,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (date == null) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    controller.setDateInput(DateFormat('yyyy-MM-dd HH:mm:ss').format(combined));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = this.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: isTablet ? 16 : 12,
          runSpacing: isTablet ? 16 : 12,
          children: [
            SizedBox(
              width: isTablet ? 260 : double.infinity,
              child: Obx(
                () => TextField(
                  controller: TextEditingController(
                    text: controller.dateInput.value,
                  ),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '日期时间',
                    hintText: '选择日期或使用当前时间',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: isTablet ? 220 : double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDateTime(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 14 : 12,
                        ),
                      ),
                      child: const Text('选择日期时间'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: controller.setNowToDateInput,
                    tooltip: '使用当前时间',
                    icon: Icon(Icons.access_time, color: theme.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: isTablet ? 220 : double.infinity,
          child: ElevatedButton(
            onPressed: controller.convertDateToTimestamp,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
            ),
            child: const Text('转换为时间戳'),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final items = controller.dateResults;
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }
          return _ResultGrid(items: items);
        }),
      ],
    );
  }
}

class _CurrentTimeSection extends StatelessWidget {
  final TimestampConverterController controller;
  final bool isTablet;

  const _CurrentTimeSection({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isTablet ? 260 : double.infinity,
          child: ElevatedButton(
            onPressed: controller.generateCurrentTime,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
            ),
            child: const Text('获取当前时间戳'),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final items = controller.currentTimeResults;
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }
          return _ResultGrid(items: items);
        }),
      ],
    );
  }
}

class _ResultGrid extends StatelessWidget {
  final List<TimestampResultItem> items;

  const _ResultGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isTablet ? 3.4 : 3.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: item.value));
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
