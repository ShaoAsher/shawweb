import 'package:get/get.dart';

import 'string_encryptor_controller.dart';

class StringEncryptorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StringEncryptorController>(() => StringEncryptorController());
  }
}
