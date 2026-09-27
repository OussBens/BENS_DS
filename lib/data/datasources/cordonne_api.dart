// lib/data/datasources/cordonne_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/cordonne.dart';
import '../../core/config.dart';

class CordonneApi {
  static Map<String, String> get postHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null ? {...postHeaders, 'Authorization': 'Bearer $token'} : postHeaders;
  }

  static String _errorMessage(http.Response response, String fallback) {
    try {
      final data = json.decode(response.body);
      final message = data['message'];
      if (message is List) return message.join(', ');
      return message?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// Récupérer les coordonnées de l'entreprise
  static Future<ApiResponse<Cordonne>> getCordonne() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.companyInfo), headers: postHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final cordonne = Cordonne.fromJson(json.decode(response.body));
        return ApiResponse<Cordonne>(success: true, data: cordonne, message: 'success');
      }

      return ApiResponse<Cordonne>(
        success: false,
        message: _errorMessage(response, 'Aucune donnée trouvée'),
      );
    } catch (e) {
      print('❌ Get cordonne error: $e');
      return ApiResponse<Cordonne>(success: false, message: 'Erreur: $e');
    }
  }

  /// Mettre à jour les coordonnées de l'entreprise
  static Future<ApiResponse<Cordonne>> updateCordonne(Cordonne cordonne) async {
    try {
      final response = await http
          .patch(
            Uri.parse(ApiConfig.companyInfo),
            headers: await _authHeaders(),
            body: json.encode(cordonne.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final updated = Cordonne.fromJson(json.decode(response.body));
        return ApiResponse<Cordonne>(success: true, data: updated, message: 'Coordonnées mises à jour');
      }

      return ApiResponse<Cordonne>(
        success: false,
        message: _errorMessage(response, 'Erreur lors de la mise à jour'),
      );
    } catch (e) {
      print('❌ Update cordonne error: $e');
      return ApiResponse<Cordonne>(success: false, message: 'Erreur: $e');
    }
  }
}
