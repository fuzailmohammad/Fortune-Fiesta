import 'package:get/get.dart';

import 'storage_service.dart';

class RewardService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  static const String _lastClaimKey = 'last_reward_claim_timestamp';

  bool get isRewardAvailable {
    final lastClaimStr = _storage.read<String>(_lastClaimKey);
    if (lastClaimStr == null || lastClaimStr.isEmpty) return true;

    try {
      final lastClaim = DateTime.parse(lastClaimStr);
      final now = DateTime.now();
      return now.difference(lastClaim).inHours >= 24;
    } catch (_) {
      return true;
    }
  }

  Duration get timeUntilNextReward {
    final lastClaimStr = _storage.read<String>(_lastClaimKey);
    if (lastClaimStr == null || lastClaimStr.isEmpty) return Duration.zero;

    try {
      final lastClaim = DateTime.parse(lastClaimStr);
      final now = DateTime.now();
      final difference = now.difference(lastClaim);
      if (difference.inHours >= 24) return Duration.zero;

      return const Duration(hours: 24) - difference;
    } catch (_) {
      return Duration.zero;
    }
  }

  Future<int> claimReward() async {
    if (!isRewardAvailable) return 0;
    await _storage.write(_lastClaimKey, DateTime.now().toIso8601String());
    return 5000; // Fixed reward amount (e.g. 5,000 coins)
  }
}
