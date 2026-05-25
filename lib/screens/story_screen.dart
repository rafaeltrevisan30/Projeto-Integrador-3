import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../models/dialogo.dart';
import '../data/dialogos_data.dart';

class StoryScreen extends StatefulWidget {
  final int regionIndex;
  final String playerName;

  const StoryScreen({
    super.key,
    required this.regionIndex,
    required this.playerName,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late int _currentDialogoIndex;
  late List<DialogoCapitulo> _dialogosRegiao;

  @override
  void initState() {
    super.initState();
    _dialogosRegiao = dialogosData
        .where((d) => d.regionIndex == widget.regionIndex)
        .toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    _currentDialogoIndex = 0;
  }

  void _proximoDialogo() {
    if (_currentDialogoIndex < _dialogosRegiao.length - 1) {
      setState(() => _currentDialogoIndex++);
    } else {
      Navigator.pop(context);
    }
  }

  void _pularDialogos() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_dialogosRegiao.isEmpty) {
      return Scaffold(
        backgroundColor: kNavy,
        body: Center(
          child: Text('Nenhum diálogo para esta região',
              style: TextStyle(color: kParchment)),
        ),
      );
    }

    final dialogo = _dialogosRegiao[_currentDialogoIndex];
    final isUltimo = _currentDialogoIndex == _dialogosRegiao.length - 1;

    return Scaffold(
      backgroundColor: kNavy,
      body: Stack(
        children: [
          // ── Fundo (mapa escuro) ────────────────────────────────
          Positioned.fill(
            child: Container(
              color: kNavy.withValues(alpha: 0.7),
            ),
          ),

          // ── Personagem (esquerda) ──────────────────────────────
          Positioned(
            left: 20,
            bottom: 100,
            child: Column(
              children: [
                // Box com nome
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kGold.withValues(alpha: 0.15),
                    border: Border.all(color: kGold, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    dialogo.personagem.toUpperCase(),
                    style: const TextStyle(
                      color: kGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Emoji grande do personagem
                Text(
                  dialogo.emoji,
                  style: const TextStyle(fontSize: 80),
                ),
              ],
            ),
          ),

          // ── Diálogo (rodapé) ───────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: kNavy,
                border: Border(
                  top: BorderSide(color: kGold, width: 2.5),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Texto do diálogo ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(left: 100),
                    child: Text(
                      dialogo.texto,
                      style: const TextStyle(
                        color: kParchment,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Controles ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicador de progresso
                      Text(
                        '${_currentDialogoIndex + 1}/${_dialogosRegiao.length}',
                        style: const TextStyle(
                          color: kParchmentDim,
                          fontSize: 11,
                        ),
                      ),

                      Row(
                        children: [
                          // Botão pular
                          GestureDetector(
                            onTap: _pularDialogos,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: kParchmentDim, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PULAR',
                                style: TextStyle(
                                  color: kParchmentDim,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Botão próximo
                          GestureDetector(
                            onTap: _proximoDialogo,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: kGold.withValues(alpha: 0.15),
                                border: Border.all(color: kGold, width: 1.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isUltimo ? 'FECHAR' : 'PRÓXIMO',
                                style: const TextStyle(
                                  color: kGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
