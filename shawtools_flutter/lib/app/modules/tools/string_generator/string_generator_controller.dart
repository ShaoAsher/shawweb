import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/toast_utils.dart';

class StringGeneratorController extends GetxController {
  // 银行卡号生成器
  final cardBank = 'random'.obs;
  final cardCount = 1.obs;
  final cardPrefixController = TextEditingController();
  final cardResults = <String>[].obs;

  // UDID 生成器
  final udidCount = 1.obs;
  final udidResults = <String>[].obs;

  // 包名生成器
  final packageCount = 1.obs;
  final packageLevel = 3.obs;
  final packageLength = 6.obs;
  final packageResults = <String>[].obs;

  // 其他生成器
  final otherType = 'uuid'.obs;
  final otherCount = 1.obs;
  final randomStringLength = 16.obs;
  final randomNumberRange = '1000-9999'.obs;
  final otherResults = <String>[].obs;

  final random = Random();

  /// Luhn 算法校验和
  int luhnChecksum(String cardNumber) {
    int sum = 0;
    bool isEven = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      if (isEven) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      isEven = !isEven;
    }
    return (10 - (sum % 10)) % 10;
  }

  /// 生成银行卡号
  void generateCardNumbers() {
    final results = <String>[];
    final bankPrefixes = {
      '6217': ['6217'],
      '6228': ['6228'],
      '6222': ['6222'],
      '6212': ['6212'],
      '6227': ['6227'],
      '6225': ['6225'],
      '6221': ['6221'],
      'random': [],
    };

    for (int i = 0; i < cardCount.value; i++) {
      String prefix;
      if (cardPrefixController.text.trim().isNotEmpty) {
        prefix = cardPrefixController.text.trim();
      } else if (cardBank.value != 'random' &&
          bankPrefixes.containsKey(cardBank.value)) {
        final prefixes = bankPrefixes[cardBank.value]!;
        prefix = prefixes[random.nextInt(prefixes.length)];
      } else {
        final commonPrefixes = [
          '6217',
          '6228',
          '6222',
          '6212',
          '6227',
          '6225',
          '6221',
          '6210',
          '6211',
          '6213',
        ];
        prefix = commonPrefixes[random.nextInt(commonPrefixes.length)];
      }

      // 补齐到15位
      String cardNumber = prefix;
      while (cardNumber.length < 15) {
        cardNumber += random.nextInt(10).toString();
      }
      cardNumber = cardNumber.substring(0, 15);

      // 计算校验位
      final checksum = luhnChecksum(cardNumber);
      cardNumber += checksum.toString();
      results.add(cardNumber);
    }

    cardResults.value = results;
  }

  /// 生成 UDID
  void generateUDIDs() {
    final results = <String>[];
    const chars = '0123456789ABCDEF';

    for (int i = 0; i < udidCount.value; i++) {
      String udid = '';
      for (int j = 0; j < 32; j++) {
        udid += chars[random.nextInt(chars.length)];
      }
      results.add(udid.toUpperCase());
    }

    udidResults.value = results;
  }

  /// 生成包名
  void generatePackages() {
    final results = <String>[];
    const chars = 'abcdefghijklmnopqrstuvwxyz';

    for (int i = 0; i < packageCount.value; i++) {
      String packageName = 'com';
      for (int j = 0; j < packageLevel.value - 1; j++) {
        packageName += '.';
        String segment = '';
        segment += chars[random.nextInt(chars.length)];
        for (int k = 1; k < packageLength.value; k++) {
          const charSet = chars + '0123456789';
          segment += charSet[random.nextInt(charSet.length)];
        }
        packageName += segment;
      }
      results.add(packageName);
    }

    packageResults.value = results;
  }

  /// 生成其他类型
  void generateOther() {
    final results = <String>[];

    for (int i = 0; i < otherCount.value; i++) {
      switch (otherType.value) {
        case 'uuid':
          results.add(generateUUID());
          break;
        case 'randomString':
          results.add(generateRandomString(randomStringLength.value));
          break;
        case 'randomNumber':
          final range = randomNumberRange.value.split('-');
          if (range.length == 2) {
            final min = int.tryParse(range[0].trim()) ?? 1000;
            final max = int.tryParse(range[1].trim()) ?? 9999;
            results.add((random.nextInt(max - min + 1) + min).toString());
          } else {
            results.add(random.nextInt(10000).toString());
          }
          break;
        case 'macAddress':
          results.add(generateMACAddress());
          break;
        case 'ipAddress':
          results.add(generateIPAddress());
          break;
        case 'email':
          results.add(generateEmail());
          break;
      }
    }

    otherResults.value = results;
  }

  /// 生成 UUID
  String generateUUID() {
    return '${_randomHex(8)}-${_randomHex(4)}-4${_randomHex(3)}-${_randomHex(1, '89ab')}-${_randomHex(12)}';
  }

  String _randomHex(int length, [String chars = '0123456789abcdef']) {
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[random.nextInt(chars.length)];
    }
    return result;
  }

  /// 生成随机字符串
  String generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[random.nextInt(chars.length)];
    }
    return result;
  }

  /// 生成 MAC 地址
  String generateMACAddress() {
    const hex = '0123456789ABCDEF';
    String mac = '';
    for (int i = 0; i < 6; i++) {
      if (i > 0) mac += ':';
      mac += hex[random.nextInt(hex.length)];
      mac += hex[random.nextInt(hex.length)];
    }
    return mac;
  }

  /// 生成 IP 地址
  String generateIPAddress() {
    return '${random.nextInt(255)}.${random.nextInt(255)}.${random.nextInt(255)}.${random.nextInt(255)}';
  }

  /// 生成邮箱地址
  String generateEmail() {
    const domains = [
      'gmail.com',
      'yahoo.com',
      'outlook.com',
      '163.com',
      'qq.com',
      'example.com',
    ];
    final username = generateRandomString(8).toLowerCase();
    final domain = domains[random.nextInt(domains.length)];
    return '$username@$domain';
  }

  /// 格式化银行卡号（每4位加空格）
  String formatCardNumber(String cardNumber) {
    String result = '';
    for (int i = 0; i < cardNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        result += ' ';
      }
      result += cardNumber[i];
    }
    return result;
  }

  /// 复制到剪贴板
  Future<void> copyToClipboard(String text) async {
    try {
      await FlutterClipboard.copy(text);
    } catch (e) {
      ToastUtils.showError('复制失败');
    }
  }

  /// 清空结果
  void clearCardResults() {
    cardResults.clear();
  }

  void clearUDIDResults() {
    udidResults.clear();
  }

  void clearPackageResults() {
    packageResults.clear();
  }

  void clearOtherResults() {
    otherResults.clear();
  }
}
