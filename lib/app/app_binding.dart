import 'package:fortune_fiesta/app/app_controller.dart';
import 'package:fortune_fiesta/app/core/analytics/analytics_service.dart';
import 'package:fortune_fiesta/app/core/error/crash_service.dart';
import 'package:fortune_fiesta/app/core/lifecycle/lifecycle_manager.dart';
import 'package:fortune_fiesta/app/core/security/security_service.dart';
import 'package:fortune_fiesta/app/data/network/network_requester.dart';
import 'package:fortune_fiesta/app/data/repository/config_repository.dart';
import 'package:fortune_fiesta/app/data/repository/user_repository.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/dynamic_atmosphere_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/player_mood_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/recommendation_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/timeline_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/welcome_back_controller.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/campaign_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/collection_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/community_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/cosmetic_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/growth_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/share_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/surprise_manager.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core Production Infrastructure
    Get.putAsync(() => CrashService().init(), permanent: true);
    Get.putAsync(() => AnalyticsService().init(), permanent: true);
    Get.putAsync(() => SecurityService().init(), permanent: true);
    Get.putAsync(() => AppLifecycleManager().init(), permanent: true);

    // 2. Network & Repositories
    Get.put(NetworkRequester(), permanent: true);
    Get.put(ConfigRepository(), permanent: true);
    Get.put(UserRepository(), permanent: true);
    Get.put(AppController(), permanent: true);

    // 3. Viral Growth & Engagement Ecosystem
    Get.put(CosmeticManager(), permanent: true);
    Get.put(CollectionManager(), permanent: true);
    Get.put(ShareManager(), permanent: true);
    Get.put(CommunityManager(), permanent: true);
    Get.put(SurpriseManager(), permanent: true);
    Get.put(CampaignManager(), permanent: true);
    Get.put(GrowthManager(), permanent: true);

    // 4. Adaptive Experience & Player Mood System
    Get.put(PlayerMoodController(), permanent: true);
    Get.put(DynamicAtmosphereController(), permanent: true);
    Get.put(WelcomeBackController(), permanent: true);
    Get.put(RecommendationController(), permanent: true);
    Get.put(TimelineController(), permanent: true);
  }
}
