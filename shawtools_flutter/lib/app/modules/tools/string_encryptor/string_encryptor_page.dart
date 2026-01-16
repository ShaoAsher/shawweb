import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../widgets/tool_page_wrapper.dart';
import 'string_encryptor_controller.dart';

class StringEncryptorPage extends GetView<StringEncryptorController> {
  const StringEncryptorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return ToolPageWrapper(
      title: '字符串加解密工具',
      titleEn: 'String Encryptor / Decryptor',
      child: Column(
        children: [
          _AlgorithmButtonSelector(controller: controller, isTablet: isTablet),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AlgorithmControls(controller: controller, isTablet: isTablet)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 50.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 16),
                  _InputOutputSection(
                        controller: controller,
                        isTablet: isTablet,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlgorithmButtonSelector extends StatelessWidget {
  final StringEncryptorController controller;
  final bool isTablet;

  const _AlgorithmButtonSelector({
    required this.controller,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 12,
            vertical: 8,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: controller.algorithms.map((algo) {
                  final isSelected =
                      controller.currentAlgorithm.value == algo.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => controller.selectAlgorithm(algo.key),
                      child:
                          AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOutCubic,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.primaryColor
                                        : theme.primaryColor.withValues(
                                            alpha: 0.5,
                                          ),
                                    width: isSelected ? 0 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: theme.primaryColor
                                                .withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  algo.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : theme.primaryColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              )
                              .animate(target: isSelected ? 1 : 0)
                              .scale(
                                begin: const Offset(1.0, 1.0),
                                end: const Offset(1.08, 1.08),
                                duration: 250.ms,
                                curve: Curves.easeOutBack,
                              ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
  }
}

class _AlgorithmControls extends StatelessWidget {
  final StringEncryptorController controller;
  final bool isTablet;

  const _AlgorithmControls({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final algo = controller.selectedAlgorithm;
      if (algo == null) return const SizedBox.shrink();

      // 检查是否有加密参数需要显示
      final hasParams = algo.needsKey || algo.key == 'aes';
      if (!hasParams) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (algo.needsKey) ...[
              TextField(
                controller: controller.keyController,
                decoration: InputDecoration(
                  labelText: algo.key == 'caesar' ? '偏移量（如：3）' : '密钥',
                  hintText: algo.key == 'caesar' ? '请输入偏移量' : '请输入密钥',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
            ],
            if (algo.key == 'aes') ...[
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: controller.aesMode.value,
                        decoration: InputDecoration(
                          labelText: 'AES 模式',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        items: const [
                          DropdownMenuItem(value: 'GCM', child: Text('GCM')),
                          DropdownMenuItem(value: 'CBC', child: Text('CBC')),
                          DropdownMenuItem(value: 'CTR', child: Text('CTR')),
                          DropdownMenuItem(value: 'CFB', child: Text('CFB')),
                          DropdownMenuItem(value: 'OFB', child: Text('OFB')),
                        ],
                        onChanged: (value) {
                          if (value != null) controller.aesMode.value = value;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => DropdownButtonFormField<int>(
                        initialValue: controller.aesKeyLength.value,
                        decoration: InputDecoration(
                          labelText: '密钥长度',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        items: const [
                          DropdownMenuItem(value: 128, child: Text('128 位')),
                          DropdownMenuItem(value: 192, child: Text('192 位')),
                          DropdownMenuItem(value: 256, child: Text('256 位')),
                        ],
                        onChanged: (value) {
                          if (value != null)
                            controller.aesKeyLength.value = value;
                        },
                      ),
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
                        initialValue: controller.aesHashAlgo.value,
                        decoration: InputDecoration(
                          labelText: '哈希算法',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        items: const [
                          DropdownMenuItem(
                            value: 'SHA-256',
                            child: Text('SHA-256'),
                          ),
                          DropdownMenuItem(
                            value: 'SHA-384',
                            child: Text('SHA-384'),
                          ),
                          DropdownMenuItem(
                            value: 'SHA-512',
                            child: Text('SHA-512'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null)
                            controller.aesHashAlgo.value = value;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => TextField(
                        key: ValueKey(controller.aesIterations.value),
                        controller: TextEditingController(
                          text: controller.aesIterations.value.toString(),
                        ),
                        decoration: InputDecoration(
                          labelText: '迭代次数',
                          hintText: '100000',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        onChanged: (value) {
                          final intValue = int.tryParse(value);
                          if (intValue != null && intValue > 0) {
                            controller.aesIterations.value = intValue;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.saltController,
                decoration: InputDecoration(
                  labelText: 'Salt (盐值)',
                  hintText: '留空自动生成',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.science,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: controller.generateSalt,
                    tooltip: '生成随机盐值',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.ivController,
                decoration: InputDecoration(
                  labelText: 'IV (初始化向量)',
                  hintText: '留空自动生成',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.shuffle,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: controller.generateIV,
                    tooltip: '生成随机 IV',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _InputOutputSection extends StatelessWidget {
  final StringEncryptorController controller;
  final bool isTablet;

  const _InputOutputSection({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: isTablet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _InputBox(controller: controller)),
                const SizedBox(width: 20),
                Expanded(child: _OutputBox(controller: controller)),
              ],
            )
          : Column(
              children: [
                _InputBox(controller: controller),
                const SizedBox(height: 20),
                _OutputBox(controller: controller),
              ],
            ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final StringEncryptorController controller;
  const _InputBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller.inputController,
          decoration: InputDecoration(
            labelText: '输入文本',
            hintText: '请输入要加密/解密的内容...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            prefixIcon: Icon(
              Icons.edit_note,
              size: 22,
              color: theme.primaryColor,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          style: TextStyle(fontSize: 15, color: Colors.black87),
          maxLines: 10,
          minLines: 8,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.error.withValues(alpha: 0.9),
                      theme.colorScheme.error.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: controller.clearInput,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    '清空',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    minimumSize: const Size(0, 48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                return Container(
                  decoration: BoxDecoration(
                    gradient: controller.isLoading.value
                        ? null
                        : LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: controller.isLoading.value
                        ? null
                        : [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.encrypt,
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.lock, size: 18),
                    label: const Text(
                      '加密',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isLoading.value
                          ? theme.primaryColor
                          : Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      minimumSize: const Size(0, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                return Container(
                  decoration: BoxDecoration(
                    gradient: controller.isLoading.value
                        ? null
                        : LinearGradient(
                            colors: [
                              theme.primaryColor.withValues(alpha: 0.95),
                              theme.primaryColor.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: controller.isLoading.value
                        ? null
                        : [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.decrypt,
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.lock_open, size: 18),
                    label: const Text(
                      '解密',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isLoading.value
                          ? theme.primaryColor.withValues(alpha: 0.9)
                          : Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      minimumSize: const Size(0, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutputBox extends StatelessWidget {
  final StringEncryptorController controller;
  const _OutputBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller.outputController,
          decoration: InputDecoration(
            labelText: '输出结果',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            prefixIcon: Icon(
              Icons.description,
              size: 22,
              color: theme.primaryColor,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          style: TextStyle(fontSize: 15, color: Colors.black87),
          maxLines: 10,
          minLines: 8,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: controller.hasOutput.value
                    ? LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: controller.hasOutput.value
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton.icon(
                onPressed: controller.hasOutput.value
                    ? controller.copyOutput
                    : null,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text(
                  '复制结果',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.hasOutput.value
                      ? Colors.transparent
                      : theme.primaryColor.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 44),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
