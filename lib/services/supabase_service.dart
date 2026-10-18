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

    final response = await supa.auth.signUp(
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user != null) {
      await createDefaultProfile(user.id);
    }

    return response;
  }

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    final supa = client;
    if (supa == null) return null;

    return await supa.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    final supa = client;
    if (supa == null) return;
    await supa.auth.signOut();
  }

  Future<void> createDefaultProfile(String userId) async {
    final supa = client;
    if (supa == null) return;

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

    await supa.from('profiles').upsert(defaultProfile.toJson());
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
          .maybeSingle();

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
      await supa.from('profiles').upsert(profile.toJson());
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
          .single();

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
      final response = await query.order('logged_at', ascending: false);

      return (response as List)
          .map((item) => MealLog.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> deleteMealLog(String id) async {
    final supa = client;
    if (supa == null) return false;

    try {
      await supa.from('meal_logs').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
