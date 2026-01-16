import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/currency_data.dart';
import '../../../services/http_service.dart';
import '../../../utils/currency_utils.dart';
import '../../../utils/toast_utils.dart';

class CurrencyItem {
  final String code;
  final String name;

  const CurrencyItem(this.code, this.name);
}

class CurrencyConverterController extends GetxController {
  final amountController = TextEditingController(text: '100');
  final fromCurrency = 'USD'.obs;
  final toCurrency = 'CNY'.obs;

  final resultText = ''.obs;

  final base = ''.obs;
  final rates = RxMap<String, double>({});
  final lastUpdated = ''.obs;
  final searchQuery = ''.obs;

  List<CurrencyItem> get currencies => CurrencyData.namesZh.entries
      .map((e) => CurrencyItem(e.key, e.value))
      .toList(growable: false);

  String getCurrencyFlag(String code) {
    return CurrencyUtils.getFlag(code);
  }

  String getCurrencyName(String code) {
    return CurrencyUtils.getName(code);
  }

  @override
  void onInit() {
    super.onInit();
    // 延迟调用，避免在构建期间显示 snackbar
    Future.microtask(() => fetchRates(fromCurrency.value));
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void setFromCurrency(String code) {
    fromCurrency.value = code;
    fetchRates(code);
  }

  void setToCurrency(String code) {
    toCurrency.value = code;
  }

  void setSearchQuery(String q) {
    searchQuery.value = q;
  }

  Future<void> fetchRates(String baseCode) async {
    try {
      final start = DateTime.now();
      Map<String, dynamic>? data;

      // 尝试主源
      try {
        debugPrint('[currency] 请求主源 base=$baseCode');
        data =
            await HttpService.to.get(
                  'https://api.exchangerate.host/latest',
                  queryParameters: {'base': baseCode},
                )
                as Map<String, dynamic>?;

        if (data != null && data['rates'] == null) {
          debugPrint('[currency] 主源数据缺少 rates');
          data = null;
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          debugPrint('[currency] 主源请求超时');
          ToastUtils.showNetworkError('请求超时，请检查网络后重试');
        } else if (e.type == DioExceptionType.connectionError ||
            (e.error is SocketException)) {
          debugPrint('[currency] 网络不可用');
          ToastUtils.showNetworkError('网络不可用，请检查连接');
        } else {
          debugPrint('[currency] 主源请求异常: ${e.message}');
        }
        data = null;
      } catch (_) {
        debugPrint('[currency] 主源请求异常');
        data = null;
      }

      // 如果主源失败，尝试备用源
      if (data == null) {
        try {
          debugPrint('[currency] 请求备用源 base=$baseCode');
          data =
              await HttpService.to.get(
                    'https://api.exchangerate-api.com/v4/latest/$baseCode',
                  )
                  as Map<String, dynamic>?;

          if (data != null) {
            final ratesField = data['rates'];
            final convField = data['conversion_rates'];
            if (ratesField == null && convField != null) {
              data = {
                'base': (data['base']?.toString() ?? baseCode),
                'date': (data['time_last_update_utc']?.toString() ?? ''),
                'rates': convField as Map<String, dynamic>,
              };
            }
          }
        } on DioException catch (e) {
          debugPrint('[currency] 备用源请求异常: ${e.message}');
          data = null;
        } catch (_) {
          debugPrint('[currency] 备用源请求异常');
          data = null;
        }
      }

      if (data == null || data['rates'] == null) {
        debugPrint('[currency] 数据解析失败，rates 缺失');
        ToastUtils.showNetworkError('汇率接口请求失败');
        return;
      }

      final m = <String, double>{};
      final r = data['rates'] as Map<String, dynamic>;
      r.forEach((k, v) {
        final d = (v is num) ? v.toDouble() : double.tryParse('$v');
        if (d != null) {
          m[k] = d;
        }
      });
      rates
        ..clear()
        ..addAll(m);
      base.value = data['base']?.toString() ?? baseCode;
      lastUpdated.value = data['date']?.toString() ?? '';
      final durMs = DateTime.now().difference(start).inMilliseconds;
      debugPrint(
        '[currency] 成功更新，base=${base.value}, 条目=${rates.length}, 用时=${durMs}ms',
      );
      convert();
    } catch (e) {
      debugPrint('[currency] 未捕获异常，更新失败: $e');
      ToastUtils.showNetworkError('更新汇率失败，请稍后重试');
    }
  }

  void convert() {
    final raw = amountController.text.trim();
    if (raw.isEmpty) {
      resultText.value = '';
      return;
    }
    final amount = double.tryParse(raw);
    if (amount == null) {
      resultText.value = '';
      ToastUtils.showError('金额格式错误');
      return;
    }
    final baseCode = fromCurrency.value;
    final targetCode = toCurrency.value;
    if (rates.isEmpty || base.value != baseCode) {
      debugPrint(
        '[currency] 转换前需要刷新汇率 base=$baseCode 当前base=${base.value} rates=${rates.length}',
      );
      resultText.value = '';
      fetchRates(baseCode);
      return;
    }
    final rate = rates[targetCode];
    if (rate == null) {
      debugPrint('[currency] 缺少目标货币汇率 target=$targetCode');
      resultText.value = '';
      ToastUtils.showError('缺少目标货币汇率');
      return;
    }
    final converted = amount * rate;
    debugPrint(
      '[currency] 转换 amount=$amount base=$baseCode rate=$rate target=$targetCode result=$converted',
    );
    resultText.value =
        '$amount $baseCode ≈ ${_formatNumber(converted)} $targetCode';
  }

  List<MapEntry<String, double>> getFilteredRates() {
    final q = searchQuery.value.trim().toUpperCase();
    final entries = rates.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (q.isEmpty) {
      return entries;
    }
    return entries.where((e) => e.key.contains(q)).toList();
  }

  String _formatNumber(double v) {
    final abs = v.abs();
    if (abs < 1) {
      return v.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
    } else if (abs < 1000000) {
      return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    } else {
      return v.toStringAsExponential(4);
    }
  }
}
