import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';

class Animal {
  final String id;
  final String nome;
  final String sexo;
  final String idade;
  final String raca;
  final String especie;
  final String? imageUrl;
  final String? imageAsset;
  final String bairro;
  final String cidade;
  final String distancia;
  final bool isLiked;

  final String? porte;
  final bool? castrado;
  final String? necessidadesEspeciais;
  final String? historia;
  final String? statusAnimal;
  final bool? sociavelAnimal;
  final bool? sociavelPessoa;
  final String? corNome;
  final Color? corHex;
  final String? ongNome;
  final String? ongEmail;
  final String? ongTelefone;
  final List<String> fotos;

  const Animal({
    required this.id,
    required this.nome,
    required this.sexo,
    required this.idade,
    required this.raca,
    required this.especie,
    this.imageUrl,
    this.imageAsset,
    this.bairro = 'Não informado',
    this.cidade = 'Não informado',
    this.distancia = 'Próximo',
    this.isLiked = false,
    this.porte,
    this.castrado,
    this.necessidadesEspeciais,
    this.historia,
    this.statusAnimal,
    this.sociavelAnimal,
    this.sociavelPessoa,
    this.corNome,
    this.corHex,
    this.ongNome,
    this.ongEmail,
    this.ongTelefone,
    this.fotos = const [],
  });

  Animal copyWith({bool? isLiked}) => Animal(
        id: id,
        nome: nome,
        sexo: sexo,
        idade: idade,
        raca: raca,
        especie: especie,
        imageUrl: imageUrl,
        imageAsset: imageAsset,
        bairro: bairro,
        cidade: cidade,
        distancia: distancia,
        isLiked: isLiked ?? this.isLiked,
        porte: porte,
        castrado: castrado,
        necessidadesEspeciais: necessidadesEspeciais,
        historia: historia,
        statusAnimal: statusAnimal,
        sociavelAnimal: sociavelAnimal,
        sociavelPessoa: sociavelPessoa,
        corNome: corNome,
        corHex: corHex,
        ongNome: ongNome,
        ongEmail: ongEmail,
        ongTelefone: ongTelefone,
        fotos: fotos,
      );

  factory Animal.fromJson(Map<String, dynamic> json) {
    final fotos = json['fotos'] as List<dynamic>?;
    final ong = json['ong'] as Map<String, dynamic>?;
    final cor = json['cor'] as Map<String, dynamic>?;
    final urls = fotos
            ?.map((e) => (e as Map<String, dynamic>)['url'] as String?)
            .whereType<String>()
            .toList() ??
        const <String>[];
    return Animal(
      id: json['uuid'] as String? ?? json['id'] as String,
      nome: json['nome'] as String? ?? 'Nome animal',
      sexo: json['sexo'] as String? ?? 'M',
      idade: formatAge(json['dataNascimento'] as String?),
      raca: (json['raca'] as Map<String, dynamic>?)?['nome'] as String? ??
          'Sem raça definida',
      especie: _especieKey(json['especie']),
      imageUrl: urls.isNotEmpty ? urls.first : null,
      bairro: ong?['bairro'] as String? ?? 'Não informado',
      cidade: ong?['cidade'] as String? ?? 'Não informado',
      isLiked: json['isLiked'] as bool? ?? false,
      porte: json['porte'] as String?,
      castrado: _toBool(json['castrado']),
      necessidadesEspeciais: json['necessidadesEspeciais'] as String?,
      historia: json['historia'] as String?,
      statusAnimal: json['statusAnimal'] as String?,
      sociavelAnimal: _toBool(json['sociavelAnimal']),
      sociavelPessoa: _toBool(json['sociavelPessoa']),
      corNome: cor?['nome'] as String?,
      corHex: _parseHex(cor?['hexadecimal'] as String?),
      ongNome: ong?['nome'] as String?,
      ongEmail: ong?['email'] as String?,
      ongTelefone: ong?['telefone'] as String?,
      fotos: urls,
    );
  }

  static bool? _toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    return null;
  }

  static Color? _parseHex(String? hex) {
    if (hex == null) return null;
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    final value = int.tryParse(h, radix: 16);
    return value == null ? null : Color(value);
  }

  static const _especieMap = {
    'cachorro': 'dog',
    'gato': 'cat',
    'cavalo': 'horse',
    'equino': 'horse',
    'pássaro': 'bird',
    'passaro': 'bird',
    'ave': 'bird',
    'coelho': 'rabbit',
    'roedor': 'rat',
    'cobra': 'snake',
    'serpente': 'snake',
  };

  static String _especieKey(dynamic especie) {
    final nome = especie is Map<String, dynamic>
        ? especie['nome'] as String?
        : especie as String?;
    if (nome == null) return 'dog';
    return _especieMap[nome.toLowerCase()] ?? nome.toLowerCase();
  }
}
