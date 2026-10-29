import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../logic/retention_cleaner.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(profileNotifierProvider);
    final targetsAsync = ref.watch(targetsProvider);
    final profile = profileAsync.value;
    final targets = targetsAsync.value;

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
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 24),

              // Profile Card
              _buildSectionHeader('Profile', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      'Name',
                      profile?.name ?? 'Alex',
                      isDark,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      'Goal',
                      profile?.goal.toUpperCase() ?? 'MAINTAIN',
                      isDark,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      'Body Stats',
                      '${profile?.age ?? 21} yrs · ${profile?.heightCm.round() ?? 175} cm · ${profile?.weightKg.round() ?? 70} kg',
                      isDark,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      'Activity',
                      profile?.activity.replaceAll('_', ' ').toUpperCase() ?? 'MODERATE',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/onboarding'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Update Profile & Recalculate'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Daily Targets Section
              _buildSectionHeader('Daily Targets', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Column(
                  children: [
                    _buildRow('Calories', '${targets?.calories ?? 2600} kcal', isDark),
                    const Divider(height: 20),
                    _buildRow('Protein', '${targets?.proteinG ?? 126} g', isDark, color: AppColors.protein),
                    const Divider(height: 20),
                    _buildRow('Carbs', '${targets?.carbsG ?? 361} g', isDark, color: AppColors.carbs),
                    const Divider(height: 20),
                    _buildRow('Fat', '${targets?.fatG ?? 72} g', isDark, color: AppColors.fat),
                    if (targets?.isCustom ?? false) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await ref.read(targetsProvider.notifier).resetToRecommended();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Targets reset to recommended values')),
                            );
                          }
                        },
                        child: const Text('Reset to Recommended'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Retention Section
              _buildSectionHeader('Data Retention', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keep history on this phone for:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [1, 3, 6].map((months) {
                        final isSelected = (profile?.retentionMonths ?? 3) == months;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text('$months mo'),
                              selected: isSelected,
                              selectedColor: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? Colors.white : AppColors.textLight),
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (selected) async {
                                if (selected && profile != null) {
                                  if (months < profile.retentionMonths) {
                                    final allMeals = await ref.read(mealRepositoryProvider).getAllMeals();
                                    final count = RetentionCleaner.countMealsToDelete(
                                      allMeals,
                                      DateTime.now(),
                                      months,
                                    );
                                    if (context.mounted) {
                                      _showRetentionConfirmDialog(context, ref, profile, months, count);
                                    }
                                  } else {
                                    ref.read(profileNotifierProvider.notifier).saveProfile(
                                          profile.copyWith(retentionMonths: months),
                                        );
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logging Reminders
              _buildSectionHeader('Daily Logging Reminders', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reminders (13:30 & 20:30)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Skip if you already logged a meal', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                    Switch(
                      value: profile?.remindersOn ?? true,
                      activeThumbColor: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                      onChanged: (val) {
                        if (profile != null) {
                          ref.read(profileNotifierProvider.notifier).saveProfile(
                                profile.copyWith(remindersOn: val),
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Not Medical Advice Statement
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1E1C) : const Color(0xFFE8EDE3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.health_and_safety_outlined, size: 22, color: AppColors.primaryGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This app provides nutritional estimates for tracking purposes only, not medical or dietary advice. Consult a healthcare professional before major dietary changes.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Account Actions
              _buildSectionHeader('Account', isDark),
              const SizedBox(height: 10),
              Material(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () async {
                          await ref.read(authRepositoryProvider).logOut();
                          if (context.mounted) {
                            context.go('/welcome');
                          }
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: AppColors.over),
                        title: const Text('Delete all local meal data', style: TextStyle(color: AppColors.over, fontWeight: FontWeight.bold)),
                        onTap: () {
                          _showDeleteDataDialog(context, ref);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_remove_outlined, color: AppColors.over),
                        title: const Text('Delete Account', style: TextStyle(color: AppColors.over, fontWeight: FontWeight.bold)),
                        onTap: () {
                          _showDeleteAccountDialog(context, ref);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : AppColors.textLight,
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color ?? (isDark ? Colors.white : AppColors.textLight),
          ),
        ),
      ],
    );
  }

  void _showRetentionConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic profile,
    int newMonths,
    int count,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Shorten History Retention?'),
        content: Text('Entries older than $newMonths month(s) will be permanently deleted ($count meal(s)). This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(profileNotifierProvider.notifier).saveProfile(
                    profile.copyWith(retentionMonths: newMonths),
                  );
              final cutoff = RetentionCleaner.getCutoffDate(DateTime.now(), newMonths);
              final cutoffStr = cutoff.toIso8601String().substring(0, 10);
              await ref.read(mealRepositoryProvider).deleteOlderThan(cutoffStr);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.over),
            child: const Text('Delete & Shorten'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Local Meal Data?'),
        content: const Text('This will delete all logged meals from this device. Your targets and profile will be kept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(mealRepositoryProvider).deleteAll();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.over),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to confirm account deletion:'),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(mealRepositoryProvider).deleteAll();
              await ref.read(authRepositoryProvider).deleteAccount(passwordController.text);
              if (context.mounted) {
                context.go('/welcome');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.over),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

