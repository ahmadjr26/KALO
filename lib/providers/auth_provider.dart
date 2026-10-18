import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';
import 'app_state_provider.dart';

class AuthState {
  final User? user;
  final ProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    ProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final SupabaseService _supabase = SupabaseService.instance;

  @override
  AuthState build() {
    final sub = _supabase.authStateChanges?.listen((data) async {
      final user = data.session?.user;
      if (user != null) {
        final profile = await _supabase.getProfile(user.id);
        state = state.copyWith(user: user, profile: profile);
        if (profile != null) {
          ref.read(appStateProvider.notifier).updateFromSupabaseProfile(profile);
        }
      } else if (data.event == AuthChangeEvent.signedOut) {
        ref.read(appStateProvider.notifier).clearUserData();
        state = const AuthState();
      }
    });
    ref.onDispose(() => sub?.cancel());

    final current = _supabase.currentUser;
    if (current != null) {
      _loadInitialProfile(current.id);
      return AuthState(user: current);
    }
    return const AuthState();
  }

  Future<void> _loadInitialProfile(String userId) async {
    final profile = await _supabase.getProfile(userId);
    state = state.copyWith(profile: profile);
    if (profile != null) {
      ref.read(appStateProvider.notifier).updateFromSupabaseProfile(profile);
      await ref.read(appStateProvider.notifier).syncFromSupabase();
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _supabase.signUp(email: email, password: password);
      if (response?.user != null) {
        final profile = await _supabase.getProfile(response!.user!.id);
        state = AuthState(user: response.user, profile: profile, isLoading: false);
        if (profile != null) {
          ref.read(appStateProvider.notifier).updateFromSupabaseProfile(profile);
        }
        await ref.read(appStateProvider.notifier).syncFromSupabase();
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'Registration failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _supabase.signIn(email: email, password: password);
      if (response?.user != null) {
        final profile = await _supabase.getProfile(response!.user!.id);
        state = AuthState(user: response.user, profile: profile, isLoading: false);
        if (profile != null) {
          ref.read(appStateProvider.notifier).updateFromSupabaseProfile(profile);
        }
        await ref.read(appStateProvider.notifier).syncFromSupabase();
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'Sign in failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.signOut();
    ref.read(appStateProvider.notifier).clearUserData();
    state = const AuthState();
  }

  Future<void> updateProfile(ProfileModel updated) async {
    final success = await _supabase.updateProfile(updated);
    if (success) {
      state = state.copyWith(profile: updated);
      ref.read(appStateProvider.notifier).updateFromSupabaseProfile(updated);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
