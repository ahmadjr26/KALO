import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isScanning = false;

  void _simulateBarcodeFound() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    const uuid = Uuid();
    final item = Meal(
      id: uuid.v4(),
      dishName: 'Barebells Salty Peanut Protein Bar',
      mealType: MealType.snack,
      sourceType: MealSource.barcode,
      loggedAt: DateTime.now(),
      healthScore: 8,
      ingredients: [
        MealIngredient(
          id: uuid.v4(),
          name: 'Protein Bar (Packaged)',
          massGrams: 55,
          displayQuantity: 1,
          displayUnit: 'bar',
          calories: 200,
          proteinG: 20,
          carbsG: 16,
          fatG: 8,
          sugarG: 1.5,
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
        title: const Text('Scan Barcode', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Barcode Viewfinder Reticle
          Container(
            width: 300,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isScanning
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : Center(
                    child: Container(
                      width: 280,
                      height: 2,
                      color: AppColors.danger.withAlpha(180),
                    ),
                  ),
          ),
          Positioned(
            bottom: 40,
            child: ElevatedButton.icon(
              onPressed: _simulateBarcodeFound,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Simulate Barcode Detected'),
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
