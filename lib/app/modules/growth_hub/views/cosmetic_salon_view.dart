import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/models/cosmetic_model.dart';
import 'package:fortune_fiesta/app/modules/growth_hub/controllers/cosmetic_manager.dart';
import 'package:fortune_fiesta/app/theme/premium_design_system.dart';
import 'package:get/get.dart';

class CosmeticSalonView extends StatefulWidget {
  const CosmeticSalonView({super.key});

  @override
  State<CosmeticSalonView> createState() => _CosmeticSalonViewState();
}

class _CosmeticSalonViewState extends State<CosmeticSalonView> {
  CosmeticType _selectedTab = CosmeticType.title;

  @override
  Widget build(BuildContext context) {
    final manager = CosmeticManager.to;

    return Column(
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('🏆 Titles', CosmeticType.title),
              const SizedBox(width: 10),
              _buildFilterChip('🎰 Machine Skins', CosmeticType.machineSkin),
              const SizedBox(width: 10),
              _buildFilterChip('👤 Avatars & Trails', CosmeticType.avatar),
              const SizedBox(width: 10),
              _buildSeasonalChip('🌍 Seasonal Themes'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Items Grid
        Expanded(
          child: Obx(() {
            if (_selectedTab == CosmeticType.avatar) {
              // Combine avatars and coin trails
              final items = manager.allItems
                  .where((i) =>
                      i.type == CosmeticType.avatar ||
                      i.type == CosmeticType.coinTrail)
                  .toList();
              return _buildGrid(items);
            }
            final items =
                manager.allItems.where((i) => i.type == _selectedTab).toList();
            return _buildGrid(items);
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, CosmeticType type) {
    final isSelected = _selectedTab == type;
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold)),
      selected: isSelected,
      selectedColor: PremiumColors.premiumGold,
      backgroundColor: PremiumColors.purpleGlass,
      onSelected: (val) {
        if (val) setState(() => _selectedTab = type);
      },
    );
  }

  Widget _buildSeasonalChip(String label) {
    return ActionChip(
      label: Text(label,
          style: const TextStyle(
              color: PremiumColors.electricBlue, fontWeight: FontWeight.bold)),
      backgroundColor: PremiumColors.purpleGlass,
      avatar: const Icon(Icons.festival,
          color: PremiumColors.electricBlue, size: 18),
      onPressed: () => _showSeasonalPicker(context),
    );
  }

  Widget _buildGrid(List<CosmeticItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        final color = Color(item.previewColorValue);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.isEquipped
                ? color.withValues(alpha: 0.2)
                : PremiumColors.purpleGlass.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isEquipped ? color : Colors.white24,
              width: item.isEquipped ? 2.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    item.isUnlocked ? Icons.check_circle : Icons.lock,
                    color: item.isUnlocked ? color : Colors.white30,
                    size: 22,
                  ),
                  if (item.isEquipped)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: color, borderRadius: BorderRadius.circular(8)),
                      child: const Text('EQUIPPED',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900)),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                item.name,
                style: PremiumTypography.subHeadingStyle
                    .copyWith(fontSize: 14, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                style: PremiumTypography.captionSmall
                    .copyWith(fontSize: 11, color: Colors.white60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: item.isUnlocked
                    ? () {
                        if (CosmeticManager.to.equipItem(item.id)) {
                          Get.snackbar('EQUIPPED!',
                              '${item.name} is now your active style!',
                              backgroundColor: color, colorText: Colors.black);
                        }
                      }
                    : () {
                        Get.snackbar(
                            'LOCKED', 'Requirement: ${item.unlockRequirement}',
                            backgroundColor: PremiumColors.purpleGlass,
                            colorText: Colors.white);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.isEquipped
                      ? Colors.white24
                      : (item.isUnlocked ? color : Colors.white12),
                  foregroundColor:
                      item.isUnlocked ? Colors.black : Colors.white38,
                  minimumSize: const Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  item.isEquipped
                      ? 'ACTIVE'
                      : (item.isUnlocked ? 'EQUIP' : 'LOCKED'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSeasonalPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF19102A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌍 SEASONAL ATMOSPHERE OVERRIDE',
                style: TextStyle(
                    color: PremiumColors.premiumGold,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: SeasonalTheme.values.map((t) {
                final isCurrent =
                    CosmeticManager.to.activeSeasonalTheme.value == t;
                return ActionChip(
                  label: Text(t.name.toUpperCase(),
                      style: TextStyle(
                          color: isCurrent ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: isCurrent
                      ? PremiumColors.premiumGold
                      : PremiumColors.purpleGlass,
                  onPressed: () {
                    CosmeticManager.to.setSeasonalTheme(t);
                    Navigator.of(ctx).pop();
                    Get.snackbar('SEASON CHANGED',
                        'Atmosphere switched to ${t.name.toUpperCase()}!',
                        backgroundColor: PremiumColors.premiumGold,
                        colorText: Colors.black);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
