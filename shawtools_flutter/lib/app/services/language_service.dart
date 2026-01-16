import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends GetxService {
  static LanguageService get to => Get.find();

  final language = 'zh'.obs;
  final _languageKey = 'app_language';

  static Future<LanguageService> init() async {
    final service = LanguageService();
    await service._loadLanguage();
    return service;
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_languageKey) ?? 'zh';
    language.value = lang;
    _updateLocale(lang);
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
    _updateLocale(lang);
  }

  void _updateLocale(String lang) {
    if (lang == 'en') {
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      Get.updateLocale(const Locale('zh', 'CN'));
    }
  }

  void toggleLanguage() {
    final newLang = language.value == 'zh' ? 'en' : 'zh';
    setLanguage(newLang);
  }
}
