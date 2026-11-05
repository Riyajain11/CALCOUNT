import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/date_helpers.dart';
import '../../data/models/food_item.dart';
import '../../data/models/meal.dart';
import '../../providers/app_providers.dart';

class ManualAddScreen extends ConsumerStatefulWidget {
  const ManualAddScreen({super.key});

  @override
  ConsumerState<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends ConsumerState<ManualAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _kcalController = TextEditingController();
  final _gramsController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  late String _mealType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mealType = DateHelpers.defaultMealType(DateTime.now());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    _gramsController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final todayStr = DateHelpers.toLocalDayString(now);

      final kcal = double.parse(_kcalController.text.trim());
      final grams = double.tryParse(_gramsController.text.trim()) ?? 100.0;
      final protein = double.tryParse(_proteinController.text.trim()) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text.trim()) ?? 0.0;
      final fat = double.tryParse(_fatController.text.trim()) ?? 0.0;

      final item = FoodItem(
        name: _nameController.text.trim(),
        grams: grams,
        kcal: kcal,
        proteinG: protein,
        carbsG: carbs,
        fatG: fat,
      );

      final meal = Meal(
        entryDate: todayStr,
        loggedAt: now,
        mealType: _mealType,
        source: 'manual',
        items: [item],
      );

      await ref.read(mealRepositoryProvider).saveMeal(meal);

      if (mounted) {
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal Manually', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Type Selector
                Text(
                  'Meal Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['breakfast', 'lunch', 'snack', 'dinner'].map((type) {
                    final isSelected = _mealType == type;
                    return ChoiceChip(
                      label: Text(DateHelpers.formatMealType(type)),
                      selected: isSelected,
                      selectedColor: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white : AppColors.textLight),
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _mealType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Meal Name
                Text(
                  'Food / Meal Name *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. Dal Makhani, 2 Roti'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter food name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Calories (Kcal)
                Text(
                  'Calories (kcal) *',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _kcalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 450'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter calories';
                    }
                    final num = double.tryParse(val);
                    if (num == null || num < 0) {
                      return 'Enter a valid calorie number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Weight (grams)
                Text(
                  'Portion Weight (grams)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _gramsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 150'),
                ),
                const SizedBox(height: 24),

                // Optional Macros
                Text(
                  'Macros (optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Protein (g)', style: TextStyle(color: AppColors.protein, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _proteinController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Carbs (g)', style: TextStyle(color: AppColors.carbs, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _carbsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fat (g)', style: TextStyle(color: AppColors.fat, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _fatController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '0'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Save Button
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Save to today'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

