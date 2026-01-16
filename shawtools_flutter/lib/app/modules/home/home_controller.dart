import 'package:get/get.dart';

import '../../data/tools_data.dart';
import '../../models/tool_model.dart';
import '../../services/language_service.dart';

class HomeController extends GetxController {
  final LanguageService _languageService = Get.find();

  final searchQuery = ''.obs;
  final selectedCategory = 'all'.obs;
  final _tools = RxList<ToolModel>(ToolsData.tools);
  final filteredTools = <ToolModel>[].obs;

  // 缓存每个分类的工具列表，避免重复计算
  final Map<String, List<ToolModel>> _categoryToolsCache = {};
  // 缓存每个分类的工具数量，避免重复计算
  final Map<String, int> _categoryCountCache = {};

  List<ToolModel> get toolsList => filteredTools;
  String get currentLanguage => _languageService.language.value;

  @override
  void onInit() {
    super.onInit();
    // 初始化时预加载所有分类的工具列表和数量
    _preloadCategoryTools();
    filteredTools.value = List.from(_tools);
    _updateFilteredTools();
  }

  /// 预加载所有分类的工具列表和数量
  void _preloadCategoryTools() {
    for (final category in ToolsData.categories) {
      if (category.key == 'all') {
        _categoryToolsCache[category.key] = List<ToolModel>.from(_tools);
        _categoryCountCache[category.key] = _tools.length;
      } else {
        final tools = _tools
            .where((tool) => tool.category == category.key)
            .toList();
        _categoryToolsCache[category.key] = tools;
        _categoryCountCache[category.key] = tools.length;
      }
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _updateFilteredTools();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _updateFilteredTools();
  }

  void _updateFilteredTools() {
    var result = List<ToolModel>.from(_tools);

    // 按分类过滤
    if (selectedCategory.value != 'all') {
      result = result
          .where((tool) => tool.category == selectedCategory.value)
          .toList();
    }

    // 按搜索关键词过滤
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((tool) {
        final title = tool.getTitle(currentLanguage).toLowerCase();
        final desc = tool.getDesc(currentLanguage).toLowerCase();
        final keywords = tool
            .getKeywords(currentLanguage)
            .join(' ')
            .toLowerCase();
        return title.contains(query) ||
            desc.contains(query) ||
            keywords.contains(query);
      }).toList();
    }

    filteredTools.value = result;
  }

  int getCategoryCount(String category) {
    // 从缓存中获取，避免重复计算
    return _categoryCountCache[category] ?? 0;
  }

  /// 根据分类获取工具列表（不考虑搜索）
  List<ToolModel> getToolsByCategory(String category) {
    // 从缓存中获取，避免重复计算
    return _categoryToolsCache[category] ?? [];
  }

  void navigateToTool(String route) {
    Get.toNamed(route);
  }
}
