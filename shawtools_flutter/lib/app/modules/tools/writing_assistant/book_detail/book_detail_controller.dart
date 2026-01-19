import 'package:get/get.dart';

import '../../../../models/writing_models.dart';
import '../writing_assistant_controller.dart';

/// 书籍详情控制器
class BookDetailController extends GetxController {
  final WritingAssistantController mainController = Get.find();

  late final Book book;

  @override
  void onInit() {
    super.onInit();
    // 从路由参数获取书籍ID
    final bookId = Get.parameters['bookId'];
    book = mainController.books.firstWhere((b) => b.id == bookId);
    mainController.currentBook.value = book;
  }

  @override
  void onClose() {
    mainController.currentBook.value = null;
    super.onClose();
  }

  /// 获取书籍统计信息
  Map<String, dynamic> getBookStats() {
    return mainController.getBookStats(book);
  }

  /// 添加卷
  Future<void> addVolume(String title) async {
    await mainController.addVolume(book.id, title);
  }

  /// 更新卷
  Future<void> updateVolume(String volumeId, String title) async {
    await mainController.updateVolume(book.id, volumeId, title);
  }

  /// 删除卷
  Future<void> deleteVolume(String volumeId) async {
    await mainController.deleteVolume(book.id, volumeId);
  }

  /// 添加章节
  Future<void> addChapter(String volumeId, String title) async {
    await mainController.addChapter(book.id, volumeId, title);
  }

  /// 更新章节标题
  Future<void> updateChapterTitle(
    String volumeId,
    String chapterId,
    String title,
  ) async {
    await mainController.updateChapterTitle(
      book.id,
      volumeId,
      chapterId,
      title,
    );
  }

  /// 删除章节
  Future<void> deleteChapter(String volumeId, String chapterId) async {
    await mainController.deleteChapter(book.id, volumeId, chapterId);
  }

  /// 更新大纲
  Future<void> updateOutline(String outline) async {
    await mainController.updateOutline(book.id, outline);
  }

  /// 导出为TXT
  Future<void> exportAsTxt() async {
    await mainController.exportBookAsTxt(book.id);
  }

  /// 导出为Markdown
  Future<void> exportAsMarkdown() async {
    await mainController.exportBookAsMd(book.id);
  }
}
