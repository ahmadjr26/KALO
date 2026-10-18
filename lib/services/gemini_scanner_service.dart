import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../core/config/app_config.dart';
import '../models/meal_log.dart';

class GeminiScannerService {
  final http.Client _client;

  GeminiScannerService({http.Client? client}) : _client = client ?? http.Client();

  Future<MealLog> scanFoodImage({
    required Uint8List imageBytes,
    List<String>? contextTags,
    String mimeType = 'image/jpeg',
    String? userId,
    String? model,
  }) async {
    final base64Image = base64Encode(imageBytes);

    String prompt = '''
You are an expert AI clinical nutritionist and calorie estimation engine for KALO.
Analyze the food in this image.
Break down each visible component into its exact portion size, calories, protein (g), carbs (g), and fat (g).
Calculate the overall total calories, total protein, total carbs, total fat, and an integer health score from 1 to 10 based on nutrient density.
''';

    if (contextTags != null && contextTags.isNotEmpty) {
      prompt += '\nContext and preparation details: ${contextTags.join(", ")}.\n';
    }

    prompt += '''
Output ONLY valid JSON strictly matching this schema:
{
  "food_name": "string",
  "total_calories": integer,
  "protein": number,
  "carbs": number,
  "fat": number,
  "health_score": integer,
  "ingredients": [
    {
      "name": "string",
      "portion": "string",
      "calories": integer,
      "protein": number,
      "carbs": number,
      "fat": number
    }
  ]
}
''';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Image,
              }
            },
            {
              'text': prompt,
            }
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.2,
      }
    });

    final activeModel = model ?? AppConfig.geminiModel;
    final primaryUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$activeModel:generateContent?key=${AppConfig.geminiApiKey}',
    );

    http.Response response = await _client.post(
      primaryUrl,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 404 || response.statusCode >= 400) {
      final fallbackModel = activeModel == AppConfig.geminiModel
          ? AppConfig.geminiLegacyModel
          : AppConfig.geminiModel;
      final fallbackUrl = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$fallbackModel:generateContent?key=${AppConfig.geminiApiKey}',
      );
      response = await _client.post(
        fallbackUrl,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
    }

    if (response.statusCode != 200) {
      throw Exception('Gemini API call failed with status: ${response.statusCode} - ${response.body}');
    }

    final Map<String, dynamic> responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = responseJson['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No candidates returned by Gemini vision API');
    }

    final firstCandidate = candidates[0] as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('No content parts found in candidate');
    }

    final rawJsonText = parts[0]['text'] as String? ?? '{}';
    final Map<String, dynamic> parsedNutrition = jsonDecode(rawJsonText) as Map<String, dynamic>;

    final List<Map<String, dynamic>> ingredients = [];
    if (parsedNutrition['ingredients'] is List) {
      for (final item in (parsedNutrition['ingredients'] as List)) {
        if (item is Map) {
          ingredients.add(Map<String, dynamic>.from(item));
        }
      }
    }

    return MealLog(
      id: const Uuid().v4(),
      userId: userId ?? '',
      foodName: parsedNutrition['food_name'] as String? ?? 'Scanned Meal',
      totalCalories: (parsedNutrition['total_calories'] as num?)?.toInt() ?? 0,
      protein: (parsedNutrition['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (parsedNutrition['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (parsedNutrition['fat'] as num?)?.toDouble() ?? 0.0,
      healthScore: (parsedNutrition['health_score'] as num?)?.round() ?? 8,
      ingredients: ingredients,
      loggedAt: DateTime.now(),
    );
  }
}
