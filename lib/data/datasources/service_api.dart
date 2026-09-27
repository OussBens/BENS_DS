// lib/data/datasources/service_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config.dart';
import '../models/api_response.dart';
import '../models/service_model.dart';

class ServiceApi {
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

  /// Liste des services. [includeUnpublished] pour l'admin (inclut les non publiés).
  static Future<ApiResponse<List<Service>>> getAllServices({bool includeUnpublished = false}) async {
    try {
      final uri = Uri.parse(includeUnpublished ? '${ApiConfig.services}?all=true' : ApiConfig.services);
      final response = await http.get(uri, headers: getHeaders).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        final services = decoded
            .map((json) {
              try {
                return Service.fromJson(json);
              } catch (e) {
                print('❌ Error parsing service: $e');
                return null;
              }
            })
            .whereType<Service>()
            .toList();

        return ApiResponse<List<Service>>(success: true, data: services, count: services.length, message: 'success');
      }

      return ApiResponse<List<Service>>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
        data: [],
      );
    } catch (e) {
      print('❌ API error: $e');
      return ApiResponse<List<Service>>(success: false, message: 'Erreur: $e', data: []);
    }
  }

  static Future<ApiResponse<Service>> getServiceById({required int id}) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.services}/$id'), headers: getHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final service = Service.fromJson(json.decode(response.body));
        return ApiResponse<Service>(success: true, data: service, message: 'success');
      }

      return ApiResponse<Service>(
        success: false,
        message: _errorMessage(response, 'Service non trouvé'),
      );
    } catch (e) {
      return ApiResponse<Service>(success: false, message: 'Erreur: $e');
    }
  }

  static Future<ApiResponse<Service>> addService(Service service) async {
    try {
      final response = await http
          .post(Uri.parse(ApiConfig.services), headers: await _authHeaders(), body: jsonEncode(service.toJson()))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newService = Service.fromJson(json.decode(response.body));
        return ApiResponse<Service>(success: true, data: newService, message: 'Service ajouté');
      }

      return ApiResponse<Service>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
      );
    } catch (e) {
      return ApiResponse<Service>(success: false, message: 'Erreur: $e');
    }
  }

  static Future<ApiResponse<Service>> updateService(Service service) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.services}/${service.id}'),
            headers: await _authHeaders(),
            body: jsonEncode(service.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final updated = Service.fromJson(json.decode(response.body));
        return ApiResponse<Service>(success: true, data: updated, message: 'Service modifié');
      }

      return ApiResponse<Service>(
        success: false,
        message: _errorMessage(response, 'Erreur lors de la modification'),
      );
    } catch (e) {
      return ApiResponse<Service>(success: false, message: 'Erreur: $e');
    }
  }

  static Future<ApiResponse<dynamic>> deleteService({required int id}) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.services}/$id'), headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(success: true, message: 'Service supprimé');
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
