import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';

class LabelScannerScreen extends StatefulWidget {
  const LabelScannerScreen({super.key});

  @override
  State<LabelScannerScreen> createState() => _LabelScannerScreenState();
}

class _LabelScannerScreenState extends State<LabelScannerScreen> {
  bool _isProcessing = false;

  void _simulateLabelRead() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    const uuid = Uuid();
    final item = Meal(
      id: uuid.v4(),
      dishName: 'Nutrition Facts OCR Item',
      mealType: MealType.snack,
      sourceType: MealSource.labelOcr,
      loggedAt: DateTime.now(),
      healthScore: 7,
      ingredients: [
        MealIngredient(
          id: uuid.v4(),
          name: 'Packaged Food (Label Scan)',
          massGrams: 80,
          displayQuantity: 1,
          displayUnit: 'serving',
          calories: 220,
          proteinG: 14,
          carbsG: 24,
          fatG: 8,
          sodiumMg: 350,
        ),
      ],
    );

    context.pushReplacement('/scan-result', extra: item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scan Nutrition Facts', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 380,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isProcessing
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : const Center(
                    child: Text(
                      'Align Nutrition Facts Table',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
          ),
          Positioned(
            bottom: 40,
            child: ElevatedButton.icon(
              onPressed: _simulateLabelRead,
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Capture & Parse Table'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
