enum UserRole {
  customer,
  vip,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.vip:
        return 'VIP Member';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: _parseRole(json['role'] ?? 'customer'),
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
    );
  }

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'vip':
        return UserRole.vip;
      default:
        return UserRole.customer;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }
}