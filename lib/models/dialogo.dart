class DialogoCapitulo {
  final int regionIndex;
  final String fase; // 'inicio', 'meio', 'fim'
  final String personagem;
  final String emoji;
  final String texto;
  final int ordem;

  const DialogoCapitulo({
    required this.regionIndex,
    required this.fase,
    required this.personagem,
    required this.emoji,
    required this.texto,
    required this.ordem,
  });
}
