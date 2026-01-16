import 'package:get/get.dart';

import 'ip_query_controller.dart';

class IpQueryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IpQueryController>(() => IpQueryController());
  }
}
