import 'package:get/get.dart';

import 'image_compressor_controller.dart';

class ImageCompressorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageCompressorController>(() => ImageCompressorController());
  }
}
