// lib/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/datasources/auth_api.dart';
import '../../data/models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isInitialized; // Nouveau flag pour savoir si l'initialisation est terminée

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.isInitialized = false, // Nouveau
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoading: true, isInitialized: false)) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');


      if (token != null && userJson != null) {
        try {
          // Vérifier si le token est toujours valide
          final isValid = await AuthApi.verifyToken(token);

          if (isValid.success && isValid.data == true) {
            final userMap = jsonDecode(userJson);
            final user = UserModel.fromJson(userMap);


            state = state.copyWith(
              user: user,
              isAuthenticated: true,
              isLoading: false,
              isInitialized: true,
            );
            return;
          } else {
           await _clearSession();
          }
        } catch (e) {
          await _clearSession();
        }
      } else {
      }

      // Si on arrive ici, soit pas de session, soit session invalide
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        isAuthenticated: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        isAuthenticated: false,
        user: null,
      );
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    // Ne pas modifier state.isInitialized ici
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await AuthApi.login(email: email, password: password);

      if (response.success && response.data != null) {
        final prefs = await SharedPreferences.getInstance();

        // Sauvegarder le token
        final token = response.data!['token'] as String;
        await prefs.setString('auth_token', token);

        // Sauvegarder les données utilisateur
        final user = response.data!['user'] as UserModel;
        final userJson = jsonEncode({
          'id': user.id,
          'email': user.email,
          'name': user.name,
          'role': user.role.name,
          // Ajoutez d'autres champs si nécessaire
        });
        await prefs.setString('user_data', userJson);


        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Email ou mot de passe incorrect',
          isAuthenticated: false,
          user: null,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Une erreur est survenue. Veuillez réessayer.',
        isAuthenticated: false,
        user: null,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // Appeler le logout API (optionnel, ne pas bloquer si échec)
        try {
          await AuthApi.logout(token);
        } catch (e) {
         }
      }
    } catch (e) {
    } finally {
      // Toujours nettoyer la session locale
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      state = AuthState(
        isLoading: false,
        isInitialized: true, // Important : garder initialized à true
      );
    }
  }

  // Méthode utilitaire pour forcer le rafraîchissement du token
  Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return false;

    try {
      final isValid = await AuthApi.verifyToken(token);
      if (isValid.success && isValid.data == true) {
        return true;
      } else {
        await _clearSession();
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
        );
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}