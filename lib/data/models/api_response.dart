// lib/data/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? count;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.count,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      count: json['count'],
    );
  }
}