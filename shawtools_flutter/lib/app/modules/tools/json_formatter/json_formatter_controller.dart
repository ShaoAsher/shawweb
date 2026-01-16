import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class JsonFormatterController extends GetxController {
  final inputController = TextEditingController();
  final formattedJson = ''.obs;
  final error = ''.obs;
  final isValid = false.obs;
  final inputStats = RxMap<String, int>({});
  final outputStats = RxMap<String, int>({});

  @override
  void onInit() {
    super.onInit();
    inputController.addListener(_onInputChanged);
  }

  @override
  void onClose() {
    inputController.removeListener(_onInputChanged);
    inputController.dispose();
    super.onClose();
  }

  void _onInputChanged() {
    // 实时验证
    final input = inputController.text.trim();
    if (input.isEmpty) {
      isValid.value = false;
      error.value = '';
      formattedJson.value = '';
      inputStats.clear();
      outputStats.clear();
      return;
    }

    try {
      jsonDecode(input);
      isValid.value = true;
      error.value = '';
      _updateStats();
    } catch (e) {
      isValid.value = false;
      error.value = e.toString();
    }
  }

  void formatJson() {
    final input = inputController.text.trim();
    if (input.isEmpty) {
      error.value = '请输入 JSON 内容';
      formattedJson.value = '';
      return;
    }

    try {
      final parsed = jsonDecode(input);
      final encoder = JsonEncoder.withIndent('  ');
      formattedJson.value = encoder.convert(parsed);
      error.value = '';
      isValid.value = true;
      _updateStats();
    } catch (e) {
      error.value = 'JSON 格式错误：${e.toString()}';
      formattedJson.value = '';
      isValid.value = false;
    }
  }

  void compressJson() {
    final input = inputController.text.trim();
    if (input.isEmpty) {
      error.value = '请输入 JSON 内容';
      formattedJson.value = '';
      return;
    }

    try {
      final parsed = jsonDecode(input);
      final compressed = jsonEncode(parsed);
      inputController.text = compressed;
      formattedJson.value = compressed;
      error.value = '';
      isValid.value = true;
      _updateStats();
    } catch (e) {
      error.value = 'JSON 格式错误：${e.toString()}';
      formattedJson.value = '';
      isValid.value = false;
    }
  }

  void clearInput() {
    inputController.clear();
    formattedJson.value = '';
    error.value = '';
    isValid.value = false;
    inputStats.clear();
    outputStats.clear();
  }

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      inputController.text = data.text!;
      formatJson();
    }
  }

  void validateJson() {
    final input = inputController.text.trim();
    if (input.isEmpty) {
      error.value = '请输入 JSON 内容';
      isValid.value = false;
      return;
    }

    try {
      jsonDecode(input);
      isValid.value = true;
      error.value = '';
      _updateStats();
    } catch (e) {
      isValid.value = false;
      error.value = 'JSON 格式错误：${e.toString()}';
    }
  }

  Future<void> copyResult() async {
    if (formattedJson.value.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: formattedJson.value));
  }

  void _updateStats() {
    final input = inputController.text;
    final output = formattedJson.value;

    inputStats.value = {
      'chars': input.length,
      'lines': input.split('\n').length,
    };

    if (output.isNotEmpty) {
      outputStats.value = {
        'chars': output.length,
        'lines': output.split('\n').length,
      };
    }
  }

  dynamic getParsedJson() {
    if (formattedJson.value.isEmpty) return null;
    try {
      return jsonDecode(formattedJson.value);
    } catch (e) {
      return null;
    }
  }
}
