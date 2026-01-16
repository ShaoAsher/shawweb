import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/getx_dialog_utils.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'qrcode_generator_controller.dart';

class QrcodeGeneratorPage extends GetView<QrcodeGeneratorController> {
  const QrcodeGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return ToolPageWrapper(
      title: '二维码/条形码生成工具',
      titleEn: 'QR Code / Barcode Generator',
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.qr_code), text: '二维码'),
                Tab(icon: Icon(Icons.view_agenda), text: '条形码'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _QRCodeTab(controller: controller, isTablet: isTablet),
                  _BarcodeTab(controller: controller, isTablet: isTablet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QRCodeTab extends StatelessWidget {
  final QrcodeGeneratorController controller;
  final bool isTablet;

  const _QRCodeTab({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.cardColor,
                    theme.cardColor.withValues(alpha: 0.92),
                  ],
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
                          Icons.edit,
                          color: Colors.blue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '内容输入',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.qrcodeTextController,
                    decoration: const InputDecoration(
                      labelText: '输入文本或链接',
                      hintText: '请输入要生成二维码的内容',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.cardColor,
                    theme.cardColor.withValues(alpha: 0.92),
                  ],
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
                          Icons.palette,
                          color: Colors.blue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '样式设置',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownButtonFormField<int>(
                      initialValue: controller.qrcodeSize.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '尺寸',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 200,
                          child: Text(
                            '200x200',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 300,
                          child: Text(
                            '300x300',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 400,
                          child: Text(
                            '400x400',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 500,
                          child: Text(
                            '500x500',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.qrcodeSize.value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.qrcodeErrorLevel.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '容错级别',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'L',
                          child: Text(
                            'L - 低 (约7%)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'M',
                          child: Text(
                            'M - 中 (约15%)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Q',
                          child: Text(
                            'Q - 较高 (约25%)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'H',
                          child: Text(
                            'H - 高 (约30%)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.qrcodeErrorLevel.value = value;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => ListTile(
                            title: const Text('前景色'),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: controller.qrcodeColor.value,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            onTap: () async {
                              final color =
                                  await GetXDialogUtils.showColorPicker(
                                    initialColor: controller.qrcodeColor.value,
                                    title: '选择二维码颜色',
                                  );
                              if (color != null) {
                                controller.qrcodeColor.value = color;
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Obx(
                          () => ListTile(
                            title: const Text('背景色'),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: controller.qrcodeBgColor.value,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            onTap: () async {
                              final color =
                                  await GetXDialogUtils.showColorPicker(
                                    initialColor:
                                        controller.qrcodeBgColor.value,
                                    title: '选择背景色',
                                  );
                              if (color != null) {
                                controller.qrcodeBgColor.value = color;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('预设样式'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StylePreset(
                        label: '默认',
                        color: const Color(0xFF000000),
                        bgColor: const Color(0xFFFFFFFF),
                        onTap: () => controller.setQRCodeStyle('default'),
                      ),
                      _StylePreset(
                        label: '蓝色',
                        color: const Color(0xFF1677FF),
                        bgColor: const Color(0xFFFFFFFF),
                        onTap: () => controller.setQRCodeStyle('blue'),
                      ),
                      _StylePreset(
                        label: '绿色',
                        color: const Color(0xFF07C160),
                        bgColor: const Color(0xFFFFFFFF),
                        onTap: () => controller.setQRCodeStyle('green'),
                      ),
                      _StylePreset(
                        label: '红色',
                        color: const Color(0xFFFF0050),
                        bgColor: const Color(0xFFFFFFFF),
                        onTap: () => controller.setQRCodeStyle('red'),
                      ),
                      _StylePreset(
                        label: '紫色',
                        color: const Color(0xFF764ba2),
                        bgColor: const Color(0xFFFFFFFF),
                        onTap: () => controller.setQRCodeStyle('purple'),
                      ),
                      _StylePreset(
                        label: '渐变',
                        color: const Color(0xFF667eea),
                        bgColor: const Color(0xFFf8f9fa),
                        onTap: () => controller.setQRCodeStyle('gradient'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Wrap(
            spacing: isTablet ? 12 : 8,
            runSpacing: isTablet ? 12 : 8,
            children: [
              GradientActionButton(
                icon: Icons.qr_code,
                label: '生成二维码',
                onPressed: controller.generateQRCode,
                color: Theme.of(context).primaryColor,
                isTablet: isTablet,
              ),
              GradientActionButton(
                icon: Icons.clear,
                label: '清空',
                onPressed: controller.clearQRCode,
                color: AppTheme.getErrorColor(
                  AppTheme.getCurrentThemeType(context),
                ),
                isTablet: isTablet,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Obx(() {
            if (!controller.showQrcode.value ||
                controller.qrcodeTextController.text.trim().isEmpty) {
              return const SizedBox.shrink();
            }
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.cardColor,
                      theme.cardColor.withValues(alpha: 0.92),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  children: [
                    Text(
                      '二维码预览',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: controller.qrcodeBgColor.value,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: controller.qrcodeTextController.text,
                        size: controller.qrcodeSize.value.toDouble(),
                        backgroundColor: controller.qrcodeBgColor.value,
                        foregroundColor: controller.qrcodeColor.value,
                        errorCorrectionLevel: controller.errorLevelInt,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BarcodeTab extends StatelessWidget {
  final QrcodeGeneratorController controller;
  final bool isTablet;

  const _BarcodeTab({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.cardColor,
                    theme.cardColor.withValues(alpha: 0.92),
                  ],
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
                          Icons.edit,
                          color: Colors.blue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '内容输入',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.barcodeTextController,
                    decoration: const InputDecoration(
                      labelText: '输入数字或文本',
                      hintText: '请输入要生成条形码的内容',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.cardColor,
                    theme.cardColor.withValues(alpha: 0.92),
                  ],
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
                          Icons.settings,
                          color: Colors.blue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '条形码设置',
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
                            initialValue: _getBarcodeFormatName(
                              controller.barcodeFormat.value,
                            ),
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: '格式类型',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'CODE128',
                                child: Text(
                                  'CODE128',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'CODE39',
                                child: Text(
                                  'CODE39',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'EAN13',
                                child: Text(
                                  'EAN13',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'EAN8',
                                child: Text(
                                  'EAN8',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'UPC',
                                child: Text(
                                  'UPC',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'ITF14',
                                child: Text(
                                  'ITF14',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'MSI',
                                child: Text(
                                  'MSI',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'pharmacode',
                                child: Text(
                                  'Pharmacode',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'codabar',
                                child: Text(
                                  'Codabar',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null)
                                controller.setBarcodeFormat(value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => TextField(
                            controller: TextEditingController(
                              text: controller.barcodeWidth.value.toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: '宽度',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final doubleValue = double.tryParse(value);
                              if (doubleValue != null && doubleValue > 0) {
                                controller.barcodeWidth.value = doubleValue;
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
                              text: controller.barcodeHeight.value.toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: '高度',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final intValue = int.tryParse(value);
                              if (intValue != null && intValue > 0) {
                                controller.barcodeHeight.value = intValue;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => SwitchListTile(
                      title: const Text('显示文本'),
                      value: controller.barcodeDisplayValue.value,
                      onChanged: (value) {
                        controller.barcodeDisplayValue.value = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => ListTile(
                            title: const Text('线条颜色'),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: controller.barcodeColor.value,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            onTap: () async {
                              final color =
                                  await GetXDialogUtils.showColorPicker(
                                    initialColor: controller.barcodeColor.value,
                                    title: '选择条形码颜色',
                                  );
                              if (color != null) {
                                controller.barcodeColor.value = color;
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Obx(
                          () => ListTile(
                            title: const Text('背景色'),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: controller.barcodeBgColor.value,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            onTap: () async {
                              final color =
                                  await GetXDialogUtils.showColorPicker(
                                    initialColor:
                                        controller.barcodeBgColor.value,
                                    title: '选择条形码背景色',
                                  );
                              if (color != null) {
                                controller.barcodeBgColor.value = color;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Wrap(
            spacing: isTablet ? 12 : 8,
            runSpacing: isTablet ? 12 : 8,
            children: [
              GradientActionButton(
                icon: Icons.view_agenda,
                label: '生成条形码',
                onPressed: controller.generateBarcode,
                color: Theme.of(context).primaryColor,
                isTablet: isTablet,
              ),
              GradientActionButton(
                icon: Icons.clear,
                label: '清空',
                onPressed: controller.clearBarcode,
                color: AppTheme.getErrorColor(
                  AppTheme.getCurrentThemeType(context),
                ),
                isTablet: isTablet,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Obx(() {
            if (!controller.showBarcode.value ||
                controller.barcodeTextController.text.trim().isEmpty) {
              return const SizedBox.shrink();
            }
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.cardColor,
                      theme.cardColor.withValues(alpha: 0.92),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  children: [
                    Text(
                      '条形码预览',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: controller.barcodeBgColor.value,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: BarcodeWidget(
                        barcode: controller.barcodeFormat.value,
                        data: controller.barcodeTextController.text,
                        width: controller.barcodeWidth.value,
                        height: controller.barcodeHeight.value.toDouble(),
                        color: controller.barcodeColor.value,
                        backgroundColor: controller.barcodeBgColor.value,
                        drawText: controller.barcodeDisplayValue.value,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getBarcodeFormatName(Barcode barcode) {
    if (barcode == Barcode.code128()) return 'CODE128';
    if (barcode == Barcode.code39()) return 'CODE39';
    if (barcode == Barcode.ean13()) return 'EAN13';
    if (barcode == Barcode.ean8()) return 'EAN8';
    if (barcode == Barcode.upcA()) return 'UPC';
    if (barcode == Barcode.itf14()) return 'ITF14';
    // MSI and pharmacode not available in barcode_widget, using code128 as fallback
    // if (barcode == Barcode.msi()) return 'MSI';
    // if (barcode == Barcode.pharmacode()) return 'pharmacode';
    if (barcode == Barcode.codabar()) return 'codabar';
    return 'CODE128';
  }
}

class _StylePreset extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _StylePreset({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
