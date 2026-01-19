import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/writing_models.dart';
import '../writing_assistant_controller.dart';

/// 章节编辑器控制器
class ChapterEditorController extends GetxController {
  final WritingAssistantController mainController = Get.find();

  late final Chapter chapter;
  late final TextEditingController contentController;

  final wordCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // 从路由参数获取章节
    chapter = Get.arguments as Chapter;
    contentController = TextEditingController(text: chapter.content);
    wordCount.value = chapter.content.length;

    // 监听内容变化
    contentController.addListener(_onContentChanged);
  }

  @override
  void onClose() {
    contentController.removeListener(_onContentChanged);
    contentController.dispose();
    super.onClose();
  }

  void _onContentChanged() {
    wordCount.value = contentController.text.length;
  }

  /// 保存章节内容（静默保存，无提示）
  Future<void> saveContent() async {
    final book = mainController.currentBook.value;
    if (book == null) return;

    // 更新章节内容和字数
    chapter.content = contentController.text;
    chapter.words = contentController.text.length;
    chapter.updatedAt = DateTime.now();
    book.updatedAt = DateTime.now();

    // 保存到存储并刷新
    mainController.books.refresh();
    if (mainController.currentBook.value?.id == book.id) {
      mainController.currentBook.value = book;
      mainController.currentBook.refresh();
    }

    // 静默保存，无需提示
  }

  /// 返回上一页（立即返回，后台保存）
  void goBack() {
    Get.back();
    // 后台异步保存，不阻塞返回
    saveContent();
  }
}
