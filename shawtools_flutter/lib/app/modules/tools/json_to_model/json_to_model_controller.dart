import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/toast_utils.dart';

// 用于在生成成功后触发弹窗的回调
typedef OnGenerateSuccess = void Function();

enum ModelLanguage {
  swift('Swift'),
  oc('Objective-C'),
  dart('Dart'),
  kotlin('Kotlin'),
  java('Java'),
  vue('Vue/TypeScript'),
  typescript('TypeScript'),
  python('Python'),
  php('PHP'),
  go('Go');

  final String label;
  const ModelLanguage(this.label);
}

class JsonToModelController extends GetxController {
  final jsonInputController = TextEditingController();
  final classNameController = TextEditingController(text: 'Model');
  final generatedCode = ''.obs;
  final selectedLanguage = ModelLanguage.dart.obs;
  final useNullSafety = true.obs;
  final useCamelCase = true.obs;
  final addComments = false.obs;
  final hasOutput = false.obs;

  // 生成成功后的回调
  OnGenerateSuccess? onGenerateSuccess;

  @override
  void onClose() {
    jsonInputController.dispose();
    classNameController.dispose();
    super.onClose();
  }

  /// 设置语言
  void setLanguage(ModelLanguage language) {
    selectedLanguage.value = language;
    // 切换语言后，清除之前的输出，需要用户手动点击生成
    if (hasOutput.value) {
      generatedCode.value = '';
      hasOutput.value = false;
    }
  }

  /// 加载示例
  void loadExample() {
    final example = {
      "id": 1001,
      "name": "张三",
      "age": 25,
      "email": "zhangsan@example.com",
      "isActive": true,
      "address": {"city": "北京", "street": "中关村大街", "zipCode": "100000"},
      "hobbies": ["阅读", "编程", "旅行"],
      "metadata": null,
    };
    jsonInputController.text = const JsonEncoder.withIndent(
      '  ',
    ).convert(example);
  }

  /// 清空输入
  void clearInput() {
    jsonInputController.clear();
    generatedCode.value = '';
    hasOutput.value = false;
  }

  /// 生成 Model
  void generateModel() {
    final jsonInput = jsonInputController.text.trim();
    final className = classNameController.text.trim().isEmpty
        ? 'Model'
        : classNameController.text.trim();

    if (jsonInput.isEmpty) {
      ToastUtils.showError('请输入 JSON 数据');
      return;
    }

    try {
      final jsonObj = jsonDecode(jsonInput);
      final code = _generateCode(jsonObj, className);
      generatedCode.value = code;
      hasOutput.value = true;
      // 生成成功后触发回调，用于显示弹窗
      onGenerateSuccess?.call();
    } catch (e) {
      ToastUtils.showError('JSON 格式错误：${e.toString()}');
      generatedCode.value = '';
      hasOutput.value = false;
    }
  }

  /// 复制生成的代码
  Future<void> copyCode() async {
    if (generatedCode.value.isEmpty) {
      ToastUtils.showError('没有可复制的代码');
      return;
    }
    try {
      await Clipboard.setData(ClipboardData(text: generatedCode.value));
      ToastUtils.showSuccess('代码已复制到剪贴板');
    } catch (e) {
      ToastUtils.showError('复制失败：${e.toString()}');
    }
  }

  /// 生成代码
  String _generateCode(dynamic jsonObj, String className) {
    switch (selectedLanguage.value) {
      case ModelLanguage.swift:
        return _generateSwift(jsonObj, className);
      case ModelLanguage.oc:
        return _generateOC(jsonObj, className);
      case ModelLanguage.dart:
        return _generateDart(jsonObj, className);
      case ModelLanguage.kotlin:
        return _generateKotlin(jsonObj, className);
      case ModelLanguage.java:
        return _generateJava(jsonObj, className);
      case ModelLanguage.vue:
      case ModelLanguage.typescript:
        return _generateTypeScript(jsonObj, className);
      case ModelLanguage.python:
        return _generatePython(jsonObj, className);
      case ModelLanguage.php:
        return _generatePHP(jsonObj, className);
      case ModelLanguage.go:
        return _generateGo(jsonObj, className);
    }
  }

  /// 转换为驼峰命名
  String _toCamelCase(String str) {
    if (!useCamelCase.value) return str;
    return str
        .replaceAllMapped(
          RegExp(r'_([a-z])'),
          (match) => match.group(1)!.toUpperCase(),
        )
        .replaceFirstMapped(
          RegExp(r'^[A-Z]'),
          (match) => match.group(0)!.toLowerCase(),
        );
  }

  /// 转换为帕斯卡命名
  String _toPascalCase(String str) {
    final camel = _toCamelCase(str);
    return camel.replaceFirstMapped(
      RegExp(r'^[a-z]'),
      (match) => match.group(0)!.toUpperCase(),
    );
  }

  /// 获取 Dart 类型
  String _getDartType(dynamic value) {
    if (value == null) return 'String';
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is double || value is num) return 'double';
    if (value is bool) return 'bool';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      return 'List<dynamic>';
    }
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  /// 生成 Dart Model
  String _generateDart(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final nullSafety = useNullSafety.value ? '?' : '';
    final pascalClassName = _toPascalCase(className);
    final buffer = StringBuffer();

    buffer.writeln("import 'dart:convert';");
    buffer.writeln();

    if (addComments.value) {
      buffer.writeln('/// $pascalClassName Model');
    }

    buffer.writeln('class $pascalClassName {');

    final properties = <String>[];
    final constructorParams = <String>[];
    final fromJsonBody = <String>[];
    final toJsonBody = <String>[];

    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toCamelCase(key);
      final type = _getDartType(value);

      if (addComments.value) {
        properties.add('  /// $key\n  final $type$nullSafety $propName;');
      } else {
        properties.add('  final $type$nullSafety $propName;');
      }

      constructorParams.add('this.$propName');

      if (useNullSafety.value) {
        fromJsonBody.add("    $propName: json['$key'],");
      } else {
        final defaultValue = type == 'String'
            ? "''"
            : type == 'int'
            ? '0'
            : type == 'double'
            ? '0.0'
            : type == 'bool'
            ? 'false'
            : 'null';
        fromJsonBody.add("    $propName: json['$key'] ?? $defaultValue,");
      }

      toJsonBody.add("      '$key': $propName,");
    }

    buffer.writeln(properties.join('\n\n'));
    buffer.writeln();
    buffer.writeln('  $pascalClassName({${constructorParams.join(', ')}});');
    buffer.writeln();
    buffer.writeln(
      '  factory $pascalClassName.fromJson(Map<String, dynamic> json) {',
    );
    buffer.writeln('    return $pascalClassName(');
    if (fromJsonBody.isNotEmpty) {
      buffer.writeln(fromJsonBody.join(',\n'));
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() => {');
    buffer.writeln(toJsonBody.join('\n'));
    buffer.writeln('  };');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// 生成 Swift Model
  String _generateSwift(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final buffer = StringBuffer();
    final pascalClassName = _toPascalCase(className);

    buffer.writeln('import Foundation');
    buffer.writeln();

    if (addComments.value) {
      buffer.writeln('/// $pascalClassName Model');
    }

    // 检查是否需要 CodingKeys
    final needsCodingKeys = obj.keys.any((key) {
      final propName = _toCamelCase(key.toString());
      return key.toString() != propName;
    });

    if (needsCodingKeys) {
      buffer.writeln('struct $pascalClassName: Codable {');
      buffer.writeln('    enum CodingKeys: String, CodingKey {');
      final keys = <String>[];
      for (final entry in obj.entries) {
        final key = entry.key.toString();
        final propName = _toCamelCase(key);
        if (key != propName) {
          keys.add('        case $propName = "$key"');
        } else {
          keys.add('        case $propName');
        }
      }
      buffer.writeln(keys.join('\n'));
      buffer.writeln('    }');
      buffer.writeln();
    } else {
      buffer.writeln('struct $pascalClassName: Codable {');
    }

    final properties = <String>[];
    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toCamelCase(key);
      String type;
      if (value == null) {
        type = 'String?';
      } else if (value is String) {
        type = 'String';
      } else if (value is int) {
        type = 'Int';
      } else if (value is double || value is num) {
        type = 'Double';
      } else if (value is bool) {
        type = 'Bool';
      } else if (value is List) {
        type = '[Any]';
      } else if (value is Map) {
        type = '[String: Any]';
      } else {
        type = 'Any';
      }

      if (addComments.value) {
        properties.add('    /// $key\n    let $propName: $type');
      } else {
        properties.add('    let $propName: $type');
      }
    }

    buffer.writeln(properties.join('\n\n'));
    buffer.writeln('}');

    return buffer.toString();
  }

  /// 生成 Objective-C Model
  String _generateOC(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final buffer = StringBuffer();
    final headerName = _toPascalCase(className);

    // Header
    buffer.writeln('//');
    buffer.writeln('// $headerName.h');
    buffer.writeln('//');
    buffer.writeln();
    buffer.writeln('#import <Foundation/Foundation.h>');
    buffer.writeln();

    if (addComments.value) {
      buffer.writeln('/**');
      buffer.writeln(' * $headerName Model');
      buffer.writeln(' */');
    }

    buffer.writeln('@interface $headerName : NSObject');
    buffer.writeln();

    final properties = <String>[];
    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toCamelCase(key);
      String type = 'NSString *';
      if (value is num) type = 'NSNumber *';
      if (value is bool) type = 'NSNumber *';
      if (value is List) type = 'NSArray *';
      if (value is Map) type = 'NSDictionary *';

      if (addComments.value) {
        properties.add(
          '/** $key */\n@property (nonatomic, strong) $type$propName;',
        );
      } else {
        properties.add('@property (nonatomic, strong) $type$propName;');
      }
    }

    buffer.writeln(properties.join('\n\n'));
    buffer.writeln();
    buffer.writeln('@end');
    buffer.writeln();
    buffer.writeln();

    // Implementation
    buffer.writeln('//');
    buffer.writeln('// $headerName.m');
    buffer.writeln('//');
    buffer.writeln();
    buffer.writeln('#import "$headerName.h"');
    buffer.writeln();
    buffer.writeln('@implementation $headerName');
    buffer.writeln();
    buffer.writeln('@end');

    return buffer.toString();
  }

  /// 生成 Kotlin Model
  String _generateKotlin(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final buffer = StringBuffer();
    final pascalClassName = _toPascalCase(className);

    buffer.writeln('data class $pascalClassName(');

    final properties = <String>[];
    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toCamelCase(key);
      String type;
      if (value is String) {
        type = 'String';
      } else if (value is int) {
        type = 'Int';
      } else if (value is double || value is num) {
        type = 'Double';
      } else if (value is bool) {
        type = 'Boolean';
      } else if (value is List) {
        type = 'List<Any>';
      } else if (value is Map) {
        type = 'Map<String, Any>';
      } else {
        type = 'Any';
      }

      if (addComments.value) {
        properties.add('    // $key\n    val $propName: $type?');
      } else {
        properties.add('    val $propName: $type?');
      }
    }

    buffer.writeln(properties.join(',\n\n'));
    buffer.writeln(')');

    return buffer.toString();
  }

  /// 生成 Java Model
  String _generateJava(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final buffer = StringBuffer();
    final javaClassName = _toPascalCase(className);

    buffer.writeln('public class $javaClassName {');
    buffer.writeln();

    final properties = <String>[];
    final getters = <String>[];
    final setters = <String>[];

    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toCamelCase(key);
      String type;
      if (value is String) {
        type = 'String';
      } else if (value is int) {
        type = 'Integer';
      } else if (value is double || value is num) {
        type = 'Double';
      } else if (value is bool) {
        type = 'Boolean';
      } else if (value is List) {
        type = 'List<Object>';
      } else if (value is Map) {
        type = 'Map<String, Object>';
      } else {
        type = 'Object';
      }

      if (addComments.value) {
        properties.add('    /** $key */\n    private $type $propName;');
      } else {
        properties.add('    private $type $propName;');
      }

      final getterName = 'get${_toPascalCase(propName)}';
      final setterName = 'set${_toPascalCase(propName)}';
      getters.add(
        '    public $type $getterName() {\n        return $propName;\n    }',
      );
      setters.add(
        '    public void $setterName($type $propName) {\n        this.$propName = $propName;\n    }',
      );
    }

    buffer.writeln(properties.join('\n\n'));
    buffer.writeln();
    buffer.writeln(getters.join('\n\n'));
    buffer.writeln();
    buffer.writeln(setters.join('\n\n'));
    buffer.writeln('}');

    return buffer.toString();
  }

  /// 生成 TypeScript Model
  String _generateTypeScript(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final buffer = StringBuffer();
    final pascalClassName = _toPascalCase(className);

    if (addComments.value) {
      buffer.writeln('/**');
      buffer.writeln(' * $pascalClassName Model');
      buffer.writeln(' */');
    }

    buffer.writeln('export interface $pascalClassName {');

    final properties = <String>[];
    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toCamelCase(key);
      String type;
      if (value is String) {
        type = 'string';
      } else if (value is num) {
        type = 'number';
      } else if (value is bool) {
        type = 'boolean';
      } else if (value is List) {
        if (value.isNotEmpty) {
          final item = value[0];
          if (item is String) {
            type = 'string[]';
          } else if (item is num) {
            type = 'number[]';
          } else {
            type = 'any[]';
          }
        } else {
          type = 'any[]';
        }
      } else if (value is Map) {
        type = 'any';
      } else {
        type = 'any';
      }

      if (addComments.value) {
        properties.add('  /** $key */\n  ${propName}?: $type;');
      } else {
        properties.add('  ${propName}?: $type;');
      }
    }

    buffer.writeln(properties.join('\n\n'));
    buffer.writeln('}');

    return buffer.toString();
  }

  /// 生成 Python Model
  String _generatePython(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final buffer = StringBuffer();
    final pascalClassName = _toPascalCase(className);

    buffer.writeln('from typing import Optional, List, Dict, Any');
    buffer.writeln('from dataclasses import dataclass');
    buffer.writeln();

    if (addComments.value) {
      buffer.writeln('# $pascalClassName Model');
    }

    buffer.writeln('@dataclass');
    buffer.writeln('class $pascalClassName:');

    final properties = <String>[];
    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toCamelCase(key);
      String type;
      if (value is String) {
        type = 'str';
      } else if (value is int) {
        type = 'int';
      } else if (value is double || value is num) {
        type = 'float';
      } else if (value is bool) {
        type = 'bool';
      } else if (value is List) {
        type = 'List[Any]';
      } else if (value is Map) {
        type = 'Dict[str, Any]';
      } else {
        type = 'Any';
      }

      if (addComments.value) {
        properties.add('    # $key\n    $propName: Optional[$type] = None');
      } else {
        properties.add('    $propName: Optional[$type] = None');
      }
    }

    buffer.writeln(properties.join('\n\n'));

    return buffer.toString();
  }

  /// 生成 PHP Model
  String _generatePHP(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final buffer = StringBuffer();
    final phpClassName = _toPascalCase(className);

    buffer.writeln('<?php');
    buffer.writeln();

    if (addComments.value) {
      buffer.writeln('/**');
      buffer.writeln(' * $phpClassName Model');
      buffer.writeln(' */');
    }

    buffer.writeln('class $phpClassName');
    buffer.writeln('{');

    final properties = <String>[];
    final getters = <String>[];
    final setters = <String>[];
    final fromArrayBody = <String>[];
    final toArrayBody = <String>[];

    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toCamelCase(key);
      String type;
      String docType;
      if (value is String) {
        type = 'string';
        docType = 'string';
      } else if (value is int) {
        type = 'int';
        docType = 'int';
      } else if (value is double || value is num) {
        type = 'float';
        docType = 'float';
      } else if (value is bool) {
        type = 'bool';
        docType = 'bool';
      } else if (value is List || value is Map) {
        type = 'array';
        docType = 'array';
      } else {
        type = 'mixed';
        docType = 'mixed';
      }

      if (addComments.value) {
        properties.add('    /**');
        properties.add('     * $key');
        properties.add('     * @var $docType');
        properties.add('     */');
        properties.add('    private \$$propName;');
      } else {
        properties.add('    private \$$propName;');
      }

      final getterName = 'get${_toPascalCase(propName)}';
      final setterName = 'set${_toPascalCase(propName)}';
      getters.add('    /**');
      getters.add('     * @return $docType');
      getters.add('     */');
      getters.add('    public function $getterName(): $type');
      getters.add('    {');
      getters.add('        return \$this->$propName;');
      getters.add('    }');

      setters.add('    /**');
      setters.add('     * @param $docType \$$propName');
      setters.add('     * @return \$this');
      setters.add('     */');
      setters.add('    public function $setterName(\$$propName): self');
      setters.add('    {');
      setters.add('        \$this->$propName = \$$propName;');
      setters.add('        return \$this;');
      setters.add('    }');

      fromArrayBody.add("        \$this->$propName = \$data['$key'] ?? null;");
      toArrayBody.add("            '$key' => \$this->$propName,");
    }

    buffer.writeln(properties.join('\n\n'));
    buffer.writeln();
    buffer.writeln(getters.join('\n\n'));
    buffer.writeln();
    buffer.writeln(setters.join('\n\n'));
    buffer.writeln();
    buffer.writeln('    /**');
    buffer.writeln('     * 从数组创建对象');
    buffer.writeln('     * @param array \$data');
    buffer.writeln('     * @return $phpClassName');
    buffer.writeln('     */');
    buffer.writeln('    public static function fromArray(array \$data): self');
    buffer.writeln('    {');
    buffer.writeln('        \$instance = new self();');
    buffer.writeln(fromArrayBody.join('\n'));
    buffer.writeln('        return \$instance;');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    /**');
    buffer.writeln('     * 转换为数组');
    buffer.writeln('     * @return array');
    buffer.writeln('     */');
    buffer.writeln('    public function toArray(): array');
    buffer.writeln('    {');
    buffer.writeln('        return [');
    buffer.writeln(toArrayBody.join('\n'));
    buffer.writeln('        ];');
    buffer.writeln('    }');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// 生成 Go Model
  String _generateGo(dynamic obj, String className) {
    if (obj is! Map) {
      throw Exception('JSON 必须是对象类型');
    }

    final buffer = StringBuffer();
    final goStructName = _toPascalCase(className);

    buffer.writeln('package model');
    buffer.writeln();

    if (addComments.value) {
      buffer.writeln('// ${goStructName} Model');
    }

    buffer.writeln('type ${goStructName} struct {');

    final properties = <String>[];
    for (final entry in obj.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      final propName = _toPascalCase(_toCamelCase(key));
      String type;
      if (value is String) {
        type = 'string';
      } else if (value is int) {
        type = 'int';
      } else if (value is double || value is num) {
        type = 'float64';
      } else if (value is bool) {
        type = 'bool';
      } else if (value is List) {
        if (value.isNotEmpty) {
          final item = value[0];
          if (item is String) {
            type = '[]string';
          } else if (item is num) {
            type = '[]interface{}';
          } else {
            type = '[]interface{}';
          }
        } else {
          type = '[]interface{}';
        }
      } else if (value is Map) {
        type = 'map[string]interface{}';
      } else {
        type = 'interface{}';
      }

      if (addComments.value) {
        properties.add('    // $key\n    $propName $type `json:"$key"`');
      } else {
        properties.add('    $propName $type `json:"$key"`');
      }
    }

    buffer.writeln(properties.join('\n\n'));
    buffer.writeln('}');

    return buffer.toString();
  }
}
