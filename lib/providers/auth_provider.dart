import 'package:flutter/foundation.dart';

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

  static AppUser? get currentUser => state.value.user;

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

  static void logout() {
    state.value = const AuthState.initial();
  }
}
