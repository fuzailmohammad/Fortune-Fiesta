// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fiesta/app/app.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/dynamic_atmosphere_controller.dart';
import 'package:fortune_fiesta/app/modules/adaptive_experience/controllers/player_mood_controller.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/community_manager.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/surprise_manager.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/juice_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/liveops_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/premium_home_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/controllers/retention_controller.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/widgets/slot_machine.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    const channels = [
      'plugins.flutter.io/path_provider',
      'plugins.flutter.io/path_provider_macos',
      'plugins.flutter.io/path_provider_foundation',
    ];
    for (final name in channels) {
      final channel = MethodChannel(name);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return '.';
      });
    }
    await GetStorage.init();
  });

  testWidgets('Fortune Fiesta startup smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the core SlotMachine widget is present and app boots cleanly
    expect(find.byType(SlotMachine), findsOneWidget);

    if (Get.isRegistered<PlayerMoodController>()) {
      Get.find<PlayerMoodController>().onClose();
    }
    if (Get.isRegistered<DynamicAtmosphereController>()) {
      Get.find<DynamicAtmosphereController>().onClose();
    }
    if (Get.isRegistered<CommunityManager>()) {
      Get.find<CommunityManager>().onClose();
    }
    if (Get.isRegistered<SurpriseManager>()) {
      Get.find<SurpriseManager>().onClose();
    }
    if (Get.isRegistered<LiveOpsController>()) {
      Get.find<LiveOpsController>().onClose();
    }
    if (Get.isRegistered<RetentionController>()) {
      Get.find<RetentionController>().onClose();
    }
    if (Get.isRegistered<JuiceController>()) {
      Get.find<JuiceController>().onClose();
    }
    if (Get.isRegistered<PremiumHomeController>()) {
      Get.find<PremiumHomeController>().onClose();
    }

    Get.reset(clearRouteBindings: true);
    Get.deleteAll(force: true);
  });
}
