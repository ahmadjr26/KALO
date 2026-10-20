import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/config/app_config.dart';
import '../models/meal_log.dart';

class GeminiApiException implements Exception {
  final String message;
  final int? statusCode;

  const GeminiApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class GeminiScannerService {
  final http.Client _client;
  final String? apiKey;

  GeminiScannerService({http.Client? client, this.apiKey})
      : _client = client ?? http.Client();

  String get _effectiveApiKey => (apiKey ?? AppConfig.geminiApiKey).trim();

  String _computeImageHash(Uint8List bytes, List<String>? contextTags) {
    int hash = 0xcbf29ce484222325;
    final step = (bytes.length > 512) ? bytes.length ~/ 256 : 1;
    for (int i = 0; i < bytes.length; i += step) {
      hash ^= bytes[i];
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    final tagsPart = (contextTags != null && contextTags.isNotEmpty) ? contextTags.join('_') : '';
    return 'kalo_scan_${bytes.length}_${hash.toRadixString(16)}_$tagsPart';
  }

  Future<MealLog?> getCachedFood(String foodName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'kalo_recent_${foodName.toLowerCase().trim()}';
      final cachedJson = prefs.getString(key);
      if (cachedJson != null) {
        final Map<String, dynamic> data = jsonDecode(cachedJson) as Map<String, dynamic>;
        return MealLog.fromJson(data).copyWith(
          id: const Uuid().v4(),
          loggedAt: DateTime.now(),
        );
      }
    } catch (_) {}
    return null;
  }

  double _parseNum(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) {
      final clean = val.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic val, [int fallback = 0]) {
    if (val is num) return val.toInt();
    if (val is String) {
      final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(clean) ?? fallback;
    }
    return fallback;
  }

  Future<MealLog> scanFoodImage({
    required Uint8List imageBytes,
    List<String>? contextTags,
    String mimeType = 'image/jpeg',
    String? userId,
    String? model,
  }) async {
    final cacheKey = _computeImageHash(imageBytes, contextTags);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        final Map<String, dynamic> data = jsonDecode(cachedJson) as Map<String, dynamic>;
        final cachedLog = MealLog.fromJson(data);
        return cachedLog.copyWith(
          id: const Uuid().v4(),
          userId: userId ?? cachedLog.userId,
          loggedAt: DateTime.now(),
        );
      }
    } catch (_) {}

    final base64Image = base64Encode(imageBytes);
    final tagsStr = (contextTags != null && contextTags.isNotEmpty) ? ' Context: ${contextTags.join(", ")}.' : '';
    final prompt = 'Analyze this meal image accurately. Return strictly valid JSON: {"food_name":"Dish Name","total_calories":int,"protein":number,"carbs":number,"fat":number,"health_score":int,"ingredients":[{"name":string,"portion":string,"calories":int,"protein":number,"carbs":number,"fat":number}]}. If the image is not food, return {"food_name":"NOT_FOOD","total_calories":0,"protein":0,"carbs":0,"fat":0,"health_score":0,"ingredients":[]}.$tagsStr';

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
        'temperature': 0.1,
        'maxOutputTokens': 500,
      }
    });

    final activeModel = model ?? AppConfig.geminiModel;
    final apiKey = _effectiveApiKey;
    final primaryUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$activeModel:generateContent?key=$apiKey',
    );

    http.Response? response;
    try {
      response = await _client.post(
        primaryUrl,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(const Duration(seconds: 25));
    } catch (e) {
      if (e is http.ClientException) {
        throw GeminiApiException('Network error communicating with Gemini API: ${e.message}');
      }
      throw GeminiApiException('Connection to Gemini API failed: $e');
    }

    if (response.statusCode == 404) {
      final fallbackModel = activeModel == AppConfig.geminiModel
          ? AppConfig.geminiLegacyModel
          : AppConfig.geminiModel;
      final fallbackUrl = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$fallbackModel:generateContent?key=$apiKey',
      );
      try {
        response = await _client.post(
          fallbackUrl,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        ).timeout(const Duration(seconds: 25));
      } catch (e) {
        throw GeminiApiException('Connection to fallback Gemini model failed: $e');
      }
    }

    _validateResponse(response);
    return _parseGeminiContent(response.body, userId, cacheKey);
  }

  Future<MealLog> parseMealFromText(String description, {String? userId}) async {
    final clean = description.trim();
    if (clean.isEmpty) {
      throw const FormatException('Empty meal description provided');
    }

    final prompt = 'Analyze this user meal description: "$clean". Return strictly valid JSON with realistic nutritional breakdown: {"food_name":"Dish Name","total_calories":int,"protein":number,"carbs":number,"fat":number,"health_score":int,"ingredients":[{"name":string,"portion":string,"calories":int,"protein":number,"carbs":number,"fat":number}]}. If not food, return {"food_name":"NOT_FOOD","total_calories":0,"protein":0,"carbs":0,"fat":0,"health_score":0,"ingredients":[]}.';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.1,
        'maxOutputTokens': 500,
      }
    });

    final activeModel = AppConfig.geminiModel;
    final apiKey = _effectiveApiKey;
    final primaryUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$activeModel:generateContent?key=$apiKey',
    );

    final response = await _client.post(
      primaryUrl,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    ).timeout(const Duration(seconds: 25));

    _validateResponse(response);
    return _parseGeminiContent(response.body, userId, null);
  }

  Future<MealLog> scanNutritionLabel({
    required Uint8List imageBytes,
    String? userId,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final prompt = 'Perform OCR and parse this Nutrition Facts label accurately. Return strictly valid JSON: {"food_name":"Packaged Item","total_calories":int,"protein":number,"carbs":number,"fat":number,"health_score":int,"ingredients":[{"name":string,"portion":string,"calories":int,"protein":number,"carbs":number,"fat":number}]}. If not a nutrition label, return {"food_name":"NOT_FOOD","total_calories":0,"protein":0,"carbs":0,"fat":0,"health_score":0,"ingredients":[]}.';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inlineData': {
                'mimeType': 'image/jpeg',
                'data': base64Image,
              }
            },
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.1,
        'maxOutputTokens': 500,
      }
    });

    final activeModel = AppConfig.geminiModel;
    final apiKey = _effectiveApiKey;
    final primaryUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$activeModel:generateContent?key=$apiKey',
    );

    final response = await _client.post(
      primaryUrl,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    ).timeout(const Duration(seconds: 25));

    _validateResponse(response);
    return _parseGeminiContent(response.body, userId, null);
  }

  String _extractErrorMessage(String responseBody, String defaultMsg) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map && decoded['error'] is Map) {
        final msg = decoded['error']['message'];
        if (msg is String && msg.trim().isNotEmpty) {
          return msg.trim();
        }
      }
    } catch (_) {}
    return defaultMsg;
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (_effectiveApiKey.isEmpty) {
        throw GeminiApiException(
          'Gemini API key is not configured (HTTP ${response.statusCode}). Please launch the app with --dart-define=GEMINI_API_KEY=your_key or configure it in run settings.',
          statusCode: response.statusCode,
        );
      }
      final detail = _extractErrorMessage(
        response.body,
        'The configured GEMINI_API_KEY is invalid or unauthorized.',
      );
      throw GeminiApiException(
        'Gemini API authentication failed (HTTP ${response.statusCode}). $detail',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 429) {
      throw const GeminiApiException(
        'Gemini API quota exceeded or rate limited (HTTP 429). Please wait a moment and try again.',
        statusCode: 429,
      );
    }

    if (response.statusCode != 200 || response.body.trim().isEmpty) {
      final detail = _extractErrorMessage(response.body, response.body);
      throw GeminiApiException(
        'Gemini API request failed (HTTP ${response.statusCode}): $detail',
        statusCode: response.statusCode,
      );
    }
  }

  MealLog _parseGeminiContent(String responseBody, String? userId, String? cacheKey) {
    dynamic responseJson;
    try {
      responseJson = jsonDecode(responseBody);
    } catch (_) {
      throw const GeminiApiException('Failed to decode JSON response from Gemini API.');
    }

    final candidates = (responseJson is Map) ? (responseJson['candidates'] as List?) : null;
    if (candidates == null || candidates.isEmpty) {
      throw const GeminiApiException('Gemini API returned no candidates.');
    }

    final firstCandidate = candidates[0] is Map ? (candidates[0] as Map<String, dynamic>) : null;
    final content = firstCandidate?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw const GeminiApiException('Gemini API returned empty content parts.');
    }

    final rawJsonText = (parts[0] is Map) ? (parts[0]['text'] as String? ?? '{}') : '{}';
    dynamic decodedJson;
    try {
      decodedJson = jsonDecode(rawJsonText);
    } catch (_) {
      throw const GeminiApiException('Failed to parse model output into structured nutrition data.');
    }

    final Map<String, dynamic> parsedNutrition = (decodedJson is List && decodedJson.isNotEmpty)
        ? Map<String, dynamic>.from(decodedJson.first as Map)
        : (decodedJson is Map ? Map<String, dynamic>.from(decodedJson) : <String, dynamic>{});

    final String rawFoodName = (parsedNutrition['food_name'] as String? ?? '').trim();
    if (rawFoodName.isEmpty || rawFoodName.toUpperCase() == 'NOT_FOOD' || rawFoodName.toLowerCase() == 'not food') {
      throw const FormatException('NOT_FOOD_DETECTED');
    }

    final int totalCalories = _parseInt(parsedNutrition['total_calories']);
    final double protein = _parseNum(parsedNutrition['protein']);
    final double carbs = _parseNum(parsedNutrition['carbs']);
    final double fat = _parseNum(parsedNutrition['fat']);
    final int healthScore = _parseInt(parsedNutrition['health_score'], 8);

    final List<Map<String, dynamic>> ingredients = [];
    if (parsedNutrition['ingredients'] is List) {
      for (final item in (parsedNutrition['ingredients'] as List)) {
        if (item is Map) {
          ingredients.add(Map<String, dynamic>.from(item));
        }
      }
    }

    final result = MealLog(
      id: const Uuid().v4(),
      userId: userId ?? '',
      foodName: rawFoodName,
      totalCalories: totalCalories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      healthScore: healthScore.clamp(1, 10),
      ingredients: ingredients,
      loggedAt: DateTime.now(),
    );

    if (cacheKey != null) {
      SharedPreferences.getInstance().then((prefs) {
        final serialized = jsonEncode(result.toJson());
        prefs.setString(cacheKey, serialized);
        final recentKey = 'kalo_recent_${result.foodName.toLowerCase().trim()}';
        prefs.setString(recentKey, serialized);
      }).catchError((_) {});
    }

    return result;
  }
}
