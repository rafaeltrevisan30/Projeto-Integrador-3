class Ambiente {

  final String id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;
  final double raioMetros;

  const Ambiente({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.raioMetros,
  });

  factory Ambiente.fromFirestore(
    Map<String, dynamic> data,
  ) {
    return Ambiente(

      id: data['id'] ?? '',
      nome: data['nome'] ?? '',
      descricao:
          data['descricao'] ?? '',
      latitude:
          (data['latitude'] ?? 0)
              .toDouble(),
      longitude:
          (data['longitude'] ?? 0)
              .toDouble(),
      raioMetros:
          (data['raioMetros'] ?? 0)
              .toDouble(),
    );
  }
}