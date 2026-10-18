import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_ai_app/services/gemini_scanner_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
  });

  test('GeminiScannerService sends request, parses MealLog and uses local caching layer', () async {
    final service = GeminiScannerService();
    const samplePngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
    final imageBytes = Uint8List.fromList(base64Decode(samplePngBase64));

    final mealLog = await service.scanFoodImage(
      imageBytes: imageBytes,
      contextTags: ['Home-cooked', 'Grilled'],
      mimeType: 'image/png',
      userId: 'test-user-123',
    );

    expect(mealLog.foodName.isNotEmpty, isTrue);
    expect(mealLog.totalCalories, isNonNegative);
    expect(mealLog.protein, isNonNegative);
    expect(mealLog.carbs, isNonNegative);
    expect(mealLog.fat, isNonNegative);
    expect(mealLog.healthScore, isNonNegative);

    final cachedMealLog = await service.scanFoodImage(
      imageBytes: imageBytes,
      contextTags: ['Home-cooked', 'Grilled'],
      mimeType: 'image/png',
      userId: 'test-user-123',
    );

    expect(cachedMealLog.foodName, equals(mealLog.foodName));
    expect(cachedMealLog.totalCalories, equals(mealLog.totalCalories));

    final queriedMeal = await service.getCachedFood(mealLog.foodName);
    expect(queriedMeal, isNotNull);
    expect(queriedMeal?.foodName, equals(mealLog.foodName));
  }, timeout: const Timeout(Duration(seconds: 45)));
}
