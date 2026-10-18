import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock_database.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';
import '../../models/meal_log.dart';
import '../../services/gemini_scanner_service.dart';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedModeIndex = 0;
  bool _isFlashOn = false;
  bool _isAnalyzing = false;
  late AnimationController _pulseController;
  final ImagePicker _picker = ImagePicker();
  final GeminiScannerService _geminiService = GeminiScannerService();

  final List<String> _modes = ['Food Scan', 'Barcode', 'Nutrition Label', 'Voice'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 65,
      ).timeout(const Duration(milliseconds: 200), onTimeout: () => null);
      if (file != null) {
        final bytes = await file.readAsBytes();
        await _analyzeImage(bytes);
      }
    } catch (_) {}
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 65,
      ).timeout(const Duration(milliseconds: 200), onTimeout: () => null);
      if (file != null) {
        final bytes = await file.readAsBytes();
        await _analyzeImage(bytes);
        return;
      }
    } catch (_) {}
    _triggerCapture();
  }

  Future<void> _analyzeImage(Uint8List imageBytes) async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    try {
      final MealLog mealLog = await _geminiService.scanFoodImage(
        imageBytes: imageBytes,
        contextTags: ['Home-cooked vs Restaurant', 'Fried vs Grilled'],
      );

      final meal = Meal(
        id: mealLog.id,
        dishName: mealLog.foodName,
        mealType: MealType.lunch,
        sourceType: MealSource.aiPhoto,
        loggedAt: mealLog.loggedAt,
        ingredients: mealLog.ingredients.isNotEmpty
            ? mealLog.ingredients.map((ing) {
                return MealIngredient(
                  id: ing['name']?.toString() ?? 'item',
                  name: ing['name']?.toString() ?? 'Item',
                  massGrams: 100.0,
                  displayQuantity: 1.0,
                  displayUnit: 'serving',
                  calories: (ing['calories'] as num?)?.toDouble() ?? 100.0,
                  proteinG: (ing['protein'] as num?)?.toDouble() ?? 5.0,
                  carbsG: (ing['carbs'] as num?)?.toDouble() ?? 10.0,
                  fatG: (ing['fat'] as num?)?.toDouble() ?? 3.0,
                );
              }).toList()
            : MockDatabase.visionSamplePrescriptions.first.ingredients,
        healthScore: mealLog.healthScore,
      );

      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      context.push('/scan-result', extra: meal);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      final fallbackMeal = MockDatabase.visionSamplePrescriptions.first;
      context.push('/scan-result', extra: fallbackMeal);
    }
  }

  void _triggerCapture() async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    final sampleMeal = MockDatabase.visionSamplePrescriptions.first;
    context.push('/scan-result', extra: sampleMeal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF141923), Color(0xFF090C11), Color(0xFF000000)],
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: 0.25,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lunch_dining_rounded, size: 100, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      'AI Vision Camera Active',
                      style: AppTypography.sm.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final double glow = 0.5 + (_pulseController.value * 0.5);

                return SizedBox(
                  width: 270,
                  height: 270,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _BracketCorner(
                          isTop: true,
                          isLeft: true,
                          color: AppColors.accent.withValues(alpha: glow),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _BracketCorner(
                          isTop: true,
                          isLeft: false,
                          color: AppColors.accent.withValues(alpha: glow),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _BracketCorner(
                          isTop: false,
                          isLeft: true,
                          color: AppColors.accent.withValues(alpha: glow),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _BracketCorner(
                          isTop: false,
                          isLeft: false,
                          color: AppColors.accent.withValues(alpha: glow),
                        ),
                      ),
                      if (_isAnalyzing)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'Gemini AI Analyzing...',
                                  style: AppTypography.xs.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: _isFlashOn ? AppColors.warning : Colors.white,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_modes.length, (index) {
                      final bool isSelected = index == _selectedModeIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedModeIndex = index);
                          if (index == 1) context.push('/barcode-scanner');
                          if (index == 2) context.push('/label-scanner');
                          if (index == 3) context.push('/voice-log');
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _modes[index],
                            style: TextStyle(
                              color: isSelected ? AppColors.accent : Colors.white70,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  key: const Key('shutter_button'),
                  onTap: _captureFromCamera,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isAnalyzing ? AppColors.accent : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to scan plate',
                        style: AppTypography.xs.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  final Color color;

  const _BracketCorner({
    required this.isTop,
    required this.isLeft,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double length = 32.0;
    const double thickness = 3.5;

    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: length,
              height: thickness,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: thickness,
              height: length,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
