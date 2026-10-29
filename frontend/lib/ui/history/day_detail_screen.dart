import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/date_helpers.dart';
import '../../data/models/meal.dart';
import '../../providers/app_providers.dart';
import '../home/widgets/calorie_ring.dart';
import '../home/widgets/macro_bar.dart';
import '../home/widgets/meal_tile.dart';

class DayDetailScreen extends ConsumerWidget {
  final String dateStr;

  const DayDetailScreen({
    super.key,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealsStream = ref.watch(mealRepositoryProvider).watchMealsForDate(dateStr);
    final targetsAsync = ref.watch(targetsProvider);

    final targets = targetsAsync.value;
    final targetKcal = targets?.calories ?? 2600;
    final proteinTarget = targets?.proteinG ?? 126;
    final carbsTarget = targets?.carbsG ?? 361;
    final fatTarget = targets?.fatG ?? 72;

    final dt = DateHelpers.parseDayString(dateStr);
    final displayDate = DateHelpers.toDisplayDate(dt);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(displayDate, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Meal>>(
        stream: mealsStream,
        builder: (context, snapshot) {
          final meals = snapshot.data ?? [];
          final eatenKcal = meals.fold(0.0, (s, m) => s + m.totalKcal);
          final proteinEaten = meals.fold(0.0, (s, m) => s + m.totalProtein);
          final carbsEaten = meals.fold(0.0, (s, m) => s + m.totalCarbs);
          final fatEaten = meals.fold(0.0, (s, m) => s + m.totalFat);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calorie Ring
                CalorieRingCard(
                  eatenKcal: eatenKcal,
                  targetKcal: targetKcal,
                ),
                const SizedBox(height: 16),

                // Macro Bars
                MacroBarCard(
                  proteinEaten: proteinEaten,
                  proteinTarget: proteinTarget,
                  carbsEaten: carbsEaten,
                  carbsTarget: carbsTarget,
                  fatEaten: fatEaten,
                  fatTarget: fatTarget,
                ),
                const SizedBox(height: 24),

                Text(
                  'Meals Logged',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 14),

                if (meals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No meals recorded for this day.',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  )
                else
                  ...meals.map((meal) {
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
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

