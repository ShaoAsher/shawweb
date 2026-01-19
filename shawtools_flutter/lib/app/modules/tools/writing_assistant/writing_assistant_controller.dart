import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../models/writing_models.dart';
import '../../../utils/toast_utils.dart';

class WritingAssistantController extends GetxController {
  static const String _booksKey = 'writing_books';

  final RxList<Book> books = <Book>[].obs;
  final Rx<Book?> currentBook = Rx<Book?>(null);
  final Rx<Chapter?> currentChapter = Rx<Chapter?>(null);

  final _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    _loadBooks();
  }

  /// 加载书籍列表
  Future<void> _loadBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final booksJson = prefs.getString(_booksKey);
      if (booksJson != null) {
        final List<dynamic> decoded = jsonDecode(booksJson);
        books.value = decoded.map((json) => Book.fromJson(json)).toList();
      }
    } catch (e) {
      ToastUtils.showError('加载失败: $e');
    }
  }

  /// 保存书籍列表
  Future<void> _saveBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final booksJson = jsonEncode(books.map((book) => book.toJson()).toList());
      await prefs.setString(_booksKey, booksJson);
    } catch (e) {
      ToastUtils.showError('保存失败: $e');
    }
  }

  /// 创建新书
  Future<void> createBook({
    required String title,
    String author = '',
    String description = '',
  }) async {
    final now = DateTime.now();
    final book = Book(
      id: _uuid.v4(),
      title: title,
      author: author,
      description: description,
      createdAt: now,
      updatedAt: now,
    );

    books.add(book);
    await _saveBooks();
    ToastUtils.showSuccess('书籍创建成功');
  }

  /// 更新书籍信息
  Future<void> updateBook(Book book) async {
    book.updatedAt = DateTime.now();
    books.refresh();
    await _saveBooks();
    ToastUtils.showSuccess('书籍更新成功');
  }

  /// 删除书籍
  Future<void> deleteBook(String bookId) async {
    books.removeWhere((book) => book.id == bookId);
    if (currentBook.value?.id == bookId) {
      currentBook.value = null;
      currentChapter.value = null;
    }
    await _saveBooks();
    ToastUtils.showSuccess('书籍已删除');
  }

  /// 选择当前书籍
  void selectBook(Book book) {
    currentBook.value = book;
    currentChapter.value = null;
  }

  /// 添加卷
  Future<void> addVolume(String bookId, String title) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final volume = Volume(
      id: _uuid.v4(),
      title: title,
      order: book.volumes.length + 1,
    );
    book.volumes.add(volume);
    book.updatedAt = DateTime.now();
    books.refresh();

    // 如果当前正在查看该书籍，刷新当前书籍
    if (currentBook.value?.id == bookId) {
      currentBook.value = book;
      currentBook.refresh();
    }

    await _saveBooks();
    ToastUtils.showSuccess('卷添加成功');
  }

  /// 更新卷信息
  Future<void> updateVolume(
    String bookId,
    String volumeId,
    String newTitle,
  ) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final volume = book.volumes.firstWhere((v) => v.id == volumeId);
    volume.title = newTitle;
    book.updatedAt = DateTime.now();
    books.refresh();

    // 如果当前正在查看该书籍，刷新当前书籍
    if (currentBook.value?.id == bookId) {
      currentBook.value = book;
      currentBook.refresh();
    }

    await _saveBooks();
    ToastUtils.showSuccess('卷名已更新');
  }

  /// 删除卷
  Future<void> deleteVolume(String bookId, String volumeId) async {
    final book = books.firstWhere((b) => b.id == bookId);
    book.volumes.removeWhere((v) => v.id == volumeId);
    // 重新排序
    for (var i = 0; i < book.volumes.length; i++) {
      book.volumes[i].order = i + 1;
    }
    book.updatedAt = DateTime.now();
    books.refresh();

    // 如果当前正在查看该书籍，刷新当前书籍
    if (currentBook.value?.id == bookId) {
      currentBook.value = book;
      currentBook.refresh();
    }

    await _saveBooks();
    ToastUtils.showSuccess('卷已删除');
  }

  /// 添加章节
  Future<void> addChapter(String bookId, String volumeId, String title) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final volume = book.volumes.firstWhere((v) => v.id == volumeId);
    final now = DateTime.now();
    final chapter = Chapter(
      id: _uuid.v4(),
      title: title,
      order: volume.chapters.length + 1,
      createdAt: now,
      updatedAt: now,
    );
    volume.chapters.add(chapter);
    book.updatedAt = now;
    books.refresh();

    // 如果当前正在查看该书籍，刷新当前书籍
    if (currentBook.value?.id == bookId) {
      currentBook.value = book;
      currentBook.refresh();
    }

    await _saveBooks();
    ToastUtils.showSuccess('章节添加成功');
  }

  /// 更新章节信息
  Future<void> updateChapterTitle(
    String bookId,
    String volumeId,
    String chapterId,
    String newTitle,
  ) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final volume = book.volumes.firstWhere((v) => v.id == volumeId);
    final chapter = volume.chapters.firstWhere((c) => c.id == chapterId);
    chapter.title = newTitle;
    chapter.updatedAt = DateTime.now();
    book.updatedAt = DateTime.now();
    books.refresh();

    // 如果当前正在查看该书籍，刷新当前书籍
    if (currentBook.value?.id == bookId) {
      currentBook.value = book;
      currentBook.refresh();
    }

    // 如果当前正在编辑该章节，也刷新
    if (currentChapter.value?.id == chapterId) {
      currentChapter.value = chapter;
      currentChapter.refresh();
    }

    await _saveBooks();
    ToastUtils.showSuccess('章节名已更新');
  }

  /// 删除章节
  Future<void> deleteChapter(
    String bookId,
    String volumeId,
    String chapterId,
  ) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final volume = book.volumes.firstWhere((v) => v.id == volumeId);
    volume.chapters.removeWhere((c) => c.id == chapterId);
    // 重新排序
    for (var i = 0; i < volume.chapters.length; i++) {
      volume.chapters[i].order = i + 1;
    }
    book.updatedAt = DateTime.now();
    if (currentChapter.value?.id == chapterId) {
      currentChapter.value = null;
    }
    books.refresh();

    // 如果当前正在查看该书籍，刷新当前书籍
    if (currentBook.value?.id == bookId) {
      currentBook.value = book;
      currentBook.refresh();
    }

    await _saveBooks();
    ToastUtils.showSuccess('章节已删除');
  }

  /// 选择当前章节
  void selectChapter(Chapter chapter) {
    currentChapter.value = chapter;
  }

  /// 保存章节内容
  Future<void> saveChapterContent(String content) async {
    if (currentChapter.value == null || currentBook.value == null) return;

    currentChapter.value!.content = content;
    currentChapter.value!.updateWords();
    currentChapter.value!.updatedAt = DateTime.now();
    currentBook.value!.updatedAt = DateTime.now();
    books.refresh();
    await _saveBooks();
  }

  /// 保存大纲
  Future<void> saveOutline(String outline) async {
    if (currentBook.value == null) return;

    currentBook.value!.outline = outline;
    currentBook.value!.updatedAt = DateTime.now();
    books.refresh();
    await _saveBooks();
    ToastUtils.showSuccess('大纲已保存');
  }

  /// 获取书籍统计信息
  Map<String, int> getBookStats(Book book) {
    return {
      'volumes': book.volumes.length,
      'chapters': book.totalChapters,
      'words': book.totalWords,
    };
  }

  /// 更新大纲
  Future<void> updateOutline(String bookId, String outline) async {
    final book = books.firstWhere((b) => b.id == bookId);
    book.outline = outline;
    book.updatedAt = DateTime.now();
    books.refresh();

    // 如果当前正在查看该书籍，刷新当前书籍
    if (currentBook.value?.id == bookId) {
      currentBook.value = book;
      currentBook.refresh();
    }

    await _saveBooks();
    ToastUtils.showSuccess('大纲已更新');
  }

  /// 导出书籍为 TXT 格式
  Future<void> exportBookAsTxt(String bookId) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final buffer = StringBuffer();

    // 书籍标题
    buffer.writeln(book.title);
    buffer.writeln('作者：${book.author}');
    buffer.writeln('');

    // 大纲
    if (book.outline.isNotEmpty) {
      buffer.writeln('【大纲】');
      buffer.writeln(book.outline);
      buffer.writeln('');
      buffer.writeln('=' * 50);
      buffer.writeln('');
    }

    // 正文
    for (var volume in book.volumes) {
      buffer.writeln('');
      buffer.writeln('第${volume.order}卷 ${volume.title}');
      buffer.writeln('');

      for (var chapter in volume.chapters) {
        buffer.writeln('');
        buffer.writeln('第${chapter.order}章 ${chapter.title}');
        buffer.writeln('');
        buffer.writeln(chapter.content);
        buffer.writeln('');
      }
    }

    // TODO: 实现文件保存和分享
    ToastUtils.showSuccess('TXT 导出功能开发中');
  }

  /// 导出书籍为 Markdown 格式
  Future<void> exportBookAsMd(String bookId) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final buffer = StringBuffer();

    // 书籍标题
    buffer.writeln('# ${book.title}');
    buffer.writeln('');
    buffer.writeln('**作者：** ${book.author}');
    buffer.writeln('');

    // 大纲
    if (book.outline.isNotEmpty) {
      buffer.writeln('## 大纲');
      buffer.writeln('');
      buffer.writeln(book.outline);
      buffer.writeln('');
      buffer.writeln('---');
      buffer.writeln('');
    }

    // 正文
    for (var volume in book.volumes) {
      buffer.writeln('## 第${volume.order}卷 ${volume.title}');
      buffer.writeln('');

      for (var chapter in volume.chapters) {
        buffer.writeln('### 第${chapter.order}章 ${chapter.title}');
        buffer.writeln('');
        buffer.writeln(chapter.content);
        buffer.writeln('');
      }
    }

    // TODO: 实现文件保存和分享
    ToastUtils.showSuccess('Markdown 导出功能开发中');
  }
}
