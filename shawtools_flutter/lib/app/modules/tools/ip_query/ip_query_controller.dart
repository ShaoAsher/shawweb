import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/http_service.dart';
import '../../../utils/toast_utils.dart';

class IpInfo {
  final String ip;
  final String country;
  final String countryCode;
  final String region;
  final String city;
  final String zip;
  final double lat;
  final double lon;
  final String timezone;
  final String isp;
  final String org;
  final String asn;

  IpInfo({
    required this.ip,
    required this.country,
    required this.countryCode,
    required this.region,
    required this.city,
    required this.zip,
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.isp,
    required this.org,
    required this.asn,
  });

  factory IpInfo.fromIpinfo(Map<String, dynamic> data, [String? inputIp]) {
    double lat = 0, lon = 0;
    if (data['loc'] != null) {
      final loc = data['loc'].toString().split(',');
      if (loc.length == 2) {
        lat = double.tryParse(loc[0]) ?? 0;
        lon = double.tryParse(loc[1]) ?? 0;
      }
    }

    String asn = '未知';
    if (data['org'] != null) {
      final orgStr = data['org'].toString();
      final asMatch = RegExp(r'AS\d+').firstMatch(orgStr);
      if (asMatch != null) {
        asn = asMatch.group(0) ?? '未知';
      }
    }

    return IpInfo(
      ip: data['ip']?.toString() ?? inputIp ?? '未知',
      country:
          data['country_name']?.toString() ??
          data['country']?.toString() ??
          '未知',
      countryCode: data['country']?.toString() ?? '',
      region: data['region']?.toString() ?? '未知',
      city: data['city']?.toString() ?? '未知',
      zip: data['postal']?.toString() ?? '未知',
      lat: lat,
      lon: lon,
      timezone: data['timezone']?.toString() ?? '未知',
      isp: data['org']?.toString().replaceAll(RegExp(r'AS\d+\s*'), '') ?? '未知',
      org: data['org']?.toString() ?? '未知',
      asn: asn,
    );
  }

  factory IpInfo.fromIpwhois(Map<String, dynamic> data, [String? inputIp]) {
    return IpInfo(
      ip: data['ip']?.toString() ?? inputIp ?? '未知',
      country: data['country']?.toString() ?? '未知',
      countryCode: data['country_code']?.toString() ?? '',
      region: data['region']?.toString() ?? '未知',
      city: data['city']?.toString() ?? '未知',
      zip: data['postal']?.toString() ?? '未知',
      lat: (data['latitude'] as num?)?.toDouble() ?? 0,
      lon: (data['longitude'] as num?)?.toDouble() ?? 0,
      timezone: data['timezone']?.toString() ?? '未知',
      isp: data['isp']?.toString() ?? '未知',
      org: data['org']?.toString() ?? '未知',
      asn: data['asn'] != null ? 'AS${data['asn']}' : '未知',
    );
  }
}

class IpQueryController extends GetxController {
  final ipInputController = TextEditingController();
  final queryIpInfo = Rx<IpInfo?>(null);
  final isLoadingCurrent = false.obs;
  final isLoadingQuery = false.obs;

  @override
  void onClose() {
    ipInputController.dispose();
    super.onClose();
  }

  /// 验证 IP 地址格式
  bool isValidIP(String ip) {
    final ipRegex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(ip);
  }

  /// 查询当前 IP 并设置到输入框
  Future<void> queryCurrentIpAndSet() async {
    isLoadingCurrent.value = true;
    try {
      await _queryIp('');
      if (queryIpInfo.value != null) {
        ipInputController.text = queryIpInfo.value!.ip;
        // 自动显示查询结果
      }
    } catch (e) {
      debugPrint('[IP Query] 查询当前IP失败: $e');
      ToastUtils.showNetworkError('查询当前IP失败，请稍后重试');
    } finally {
      isLoadingCurrent.value = false;
    }
  }

  /// 查询指定 IP
  Future<void> queryIp() async {
    final ip = ipInputController.text.trim();
    if (ip.isEmpty) {
      ToastUtils.showError('请输入IP地址');
      return;
    }
    if (!isValidIP(ip)) {
      ToastUtils.showError('IP地址格式不正确');
      return;
    }

    isLoadingQuery.value = true;
    queryIpInfo.value = null;
    try {
      await _queryIp(ip);
    } catch (e) {
      debugPrint('[IP Query] 查询IP失败: $e');
      ToastUtils.showNetworkError('查询IP失败，请稍后重试');
    } finally {
      isLoadingQuery.value = false;
    }
  }

  /// 执行 IP 查询（尝试多个 API）
  Future<void> _queryIp(String ip) async {
    final apis = [_queryWithIpinfo, _queryWithIpwhois];

    for (final api in apis) {
      try {
        debugPrint('[IP Query] 尝试查询 IP: $ip');
        final info = await api(ip);
        queryIpInfo.value = info;
        debugPrint('[IP Query] 查询成功: ${info.ip}');
        return;
      } on DioException catch (e) {
        debugPrint('[IP Query] API请求失败: ${e.message}');
        continue;
      } catch (e) {
        debugPrint('[IP Query] 查询异常: $e');
        continue;
      }
    }

    throw Exception('所有API查询均失败，请检查网络连接或稍后重试');
  }

  /// 使用 ipinfo.io 查询
  Future<IpInfo> _queryWithIpinfo(String ip) async {
    final url = ip.isEmpty
        ? 'https://ipinfo.io/json'
        : 'https://ipinfo.io/$ip/json';
    final data = await HttpService.to.get(url) as Map<String, dynamic>;
    return IpInfo.fromIpinfo(data, ip.isEmpty ? null : ip);
  }

  /// 使用 ipwhois.app 查询
  Future<IpInfo> _queryWithIpwhois(String ip) async {
    final url = ip.isEmpty
        ? 'https://ipwhois.app/json/'
        : 'https://ipwhois.app/json/$ip';
    final data = await HttpService.to.get(url) as Map<String, dynamic>;

    if (data['success'] == false) {
      throw Exception(data['message']?.toString() ?? '查询失败');
    }

    return IpInfo.fromIpwhois(data, ip.isEmpty ? null : ip);
  }
}
