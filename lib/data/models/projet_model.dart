// lib/data/models/projet_model.dart
class Projet {
  final int id;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final List<String> gallery;
  final List<String> technologies;
  final String? clientName;
  final String? projectUrl;
  final bool isFeatured;
  final bool isPublished;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Projet({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.gallery,
    required this.technologies,
    this.clientName,
    this.projectUrl,
    required this.isFeatured,
    required this.isPublished,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  static List<String> _parseStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  factory Projet.fromJson(Map<String, dynamic> json) {
    return Projet(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
      gallery: _parseStringList(json['gallery']),
      technologies: _parseStringList(json['technologies']),
      clientName: json['clientName'],
      projectUrl: json['projectUrl'],
      isFeatured: json['isFeatured'] == true,
      isPublished: json['isPublished'] ?? true,
      order: json['order'] is int ? json['order'] : int.tryParse(json['order'].toString()) ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'gallery': gallery,
      'technologies': technologies,
      'clientName': clientName,
      'projectUrl': projectUrl,
      'isFeatured': isFeatured,
      'isPublished': isPublished,
      'order': order,
    };
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}
