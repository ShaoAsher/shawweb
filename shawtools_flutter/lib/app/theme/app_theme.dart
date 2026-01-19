import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/theme_service.dart';

/// 应用主题枚举
enum AppThemeType {
  purple, // 优雅紫色
  light, // 清新蓝色
  alipay, // 支付宝蓝
  wechat, // 微信绿
}

/// 主题配置数据类
class ThemeConfig {
  final String nameZh;
  final String nameEn;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color textSecondary;
  final Color textLight;
  final Color border;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  const ThemeConfig({
    required this.nameZh,
    required this.nameEn,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.textSecondary,
    required this.textLight,
    required this.border,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });
}

/// 应用主题配置类
/// 提供完整的主题配置，支持4套渐变主题切换
class AppTheme {
  // ========== 主题配置 ==========
  static const Map<AppThemeType, ThemeConfig> _themes = {
    // 优雅紫色 - Instagram风格渐变
    AppThemeType.purple: ThemeConfig(
      nameZh: '优雅紫色',
      nameEn: 'Elegant Purple',
      primary: Color(0xFF667EEA), // 主色：优雅蓝紫色
      primaryDark: Color(0xFF764BA2), // 渐变终点：深紫色
      secondary: Color(0xFF8B5CF6), // 辅助色：亮紫色
      background: Color(0xFFF5F7FA), // 背景：浅灰蓝
      surface: Color(0xFFFFFFFF), // 表面：纯白
      surfaceAlt: Color(0xFFF8F9FA), // 备用表面：极浅灰
      text: Color(0xFF2D3748), // 文本：深灰蓝
      textSecondary: Color(0xFF718096), // 次要文本：中灰
      textLight: Color(0xFFADB5BD), // 浅文本：浅灰
      border: Color(0xFFE9ECEF), // 边框：浅灰
      success: Color(0xFF10B981), // 成功：翠绿
      error: Color(0xFFEF4444), // 错误：鲜红
      warning: Color(0xFFF59E0B), // 警告：橙色
      info: Color(0xFF3B82F6), // 信息：蓝色
    ),
    // 清新蓝色 - Facebook/Twitter风格渐变
    AppThemeType.light: ThemeConfig(
      nameZh: '清新蓝色',
      nameEn: 'Fresh Blue',
      primary: Color(0xFF3B82F6), // 主色：清新蓝
      primaryDark: Color(0xFF2563EB), // 渐变终点：深蓝
      secondary: Color(0xFF60A5FA), // 辅助色：亮蓝
      background: Color(0xFFF8FAFC), // 背景：极浅蓝灰
      surface: Color(0xFFFFFFFF), // 表面：纯白
      surfaceAlt: Color(0xFFF1F5F9), // 备用表面：浅蓝灰
      text: Color(0xFF0F172A), // 文本：深蓝黑
      textSecondary: Color(0xFF475569), // 次要文本：中蓝灰
      textLight: Color(0xFF94A3B8), // 浅文本：浅蓝灰
      border: Color(0xFFE2E8F0), // 边框：浅蓝灰
      success: Color(0xFF10B981), // 成功：翠绿
      error: Color(0xFFEF4444), // 错误：鲜红
      warning: Color(0xFFF59E0B), // 警告：橙色
      info: Color(0xFF3B82F6), // 信息：蓝色
    ),
    // 支付宝蓝 - 专业商务风格渐变
    AppThemeType.alipay: ThemeConfig(
      nameZh: '支付宝蓝',
      nameEn: 'Alipay Blue',
      primary: Color(0xFF1677FF), // 主色：支付宝蓝
      primaryDark: Color(0xFF0958D9), // 渐变终点：深蓝
      secondary: Color(0xFF4096FF), // 辅助色：亮蓝
      background: Color(0xFFE6F4FF), // 背景：浅蓝
      surface: Color(0xFFFFFFFF), // 表面：纯白
      surfaceAlt: Color(0xFFF0F9FF), // 备用表面：极浅蓝
      text: Color(0xFF1D39C4), // 文本：深蓝
      textSecondary: Color(0xFF597EF7), // 次要文本：中蓝
      textLight: Color(0xFFADC6FF), // 浅文本：浅蓝
      border: Color(0xFFD4E4F7), // 边框：浅蓝
      success: Color(0xFF52C41A), // 成功：支付宝绿
      error: Color(0xFFFF4D4F), // 错误：鲜红
      warning: Color(0xFFFAAD14), // 警告：金色
      info: Color(0xFF1677FF), // 信息：支付宝蓝
    ),
    // 微信绿 - 社交活力风格渐变
    AppThemeType.wechat: ThemeConfig(
      nameZh: '微信绿',
      nameEn: 'WeChat Green',
      primary: Color(0xFF07C160), // 主色：微信绿
      primaryDark: Color(0xFF06AD56), // 渐变终点：深绿
      secondary: Color(0xFF36D399), // 辅助色：亮绿
      background: Color(0xFFF0FDF4), // 背景：浅绿
      surface: Color(0xFFFFFFFF), // 表面：纯白
      surfaceAlt: Color(0xFFF0FDF4), // 备用表面：浅绿
      text: Color(0xFF166534), // 文本：深绿
      textSecondary: Color(0xFF16A34A), // 次要文本：中绿
      textLight: Color(0xFF86EFAC), // 浅文本：浅绿
      border: Color(0xFFBBF7D0), // 边框：浅绿
      success: Color(0xFF07C160), // 成功：微信绿
      error: Color(0xFFEF4444), // 错误：鲜红
      warning: Color(0xFFF59E0B), // 警告：橙色
      info: Color(0xFF576B95), // 信息：蓝灰
    ),
  };

  // ========== JSON 语法高亮颜色 ==========
  static const Map<String, Color> _jsonColors = {
      'key': Color(0xFF0969DA),
      'string': Color(0xFF0A3069),
      'number': Color(0xFF0550AE),
      'boolean': Color(0xFFCF222E),
      'null': Color(0xFF6E7781),
  };

  // ========== 主题描述 ==========
  static const Map<AppThemeType, Map<String, String>> _descriptions = {
    AppThemeType.purple: {
      'zh': '优雅紫色，Instagram风格渐变',
      'en': 'Elegant purple gradient, Instagram style',
    },
    AppThemeType.light: {
      'zh': '清新蓝色，Facebook/Twitter风格渐变',
      'en': 'Fresh blue gradient, Facebook/Twitter style',
    },
    AppThemeType.alipay: {
      'zh': '支付宝蓝，专业商务风格渐变',
      'en': 'Alipay blue gradient, professional business style',
    },
    AppThemeType.wechat: {
      'zh': '微信绿，社交活力风格渐变',
      'en': 'WeChat green gradient, social vitality style',
    },
  };

  // ========== 基础方法 ==========

  /// 获取主题配置
  static ThemeConfig getTheme(AppThemeType type) {
    return _themes[type] ?? _themes[AppThemeType.purple]!;
  }

  /// 获取所有主题列表
  static List<AppThemeType> get allThemes => AppThemeType.values;

  /// 获取主题名称（根据语言）
  static String getThemeName(AppThemeType type, String language) {
    final config = getTheme(type);
    return language == 'en' ? config.nameEn : config.nameZh;
  }

  /// 获取主题描述（根据语言）
  static String getThemeDescription(AppThemeType type, String language) {
    return _descriptions[type]?[language] ?? '';
  }

  // ========== 颜色获取方法 ==========

  static Color _getColor(
    AppThemeType type,
    Color Function(ThemeConfig) getter,
  ) {
    return getter(getTheme(type));
  }

  static Color getTextColor(AppThemeType type) =>
      _getColor(type, (c) => c.text);
  static Color getTextSecondaryColor(AppThemeType type) =>
      _getColor(type, (c) => c.textSecondary);
  static Color getTextLightColor(AppThemeType type) =>
      _getColor(type, (c) => c.textLight);
  static Color getBorderColor(AppThemeType type) =>
      _getColor(type, (c) => c.border);
  static Color getSurfaceColor(AppThemeType type) =>
      _getColor(type, (c) => c.surface);
  static Color getSurfaceAltColor(AppThemeType type) =>
      _getColor(type, (c) => c.surfaceAlt);
  static Color getSuccessColor(AppThemeType type) =>
      _getColor(type, (c) => c.success);
  static Color getErrorColor(AppThemeType type) =>
      _getColor(type, (c) => c.error);
  static Color getWarningColor(AppThemeType type) =>
      _getColor(type, (c) => c.warning);
  static Color getInfoColor(AppThemeType type) =>
      _getColor(type, (c) => c.info);

  // ========== JSON 语法高亮颜色 ==========

  static Color getJsonKeyColor(AppThemeType type) => _jsonColors['key']!;
  static Color getJsonStringColor(AppThemeType type) => _jsonColors['string']!;
  static Color getJsonNumberColor(AppThemeType type) => _jsonColors['number']!;
  static Color getJsonBooleanColor(AppThemeType type) => _jsonColors['boolean']!;
  static Color getJsonNullColor(AppThemeType type) => _jsonColors['null']!;

  // ========== ThemeData 构建 ==========

  /// 根据主题类型构建ThemeData
  static ThemeData buildTheme(AppThemeType themeType) {
    final config = getTheme(themeType);

    final colorScheme = ColorScheme.light(
      primary: config.primary,
      secondary: config.secondary,
      surface: config.surface,
      error: config.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: config.text,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: config.background,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: config.border, width: 1),
        ),
        color: config.surface,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: config.surface,
        foregroundColor: config.text,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: config.text,
        ),
        iconTheme: IconThemeData(color: config.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: config.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: config.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: config.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: config.primary, width: 2),
        ),
        hintStyle: TextStyle(color: config.textLight),
        labelStyle: TextStyle(color: config.textSecondary),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: config.text),
        displayMedium: TextStyle(color: config.text),
        displaySmall: TextStyle(color: config.text),
        headlineLarge: TextStyle(color: config.text),
        headlineMedium: TextStyle(color: config.text),
        headlineSmall: TextStyle(color: config.text),
        titleLarge: TextStyle(color: config.text),
        titleMedium: TextStyle(color: config.text),
        titleSmall: TextStyle(color: config.text),
        bodyLarge: TextStyle(color: config.text),
        bodyMedium: TextStyle(color: config.text),
        bodySmall: TextStyle(color: config.textSecondary),
        labelLarge: TextStyle(color: config.text),
        labelMedium: TextStyle(color: config.textSecondary),
        labelSmall: TextStyle(color: config.textLight),
      ),
      dividerTheme: DividerThemeData(
        color: config.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: config.text, size: 24),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: config.primary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: config.primary),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: config.primary,
        selectionColor: config.primary.withValues(alpha: 0.3),
        selectionHandleColor: config.primary,
      ),
    );
  }

  // ========== 便捷方法（使用BuildContext） ==========

  /// 从BuildContext获取当前主题类型
  static AppThemeType getCurrentThemeType(BuildContext context) {
    try {
      final themeService = Get.find<ThemeService>();
      return themeService.currentTheme;
    } catch (e) {
      return AppThemeType.purple;
    }
  }

  /// 获取文本颜色（使用BuildContext）
  static Color getTextColorFromContext(BuildContext context) =>
      getTextColor(getCurrentThemeType(context));

  /// 获取次要文本颜色（使用BuildContext）
  static Color getTextSecondaryColorFromContext(BuildContext context) =>
      getTextSecondaryColor(getCurrentThemeType(context));

  /// 获取浅色文本颜色（使用BuildContext）
  static Color getTextLightColorFromContext(BuildContext context) =>
      getTextLightColor(getCurrentThemeType(context));

  /// 获取边框颜色（使用BuildContext）
  static Color getBorderColorFromContext(BuildContext context) =>
      getBorderColor(getCurrentThemeType(context));

  /// 获取成功颜色（使用BuildContext）
  static Color getSuccessColorFromContext(BuildContext context) =>
      getSuccessColor(getCurrentThemeType(context));

  /// 获取错误颜色（使用BuildContext）
  static Color getErrorColorFromContext(BuildContext context) =>
      getErrorColor(getCurrentThemeType(context));

  /// 获取 JSON Key 颜色（使用BuildContext）
  static Color getJsonKeyColorFromContext(BuildContext context) =>
      getJsonKeyColor(getCurrentThemeType(context));

  /// 获取 JSON String 颜色（使用BuildContext）
  static Color getJsonStringColorFromContext(BuildContext context) =>
      getJsonStringColor(getCurrentThemeType(context));

  /// 获取 JSON Number 颜色（使用BuildContext）
  static Color getJsonNumberColorFromContext(BuildContext context) =>
      getJsonNumberColor(getCurrentThemeType(context));

  /// 获取 JSON Boolean 颜色（使用BuildContext）
  static Color getJsonBooleanColorFromContext(BuildContext context) =>
      getJsonBooleanColor(getCurrentThemeType(context));

  /// 获取 JSON Null 颜色（使用BuildContext）
  static Color getJsonNullColorFromContext(BuildContext context) =>
      getJsonNullColor(getCurrentThemeType(context));
}
