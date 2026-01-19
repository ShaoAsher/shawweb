import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/writing_models.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/gradient_action_button.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'writing_assistant_controller.dart';

/// 写作助手主页
class WritingAssistantPage extends GetView<WritingAssistantController> {
  const WritingAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.currentBook.value != null) {
        return _BookDetailPage(controller: controller);
      }
      return _BookshelfPage(controller: controller);
    });
  }
}

/// 书架页面
class _BookshelfPage extends StatelessWidget {
  final WritingAssistantController controller;

  const _BookshelfPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ToolPageWrapper(
      title: '写作助手',
      titleEn: 'Writing Assistant',
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBookList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '我的书架',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GradientActionButton(
            icon: Icons.add,
            label: '新建书籍',
            onPressed: _showCreateBookDialog,
            color: Get.theme.primaryColor,
            isTablet: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    return Obx(() {
      if (controller.books.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 80, color: Get.theme.disabledColor),
              const SizedBox(height: 16),
              Text(
                '还没有创作任何作品',
                style: Get.theme.textTheme.titleMedium?.copyWith(
                  color: Get.theme.disabledColor,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showCreateBookDialog,
                icon: const Icon(Icons.add),
                label: const Text('创建第一本书'),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(Get.context!).size.width > 600 ? 3 : 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: controller.books.length,
        itemBuilder: (context, index) {
          final book = controller.books[index];
          return _buildBookCard(book);
        },
      );
    });
  }

  Widget _buildBookCard(Book book) {
    final stats = controller.getBookStats(book);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => controller.selectBook(book),
        onLongPress: () => _showBookMenu(book),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Get.theme.primaryColor,
                    Get.theme.primaryColor.withOpacity(0.6),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.menu_book,
                  size: 48,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            // 信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.author.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.book,
                          text: '${stats['chapters']}章',
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.edit,
                          text: '${stats['words']}字',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Get.theme.primaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: Get.theme.textTheme.bodySmall?.copyWith(
              color: Get.theme.primaryColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('新建书籍'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '书名',
                  hintText: '请输入书名',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: '作者',
                  hintText: '请输入作者名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '简介',
                  hintText: '请输入书籍简介',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                Get.snackbar('提示', '请输入书名');
                return;
              }
              controller.createBook(
                title: titleController.text.trim(),
                author: authorController.text.trim(),
                description: descController.text.trim(),
              );
              Get.back();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showBookMenu(Book book) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑信息'),
                onTap: () {
                  Get.back();
                  _showEditBookDialog(book);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Get.theme.colorScheme.error),
                title: Text(
                  '删除书籍',
                  style: TextStyle(color: Get.theme.colorScheme.error),
                ),
                onTap: () {
                  Get.back();
                  _confirmDeleteBook(book);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBookDialog(Book book) {
    final titleController = TextEditingController(text: book.title);
    final authorController = TextEditingController(text: book.author);
    final descController = TextEditingController(text: book.description);

    Get.dialog(
      AlertDialog(
        title: const Text('编辑书籍'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '书名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: '作者',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '简介',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              book.title = titleController.text.trim();
              book.author = authorController.text.trim();
              book.description = descController.text.trim();
              controller.updateBook(book);
              Get.back();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBook(Book book) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除《${book.title}》吗？此操作无法撤销。'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              controller.deleteBook(book.id);
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 书籍详情页
class _BookDetailPage extends StatefulWidget {
  final WritingAssistantController controller;

  const _BookDetailPage({required this.controller});

  @override
  State<_BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<_BookDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.controller.currentBook.value!.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.controller.currentBook.value = null;
            widget.controller.currentChapter.value = null;
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportDialog,
            tooltip: '导出',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '章节', icon: Icon(Icons.book)),
            Tab(text: '大纲', icon: Icon(Icons.list_alt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChaptersTab(controller: widget.controller),
          _OutlineTab(controller: widget.controller),
        ],
      ),
    );
  }

  void _showExportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('导出作品'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('导出为 TXT'),
              onTap: () {
                Get.back();
                _exportAsTxt();
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('导出为 Markdown'),
              onTap: () {
                Get.back();
                _exportAsMarkdown();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsTxt() async {
    // TODO: 实现 TXT 导出
    Get.snackbar('提示', 'TXT 导出功能开发中');
  }

  Future<void> _exportAsMarkdown() async {
    // TODO: 实现 Markdown 导出
    Get.snackbar('提示', 'Markdown 导出功能开发中');
  }
}

/// 章节列表标签页
class _ChaptersTab extends StatefulWidget {
  final WritingAssistantController controller;

  const _ChaptersTab({required this.controller});

  @override
  State<_ChaptersTab> createState() => _ChaptersTabState();
}

class _ChaptersTabState extends State<_ChaptersTab> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _expandedVolumes = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final book = widget.controller.currentBook.value!;

      return Column(
        children: [
          _buildHeader(book),
          Expanded(child: _buildVolumeList(book)),
        ],
      );
    });
  }

  Widget _buildHeader(Book book) {
    final stats = widget.controller.getBookStats(book);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats['volumes']} 卷 · ${stats['chapters']} 章',
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '总字数: ${stats['words']}',
                      style: Get.theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              GradientActionButton(
                icon: Icons.add,
                label: '新建卷',
                onPressed: _showAddVolumeDialog,
                color: Get.theme.primaryColor,
                isTablet: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeList(Book book) {
    if (book.volumes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Get.theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              '还没有创建分卷',
              style: Get.theme.textTheme.titleMedium?.copyWith(
                color: Get.theme.disabledColor,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _showAddVolumeDialog,
              icon: const Icon(Icons.add),
              label: const Text('创建第一卷'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: book.volumes.length,
      itemBuilder: (context, index) {
        final volume = book.volumes[index];
        return _buildVolumeCard(book, volume);
      },
    );
  }

  Widget _buildVolumeCard(Book book, Volume volume) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.primaryColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Get.theme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 卷标题头部
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.primaryColor.withOpacity(0.1),
                  Get.theme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: ExpansionTile(
              key: PageStorageKey<String>(volume.id),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: _expandedVolumes[volume.id] ?? true,
              onExpansionChanged: (expanded) {
                // 延迟到构建完成后再更新状态
                Future.microtask(() {
                  if (mounted) {
                    setState(() {
                      _expandedVolumes[volume.id] = expanded;
                    });
                  }
                });
              },
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Get.theme.primaryColor,
                          Get.theme.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '第${volume.order}卷',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      volume.title,
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${volume.chapters.length} 章 · 共 ${volume.chapters.fold<int>(0, (sum, ch) => sum + ch.words)} 字',
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.primaryColor,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showVolumeMenu(book, volume),
                tooltip: '更多操作',
              ),
              children: [
                // 章节列表
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      ...volume.chapters.map(
                        (chapter) => _buildChapterItem(book, volume, chapter),
                      ),
                      // 添加章节按钮
                      InkWell(
                        onTap: () => _showAddChapterDialog(book, volume),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Get.theme.primaryColor.withOpacity(0.2),
                              style: BorderStyle.solid,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Get.theme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '添加章节',
                                style: TextStyle(
                                  color: Get.theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterItem(Book book, Volume volume, Chapter chapter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 跳转到章节编辑页面
            Get.toNamed(Routes.writingChapterEditor, arguments: chapter);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 章节序号
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Get.theme.primaryColor.withOpacity(0.2),
                        Get.theme.primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Get.theme.primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${chapter.order}',
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 章节信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title,
                        style: Get.theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.text_fields,
                            size: 14,
                            color: Get.theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${chapter.words} 字',
                            style: Get.theme.textTheme.bodySmall?.copyWith(
                              color: Get.theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Get.theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MM-dd').format(chapter.updatedAt),
                            style: Get.theme.textTheme.bodySmall?.copyWith(
                              color: Get.theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 更多操作按钮
                IconButton(
                  icon: Icon(Icons.more_vert, color: Get.theme.disabledColor),
                  onPressed: () => _showChapterMenu(book, volume, chapter),
                  tooltip: '更多操作',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddVolumeDialog() {
    final titleController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('新建卷'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: '卷名',
            hintText: '请输入卷名',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              widget.controller.addVolume(
                widget.controller.currentBook.value!.id,
                titleController.text.trim(),
              );
              Get.back();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showEditVolumeDialog(Book book, Volume volume) {
    final titleController = TextEditingController(text: volume.title);

    Get.dialog(
      AlertDialog(
        title: const Text('编辑卷名'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: '卷名',
            hintText: '请输入卷名',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              widget.controller.updateVolume(
                book.id,
                volume.id,
                titleController.text.trim(),
              );
              Get.back();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddChapterDialog(Book book, Volume volume) {
    final titleController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('新建章节'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: '章节标题',
            hintText: '请输入章节标题',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              widget.controller.addChapter(
                book.id,
                volume.id,
                titleController.text.trim(),
              );
              Get.back();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showEditChapterDialog(Book book, Volume volume, Chapter chapter) {
    final titleController = TextEditingController(text: chapter.title);

    Get.dialog(
      AlertDialog(
        title: const Text('编辑章节名'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: '章节标题',
            hintText: '请输入章节标题',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              widget.controller.updateChapterTitle(
                book.id,
                volume.id,
                chapter.id,
                titleController.text.trim(),
              );
              Get.back();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showVolumeMenu(Book book, Volume volume) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑卷名'),
                onTap: () {
                  Get.back();
                  _showEditVolumeDialog(book, volume);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除卷'),
                textColor: Get.theme.colorScheme.error,
                iconColor: Get.theme.colorScheme.error,
                onTap: () {
                  Get.back();
                  _confirmDeleteVolume(book, volume);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChapterMenu(Book book, Volume volume, Chapter chapter) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑章节名'),
                onTap: () {
                  Get.back();
                  _showEditChapterDialog(book, volume, chapter);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除章节'),
                textColor: Get.theme.colorScheme.error,
                iconColor: Get.theme.colorScheme.error,
                onTap: () {
                  Get.back();
                  _confirmDeleteChapter(book, volume, chapter);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteVolume(Book book, Volume volume) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除《${volume.title}》及其所有章节吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              widget.controller.deleteVolume(book.id, volume.id);
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChapter(Book book, Volume volume, Chapter chapter) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除《${chapter.title}》吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              widget.controller.deleteChapter(book.id, volume.id, chapter.id);
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 大纲标签页
class _OutlineTab extends StatefulWidget {
  final WritingAssistantController controller;

  const _OutlineTab({required this.controller});

  @override
  State<_OutlineTab> createState() => _OutlineTabState();
}

class _OutlineTabState extends State<_OutlineTab> {
  late TextEditingController _outlineController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _outlineController = TextEditingController(
      text: widget.controller.currentBook.value!.outline,
    );
  }

  @override
  void dispose() {
    _outlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(child: _buildOutlineEditor()),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '作品大纲',
              style: Get.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isEditing)
            GradientActionButton(
              icon: Icons.save,
              label: '保存',
              onPressed: _saveOutline,
              color: AppTheme.getSuccessColor(
                AppTheme.getCurrentThemeType(Get.context!),
              ),
              isTablet: false,
            )
          else
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              label: const Text('编辑'),
            ),
        ],
      ),
    );
  }

  Widget _buildOutlineEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _outlineController,
        maxLines: null,
        expands: true,
        readOnly: !_isEditing,
        decoration: InputDecoration(
          hintText: '在此记录作品大纲、人物设定、剧情走向等...',
          border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
        ),
        style: const TextStyle(fontSize: 16, height: 1.8),
      ),
    );
  }

  void _saveOutline() {
    widget.controller.saveOutline(_outlineController.text);
    setState(() => _isEditing = false);
  }
}

/// 章节编辑器页面
