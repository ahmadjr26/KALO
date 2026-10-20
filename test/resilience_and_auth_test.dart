import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cal_ai_app/models/profile_model.dart';
import 'package:cal_ai_app/services/gemini_scanner_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cal_ai_app/providers/app_state_provider.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('GeminiScannerService resilience & error handling', () {
    test('handles empty response by throwing GeminiApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 200);
      });
      final service = GeminiScannerService(client: mockClient);
      expect(
        () => service.scanFoodImage(imageBytes: Uint8List.fromList([1, 2, 3])),
        throwsA(isA<GeminiApiException>()),
      );
    });

    test('handles malformed JSON by throwing GeminiApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"corrupted_json: [}', 200);
      });
      final service = GeminiScannerService(client: mockClient);
      expect(
        () => service.scanFoodImage(imageBytes: Uint8List.fromList([4, 5, 6])),
        throwsA(isA<GeminiApiException>()),
      );
    });

    test('handles server 500 error by throwing GeminiApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });
      final service = GeminiScannerService(client: mockClient);
      expect(
        () => service.scanFoodImage(imageBytes: Uint8List.fromList([7, 8, 9])),
        throwsA(isA<GeminiApiException>()),
      );
    });

    test('handles missing candidates in JSON response by throwing GeminiApiException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'candidates': []}), 200);
      });
      final service = GeminiScannerService(client: mockClient);
      expect(
        () => service.scanFoodImage(imageBytes: Uint8List.fromList([10, 11, 12])),
        throwsA(isA<GeminiApiException>()),
      );
    });

    test('handles network timeout and client exceptions by throwing GeminiApiException', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Connection timed out');
      });
      final service = GeminiScannerService(client: mockClient);
      expect(
        () => service.scanFoodImage(imageBytes: Uint8List.fromList([13, 14, 15])),
        throwsA(isA<GeminiApiException>()),
      );
    });
  });

  group('Supabase Auth state and profile synchronization', () {
    test('AppState updates profile when new profile model is received', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialProfile = container.read(appStateProvider).profile;
      expect(initialProfile.calorieBudget, equals(2150));

      const updatedProfileModel = ProfileModel(
        id: 'test-user-sync',
        weight: 82.5,
        height: 180.0,
        age: 28,
        goal: 'muscle_gain',
        dailyCalories: 2650,
        dailyProtein: 180.0,
        dailyCarbs: 290.0,
        dailyFat: 75.0,
      );

      container.read(appStateProvider.notifier).updateFromSupabaseProfile(updatedProfileModel);

      final syncedProfile = container.read(appStateProvider).profile;
      expect(syncedProfile.calorieBudget, equals(2650));
      expect(syncedProfile.proteinTargetG, equals(180));
      expect(syncedProfile.carbsTargetG, equals(290));
      expect(syncedProfile.fatTargetG, equals(75));
      expect(syncedProfile.weightKg, equals(82.5));
      expect(syncedProfile.heightCm, equals(180.0));
      expect(syncedProfile.age, equals(28));
    });

    test('AppState profile targets sync correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const newProfile = ProfileModel(
        id: 'user-xyz',
        weight: 75.0,
        height: 177.0,
        age: 30,
        goal: 'cutting',
        dailyCalories: 1950,
        dailyProtein: 165.0,
        dailyCarbs: 160.0,
        dailyFat: 55.0,
      );

      container.read(appStateProvider.notifier).updateFromSupabaseProfile(newProfile);
      final appState = container.read(appStateProvider);
      expect(appState.profile.calorieBudget, equals(1950));
      expect(appState.profile.proteinTargetG, equals(165));
    });
  });
}
