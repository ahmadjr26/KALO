import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final authState = ref.watch(authProvider);
    final profile = state.profile;
    final userEmail = authState.user?.email ?? profile.email;
    final isSignedIn = authState.user != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Settings & Profile',
          style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                      ),
                      child: Center(
                        child: Text(
                          userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'K',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSignedIn ? 'Supabase Account' : profile.name,
                            style: AppTypography.base.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(userEmail, style: AppTypography.xs),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.verified, size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                '${AppConfig.appName} Cloud Sync Active',
                                style: AppTypography.xs.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!isSignedIn)
                PrimaryButton(
                  label: 'Sign In / Create Account',
                  icon: Icons.login,
                  onPressed: () => context.push('/auth'),
                )
              else
                PrimaryButton(
                  label: 'Sign Out (${authState.user!.email})',
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.sm,
                  icon: Icons.logout,
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out successfully'),
                        ),
                      );
                    }
                  },
                ),
              const SizedBox(height: 24),
              Text('Daily Nutrition Targets', style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _SettingsRow(
                      label: 'Daily Calorie Budget',
                      value: '${profile.calorieBudget} kcal',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      label: 'Protein Target',
                      value: '${profile.proteinTargetG}g',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      label: 'Carbs Target',
                      value: '${profile.carbsTargetG}g',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      label: 'Fats Target',
                      value: '${profile.fatTargetG}g',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Preferences', style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _SettingsRow(
                      label: 'Units of Measurement',
                      value: 'Metric (kg/cm)',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      label: 'Apple Health / Health Connect',
                      value: 'Connected',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      label: 'Mealtime Reminders',
                      value: 'Enabled',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Run Onboarding Questionnaire',
                variant: ButtonVariant.secondary,
                size: ButtonSize.md,
                icon: Icons.refresh,
                onPressed: () => context.push('/onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.sm.copyWith(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Text(value, style: AppTypography.xs.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
