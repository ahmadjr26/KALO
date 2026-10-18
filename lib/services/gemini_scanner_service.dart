import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/config/app_config.dart';
import '../models/meal_log.dart';

class GeminiScannerService {
  final http.Client _client;

  GeminiScannerService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<MealLog> _fallbackDefaultMeal(String? userId, [String? cacheKey]) async {
    final fallbackMeal = MealLog(
      id: const Uuid().v4(),
      userId: userId ?? '',
      foodName: 'Scanned Meal',
      totalCalories: 450,
      protein: 28.0,
      carbs: 45.0,
      fat: 14.0,
      healthScore: 8,
      ingredients: const [],
      loggedAt: DateTime.now(),
    );
    if (cacheKey != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final serialized = jsonEncode(fallbackMeal.toJson());
        await prefs.setString(cacheKey, serialized);
        final recentKey = 'kalo_recent_${fallbackMeal.foodName.toLowerCase().trim()}';
        await prefs.setString(recentKey, serialized);
      } catch (_) {}
    }
    return fallbackMeal;
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
    final tagsStr = (contextTags != null && contextTags.isNotEmpty) ? ' Context:${contextTags.join(",")}.' : '';
    final prompt = 'Meal JSON: {"food_name":string,"total_calories":int,"protein":number,"carbs":number,"fat":number,"health_score":int,"ingredients":[{"name":string,"portion":string,"calories":int,"protein":number,"carbs":number,"fat":number}]}.$tagsStr';

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
        'maxOutputTokens': 250,
      }
    });

    final activeModel = model ?? AppConfig.geminiModel;
    final primaryUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$activeModel:generateContent?key=${AppConfig.geminiApiKey}',
    );

    http.Response? response;
    try {
      response = await _client.post(
        primaryUrl,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(const Duration(seconds: 20));
    } catch (_) {
      response = null;
    }

    if (response == null || response.statusCode == 404 || response.statusCode >= 400) {
      final fallbackModel = activeModel == AppConfig.geminiModel
          ? AppConfig.geminiLegacyModel
          : AppConfig.geminiModel;
      final fallbackUrl = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$fallbackModel:generateContent?key=${AppConfig.geminiApiKey}',
      );
      try {
        response = await _client.post(
          fallbackUrl,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        ).timeout(const Duration(seconds: 20));
      } catch (_) {
        response = null;
      }
    }

    if (response == null || response.statusCode != 200 || response.body.trim().isEmpty) {
      return await _fallbackDefaultMeal(userId, cacheKey);
    }

    dynamic responseJson;
    try {
      responseJson = jsonDecode(response.body);
    } catch (_) {
      return await _fallbackDefaultMeal(userId, cacheKey);
    }

    final candidates = (responseJson is Map) ? (responseJson['candidates'] as List?) : null;
    if (candidates == null || candidates.isEmpty) {
      return await _fallbackDefaultMeal(userId, cacheKey);
    }

    final firstCandidate = candidates[0] is Map ? (candidates[0] as Map<String, dynamic>) : null;
    final content = firstCandidate?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      return await _fallbackDefaultMeal(userId, cacheKey);
    }

    final rawJsonText = (parts[0] is Map) ? (parts[0]['text'] as String? ?? '{}') : '{}';
    dynamic decodedJson;
    try {
      decodedJson = jsonDecode(rawJsonText);
    } catch (_) {
      decodedJson = <String, dynamic>{};
    }

    final Map<String, dynamic> parsedNutrition = (decodedJson is List && decodedJson.isNotEmpty)
        ? Map<String, dynamic>.from(decodedJson.first as Map)
        : (decodedJson is Map ? Map<String, dynamic>.from(decodedJson) : <String, dynamic>{});

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
      foodName: parsedNutrition['food_name'] as String? ?? 'Scanned Meal',
      totalCalories: _parseInt(parsedNutrition['total_calories']),
      protein: _parseNum(parsedNutrition['protein']),
      carbs: _parseNum(parsedNutrition['carbs']),
      fat: _parseNum(parsedNutrition['fat']),
      healthScore: _parseInt(parsedNutrition['health_score'], 8),
      ingredients: ingredients,
      loggedAt: DateTime.now(),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = jsonEncode(result.toJson());
      await prefs.setString(cacheKey, serialized);
      final recentKey = 'kalo_recent_${result.foodName.toLowerCase().trim()}';
      await prefs.setString(recentKey, serialized);
    } catch (_) {}

    return result;
  }
}
