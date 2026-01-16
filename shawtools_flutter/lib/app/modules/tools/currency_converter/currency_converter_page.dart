import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'currency_converter_controller.dart';

class CurrencyConverterPage extends GetView<CurrencyConverterController> {
  const CurrencyConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolPageWrapper(
      title: '汇率转换工具',
      titleEn: 'Currency Converter',
      child: _TabLayout(controller: controller),
    );
  }
}

class _TabLayout extends StatelessWidget {
  final CurrencyConverterController controller;
  const _TabLayout({required this.controller});
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.currency_exchange), text: '汇率转换'),
              Tab(icon: Icon(Icons.list_alt), text: '汇率列表'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: _SectionCard(
                    icon: Icons.currency_exchange,
                    title: '汇率换算',
                    child: _ConverterSection(
                      controller: controller,
                      isTablet: isTablet,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: _SectionCard(
                    icon: Icons.list_alt,
                    title: '实时汇率列表',
                    child: _RatesSection(
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

class _ConverterSection extends StatelessWidget {
  final CurrencyConverterController controller;
  final bool isTablet;
  const _ConverterSection({required this.controller, required this.isTablet});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: isTablet ? 16 : 12,
          runSpacing: isTablet ? 16 : 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: isTablet ? 200 : MediaQuery.of(context).size.width,
              child: TextField(
                controller: controller.amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '金额',
                  hintText: '请输入金额',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: isTablet ? 200 : MediaQuery.of(context).size.width,
              child: _CurrencyPickerField(
                controller: controller,
                label: '来源货币',
                isFrom: true,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    final from = controller.fromCurrency.value;
                    final to = controller.toCurrency.value;
                    controller.setFromCurrency(to);
                    controller.setToCurrency(from);
                    controller.convert();
                  },
                  icon: Icon(Icons.swap_horiz, color: theme.primaryColor),
                ),
              ],
            ),
            SizedBox(
              width: isTablet ? 200 : MediaQuery.of(context).size.width,
              child: _CurrencyPickerField(
                controller: controller,
                label: '目标货币',
                isFrom: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: isTablet ? 200 : MediaQuery.of(context).size.width,
          child: GradientActionButton(
            icon: Icons.swap_horiz,
            label: '转换',
            onPressed: controller.convert,
            color: Theme.of(context).primaryColor,
            isTablet: isTablet,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final text = controller.resultText.value;
          if (text.isEmpty) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.8),
              ),
            ),
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _CurrencyPickerField extends StatelessWidget {
  final CurrencyConverterController controller;
  final String label;
  final bool isFrom;
  const _CurrencyPickerField({
    required this.controller,
    required this.label,
    required this.isFrom,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final code = isFrom
          ? controller.fromCurrency.value
          : controller.toCurrency.value;
      final name = controller.getCurrencyName(code);
      final flag = controller.getCurrencyFlag(code);
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCurrencyPicker(context, controller: controller, isFrom: isFrom);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      code,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextSecondaryColorFromContext(
                          context,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
      );
    });
  }
}

Future<void> _showCurrencyPicker(
  BuildContext context, {
  required CurrencyConverterController controller,
  required bool isFrom,
}) async {
  final theme = Theme.of(context);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      String query = '';
      return StatefulBuilder(
        builder: (context, setState) {
          final all = controller.currencies;
          final lower = query.toLowerCase();
          final filtered = all.where((c) {
            if (lower.isEmpty) return true;
            return c.code.toLowerCase().contains(lower) ||
                c.name.toLowerCase().contains(lower);
          });
          final items = filtered.toList()
            ..sort((a, b) => a.code.compareTo(b.code));
          final selectedCode = isFrom
              ? controller.fromCurrency.value
              : controller.toCurrency.value;
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isFrom ? '选择来源货币' : '选择目标货币',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: '搜索货币名称或代码',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    onChanged: (v) {
                      setState(() {
                        query = v.trim();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color:
                                    AppTheme.getTextSecondaryColorFromContext(
                                      context,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '未找到匹配的货币',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color:
                                      AppTheme.getTextSecondaryColorFromContext(
                                        context,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final c = items[index];
                            final code = c.code;
                            final name = c.name;
                            final flag = controller.getCurrencyFlag(code);
                            final selected = selectedCode == code;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      )
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      flag,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      code,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: selected
                                                ? theme.colorScheme.primary
                                                : null,
                                          ),
                                    ),
                                    if (selected) const SizedBox(width: 8),
                                    if (selected)
                                      Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          AppTheme.getTextSecondaryColorFromContext(
                                            context,
                                          ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                onTap: () {
                                  if (isFrom) {
                                    controller.setFromCurrency(code);
                                  } else {
                                    controller.setToCurrency(code);
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _RatesSection extends StatelessWidget {
  final CurrencyConverterController controller;
  final bool isTablet;
  const _RatesSection({required this.controller, required this.isTablet});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final base = controller.base.value.isEmpty
                    ? controller.fromCurrency.value
                    : controller.base.value;
                final updated = controller.lastUpdated.value;
                final info = updated.isEmpty ? '—' : updated;
                return Text(
                  '基准：$base   更新日期：$info',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextSecondaryColorFromContext(context),
                  ),
                );
              }),
            ),
            IconButton(
              onPressed: () =>
                  controller.fetchRates(controller.fromCurrency.value),
              icon: Icon(Icons.refresh, color: theme.primaryColor),
              tooltip: '刷新',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: controller.setSearchQuery,
          decoration: const InputDecoration(
            labelText: '搜索货币代码',
            hintText: '例如 USD、CNY',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final entries = controller.getFilteredRates();
          if (entries.isEmpty) {
            return Text(
              '暂无数据或未匹配到货币代码',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.getTextSecondaryColorFromContext(context),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              final code = e.key;
              final rate = e.value;
              final flag = controller.getCurrencyFlag(code);
              final name = controller.getCurrencyName(code);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            code,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.getTextSecondaryColorFromContext(
                                context,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rate
                          .toStringAsFixed(6)
                          .replaceFirst(RegExp(r'\.?0+$'), ''),
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
