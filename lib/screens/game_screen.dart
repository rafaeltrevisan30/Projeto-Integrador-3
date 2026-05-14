import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_region.dart';
import '../theme/game_theme.dart';
import '../widgets/dpad_widget.dart';
import '../widgets/action_buttons_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Consumer<GameController>(
          builder: (context, game, _) {
            return Column(
              children: [
                // ── Top bar ────────────────────────────────────────
                _TopBar(game: game),

                // ── Game viewport (tela do GameBoy) ───────────────
                Expanded(
                  flex: 60,
                  child: _Viewport(game: game),
                ),

                // ── Brand label ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _goldDot(),
                      const SizedBox(width: 8),
                      Text(
                        'INVASÃO  DA  PUC',
                        style: TextStyle(
                          color: kGoldDark,
                          fontSize: 10,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _goldDot(),
                    ],
                  ),
                ),

                // ── Controls ───────────────────────────────────────
                Expanded(
                  flex: 38,
                  child: _Controls(game: game),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _goldDot() => Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: kGoldDark,
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final GameController game;
  const _TopBar({required this.game});

  @override
  Widget build(BuildContext context) {
    final player = game.player;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kGoldDark, width: 1)),
      ),
      child: Row(
        children: [
          // Back to map
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: ffBox(borderColor: kGoldDark, bgColor: kNavy),
              child: const Row(
                children: [
                  Icon(Icons.map_outlined, color: kGoldDark, size: 14),
                  SizedBox(width: 4),
                  Text('Mapa',
                      style: TextStyle(color: kGoldDark, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FfBar(
                  label: 'HP',
                  current: player.hp,
                  max: player.maxHp,
                  color: kGreenHP,
                  lightColor: kGreenHPLight,
                ),
                const SizedBox(height: 3),
                FfBar(
                  label: 'XP',
                  current: player.xp,
                  max: player.xpToNextLevel,
                  color: kBlueXP,
                  lightColor: kBlueXPLight,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ffBox(borderColor: kGold, bgColor: kNavy),
            child: Column(
              children: [
                const Text('LV',
                    style: TextStyle(color: kGoldDark, fontSize: 8, letterSpacing: 1)),
                Text(
                  '${player.level}',
                  style: const TextStyle(
                    color: kGold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// VIEWPORT (tela do GameBoy com borda dourada)
// ═══════════════════════════════════════════════════════════════
class _Viewport extends StatelessWidget {
  final GameController game;
  const _Viewport({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kNavy,
        border: Border.all(color: kGold, width: 2.5),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _viewFor(game.state),
      ),
    );
  }

  Widget _viewFor(GameState state) {
    switch (state) {
      case GameState.cutscene:
        return _CutsceneView(game: game);
      case GameState.exploring:
        return _ExploreView(game: game);
      case GameState.combat:
        return _CombatView(game: game);
      case GameState.victory:
        return _VictoryView(game: game);
      case GameState.defeat:
        return _DefeatView(game: game);
      case GameState.regionComplete:
        return _RegionCompleteView(game: game);
      case GameState.gameComplete:
        return _GameCompleteView(game: game);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// CUTSCENE  — estilo Final Fantasy (caixa de diálogo inferior)
// ═══════════════════════════════════════════════════════════════
class _CutsceneView extends StatelessWidget {
  final GameController game;
  const _CutsceneView({required this.game});

  @override
  Widget build(BuildContext context) {
    final region = game.currentRegion;
    final line = region.cutsceneLines[game.cutsceneLine];
    final isLast = game.cutsceneLine == region.cutsceneLines.length - 1;

    return GestureDetector(
      onTap: game.advanceCutscene,
      child: Stack(
        children: [
          // Fundo: cor da região
          Container(
            color: region.backgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(region.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 8),
                  Text(
                    region.name.toUpperCase(),
                    style: TextStyle(
                      color: region.primaryColor.withValues(alpha: 0.5),
                      fontSize: 12,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Caixa de diálogo estilo FF (parte inferior)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: kNavy,
                border: Border(top: BorderSide(color: kGold, width: 2)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speaker label
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: ffBox(borderColor: kGold, bgColor: kDarkBlue),
                    child: Text(
                      region.name.toUpperCase(),
                      style: const TextStyle(
                        color: kGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(line, style: kBodyStyle),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress dots
                      Row(
                        children: List.generate(
                          region.cutsceneLines.length,
                          (i) => Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i <= game.cutsceneLine
                                  ? kGold
                                  : kBorder,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (!isLast)
                            GestureDetector(
                              onTap: game.skipCutscene,
                              child: const Text('PULAR',
                                  style: TextStyle(
                                      color: kParchmentDim,
                                      fontSize: 10,
                                      letterSpacing: 1.5)),
                            ),
                          const SizedBox(width: 12),
                          const Text('▼',
                              style:
                                  TextStyle(color: kGold, fontSize: 12)),
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

// ═══════════════════════════════════════════════════════════════
// EXPLORE VIEW
// ═══════════════════════════════════════════════════════════════
class _ExploreView extends StatelessWidget {
  final GameController game;
  const _ExploreView({required this.game});

  @override
  Widget build(BuildContext context) {
    final region = game.currentRegion;

    return Container(
      color: region.backgroundColor,
      child: Stack(
        children: [
          // Paisagem / cenário da região
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(region.emoji,
                      style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 4),
                  Text(
                    region.name.toUpperCase(),
                    style: TextStyle(
                      color: region.primaryColor.withValues(alpha: 0.3),
                      fontSize: 11,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Painel inferior de exploração
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: kNavy,
                border: Border(top: BorderSide(color: kGold, width: 2)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(region.description,
                      style: kBodyStyle.copyWith(fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Batalhar
                      Expanded(
                        child: GestureDetector(
                          onTap: game.startBattle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            decoration: ffBox(
                              borderColor: kGold,
                              bgColor: kGold.withValues(alpha: 0.1),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('⚔️',
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(width: 8),
                                Text(
                                  'BATALHAR',
                                  style: TextStyle(
                                    color: kGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Curar
                      GestureDetector(
                        onTap: game.healPlayer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          decoration: ffBox(
                            borderColor: kGreenHPLight,
                            bgColor:
                                kGreenHP.withValues(alpha: 0.1),
                          ),
                          child: const Text('💊',
                              style: TextStyle(fontSize: 18)),
                        ),
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

// ═══════════════════════════════════════════════════════════════
// COMBAT VIEW  — estilo FF com pergunta + opções
// ═══════════════════════════════════════════════════════════════
class _CombatView extends StatelessWidget {
  final GameController game;
  const _CombatView({required this.game});

  @override
  Widget build(BuildContext context) {
    final enemy = game.currentEnemy!;
    final region = game.currentRegion;
    final question = enemy.currentQuestion;
    final answerResult = game.lastAnswerCorrect;

    return Column(
      children: [
        // ── Seção do inimigo ──────────────────────────────
        Expanded(
          flex: 35,
          child: Container(
            color: region.backgroundColor,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sprite do inimigo
                Container(
                  width: 70,
                  height: 70,
                  decoration: ffBox(
                      borderColor: enemy.color,
                      bgColor: kNavy),
                  child: Center(
                    child: Text(enemy.emoji,
                        style: const TextStyle(fontSize: 38)),
                  ),
                ),
                const SizedBox(width: 10),
                // Stats do inimigo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enemy.name.toUpperCase(),
                        style: TextStyle(
                          color: enemy.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FfBar(
                        label: 'HP',
                        current: enemy.hp,
                        max: enemy.maxHp,
                        color: kCrimson,
                        lightColor: kCrimsonLight,
                      ),
                      const SizedBox(height: 8),
                      // Feedback da resposta
                      if (answerResult != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: ffBox(
                            borderColor: answerResult
                                ? kGreenHPLight
                                : kCrimsonLight,
                            bgColor: answerResult
                                ? kGreenHP.withValues(alpha: 0.2)
                                : kCrimson.withValues(alpha: 0.2),
                          ),
                          child: Text(
                            answerResult
                                ? '✦ Acerto! Ataque crítico!'
                                : '✦ Errou! Tome o golpe!',
                            style: TextStyle(
                              color: answerResult
                                  ? kGreenHPLight
                                  : kCrimsonLight,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Caixa de pergunta ─────────────────────────────
        Expanded(
          flex: 65,
          child: Container(
            color: kNavy,
            child: Column(
              children: [
                // Pergunta (caixa de diálogo estilo FF)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: kGold, width: 2),
                      bottom: BorderSide(color: kGoldDark, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('❓ PERGUNTA',
                          style: TextStyle(
                              color: kGoldDark,
                              fontSize: 9,
                              letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text(question.question, style: kBodyStyle.copyWith(fontSize: 13)),
                    ],
                  ),
                ),

                // Opções de resposta
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    itemCount: question.options.length,
                    itemBuilder: (context, i) {
                      final label = ['Ⅰ', 'Ⅱ', 'Ⅲ', 'Ⅳ'][i];
                      Color borderColor = kBorder;
                      Color bgColor = Colors.transparent;

                      if (answerResult != null &&
                          i == question.correctIndex) {
                        borderColor = kGreenHPLight;
                        bgColor = kGreenHP.withValues(alpha: 0.15);
                      }

                      return GestureDetector(
                        onTap: game.answerLocked
                            ? null
                            : () => game.answerQuestion(i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              vertical: 9, horizontal: 12),
                          decoration: ffBox(
                              borderColor: borderColor, bgColor: bgColor),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: kGoldDark.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      color: kGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  question.options[i],
                                  style: const TextStyle(
                                      color: kParchment, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// VICTORY
// ═══════════════════════════════════════════════════════════════
class _VictoryView extends StatelessWidget {
  final GameController game;
  const _VictoryView({required this.game});

  @override
  Widget build(BuildContext context) {
    final region = game.currentRegion;
    return Container(
      color: region.backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FfCornerBox(
            borderColor: kGold,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 10),
                const Text('VITÓRIA!', style: kTitleStyle),
                const SizedBox(height: 6),
                Text(
                  '+ ${game.currentEnemy?.xpReward ?? 0}  XP',
                  style: const TextStyle(
                      color: kGoldLight,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                if (game.leveledUp) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: ffBox(
                        borderColor: kGoldLight,
                        bgColor:
                            kGold.withValues(alpha: 0.1)),
                    child: Text(
                      '⬆  NÍVEL ${game.player.level}!',
                      style: const TextStyle(
                          color: kGoldLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Pressione  A  para continuar',
                  style: kDimStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DEFEAT
// ═══════════════════════════════════════════════════════════════
class _DefeatView extends StatelessWidget {
  final GameController game;
  const _DefeatView({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kNavy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FfCornerBox(
            borderColor: kCrimsonLight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💀', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 10),
                const Text(
                  'DERROTA',
                  style: TextStyle(
                    color: kCrimsonLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seus conhecimentos não\nforam suficientes...',
                  textAlign: TextAlign.center,
                  style: kBodyStyle,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: game.restartAfterDefeat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: ffBox(
                        borderColor: kCrimsonLight,
                        bgColor:
                            kCrimson.withValues(alpha: 0.1)),
                    child: const Text(
                      '↺  TENTAR NOVAMENTE',
                      style: TextStyle(
                          color: kCrimsonLight,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REGION COMPLETE
// ═══════════════════════════════════════════════════════════════
class _RegionCompleteView extends StatelessWidget {
  final GameController game;
  const _RegionCompleteView({required this.game});

  @override
  Widget build(BuildContext context) {
    final region = game.currentRegion;
    final nextIndex = game.player.currentRegion + 1;
    final nextRegion = gameRegions[nextIndex];

    return Container(
      color: kNavy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FfCornerBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(region.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 8),
                Text(
                  '${region.name.toUpperCase()}\nCONCLUÍDA!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: region.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: kGoldDark),
                const SizedBox(height: 10),
                const Text('Próxima região:', style: kDimStyle),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(nextRegion.emoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      nextRegion.name.toUpperCase(),
                      style: TextStyle(
                        color: nextRegion.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Pressione  A  para avançar', style: kDimStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GAME COMPLETE
// ═══════════════════════════════════════════════════════════════
class _GameCompleteView extends StatelessWidget {
  final GameController game;
  const _GameCompleteView({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kNavy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FfCornerBox(
            borderColor: kGoldLight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 10),
                const Text('A PUC FOI SALVA!', style: kTitleStyle),
                const SizedBox(height: 6),
                Text(
                  'Herói: ${game.player.name}',
                  style: const TextStyle(color: kParchment, fontSize: 14),
                ),
                Text(
                  'Nível ${game.player.level}',
                  style: const TextStyle(color: kGoldLight, fontSize: 13),
                ),
                const SizedBox(height: 12),
                const Divider(color: kGoldDark),
                const SizedBox(height: 8),
                const Text(
                  'Todas as 5 regiões do campus\nforam libertadas!\n\nSeu conhecimento triunfou!',
                  textAlign: TextAlign.center,
                  style: kBodyStyle,
                ),
                const SizedBox(height: 12),
                const Text('⭐ ⭐ ⭐ ⭐ ⭐',
                    style: TextStyle(fontSize: 22, letterSpacing: 6)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: ffBox(
                        borderColor: kGold,
                        bgColor:
                            kGold.withValues(alpha: 0.1)),
                    child: const Text(
                      '🗺️  Voltar ao Mapa',
                      style: TextStyle(
                          color: kGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CONTROLS  — GameBoy com estética medieval
// ═══════════════════════════════════════════════════════════════
class _Controls extends StatelessWidget {
  final GameController game;
  const _Controls({required this.game});

  VoidCallback? _onA(BuildContext context) {
    switch (game.state) {
      case GameState.cutscene:
        return game.advanceCutscene;
      case GameState.exploring:
        return game.startBattle;
      case GameState.victory:
        return game.continueAfterVictory;
      case GameState.defeat:
        return game.restartAfterDefeat;
      case GameState.regionComplete:
        return game.moveToNextRegion;
      case GameState.gameComplete:
        return () => Navigator.of(context).pop();
      default:
        return null;
    }
  }

  VoidCallback? _onB(BuildContext context) {
    switch (game.state) {
      case GameState.cutscene:
        return game.skipCutscene;
      case GameState.exploring:
      case GameState.victory:
      case GameState.defeat:
      case GameState.regionComplete:
        return () => Navigator.of(context).pop();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DPadWidget(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniButton(label: 'SELECT'),
              const SizedBox(height: 8),
              _MiniButton(label: 'START'),
            ],
          ),
          ActionButtonsWidget(
            onA: _onA(context),
            onB: _onB(context),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  const _MiniButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: kGoldDark, width: 1.5),
        color: kNavy,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: kGoldDark,
            fontSize: 7,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
