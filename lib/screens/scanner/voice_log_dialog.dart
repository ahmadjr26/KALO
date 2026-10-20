import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/permission_utils.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';
import '../../models/meal_log.dart';
import '../../services/gemini_scanner_service.dart';

class VoiceLogScreen extends ConsumerStatefulWidget {
  const VoiceLogScreen({super.key});

  @override
  ConsumerState<VoiceLogScreen> createState() => _VoiceLogScreenState();
}

class _VoiceLogScreenState extends ConsumerState<VoiceLogScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final GeminiScannerService _geminiService = GeminiScannerService();

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  bool _isParsing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _isSpeechInitialized = await _speechToText.initialize(
        onError: (val) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    } catch (_) {
      _isSpeechInitialized = false;
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final granted = await PermissionUtils.requestMicrophonePermission(
      context,
      reason: 'Microphone access is needed to dictate your meals.',
    );
    if (!granted) return;

    if (!_isSpeechInitialized) {
      await _initSpeech();
    }

    if (_isSpeechInitialized) {
      setState(() => _isListening = true);
      await _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _textCtrl.text = result.recognizedWords;
              _textCtrl.selection = TextSelection.fromPosition(
                TextPosition(offset: _textCtrl.text.length),
              );
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition is not available on this device. You can type your meal description.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<void> _parseTextToMeal() async {
    final query = _textCtrl.text.trim();
    final lang = ref.read(localeProvider);
    final isAr = lang == AppLanguage.arabic;

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'يرجى التحدث أو كتابة وصف الوجبة أولاً'
                : 'Please speak or enter a meal description first',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isParsing = true);

    try {
      final MealLog mealLog = await _geminiService.parseMealFromText(query);

      final meal = Meal(
        id: mealLog.id,
        dishName: mealLog.foodName,
        mealType: MealType.breakfast,
        sourceType: MealSource.voice,
        loggedAt: mealLog.loggedAt,
        healthScore: mealLog.healthScore,
        ingredients: mealLog.ingredients.isNotEmpty
            ? mealLog.ingredients.map((ing) {
                return MealIngredient(
                  id: ing['name']?.toString() ?? 'item',
                  name: ing['name']?.toString() ?? 'Item',
                  massGrams: 100.0,
                  displayQuantity: 1.0,
                  displayUnit: ing['portion']?.toString() ?? 'serving',
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
      setState(() => _isParsing = false);
      context.pushReplacement('/scan-result', extra: meal);
    } catch (err) {
      if (!mounted) return;
      setState(() => _isParsing = false);

      final errorMsg = err is GeminiApiException
          ? err.message
          : (err is FormatException && err.message == 'NOT_FOOD_DETECTED'
              ? (isAr ? 'لم يتم التعرف على أطعمة في الوصف' : 'No food items detected in description')
              : (isAr ? 'تعذر تحليل الوجبة. تحقق من الاتصال' : 'Failed to analyze meal. Please check connection.'));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final isAr = lang == AppLanguage.arabic;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isAr ? 'التسجيل الصوتي والنصي' : 'Voice & Text Log',
          style: AppTypography.md.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        isAr ? 'تحدث أو صف وجبتك' : 'Speak or describe what you ate',
                        style: AppTypography.xl.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr
                            ? 'يقوم الذكاء الاصطناعي بتحليل الوصف وحساب السعرات والمغذيات بدقة.'
                            : 'AI breaks down your natural speech into ingredients and nutritional macros.',
                        textAlign: TextAlign.center,
                        style: AppTypography.sm.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 36),

                      GestureDetector(
                        onTap: _toggleListening,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening ? AppColors.danger : AppColors.surfaceElevated,
                            border: Border.all(
                              color: _isListening ? AppColors.danger : AppColors.border,
                              width: _isListening ? 4 : 2,
                            ),
                            boxShadow: _isListening
                                ? [
                                    BoxShadow(
                                      color: AppColors.danger.withValues(alpha: 0.5),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _isListening ? Icons.graphic_eq : Icons.mic_none,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isListening
                            ? (isAr ? 'جاري الاستماع... تحدّث الآن' : 'Listening... Speak now')
                            : (isAr ? 'اضغط على الميكروفون للتحدث' : 'Tap mic to speak'),
                        style: AppTypography.xs.copyWith(
                          color: _isListening ? AppColors.danger : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _isListening ? AppColors.accent : AppColors.border,
                          ),
                        ),
                        child: TextField(
                          controller: _textCtrl,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: isAr
                                ? 'اكتب أو املِ وصف الوجبة هنا (مثلاً: بيضتان مسلوقتان مع شريحة توست)...'
                                : 'Type or dictate your meal here (e.g., 2 scrambled eggs with toast)...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              PrimaryButton(
                label: isAr ? 'تحليل الوجبة وحساب السعرات' : 'Parse & Calculate Macros',
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
