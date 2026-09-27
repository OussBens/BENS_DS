// lib/data/models/temoin_model.dart
class Temoin {
  final int id;
  final String nomClient;
  final String? titre;
  final String? modeleVoiture;
  final String contenu;
  final int note; // 1 à 5 étoiles
  final List<String> photos;
  final String? video;
  final DateTime date;
  final bool isActive;
  final String creePar;
  final DateTime creeLe;
  final String? modifiePar;
  final DateTime? modifieLe;

  Temoin({
    required this.id,
    required this.nomClient,
    this.titre,
    this.modeleVoiture,
    required this.contenu,
    required this.note,
    required this.photos,
    this.video,
    required this.date,
    required this.isActive,
    required this.creePar,
    required this.creeLe,
    this.modifiePar,
    this.modifieLe,
  });

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  static int _parseNote(dynamic value) {
    if (value == null) return 5;
    final parsed = value is int ? value : int.tryParse(value.toString()) ?? 5;
    return parsed.clamp(1, 5);
  }

  factory Temoin.fromJson(Map<String, dynamic> json) {
    List<String> photosList = [];
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        photosList = (json['photos'] as List).map((e) => e.toString()).toList();
      } else if (json['photos'] is String && (json['photos'] as String).isNotEmpty) {
        photosList = [json['photos'] as String];
      }
    }

    return Temoin(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nomClient: json['nomClient'] ?? '',
      titre: json['titre'],
      modeleVoiture: json['modeleVoiture'],
      contenu: json['contenu'] ?? '',
      note: _parseNote(json['note']),
      photos: photosList,
      video: (json['video'] != null && json['video'].toString().isNotEmpty) ? json['video'] : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      isActive: _parseBool(json['isActive']),
      creePar: json['creePar'] ?? 'system',
      creeLe: json['creeLe'] != null ? DateTime.parse(json['creeLe']) : DateTime.now(),
      modifiePar: json['modifiePar'],
      modifieLe: json['modifieLe'] != null ? DateTime.parse(json['modifieLe']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomClient': nomClient,
      'titre': titre,
      'modeleVoiture': modeleVoiture,
      'contenu': contenu,
      'note': note,
      'photos': photos,
      'video': video,
      'date': date.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'creePar': creePar,
      'creeLe': creeLe.toIso8601String(),
      'modifiePar': modifiePar,
      'modifieLe': modifieLe?.toIso8601String(),
    };
  }

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  bool get hasPhoto => photos.isNotEmpty;
  bool get hasVideo => video != null && video!.isNotEmpty;
  String get displayPhoto => photos.isNotEmpty ? photos.first : '';
}
