import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';

class VoiceLogScreen extends StatefulWidget {
  const VoiceLogScreen({super.key});

  @override
  State<VoiceLogScreen> createState() => _VoiceLogScreenState();
}

class _VoiceLogScreenState extends State<VoiceLogScreen> {
  final TextEditingController _textCtrl = TextEditingController(
    text: '2 boiled eggs with 1 slice of sourdough toast and half an avocado',
  );
  bool _isListening = false;
  bool _isParsing = false;

  void _parseTextToMeal() async {
    setState(() => _isParsing = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    const uuid = Uuid();
    final meal = Meal(
      id: uuid.v4(),
      dishName: 'Eggs, Toast & Avocado',
      mealType: MealType.breakfast,
      sourceType: MealSource.voice,
      loggedAt: DateTime.now(),
      healthScore: 9,
      ingredients: [
        MealIngredient(
          id: uuid.v4(),
          name: 'Boiled Eggs',
          massGrams: 100,
          displayQuantity: 2,
          displayUnit: 'eggs',
          calories: 144,
          proteinG: 12.6,
          carbsG: 0.8,
          fatG: 9.6,
        ),
        MealIngredient(
          id: uuid.v4(),
          name: 'Sourdough Bread',
          massGrams: 40,
          displayQuantity: 1,
          displayUnit: 'slice',
          calories: 110,
          proteinG: 4,
          carbsG: 22,
          fatG: 0.8,
        ),
        MealIngredient(
          id: uuid.v4(),
          name: 'Hass Avocado',
          massGrams: 60,
          displayQuantity: 0.5,
          displayUnit: 'avocado',
          calories: 96,
          proteinG: 1.2,
          carbsG: 5.1,
          fatG: 8.8,
          fiberG: 4,
        ),
      ],
    );

    context.pushReplacement('/scan-result', extra: meal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Voice & Text Log',
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
                  children: [
                    Text(
                      'Speak or describe what you ate',
                      style: AppTypography.xl.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI decomposes your natural description into individual ingredients and macros.',
                      style: AppTypography.sm.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 28),

                    GestureDetector(
                      onTap: () {
                        setState(() => _isListening = !_isListening);
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening ? AppColors.danger : AppColors.surfaceElevated,
                          border: Border.all(
                            color: _isListening ? AppColors.danger : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isListening ? Icons.graphic_eq : Icons.mic_none,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isListening ? 'Listening...' : 'Tap mic to speak',
                      style: AppTypography.xs.copyWith(
                        color: _isListening ? AppColors.danger : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _textCtrl,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Type meal description here...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              PrimaryButton(
                label: 'Parse & Calculate Macros',
                size: ButtonSize.lg,
                icon: Icons.auto_awesome,
                isLoading: _isParsing,
                onPressed: _parseTextToMeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
