import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final _currentTheme = AppThemeType.purple.obs;
  final _themeKey = 'app_theme';

  AppThemeType get currentTheme => _currentTheme.value;

  static Future<ThemeService> init() async {
    final service = ThemeService();
    await service._loadTheme();
    return service;
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    // 处理旧主题索引迁移（移除 cyberpunk 和 modern 后）
    // 旧索引映射：0=purple, 1=cyberpunk(移除), 2=light, 3=modern(移除), 4=alipay, 5=wechat
    // 新索引映射：0=purple, 1=light, 2=alipay, 3=wechat
    final validThemes = AppThemeType.values;
    int validIndex = themeIndex;
    if (themeIndex == 1 || themeIndex == 3) {
      // 如果之前是 cyberpunk(1) 或 modern(3)，迁移到 purple(0)
      validIndex = 0;
    } else if (themeIndex == 4) {
      // alipay 从索引 4 变为 2
      validIndex = 2;
    } else if (themeIndex == 5) {
      // wechat 从索引 5 变为 3
      validIndex = 3;
    } else if (themeIndex == 2) {
      // light 保持索引 1
      validIndex = 1;
    }
    
    if (validIndex >= 0 && validIndex < validThemes.length) {
      _currentTheme.value = validThemes[validIndex];
    } else {
      _currentTheme.value = AppThemeType.purple;
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme.value = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    // 通知GetX更新主题
    Get.changeTheme(AppTheme.buildTheme(theme));
  }

  /// 获取当前主题的ThemeData
  ThemeData get themeData => AppTheme.buildTheme(_currentTheme.value);

  /// 切换主题（循环切换）
  void toggleTheme() {
    final themes = AppThemeType.values;
    final currentIndex = themes.indexOf(_currentTheme.value);
    final nextIndex = (currentIndex + 1) % themes.length;
    setTheme(themes[nextIndex]);
  }
}
