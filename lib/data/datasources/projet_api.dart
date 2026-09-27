// lib/data/datasources/projet_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config.dart';
import '../models/api_response.dart';
import '../models/projet_model.dart';

class ProjetApi {
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

  /// Liste des projets. [includeUnpublished] pour l'admin (inclut les non publiés).
  static Future<ApiResponse<List<Projet>>> getAllProjets({bool includeUnpublished = false}) async {
    try {
      final uri = Uri.parse(includeUnpublished ? '${ApiConfig.projects}?all=true' : ApiConfig.projects);
      final response = await http.get(uri, headers: getHeaders).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        final projets = decoded
            .map((json) {
              try {
                return Projet.fromJson(json);
              } catch (e) {
                print('❌ Error parsing projet: $e');
                return null;
              }
            })
            .whereType<Projet>()
            .toList();

        return ApiResponse<List<Projet>>(success: true, data: projets, count: projets.length, message: 'success');
      }

      return ApiResponse<List<Projet>>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
        data: [],
      );
    } catch (e) {
      print('❌ API error: $e');
      return ApiResponse<List<Projet>>(success: false, message: 'Erreur: $e', data: []);
    }
  }

  static Future<ApiResponse<Projet>> getProjetById({required int id}) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.projects}/$id'), headers: getHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final projet = Projet.fromJson(json.decode(response.body));
        return ApiResponse<Projet>(success: true, data: projet, message: 'success');
      }

      return ApiResponse<Projet>(
        success: false,
        message: _errorMessage(response, 'Projet non trouvé'),
      );
    } catch (e) {
      return ApiResponse<Projet>(success: false, message: 'Erreur: $e');
    }
  }

  static Future<ApiResponse<Projet>> addProjet(Projet projet) async {
    try {
      final response = await http
          .post(Uri.parse(ApiConfig.projects), headers: await _authHeaders(), body: jsonEncode(projet.toJson()))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newProjet = Projet.fromJson(json.decode(response.body));
        return ApiResponse<Projet>(success: true, data: newProjet, message: 'Projet ajouté');
      }

      return ApiResponse<Projet>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
      );
    } catch (e) {
      return ApiResponse<Projet>(success: false, message: 'Erreur: $e');
    }
  }

  static Future<ApiResponse<Projet>> updateProjet(Projet projet) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.projects}/${projet.id}'),
            headers: await _authHeaders(),
            body: jsonEncode(projet.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final updated = Projet.fromJson(json.decode(response.body));
        return ApiResponse<Projet>(success: true, data: updated, message: 'Projet modifié');
      }

      return ApiResponse<Projet>(
        success: false,
        message: _errorMessage(response, 'Erreur lors de la modification'),
      );
    } catch (e) {
      return ApiResponse<Projet>(success: false, message: 'Erreur: $e');
    }
  }

  static Future<ApiResponse<dynamic>> deleteProjet({required int id}) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.projects}/$id'), headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(success: true, message: 'Projet supprimé');
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
