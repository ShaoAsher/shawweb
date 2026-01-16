import 'package:get/get.dart';

import 'qrcode_generator_controller.dart';

class QrcodeGeneratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrcodeGeneratorController>(() => QrcodeGeneratorController());
  }
}
