import 'package:get/get.dart';

import 'device_preview_controller.dart';

class DevicePreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DevicePreviewController>(() => DevicePreviewController());
  }
}
