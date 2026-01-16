import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio show FormData, MultipartFile;
import 'package:dio/dio.dart' hide FormData, MultipartFile;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/http_service.dart';
import '../../../utils/toast_utils.dart';

class TestServer {
  final String name;
  final String pingUrl;
  final String downloadUrl;
  final String uploadUrl;

  TestServer({
    required this.name,
    required this.pingUrl,
    required this.downloadUrl,
    required this.uploadUrl,
  });
}

enum SpeedUnit {
  mbps('Mbps', 1.0),
  kbps('Kbps', 1000.0),
  mbs('MB/s', 0.125),
  kbs('KB/s', 125.0);

  final String label;
  final double multiplier; // 相对于 Mbps 的倍数

  const SpeedUnit(this.label, this.multiplier);
}

class SpeedTestController extends GetxController {
  // 测试服务器列表
  final List<TestServer> testServers = [
    TestServer(
      name: 'Cloudflare',
      pingUrl: 'https://1.1.1.1',
      downloadUrl: 'https://speed.cloudflare.com/__down?bytes=',
      uploadUrl: 'https://speed.cloudflare.com/__up',
    ),
    TestServer(
      name: 'Google',
      pingUrl: 'https://www.google.com',
      downloadUrl: 'https://speed.cloudflare.com/__down?bytes=',
      uploadUrl: 'https://speed.cloudflare.com/__up',
    ),
  ];

  // 当前选择的服务器
  final currentServer = Rx<TestServer?>(null);
  final serverInfo = '正在选择最佳测试服务器...'.obs;

  // 测试状态
  final isTesting = false.obs;
  final testStartTime = Rx<DateTime?>(null);

  // Ping 测试结果
  final pingValue = '--'.obs;
  final pingStatus = '等待测试'.obs;
  final pingProgress = 0.0.obs;
  final isPingTesting = false.obs;

  // 下载速度测试结果
  final downloadValue = '--'.obs;
  final downloadStatus = '等待测试'.obs;
  final downloadProgress = 0.0.obs;
  final isDownloadTesting = false.obs;

  // 上传速度测试结果
  final uploadValue = '--'.obs;
  final uploadStatus = '等待测试'.obs;
  final uploadProgress = 0.0.obs;
  final isUploadTesting = false.obs;

  // 速度单位选择
  final speedUnit = SpeedUnit.mbps.obs;

  // 原始速度值（Mbps）
  final _rawDownloadSpeed = 0.0.obs;
  final _rawUploadSpeed = 0.0.obs;

  // 测试摘要
  final showSummary = false.obs;
  final summaryPing = '-- ms'.obs;
  final summaryDownload = '-- Mbps'.obs;
  final summaryUpload = '-- Mbps'.obs;
  final summaryTime = '--'.obs;

  /// 设置速度单位
  void setSpeedUnit(SpeedUnit unit) {
    speedUnit.value = unit;
    _updateSpeedDisplay();
  }

  /// 更新速度显示
  void _updateSpeedDisplay() {
    if (_rawDownloadSpeed.value > 0) {
      final converted = _rawDownloadSpeed.value * speedUnit.value.multiplier;
      downloadValue.value = converted.toStringAsFixed(2);
    }
    if (_rawUploadSpeed.value > 0) {
      final converted = _rawUploadSpeed.value * speedUnit.value.multiplier;
      uploadValue.value = converted.toStringAsFixed(2);
    }
    _updateSummary();
  }

  /// 更新摘要显示
  void _updateSummary() {
    if (_rawDownloadSpeed.value > 0) {
      final converted = _rawDownloadSpeed.value * speedUnit.value.multiplier;
      summaryDownload.value =
          '${converted.toStringAsFixed(2)} ${speedUnit.value.label}';
    }
    if (_rawUploadSpeed.value > 0) {
      final converted = _rawUploadSpeed.value * speedUnit.value.multiplier;
      summaryUpload.value =
          '${converted.toStringAsFixed(2)} ${speedUnit.value.label}';
    }
  }

  @override
  void onInit() {
    super.onInit();
    selectBestServer();
  }

  /// 选择最佳服务器
  Future<void> selectBestServer() async {
    serverInfo.value = '正在选择最佳测试服务器...';
    TestServer? bestServer;
    double bestPing = double.infinity;

    for (final server in testServers) {
      try {
        final startTime = DateTime.now();
        final controller = CancelToken();
        final timeout = Timer(const Duration(seconds: 5), () {
          controller.cancel();
        });

        try {
          await HttpService.to.dio.get(
            server.pingUrl,
            options: Options(method: 'HEAD', followRedirects: false),
            cancelToken: controller,
          );
          timeout.cancel();
          final ping = DateTime.now()
              .difference(startTime)
              .inMilliseconds
              .toDouble();

          if (ping < bestPing) {
            bestPing = ping;
            bestServer = server;
          }
        } catch (e) {
          timeout.cancel();
          if (e is! DioException || e.type != DioExceptionType.cancel) {
            rethrow;
          }
        }
      } catch (e) {
        debugPrint('[Speed Test] 服务器 ${server.name} 测试失败: $e');
      }
    }

    if (bestServer != null) {
      currentServer.value = bestServer;
      serverInfo.value = '已选择测试服务器: ${bestServer.name}';
    } else {
      // 如果所有服务器都失败，使用第一个作为默认
      currentServer.value = testServers[0];
      serverInfo.value = '已选择测试服务器: ${testServers[0].name}';
    }
  }

  /// 测试延迟 (Ping)
  Future<double> testPing() async {
    if (currentServer.value == null) {
      throw Exception('未选择测试服务器');
    }

    isPingTesting.value = true;
    pingStatus.value = '测试中...';
    pingProgress.value = 0.0;

    try {
      final times = <double>[];
      const testCount = 3;

      for (int i = 0; i < testCount; i++) {
        try {
          final startTime = DateTime.now();
          final controller = CancelToken();
          final timeout = Timer(const Duration(seconds: 5), () {
            controller.cancel();
          });

          try {
            await HttpService.to.dio.get(
              currentServer.value!.pingUrl,
              options: Options(method: 'HEAD', followRedirects: false),
              cancelToken: controller,
            );
            timeout.cancel();
            final ping = DateTime.now()
                .difference(startTime)
                .inMilliseconds
                .toDouble();
            times.add(ping);
          } catch (e) {
            timeout.cancel();
            if (e is DioException && e.type == DioExceptionType.cancel) {
              times.add(5000.0); // 超时视为5000ms
            } else {
              rethrow;
            }
          }
        } catch (e) {
          debugPrint('[Speed Test] Ping 测试失败: $e');
          times.add(5000.0);
        }

        pingProgress.value = ((i + 1) / testCount) * 100;
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final avgPing = times.reduce((a, b) => a + b) / times.length;
      pingValue.value = avgPing.round().toString();
      pingStatus.value = '测试完成';
      pingProgress.value = 100.0;

      return avgPing;
    } catch (e) {
      pingValue.value = '错误';
      pingStatus.value = '测试失败: ${e.toString()}';
      pingProgress.value = 0.0;
      throw e;
    } finally {
      isPingTesting.value = false;
    }
  }

  /// 测试下载速度
  Future<double> testDownload() async {
    if (currentServer.value == null) {
      throw Exception('未选择测试服务器');
    }

    isDownloadTesting.value = true;
    downloadStatus.value = '测试中...';
    downloadProgress.value = 0.0;

    try {
      final testSizes = [
        1 * 1024 * 1024,
        5 * 1024 * 1024,
        10 * 1024 * 1024,
      ]; // 1MB, 5MB, 10MB
      int totalBytes = 0;
      double totalTime = 0;

      for (int i = 0; i < testSizes.length; i++) {
        final size = testSizes[i];
        final url = '${currentServer.value!.downloadUrl}$size';

        try {
          final startTime = DateTime.now();
          final response = await HttpService.to.dio.get<List<int>>(
            url,
            options: Options(responseType: ResponseType.bytes),
            onReceiveProgress: (received, total) {
              if (total > 0) {
                final progress =
                    ((received / total) * 100) / testSizes.length +
                    (i * 100 / testSizes.length);
                downloadProgress.value = progress.clamp(0.0, 100.0);
              }
            },
          );

          final endTime = DateTime.now();
          final duration =
              endTime.difference(startTime).inMilliseconds / 1000.0;
          totalBytes += response.data?.length ?? 0;
          totalTime += duration;
        } catch (e) {
          debugPrint('[Speed Test] 下载测试失败: $e');
          // 继续下一个测试
        }
      }

      // 计算速度 (Mbps)
      final speedMbps = (totalBytes * 8) / (totalTime * 1000000);
      _rawDownloadSpeed.value = speedMbps;
      _updateSpeedDisplay();
      downloadStatus.value = '测试完成';
      downloadProgress.value = 100.0;

      return speedMbps;
    } catch (e) {
      downloadValue.value = '错误';
      downloadStatus.value = '测试失败: ${e.toString()}';
      downloadProgress.value = 0.0;
      throw e;
    } finally {
      isDownloadTesting.value = false;
    }
  }

  /// 测试上传速度
  Future<double> testUpload() async {
    if (currentServer.value == null) {
      throw Exception('未选择测试服务器');
    }

    isUploadTesting.value = true;
    uploadStatus.value = '测试中...';
    uploadProgress.value = 0.0;

    try {
      final testSizes = [1 * 1024 * 1024, 2 * 1024 * 1024]; // 1MB, 2MB
      int totalBytes = 0;
      double totalTime = 0;

      for (int i = 0; i < testSizes.length; i++) {
        final size = testSizes[i];
        final testData = Uint8List(size);
        // 填充随机数据
        for (int j = 0; j < size; j++) {
          testData[j] = (j % 256).toInt();
        }

        try {
          final formData = dio.FormData.fromMap({
            'file': dio.MultipartFile.fromBytes(testData, filename: 'test.dat'),
          });

          final startTime = DateTime.now();
          await HttpService.to.dio.post(
            currentServer.value!.uploadUrl,
            data: formData,
            onSendProgress: (sent, total) {
              if (total > 0) {
                final progress =
                    ((sent / total) * 100) / testSizes.length +
                    (i * 100 / testSizes.length);
                uploadProgress.value = progress.clamp(0.0, 100.0);
              }
            },
          );

          final endTime = DateTime.now();
          final duration =
              endTime.difference(startTime).inMilliseconds / 1000.0;
          totalBytes += size;
          totalTime += duration;
        } catch (e) {
          debugPrint('[Speed Test] 上传测试失败: $e');
          // 如果上传测试失败，使用估算值（基于下载速度的估算）
          if (i == 0) {
            final estimatedUpload = _rawDownloadSpeed.value * 0.1;
            _rawUploadSpeed.value = estimatedUpload;
            _updateSpeedDisplay();
            uploadStatus.value = '估算值（上传测试受限）';
            uploadProgress.value = 100.0;
            isUploadTesting.value = false;
            return estimatedUpload;
          }
        }
      }

      // 计算速度 (Mbps)
      final speedMbps = (totalBytes * 8) / (totalTime * 1000000);
      _rawUploadSpeed.value = speedMbps;
      _updateSpeedDisplay();
      uploadStatus.value = '测试完成';
      uploadProgress.value = 100.0;

      return speedMbps;
    } catch (e) {
      // 如果上传测试完全失败，提供估算值
      try {
        final estimatedUpload = _rawDownloadSpeed.value * 0.1;
        _rawUploadSpeed.value = estimatedUpload;
        _updateSpeedDisplay();
        uploadStatus.value = '估算值（上传测试受限）';
        uploadProgress.value = 100.0;
        return estimatedUpload;
      } catch (fallbackError) {
        uploadValue.value = '错误';
        uploadStatus.value = '测试失败: ${e.toString()}';
        uploadProgress.value = 0.0;
        throw e;
      }
    } finally {
      isUploadTesting.value = false;
    }
  }

  /// 运行完整测试
  Future<void> runSpeedTest() async {
    if (isTesting.value) return;

    isTesting.value = true;
    testStartTime.value = DateTime.now();

    // 重置结果
    pingValue.value = '--';
    downloadValue.value = '--';
    uploadValue.value = '--';
    _rawDownloadSpeed.value = 0.0;
    _rawUploadSpeed.value = 0.0;
    pingStatus.value = '等待测试';
    downloadStatus.value = '等待测试';
    uploadStatus.value = '等待测试';
    pingProgress.value = 0.0;
    downloadProgress.value = 0.0;
    uploadProgress.value = 0.0;
    showSummary.value = false;

    try {
      // 选择服务器
      await selectBestServer();

      // 测试延迟
      final ping = await testPing();

      // 测试下载速度
      final download = await testDownload();

      // 测试上传速度
      final upload = await testUpload();

      // 显示摘要
      final testEndTime = DateTime.now();
      final testDuration = testEndTime
          .difference(testStartTime.value!)
          .inSeconds;

      summaryPing.value = '${ping.round()} ms';
      _rawDownloadSpeed.value = download;
      _rawUploadSpeed.value = upload;
      _updateSummary();
      summaryTime.value = '$testDuration 秒';
      showSummary.value = true;
    } catch (e) {
      debugPrint('[Speed Test] 测试失败: $e');
      ToastUtils.showError('测试过程中出现错误: ${e.toString()}');
    } finally {
      isTesting.value = false;
    }
  }

  /// 重置测试结果
  void resetTest() {
    pingValue.value = '--';
    downloadValue.value = '--';
    uploadValue.value = '--';
    _rawDownloadSpeed.value = 0.0;
    _rawUploadSpeed.value = 0.0;
    pingStatus.value = '等待测试';
    downloadStatus.value = '等待测试';
    uploadStatus.value = '等待测试';
    pingProgress.value = 0.0;
    downloadProgress.value = 0.0;
    uploadProgress.value = 0.0;
    showSummary.value = false;
  }
}
