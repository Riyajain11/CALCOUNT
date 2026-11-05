import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../logic/alert_evaluator.dart';

class WarningBannerCard extends StatelessWidget {
  final AlertEvaluation evaluation;

  const WarningBannerCard({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    if (evaluation.bannerMessage == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOver = evaluation.level == CalorieAlertLevel.over;

    final borderColor = isOver ? AppColors.over : AppColors.warning;
    final bgColor = isDark
        ? (isOver
            ? AppColors.over.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.15))
        : (isOver ? AppColors.overBg : AppColors.warningBg);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isOver ? Icons.error_outline : Icons.info_outline,
            color: borderColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              evaluation.bannerMessage!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textLight,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

