import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/profile_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showEditTargetsDialog(BuildContext context, WidgetRef ref, int cal, int p, int c, int f) {
    final lang = ref.read(localeProvider);
    final isAr = lang == AppLanguage.arabic;
    final calCtrl = TextEditingController(text: cal.toString());
    final pCtrl = TextEditingController(text: p.toString());
    final cCtrl = TextEditingController(text: c.toString());
    final fCtrl = TextEditingController(text: f.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          isAr ? 'تعديل الأهداف الغذائية' : 'Edit Nutrition Goals',
          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  labelText: AppStrings.get('target_calories', lang),
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  labelText: AppStrings.get('target_protein', lang),
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  labelText: AppStrings.get('target_carbs', lang),
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  labelText: AppStrings.get('target_fat', lang),
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.get('cancel', lang),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCal = int.tryParse(calCtrl.text) ?? cal;
              final newP = int.tryParse(pCtrl.text) ?? p;
              final newC = int.tryParse(cCtrl.text) ?? c;
              final newF = int.tryParse(fCtrl.text) ?? f;

              final authState = ref.read(authProvider);
              if (authState.user != null) {
                final updated = ProfileModel(
                  id: authState.user!.id,
                  weight: authState.profile?.weight ?? 75.0,
                  height: authState.profile?.height ?? 175.0,
                  age: authState.profile?.age ?? 25,
                  goal: authState.profile?.goal ?? 'maintain',
                  dailyCalories: newCal,
                  dailyProtein: newP.toDouble(),
                  dailyCarbs: newC.toDouble(),
                  dailyFat: newF.toDouble(),
                );
                await ref.read(authProvider.notifier).updateProfile(updated);
              } else {
                final cur = ref.read(appStateProvider).profile;
                ref.read(appStateProvider.notifier).updateProfile(
                      cur.copyWith(
                        calorieBudget: newCal,
                        proteinTargetG: newP,
                        carbsTargetG: newC,
                        fatTargetG: newF,
                      ),
                    );
              }

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.accent,
                    content: Text(
                      AppStrings.get('goals_saved', lang),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
            ),
            child: Text(AppStrings.get('confirm', lang)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final authState = ref.watch(authProvider);
    final currentLang = ref.watch(localeProvider);
    final isAr = currentLang == AppLanguage.arabic;

    final profile = state.profile;
    final userEmail = authState.user?.email ?? '';
    final isSignedIn = authState.user != null;
    final calorieBudget = authState.profile?.dailyCalories ?? profile.calorieBudget;
    final proteinTarget = authState.profile?.dailyProtein.round() ?? profile.proteinTargetG;
    final carbsTarget = authState.profile?.dailyCarbs.round() ?? profile.carbsTargetG;
    final fatTarget = authState.profile?.dailyFat.round() ?? profile.fatTargetG;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          AppStrings.get('settings_title', currentLang),
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      // Centered Avatar with Edit Pen Badge matching Figma Frame 1:1223 & 1:1228
                      Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFCDE26D).withAlpha(60),
                              border: Border.all(color: const Color(0xFFCDE26D), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'K',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 34,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(15),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.edit_rounded, size: 14, color: AppColors.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isSignedIn ? (userEmail.split('@').first) : (isAr ? 'حساب ضيف' : 'Guest User'),
                        style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        userEmail.isNotEmpty ? '@${userEmail.split('@').first}' : '@kalo_guest',
                        style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSignedIn ? AppColors.accentSubtle : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSignedIn ? Icons.verified : Icons.cloud_off,
                              size: 13,
                              color: isSignedIn ? AppColors.accent : AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isSignedIn
                                  ? (isAr ? 'المزامنة السحابية مفعّلة' : 'Cloud Sync Active')
                                  : (isAr ? 'وضع محلي غير متصل' : 'Local Offline Mode'),
                              style: AppTypography.xs.copyWith(
                                color: isSignedIn ? AppColors.accent : AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isSignedIn)
                PrimaryButton(
                  label: AppStrings.get('sign_in', currentLang),
                  icon: Icons.login,
                  onPressed: () => context.push('/auth'),
                )
              else
                PrimaryButton(
                  label: AppStrings.get('sign_out', currentLang),
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.sm,
                  icon: Icons.logout,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text(
                          AppStrings.get('sign_out', currentLang),
                          style: const TextStyle(color: AppColors.text),
                        ),
                        content: Text(
                          AppStrings.get('sign_out_confirm', currentLang),
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              AppStrings.get('cancel', currentLang),
                              style: const TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(AppStrings.get('confirm', currentLang)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/auth');
                      }
                    }
                  },
                ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('language_switch', currentLang),
                style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
onTap: () => ref.read(localeProvider.notifier).setLanguage(AppLanguage.arabic),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isAr ? AppColors.surfaceElevated : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'العربية (RTL)',
                                style: TextStyle(
                                  color: isAr ? AppColors.accent : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (isAr) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.check, size: 16, color: AppColors.accent),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
onTap: () => ref.read(localeProvider.notifier).setLanguage(AppLanguage.english),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isAr ? AppColors.surfaceElevated : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'English (LTR)',
                                style: TextStyle(
                                  color: !isAr ? AppColors.accent : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (!isAr) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.check, size: 16, color: AppColors.accent),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('daily_goals', currentLang),
                    style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
                  ),
                  TextButton.icon(
                    onPressed: () => _showEditTargetsDialog(
                      context,
                      ref,
                      calorieBudget,
                      proteinTarget,
                      carbsTarget,
                      fatTarget,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.accent),
                    label: Text(
                      isAr ? 'تعديل' : 'Edit',
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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
                      label: AppStrings.get('target_calories', currentLang),
                      value: '$calorieBudget ${AppStrings.get('kcal', currentLang)}',
                      onTap: () => _showEditTargetsDialog(
                        context,
                        ref,
                        calorieBudget,
                        proteinTarget,
                        carbsTarget,
                        fatTarget,
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _SettingsRow(
                      label: AppStrings.get('target_protein', currentLang),
                      value: '$proteinTarget${AppStrings.get('g', currentLang)}',
                      onTap: () => _showEditTargetsDialog(
                        context,
                        ref,
                        calorieBudget,
                        proteinTarget,
                        carbsTarget,
                        fatTarget,
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _SettingsRow(
                      label: AppStrings.get('target_carbs', currentLang),
                      value: '$carbsTarget${AppStrings.get('g', currentLang)}',
                      onTap: () => _showEditTargetsDialog(
                        context,
                        ref,
                        calorieBudget,
                        proteinTarget,
                        carbsTarget,
                        fatTarget,
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _SettingsRow(
                      label: AppStrings.get('target_fat', currentLang),
                      value: '$fatTarget${AppStrings.get('g', currentLang)}',
                      onTap: () => _showEditTargetsDialog(
                        context,
                        ref,
                        calorieBudget,
                        proteinTarget,
                        carbsTarget,
                        fatTarget,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '${AppConfig.appName} v1.0.0 • Production Ready',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
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
                Text(
                  value,
                  style: AppTypography.xs.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
                ),
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
