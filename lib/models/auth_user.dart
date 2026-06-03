class AuthUser {
  final String uuid;
  final String email;
  final String? fullName;
  final String? telefone;
  final String? cidade;
  final String? bairro;
  final bool isOng;
  final Map<String, dynamic> raw;

  const AuthUser({
    required this.uuid,
    required this.email,
    this.fullName,
    this.telefone,
    this.cidade,
    this.bairro,
    this.isOng = false,
    this.raw = const {},
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
      raw: json,
    );
  }

  String? get dataNascimento => raw['dataNascimento'] as String?;
  String? get cpf => raw['cpf'] as String?;
  String? get cep => raw['cep'] as String?;
  String? get rua => raw['rua'] as String?;
  String? get numero => raw['numero']?.toString();
  String? get complemento => raw['complemento'] as String?;
  String? get estado => raw['estado'] as String?;

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return email.split('@').first;
  }
}
