import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_model.freezed.dart';

/// Modelo de Cliente - Capa de Datos
/// Representa un usuario registrado en la tienda
@Freezed(fromJson: false, toJson: false)
class CustomerModel with _$CustomerModel {
  const factory CustomerModel({
    required String id,
    required String email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? defaultAddressId,
    @Default(false) bool newsletter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CustomerModel;

  const CustomerModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        defaultAddressId: json['default_address_id'] as String?,
        newsletter: json['newsletter'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
        'default_address_id': defaultAddressId,
        'newsletter': newsletter,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// Nombre para mostrar (nombre completo o email)
  String get displayName => fullName ?? email.split('@').first;

  /// Iniciales para avatar placeholder
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// ¿Tiene perfil completo?
  bool get isProfileComplete =>
      fullName != null && fullName!.isNotEmpty && phone != null;
}

/// Modelo de Dirección del Cliente
@Freezed(fromJson: false, toJson: false)
class CustomerAddressModel with _$CustomerAddressModel {
  const factory CustomerAddressModel({
    required String id,
    required String customerId,
    String? label,
    required String fullName,
    required String street,
    String? streetNumber,
    String? apartment,
    required String city,
    String? state,
    required String postalCode,
    @Default('España') String country,
    String? phone,
    @Default(false) bool isDefault,
    DateTime? createdAt,
  }) = _CustomerAddressModel;

  const CustomerAddressModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) =>
      CustomerAddressModel(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        label: json['label'] as String?,
        fullName: json['full_name'] as String,
        street: json['street'] as String,
        streetNumber: json['street_number'] as String?,
        apartment: json['apartment'] as String?,
        city: json['city'] as String,
        state: json['state'] as String?,
        postalCode: json['postal_code'] as String,
        country: json['country'] as String? ?? 'España',
        phone: json['phone'] as String?,
        isDefault: json['is_default'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'label': label,
        'full_name': fullName,
        'street': street,
        'street_number': streetNumber,
        'apartment': apartment,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'phone': phone,
        'is_default': isDefault,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Dirección formateada en una línea
  String get formattedAddress {
    final parts = <String>[
      street,
      if (streetNumber != null) streetNumber!,
      if (apartment != null) apartment!,
    ];
    return '${parts.join(' ')}, $postalCode $city';
  }

  /// Dirección completa multilinea
  String get fullAddress {
    final lines = <String>[
      fullName,
      '$street ${streetNumber ?? ''}${apartment != null ? ', $apartment' : ''}',
      '$postalCode $city',
      if (state != null) state!,
      country,
    ];
    return lines.join('\n');
  }
}
