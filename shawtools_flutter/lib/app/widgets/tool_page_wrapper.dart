import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/tools_data.dart';
import '../services/language_service.dart';
import '../utils/dialog_utils.dart';

class ToolPageWrapper extends StatelessWidget {
  final String title;
  final String titleEn;
  final Widget child;
  final List<Widget>? actions;

  const ToolPageWrapper({
    super.key,
    required this.title,
    required this.titleEn,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(languageService.language.value == 'en' ? titleEn : title),
        ),
        actions: [
          ...?actions,
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => DialogUtils.showLanguageDialog(context),
            tooltip: languageService.language.value == 'en'
                ? '切换中文'
                : 'Switch to English',
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => DialogUtils.showThemeDialog(context),
            tooltip: '切换主题',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final lang = languageService.language.value;
                  final routeName =
                      ModalRoute.of(context)?.settings.name ?? Get.currentRoute;
                  String? desc;
                  final tool = ToolsData.tools.firstWhere(
                    (t) => t.route == routeName,
                    orElse: () => ToolsData.tools.firstWhere(
                      (t) =>
                          t.getTitle(lang) == (lang == 'en' ? titleEn : title),
                      orElse: () => ToolsData.tools.first,
                    ),
                  );
                  if (tool.route == routeName ||
                      tool.getTitle(lang) == (lang == 'en' ? titleEn : title)) {
                    desc = tool.getDesc(lang);
                  }
                  return Text(
                    desc ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
