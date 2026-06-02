class AuthUser {
  final String uuid;
  final String email;
  final String? fullName;
  final String? telefone;
  final String? cidade;
  final String? bairro;
  final bool isOng;

  const AuthUser({
    required this.uuid,
    required this.email,
    this.fullName,
    this.telefone,
    this.cidade,
    this.bairro,
    this.isOng = false,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uuid: json['uuid'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['nome'] as String?,
      telefone: json['telefone'] as String?,
      cidade: json['cidade'] as String?,
      bairro: json['bairro'] as String?,
      isOng: json['cnpj'] != null,
    );
  }

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return email.split('@').first;
  }
}
