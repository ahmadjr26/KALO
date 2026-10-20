import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/permission_utils.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';
import '../../models/meal_log.dart';
import '../../services/gemini_scanner_service.dart';

class LabelScannerScreen extends ConsumerStatefulWidget {
  const LabelScannerScreen({super.key});

  @override
  ConsumerState<LabelScannerScreen> createState() => _LabelScannerScreenState();
}

class _LabelScannerScreenState extends ConsumerState<LabelScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeminiScannerService _geminiService = GeminiScannerService();

  Uint8List? _capturedImageBytes;
  bool _isProcessing = false;

  Future<void> _captureFromCamera() async {
    final granted = await PermissionUtils.requestCameraPermission(
      context,
      reason: 'Camera access is required to photograph nutrition labels.',
    );
    if (!granted) return;

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 720,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _capturedImageBytes = bytes;
          });
          _parseLabel(bytes);
        }
      }
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _capturedImageBytes = bytes;
          });
          _parseLabel(bytes);
        }
      }
    } catch (_) {}
  }

  Future<void> _parseLabel(Uint8List bytes) async {
    setState(() => _isProcessing = true);

    final lang = ref.read(localeProvider);
    final isAr = lang == AppLanguage.arabic;

    try {
      final MealLog mealLog = await _geminiService.scanNutritionLabel(imageBytes: bytes);

      final meal = Meal(
        id: mealLog.id,
        dishName: mealLog.foodName,
        mealType: MealType.snack,
        sourceType: MealSource.labelOcr,
        loggedAt: mealLog.loggedAt,
        healthScore: mealLog.healthScore,
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
                  massGrams: 100.0,
                  displayQuantity: 1.0,
                  displayUnit: 'serving',
                  calories: mealLog.totalCalories.toDouble(),
                  proteinG: mealLog.protein,
                  carbsG: mealLog.carbs,
                  fatG: mealLog.fat,
                )
              ],
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);
      context.pushReplacement('/scan-result', extra: meal);
    } catch (err) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      final errorMsg = err is GeminiApiException
          ? err.message
          : (isAr
              ? 'تعذر قراءة الملصق الغذائي. تأكد من وضوح الصورة وتوفر اتصال بالإنترنت.'
              : 'Could not parse nutrition facts table. Please ensure the label is clearly legible.');

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
                  const Icon(Icons.document_scanner_outlined, color: AppColors.danger, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'فشل تحليل الملصق' : 'Label Scan Failed',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMsg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.4),
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
                            isAr ? 'إعادة المحاولة' : 'Retake Photo',
                            style: const TextStyle(color: AppColors.text),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.pushReplacement('/food-search');
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
                            isAr ? 'بحث يدوي' : 'Manual Entry',
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
    final lang = ref.watch(localeProvider);
    final isAr = lang == AppLanguage.arabic;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isAr ? 'مسح الملصق الغذائي' : 'Scan Nutrition Facts',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
            onPressed: _pickFromGallery,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
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
              color: const Color(0xFF0D1117),
              child: Center(
                child: Opacity(
                  opacity: 0.35,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_rounded, size: 84, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        isAr ? 'كاميرا قراءة الملصقات نشطة' : 'Label OCR Camera Ready',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Container(
            width: 280,
            height: 420,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent, width: 2.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _isProcessing
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.accent),
                        SizedBox(height: 16),
                        Text(
                          'Reading Nutrition Facts...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAr ? 'وجّه الكاميرا نحو جدول القيم الغذائية' : 'Align Nutrition Facts Table',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ),
          ),
          Positioned(
            bottom: 40,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _captureFromCamera,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(
                isAr ? 'التقاط وقراءة الجدول' : 'Capture & Read Label',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: const StadiumBorder(),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
