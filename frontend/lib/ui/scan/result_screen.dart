import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/date_helpers.dart';
import '../../data/models/food_item.dart';
import '../../data/models/meal.dart';
import '../../data/models/scan_result.dart';
import '../../logic/portion_scaler.dart';
import '../../providers/app_providers.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final ScanResult scanResult;

  const ResultScreen({
    super.key,
    required this.scanResult,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late List<FoodItem> _baseItems;
  late List<FoodItem> _currentItems;
  int _portionPercent = 100;
  late String _selectedMealType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _baseItems = List.from(widget.scanResult.items);
    _currentItems = List.from(widget.scanResult.items);
    _selectedMealType = DateHelpers.defaultMealType(DateTime.now());
  }

  void _adjustPortion(int delta) {
    final newPercent = (_portionPercent + delta).clamp(10, 300);
    if (newPercent != _portionPercent) {
      setState(() {
        _portionPercent = newPercent;
        _currentItems = PortionScaler.scaleByPercentage(
          _currentItems,
          _baseItems,
          _portionPercent.toDouble(),
        );
      });
    }
  }

  void _editItemDialog(int index) {
    final item = _currentItems[index];
    final nameController = TextEditingController(text: item.name);
    final gramsController = TextEditingController(text: item.grams.round().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        title: const Text('Edit Item', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Food Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gramsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Weight (grams)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentItems.removeAt(index);
                _baseItems.removeAt(index);
              });
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.over)),
          ),
          ElevatedButton(
            onPressed: () {
              final newGrams = double.tryParse(gramsController.text) ?? item.grams;
              final newName = nameController.text.trim();
              final updatedItem = PortionScaler.scaleItem(
                item.copyWith(name: newName.isNotEmpty ? newName : item.name),
                newGrams,
              );
              setState(() {
                _currentItems[index] = updatedItem;
                _baseItems[index] = updatedItem; // update baseline
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMeal() async {
    if (_currentItems.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final todayStr = DateHelpers.toLocalDayString(now);

      final meal = Meal(
        entryDate: todayStr,
        loggedAt: now,
        mealType: _selectedMealType,
        source: 'ai',
        provider: widget.scanResult.provider,
        promptVersion: widget.scanResult.promptVersion,
        confidence: widget.scanResult.confidence,
        items: _currentItems,
      );

      await ref.read(mealRepositoryProvider).saveMeal(meal);

      if (mounted) {
        context.go('/home');
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
    final totalKcal = _currentItems.fold(0.0, (s, i) => s + i.kcal).round();
    final totalProtein = _currentItems.fold(0.0, (s, i) => s + i.proteinG).round();
    final totalCarbs = _currentItems.fold(0.0, (s, i) => s + i.carbsG).round();
    final totalFat = _currentItems.fold(0.0, (s, i) => s + i.fatG).round();
    final scansLeft = widget.scanResult.scansRemaining;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePadding,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E281F) : const Color(0xFFE5EEDF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$scansLeft scans left today',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Thumbnail Preview
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF222824),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Plate illustration
                  Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF333C36),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 25,
                          left: 25,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFDE9343),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 25,
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFBE7129),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 18,
                          child: Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF70983A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reticle corners
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _buildSmallCorner(true, true, isDark),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _buildSmallCorner(true, false, isDark),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: _buildSmallCorner(false, true, isDark),
                  ),
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: _buildSmallCorner(false, false, isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Results Card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: 3 items · 570 kcal + AI estimate chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentItems.length} items · $totalKcal kcal',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD49B24),
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'AI estimate',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD49B24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List of Detected Items
                      ...List.generate(_currentItems.length, (index) {
                        final item = _currentItems[index];
                        return InkWell(
                          onTap: () => _editItemDialog(index),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : AppColors.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.portionLabel ?? '${item.grams.round()} g',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${item.kcal.round()} kcal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 18),

                      // Macro Total Chips: Protein, Carbs, Fat
                      Row(
                        children: [
                          Expanded(
                            child: _buildMacroChip(
                              label: 'Protein',
                              value: '$totalProtein g',
                              color: AppColors.protein,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMacroChip(
                              label: 'Carbs',
                              value: '$totalCarbs g',
                              color: AppColors.carbs,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMacroChip(
                              label: 'Fat',
                              value: '$totalFat g',
                              color: AppColors.fat,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Portion Stepper Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Portion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161817) : const Color(0xFFDCE3D4),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => _adjustPortion(-10),
                                  icon: const Icon(Icons.remove, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  color: isDark ? Colors.white : AppColors.textLight,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    '$_portionPercent%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : AppColors.textLight,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _adjustPortion(10),
                                  icon: const Icon(Icons.add, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  color: isDark ? Colors.white : AppColors.textLight,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Rescan & Save Buttons Row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                                ),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderSubtle,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'Rescan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveMeal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Save to today',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161817) : const Color(0xFFDCE3D4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
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
      ),
    );
  }

  Widget _buildSmallCorner(bool isTop, bool isLeft, bool isDark) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: isDark ? AppColors.accentLime : const Color(0xFF67B73F), width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: isDark ? AppColors.accentLime : const Color(0xFF67B73F), width: 3)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: isDark ? AppColors.accentLime : const Color(0xFF67B73F), width: 3)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: isDark ? AppColors.accentLime : const Color(0xFF67B73F), width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}

