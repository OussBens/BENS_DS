// lib/data/models/cordonne_model.dart
class Cordonne {
  final int id;
  final String telephone;
  final String email;
  final String adresse;
  final String horraire;

  Cordonne({
    required this.id,
    required this.telephone,
    required this.email,
    required this.adresse,
    required this.horraire,
  });

  factory Cordonne.fromJson(Map<String, dynamic> json) {
    return Cordonne(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      telephone: json['telephone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      horraire: json['horraire']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'horraire': horraire,
    };
  }

  Cordonne copyWith({
    int? id,
    String? telephone,
    String? email,
    String? adresse,
    String? horraire,
  }) {
    return Cordonne(
      id: id ?? this.id,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
      horraire: horraire ?? this.horraire,
    );
  }
}