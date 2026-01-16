import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/encrypt_utils.dart';
import '../../../utils/toast_utils.dart';

enum AlgorithmType { encode, hash, crypto }

class Algorithm {
  final String key;
  final String name;
  final AlgorithmType type;
  final bool needsKey;

  const Algorithm({
    required this.key,
    required this.name,
    required this.type,
    this.needsKey = false,
  });
}

class StringEncryptorController extends GetxController {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final keyController = TextEditingController();
  final saltController = TextEditingController();
  final ivController = TextEditingController();

  final currentAlgorithm = 'base64'.obs;
  final isLoading = false.obs;
  final hasOutput = false.obs;

  // AES 选项
  final aesMode = 'GCM'.obs;
  final aesKeyLength = 256.obs;
  final aesIterations = 100000.obs;
  final aesHashAlgo = 'SHA-256'.obs;

  final algorithms = const [
    Algorithm(key: 'base64', name: 'Base64', type: AlgorithmType.encode),
    Algorithm(key: 'url', name: 'URL 编码', type: AlgorithmType.encode),
    Algorithm(key: 'html', name: 'HTML 实体', type: AlgorithmType.encode),
    Algorithm(key: 'hex', name: 'Hex 编码', type: AlgorithmType.encode),
    Algorithm(key: 'unicode', name: 'Unicode 编码', type: AlgorithmType.encode),
    Algorithm(key: 'morse', name: '摩斯密码', type: AlgorithmType.encode),
    Algorithm(key: 'md5', name: 'MD5 哈希', type: AlgorithmType.hash),
    Algorithm(key: 'sha1', name: 'SHA-1 哈希', type: AlgorithmType.hash),
    Algorithm(key: 'sha256', name: 'SHA-256 哈希', type: AlgorithmType.hash),
    Algorithm(key: 'sha512', name: 'SHA-512 哈希', type: AlgorithmType.hash),
    Algorithm(
      key: 'aes',
      name: 'AES 加密',
      type: AlgorithmType.crypto,
      needsKey: true,
    ),
    Algorithm(
      key: 'caesar',
      name: '凯撒密码',
      type: AlgorithmType.crypto,
      needsKey: true,
    ),
  ];

  @override
  void onClose() {
    inputController.dispose();
    outputController.dispose();
    keyController.dispose();
    saltController.dispose();
    ivController.dispose();
    super.onClose();
  }

  void selectAlgorithm(String key) {
    currentAlgorithm.value = key;
  }

  Algorithm? get selectedAlgorithm {
    return algorithms.firstWhereOrNull((a) => a.key == currentAlgorithm.value);
  }

  Future<void> encrypt() async {
    final input = inputController.text.trim();
    if (input.isEmpty) {
      ToastUtils.showError('请输入要加密/编码的内容');
      return;
    }

    final algo = selectedAlgorithm;
    if (algo == null) return;

    if (algo.needsKey && keyController.text.trim().isEmpty) {
      ToastUtils.showError('请输入密钥');
      return;
    }

    isLoading.value = true;
    try {
      String result = '';
      if (algo.type == AlgorithmType.encode) {
        result = await _handleEncode(algo.key, input, true);
      } else if (algo.type == AlgorithmType.hash) {
        result = await _handleHash(algo.key, input);
      } else if (algo.type == AlgorithmType.crypto) {
        result = await _handleCrypto(algo.key, input, true);
      }
      outputController.text = result;
      hasOutput.value = result.isNotEmpty;
    } catch (e) {
      ToastUtils.showError('处理失败: ${e.toString()}');
      outputController.text = '';
      hasOutput.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> decrypt() async {
    final input = inputController.text.trim();
    if (input.isEmpty) {
      ToastUtils.showError('请输入要解密/解码的内容');
      return;
    }

    final algo = selectedAlgorithm;
    if (algo == null) return;

    if (algo.type == AlgorithmType.hash) {
      ToastUtils.showError('哈希算法不支持解密');
      return;
    }

    if (algo.needsKey && keyController.text.trim().isEmpty) {
      ToastUtils.showError('请输入密钥');
      return;
    }

    isLoading.value = true;
    try {
      String result = '';
      if (algo.type == AlgorithmType.encode) {
        result = await _handleEncode(algo.key, input, false);
      } else if (algo.type == AlgorithmType.crypto) {
        result = await _handleCrypto(algo.key, input, false);
      }
      outputController.text = result;
      hasOutput.value = result.isNotEmpty;
    } catch (e) {
      ToastUtils.showError('处理失败: ${e.toString()}');
      outputController.text = '';
      hasOutput.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _handleEncode(
    String algorithm,
    String input,
    bool encode,
  ) async {
    switch (algorithm) {
      case 'base64':
        return encode
            ? EncryptUtils.base64Encode(input)
            : EncryptUtils.base64Decode(input);
      case 'url':
        return encode
            ? EncryptUtils.urlEncode(input)
            : EncryptUtils.urlDecode(input);
      case 'html':
        return encode
            ? EncryptUtils.htmlEncode(input)
            : EncryptUtils.htmlDecode(input);
      case 'hex':
        return encode
            ? EncryptUtils.hexEncode(input)
            : EncryptUtils.hexDecode(input);
      case 'unicode':
        return encode
            ? EncryptUtils.unicodeEncode(input)
            : EncryptUtils.unicodeDecode(input);
      case 'morse':
        return encode
            ? EncryptUtils.morseEncode(input)
            : EncryptUtils.morseDecode(input);
      default:
        throw Exception('不支持的编码算法');
    }
  }

  Future<String> _handleHash(String algorithm, String input) async {
    switch (algorithm) {
      case 'md5':
        return EncryptUtils.md5Hash(input);
      case 'sha1':
        return EncryptUtils.sha1Hash(input);
      case 'sha256':
        return EncryptUtils.sha256Hash(input);
      case 'sha512':
        return EncryptUtils.sha512Hash(input);
      default:
        throw Exception('不支持的哈希算法');
    }
  }

  Future<String> _handleCrypto(
    String algorithm,
    String input,
    bool encrypt,
  ) async {
    final key = keyController.text.trim();
    if (algorithm == 'aes') {
      if (encrypt) {
        return await EncryptUtils.aesEncrypt(
          input,
          key,
          mode: aesMode.value,
          keyLength: aesKeyLength.value,
          salt: saltController.text.trim().isEmpty
              ? null
              : saltController.text.trim(),
          iv: ivController.text.trim().isEmpty
              ? null
              : ivController.text.trim(),
          iterations: aesIterations.value,
          hashAlgo: aesHashAlgo.value,
        );
      } else {
        return await EncryptUtils.aesDecrypt(
          input,
          key,
          mode: aesMode.value,
          keyLength: aesKeyLength.value,
          iterations: aesIterations.value,
          hashAlgo: aesHashAlgo.value,
        );
      }
    } else if (algorithm == 'caesar') {
      final shift = int.tryParse(key) ?? 3;
      return EncryptUtils.caesarCipher(input, shift, encrypt);
    }
    throw Exception('不支持的加密算法');
  }

  void clearInput() {
    inputController.clear();
  }

  void clearOutput() {
    outputController.clear();
    hasOutput.value = false;
  }

  Future<void> copyOutput() async {
    if (outputController.text.isEmpty) {
      ToastUtils.showError('没有内容可复制');
      return;
    }
    await FlutterClipboard.copy(outputController.text);
  }

  void generateSalt() {
    final random = List.generate(16, (_) => (0 + (255 - 0) * (0.5)).round());
    saltController.text = random
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  void generateIV() {
    final ivLength = aesMode.value == 'GCM' ? 12 : 16;
    final random = List.generate(
      ivLength,
      (_) => (0 + (255 - 0) * (0.5)).round(),
    );
    ivController.text = random
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
