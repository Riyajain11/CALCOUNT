import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/food_item.dart';
import '../data/models/scan_result.dart';
import '../ui/auth/auth_screen.dart';
import '../ui/auth/forgot_password_screen.dart';
import '../ui/auth/splash_screen.dart';
import '../ui/auth/welcome_screen.dart';
import '../ui/common/error_screen.dart';
import '../ui/history/day_detail_screen.dart';
import '../ui/navigation/main_navigation_screen.dart';
import '../ui/onboarding/profile_setup_screen.dart';
import '../ui/scan/manual_add_screen.dart';
import '../ui/scan/result_screen.dart';
import '../ui/settings/edit_entry_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => ErrorScreen(
    title: 'Page Not Found',
    message: state.error?.message ?? 'The requested page does not exist.',
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const AuthScreen(initialIsSignUp: true),
    ),
    GoRoute(
      path: '/log-in',
      builder: (context, state) => const AuthScreen(initialIsSignUp: false),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 0),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
    ),
    GoRoute(
      path: '/scan/result',
      builder: (context, state) {
        final scanResult = state.extra as ScanResult;
        return ResultScreen(scanResult: scanResult);
      },
    ),
    GoRoute(
      path: '/manual-add',
      builder: (context, state) => const ManualAddScreen(),
    ),
    GoRoute(
      path: '/history/day',
      builder: (context, state) {
        final dateStr = state.extra as String;
        return DayDetailScreen(dateStr: dateStr);
      },
    ),
    GoRoute(
      path: '/edit-entry',
      builder: (context, state) {
        final item = state.extra as FoodItem;
        return EditEntryScreen(item: item);
      },
    ),
    GoRoute(
      path: '/error',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ErrorScreen(
          title: extra?['title'] as String? ?? 'Error',
          message: extra?['message'] as String? ?? 'An unexpected error occurred.',
          onRetry: extra?['onRetry'] as VoidCallback?,
        );
      },
    ),
  ],
);
