import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/language_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import 'getx_dialog_utils.dart';

/// 对话框工具类
/// 提供语言选择和主题选择的公共弹窗
class DialogUtils {
  /// 显示语言选择对话框
  static void showLanguageDialog(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    final current = languageService.language.value;

    GetXDialogUtils.showBottomSheet<void>(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current == 'en' ? 'Select Language' : '选择语言',
              style: Get.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('简体中文'),
              subtitle: const Text('界面显示为中文'),
              trailing: current == 'zh'
                  ? Icon(Icons.check_circle, color: Get.theme.primaryColor)
                  : null,
              onTap: () {
                languageService.setLanguage('zh');
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              subtitle: const Text('Display interface in English'),
              trailing: current == 'en'
                  ? Icon(Icons.check_circle, color: Get.theme.primaryColor)
                  : null,
              onTap: () {
                languageService.setLanguage('en');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示主题选择对话框
  static void showThemeDialog(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final languageService = Get.find<LanguageService>();
    final currentTheme = themeService.currentTheme;
    final language = languageService.language.value;
    final themes = AppTheme.allThemes;

    GetXDialogUtils.showBottomSheet(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language == 'en' ? 'Select Theme' : '选择主题',
              style: Get.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final type = themes[index];
                  final name = AppTheme.getThemeName(type, language);
                  final desc = AppTheme.getThemeDescription(type, language);
                  final config = AppTheme.getTheme(type);
                  final primary = config.primary;
                  final secondary = config.secondary;
                  final selected = type == currentTheme;
                  return ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: secondary.withValues(alpha: 0.15),
                        border: Border.all(
                          color: secondary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(child: Icon(Icons.palette, color: primary)),
                    ),
                    title: Text(
                      name,
                      style: Get.theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(desc, style: Get.theme.textTheme.bodySmall),
                    trailing: selected
                        ? Icon(
                            Icons.check_circle,
                            color: Get.theme.primaryColor,
                          )
                        : null,
                    onTap: () {
                      themeService.setTheme(type);
                      Get.back();
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemCount: themes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
