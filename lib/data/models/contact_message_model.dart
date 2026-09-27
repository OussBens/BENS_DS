// lib/data/models/contact_message_model.dart
enum ContactMessageStatus {
  nouveau,
  lu,
  repondu;

  static ContactMessageStatus fromString(String? value) {
    switch (value) {
      case 'READ':
        return ContactMessageStatus.lu;
      case 'RESPONDED':
        return ContactMessageStatus.repondu;
      default:
        return ContactMessageStatus.nouveau;
    }
  }

  String get apiValue {
    switch (this) {
      case ContactMessageStatus.lu:
        return 'READ';
      case ContactMessageStatus.repondu:
        return 'RESPONDED';
      case ContactMessageStatus.nouveau:
        return 'NEW';
    }
  }

  String get displayName {
    switch (this) {
      case ContactMessageStatus.nouveau:
        return 'Nouveau';
      case ContactMessageStatus.lu:
        return 'Lu';
      case ContactMessageStatus.repondu:
        return 'Répondu';
    }
  }
}

class ContactMessage {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String subject;
  final String message;
  final ContactMessageStatus status;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? respondedAt;

  ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.subject,
    required this.message,
    required this.status,
    this.adminNote,
    required this.createdAt,
    this.respondedAt,
  });

  factory ContactMessage.fromJson(Map<String, dynamic> json) {
    return ContactMessage(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      status: ContactMessageStatus.fromString(json['status']),
      adminNote: json['adminNote'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
    };
  }
}
