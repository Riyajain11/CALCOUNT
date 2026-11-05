import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/date_helpers.dart';
import '../../providers/app_providers.dart';
import 'widgets/calorie_ring.dart';
import 'widgets/macro_bar.dart';
import 'widgets/meal_tile.dart';
import 'widgets/warning_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayTotals = ref.watch(todayTotalsProvider);
    final targetsAsync = ref.watch(targetsProvider);
    final mealsAsync = ref.watch(todayMealsProvider);
    final evaluation = ref.watch(alertEvaluationProvider);
    final streak = ref.watch(streakProvider);

    final targets = targetsAsync.value;
    final targetKcal = targets?.calories ?? 2600;
    final proteinTarget = targets?.proteinG ?? 126;
    final carbsTarget = targets?.carbsG ?? 361;
    final fatTarget = targets?.fatG ?? 72;

    final todayDisplay = DateHelpers.toDisplayDate(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayMealsProvider);
            ref.read(scanQuotaNotifierProvider.notifier).refreshQuota();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Date & Streak Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayDisplay,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    // Streak Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.accentLime
                              : AppColors.primaryGreen,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 18,
                            color: isDark
                                ? AppColors.accentLime
                                : AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streak-day streak',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.accentLime
                                  : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Calorie Ring Card
                CalorieRingCard(
                  eatenKcal: todayTotals.kcal,
                  targetKcal: targetKcal,
                ),
                const SizedBox(height: 16),

                // Macro Progress Bars Card
                MacroBarCard(
                  proteinEaten: todayTotals.proteinG,
                  proteinTarget: proteinTarget,
                  carbsEaten: todayTotals.carbsG,
                  carbsTarget: carbsTarget,
                  fatEaten: todayTotals.fatG,
                  fatTarget: fatTarget,
                ),
                const SizedBox(height: 16),

                // Warning / Suggestion Banner
                WarningBannerCard(evaluation: evaluation),
                if (evaluation.bannerMessage != null)
                  const SizedBox(height: 24)
                else
                  const SizedBox(height: 8),

                // Today's Meals Section
                Text(
                  'Today\'s meals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 14),

                mealsAsync.when(
                  data: (meals) {
                    if (meals.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 40,
                              color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No meals logged today yet',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Take a photo of your food or add it manually to track your macros.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/scan'),
                                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                                  label: const Text('Scan Meal'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(130, 44),
                                    backgroundColor: isDark
                                        ? AppColors.accentLime
                                        : AppColors.primaryGreen,
                                    foregroundColor:
                                        isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/manual-add'),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add Manually'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(130, 44),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: meals.map((meal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MealTile(
                            meal: meal,
                            onTap: () {
                              if (meal.items.isNotEmpty) {
                                context.push(
                                  '/edit-entry',
                                  extra: meal.items.first,
                                );
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Text('Error loading meals: $err'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

