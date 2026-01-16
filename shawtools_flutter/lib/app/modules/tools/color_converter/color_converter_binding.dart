import 'package:get/get.dart';

import 'color_converter_controller.dart';

class ColorConverterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ColorConverterController>(
      () => ColorConverterController(),
    );
  }
}

