import 'package:get/get.dart';

import '../../data/tools_data.dart';
import '../../models/tool_model.dart';
import '../../services/language_service.dart';

class HomeController extends GetxController {
  final LanguageService _languageService = Get.find();

  final searchQuery = ''.obs;
  final selectedCategory = 'all'.obs;
  final _tools = RxList<ToolModel>(ToolsData.tools);

  List<ToolModel> get toolsList => _tools;
  String get currentLanguage => _languageService.language.value;

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  int getCategoryCount(String category) {
    if (category == 'all') return _tools.length;
    return _tools.where((tool) => tool.category == category).length;
  }

  /// 根据分类获取工具列表（不考虑搜索）
  List<ToolModel> getToolsByCategory(String category) {
    if (category == 'all') {
      return List<ToolModel>.from(_tools);
    }
    return _tools.where((tool) => tool.category == category).toList();
  }

  void navigateToTool(String route) {
    Get.toNamed(route);
  }
}
