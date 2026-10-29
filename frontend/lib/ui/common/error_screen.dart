import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/error_types.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final ScanErrorCode? errorCode;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An unexpected error occurred. Please try again.',
    this.errorCode,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData errorIcon = Icons.error_outline_rounded;
    Color iconColor = AppColors.over;

    if (errorCode == ScanErrorCode.limitReached) {
      errorIcon = Icons.hourglass_empty_rounded;
      iconColor = AppColors.warning;
    } else if (errorCode == ScanErrorCode.noFoodDetected) {
      errorIcon = Icons.no_food_outlined;
      iconColor = AppColors.warning;
    } else if (errorCode == ScanErrorCode.network) {
      errorIcon = Icons.wifi_off_rounded;
      iconColor = AppColors.over;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: 24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Error Icon Badge
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  errorIcon,
                  size: 48,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),

              // Message Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const Spacer(),

              // Action Buttons
              if (onRetry != null) ...[
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Fallback to Add Manually
              OutlinedButton(
                onPressed: () => context.push('/manual-add'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderSubtle,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                  ),
                ),
                child: Text(
                  'Add Meal Manually',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Home
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

