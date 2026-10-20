import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/meal.dart';
import '../models/meal_ingredient.dart';

class ProductNotFoundException implements Exception {
  final String barcode;
  const ProductNotFoundException(this.barcode);

  @override
  String toString() => 'Product with barcode $barcode was not found in OpenFoodFacts database.';
}

class OpenFoodFactsService {
  final http.Client _client;

  OpenFoodFactsService({http.Client? client}) : _client = client ?? http.Client();

  double _parseNum(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) {
      final clean = val.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  int _calculateHealthScore(String? nutriscore) {
    switch (nutriscore?.toLowerCase()) {
      case 'a':
        return 10;
      case 'b':
        return 8;
      case 'c':
        return 6;
      case 'd':
        return 4;
      case 'e':
        return 2;
      default:
        return 7;
    }
  }

  Future<Meal?> fetchProductByBarcode(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) return null;

    final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$cleanBarcode.json');
    
    final response = await _client.get(
      url,
      headers: {
        'User-Agent': 'KaloFoodTracker/1.0 (Flutter; Android/iOS) OpenFoodFactsLookup',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw http.ClientException('Server returned HTTP ${response.statusCode} for barcode $cleanBarcode');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON response from OpenFoodFacts');
    }

    final int status = data['status'] is int ? data['status'] as int : int.tryParse('${data['status']}') ?? 0;
    if (status != 1 || data['product'] == null) {
      throw ProductNotFoundException(cleanBarcode);
    }

    final product = data['product'] as Map<String, dynamic>;
    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};

    final String name = (product['product_name'] as String?)?.trim() ??
        (product['product_name_en'] as String?)?.trim() ??
        (product['brands'] as String?)?.trim() ??
        'Product $cleanBarcode';

    final double calories = _parseNum(nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal_serving'] ?? nutriments['energy-kcal']);
    final double protein = _parseNum(nutriments['proteins_100g'] ?? nutriments['proteins_serving'] ?? nutriments['proteins']);
    final double carbs = _parseNum(nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates_serving'] ?? nutriments['carbohydrates']);
    final double fat = _parseNum(nutriments['fat_100g'] ?? nutriments['fat_serving'] ?? nutriments['fat']);
    final double sugars = _parseNum(nutriments['sugars_100g'] ?? nutriments['sugars_serving'] ?? nutriments['sugars']);
    final double fiber = _parseNum(nutriments['fiber_100g'] ?? nutriments['fiber_serving'] ?? nutriments['fiber']);
    final double sodium = _parseNum(nutriments['sodium_100g'] ?? nutriments['sodium_serving'] ?? nutriments['sodium']);

    final String? servingSize = product['serving_size'] as String?;
    final double servingWeight = _parseNum(product['serving_quantity'] ?? 100);

    const uuid = Uuid();
    return Meal(
      id: uuid.v4(),
      dishName: name,
      mealType: MealType.snack,
      sourceType: MealSource.barcode,
      loggedAt: DateTime.now(),
      healthScore: _calculateHealthScore(product['nutriscore_grade'] as String?),
      ingredients: [
        MealIngredient(
          id: uuid.v4(),
          name: name,
          massGrams: servingWeight > 0 ? servingWeight : 100.0,
          displayQuantity: 1,
          displayUnit: servingSize ?? 'serving',
          calories: calories,
          proteinG: protein,
          carbsG: carbs,
          fatG: fat,
          fiberG: fiber > 0 ? fiber : 0.0,
          sugarG: sugars > 0 ? sugars : 0.0,
          sodiumMg: sodium > 0 ? (sodium * 1000) : 0.0,
        ),
      ],
    );
  }
}
