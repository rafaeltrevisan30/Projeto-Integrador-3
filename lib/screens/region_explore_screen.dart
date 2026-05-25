import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/campaign_controller.dart';
import '../controllers/game_controller.dart';
import '../data/campaign_story_data.dart';
import '../models/campaign_scene.dart';
import '../models/game_region.dart';
import '../models/map_entity.dart';
import '../theme/game_theme.dart';
import '../widgets/dpad_widget.dart';
import '../widgets/action_buttons_widget.dart';
import 'game_screen.dart';
import 'region_conclusion_screen.dart';

class RegionExploreScreen extends StatefulWidget {
  final int regionIndex;
  final String playerName;

  const RegionExploreScreen({
    super.key,
    required this.regionIndex,
    required this.playerName,
  });

  @override
  State<RegionExploreScreen> createState() => _RegionExploreScreenState();
}

class _RegionExploreScreenState extends State<RegionExploreScreen> {
  late int _px;
  late int _py;
  late List<MapEntity> _entities;
  MapEntity? _activeDialogue;
  VoidCallback? _afterDialogue;
  int _dialogueLine = 0;
  bool _showRegionIntro = false;
  int _introLine = 0;

  @override
  void initState() {
    super.initState();
    _px = playerStartX(widget.regionIndex);
    _py = playerStartY(widget.regionIndex);
    _entities = entitiesForRegion(widget.regionIndex);
    _showRegionIntro = regionIntroScenes.containsKey(widget.regionIndex);
  }

  // ── Movimento ───────────────────────────────────────────────────
  void _move(int dx, int dy) {
    if (_showRegionIntro || _activeDialogue != null) return;

    final nx = (_px + dx).clamp(0, kMapW - 1);
    final ny = (_py + dy).clamp(0, kMapH - 1);

    final entity = _entityAt(nx, ny);

    if (entity != null) {
      if (entity.type == EntityType.enemy || entity.type == EntityType.boss) {
        _handleEnemy(entity);
        return;
      }
      // NPC bloqueia o caminho — fica no lugar, abre diálogo
      _openDialogue(entity);
      return;
    }

    setState(() {
      _px = nx;
      _py = ny;
    });
  }

  // ── Ação (botão A) ───────────────────────────────────────────────
  void _onA() {
    if (_showRegionIntro) {
      _advanceRegionIntro();
      return;
    }

    if (_activeDialogue != null) {
      _advanceDialogue();
      return;
    }
    // Verifica NPC adjacente
    final adj = _adjacentNpc();
    if (adj != null) {
      _openDialogue(adj);
      return;
    }
    // Verifica inimigo adjacente
    final enemy = _adjacentEnemy();
    if (enemy != null) {
      _handleEnemy(enemy);
    }
  }

  void _onB() {
    if (_showRegionIntro) {
      setState(() => _showRegionIntro = false);
      return;
    }

    if (_activeDialogue != null) {
      setState(() {
        _activeDialogue = null;
        _afterDialogue = null;
        _dialogueLine = 0;
      });
      return;
    }
    Navigator.pop(context);
  }

  void _advanceRegionIntro() {
    final intro = regionIntroScenes[widget.regionIndex];
    if (intro == null) {
      setState(() => _showRegionIntro = false);
      return;
    }

    if (_introLine < intro.dialogue.length - 1) {
      setState(() => _introLine++);
      return;
    }

    setState(() => _showRegionIntro = false);
  }

  void _openDialogue(MapEntity entity, {VoidCallback? afterDialogue}) {
    setState(() {
      _activeDialogue = entity;
      _afterDialogue = afterDialogue;
      _dialogueLine = 0;
    });
  }

  void _advanceDialogue() {
    final d = _activeDialogue!;
    if (_dialogueLine < d.dialogues.length - 1) {
      setState(() => _dialogueLine++);
    } else {
      final afterDialogue = _afterDialogue;
      setState(() {
        _activeDialogue = null;
        _afterDialogue = null;
        _dialogueLine = 0;
      });
      afterDialogue?.call();
    }
  }

  void _handleEnemy(MapEntity entity) {
    if (entity.preCombatDialogues.isNotEmpty) {
      _openDialogue(
        _dialogueCopy(entity, entity.preCombatDialogues),
        afterDialogue: () => _startCombat(entity),
      );
      return;
    }
    _startCombat(entity);
  }

  Future<void> _startCombat(MapEntity entity) async {
    final game = context.read<GameController>();
    game.enterEncounter(widget.regionIndex, entity.enemyIndex ?? 0);
    game.startBattle();
    final won = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(playerName: widget.playerName),
      ),
    );
    if (!mounted || won != true) return;

    if (entity.type == EntityType.boss) {
      context.read<CampaignController>().markBossDefeated(widget.regionIndex);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegionConclusionScreen(
            regionIndex: widget.regionIndex,
            playerName: widget.playerName,
          ),
        ),
      );
      return;
    }

    setState(() {
      _entities.removeWhere((e) => e.id == entity.id);
    });

    if (entity.victoryDialogues.isNotEmpty) {
      _openDialogue(_dialogueCopy(entity, entity.victoryDialogues));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────
  MapEntity? _entityAt(int x, int y) {
    for (final e in _entities) {
      if (e.x == x && e.y == y) return e;
    }
    return null;
  }

  MapEntity? _adjacentNpc() {
    for (final e in _entities) {
      if (e.type != EntityType.npc) continue;
      if ((_px - e.x).abs() + (_py - e.y).abs() <= 1) return e;
    }
    return null;
  }

  MapEntity? _adjacentEnemy() {
    for (final e in _entities) {
      if (e.type != EntityType.enemy && e.type != EntityType.boss) continue;
      if ((_px - e.x).abs() + (_py - e.y).abs() <= 1) return e;
    }
    return null;
  }

  bool get _nearInteractable =>
      _adjacentNpc() != null || _adjacentEnemy() != null;

  MapEntity _dialogueCopy(MapEntity entity, List<String> dialogues) {
    return MapEntity(
      id: '${entity.id}_dialogue',
      x: entity.x,
      y: entity.y,
      type: entity.type,
      name: entity.name,
      color: entity.color,
      dialogues: dialogues,
      enemyIndex: entity.enemyIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final region = gameRegions[widget.regionIndex];
    final nearNpc = _adjacentNpc();
    final nearEnemy = _adjacentEnemy();

    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────
            _ExploreTopBar(
              region: region,
              nearInteractable: _nearInteractable,
              nearNpcName: nearNpc?.name ?? nearEnemy?.name,
              onBack: () => Navigator.pop(context),
            ),

            // ── Map viewport ────────────────────────────────────
            Expanded(
              flex: 60,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kNavy,
                  border: Border.all(color: kGold, width: 2.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Mapa
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MapPainter(
                          px: _px,
                          py: _py,
                          entities: _entities,
                        ),
                      ),
                    ),

                    if (_showRegionIntro)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.18),
                          ),
                        ),
                      ),

                    // Caixa de diálogo NPC (parte inferior do viewport)
                    if (_activeDialogue != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _DialogueBox(
                          entity: _activeDialogue!,
                          line: _dialogueLine,
                          isLast:
                              _dialogueLine ==
                              _activeDialogue!.dialogues.length - 1,
                        ),
                      ),

                    if (_showRegionIntro)
                      Positioned.fill(
                        child: _RegionIntroOverlay(
                          intro: regionIntroScenes[widget.regionIndex]!,
                          lineIndex: _introLine,
                        ),
                      ),

                    // Legenda de interação (pequena, no topo)
                    if (_nearInteractable &&
                        _activeDialogue == null &&
                        !_showRegionIntro)
                      Positioned(
                        top: 6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kNavy.withValues(alpha: 0.9),
                              border: Border.all(color: kGold),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              nearNpc != null
                                  ? '[ A ] Falar com ${nearNpc.name}'
                                  : '[ A ] Batalhar com ${nearEnemy!.name}',
                              style: const TextStyle(
                                color: kGold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Brand label ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '◆  EXPLORAÇÃO  ◆',
                style: TextStyle(
                  color: kGoldDark,
                  fontSize: 10,
                  letterSpacing: 4,
                ),
              ),
            ),

            // ── Controls ─────────────────────────────────────────
            Expanded(
              flex: 37,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DPadWidget(
                      onUp: () => _move(0, -1),
                      onDown: () => _move(0, 1),
                      onLeft: () => _move(-1, 0),
                      onRight: () => _move(1, 0),
                    ),
                    // Legenda
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendDot(color: Colors.white, label: 'Você'),
                        const SizedBox(height: 6),
                        _LegendDot(
                          color: const Color(0xFF42A5F5),
                          label: 'NPC',
                        ),
                        const SizedBox(height: 6),
                        _LegendDot(
                          color: const Color(0xFFEF5350),
                          label: 'Inimigo',
                        ),
                        const SizedBox(height: 6),
                        _LegendDot(
                          color: const Color(0xFFFDD835),
                          label: 'Chefe',
                        ),
                      ],
                    ),
                    ActionButtonsWidget(
                      onA: _onA,
                      onB: _onB,
                      labelA: 'A',
                      labelB: 'B',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════
class _ExploreTopBar extends StatelessWidget {
  final GameRegion region;
  final bool nearInteractable;
  final String? nearNpcName;
  final VoidCallback onBack;

  const _ExploreTopBar({
    required this.region,
    required this.nearInteractable,
    required this.nearNpcName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kGoldDark, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: ffBox(borderColor: kGoldDark, bgColor: kDarkBlue),
              child: const Row(
                children: [
                  Icon(Icons.map_outlined, color: kGoldDark, size: 13),
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
          Text(region.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                region.name.toUpperCase(),
                style: const TextStyle(
                  color: kGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Text('Exploração', style: kDimStyle),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MAP PAINTER (CustomPainter)
// ═══════════════════════════════════════════════════════════════
class _MapPainter extends CustomPainter {
  final int px, py;
  final List<MapEntity> entities;

  const _MapPainter({
    required this.px,
    required this.py,
    required this.entities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cW = size.width / kMapW;
    final cH = size.height / kMapH;

    // ── Fundo ────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF080D1A),
    );

    // ── Grid sutil ───────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFF1A2540)
      ..strokeWidth = 0.6;

    for (int x = 0; x <= kMapW; x++) {
      canvas.drawLine(
        Offset(x * cW, 0),
        Offset(x * cW, size.height),
        gridPaint,
      );
    }
    for (int y = 0; y <= kMapH; y++) {
      canvas.drawLine(Offset(0, y * cH), Offset(size.width, y * cH), gridPaint);
    }

    // ── Entidades ─────────────────────────────────────────────
    for (final e in entities) {
      final cx = e.x * cW + cW / 2;
      final cy = e.y * cH + cH / 2;
      final r = min(cW, cH) * 0.36;

      // Sombra
      canvas.drawCircle(
        Offset(cx, cy + 1.5),
        r,
        Paint()..color = Colors.black45,
      );

      // Corpo
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = e.color);

      // Borda
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Chefe: círculo extra pulsante
      if (e.type == EntityType.boss) {
        canvas.drawCircle(
          Offset(cx, cy),
          r * 1.55,
          Paint()
            ..color = e.color.withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // ── Player (ponto branco) ─────────────────────────────────
    final pcx = px * cW + cW / 2;
    final pcy = py * cH + cH / 2;
    final pr = min(cW, cH) * 0.38;

    // Sombra
    canvas.drawCircle(
      Offset(pcx, pcy + 1.5),
      pr,
      Paint()..color = Colors.black45,
    );

    // Ponto branco
    canvas.drawCircle(Offset(pcx, pcy), pr, Paint()..color = Colors.white);

    // Halo ao redor do player
    canvas.drawCircle(
      Offset(pcx, pcy),
      pr * 1.6,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.px != px || old.py != py;
}

// ═══════════════════════════════════════════════════════════════
// NPC DIALOGUE BOX (estilo Final Fantasy)
// ═══════════════════════════════════════════════════════════════
class _DialogueBox extends StatelessWidget {
  final MapEntity entity;
  final int line;
  final bool isLast;

  const _DialogueBox({
    required this.entity,
    required this.line,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kNavy,
        border: Border(top: BorderSide(color: kGold, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speaker name box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: ffBox(
              borderColor: entity.type == EntityType.npc
                  ? entity.color
                  : kCrimsonLight,
              bgColor: kDarkBlue,
            ),
            child: Text(
              entity.name.toUpperCase(),
              style: TextStyle(
                color: entity.type == EntityType.npc
                    ? entity.color
                    : kCrimsonLight,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Dialogue text
          Text(
            entity.dialogues.isNotEmpty ? entity.dialogues[line] : '',
            style: kBodyStyle,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                isLast ? '[ B ] Fechar' : '[ A ] Continuar',
                style: TextStyle(
                  color: kGoldDark,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text('▼', style: TextStyle(color: kGold, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegionIntroOverlay extends StatelessWidget {
  final RegionIntroScene intro;
  final int lineIndex;

  const _RegionIntroOverlay({required this.intro, required this.lineIndex});

  @override
  Widget build(BuildContext context) {
    final line = intro.dialogue[lineIndex];
    final leftActive = line.side == DialogueSide.left;

    return Stack(
      children: [
        Positioned(
          top: 8,
          left: 10,
          right: 10,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(intro.title),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: kNavy.withValues(alpha: 0.78),
                border: Border.all(color: kGoldDark),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    intro.title.toUpperCase(),
                    style: const TextStyle(
                      color: kGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    intro.objective,
                    style: const TextStyle(
                      color: kParchmentDim,
                      fontSize: 9,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 4,
          bottom: 72,
          child: _PortraitActor(
            name: intro.leftName,
            portrait: intro.leftPortrait,
            active: leftActive,
            alignRight: false,
          ),
        ),
        Positioned(
          right: 4,
          bottom: 72,
          child: _PortraitActor(
            name: intro.rightName,
            portrait: intro.rightPortrait,
            active: !leftActive,
            alignRight: true,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _IntroDialogueBox(
              key: ValueKey('$lineIndex-${line.speaker}'),
              line: line,
              progress: '${lineIndex + 1}/${intro.dialogue.length}',
            ),
          ),
        ),
      ],
    );
  }
}

class _PortraitActor extends StatelessWidget {
  final String name;
  final String portrait;
  final bool active;
  final bool alignRight;

  const _PortraitActor({
    required this.name,
    required this.portrait,
    required this.active,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final content = AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: active ? 1 : 0.42,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 280),
        scale: active ? 1.06 : 0.96,
        curve: Curves.easeOutCubic,
        child: Column(
          crossAxisAlignment: alignRight
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              portrait.startsWith('assets/') ? '' : portrait,
              style: TextStyle(
                fontSize: active ? 64 : 56,
                shadows: active
                    ? [
                        Shadow(
                          color: kGold.withValues(alpha: 0.45),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
            ),
            if (portrait.startsWith('assets/'))
              Image.asset(
                portrait,
                width: active ? 92 : 80,
                height: active ? 92 : 80,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Text('?', style: TextStyle(fontSize: active ? 64 : 56)),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kNavy.withValues(alpha: active ? 0.82 : 0.55),
                border: Border.all(color: active ? kGold : kBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                name.toUpperCase(),
                style: TextStyle(
                  color: active ? kGold : kParchmentDim,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (active) return content;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8),
      child: content,
    );
  }
}

class _IntroDialogueBox extends StatelessWidget {
  final RegionIntroLine line;
  final String progress;

  const _IntroDialogueBox({
    super.key,
    required this.line,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kNavy.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: kGold, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: ffBox(borderColor: kGold, bgColor: kDarkBlue),
            child: Text(
              line.speaker.toUpperCase(),
              style: const TextStyle(
                color: kGold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(line.text, style: kBodyStyle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$progress  [ A ] Continuar  [ B ] Pular',
                style: const TextStyle(
                  color: kGoldDark,
                  fontSize: 9,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              const Text('▼', style: TextStyle(color: kGold, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LEGEND DOT
// ═══════════════════════════════════════════════════════════════
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: kParchmentDim, fontSize: 9)),
      ],
    );
  }
}
