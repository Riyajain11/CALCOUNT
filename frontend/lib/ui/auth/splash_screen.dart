import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      context.go('/welcome');
    } else {
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      if (!mounted) return;
      if (profile == null) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.center_focus_strong,
                size: 48,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI Food & Macro',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracker',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

