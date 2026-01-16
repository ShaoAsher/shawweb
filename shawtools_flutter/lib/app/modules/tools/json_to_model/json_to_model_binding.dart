import 'package:get/get.dart';

import 'json_to_model_controller.dart';

class JsonToModelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JsonToModelController>(() => JsonToModelController());
  }
}
