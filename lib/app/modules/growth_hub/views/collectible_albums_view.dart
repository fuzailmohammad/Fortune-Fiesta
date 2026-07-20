import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/collection_model.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/collection_manager.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class CollectibleAlbumsView extends StatelessWidget {
  const CollectibleAlbumsView({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = CollectionManager.to;

    return Column(
      children: [
        // Top Banner & Booster Pack Action
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PremiumColors.royalPurple.withValues(alpha: 0.6),
                PremiumColors.electricBlue.withValues(alpha: 0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: PremiumColors.premiumGold.withValues(alpha: 0.4),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                color: PremiumColors.premiumGold.withValues(alpha: 0.1),
                blurRadius: 15,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PremiumColors.premiumGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_mosaic,
                    color: PremiumColors.premiumGold, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MYSTERY SYMBOL VAULT',
                        style: PremiumTypography.subHeadingStyle
                            .copyWith(color: PremiumColors.premiumGold)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          'Duplicate Dust: ${manager.duplicateDust.value} ✨',
                          style: PremiumTypography.captionSmall
                              .copyWith(color: Colors.white70),
                        )),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBoosterPackDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumColors.premiumGold,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.style, size: 20),
                label: const Text('OPEN PACK',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Albums Grid
        Expanded(
          child: Obx(() {
            final albums = manager.albums;
            return GridView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return _buildAlbumCard(context, album);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAlbumCard(BuildContext context, CollectibleAlbum album) {
    final bool isCompleted = album.unlockedCount == album.cards.length;

    return GestureDetector(
      onTap: () => _showAlbumDetailsDialog(context, album),
      child: Container(
        decoration: BoxDecoration(
          color: PremiumColors.purpleGlass.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? PremiumColors.premiumGold
                : PremiumColors.royalPurple.withValues(alpha: 0.4),
            width: isCompleted ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isCompleted)
              BoxShadow(
                  color: PremiumColors.premiumGold.withValues(alpha: 0.25),
                  blurRadius: 15),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  _getCategoryIcon(album.category),
                  color: isCompleted
                      ? PremiumColors.premiumGold
                      : PremiumColors.electricBlue,
                  size: 28,
                ),
                if (isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PremiumColors.premiumGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('COMPLETE',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  )
                else
                  Text(
                    '${album.unlockedCount}/${album.cards.length}',
                    style: PremiumTypography.numbersStyle.copyWith(
                        fontSize: 14, color: PremiumColors.electricBlue),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              album.title.toUpperCase(),
              style: PremiumTypography.subHeadingStyle
                  .copyWith(fontSize: 14, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              album.description,
              style: PremiumTypography.captionSmall
                  .copyWith(fontSize: 11, color: Colors.white60),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: album.progressRatio,
                backgroundColor: Colors.black38,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted
                      ? PremiumColors.premiumGold
                      : PremiumColors.electricBlue,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'fruit':
        return Icons.apple;
      case 'gem':
        return Icons.diamond;
      case 'golden_symbols':
        return Icons.monetization_on;
      case 'legendary':
        return Icons.military_tech;
      case 'season':
        return Icons.festival;
      case 'machine':
        return Icons.casino;
      default:
        return Icons.collections;
    }
  }

  void _showAlbumDetailsDialog(BuildContext context, CollectibleAlbum album) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1435),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: PremiumColors.premiumGold.withValues(alpha: 0.6),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8), blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(album.title.toUpperCase(),
                  style: PremiumTypography.headingStyle.copyWith(
                      fontSize: 22, color: PremiumColors.premiumGold)),
              const SizedBox(height: 6),
              Text(album.description,
                  style: PremiumTypography.bodyStyle
                      .copyWith(color: Colors.white70),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),

              // Cards Grid
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: album.cards.length,
                  itemBuilder: (ctx, idx) {
                    final card = album.cards[idx];
                    final color = _getRarityColor(card.rarity);
                    return Container(
                      decoration: BoxDecoration(
                        color: card.isUnlocked
                            ? color.withValues(alpha: 0.15)
                            : Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: card.isUnlocked ? color : Colors.white24,
                            width: 1.5),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            card.isUnlocked
                                ? Icons.auto_awesome
                                : Icons.lock_outline,
                            color: card.isUnlocked ? color : Colors.white30,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            card.isUnlocked ? card.name : '???',
                            style: TextStyle(
                                color: card.isUnlocked
                                    ? Colors.white
                                    : Colors.white30,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.rarity.name.toUpperCase(),
                            style: TextStyle(
                                color: color,
                                fontSize: 8,
                                fontWeight: FontWeight.w900),
                          ),
                          if (card.duplicateCount > 0)
                            Text(
                              '+${card.duplicateCount}',
                              style: const TextStyle(
                                  color: PremiumColors.premiumGold,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Completion Reward Button
              if (album.unlockedCount == album.cards.length)
                ElevatedButton(
                  onPressed: album.isRewardClaimed
                      ? null
                      : () {
                          if (CollectionManager.to.claimAlbumReward(album.id)) {
                            Navigator.of(ctx).pop();
                            Get.snackbar('JACKPOT CLAIMED!',
                                '+${album.rewardCoins} Coins added to your balance!',
                                backgroundColor: PremiumColors.premiumGold,
                                colorText: Colors.black);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumColors.premiumGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    album.isRewardClaimed
                        ? 'REWARD ALREADY CLAIMED'
                        : 'CLAIM +${album.rewardCoins} COINS',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                )
              else
                Text(
                  'Unlock all symbols to claim +${album.rewardCoins} Coins!',
                  style: PremiumTypography.captionSmall
                      .copyWith(color: PremiumColors.electricBlue),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(CollectibleRarity rarity) {
    switch (rarity) {
      case CollectibleRarity.common:
        return Colors.white;
      case CollectibleRarity.rare:
        return PremiumColors.electricBlue;
      case CollectibleRarity.epic:
        return const Color(0xFFE040FB);
      case CollectibleRarity.legendary:
        return PremiumColors.premiumGold;
      case CollectibleRarity.mythic:
        return const Color(0xFFFF1744);
    }
  }

  void _showBoosterPackDialog(BuildContext context) {
    final drawnCard = CollectionManager.to.openBoosterPack();
    final color = _getRarityColor(drawnCard.rarity);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF19102A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 40),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨ BOOSTER PACK OPENED! ✨',
                  style: TextStyle(
                      color: PremiumColors.premiumGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2)),
              const SizedBox(height: 24),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(Icons.auto_awesome, color: color, size: 64),
              ),
              const SizedBox(height: 20),
              Text(drawnCard.name.toUpperCase(),
                  style: PremiumTypography.headingStyle
                      .copyWith(fontSize: 22, color: Colors.white)),
              const SizedBox(height: 6),
              Text(drawnCard.rarity.name.toUpperCase(),
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: 14)),
              const SizedBox(height: 12),
              Text(drawnCard.description,
                  style: PremiumTypography.bodyStyle
                      .copyWith(color: Colors.white70),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('AWESOME!',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
