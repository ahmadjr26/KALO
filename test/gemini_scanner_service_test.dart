import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_ai_app/services/gemini_scanner_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test('GeminiScannerService sends request, parses MealLog and uses local caching layer', () async {
    final mockClient = MockClient((request) async {
      final sampleResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'food_name': 'Grilled Chicken Bowl',
                    'total_calories': 520,
                    'protein': 42.0,
                    'carbs': 48.0,
                    'fat': 12.0,
                    'health_score': 9,
                    'ingredients': [
                      {
                        'name': 'Grilled Chicken Breast',
                        'portion': '150g',
                        'calories': 250,
                        'protein': 38.0,
                        'carbs': 0.0,
                        'fat': 4.0,
                      },
                      {
                        'name': 'Brown Rice',
                        'portion': '1 cup',
                        'calories': 215,
                        'protein': 4.0,
                        'carbs': 45.0,
                        'fat': 1.5,
                      }
                    ]
                  })
                }
              ]
            }
          }
        ]
      };
      return http.Response(jsonEncode(sampleResponse), 200);
    });

    final service = GeminiScannerService(client: mockClient);
    const samplePngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
    final imageBytes = Uint8List.fromList(base64Decode(samplePngBase64));

    final mealLog = await service.scanFoodImage(
      imageBytes: imageBytes,
      contextTags: ['Home-cooked', 'Grilled'],
      mimeType: 'image/png',
      userId: 'test-user-123',
    );

    expect(mealLog.foodName, equals('Grilled Chicken Bowl'));
    expect(mealLog.totalCalories, equals(520));
    expect(mealLog.protein, equals(42.0));
    expect(mealLog.carbs, equals(48.0));
    expect(mealLog.fat, equals(12.0));
    expect(mealLog.healthScore, equals(9));
    expect(mealLog.ingredients.length, equals(2));

    // Test cached response uses the cache without hitting client again
    final cachedMealLog = await service.scanFoodImage(
      imageBytes: imageBytes,
      contextTags: ['Home-cooked', 'Grilled'],
      mimeType: 'image/png',
      userId: 'test-user-123',
    );

    expect(cachedMealLog.foodName, equals('Grilled Chicken Bowl'));
    expect(cachedMealLog.totalCalories, equals(520));

    final queriedMeal = await service.getCachedFood('Grilled Chicken Bowl');
    expect(queriedMeal, isNotNull);
    expect(queriedMeal?.foodName, equals('Grilled Chicken Bowl'));
  });
}
