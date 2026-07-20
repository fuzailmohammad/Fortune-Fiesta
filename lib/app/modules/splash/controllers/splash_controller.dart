import 'package:fortune_fiesta/app/routes/app_pages.dart';
import 'package:fortune_fiesta/utils/storage/storage_utils.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startOnboarding();
  }

  Future<void> _startOnboarding() async {
    await Future.delayed(const Duration(seconds: 3));

    if (Storage.isUserExists()) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.authLogin);
    }
  }
}
