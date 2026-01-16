/// Toast 工具类
/// 提供统一的 toast 提示方法
library toast_utils;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Toast 工具类
///
/// 提供统一的 toast 提示方法，用于显示简洁的底部提示
class ToastUtils {
  /// 显示错误 toast
  ///
  /// [message] 错误消息
  static void showError(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(
        Icons.error_outline,
        color: Get.theme.colorScheme.onError,
        size: 20,
      ),
    );
  }

  /// 显示网络错误 toast
  ///
  /// [message] 错误消息
  static void showNetworkError(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(
        Icons.wifi_off,
        color: Get.theme.colorScheme.onError,
        size: 20,
      ),
    );
  }

  /// 显示成功 toast
  ///
  /// [message] 成功消息
  static void showSuccess(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
