import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_state_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedPlan = 0; // 0: Annual (3-Day Free Trial), 1: Monthly

  void _onDismissAttempt() {
    // Show exit-intent discount roulette wheel
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DiscountWheelDialog(),
    );
  }

  void _subscribe() {
    // Activate subscription in state
    final current = ref.read(appStateProvider).profile;
    ref.read(appStateProvider.notifier).updateProfile(
          current.copyWith(isSubscribed: true),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        content: Text('🎉 Welcome to Cal AI Unlimited!'),
      ),
    );

    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _onDismissAttempt,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Restore Purchases
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchases restored successfully.')),
              );
              context.go('/dashboard');
            },
            child: Text(
              'Restore',
              style: AppTypography.xs.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'UNLIMITED AI ACCESS',
                          style: AppTypography.xs.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Achieve Your Goal Faster with Cal AI',
                        style: AppTypography.display.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 24),

                      // Feature Bullet Points
                      _FeatureBullet(
                        icon: Icons.camera_alt_outlined,
                        title: 'Unlimited AI Photo Scanning',
                        subtitle: 'Snap any dish and count calories instantly',
                      ),
                      const SizedBox(height: 16),
                      _FeatureBullet(
                        icon: Icons.pie_chart_outline,
                        title: 'Accurate Macro & Portion Analysis',
                        subtitle: 'Dynamic protein, carbs, and fat breakdown',
                      ),
                      const SizedBox(height: 16),
                      _FeatureBullet(
                        icon: Icons.qr_code_scanner,
                        title: 'Barcode & Nutrition Label OCR',
                        subtitle: 'Quickly scan packaged grocery items',
                      ),
                      const SizedBox(height: 16),
                      _FeatureBullet(
                        icon: Icons.mic_none_outlined,
                        title: 'Voice & Natural Language Dictation',
                        subtitle: 'Describe meals with natural speech',
                      ),
                      const SizedBox(height: 32),

                      // Annual Plan Card (Featured)
                      GestureDetector(
                        onTap: () => setState(() => _selectedPlan = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _selectedPlan == 0
                                ? AppColors.surfaceElevated
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedPlan == 0
                                  ? AppColors.accent
                                  : AppColors.border,
                              width: _selectedPlan == 0 ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'SAVE 65% • BEST VALUE',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _selectedPlan == 0
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: _selectedPlan == 0
                                        ? AppColors.accent
                                        : AppColors.borderInput,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '3 Days Free Trial',
                                        style: AppTypography.base.copyWith(
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        'Then \$29.99 / year (\$2.49/mo)',
                                        style: AppTypography.xs,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '\$2.49/mo',
                                    style: AppTypography.lg.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.accent),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Monthly Plan Card
                      GestureDetector(
                        onTap: () => setState(() => _selectedPlan = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _selectedPlan == 1
                                ? AppColors.surfaceElevated
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedPlan == 1
                                  ? AppColors.accent
                                  : AppColors.border,
                              width: _selectedPlan == 1 ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Monthly Subscription',
                                    style: AppTypography.base.copyWith(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text('Billed every month',
                                      style: AppTypography.xs),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '\$9.99/mo',
                                    style: AppTypography.base.copyWith(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _selectedPlan == 1
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: _selectedPlan == 1
                                        ? AppColors.accent
                                        : AppColors.borderInput,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                label: _selectedPlan == 0
                    ? 'Start 3-Day Free Trial'
                    : 'Unlock Cal AI Monthly',
                size: ButtonSize.lg,
                onPressed: _subscribe,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Cancel anytime in App Store settings. No commitment.',
                  style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.accent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                style: AppTypography.xs.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Exit-intent Discount Roulette Wheel Dialog
class _DiscountWheelDialog extends StatefulWidget {
  const _DiscountWheelDialog();

  @override
  State<_DiscountWheelDialog> createState() => _DiscountWheelDialogState();
}

class _DiscountWheelDialogState extends State<_DiscountWheelDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _hasSpun = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin() {
    setState(() => _hasSpun = true);
    _spinController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(30),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'ONE-TIME OFFER',
                    style: AppTypography.xs.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/dashboard');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Wait! Spin to Save',
              style: AppTypography.xl.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Spin the wheel to unlock an exclusive discount off Cal AI Unlimited.',
              style: AppTypography.xs.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Animated Roulette Wheel
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                final double angle = _spinController.value * 2 * math.pi * 5;
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          AppColors.accent,
                          AppColors.warning,
                          AppColors.protein,
                          AppColors.carbs,
                          AppColors.accent,
                        ],
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        '80% OFF',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            if (!_hasSpun)
              PrimaryButton(
                label: 'Spin Now 🎯',
                size: ButtonSize.md,
                onPressed: _spin,
              )
            else if (_spinController.isCompleted) ...[
              Text(
                '🎉 YOU UNLOCKED 80% OFF!',
                style: AppTypography.md.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Get Cal AI for just \$1.99/mo',
                style: AppTypography.sm.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Claim 80% Discount',
                size: ButtonSize.md,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/dashboard');
                },
              ),
            ] else ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
