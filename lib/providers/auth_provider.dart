import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:freeradius_app/models/app_user.dart';
import 'package:freeradius_app/services/api_services.dart';
import 'package:freeradius_app/utilities/error_messages.dart';

class AuthState {
  const AuthState({
    required this.user,
    required this.isLoading,
    this.errorMessage,
  });

  const AuthState.initial()
      : user = null,
        isLoading = false,
        errorMessage = null;

  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Object? user = _sentinel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: identical(user, _sentinel) ? this.user : user as AppUser?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  static const Object _sentinel = Object();
}

class AuthController {
  AuthController._();

  static final ValueNotifier<AuthState> state =
      ValueNotifier<AuthState>(const AuthState.initial());
  static SharedPreferences? _prefs;
  static const String _userStorageKey = 'auth_user';

  static AppUser? get currentUser => state.value.user;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } on Exception catch (error) {
      debugPrint('SharedPreferences init failed: $error');
      _prefs = null;
      return;
    }

    final storedUser = _prefs?.getString(_userStorageKey);
    if (storedUser == null || storedUser.isEmpty) {
      return;
    }
    try {
      final json = jsonDecode(storedUser);
      if (json is Map<String, dynamic>) {
        final user = AppUser.fromJson(json);
        state.value = AuthState(user: user, isLoading: false);
      }
    } catch (_) {
      await _prefs?.remove(_userStorageKey);
    }
  }

  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    state.value = state.value.copyWith(
      isLoading: true,
      errorMessage: null,
    );
    try {
      final user = await apiService.authenticateUser(
        username: username,
        password: password,
      );
      if (user == null) {
        state.value = state.value.copyWith(
          isLoading: false,
          user: null,
          errorMessage: 'Credenciales inválidas',
        );
        return false;
      }

      state.value = AuthState(
        user: user,
        isLoading: false,
      );
      await _persistUser(user);
      return true;
    } catch (error) {
      state.value = state.value.copyWith(
        isLoading: false,
        user: null,
        errorMessage: describeApiError(error),
      );
      return false;
    }
  }

  static Future<void> logout() async {
    await _clearStoredUser();
    state.value = const AuthState.initial();
  }

  static Future<void> _persistUser(AppUser user) async {
    try {
      final prefs = await _ensurePrefs();
      await prefs?.setString(_userStorageKey, jsonEncode(user.toJson()));
    } catch (error) {
      debugPrint('Persist user failed: $error');
    }
  }

  static Future<void> _clearStoredUser() async {
    try {
      final prefs = await _ensurePrefs();
      await prefs?.remove(_userStorageKey);
    } catch (error) {
      debugPrint('Clear user failed: $error');
    }
  }

  static Future<SharedPreferences?> _ensurePrefs() async {
    if (_prefs != null) return _prefs;
    try {
      _prefs = await SharedPreferences.getInstance();
      return _prefs;
    } on Exception catch (error) {
      debugPrint('SharedPreferences unavailable: $error');
      return null;
    }
  }
}
