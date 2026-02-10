/// Modelo para representar un administrador
class AdminModel {
  final String id;
  final String email;
  final String? fullName;
  final String role;

  const AdminModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
    };
  }

  /// Si es super admin
  bool get isSuperAdmin => role == 'super_admin';

  /// Nombre a mostrar
  String get displayName => fullName ?? email.split('@').first;

  AdminModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
    );
  }
}
