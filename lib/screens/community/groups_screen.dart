import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final members = [
      {'rank': '1', 'name': 'Jordan K.', 'streak': '28 days', 'emoji': '🥇'},
      {'rank': '2', 'name': 'Alex Rivera (You)', 'streak': '7 days', 'emoji': '🥈'},
      {'rank': '3', 'name': 'Sarah M.', 'streak': '6 days', 'emoji': '🥉'},
      {'rank': '4', 'name': 'Marcus L.', 'streak': '5 days', 'emoji': '⚡'},
      {'rank': '5', 'name': 'Elena R.', 'streak': '3 days', 'emoji': '⚡'},
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Challenge Groups',
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
              // Active Group Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withAlpha(30),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'ACTIVE CHALLENGE',
                            style: AppTypography.xs.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text('14 Members', style: AppTypography.xs),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '30-Day Protein & Calorie Goal',
                      style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hit your minimum daily protein target and stay within 10% of your caloric budget.',
                      style: AppTypography.xs,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Group Leaderboard',
                style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              ...members.map((m) {
                final bool isUser = m['name']!.contains('You');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.surfaceElevated : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUser ? AppColors.accent : AppColors.border,
                        width: isUser ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(m['emoji']!, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            m['name']!,
                            style: AppTypography.base.copyWith(
                              fontWeight: isUser ? FontWeight.w800 : FontWeight.w600,
                              color: isUser ? AppColors.accent : AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          m['streak']!,
                          style: AppTypography.sm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Join with Code',
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.md,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Create Group',
                      size: ButtonSize.md,
                      onPressed: () {},
                    ),
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
