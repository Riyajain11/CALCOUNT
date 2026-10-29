import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../core/date_helpers.dart';
import '../data/models/daily_total.dart';
import '../data/models/meal.dart';
import '../data/models/scan_quota.dart';
import '../data/models/targets.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/scan_repository.dart';
import '../estimator/nutrition_estimator.dart';
import '../logic/alert_evaluator.dart';
import '../logic/totals_service.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return MockApiClient();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository(startLoggedIn: true);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FakeProfileRepository(initializeWithDefault: true);
});

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return FakeMealRepository(seedSampleMeals: false);
});

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScanRepositoryImpl(apiClient: apiClient);
});

final nutritionEstimatorProvider = Provider<NutritionEstimator>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CloudNutritionEstimator(apiClient: apiClient);
});

// Auth State Provider
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

// User Profile State Notifier
class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.saveProfile(profile);
    state = AsyncData(profile);
    // Refresh targets as well
    ref.invalidate(targetsProvider);
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile?>(() {
  return ProfileNotifier();
});

// Targets State Notifier
class TargetsNotifier extends AsyncNotifier<Targets?> {
  @override
  Future<Targets?> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getTargets();
  }

  Future<void> saveTargets(Targets targets) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.saveTargets(targets);
    state = AsyncData(targets);
  }

  Future<void> resetToRecommended() async {
    final repo = ref.read(profileRepositoryProvider);
    final targets = await repo.resetTargets();
    state = AsyncData(targets);
  }
}

final targetsProvider = AsyncNotifierProvider<TargetsNotifier, Targets?>(() {
  return TargetsNotifier();
});

// Quota Provider
class ScanQuotaNotifier extends AsyncNotifier<ScanQuota> {
  @override
  Future<ScanQuota> build() async {
    final scanRepo = ref.read(scanRepositoryProvider);
    return scanRepo.getQuota();
  }

  Future<void> refreshQuota() async {
    final scanRepo = ref.read(scanRepositoryProvider);
    final quota = await scanRepo.getQuota();
    state = AsyncData(quota);
  }
}

final scanQuotaNotifierProvider =
    AsyncNotifierProvider<ScanQuotaNotifier, ScanQuota>(() {
  return ScanQuotaNotifier();
});

// Today's Meals Stream Provider
final todayDateStringProvider = Provider<String>((ref) {
  return DateHelpers.toLocalDayString(DateTime.now());
});

final todayMealsProvider = StreamProvider<List<Meal>>((ref) {
  final mealRepo = ref.watch(mealRepositoryProvider);
  final todayStr = ref.watch(todayDateStringProvider);
  return mealRepo.watchMealsForDate(todayStr);
});

// Today's Totals Provider
final todayTotalsProvider = Provider<DailyTotal>((ref) {
  final todayStr = ref.watch(todayDateStringProvider);
  final mealsAsync = ref.watch(todayMealsProvider);
  final meals = mealsAsync.value ?? [];
  return TotalsService.computeDayTotal(todayStr, meals);
});

// Alert Evaluator Provider
final alertEvaluationProvider = Provider<AlertEvaluation>((ref) {
  final todayTotal = ref.watch(todayTotalsProvider);
  final targetsAsync = ref.watch(targetsProvider);
  final targets = targetsAsync.value;

  final targetKcal = targets?.calories ?? 2600;
  final fatTargetG = targets?.fatG ?? 72;

  return AlertEvaluator.evaluate(
    eatenKcal: todayTotal.kcal,
    targetKcal: targetKcal,
    fatEatenG: todayTotal.fatG,
    fatTargetG: fatTargetG,
  );
});

// Streak Provider: returns consecutive days logged or 0 for fresh user
final streakProvider = Provider<int>((ref) {
  final todayTotal = ref.watch(todayTotalsProvider);
  return todayTotal.kcal > 0 ? 1 : 0;
});

