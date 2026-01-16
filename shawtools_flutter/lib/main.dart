import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/services/http_service.dart';
import 'app/services/language_service.dart';
import 'app/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 禁止横屏，只支持竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 初始化服务
  await Get.putAsync(() => ThemeService.init());
  await Get.putAsync(() => LanguageService.init());
  await Get.putAsync(() => HttpService.init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Obx(
      () => GetMaterialApp(
        title: 'Shaw Tools',
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        theme: themeService.themeData,
        locale: Get.find<LanguageService>().language == 'en'
            ? const Locale('en', 'US')
            : const Locale('zh', 'CN'),
        fallbackLocale: const Locale('zh', 'CN'),
        translations: _AppTranslations(),
        builder: (context, child) {
          // 全局点击空白处收起键盘
          return GestureDetector(
            onTap: () {
              // 点击空白处收起键盘
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                currentFocus.focusedChild?.unfocus();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: child,
          );
        },
      ),
    );
  }
}

class _AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': {'home': '首页', 'search': '搜索'},
    'en_US': {'home': 'Home', 'search': 'Search'},
  };
}
