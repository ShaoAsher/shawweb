import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../utils/toast_utils.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'device_preview_controller.dart';

/// 设备预览页面
class DevicePreviewPage extends StatefulWidget {
  const DevicePreviewPage({super.key});

  @override
  State<DevicePreviewPage> createState() => _DevicePreviewPageState();
}

class _DevicePreviewPageState extends State<DevicePreviewPage> {
  final controller = Get.find<DevicePreviewController>();
  final Map<String, bool> _expandedBrands = {};

  @override
  Widget build(BuildContext context) {
    return ToolPageWrapper(
      title: '设备预览工具',
      titleEn: 'Device Preview',
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildDeviceList()),
        ],
      ),
    );
  }

  /// 头部搜索和统计
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索框
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              labelText: '搜索设备',
              hintText: '输入品牌、型号或机型',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() {
                if (controller.searchText.value.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.searchController.clear();
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          // 统计信息
          Obx(() {
            return Wrap(
              spacing: 16,
              children: [
                _buildStatChip(
                  icon: Icons.devices,
                  label: '总设备数',
                  value: controller.totalCount.toString(),
                  color: Get.theme.primaryColor,
                ),
                if (controller.searchText.value.isNotEmpty)
                  _buildStatChip(
                    icon: Icons.filter_list,
                    label: '筛选结果',
                    value: controller.displayCount.toString(),
                    color: Get.theme.colorScheme.secondary,
                  ),
                _buildStatChip(
                  icon: Icons.category,
                  label: '品牌数',
                  value: controller.groupedDevices.length.toString(),
                  color: Get.theme.colorScheme.tertiary,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 统计芯片
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Get.theme.textTheme.bodySmall?.copyWith(color: color),
          ),
          Text(
            value,
            style: Get.theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 设备列表
  Widget _buildDeviceList() {
    return Obx(() {
      final groupedDevices = controller.groupedDevices;

      if (groupedDevices.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Get.theme.disabledColor),
              const SizedBox(height: 16),
              Text(
                '未找到匹配的设备',
                style: Get.theme.textTheme.titleMedium?.copyWith(
                  color: Get.theme.disabledColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedDevices.length,
        itemBuilder: (context, index) {
          final brand = groupedDevices.keys.elementAt(index);
          final devices = groupedDevices[brand]!;
          return _buildBrandSection(brand, devices);
        },
      );
    });
  }

  /// 品牌分组（带折叠功能）
  Widget _buildBrandSection(String brand, List<DeviceInfo> devices) {
    final brandInfo = _getBrandInfo(brand);
    final isExpanded = _expandedBrands[brand] ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedBrands[brand] = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [brandInfo.color, brandInfo.color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(brandInfo.icon, size: 24, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    brand,
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${devices.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildDeviceStaggeredGrid(devices, brandInfo),
                    const SizedBox(height: 16),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// 瀑布流设备网格
  Widget _buildDeviceStaggeredGrid(
    List<DeviceInfo> devices,
    _BrandInfo brandInfo,
  ) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isTablet ? 3 : 2;

    return MasonryGridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return _buildDeviceCard(devices[index], brandInfo);
      },
    );
  }

  /// 设备卡片（瀑布流样式）
  Widget _buildDeviceCard(DeviceInfo device, _BrandInfo brandInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandInfo.color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: brandInfo.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDeviceDetail(device),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          brandInfo.color.withOpacity(0.2),
                          brandInfo.color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.phone_android,
                      size: 28,
                      color: brandInfo.color,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // 设备名称
                Text(
                  device.name,
                  style: Get.theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  device.model,
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.textTheme.bodySmall?.color?.withOpacity(
                      0.6,
                    ),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // 设备信息标签
                _buildInfoChip(
                  icon: Icons.straighten,
                  label: device.size,
                  color: brandInfo.color,
                ),
                const SizedBox(height: 6),
                _buildInfoChip(
                  icon: Icons.crop,
                  label: device.resolution,
                  color: brandInfo.color.withOpacity(0.8),
                ),
                const SizedBox(height: 6),
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: device.releaseDate,
                  color: brandInfo.color.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 信息芯片（全宽样式）
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Get.theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示设备详情
  void _showDeviceDetail(DeviceInfo device) {
    final brandInfo = _getBrandInfo(device.brand);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [brandInfo.color, brandInfo.color.withOpacity(0.8)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.phone_android,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: Get.theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            device.brand,
                            style: Get.theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: '关闭',
                    ),
                  ],
                ),
              ),
              // 内容区域
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('设备型号', device.model, Icons.tag),
                    if (device.internalModel != null)
                      _buildDetailRow(
                        '内部型号',
                        device.internalModel!,
                        Icons.info_outline,
                      ),
                    _buildDetailRow('屏幕尺寸', device.size, Icons.straighten),
                    _buildDetailRow('分辨率', device.resolution, Icons.crop),
                    _buildDetailRow(
                      '发布日期',
                      device.releaseDate,
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 20),
                    // 复制按钮
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyDeviceInfo(device),
                            icon: const Icon(Icons.copy),
                            label: const Text('复制设备信息'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 详情行
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Get.theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.textTheme.bodySmall?.color?.withOpacity(
                      0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Get.theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 复制设备信息
  void _copyDeviceInfo(DeviceInfo device) {
    final info = StringBuffer();
    info.writeln('品牌: ${device.brand}');
    info.writeln('设备名称: ${device.name}');
    info.writeln('设备型号: ${device.model}');
    if (device.internalModel != null) {
      info.writeln('内部型号: ${device.internalModel}');
    }
    info.writeln('屏幕尺寸: ${device.size}');
    info.writeln('分辨率: ${device.resolution}');
    info.writeln('发布日期: ${device.releaseDate}');

    Clipboard.setData(ClipboardData(text: info.toString()));
    ToastUtils.showSuccess('设备信息已复制');
  }

  /// 获取品牌信息
  _BrandInfo _getBrandInfo(String brand) {
    switch (brand) {
      case 'Apple':
        return _BrandInfo(
          icon: Icons.phone_iphone,
          color: const Color(0xFF007AFF),
        );
      case 'Huawei':
        return _BrandInfo(
          icon: Icons.phone_android,
          color: const Color(0xFFE60012),
        );
      case 'Xiaomi':
        return _BrandInfo(
          icon: Icons.phone_android,
          color: const Color(0xFFFF6900),
        );
      case 'OPPO':
        return _BrandInfo(
          icon: Icons.phone_android,
          color: const Color(0xFF00A862),
        );
      case 'vivo':
        return _BrandInfo(
          icon: Icons.phone_android,
          color: const Color(0xFF0060BF),
        );
      case 'Samsung':
        return _BrandInfo(
          icon: Icons.phone_android,
          color: const Color(0xFF1428A0),
        );
      default:
        return _BrandInfo(
          icon: Icons.phone_android,
          color: Get.theme.primaryColor,
        );
    }
  }
}

/// 品牌信息
class _BrandInfo {
  final IconData icon;
  final Color color;

  _BrandInfo({required this.icon, required this.color});
}
