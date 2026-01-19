import 'package:get/get.dart';

import 'writing_assistant_controller.dart';

class WritingAssistantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WritingAssistantController>(() => WritingAssistantController());
  }
}
