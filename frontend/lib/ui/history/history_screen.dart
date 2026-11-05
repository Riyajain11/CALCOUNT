import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/date_helpers.dart';
import '../../data/models/daily_total.dart';
import '../../providers/app_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _selectedRangeIndex = 0; // 0: 7 days, 1: 30 days, 2: All

  int get _daysCount {
    switch (_selectedRangeIndex) {
      case 0:
        return 7;
      case 1:
        return 30;
      case 2:
      default:
        return 90; // All (up to retention window)
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final targetsAsync = ref.watch(targetsProvider);
    final targetKcal = targetsAsync.value?.calories.toDouble() ?? 2600.0;

    final now = DateTime.now();
    final fromDate = now.subtract(Duration(days: _daysCount - 1));
    final totalsAsync = ref.watch(mealRepositoryProvider).watchDailyTotals(fromDate, now);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),

              // Range Tabs: 7 days, 30 days, All
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildRangeTab('7 days', 0, isDark),
                    _buildRangeTab('30 days', 1, isDark),
                    _buildRangeTab('All', 2, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stream of Daily Totals
              StreamBuilder<List<DailyTotal>>(
                stream: totalsAsync,
                builder: (context, snapshot) {
                  final totals = snapshot.data ?? [];
                  final loggedDays = totals.where((t) => t.kcal > 0).toList();
                  final avgKcal = loggedDays.isEmpty
                      ? 0
                      : (loggedDays.fold(0.0, (s, t) => s + t.kcal) / loggedDays.length).round();
                  final daysOver = loggedDays.where((t) => t.kcal > targetKcal).length;

                  return Column(
                    children: [
                      // Bar Chart Container
                      Container(
                        height: 240,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                        ),
                        child: totals.isEmpty
                            ? const Center(child: Text('No data'))
                            : _buildBarChart(totals, targetKcal, isDark),
                      ),
                      const SizedBox(height: 16),

                      // Summary Row under Chart
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Average', '$avgKcal kcal', isDark),
                            _buildStatItem('Over target', '$daysOver days', isDark),
                            _buildStatItem('Logged', '${loggedDays.length}/${totals.length} d', isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Days List
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Past Days',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (loggedDays.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                          ),
                          child: Center(
                            child: Text(
                              'No history recorded yet.\nStart logging meals to view your trends!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        )
                      else
                        ...loggedDays.reversed.map((dayTotal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () {
                              context.push('/history/day', extra: dayTotal.date);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateHelpers.toDisplayDate(
                                          DateHelpers.parseDayString(dayTotal.date),
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : AppColors.textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${dayTotal.proteinG.round()}g P · ${dayTotal.carbsG.round()}g C · ${dayTotal.fatG.round()}g F',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${dayTotal.kcal.round()} kcal',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: dayTotal.kcal > targetKcal
                                              ? AppColors.over
                                              : (dayTotal.kcal >= targetKcal * 0.8
                                                  ? AppColors.warning
                                                  : (isDark
                                                      ? AppColors.accentLime
                                                      : AppColors.primaryGreen)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 20,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeTab(String label, int index, bool isDark) {
    final isSelected = _selectedRangeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRangeIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.accentLime : AppColors.primaryGreen)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.white70 : AppColors.textLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<DailyTotal> totals, double targetKcal, bool isDark) {
    // Show only the most recent up to 14 days on chart for readability
    final visibleTotals = totals.length > 14
        ? totals.sublist(totals.length - 14)
        : totals;

    final maxY = (targetKcal * 1.3).clamp(3000.0, 5000.0);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: targetKcal,
              color: isDark ? Colors.white38 : Colors.black38,
              strokeWidth: 1.5,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 6, bottom: 4),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                labelResolver: (line) => 'Target ${targetKcal.round()}',
              ),
            ),
          ],
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = visibleTotals[group.x.toInt()];
              return BarTooltipItem(
                '${day.date}\n${rod.toY.round()} kcal',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final index = val.toInt();
                if (index < 0 || index >= visibleTotals.length) {
                  return const SizedBox.shrink();
                }
                final dt = DateHelpers.parseDayString(visibleTotals[index].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    DateHelpers.toShortDisplayDate(dt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(visibleTotals.length, (index) {
          final total = visibleTotals[index];
          final kcal = total.kcal;

          Color barColor;
          if (kcal > targetKcal) {
            barColor = AppColors.over;
          } else if (kcal >= targetKcal * 0.8) {
            barColor = AppColors.warning;
          } else {
            barColor = isDark ? AppColors.accentLime : AppColors.primaryGreen;
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: kcal,
                color: barColor,
                width: 14,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}

