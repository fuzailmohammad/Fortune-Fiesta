import 'package:get/get.dart';

import '../controllers/ad_controller.dart';
import '../controllers/audio_controller.dart';
import '../controllers/juice_controller.dart';
import '../controllers/liveops_controller.dart';
import '../controllers/mission_controller.dart';
import '../controllers/premium_home_controller.dart';
import '../controllers/progression_controller.dart';
import '../controllers/retention_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/shop_controller.dart';
import '../controllers/social_controller.dart';
import '../services/reward_service.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';

class PremiumHomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize storage first since other services depend on it
    final storage = Get.put(StorageService(), permanent: true);
    storage.init();

    // Register services
    Get.put(RewardService(), permanent: true);
    Get.put(StatsService(), permanent: true);

    // Register controllers
    Get.lazyPut<PremiumHomeController>(() => PremiumHomeController());
    Get.lazyPut<AdController>(() => AdController());
    Get.lazyPut<AudioController>(() => AudioController());
    Get.lazyPut<JuiceController>(() => JuiceController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<LiveOpsController>(() => LiveOpsController());
    Get.lazyPut<MissionController>(() => MissionController());
    Get.lazyPut<ProgressionController>(() => ProgressionController());
    Get.lazyPut<RetentionController>(() => RetentionController());
    Get.lazyPut<ShopController>(() => ShopController());
    Get.lazyPut<SocialController>(() => SocialController());
  }
}
