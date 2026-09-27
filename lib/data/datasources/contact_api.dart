// lib/data/datasources/contact_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config.dart';
import '../models/api_response.dart';
import '../models/contact_message_model.dart';

class ContactApi {
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

  /// Soumission publique du formulaire de contact
  static Future<ApiResponse<ContactMessage>> submitMessage(ContactMessage message) async {
    try {
      final response = await http
          .post(Uri.parse(ApiConfig.contactMessages), headers: postHeaders, body: jsonEncode(message.toJson()))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final created = ContactMessage.fromJson(json.decode(response.body));
        return ApiResponse<ContactMessage>(success: true, data: created, message: 'Message envoyé');
      }

      return ApiResponse<ContactMessage>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
      );
    } catch (e) {
      return ApiResponse<ContactMessage>(success: false, message: 'Erreur: $e');
    }
  }

  /// Liste des messages (admin)
  static Future<ApiResponse<List<ContactMessage>>> getAllMessages() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.contactMessages), headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        final messages = decoded
            .map((json) {
              try {
                return ContactMessage.fromJson(json);
              } catch (e) {
                print('❌ Error parsing contact message: $e');
                return null;
              }
            })
            .whereType<ContactMessage>()
            .toList();

        return ApiResponse<List<ContactMessage>>(
          success: true,
          data: messages,
          count: messages.length,
          message: 'success',
        );
      }

      return ApiResponse<List<ContactMessage>>(
        success: false,
        message: _errorMessage(response, 'Erreur HTTP ${response.statusCode}'),
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<ContactMessage>>(success: false, message: 'Erreur: $e', data: []);
    }
  }

  /// Marquer lu / répondu / ajouter une note admin
  static Future<ApiResponse<ContactMessage>> updateMessage({
    required int id,
    ContactMessageStatus? status,
    String? adminNote,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status.apiValue;
      if (adminNote != null) body['adminNote'] = adminNote;

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.contactMessages}/$id'),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final updated = ContactMessage.fromJson(json.decode(response.body));
        return ApiResponse<ContactMessage>(success: true, data: updated, message: 'Message mis à jour');
      }

      return ApiResponse<ContactMessage>(
        success: false,
        message: _errorMessage(response, 'Erreur lors de la mise à jour'),
      );
    } catch (e) {
      return ApiResponse<ContactMessage>(success: false, message: 'Erreur: $e');
    }
  }

  static Future<ApiResponse<dynamic>> deleteMessage({required int id}) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.contactMessages}/$id'), headers: await _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ApiResponse<dynamic>(success: true, message: 'Message supprimé');
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
