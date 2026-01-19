import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 设备信息模型
class DeviceInfo {
  final String brand;
  final String name;
  final String model;
  final String? internalModel;
  final String size;
  final String resolution;
  final String releaseDate;

  const DeviceInfo({
    required this.brand,
    required this.name,
    required this.model,
    this.internalModel,
    required this.size,
    required this.resolution,
    required this.releaseDate,
  });
}

/// 设备预览控制器
class DevicePreviewController extends GetxController {
  final searchController = TextEditingController();
  RxString searchText = ''.obs;
  RxList<DeviceInfo> filteredDevices = <DeviceInfo>[].obs;

  // 设备数据（主流设备）
  final devices = <DeviceInfo>[
    // Apple - iPhone 17系列（2025年9月发布）
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 17 Pro Max',
      model: 'A3526',
      internalModel: 'iPhone18,2',
      size: '6.9英寸',
      resolution: '3200×1440',
      releaseDate: '2025-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 17 Pro',
      model: 'A3521',
      internalModel: 'iPhone18,1',
      size: '6.3英寸',
      resolution: '2800×1260',
      releaseDate: '2025-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 17',
      model: 'A3520',
      internalModel: 'iPhone18,3',
      size: '6.1英寸',
      resolution: '2556×1179',
      releaseDate: '2025-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 17 Plus',
      model: 'A3522',
      internalModel: 'iPhone17,4',
      size: '6.7英寸',
      resolution: '2796×1290',
      releaseDate: '2025-09',
    ),

    // Apple - iPhone 16系列
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 16 Pro Max',
      model: 'A2901',
      internalModel: 'iPhone17,2',
      size: '6.9英寸',
      resolution: '3200×1440',
      releaseDate: '2024-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 16 Pro',
      model: 'A2895',
      internalModel: 'iPhone17,1',
      size: '6.3英寸',
      resolution: '2800×1260',
      releaseDate: '2024-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 16',
      model: 'A2893',
      internalModel: 'iPhone17,3',
      size: '6.1英寸',
      resolution: '2556×1179',
      releaseDate: '2024-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 16 Plus',
      model: 'A2894',
      internalModel: 'iPhone17,4',
      size: '6.7英寸',
      resolution: '2796×1290',
      releaseDate: '2024-09',
    ),

    // Apple - iPhone 15系列
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 15 Pro Max',
      model: 'A3101',
      internalModel: 'iPhone16,2',
      size: '6.7英寸',
      resolution: '2796×1290',
      releaseDate: '2023-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 15 Pro',
      model: 'A3102',
      internalModel: 'iPhone16,1',
      size: '6.1英寸',
      resolution: '2556×1179',
      releaseDate: '2023-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 15 Plus',
      model: 'A3104',
      internalModel: 'iPhone15,5',
      size: '6.7英寸',
      resolution: '2796×1290',
      releaseDate: '2023-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 15',
      model: 'A3103',
      internalModel: 'iPhone15,4',
      size: '6.1英寸',
      resolution: '2556×1179',
      releaseDate: '2023-09',
    ),

    // Apple - iPhone 14系列
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 14 Pro Max',
      model: 'A2896',
      internalModel: 'iPhone15,3',
      size: '6.7英寸',
      resolution: '2796×1290',
      releaseDate: '2022-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 14 Pro',
      model: 'A2892',
      internalModel: 'iPhone15,2',
      size: '6.1英寸',
      resolution: '2556×1179',
      releaseDate: '2022-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 14 Plus',
      model: 'A2888',
      internalModel: 'iPhone14,8',
      size: '6.7英寸',
      resolution: '2778×1284',
      releaseDate: '2022-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 14',
      model: 'A2882',
      internalModel: 'iPhone14,7',
      size: '6.1英寸',
      resolution: '2532×1170',
      releaseDate: '2022-09',
    ),

    // Apple - iPhone 13系列
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 13 Pro Max',
      model: 'A2643',
      internalModel: 'iPhone14,3',
      size: '6.7英寸',
      resolution: '2778×1284',
      releaseDate: '2021-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 13 Pro',
      model: 'A2639',
      internalModel: 'iPhone14,2',
      size: '6.1英寸',
      resolution: '2532×1170',
      releaseDate: '2021-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 13',
      model: 'A2634',
      internalModel: 'iPhone14,5',
      size: '6.1英寸',
      resolution: '2532×1170',
      releaseDate: '2021-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 13 mini',
      model: 'A2629',
      internalModel: 'iPhone14,4',
      size: '5.4英寸',
      resolution: '2340×1080',
      releaseDate: '2021-09',
    ),

    // Apple - iPhone 12系列
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 12 Pro Max',
      model: 'A2412',
      internalModel: 'iPhone13,4',
      size: '6.7英寸',
      resolution: '2778×1284',
      releaseDate: '2020-10',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 12 Pro',
      model: 'A2408',
      internalModel: 'iPhone13,3',
      size: '6.1英寸',
      resolution: '2532×1170',
      releaseDate: '2020-10',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 12',
      model: 'A2404',
      internalModel: 'iPhone13,2',
      size: '6.1英寸',
      resolution: '2532×1170',
      releaseDate: '2020-10',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 12 mini',
      model: 'A2399',
      internalModel: 'iPhone13,1',
      size: '5.4英寸',
      resolution: '2340×1080',
      releaseDate: '2020-10',
    ),

    // Apple - iPhone SE系列
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone SE (第三代)',
      model: 'A2785',
      internalModel: 'iPhone14,6',
      size: '4.7英寸',
      resolution: '1334×750',
      releaseDate: '2022-03',
    ),

    // Apple - iPhone 11系列
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 11 Pro Max',
      model: 'A2161',
      internalModel: 'iPhone12,5',
      size: '6.5英寸',
      resolution: '2688×1242',
      releaseDate: '2019-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 11 Pro',
      model: 'A2160',
      internalModel: 'iPhone12,3',
      size: '5.8英寸',
      resolution: '2436×1125',
      releaseDate: '2019-09',
    ),
    const DeviceInfo(
      brand: 'Apple',
      name: 'iPhone 11',
      model: 'A2221',
      internalModel: 'iPhone12,1',
      size: '6.1英寸',
      resolution: '1792×828',
      releaseDate: '2019-09',
    ),

    // Huawei - Mate系列
    const DeviceInfo(
      brand: 'Huawei',
      name: 'Mate 60 Pro+',
      model: 'ALN-AL00',
      size: '6.82英寸',
      resolution: '2720×1260',
      releaseDate: '2023-09',
    ),
    const DeviceInfo(
      brand: 'Huawei',
      name: 'Mate 60 Pro',
      model: 'ALT-AL00',
      size: '6.82英寸',
      resolution: '2720×1260',
      releaseDate: '2023-08',
    ),
    const DeviceInfo(
      brand: 'Huawei',
      name: 'Mate 50 Pro',
      model: 'BNE-AL00',
      size: '6.74英寸',
      resolution: '2616×1212',
      releaseDate: '2022-09',
    ),

    // Xiaomi - 小米系列
    const DeviceInfo(
      brand: 'Xiaomi',
      name: '小米 14 Ultra',
      model: '24031PN0DC',
      size: '6.73英寸',
      resolution: '3200×1440',
      releaseDate: '2024-02',
    ),
    const DeviceInfo(
      brand: 'Xiaomi',
      name: '小米 14 Pro',
      model: '23116PN5BC',
      size: '6.73英寸',
      resolution: '3200×1440',
      releaseDate: '2023-10',
    ),
    const DeviceInfo(
      brand: 'Xiaomi',
      name: '小米 14',
      model: '23127PN0CC',
      size: '6.36英寸',
      resolution: '2670×1200',
      releaseDate: '2023-10',
    ),

    // OPPO - Find系列
    const DeviceInfo(
      brand: 'OPPO',
      name: 'Find X7 Ultra',
      model: 'PHZ110',
      size: '6.82英寸',
      resolution: '3168×1440',
      releaseDate: '2024-01',
    ),
    const DeviceInfo(
      brand: 'OPPO',
      name: 'Find X6 Pro',
      model: 'PHK110',
      size: '6.82英寸',
      resolution: '3168×1440',
      releaseDate: '2023-03',
    ),

    // vivo - X系列
    const DeviceInfo(
      brand: 'vivo',
      name: 'X100 Pro',
      model: 'V2309A',
      size: '6.78英寸',
      resolution: '2800×1260',
      releaseDate: '2023-11',
    ),
    const DeviceInfo(
      brand: 'vivo',
      name: 'X90 Pro+',
      model: 'V2227A',
      size: '6.78英寸',
      resolution: '3200×1440',
      releaseDate: '2022-11',
    ),

    // Samsung - Galaxy S系列
    const DeviceInfo(
      brand: 'Samsung',
      name: 'Galaxy S24 Ultra',
      model: 'SM-S928',
      size: '6.8英寸',
      resolution: '3120×1440',
      releaseDate: '2024-01',
    ),
    const DeviceInfo(
      brand: 'Samsung',
      name: 'Galaxy S24+',
      model: 'SM-S926',
      size: '6.7英寸',
      resolution: '3120×1440',
      releaseDate: '2024-01',
    ),
    const DeviceInfo(
      brand: 'Samsung',
      name: 'Galaxy S24',
      model: 'SM-S921',
      size: '6.2英寸',
      resolution: '2340×1080',
      releaseDate: '2024-01',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    filteredDevices.value = devices;
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchText.value = searchController.text;
    _filterDevices();
  }

  void _filterDevices() {
    final query = searchText.value.toLowerCase().trim();
    if (query.isEmpty) {
      filteredDevices.value = devices;
    } else {
      filteredDevices.value = devices.where((device) {
        return device.name.toLowerCase().contains(query) ||
            device.brand.toLowerCase().contains(query) ||
            device.model.toLowerCase().contains(query) ||
            (device.internalModel?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  /// 获取按品牌分组的设备
  Map<String, List<DeviceInfo>> get groupedDevices {
    final map = <String, List<DeviceInfo>>{};
    for (final device in filteredDevices) {
      map.putIfAbsent(device.brand, () => []).add(device);
    }
    return map;
  }

  /// 获取统计信息
  int get totalCount => devices.length;
  int get displayCount => filteredDevices.length;
}
