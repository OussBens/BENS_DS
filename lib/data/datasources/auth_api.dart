// lib/data/datasources/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';

class AuthApi {
  static Map<String, String> get postHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static String _errorMessage(http.Response response, String fallback) {
    try {
      final data = json.decode(response.body);
      return data['message']?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static ApiResponse<T> _handleError<T>(dynamic error) {
    print('❌ AuthApi error: $error');
    return ApiResponse(
      success: false,
      message: 'Erreur de connexion: $error',
    );
  }

  /// Login user
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.authLogin),
            headers: postHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Authentification réussie',
          data: {
            'token': data['access_token'],
            'user': UserModel.fromJson(data['user']),
            'role': data['user']?['role'],
          },
        );
      }

      return ApiResponse(
        success: false,
        message: _errorMessage(response, 'Email ou mot de passe incorrect'),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Verify token with backend
  static Future<ApiResponse<bool>> verifyToken(String token) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.authVerify), headers: getAuthHeaders(token))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['valid'] == true) {
          return ApiResponse(success: true, message: 'Token valide', data: true);
        }
      }

      return ApiResponse(success: false, message: 'Token invalide', data: false);
    } catch (e) {
      print('❌ Erreur vérification token: $e');
      return ApiResponse(success: false, message: 'Erreur de vérification', data: false);
    }
  }

  /// Logout user
  static Future<ApiResponse<bool>> logout(String token) async {
    try {
      final response = await http
          .post(Uri.parse(ApiConfig.authLogout), headers: getAuthHeaders(token))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(success: true, message: 'Déconnexion réussie', data: true);
      }

      return ApiResponse(success: false, message: 'Erreur lors de la déconnexion', data: false);
    } catch (e) {
      return _handleError(e);
    }
  }
}
