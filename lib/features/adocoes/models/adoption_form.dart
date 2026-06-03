class AdoptionForm {
  String tipoResidencia = '';
  bool? areaExterna;
  bool? telaProtetora;
  String quantidadeMoradores = '';
  String composicaoFamiliar = '';

  bool? possuiAnimais;
  String quantidadeAnimais = '';
  String idadeAnimais = '';
  String sexoAnimais = '';
  String comportamentoAnimais = '';

  bool? possuiCriancas;
  String quantidadeCriancas = '';
  String faixaEtariaCriancas = '';
  bool? criancaNecessidadeEspecial;
  String tipoNecessidadeCriancas = '';

  bool? familiarNecessidadeEspecial;
  String tipoNecessidadeEspecialFamiliar = '';

  bool? experienciaComAnimais;
  bool? conhecimentoDespesasAnimais;
  String tempoDisponivel = '';

  Map<String, dynamic> toJson() => {
    'tipo_residencia': tipoResidencia,
    'area_externa': areaExterna,
    'tela_protetora': telaProtetora,
    'quantidade_moradores': quantidadeMoradores,
    'composicao_familiar': composicaoFamiliar,
    'possui_animais': possuiAnimais,
    'quantidade_animais': quantidadeAnimais,
    'idade_animais': idadeAnimais,
    'sexo_animais': sexoAnimais,
    'comportamento_animais': comportamentoAnimais,
    'possui_criancas': possuiCriancas,
    'quantidade_criancas': quantidadeCriancas,
    'faixa_etaria_criancas': faixaEtariaCriancas,
    'crianca_necessidade_especial': criancaNecessidadeEspecial,
    'tipo_necessidade_criancas': tipoNecessidadeCriancas,
    'familiar_necessidade_especial': familiarNecessidadeEspecial,
    'tipo_necessidade_especial_familiar': tipoNecessidadeEspecialFamiliar,
    'experiencia_com_animais': experienciaComAnimais,
    'conhecimento_despesas_animais': conhecimentoDespesasAnimais,
    'tempo_disponivel': tempoDisponivel,
  };
}
