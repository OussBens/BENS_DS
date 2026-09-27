// lib/data/models/service_model.dart
class Service {
  final int id;
  final String title;
  final String description;
  final String icon;
  final List<String> technologies;
  final double? priceFrom;
  final int order;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.technologies,
    this.priceFrom,
    required this.order,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  static List<String> _parseStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      technologies: _parseStringList(json['technologies']),
      priceFrom: json['priceFrom'] != null ? double.tryParse(json['priceFrom'].toString()) : null,
      order: json['order'] is int ? json['order'] : int.tryParse(json['order'].toString()) ?? 0,
      isPublished: json['isPublished'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'technologies': technologies,
      'priceFrom': priceFrom,
      'order': order,
      'isPublished': isPublished,
    };
  }
}
