import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../data/tools_data.dart';
import '../../models/tool_model.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/dialog_utils.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HomeController _controller;
  int _lastSelectedIndex = 0; // 记录上次选择的页签索引

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();

    // 初始化时记录当前选择的页签
    final initialIndex = ToolsData.categories.indexWhere(
      (c) => c.key == _controller.selectedCategory.value,
    );
    _lastSelectedIndex = initialIndex >= 0 ? initialIndex : 0;

    _tabController = TabController(
      length: ToolsData.categories.length,
      vsync: this,
      initialIndex: _lastSelectedIndex,
    );
    _tabController.addListener(_onTabChanged);

    // 监听搜索变化
    ever(_controller.searchQuery, (query) {
      if (query.isNotEmpty) {
        // 搜索时切换到"全部"页签
        _switchToCategory('all');
      } else {
        // 取消搜索时回到上次选择的页签
        _switchToCategory(ToolsData.categories[_lastSelectedIndex].key);
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final category = ToolsData.categories[_tabController.index];
      _controller.setCategory(category.key);
      // 只有在非搜索状态下才更新上次选择的索引
      if (_controller.searchQuery.value.isEmpty) {
        _lastSelectedIndex = _tabController.index;
      }
    }
  }

  /// 切换到指定分类
  void _switchToCategory(String categoryKey) {
    final index = ToolsData.categories.indexWhere((c) => c.key == categoryKey);
    if (index >= 0 && _tabController.index != index) {
      _tabController.animateTo(index);
      _controller.setCategory(categoryKey);
      if (_controller.searchQuery.value.isEmpty) {
        _lastSelectedIndex = index;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final languageService = Get.find<LanguageService>();
    final themeService = Get.find<ThemeService>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _AppBar(
              languageService: languageService,
              themeService: themeService,
            ),

            // Search Bar
            Obx(
              () => _SearchBar(
                onChanged: _controller.setSearchQuery,
                language: languageService.language.value,
              ),
            ),

            // Animated TabBar
            _AnimatedTabBar(
              controller: _controller,
              languageService: languageService,
              tabController: _tabController,
            ),

            // TabBarView with tools
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: ToolsData.categories.map((category) {
                  return _ToolsGridView(
                    category: category.key,
                    controller: _controller,
                    language: languageService.language.value,
                    isTablet: isTablet,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// App Bar Widget
class _AppBar extends StatelessWidget {
  final LanguageService languageService;
  final ThemeService themeService;

  const _AppBar({required this.languageService, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final titleText = languageService.language.value == 'en'
                  ? 'Common Tools Panel'
                  : '常用工具面板';
              final desc = AppTheme.getThemeDescription(
                themeService.currentTheme,
                languageService.language.value,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    desc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              );
            }),
          ),
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
    );
  }
}

// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String language;

  const _SearchBar({required this.onChanged, required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: language == 'en' ? '🔍 Search tools...' : '🔍 搜索工具...',
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// Animated TabBar Widget
class _AnimatedTabBar extends StatelessWidget {
  final HomeController controller;
  final LanguageService languageService;
  final TabController tabController;

  const _AnimatedTabBar({
    required this.controller,
    required this.languageService,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        return TabBar(
          controller: tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          onTap: (index) {
            final category = ToolsData.categories[index];
            controller.setCategory(category.key);
          },
          tabs: ToolsData.categories.map((category) {
            final count = controller.getCategoryCount(category.key);
            final isSelected =
                controller.selectedCategory.value == category.key;
            return Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.getName(languageService.language.value)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

// Tools Grid View Widget
class _ToolsGridView extends StatelessWidget {
  final String category;
  final HomeController controller;
  final String language;
  final bool isTablet;

  const _ToolsGridView({
    required this.category,
    required this.controller,
    required this.language,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 直接从所有工具中根据分类获取，而不是使用 filteredTools
      var tools = controller.getToolsByCategory(category);

      // 应用搜索过滤
      if (controller.searchQuery.value.isNotEmpty) {
        final query = controller.searchQuery.value.toLowerCase();
        tools = tools.where((tool) {
          final title = tool.getTitle(language).toLowerCase();
          final desc = tool.getDesc(language).toLowerCase();
          final keywords = tool.getKeywords(language).join(' ').toLowerCase();
          return title.contains(query) ||
              desc.contains(query) ||
              keywords.contains(query);
        }).toList();
      }

      if (tools.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey[400],
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                language == 'en' ? 'No tools found' : '未找到相关工具',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ],
          ),
        );
      }

      // 动态计算列数
      final screenWidth = MediaQuery.of(context).size.width;
      int crossAxisCount;
      double childAspectRatio;

      if (isTablet) {
        crossAxisCount = screenWidth > 800 ? 4 : 3;
        childAspectRatio = 0.9;
      } else {
        crossAxisCount = 2;
        childAspectRatio = 0.85;
      }

      return GridView.builder(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: isTablet ? 20 : 16,
          mainAxisSpacing: isTablet ? 20 : 16,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return _ToolCard(
            tool: tool,
            language: language,
            onTap: () => controller.navigateToTool(tool.route),
            index: index,
            isTablet: isTablet,
          );
        },
      );
    });
  }
}

// Tool Card Widget
class _ToolCard extends StatefulWidget {
  final ToolModel tool;
  final String language;
  final VoidCallback onTap;
  final int index;
  final bool isTablet;

  const _ToolCard({
    required this.tool,
    required this.language,
    required this.onTap,
    required this.index,
    required this.isTablet,
  });

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child:
            Card(
                  elevation: _isPressed ? 2 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).cardColor,
                          Theme.of(context).cardColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background decoration
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon and Rating
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: widget.isTablet ? 56 : 48,
                                    height: widget.isTablet ? 56 : 48,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).primaryColor
                                                .withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.tool.icon,
                                          style: TextStyle(
                                            fontSize: widget.isTablet ? 28 : 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: _buildRating(widget.tool.rating),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: widget.isTablet ? 16 : 12),
                              // Title
                              Text(
                                widget.tool.getTitle(widget.language),
                                style: TextStyle(
                                  fontSize: widget.isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: widget.isTablet ? 10 : 8),
                              // Description
                              Flexible(
                                child: Text(
                                  widget.tool.getDesc(widget.language),
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 13 : 12,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: widget.isTablet ? 10 : 8),
                              // Category Badge and Arrow
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).primaryColor
                                                .withValues(alpha: 0.15),
                                            Theme.of(context).primaryColor
                                                .withValues(alpha: 0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        ToolsData.categories
                                            .firstWhere(
                                              (c) =>
                                                  c.key == widget.tool.category,
                                            )
                                            .getName(widget.language),
                                        style: TextStyle(
                                          fontSize: widget.isTablet ? 11 : 10,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: (widget.index * 50).ms)
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 400.ms,
                  delay: (widget.index * 50).ms,
                  curve: Curves.easeOutCubic,
                )
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  delay: (widget.index * 50).ms,
                  curve: Curves.easeOutCubic,
                ),
      ),
    );
  }

  Widget _buildRating(int rating) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      alignment: WrapAlignment.end,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 12,
          color: Colors.amber,
        ),
      ),
    );
  }
}
