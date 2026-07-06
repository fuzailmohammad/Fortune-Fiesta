import 'package:get/get.dart';

import '../models/statistics_model.dart';
import 'storage_service.dart';

class StatsService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  static const String _statsKey = 'gameplay_statistics';

  StatisticsModel getStats() {
    final statsData = _storage.read(_statsKey);
    if (statsData == null) {
      return StatisticsModel(totalSpins: 0, totalWins: 0, highestWin: 0);
    }
    try {
      // GetStorage might read as Map<dynamic, dynamic> or Map<String, dynamic>
      final Map<String, dynamic> statsMap =
          Map<String, dynamic>.from(statsData as Map);
      return StatisticsModel.fromJson(statsMap);
    } catch (_) {
      return StatisticsModel(totalSpins: 0, totalWins: 0, highestWin: 0);
    }
  }

  Future<void> saveStats(StatisticsModel stats) async {
    await _storage.write(_statsKey, stats.toJson());
  }

  Future<void> recordSpin(bool isWin, int winAmount) async {
    final current = getStats();
    final updated = current.copyWith(
      totalSpins: current.totalSpins + 1,
      totalWins: current.totalWins + (isWin ? 1 : 0),
      highestWin:
          winAmount > current.highestWin ? winAmount : current.highestWin,
    );
    await saveStats(updated);
  }
}
