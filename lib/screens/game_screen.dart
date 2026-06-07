import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/game_theme.dart';
import '../widgets/dpad_widget.dart';
import '../widgets/action_buttons_widget.dart';

class GameScreen extends StatefulWidget {
  final String playerName;
  const GameScreen({super.key, required this.playerName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameController>().init(widget.playerName, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Consumer<GameController>(
          builder: (context, game, _) {
            return Column(
              children: [
                _TopBar(game: game),
                if (game.loadingPlayer)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: kGold,
                    backgroundColor: kDarkBlue,
                  ),
                Expanded(flex: 60, child: _Viewport(game: game)),
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
                Expanded(flex: 38, child: _Controls(game: game)),
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
    decoration: const BoxDecoration(shape: BoxShape.circle, color: kGoldDark),
  );
}

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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: ffBox(borderColor: kGoldDark, bgColor: kNavy),
              child: const Row(
                children: [
                  Icon(Icons.map_outlined, color: kGoldDark, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Mapa',
                    style: TextStyle(color: kGoldDark, fontSize: 11),
                  ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ffBox(borderColor: kGold, bgColor: kNavy),
            child: Column(
              children: [
                const Text(
                  'LV',
                  style: TextStyle(
                    color: kGoldDark,
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
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
                      Row(
                        children: List.generate(
                          region.cutsceneLines.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i <= game.cutsceneLine ? kGold : kBorder,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (!isLast)
                            GestureDetector(
                              onTap: game.skipCutscene,
                              child: const Text(
                                'PULAR',
                                style: TextStyle(
                                  color: kParchmentDim,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          const Text(
                            '▼',
                            style: TextStyle(color: kGold, fontSize: 12),
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
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(region.emoji, style: const TextStyle(fontSize: 60)),
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
                  Text(
                    region.description,
                    style: kBodyStyle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: game.startBattle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: ffBox(
                              borderColor: kGold,
                              bgColor: kGold.withValues(alpha: 0.1),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('⚔️', style: TextStyle(fontSize: 16)),
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
                      GestureDetector(
                        onTap: game.healPlayer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          decoration: ffBox(
                            borderColor: kGreenHPLight,
                            bgColor: kGreenHP.withValues(alpha: 0.1),
                          ),
                          child: const Text(
                            '💊',
                            style: TextStyle(fontSize: 18),
                          ),
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
        Expanded(
          flex: 42,
          child: _MonsterBattleStage(
            regionColor: region.backgroundColor,
            enemyName: enemy.name,
            enemyAssetPath: enemy.assetPath,
            enemyColor: enemy.color,
            enemyHp: enemy.hp,
            enemyMaxHp: enemy.maxHp,
            playerName: game.player.name,
            playerLevel: game.player.level,
            playerHp: game.player.hp,
            playerMaxHp: game.player.maxHp,
            hitEnemy: answerResult == true,
            hitPlayer: answerResult == false,
            feedback: answerResult == null
                ? null
                : answerResult
                ? 'Resposta correta! Ataque certeiro!'
                : 'Resposta errada! O inimigo contra-atacou!',
          ),
        ),
        Expanded(
          flex: 65,
          child: Container(
            color: kNavy,
            child: Column(
              children: [
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
                      const Text(
                        '❓ PERGUNTA',
                        style: TextStyle(
                          color: kGoldDark,
                          fontSize: 9,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.question,
                        style: kBodyStyle.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    itemCount: question.options.length,
                    itemBuilder: (context, i) {
                      final label = ['Ⅰ', 'Ⅱ', 'Ⅲ', 'Ⅳ'][i];
                      Color borderColor = kBorder;
                      Color bgColor = Colors.transparent;

                      if (answerResult != null && i == question.correctIndex) {
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
                            vertical: 9,
                            horizontal: 12,
                          ),
                          decoration: ffBox(
                            borderColor: borderColor,
                            bgColor: bgColor,
                          ),
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
                                    color: kParchment,
                                    fontSize: 12,
                                  ),
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

class _MonsterBattleStage extends StatelessWidget {
  final Color regionColor;
  final String enemyName;
  final String enemyAssetPath;
  final Color enemyColor;
  final int enemyHp;
  final int enemyMaxHp;
  final String playerName;
  final int playerLevel;
  final int playerHp;
  final int playerMaxHp;
  final bool hitEnemy;
  final bool hitPlayer;
  final String? feedback;

  const _MonsterBattleStage({
    required this.regionColor,
    required this.enemyName,
    required this.enemyAssetPath,
    required this.enemyColor,
    required this.enemyHp,
    required this.enemyMaxHp,
    required this.playerName,
    required this.playerLevel,
    required this.playerHp,
    required this.playerMaxHp,
    required this.hitEnemy,
    required this.hitPlayer,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: regionColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _BattleBackdropPainter()),
          ),
          Positioned(
            top: 9,
            left: 10,
            child: _BattleHpPanel(
              name: enemyName,
              level: 5,
              hp: enemyHp,
              maxHp: enemyMaxHp,
              alignRight: false,
            ),
          ),
          Positioned(
            top: 35,
            right: 22,
            child: _BattleSprite(
              key: ValueKey('enemy-$hitEnemy-$enemyHp'),
              label: enemyName,
              assetPath: enemyAssetPath,
              color: enemyColor,
              hit: hitEnemy,
              backView: false,
            ),
          ),
          Positioned(
            left: 20,
            bottom: 28,
            child: _BattleSprite(
              key: ValueKey('player-$hitPlayer-$playerHp'),
              label: playerName,
              assetPath: 'assets/images/16x32 Idle-Sheet.png',
              color: kGold,
              hit: hitPlayer,
              backView: true,
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: _BattleHpPanel(
              name: playerName.isEmpty ? 'VINI' : playerName,
              level: playerLevel,
              hp: playerHp,
              maxHp: playerMaxHp,
              alignRight: true,
              showNumbers: true,
            ),
          ),
          if (feedback != null)
            Positioned(
              left: 10,
              right: 10,
              bottom: 2,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: kNavy.withValues(alpha: 0.82),
                    border: Border.all(
                      color: hitEnemy ? kGreenHPLight : kCrimsonLight,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    feedback!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: hitEnemy ? kGreenHPLight : kCrimsonLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpriteImage extends StatelessWidget {
  final String assetPath;
  final String fallbackText;
  final double size;

  const _SpriteImage({
    required this.assetPath,
    required this.fallbackText,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,

      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(fallbackText, style: TextStyle(fontSize: size * 0.6)),
          ),
        );
      },
    );
  }
}

class _BattleSprite extends StatelessWidget {
  final String label;
  final String assetPath;
  final Color color;
  final bool hit;
  final bool backView;

  const _BattleSprite({
    super.key,
    required this.label,
    required this.assetPath,
    required this.color,
    required this.hit,
    required this.backView,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: hit ? 1 : 0),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final shake = hit ? sin(value * pi * 5) * 8 : 0.0;
        final lift = hit ? -sin(value * pi) * 5 : 0.0;
        final flashOpacity = hit ? (1 - value).clamp(0.0, 1.0) : 0.0;

        return Transform.translate(
          offset: Offset(shake, lift),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, 42),
                child: Container(
                  width: backView ? 116 : 104,
                  height: backView ? 28 : 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white24),
                  ),
                ),
              ),
              Container(
                width: backView ? 104 : 92,
                height: backView ? 104 : 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: backView ? 0.16 : 0.12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: 1.4,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      backView ? 'COSTAS' : 'FRENTE',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.16),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    _SpriteImage(
                      assetPath: assetPath,
                      fallbackText: backView ? '🧥' : assetPath,
                      size: backView ? 78 : 72,
                    ),
                    if (flashOpacity > 0)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kCrimsonLight.withValues(
                              alpha: 0.48 * flashOpacity,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                bottom: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: kNavy.withValues(alpha: 0.82),
                    border: Border.all(color: color.withValues(alpha: 0.55)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    label.length > 14 ? '${label.substring(0, 14)}...' : label,
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BattleHpPanel extends StatelessWidget {
  final String name;
  final int level;
  final int hp;
  final int maxHp;
  final bool alignRight;
  final bool showNumbers;

  const _BattleHpPanel({
    required this.name,
    required this.level,
    required this.hp,
    required this.maxHp,
    required this.alignRight,
    this.showNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxHp == 0 ? 0.0 : (hp / maxHp).clamp(0.0, 1.0);
    final hpColor = ratio > 0.5
        ? kGreenHPLight
        : ratio > 0.25
        ? kGold
        : kCrimsonLight;

    return Container(
      width: 142,
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0B8),
        border: Border.all(color: const Color(0xFF2F3A2D), width: 2),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
          bottomLeft: Radius.circular(alignRight ? 14 : 3),
          bottomRight: Radius.circular(alignRight ? 3 : 14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  name.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF273025),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                'Lv$level',
                style: const TextStyle(
                  color: Color(0xFF273025),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Text(
                'HP',
                style: TextStyle(
                  color: Color(0xFFB58A1C),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF273025),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(1),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: hpColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showNumbers) ...[
            const SizedBox(height: 2),
            Text(
              '$hp / $maxHp',
              style: const TextStyle(
                color: Color(0xFF273025),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BattleBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    for (double y = 8; y < size.height; y += 9) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stripePaint);
    }

    final arenaPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.73, size.height * 0.55),
        width: size.width * 0.42,
        height: 34,
      ),
      arenaPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.28, size.height * 0.78),
        width: size.width * 0.48,
        height: 38,
      ),
      arenaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
                const SizedBox(height: 10),
                Text(
                  '+${game.currentEnemy!.xpReward} XP',
                  style: const TextStyle(
                    color: kGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                const Text('[ A ] Continuar', style: kDimStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefeatView extends StatelessWidget {
  final GameController game;
  const _DefeatView({required this.game});

  @override
  Widget build(BuildContext context) {
    final region = game.currentRegion;
    return Container(
      color: region.backgroundColor,
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
                  'DERROTA!',
                  style: TextStyle(
                    color: kCrimsonLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Você foi derrotado...',
                  textAlign: TextAlign.center,
                  style: kBodyStyle,
                ),
                const SizedBox(height: 14),
                const Text('[ A ] Voltar ao mapa', style: kDimStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionCompleteView extends StatelessWidget {
  final GameController game;
  const _RegionCompleteView({required this.game});

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
                const Text('👑', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 10),
                const Text('REGIÃO CONQUISTADA!', style: kTitleStyle),
                const SizedBox(height: 10),
                Text(
                  region.name.toUpperCase(),
                  style: const TextStyle(
                    color: kGold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                const Text('[ A ] Continuar', style: kDimStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
            borderColor: kGold,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 14),
                const Text('JOGO COMPLETO!', style: kTitleStyle),
                const SizedBox(height: 10),
                const Text(
                  'Você salvou a PUC!',
                  textAlign: TextAlign.center,
                  style: kBodyStyle,
                ),
                const SizedBox(height: 14),
                const Text('[ A ] Voltar ao mapa', style: kDimStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
        if (game.singleEncounterMode) {
          return () => Navigator.of(context).pop(true);
        }
        return game.continueAfterVictory;
      case GameState.defeat:
        return game.restartAfterDefeat;
      case GameState.regionComplete:
        return game.moveToNextRegion;
      case GameState.gameComplete:
        return () => Navigator.of(context).pop();
      case GameState.combat:
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
      case GameState.gameComplete:
        return () => Navigator.of(context).pop();
      case GameState.combat:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const DPadWidget(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _MiniButton(label: 'SELECT'),
              SizedBox(height: 8),
              _MiniButton(label: 'START'),
            ],
          ),
          ActionButtonsWidget(onA: _onA(context), onB: _onB(context)),
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
