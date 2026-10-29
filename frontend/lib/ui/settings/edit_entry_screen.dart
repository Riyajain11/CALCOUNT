import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../data/models/food_item.dart';
import '../../logic/portion_scaler.dart';
import '../../providers/app_providers.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  final FoodItem item;

  const EditEntryScreen({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late TextEditingController _nameController;
  late TextEditingController _gramsController;
  late FoodItem _currentItem;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _nameController = TextEditingController(text: widget.item.name);
    _gramsController =
        TextEditingController(text: widget.item.grams.round().toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  void _onGramsChanged(String val) {
    final newGrams = double.tryParse(val);
    if (newGrams != null && newGrams > 0) {
      setState(() {
        _currentItem = PortionScaler.scaleItem(
          _currentItem.copyWith(name: _nameController.text.trim()),
          newGrams,
        );
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updatedItem = _currentItem.copyWith(
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : _currentItem.name,
      );
      await ref.read(mealRepositoryProvider).updateEntry(updatedItem);
      if (mounted) {
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text('Are you sure you want to remove "${widget.item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.over),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(mealRepositoryProvider).deleteEntry(widget.item.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Entry',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.over),
            onPressed: _delete,
            tooltip: 'Delete entry',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Food Name',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Food Name'),
              ),
              const SizedBox(height: 20),

              Text(
                'Weight (grams)',
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
                onChanged: _onGramsChanged,
                decoration: const InputDecoration(hintText: 'Weight in grams'),
              ),
              const SizedBox(height: 28),

              // Recalculated Values Card
              Text(
                'Calculated Nutrition',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Column(
                  children: [
                    _buildNutritionRow(
                      'Calories',
                      '${_currentItem.kcal.round()} kcal',
                      isDark ? AppColors.accentLime : AppColors.primaryGreen,
                      isDark,
                    ),
                    const Divider(height: 20),
                    _buildNutritionRow(
                      'Protein',
                      '${_currentItem.proteinG.round()} g',
                      AppColors.protein,
                      isDark,
                    ),
                    const Divider(height: 20),
                    _buildNutritionRow(
                      'Carbs',
                      '${_currentItem.carbsG.round()} g',
                      AppColors.carbs,
                      isDark,
                    ),
                    const Divider(height: 20),
                    _buildNutritionRow(
                      'Fat',
                      '${_currentItem.fatG.round()} g',
                      AppColors.fat,
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Update Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(
      String label, String value, Color color, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

