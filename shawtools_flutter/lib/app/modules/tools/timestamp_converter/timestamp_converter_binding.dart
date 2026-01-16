import 'package:get/get.dart';

import 'timestamp_converter_controller.dart';

class TimestampConverterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimestampConverterController>(() => TimestampConverterController());
  }
}

