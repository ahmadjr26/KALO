import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cal_ai_app/services/open_food_facts_service.dart';

void main() {
  group('OpenFoodFactsService', () {
    test('fetches and parses real product data correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('3017620422003'));
        final sampleResponse = {
          'status': 1,
          'product': {
            'product_name': 'Nutella Hazelnut Spread',
            'brands': 'Ferrero',
            'nutriments': {
              'energy-kcal_100g': 539,
              'proteins_100g': 6.3,
              'carbohydrates_100g': 57.5,
              'fat_100g': 30.9,
              'sugars_100g': 56.3,
              'sodium_100g': 0.042,
            },
            'serving_quantity': '15',
            'serving_size': '15g',
            'nutriscore_grade': 'e',
          }
        };
        return http.Response(jsonEncode(sampleResponse), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      final meal = await service.fetchProductByBarcode('3017620422003');

      expect(meal, isNotNull);
      expect(meal!.dishName, equals('Nutella Hazelnut Spread'));
      expect(meal.totalCalories, equals(539));
      expect(meal.totalProtein, equals(6.3));
      expect(meal.totalCarbs, equals(57.5));
      expect(meal.totalFat, equals(30.9));
      expect(meal.healthScore, equals(2)); // grade 'e'
    });

    test('throws ProductNotFoundException when product is missing', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'status': 0, 'status_verbose': 'product not found'}), 200);
      });

      final service = OpenFoodFactsService(client: mockClient);
      expect(
        () => service.fetchProductByBarcode('9999999999999'),
        throwsA(isA<ProductNotFoundException>()),
      );
    });
  });
}
