import 'package:get/get.dart';
import 'string_generator_controller.dart';

class StringGeneratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StringGeneratorController>(() => StringGeneratorController());
  }
}
