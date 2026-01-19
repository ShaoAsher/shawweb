import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chapter_editor_controller.dart';

/// 章节编辑器页面
class ChapterEditorPage extends GetView<ChapterEditorController> {
  const ChapterEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 后台异步保存，不阻塞返回
          controller.saveContent();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(controller.chapter.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => controller.goBack(),
          ),
          actions: [
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    '${controller.wordCount.value} 字',
                    style: Get.theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller.contentController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              hintText: '开始你的创作...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 18, height: 2.0),
          ),
        ),
      ),
    );
  }
}
