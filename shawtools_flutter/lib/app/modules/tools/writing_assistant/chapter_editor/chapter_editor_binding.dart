import 'package:get/get.dart';

import 'chapter_editor_controller.dart';

class ChapterEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChapterEditorController>(() => ChapterEditorController());
  }
}
