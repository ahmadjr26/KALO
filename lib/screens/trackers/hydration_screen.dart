import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/app_state_provider.dart';

class HydrationScreen extends ConsumerWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final target = state.profile.waterTargetMl;
    final double progress = (state.waterIntakeMl / target).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Daily Hydration',
          style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.water_drop, color: AppColors.water, size: 36),
                            const SizedBox(height: 6),
                            Text(
                              '${state.waterIntakeMl}',
                              style: AppTypography.display.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.water,
                              ),
                            ),
                            Text(
                              'of $target ml',
                              style: AppTypography.xs,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${(progress * 100).toInt()}% of Daily Fluid Goal',
                      style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  _PresetButton(
                    label: '+250ml',
                    sublabel: 'Glass',
                    onTap: () => ref.read(appStateProvider.notifier).addWater(250),
                  ),
                  const SizedBox(width: 12),
                  _PresetButton(
                    label: '+500ml',
                    sublabel: 'Bottle',
                    onTap: () => ref.read(appStateProvider.notifier).addWater(500),
                  ),
                  const SizedBox(width: 12),
                  _PresetButton(
                    label: '+1000ml',
                    sublabel: 'Jug',
                    onTap: () => ref.read(appStateProvider.notifier).addWater(1000),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text(
                  label,
                  style: AppTypography.base.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.water,
                  ),
                ),
                Text(sublabel, style: AppTypography.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
