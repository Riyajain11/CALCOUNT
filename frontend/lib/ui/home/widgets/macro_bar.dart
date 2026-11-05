import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class MacroBarCard extends StatelessWidget {
  final double proteinEaten;
  final int proteinTarget;
  final double carbsEaten;
  final int carbsTarget;
  final double fatEaten;
  final int fatTarget;

  const MacroBarCard({
    super.key,
    required this.proteinEaten,
    required this.proteinTarget,
    required this.carbsEaten,
    required this.carbsTarget,
    required this.fatEaten,
    required this.fatTarget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        children: [
          _buildMacroRow(
            context: context,
            label: 'Protein',
            eaten: proteinEaten,
            target: proteinTarget,
            barColor: AppColors.protein,
            isDark: isDark,
          ),
          const SizedBox(height: 18),
          _buildMacroRow(
            context: context,
            label: 'Carbs',
            eaten: carbsEaten,
            target: carbsTarget,
            barColor: AppColors.carbs,
            isDark: isDark,
          ),
          const SizedBox(height: 18),
          _buildMacroRow(
            context: context,
            label: 'Fat',
            eaten: fatEaten,
            target: fatTarget,
            barColor: AppColors.fat,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow({
    required BuildContext context,
    required String label,
    required double eaten,
    required int target,
    required Color barColor,
    required bool isDark,
  }) {
    final progress = target > 0 ? (eaten / target).clamp(0.0, 1.0) : 0.0;
    final eatenRound = eaten.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textLight,
              ),
            ),
            Text(
              '$eatenRound / $target g',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor:
                isDark ? const Color(0xFF2C332D) : const Color(0xFFDCE3D4),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

