import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/meal_log.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  SupabaseClient? _customClient;

  void setClient(SupabaseClient client) {
    _customClient = client;
  }

  SupabaseClient? get client {
    if (_customClient != null) return _customClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isAvailable => client != null;

  User? get currentUser => client?.auth.currentUser;

  String? get currentUserId => client?.auth.currentUser?.id;

  Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
  }) async {
    final supa = client;
    if (supa == null) return null;

    try {
      final response = await supa.auth
          .signUp(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 15));

      final user = response.user;
      if (user != null) {
        await createDefaultProfile(user.id);
      }

      return response;
    } catch (_) {
      return null;
    }
  }

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    final supa = client;
    if (supa == null) return null;

    try {
      return await supa.auth
          .signInWithPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    final supa = client;
    if (supa == null) return;
    try {
      await supa.auth.signOut().timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  Future<void> createDefaultProfile(String userId) async {
    final supa = client;
    if (supa == null) return;

    try {
      final defaultProfile = ProfileModel(
        id: userId,
        weight: 70.0,
        height: 175.0,
        age: 25,
        goal: 'maintain',
        dailyCalories: 2000,
        dailyProtein: 150.0,
        dailyCarbs: 200.0,
        dailyFat: 65.0,
      );

      await supa.from('profiles').upsert(defaultProfile.toJson()).timeout(const Duration(seconds: 15));
    } catch (_) {}
  }

  Future<ProfileModel?> getProfile([String? userId]) async {
    final supa = client;
    final targetId = userId ?? currentUserId;
    if (supa == null || targetId == null) return null;

    try {
      final data = await supa
          .from('profiles')
          .select()
          .eq('id', targetId)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (data == null) return null;
      return ProfileModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateProfile(ProfileModel profile) async {
    final supa = client;
    if (supa == null) return false;

    try {
      await supa.from('profiles').upsert(profile.toJson()).timeout(const Duration(seconds: 15));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<MealLog?> insertMealLog(MealLog mealLog) async {
    final supa = client;
    if (supa == null) return mealLog;

    final userId = mealLog.userId.isNotEmpty ? mealLog.userId : (currentUserId ?? 'anonymous');
    final payload = mealLog.copyWith(userId: userId).toJson();

    try {
      final response = await supa
          .from('meal_logs')
          .insert(payload)
          .select()
          .single()
          .timeout(const Duration(seconds: 15));

      return MealLog.fromJson(response);
    } catch (_) {
      return mealLog;
    }
  }

  Future<List<MealLog>> getMealLogs([String? userId]) async {
    final supa = client;
    final targetId = userId ?? currentUserId;
    if (supa == null) return [];

    try {
      var query = supa.from('meal_logs').select();
      if (targetId != null && targetId.isNotEmpty) {
        query = query.eq('user_id', targetId);
      }
      final response = await query.order('logged_at', ascending: false).timeout(const Duration(seconds: 15));
      return response.map((item) => MealLog.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> deleteMealLog(String id) async {
    final supa = client;
    if (supa == null) return false;

    try {
      await supa.from('meal_logs').delete().eq('id', id).timeout(const Duration(seconds: 15));
      return true;
    } catch (_) {
      return false;
    }
  }
}
