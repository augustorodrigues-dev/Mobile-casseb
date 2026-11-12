class Estande {
  const Estande({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.localizacao,
    required this.ativo,
  });
  final String id;
  final String nome;
  final String descricao;
  final String localizacao;
  final bool ativo;

  factory Estande.fromMap(String id, Map<String, dynamic> data) => Estande(
    id: id,
    nome: data['nome'] as String,
    descricao: data['descricao'] as String,
    localizacao: data['localizacao'] as String,
    ativo: data['ativo'] as bool,
  );
}
