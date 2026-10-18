import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_state_provider.dart';

class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Intermittent Fasting',
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
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.warning, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withAlpha(30),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 6),
                            Text(
                              state.isFasting ? '13h 24m' : '0h 00m',
                              style: AppTypography.xl.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              state.isFasting ? 'of 16h 00m goal' : 'Fast Ended',
                              style: AppTypography.xs,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            'CURRENT STAGE: FAT BURNING (KETOSIS)',
                            style: AppTypography.xs.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.warning,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              PrimaryButton(
                label: state.isFasting ? 'End Fast & Open Window' : 'Start 16:8 Fast',
                variant: state.isFasting ? ButtonVariant.secondary : ButtonVariant.primary,
                size: ButtonSize.lg,
                onPressed: () {
                  ref.read(appStateProvider.notifier).toggleFasting();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
