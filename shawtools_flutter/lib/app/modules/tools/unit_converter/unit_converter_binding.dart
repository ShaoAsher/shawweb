import 'package:get/get.dart';

import 'unit_converter_controller.dart';

class UnitConverterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnitConverterController>(
      () => UnitConverterController(),
    );
  }
}

