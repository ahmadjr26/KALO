import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/kalo_card.dart';
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

  String _goal = 'Lose Weight';
  String _barrier = 'too_long';
  String _gender = 'Male';
  int _age = 26;
  int _unitIndex = 0;
  double _heightCm = 178;
  double _currentWeightKg = 78.0;
  double _targetWeightKg = 72.0;
  String _pace = 'balanced';
  String _activity = '3-5';

  int _calculateBmr() {
    final double weight = _currentWeightKg;
    final double height = _heightCm;
    final int age = _age;
    if (_gender == 'Female') {
      return ((10 * weight) + (6.25 * height) - (5 * age) - 161).round();
    }
    return ((10 * weight) + (6.25 * height) - (5 * age) + 5).round();
  }

  int _calculateTdee() {
    final bmr = _calculateBmr();
    double multiplier = 1.2;
    if (_activity == '3-5') {
      multiplier = 1.45;
    } else if (_activity == '6+') {
      multiplier = 1.7;
    }
    return (bmr * multiplier).round();
  }

  int _calculateCalorieBudget() {
    final tdee = _calculateTdee();
    int adjustment = 0;
    if (_goal == 'Lose Weight') {
      if (_pace == 'steady') {
        adjustment = -250;
      } else if (_pace == 'fast') {
        adjustment = -750;
      } else {
        adjustment = -500;
      }
    } else if (_goal == 'Build Muscle') {
      adjustment = 300;
    } else {
      adjustment = 0;
    }
    final int minCal = _gender == 'Female' ? 1200 : 1500;
    return (tdee + adjustment).clamp(minCal, 5000);
  }

  int _calculateProteinG() {
    final double weight = _currentWeightKg;
    double factor = 1.8;
    if (_goal == 'Build Muscle') {
      factor = 2.2;
    } else if (_goal == 'Lose Weight') {
      factor = 2.0;
    }
    return (weight * factor).round();
  }

  int _calculateFatG() {
    final budget = _calculateCalorieBudget();
    return ((budget * 0.25) / 9).round();
  }

  int _calculateCarbsG() {
    final budget = _calculateCalorieBudget();
    final proteinCal = _calculateProteinG() * 4;
    final fatCal = _calculateFatG() * 9;
    final rem = budget - proteinCal - fatCal;
    return (rem > 0 ? rem / 4 : 50).round();
  }

  int _calculateWeeksToGoal() {
    final diff = (_currentWeightKg - _targetWeightKg).abs();
    double weeklyRate = 0.5;
    if (_pace == 'steady') {
      weeklyRate = 0.25;
    } else if (_pace == 'fast') {
      weeklyRate = 0.75;
    }
    final weeks = (diff / weeklyRate).ceil();
    return weeks > 0 ? weeks : 1;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _applyPlanAndProceed();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _applyPlanAndProceed() {
    final budget = _calculateCalorieBudget();
    final protein = _calculateProteinG();
    final carbs = _calculateCarbsG();
    final fat = _calculateFatG();

    final updatedProfile = ref.read(appStateProvider).profile.copyWith(
          gender: _gender,
          age: _age,
          heightCm: _heightCm,
          weightKg: _currentWeightKg,
          targetWeightKg: _targetWeightKg,
          activityLevel: _activity == '6+'
              ? 'Athletic (6+ sessions)'
              : (_activity == '3-5' ? 'Active (3-5 sessions)' : 'Sedentary (0-2 sessions)'),
          calorieBudget: budget,
          proteinTargetG: protein,
          carbsTargetG: carbs,
          fatTargetG: fat,
        );
    ref.read(appStateProvider.notifier).updateProfile(updatedProfile);
    context.push('/paywall');
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic(ref);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(isArabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded),
          onPressed: _previousStep,
        ),
        title: Text(
          '${_currentStep + 1}/$_totalSteps',
          style: AppTypography.sm.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: TextButton.icon(
              onPressed: () => ref.read(localeProvider.notifier).toggleLanguage(),
              icon: const Icon(Icons.language_rounded, size: 16, color: AppColors.accent),
              label: Text(
                context.tr(ref, 'switch_language'),
                style: AppTypography.xs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 3,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildCurrentStep(isArabic),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: _currentStep == 0
                    ? context.tr(ref, 'onboarding_get_started')
                    : (_currentStep == _totalSteps - 1
                        ? context.tr(ref, 'start_journey')
                        : context.tr(ref, 'continue_label')),
                size: ButtonSize.lg,
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(bool isArabic) {
    switch (_currentStep) {
      case 0:
        return _buildStepWelcome(isArabic);
      case 1:
        return _buildStepGoal(isArabic);
      case 2:
        return _buildStepBarrier(isArabic);
      case 3:
        return _buildStepBio(isArabic);
      case 4:
        return _buildStepMeasurements(isArabic);
      case 5:
        return _buildStepActivity(isArabic);
      case 6:
        return _buildStepTarget(isArabic);
      case 7:
        return _buildStepPlan(isArabic);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepWelcome(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(25),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accent.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                context.tr(ref, 'onboarding_welcome_badge'),
                style: AppTypography.xs.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.tr(ref, 'onboarding_welcome_title'),
          style: isArabic
              ? AppTypography.displayArabic().copyWith(fontWeight: FontWeight.w900)
              : AppTypography.display.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          context.tr(ref, 'onboarding_welcome_subtitle'),
          style: isArabic
              ? AppTypography.baseArabic(AppColors.textMuted)
              : AppTypography.base.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            context.tr(ref, 'onboarding_demo_label'),
                            style: AppTypography.xs.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 12, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          context.tr(ref, 'onboarding_demo_confidence'),
                          style: AppTypography.xs.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderInput.withAlpha(60)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant_rounded,
                                size: 26,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              context.tr(ref, 'onboarding_demo_dish'),
                              style: AppTypography.sm.copyWith(fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.accent, width: 2),
                            left: BorderSide(color: AppColors.accent, width: 2),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.accent, width: 2),
                            right: BorderSide(color: AppColors.accent, width: 2),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.accent, width: 2),
                            left: BorderSide(color: AppColors.accent, width: 2),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.accent, width: 2),
                            right: BorderSide(color: AppColors.accent, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMacroBadge(
                      context.tr(ref, 'onboarding_demo_cal'),
                      AppColors.calories,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroBadge(
                      context.tr(ref, 'onboarding_demo_p'),
                      AppColors.protein,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroBadge(
                      context.tr(ref, 'onboarding_demo_c'),
                      AppColors.carbs,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroBadge(
                      context.tr(ref, 'onboarding_demo_f'),
                      AppColors.fat,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildStepGoal(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_goal_title'),
          style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_goal_subtitle'),
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        OptionCard(
          title: context.tr(ref, 'goal_lose_weight'),
          subtitle: context.tr(ref, 'goal_lose_weight_desc'),
          icon: Icons.trending_down_rounded,
          isSelected: _goal == 'Lose Weight',
          onTap: () => setState(() => _goal = 'Lose Weight'),
        ),
        const SizedBox(height: 12),
        OptionCard(
          title: context.tr(ref, 'goal_build_muscle'),
          subtitle: context.tr(ref, 'goal_build_muscle_desc'),
          icon: Icons.fitness_center_rounded,
          isSelected: _goal == 'Build Muscle',
          onTap: () => setState(() => _goal = 'Build Muscle'),
        ),
        const SizedBox(height: 12),
        OptionCard(
          title: context.tr(ref, 'goal_maintain'),
          subtitle: context.tr(ref, 'goal_maintain_desc'),
          icon: Icons.balance_rounded,
          isSelected: _goal == 'Maintain Weight',
          onTap: () => setState(() => _goal = 'Maintain Weight'),
        ),
        const SizedBox(height: 12),
        OptionCard(
          title: context.tr(ref, 'goal_eat_healthier'),
          subtitle: context.tr(ref, 'goal_eat_healthier_desc'),
          icon: Icons.eco_rounded,
          isSelected: _goal == 'Eat Healthier',
          onTap: () => setState(() => _goal = 'Eat Healthier'),
        ),
      ],
    );
  }

  Widget _buildStepBarrier(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_barrier_title'),
          style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_barrier_subtitle'),
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        OptionCard(
          title: context.tr(ref, 'barrier_too_long'),
          subtitle: context.tr(ref, 'barrier_too_long_desc'),
          icon: Icons.schedule_rounded,
          isSelected: _barrier == 'too_long',
          onTap: () => setState(() => _barrier = 'too_long'),
        ),
        const SizedBox(height: 12),
        OptionCard(
          title: context.tr(ref, 'barrier_forget'),
          subtitle: context.tr(ref, 'barrier_forget_desc'),
          icon: Icons.notifications_off_outlined,
          isSelected: _barrier == 'forget',
          onTap: () => setState(() => _barrier = 'forget'),
        ),
        const SizedBox(height: 12),
        OptionCard(
          title: context.tr(ref, 'barrier_portions'),
          subtitle: context.tr(ref, 'barrier_portions_desc'),
          icon: Icons.straighten_rounded,
          isSelected: _barrier == 'portions',
          onTap: () => setState(() => _barrier = 'portions'),
        ),
      ],
    );
  }

  Widget _buildStepBio(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_bio_title'),
          style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_bio_subtitle'),
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OptionCard(
                title: context.tr(ref, 'gender_male'),
                icon: Icons.male_rounded,
                isSelected: _gender == 'Male',
                onTap: () => setState(() => _gender = 'Male'),
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OptionCard(
                title: context.tr(ref, 'gender_female'),
                icon: Icons.female_rounded,
                isSelected: _gender == 'Female',
                onTap: () => setState(() => _gender = 'Female'),
                isCompact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          context.tr(ref, 'age_title'),
          style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_age ${context.tr(ref, 'years_old')}',
                style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _age > 16 ? () => setState(() => _age--) : null,
                    icon: const Icon(Icons.remove_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.text,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _age < 99 ? () => setState(() => _age++) : null,
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent.withAlpha(25),
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepMeasurements(bool isArabic) {
    final isImperial = _unitIndex == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_measurements_title'),
          style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_measurements_subtitle'),
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        Center(
          child: SegmentedToggle(
            segments: [
              context.tr(ref, 'unit_metric'),
              context.tr(ref, 'unit_imperial'),
            ],
            selectedIndex: _unitIndex,
            onChanged: (idx) => setState(() => _unitIndex = idx),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(ref, 'height_label'),
                    style: AppTypography.base.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    isImperial
                        ? '${(_heightCm / 30.48).floor()}\' ${((_heightCm % 30.48) / 2.54).round()}"'
                        : '${_heightCm.toInt()} cm',
                    style: AppTypography.lg.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.accent,
                  overlayColor: AppColors.accent.withAlpha(30),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _heightCm,
                  min: 140,
                  max: 220,
                  onChanged: (val) => setState(() => _heightCm = val),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(ref, 'weight_label'),
                    style: AppTypography.base.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    isImperial
                        ? '${(_currentWeightKg * 2.20462).toStringAsFixed(1)} lbs'
                        : '${_currentWeightKg.toStringAsFixed(1)} kg',
                    style: AppTypography.lg.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.accent,
                  overlayColor: AppColors.accent.withAlpha(30),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _currentWeightKg,
                  min: 40,
                  max: 180,
                  onChanged: (val) => setState(() => _currentWeightKg = val),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepActivity(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_activity_title'),
          style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_activity_subtitle'),
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        OptionCard(
          title: context.tr(ref, 'activity_light'),
          subtitle: context.tr(ref, 'activity_light_desc'),
          icon: Icons.directions_walk_rounded,
          isSelected: _activity == '0-2',
          onTap: () => setState(() => _activity = '0-2'),
        ),
        const SizedBox(height: 12),
        OptionCard(
          title: context.tr(ref, 'activity_moderate'),
          subtitle: context.tr(ref, 'activity_moderate_desc'),
          icon: Icons.directions_run_rounded,
          isSelected: _activity == '3-5',
          onTap: () => setState(() => _activity = '3-5'),
        ),
        const SizedBox(height: 12),
        OptionCard(
          title: context.tr(ref, 'activity_intense'),
          subtitle: context.tr(ref, 'activity_intense_desc'),
          icon: Icons.bolt_rounded,
          isSelected: _activity == '6+',
          onTap: () => setState(() => _activity = '6+'),
        ),
      ],
    );
  }

  Widget _buildStepTarget(bool isArabic) {
    final double diffKg = _targetWeightKg - _currentWeightKg;
    final String diffSign = diffKg > 0 ? '+${diffKg.toStringAsFixed(1)}' : diffKg.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_target_title'),
          style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_target_subtitle'),
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr(ref, 'target_weight_label'),
                      style: AppTypography.base.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Δ $diffSign kg',
                          style: AppTypography.xs.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_targetWeightKg.toStringAsFixed(1)} kg',
                        style: AppTypography.lg.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.accent,
                  overlayColor: AppColors.accent.withAlpha(30),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _targetWeightKg,
                  min: 40,
                  max: 160,
                  onChanged: (val) => setState(() => _targetWeightKg = val),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OptionCard(
          title: context.tr(ref, 'pace_steady'),
          subtitle: context.tr(ref, 'pace_steady_desc'),
          icon: Icons.spa_outlined,
          isSelected: _pace == 'steady',
          onTap: () => setState(() => _pace = 'steady'),
        ),
        const SizedBox(height: 10),
        OptionCard(
          title: context.tr(ref, 'pace_balanced'),
          subtitle: context.tr(ref, 'pace_balanced_desc'),
          icon: Icons.verified_rounded,
          isSelected: _pace == 'balanced',
          onTap: () => setState(() => _pace = 'balanced'),
        ),
        const SizedBox(height: 10),
        OptionCard(
          title: context.tr(ref, 'pace_fast'),
          subtitle: context.tr(ref, 'pace_fast_desc'),
          icon: Icons.speed_rounded,
          isSelected: _pace == 'fast',
          onTap: () => setState(() => _pace = 'fast'),
        ),
      ],
    );
  }

  Widget _buildStepPlan(bool isArabic) {
    final bmr = _calculateBmr();
    final tdee = _calculateTdee();
    final budget = _calculateCalorieBudget();
    final protein = _calculateProteinG();
    final carbs = _calculateCarbsG();
    final fat = _calculateFatG();
    final weeks = _calculateWeeksToGoal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_plan_title'),
          style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(ref, 'onboarding_plan_subtitle'),
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        KaloCard(
          hasGlow: true,
          padding: const EdgeInsetsDirectional.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr(ref, 'daily_budget'),
                      style: AppTypography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _goal,
                      style: AppTypography.xs.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$budget',
                    style: AppTypography.display.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'kcal / day',
                    style: AppTypography.base.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(ref, 'metric_bmr'),
                          style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$bmr kcal',
                          style: AppTypography.base.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.border),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(ref, 'metric_tdee'),
                          style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$tdee kcal',
                          style: AppTypography.base.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(ref, 'daily_macros'),
                style: AppTypography.sm.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPlanMacroItem(
                      'Protein',
                      '${protein}g',
                      AppColors.protein,
                      '${((protein * 4 / budget) * 100).round()}%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPlanMacroItem(
                      'Carbs',
                      '${carbs}g',
                      AppColors.carbs,
                      '${((carbs * 4 / budget) * 100).round()}%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPlanMacroItem(
                      'Fat',
                      '${fat}g',
                      AppColors.fat,
                      '${((fat * 9 / budget) * 100).round()}%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.flag_rounded, color: AppColors.accent, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(ref, 'projected_timeline'),
                      style: AppTypography.sm.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$weeks weeks of structured consistency',
                      style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanMacroItem(String label, String grams, Color color, String percent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Text(
                percent,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            grams,
            style: AppTypography.base.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.xs.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
