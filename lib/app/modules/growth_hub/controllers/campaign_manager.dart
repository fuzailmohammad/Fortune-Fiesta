import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:get/get.dart';

class CampaignMessage {
  final String id;
  final String title;
  final String body;
  final String triggerTime;
  final bool isSent;

  const CampaignMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.triggerTime,
    this.isSent = false,
  });

  CampaignMessage copyWith({bool? isSent}) {
    return CampaignMessage(
      id: id,
      title: title,
      body: body,
      triggerTime: triggerTime,
      isSent: isSent ?? this.isSent,
    );
  }
}

class CampaignManager extends GetxController {
  static CampaignManager get to => Get.find();

  final RxList<CampaignMessage> scheduledCampaigns = <CampaignMessage>[].obs;
  final RxBool pushEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialCampaigns();
  }

  void _loadInitialCampaigns() {
    scheduledCampaigns.assignAll([
      const CampaignMessage(
          id: 'c_lucky_hour',
          title: '🍀 Lucky Hour Started!',
          body: 'Spin now for 2x XP and increased Jackpot chances!',
          triggerTime: 'Every day at 8:00 PM'),
      const CampaignMessage(
          id: 'c_daily_reward',
          title: '🎁 Your Daily Vault is Ready!',
          body: 'Don\'t break your streak! Claim up to 50,000 Coins today.',
          triggerTime: 'Every morning at 9:00 AM'),
      const CampaignMessage(
          id: 'c_comm_goal',
          title: '🌍 Global Goal 90% Reached!',
          body:
              'The community is close to unlocking the Grand Chest! Spin to help!',
          triggerTime: 'Weekend Event Trigger'),
      const CampaignMessage(
          id: 'c_friend_pass',
          title: '🏆 Alex passed your ranking!',
          body:
              'You dropped to #14 on the Diamond League leaderboard. Reclaim your spot!',
          triggerTime: 'Real-time Social Trigger'),
      const CampaignMessage(
          id: 'c_weekend_bonus',
          title: '⚡ Weekend Double Coin Festival!',
          body: 'All slot machine coin wins are doubled for the next 48 hours!',
          triggerTime: 'Friday at 6:00 PM'),
      const CampaignMessage(
          id: 'c_special_event',
          title: '🎃 Halloween Spooktacular Live!',
          body:
              'Unlock the exclusive Pumpkin Machine Skin before the event ends!',
          triggerTime: 'Seasonal Trigger'),
    ]);
  }

  // 🔔 Simulate dispatching a notification campaign
  void testDispatchCampaign(String campaignId) {
    final idx = scheduledCampaigns.indexWhere((c) => c.id == campaignId);
    if (idx != -1) {
      final c = scheduledCampaigns[idx];
      scheduledCampaigns[idx] = c.copyWith(isSent: true);
      AppLogger.i('🔔 CAMPAIGN DISPATCHED: [${c.title}] - ${c.body}',
          tag: 'CampaignManager');

      Get.snackbar(
        c.title,
        c.body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void togglePushNotifications(bool value) {
    pushEnabled.value = value;
    AppLogger.i('Push notifications toggled: $value', tag: 'CampaignManager');
  }
}
