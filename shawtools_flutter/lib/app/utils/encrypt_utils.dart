/// 加密工具类
/// 提供各种编码、加密、哈希等工具方法
library encrypt_utils;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/export.dart';

/// 加密工具类
class EncryptUtils {
  /// Base64 编码/解码
  static String base64Encode(String input) {
    return base64.encode(utf8.encode(input));
  }

  static String base64Decode(String input) {
    try {
      return utf8.decode(base64.decode(input));
    } catch (e) {
      throw Exception('Base64 解码失败: $e');
    }
  }

  /// URL 编码/解码
  static String urlEncode(String input) {
    return Uri.encodeComponent(input);
  }

  static String urlDecode(String input) {
    try {
      return Uri.decodeComponent(input);
    } catch (e) {
      throw Exception('URL 解码失败: $e');
    }
  }

  /// HTML 实体编码/解码
  static String htmlEncode(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  static String htmlDecode(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  /// Hex 编码/解码
  static String hexEncode(String input) {
    return utf8
        .encode(input)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ');
  }

  static String hexDecode(String input) {
    try {
      final hexStr = input.replaceAll(RegExp(r'\s+'), '');
      if (hexStr.length % 2 != 0) {
        throw Exception('Hex字符串长度必须是偶数');
      }
      final bytes = <int>[];
      for (int i = 0; i < hexStr.length; i += 2) {
        bytes.add(int.parse(hexStr.substring(i, i + 2), radix: 16));
      }
      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('Hex 解码失败: $e');
    }
  }

  /// Unicode 编码/解码
  static String unicodeEncode(String input) {
    return input
        .split('')
        .map((char) {
          final code = char.codeUnitAt(0);
          return '\\u${code.toRadixString(16).padLeft(4, '0')}';
        })
        .join('');
  }

  static String unicodeDecode(String input) {
    try {
      return input.replaceAllMapped(
        RegExp(r'\\u([0-9a-fA-F]{4})'),
        (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
      );
    } catch (e) {
      throw Exception('Unicode 解码失败: $e');
    }
  }

  /// MD5 哈希
  static String md5Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// SHA-1 哈希
  static String sha1Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  /// SHA-256 哈希
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// SHA-512 哈希
  static String sha512Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  /// 凯撒密码
  static String caesarCipher(String input, int shift, bool encrypt) {
    final effectiveShift = encrypt ? shift : -shift;
    return input
        .split('')
        .map((char) {
          if (char.codeUnitAt(0) >= 32 && char.codeUnitAt(0) <= 126) {
            int code = char.codeUnitAt(0);
            code = code + effectiveShift;
            while (code < 32) code += 95;
            while (code > 126) code -= 95;
            return String.fromCharCode(code);
          }
          return char;
        })
        .join('');
  }

  /// 摩斯密码编码/解码
  static String morseEncode(String input) {
    const morseCode = {
      'A': '.-',
      'B': '-...',
      'C': '-.-.',
      'D': '-..',
      'E': '.',
      'F': '..-.',
      'G': '--.',
      'H': '....',
      'I': '..',
      'J': '.---',
      'K': '-.-',
      'L': '.-..',
      'M': '--',
      'N': '-.',
      'O': '---',
      'P': '.--.',
      'Q': '--.-',
      'R': '.-.',
      'S': '...',
      'T': '-',
      'U': '..-',
      'V': '...-',
      'W': '.--',
      'X': '-..-',
      'Y': '-.--',
      'Z': '--..',
      '0': '-----',
      '1': '.----',
      '2': '..---',
      '3': '...--',
      '4': '....-',
      '5': '.....',
      '6': '-....',
      '7': '--...',
      '8': '---..',
      '9': '----.',
      '.': '.-.-.-',
      ',': '--..--',
      '?': '..--..',
      "'": '.----.',
      '!': '-.-.--',
      '/': '-..-.',
      '(': '-.--.',
      ')': '-.--.-',
      '&': '.-...',
      ':': '---...',
      ';': '-.-.-.',
      '=': '-...-',
      '+': '.-.-.',
      '-': '-....-',
      '_': '..--.-',
      '"': '.-..-.',
      '\$': '...-..-',
      '@': '.--.-.',
    };

    return input
        .toUpperCase()
        .split('')
        .map((char) {
          if (char == ' ') return '/';
          return morseCode[char] ?? char;
        })
        .join(' ');
  }

  static String morseDecode(String input) {
    const reverseMorse = {
      '.-': 'A',
      '-...': 'B',
      '-.-.': 'C',
      '-..': 'D',
      '.': 'E',
      '..-.': 'F',
      '--.': 'G',
      '....': 'H',
      '..': 'I',
      '.---': 'J',
      '-.-': 'K',
      '.-..': 'L',
      '--': 'M',
      '-.': 'N',
      '---': 'O',
      '.--.': 'P',
      '--.-': 'Q',
      '.-.': 'R',
      '...': 'S',
      '-': 'T',
      '..-': 'U',
      '...-': 'V',
      '.--': 'W',
      '-..-': 'X',
      '-.--': 'Y',
      '--..': 'Z',
      '-----': '0',
      '.----': '1',
      '..---': '2',
      '...--': '3',
      '....-': '4',
      '.....': '5',
      '-....': '6',
      '--...': '7',
      '---..': '8',
      '----.': '9',
      '.-.-.-': '.',
      '--..--': ',',
      '..--..': '?',
      '.----.': "'",
      '-.-.--': '!',
      '-..-.': '/',
      '-.--.': '(',
      '-.--.-': ')',
      '.-...': '&',
      '---...': ':',
      '-.-.-.': ';',
      '-...-': '=',
      '.-.-.': '+',
      '-....-': '-',
      '..--.-': '_',
      '.-..-.': '"',
      '...-..-': '\$',
      '.--.-.': '@',
    };

    try {
      return input
          .split(RegExp(r'[\s\/]+'))
          .map((code) {
            if (code.isEmpty || code == '/') return ' ';
            return reverseMorse[code] ?? code;
          })
          .join('')
          .replaceAll(RegExp(r'\s+'), ' ');
    } catch (e) {
      throw Exception('摩斯密码解码失败: $e');
    }
  }

  /// AES 加密/解密
  static Future<String> aesEncrypt(
    String input,
    String password, {
    String mode = 'GCM',
    int keyLength = 256,
    String? salt,
    String? iv,
    int iterations = 100000,
    String hashAlgo = 'SHA-256',
  }) async {
    try {
      // 生成或使用提供的 salt
      final saltBytes = salt != null && salt.isNotEmpty
          ? _hexToBytes(salt)
          : _generateRandomBytes(16);

      // 生成或使用提供的 IV
      final ivLength = mode == 'GCM' ? 12 : 16;
      final ivBytes = iv != null && iv.isNotEmpty
          ? _hexToBytes(iv)
          : _generateRandomBytes(ivLength);

      // 派生密钥
      final key = _deriveKey(
        password,
        saltBytes,
        iterations,
        keyLength,
        hashAlgo,
      );

      // 执行加密
      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          encrypt.Key(Uint8List.fromList(key)),
          mode: _getAESMode(mode),
        ),
      );

      final encrypted = encrypter.encrypt(
        input,
        iv: encrypt.IV(Uint8List.fromList(ivBytes)),
      );

      // 组合元数据和加密数据
      final metadata = {
        'saltLen': saltBytes.length,
        'ivLen': ivBytes.length,
        'mode': mode,
        'keyLen': keyLength,
        'iterations': iterations,
        'hashAlgo': hashAlgo,
      };

      final metadataJson = jsonEncode(metadata);
      final metadataBytes = utf8.encode(metadataJson);
      final metadataLen = [
        (metadataBytes.length >> 8) & 0xFF,
        metadataBytes.length & 0xFF,
      ];

      final combined = <int>[
        ...metadataLen,
        ...metadataBytes,
        ...saltBytes,
        ...ivBytes,
        ...encrypted.bytes,
      ];

      return base64.encode(combined);
    } catch (e) {
      throw Exception('AES 加密失败: $e');
    }
  }

  static Future<String> aesDecrypt(
    String input,
    String password, {
    String mode = 'GCM',
    int keyLength = 256,
    int iterations = 100000,
    String hashAlgo = 'SHA-256',
  }) async {
    try {
      final allData = base64.decode(input);
      final metadataLen = (allData[0] << 8) | allData[1];
      final metadataJson = utf8.decode(allData.sublist(2, 2 + metadataLen));
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      final dataStart = 2 + metadataLen;
      final saltBytes = allData.sublist(
        dataStart,
        dataStart + metadata['saltLen'] as int,
      );
      final ivStart = dataStart + metadata['saltLen'] as int;
      final ivBytes = allData.sublist(
        ivStart,
        ivStart + metadata['ivLen'] as int,
      );
      final encryptedBytes = allData.sublist(
        ivStart + metadata['ivLen'] as int,
      );

      final storedMode = metadata['mode'] as String? ?? mode;
      final storedKeyLen = metadata['keyLen'] as int? ?? keyLength;
      final storedIterations = metadata['iterations'] as int? ?? iterations;
      final storedHashAlgo = metadata['hashAlgo'] as String? ?? hashAlgo;

      final key = _deriveKey(
        password,
        saltBytes,
        storedIterations,
        storedKeyLen,
        storedHashAlgo,
      );

      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          encrypt.Key(Uint8List.fromList(key)),
          mode: _getAESMode(storedMode),
        ),
      );

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: encrypt.IV(Uint8List.fromList(ivBytes)),
      );

      return decrypted;
    } catch (e) {
      throw Exception('AES 解密失败: $e');
    }
  }

  /// 获取 AES 模式
  static encrypt.AESMode _getAESMode(String mode) {
    switch (mode.toUpperCase()) {
      case 'CBC':
        return encrypt.AESMode.cbc;
      case 'CTR':
        return encrypt.AESMode.ctr;
      case 'CFB':
        return encrypt.AESMode.cfb64;
      case 'OFB':
        return encrypt.AESMode.ofb64;
      case 'GCM':
      default:
        return encrypt.AESMode.gcm;
    }
  }

  /// 派生密钥
  static List<int> _deriveKey(
    String password,
    List<int> salt,
    int iterations,
    int keyLength,
    String hashAlgo,
  ) {
    final passwordBytes = utf8.encode(password);
    final keyDerivator = PBKDF2KeyDerivator(HMac(_getDigest(hashAlgo), 64))
      ..init(
        Pbkdf2Parameters(Uint8List.fromList(salt), iterations, keyLength ~/ 8),
      );

    return keyDerivator.process(passwordBytes);
  }

  /// 获取摘要算法
  static pc.Digest _getDigest(String hashAlgo) {
    switch (hashAlgo.toUpperCase()) {
      case 'SHA-384':
        return SHA384Digest();
      case 'SHA-512':
        return SHA512Digest();
      case 'SHA-256':
      default:
        return SHA256Digest();
    }
  }

  /// Hex 转字节
  static List<int> _hexToBytes(String hex) {
    final hexStr = hex.replaceAll(RegExp(r'\s+'), '');
    if (hexStr.length % 2 != 0) {
      throw Exception('Hex字符串长度必须是偶数');
    }
    final bytes = <int>[];
    for (int i = 0; i < hexStr.length; i += 2) {
      bytes.add(int.parse(hexStr.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  /// 生成随机字节
  static List<int> _generateRandomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
  }
}
