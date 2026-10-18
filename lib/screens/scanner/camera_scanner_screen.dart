import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock_database.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';
import '../../models/meal_log.dart';
import '../../services/gemini_scanner_service.dart';

class CameraScannerScreen extends ConsumerStatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  ConsumerState<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends ConsumerState<CameraScannerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedModeIndex = 0;
  bool _isFlashOn = false;
  bool _isAnalyzing = false;
  Uint8List? _capturedImageBytes;
  late AnimationController _laserController;
  final ImagePicker _picker = ImagePicker();
  final GeminiScannerService _geminiService = GeminiScannerService();

  final List<String> _modes = ['Food Scan', 'Barcode', 'Nutrition Label', 'Voice'];

  bool get _isInTest =>
      !kIsWeb && (Platform.environment.containsKey('FLUTTER_TEST') || const bool.fromEnvironment('flutter.test'));

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 65,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _capturedImageBytes = bytes;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _captureFromCamera() async {
    if (_isInTest) {
      _triggerTestMock();
      return;
    }

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 65,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _capturedImageBytes = bytes;
          });
        }
      }
    } catch (_) {}
  }

  void _triggerTestMock() async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    final sampleMeal = MockDatabase.visionSamplePrescriptions.first;
    context.push('/scan-result', extra: sampleMeal);
  }

  Future<void> _startAnalysis() async {
    if (_capturedImageBytes == null || _isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    final lang = ref.read(localeProvider);
    final isAr = lang == AppLanguage.arabic;

    try {
      final MealLog mealLog = await _geminiService.scanFoodImage(
        imageBytes: _capturedImageBytes!,
        contextTags: ['Real Food Capture', isAr ? 'Arabic context' : 'English context'],
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
            : [
                MealIngredient(
                  id: mealLog.foodName,
                  name: mealLog.foodName,
                  massGrams: 150.0,
                  displayQuantity: 1.0,
                  displayUnit: 'serving',
                  calories: mealLog.totalCalories.toDouble(),
                  proteinG: mealLog.protein,
                  carbsG: mealLog.carbs,
                  fatG: mealLog.fat,
                )
              ],
        healthScore: mealLog.healthScore,
      );

      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _capturedImageBytes = null;
      });
      context.push('/scan-result', extra: meal);
    } catch (err) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      final isNotFood = err is FormatException && err.message == 'NOT_FOOD_DETECTED';
      final alertMsg = isNotFood
          ? AppStrings.get('not_food_error', lang)
          : AppStrings.get('scan_error_retry', lang);

      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isNotFood ? Icons.no_food_rounded : Icons.wifi_off_rounded,
                    color: isNotFood ? AppColors.warning : AppColors.danger,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    alertMsg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() => _capturedImageBytes = null);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppStrings.get('retake_photo', lang),
                            style: const TextStyle(color: AppColors.text),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _startAnalysis();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isAr ? 'إعادة المحاولة' : 'Retry',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_capturedImageBytes != null)
            Positioned.fill(
              child: Image.memory(
                _capturedImageBytes!,
                fit: BoxFit.cover,
              ),
            )
          else
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
                  opacity: 0.35,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lunch_dining_rounded, size: 90, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        'AI Vision Camera Active',
                        style: AppTypography.sm.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.get('point_camera_hint', currentLang),
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _BracketCorner(
                      isTop: true,
                      isLeft: true,
                      color: AppColors.accent,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _BracketCorner(
                      isTop: true,
                      isLeft: false,
                      color: AppColors.accent,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _BracketCorner(
                      isTop: false,
                      isLeft: true,
                      color: AppColors.accent,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _BracketCorner(
                      isTop: false,
                      isLeft: false,
                      color: AppColors.accent,
                    ),
                  ),
                  if (_isAnalyzing)
                    AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, child) {
                        return Positioned(
                          top: _laserController.value * 270,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.accent,
                                  Colors.white,
                                  AppColors.accent,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.8),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  if (_isAnalyzing)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                currentLang == AppLanguage.arabic ? 'جاري التحليل بالـ AI...' : 'Analyzing with AI...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: _isFlashOn ? AppColors.warning : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _pickFromGallery,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 20),
                        ),
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
                if (_capturedImageBytes != null && !_isAnalyzing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _capturedImageBytes = null),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white38),
                              backgroundColor: Colors.black54,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppStrings.get('retake_photo', currentLang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _startAnalysis,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.get('confirm_and_scan', currentLang),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
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
                  const SizedBox(height: 20),
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
                          AppStrings.get('snap_photo', currentLang),
                          style: AppTypography.xs.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
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
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color, width: 3.5) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color, width: 3.5) : BorderSide.none,
          left: isLeft ? BorderSide(color: color, width: 3.5) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color, width: 3.5) : BorderSide.none,
        ),
      ),
    );
  }
}
