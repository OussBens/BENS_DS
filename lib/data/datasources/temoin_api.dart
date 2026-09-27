import 'dart:convert';
import 'package:bens_ds/core/config.dart';
import 'package:bens_ds/data/models/temoin_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';

class TemoinApi {
  static Map<String, String> get postHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> get getHeaders => {'Accept': 'application/json'};

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

  static Map<String, dynamic> _toRequestBody(Temoin temoin) {
    return {
      'nomClient': temoin.nomClient,
      'titre': temoin.titre,
      'modeleVoiture': temoin.modeleVoiture,
      'contenu': temoin.contenu,
      'note': temoin.note,
      'photos': temoin.photos,
      'video': temoin.video,
      'date': temoin.date.toIso8601String(),
      'isActive': temoin.isActive,
    };
  }

  /// Get all témoignages (y compris inactifs, filtrés côté UI)
  static Future<ApiResponse<List<Temoin>>> getAllTemoins() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.testimonials}?all=true'), headers: getHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        final temoins = decoded
            .map((json) {
              try {
                return Temoin.fromJson(json);
              } catch (e) {
                print('❌ Error parsing temoin: $e');
                return null;
              }
            })
            .whereType<Temoin>()
            .toList();

        return ApiResponse<List<Temoin>>(
          success: true,
          data: temoins,
          count: temoins.length,
          message: 'success',
        );
      }

      return ApiResponse<List<Temoin>>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
        data: [],
      );
    } catch (e) {
      print('❌ API error: $e');
      return ApiResponse<List<Temoin>>(success: false, message: 'Erreur: $e', data: []);
    }
  }

  /// Get témoignage by ID
  static Future<ApiResponse<Temoin>> getTemoinById({required int id}) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.testimonials}/$id'), headers: getHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final temoin = Temoin.fromJson(json.decode(response.body));
          return ApiResponse<Temoin>(success: true, data: temoin, message: 'success');
        } catch (e) {
          return ApiResponse<Temoin>(success: false, message: 'Error parsing temoin data: $e');
        }
      }

      return ApiResponse<Temoin>(
        success: false,
        message: _errorMessage(response, 'Témoignage non trouvé'),
      );
    } catch (e) {
      return ApiResponse<Temoin>(success: false, message: 'Erreur: $e');
    }
  }

  /// Add témoignage (nécessite un token admin)
  static Future<ApiResponse<Temoin>> addTemoin(Temoin temoin) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.testimonials),
            headers: await _authHeaders(),
            body: jsonEncode(_toRequestBody(temoin)),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newTemoin = Temoin.fromJson(json.decode(response.body));
        return ApiResponse<Temoin>(success: true, data: newTemoin, message: 'Témoignage ajouté');
      }

      return ApiResponse<Temoin>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
      );
    } catch (e) {
      return ApiResponse<Temoin>(success: false, message: 'Erreur: $e');
    }
  }

  /// Update témoignage
  static Future<ApiResponse<Temoin>> updateTemoin(Temoin temoin) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.testimonials}/${temoin.id}'),
            headers: await _authHeaders(),
            body: jsonEncode(_toRequestBody(temoin)),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final updatedTemoin = Temoin.fromJson(json.decode(response.body));
        return ApiResponse<Temoin>(success: true, data: updatedTemoin, message: 'Témoignage modifié');
      }

      return ApiResponse<Temoin>(
        success: false,
        message: _errorMessage(response, 'Erreur lors de la modification'),
      );
    } catch (e) {
      return ApiResponse<Temoin>(success: false, message: 'Erreur: $e');
    }
  }

  /// Delete témoignage
  static Future<ApiResponse<dynamic>> deleteTemoin({required int id}) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.testimonials}/$id'),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(success: true, message: 'Témoignage supprimé');
      }

      return ApiResponse<dynamic>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
      );
    } catch (e) {
      return ApiResponse<dynamic>(success: false, message: 'Erreur: $e');
    }
  }
}
