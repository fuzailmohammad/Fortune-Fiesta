import 'package:get/get.dart';
import 'package:fortune_fiesta/app/app_controller.dart';
import 'package:fortune_fiesta/app/data/network/network_requester.dart';
import 'package:fortune_fiesta/app/data/repository/config_repository.dart';
import 'package:fortune_fiesta/app/data/repository/user_repository.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkRequester(), permanent: true);
    Get.put(ConfigRepository(), permanent: true);
    Get.put(UserRepository(), permanent: true);
    Get.put(AppController(), permanent: true);
  }
}
