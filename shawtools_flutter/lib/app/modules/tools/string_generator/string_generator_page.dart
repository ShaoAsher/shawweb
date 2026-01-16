import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'string_generator_controller.dart';

class StringGeneratorPage extends GetView<StringGeneratorController> {
  const StringGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return ToolPageWrapper(
      title: '多种字符串生成器',
      titleEn: 'String Generator',
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(
                context,
              ).textTheme.bodyLarge?.color,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.credit_card), text: '银行卡号'),
                Tab(icon: Icon(Icons.fingerprint), text: 'UDID'),
                Tab(icon: Icon(Icons.apps), text: '包名'),
                Tab(icon: Icon(Icons.category), text: '其他'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: _CardGenerator(
                      controller: controller,
                      isTablet: isTablet,
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: _UDIDGenerator(
                      controller: controller,
                      isTablet: isTablet,
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: _PackageGenerator(
                      controller: controller,
                      isTablet: isTablet,
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: _OtherGenerator(
                      controller: controller,
                      isTablet: isTablet,
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

class _CardGenerator extends StatelessWidget {
  final StringGeneratorController controller;
  final bool isTablet;

  const _CardGenerator({required this.controller, required this.isTablet});

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
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '标准银行卡卡号生成器',
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
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.cardBank.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '选择银行',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'random',
                          child: Text('随机银行', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: '6217',
                          child: Text(
                            '中国工商银行 (6217)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '6228',
                          child: Text(
                            '中国工商银行 (6228)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '6222',
                          child: Text(
                            '中国工商银行 (6222)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '6212',
                          child: Text(
                            '中国农业银行 (6212)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '6227',
                          child: Text(
                            '中国建设银行 (6227)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '6225',
                          child: Text(
                            '中国银行 (6225)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: '6221',
                          child: Text(
                            '交通银行 (6221)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.cardBank.value = value;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller: TextEditingController(
                        text: controller.cardCount.value.toString(),
                      ),
                      decoration: const InputDecoration(
                        labelText: '生成数量',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final intValue = int.tryParse(value);
                        if (intValue != null &&
                            intValue > 0 &&
                            intValue <= 100) {
                          controller.cardCount.value = intValue;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.cardPrefixController,
              decoration: const InputDecoration(
                labelText: '自定义前缀（可选，如：6217, 6228）',
                hintText: '留空则使用选择的银行',
                border: OutlineInputBorder(),
              ),
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: isTablet ? 12 : 8,
              runSpacing: isTablet ? 12 : 8,
              children: [
                GradientActionButton(
                  icon: Icons.credit_card,
                  label: '生成银行卡号',
                  onPressed: controller.generateCardNumbers,
                  color: Theme.of(context).primaryColor,
                  isTablet: isTablet,
                ),
                GradientActionButton(
                  icon: Icons.clear,
                  label: '清空',
                  onPressed: controller.clearCardResults,
                  color: AppTheme.getErrorColor(
                    AppTheme.getCurrentThemeType(context),
                  ),
                  isTablet: isTablet,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.cardResults.isEmpty) {
                return const SizedBox.shrink();
              }
              return _ResultList(
                results: controller.cardResults,
                formatCard: controller.formatCardNumber,
                onCopy: controller.copyToClipboard,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _UDIDGenerator extends StatelessWidget {
  final StringGeneratorController controller;
  final bool isTablet;

  const _UDIDGenerator({required this.controller, required this.isTablet});

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
                  child: const Icon(
                    Icons.fingerprint,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'UDID 生成器',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                controller: TextEditingController(
                  text: controller.udidCount.value.toString(),
                ),
                decoration: const InputDecoration(
                  labelText: '生成数量',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final intValue = int.tryParse(value);
                  if (intValue != null && intValue > 0 && intValue <= 100) {
                    controller.udidCount.value = intValue;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: isTablet ? 12 : 8,
              runSpacing: isTablet ? 12 : 8,
              children: [
                GradientActionButton(
                  icon: Icons.fingerprint,
                  label: '生成 UDID',
                  onPressed: controller.generateUDIDs,
                  color: Theme.of(context).primaryColor,
                  isTablet: isTablet,
                ),
                GradientActionButton(
                  icon: Icons.clear,
                  label: '清空',
                  onPressed: controller.clearUDIDResults,
                  color: AppTheme.getErrorColor(
                    AppTheme.getCurrentThemeType(context),
                  ),
                  isTablet: isTablet,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.udidResults.isEmpty) {
                return const SizedBox.shrink();
              }
              return _ResultList(
                results: controller.udidResults,
                onCopy: controller.copyToClipboard,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PackageGenerator extends StatelessWidget {
  final StringGeneratorController controller;
  final bool isTablet;

  const _PackageGenerator({required this.controller, required this.isTablet});

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
                  child: const Icon(Icons.apps, color: Colors.blue, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  '包名生成器',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                controller: TextEditingController(
                  text: controller.packageCount.value.toString(),
                ),
                decoration: const InputDecoration(
                  labelText: '生成数量',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final intValue = int.tryParse(value);
                  if (intValue != null && intValue > 0 && intValue <= 100) {
                    controller.packageCount.value = intValue;
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller: TextEditingController(
                        text: controller.packageLevel.value.toString(),
                      ),
                      decoration: const InputDecoration(
                        labelText: '包名层级（2-4）',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final intValue = int.tryParse(value);
                        if (intValue != null &&
                            intValue >= 2 &&
                            intValue <= 4) {
                          controller.packageLevel.value = intValue;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller: TextEditingController(
                        text: controller.packageLength.value.toString(),
                      ),
                      decoration: const InputDecoration(
                        labelText: '每段长度（3-10）',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final intValue = int.tryParse(value);
                        if (intValue != null &&
                            intValue >= 3 &&
                            intValue <= 10) {
                          controller.packageLength.value = intValue;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: isTablet ? 12 : 8,
              runSpacing: isTablet ? 12 : 8,
              children: [
                GradientActionButton(
                  icon: Icons.apps,
                  label: '生成包名',
                  onPressed: controller.generatePackages,
                  color: Theme.of(context).primaryColor,
                  isTablet: isTablet,
                ),
                GradientActionButton(
                  icon: Icons.clear,
                  label: '清空',
                  onPressed: controller.clearPackageResults,
                  color: AppTheme.getErrorColor(
                    AppTheme.getCurrentThemeType(context),
                  ),
                  isTablet: isTablet,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.packageResults.isEmpty) {
                return const SizedBox.shrink();
              }
              return _ResultList(
                results: controller.packageResults,
                onCopy: controller.copyToClipboard,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OtherGenerator extends StatelessWidget {
  final StringGeneratorController controller;
  final bool isTablet;

  const _OtherGenerator({required this.controller, required this.isTablet});

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
                  child: const Icon(
                    Icons.category,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '其他常用生成器',
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
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.otherType.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '生成器类型',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'uuid',
                          child: Text('UUID', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'randomString',
                          child: Text('随机字符串', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'randomNumber',
                          child: Text('随机数字', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'macAddress',
                          child: Text(
                            'MAC 地址',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'ipAddress',
                          child: Text('IP 地址', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'email',
                          child: Text('邮箱地址', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.otherType.value = value;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller: TextEditingController(
                        text: controller.otherCount.value.toString(),
                      ),
                      decoration: const InputDecoration(
                        labelText: '生成数量',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final intValue = int.tryParse(value);
                        if (intValue != null &&
                            intValue > 0 &&
                            intValue <= 100) {
                          controller.otherCount.value = intValue;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Obx(() {
              if (controller.otherType.value == 'randomString') {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Obx(
                    () => TextField(
                      controller: TextEditingController(
                        text: controller.randomStringLength.value.toString(),
                      ),
                      decoration: const InputDecoration(
                        labelText: '字符串长度',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final intValue = int.tryParse(value);
                        if (intValue != null &&
                            intValue > 0 &&
                            intValue <= 100) {
                          controller.randomStringLength.value = intValue;
                        }
                      },
                    ),
                  ),
                );
              } else if (controller.otherType.value == 'randomNumber') {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: TextEditingController(
                      text: controller.randomNumberRange.value,
                    ),
                    decoration: const InputDecoration(
                      labelText: '数字范围（格式：最小值-最大值，如：1000-9999）',
                      hintText: '1000-9999',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        controller.randomNumberRange.value = value,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 16),
            Wrap(
              spacing: isTablet ? 12 : 8,
              runSpacing: isTablet ? 12 : 8,
              children: [
                GradientActionButton(
                  icon: Icons.auto_awesome,
                  label: '生成',
                  onPressed: controller.generateOther,
                  color: Theme.of(context).primaryColor,
                  isTablet: isTablet,
                ),
                GradientActionButton(
                  icon: Icons.clear,
                  label: '清空',
                  onPressed: controller.clearOtherResults,
                  color: AppTheme.getErrorColor(
                    AppTheme.getCurrentThemeType(context),
                  ),
                  isTablet: isTablet,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.otherResults.isEmpty) {
                return const SizedBox.shrink();
              }
              return _ResultList(
                results: controller.otherResults,
                onCopy: controller.copyToClipboard,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  final List<String> results;
  final String Function(String)? formatCard;
  final Future<void> Function(String) onCopy;

  const _ResultList({
    required this.results,
    this.formatCard,
    required this.onCopy,
  });

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
          Text(
            '生成结果',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            final displayText = formatCard != null
                ? formatCard!(result)
                : result;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${index + 1}. $displayText',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => onCopy(result),
                    tooltip: '复制',
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
