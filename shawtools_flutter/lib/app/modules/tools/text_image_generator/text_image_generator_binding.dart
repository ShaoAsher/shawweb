import 'package:get/get.dart';

import 'text_image_generator_controller.dart';

class TextImageGeneratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TextImageGeneratorController>(
      () => TextImageGeneratorController(),
    );
  }
}
