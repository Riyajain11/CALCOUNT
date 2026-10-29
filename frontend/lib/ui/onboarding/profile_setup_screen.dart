import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../data/models/targets.dart';
import '../../data/models/user_profile.dart';
import '../../logic/target_calculator.dart';
import '../../providers/app_providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _currentStep = 1; // 1: Goal, 2: Body Details, 3: Targets Review

  // Step 1: Goal
  String _selectedGoal = 'maintain'; // 'cut', 'maintain', 'bulk'

  // Step 2: Details
  final _nameController = TextEditingController(text: 'User');
  final _ageController = TextEditingController(text: '21');
  String _selectedSex = 'male';
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');
  String _selectedActivity = 'moderate';

  // Step 3: Targets Review
  Targets? _calculatedTargets;
  bool _isCustomEdit = false;
  late TextEditingController _calController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    _calController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _computeTargets() {
    final age = int.tryParse(_ageController.text) ?? 21;
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final weight = double.tryParse(_weightController.text) ?? 70.0;

    final profile = UserProfile(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'User',
      goal: _selectedGoal,
      age: age,
      sex: _selectedSex,
      heightCm: height,
      weightKg: weight,
      activity: _selectedActivity,
    );

    _calculatedTargets = TargetCalculator.calculateTargets(profile);
    _calController.text = _calculatedTargets!.calories.toString();
    _proteinController.text = _calculatedTargets!.proteinG.toString();
    _carbsController.text = _calculatedTargets!.carbsG.toString();
    _fatController.text = _calculatedTargets!.fatG.toString();
  }

  Future<void> _finishSetup() async {
    final age = int.tryParse(_ageController.text) ?? 21;
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final weight = double.tryParse(_weightController.text) ?? 70.0;

    final profile = UserProfile(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'User',
      goal: _selectedGoal,
      age: age,
      sex: _selectedSex,
      heightCm: height,
      weightKg: weight,
      activity: _selectedActivity,
    );

    await ref.read(profileNotifierProvider.notifier).saveProfile(profile);

    final finalTargets = Targets(
      calories: int.tryParse(_calController.text) ?? _calculatedTargets!.calories,
      proteinG: int.tryParse(_proteinController.text) ?? _calculatedTargets!.proteinG,
      carbsG: int.tryParse(_carbsController.text) ?? _calculatedTargets!.carbsG,
      fatG: int.tryParse(_fatController.text) ?? _calculatedTargets!.fatG,
      isCustom: _isCustomEdit,
    );

    await ref.read(targetsProvider.notifier).saveTargets(finalTargets);

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-step progress bar indicator
              Row(
                children: [
                  _buildProgressSegment(step: 1, isDark: isDark),
                  const SizedBox(width: 8),
                  _buildProgressSegment(step: 2, isDark: isDark),
                  const SizedBox(width: 8),
                  _buildProgressSegment(step: 3, isDark: isDark),
                ],
              ),
              const SizedBox(height: 24),

              // Step indicator text
              Text(
                'Step $_currentStep of 3',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),

              // Step Content
              Expanded(
                child: SingleChildScrollView(
                  child: _buildCurrentStepContent(isDark),
                ),
              ),

              // Medical Disclaimer Note
              Text(
                'Targets are estimates, not medical advice. You can edit them anytime.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Continue / Finish Button
              ElevatedButton(
                onPressed: () {
                  if (_currentStep == 1) {
                    setState(() => _currentStep = 2);
                  } else if (_currentStep == 2) {
                    _computeTargets();
                    setState(() => _currentStep = 3);
                  } else {
                    _finishSetup();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                  ),
                ),
                child: Text(
                  _currentStep == 3 ? 'Accept & Continue' : 'Continue',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSegment({required int step, required bool isDark}) {
    final isDoneOrCurrent = _currentStep >= step;
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: isDoneOrCurrent
              ? (isDark ? AppColors.accentLime : AppColors.primaryGreen)
              : (isDark ? const Color(0xFF282E29) : const Color(0xFFD6DEC9)),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Goal(isDark);
      case 2:
        return _buildStep2Details(isDark);
      case 3:
      default:
        return _buildStep3Review(isDark);
    }
  }

  // Step 1: Goal Selection
  Widget _buildStep1Goal(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are you\nfuelling for?',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.15,
            color: isDark ? Colors.white : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 28),
        _buildGoalCard(
          goalId: 'cut',
          title: 'Cut',
          subtitle: 'About 15% fewer calories',
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildGoalCard(
          goalId: 'maintain',
          title: 'Maintain',
          subtitle: 'Eat what you burn',
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildGoalCard(
          goalId: 'bulk',
          title: 'Bulk',
          subtitle: 'About 10% more calories',
          isDark: isDark,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGoalCard({
    required String goalId,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final isSelected = _selectedGoal == goalId;
    final borderColor = isSelected
        ? (isDark ? AppColors.accentLime : AppColors.primaryGreen)
        : Colors.transparent;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goalId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isDark ? AppColors.accentLime : AppColors.primaryGreen)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? const Color(0xFF3B443D) : const Color(0xFFB5BEAD)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: isDark ? Colors.black : Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Body Details
  Widget _buildStep2Details(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about\nyourself',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.15,
            color: isDark ? Colors.white : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 24),
        // Age & Sex
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Age (16 - 90)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '21'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sex for formula', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSex,
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedSex = v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Height & Weight
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Height (cm)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '175'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weight (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '70'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Activity Level
        const Text('Daily Activity Level', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedActivity,
          items: const [
            DropdownMenuItem(value: 'sedentary', child: Text('Sedentary (desk job, little exercise)')),
            DropdownMenuItem(value: 'light', child: Text('Light (1-3 days exercise/week)')),
            DropdownMenuItem(value: 'moderate', child: Text('Moderate (3-5 days exercise/week)')),
            DropdownMenuItem(value: 'active', child: Text('Active (6-7 days intense exercise)')),
            DropdownMenuItem(value: 'very_active', child: Text('Very Active (heavy physical job/athlete)')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _selectedActivity = v);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Step 3: Targets Review
  Widget _buildStep3Review(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Recommended\nDaily Targets',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: isDark ? Colors.white : AppColors.textLight,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isCustomEdit = !_isCustomEdit),
              child: Text(
                _isCustomEdit ? 'Done' : 'Edit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Target Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          child: Column(
            children: [
              _buildTargetRow('Daily Calories', _calController, 'kcal', Colors.green, isDark),
              const Divider(height: 28),
              _buildTargetRow('Protein', _proteinController, 'g', AppColors.protein, isDark),
              const Divider(height: 28),
              _buildTargetRow('Carbs', _carbsController, 'g', AppColors.carbs, isDark),
              const Divider(height: 28),
              _buildTargetRow('Fat', _fatController, 'g', AppColors.fat, isDark),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTargetRow(
    String label,
    TextEditingController controller,
    String unit,
    Color color,
    bool isDark,
  ) {
    return Row(
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
        Row(
          children: [
            if (_isCustomEdit)
              SizedBox(
                width: 80,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              )
            else
              Text(
                controller.text,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

