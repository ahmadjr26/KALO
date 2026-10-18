import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/option_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/segmented_toggle.dart';
import '../../providers/app_state_provider.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  int _currentStep = 0;
  final int _totalSteps = 8;

  // Form State
  String _goal = 'Lose Weight';
  String _barrier = 'Manual tracking takes too long';
  String _gender = 'Male';
  int _age = 26;
  int _unitIndex = 0; // 0: Metric, 1: Imperial
  double _heightCm = 180;
  double _currentWeightKg = 78.5;
  double _targetWeightKg = 73.0;
  String _pace = 'Balanced (Rabbit: -0.5 kg/week)';
  String _activity = '3-5 Workouts per week';
  bool _isHoldCommitting = false;
  bool _isGeneratingPlan = false;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _startPlanGeneration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _startPlanGeneration() async {
    setState(() => _isGeneratingPlan = true);

    // Save customized profile to Riverpod
    final updatedProfile = ref.read(appStateProvider).profile.copyWith(
          gender: _gender,
          age: _age,
          heightCm: _heightCm,
          weightKg: _currentWeightKg,
          targetWeightKg: _targetWeightKg,
          activityLevel: _activity,
        );
    ref.read(appStateProvider.notifier).updateProfile(updatedProfile);

    // Dynamic anticipation loading animation (1.5s)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _isGeneratingPlan = false);

    // Route to Hard Paywall S14
    context.push('/paywall');
  }

  @override
  Widget build(BuildContext context) {
    if (_isGeneratingPlan) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Formulating Your Plan',
                  style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calculating Basal Metabolic Rate and caloric deficit based on your biometrics...',
                  style: AppTypography.sm.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 6,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                '${_currentStep + 1}/$_totalSteps',
                style: AppTypography.xs.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildCurrentStep(),
                ),
              ),
              if (_currentStep != 7) // Step 7 uses the press & hold pledge button
                PrimaryButton(
                  label: _currentStep == 0 ? 'Let\'s Get Started' : 'Continue',
                  size: ButtonSize.lg,
                  onPressed: _nextStep,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: // Welcome & Hook
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Snap a photo.\nAI counts the calories.',
              style: AppTypography.display.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'No tedious searching. No manual weighing. Just point your camera and track in seconds.',
              style: AppTypography.base.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.center_focus_strong_rounded, size: 64, color: AppColors.accent),
                    SizedBox(height: 12),
                    Text('Visual Multi-Food Recognition', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        );

      case 1: // Primary Goal
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your primary goal?', style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('We tailor your daily caloric budget around this target.', style: AppTypography.sm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            OptionCard(
              title: 'Lose Weight',
              subtitle: 'Burn fat with a sustained caloric deficit',
              emoji: '🔥',
              isSelected: _goal == 'Lose Weight',
              onTap: () => setState(() => _goal = 'Lose Weight'),
            ),
            const SizedBox(height: 12),
            OptionCard(
              title: 'Build Muscle',
              subtitle: 'Lean mass gains with a targeted surplus',
              emoji: '💪',
              isSelected: _goal == 'Build Muscle',
              onTap: () => setState(() => _goal = 'Build Muscle'),
            ),
            const SizedBox(height: 12),
            OptionCard(
              title: 'Maintain Weight',
              subtitle: 'Balance intake and optimize metabolic health',
              emoji: '⚖️',
              isSelected: _goal == 'Maintain Weight',
              onTap: () => setState(() => _goal = 'Maintain Weight'),
            ),
            const SizedBox(height: 12),
            OptionCard(
              title: 'Eat Healthier',
              subtitle: 'Improve food quality and micronutrient density',
              emoji: '🥗',
              isSelected: _goal == 'Eat Healthier',
              onTap: () => setState(() => _goal = 'Eat Healthier'),
            ),
          ],
        );

      case 2: // Past Barriers
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What stopped you in the past?', style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Cal AI is built specifically to remove these pain points.', style: AppTypography.sm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            OptionCard(
              title: 'Manual logging takes too long',
              subtitle: 'Searching databases for every single ingredient',
              icon: Icons.timer_off_outlined,
              isSelected: _barrier == 'Manual tracking takes too long',
              onTap: () => setState(() => _barrier = 'Manual tracking takes too long'),
            ),
            const SizedBox(height: 12),
            OptionCard(
              title: 'I forget to log meals',
              subtitle: 'Complicated apps are hard to stick with daily',
              icon: Icons.notifications_paused_outlined,
              isSelected: _barrier == 'I forget to log meals',
              onTap: () => setState(() => _barrier = 'I forget to log meals'),
            ),
            const SizedBox(height: 12),
            OptionCard(
              title: 'Inaccurate portion estimates',
              subtitle: 'Not knowing how many grams are on a restaurant plate',
              icon: Icons.scale_outlined,
              isSelected: _barrier == 'Inaccurate portion estimates',
              onTap: () => setState(() => _barrier = 'Inaccurate portion estimates'),
            ),
          ],
        );

      case 3: // Gender & Age
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select your sex and age', style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Biological factors determine baseline caloric expenditure.', style: AppTypography.sm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            Row(
              children: ['Male', 'Female'].map((g) {
                final isSelected = _gender == g;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OptionCard(
                      title: g,
                      emoji: g == 'Male' ? '👨' : '👩',
                      isSelected: isSelected,
                      onTap: () => setState(() => _gender = g),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text('Your Age', style: AppTypography.base.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Age', style: AppTypography.sm.copyWith(color: AppColors.textMuted)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _age > 16 ? () => setState(() => _age--) : null,
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.accent),
                      ),
                      Text('$_age years old', style: AppTypography.md.copyWith(fontWeight: FontWeight.w800)),
                      IconButton(
                        onPressed: _age < 99 ? () => setState(() => _age++) : null,
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

      case 4: // Height & Weight
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your measurements', style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Used to calculate your Basal Metabolic Rate (BMR).', style: AppTypography.sm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            Center(
              child: SegmentedToggle(
                segments: const ['Metric (cm/kg)', 'Imperial (ft/lbs)'],
                selectedIndex: _unitIndex,
                onChanged: (idx) => setState(() => _unitIndex = idx),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Height', style: AppTypography.base.copyWith(fontWeight: FontWeight.w600)),
                      Text('${_heightCm.toInt()} cm', style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800, color: AppColors.accent)),
                    ],
                  ),
                  Slider(
                    value: _heightCm,
                    min: 140,
                    max: 220,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.border,
                    onChanged: (val) => setState(() => _heightCm = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Weight', style: AppTypography.base.copyWith(fontWeight: FontWeight.w600)),
                      Text('${_currentWeightKg.toStringAsFixed(1)} kg', style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800, color: AppColors.accent)),
                    ],
                  ),
                  Slider(
                    value: _currentWeightKg,
                    min: 40,
                    max: 160,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.border,
                    onChanged: (val) => setState(() => _currentWeightKg = val),
                  ),
                ],
              ),
            ),
          ],
        );

      case 5: // Target Weight & Pace
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your target weight?', style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Select your desired pace for sustainable results.', style: AppTypography.sm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target Goal', style: AppTypography.base.copyWith(fontWeight: FontWeight.w600)),
                      Text('${_targetWeightKg.toStringAsFixed(1)} kg', style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800, color: AppColors.accent)),
                    ],
                  ),
                  Slider(
                    value: _targetWeightKg,
                    min: 40,
                    max: 140,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.border,
                    onChanged: (val) => setState(() => _targetWeightKg = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Deficit Pace', style: AppTypography.base.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            OptionCard(
              title: 'Sloth: Gentle & Steady',
              subtitle: '0.25 kg / week • Minimal hunger deficit',
              emoji: '🦥',
              isSelected: _pace.contains('Sloth'),
              onTap: () => setState(() => _pace = 'Steady (Sloth)'),
            ),
            const SizedBox(height: 10),
            OptionCard(
              title: 'Rabbit: Balanced',
              subtitle: '0.50 kg / week • Recommended sweet spot',
              emoji: '🐇',
              isSelected: _pace.contains('Rabbit'),
              onTap: () => setState(() => _pace = 'Balanced (Rabbit: -0.5 kg/week)'),
            ),
            const SizedBox(height: 10),
            OptionCard(
              title: 'Panther: Aggressive',
              subtitle: '0.80 kg / week • Strict caloric ceiling',
              emoji: '🐆',
              isSelected: _pace.contains('Panther'),
              onTap: () => setState(() => _pace = 'Fast (Panther)'),
            ),
          ],
        );

      case 6: // Activity Level
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity & workout frequency', style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Multiplies your BMR to calculate Total Daily Energy Expenditure (TDEE).', style: AppTypography.sm.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            OptionCard(
              title: '0 - 2 workouts / week',
              subtitle: 'Mostly desk work or sedentary routine',
              emoji: '🚶',
              isSelected: _activity.contains('0 - 2'),
              onTap: () => setState(() => _activity = '0 - 2 workouts / week'),
            ),
            const SizedBox(height: 12),
            OptionCard(
              title: '3 - 5 workouts / week',
              subtitle: 'Moderate gym, jogging, or sports',
              emoji: '🏃',
              isSelected: _activity.contains('3 - 5'),
              onTap: () => setState(() => _activity = '3-5 Workouts per week'),
            ),
            const SizedBox(height: 12),
            OptionCard(
              title: '6+ workouts / week',
              subtitle: 'High-intensity athletic training',
              emoji: '🏋️',
              isSelected: _activity.contains('6+'),
              onTap: () => setState(() => _activity = '6+ workouts per week'),
            ),
          ],
        );

      case 7: // Commitment Pledge Contract
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text('🤝', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Your Commitment Pledge',
              style: AppTypography.xl.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Calorie counting only works if you stick with it. I pledge to log my meals for at least 14 consecutive days to see real, proven results.',
              style: AppTypography.base.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Press and Hold Tactile Commitment Button
            GestureDetector(
              onTapDown: (_) {
                setState(() => _isHoldCommitting = true);
              },
              onTapUp: (_) {
                setState(() => _isHoldCommitting = false);
              },
              onTapCancel: () {
                setState(() => _isHoldCommitting = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.accent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(_isHoldCommitting ? 120 : 40),
                      blurRadius: _isHoldCommitting ? 28 : 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app, size: 36, color: AppColors.accent),
                      const SizedBox(height: 6),
                      Text(
                        'PRESS TO COMMIT',
                        style: AppTypography.xs.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _startPlanGeneration,
              child: Text(
                'Skip to Plan',
                style: AppTypography.xs.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
