import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../controllers/campaign_controller.dart';
import '../controllers/game_controller.dart';
import '../data/campaign_story_data.dart';
import '../models/campaign_scene.dart';
import '../models/game_region.dart';
import '../services/pontos_controller.dart';
import '../theme/game_theme.dart';
import '../widgets/action_buttons_widget.dart';
import '../widgets/dpad_widget.dart';
import 'game_screen.dart';
import 'region_explore_screen.dart';

class StoryExploreScreen extends StatefulWidget {
  final String playerName;

  const StoryExploreScreen({super.key, required this.playerName});

  @override
  State<StoryExploreScreen> createState() => _StoryExploreScreenState();
}

class _StoryExploreScreenState extends State<StoryExploreScreen> {
  int _sceneIndex = 0;
  int _lineIndex = 0;

  CampaignScene get _scene => campaignScenes[_sceneIndex];

  bool get _introFinished => _sceneIndex >= campaignScenes.length - 1;

  void _advanceIntro() {
    final scene = _scene;
    final itemCount = switch (scene.type) {
      CampaignSceneType.cinematicText => scene.textPages.length,
      CampaignSceneType.dialogue => scene.dialogue.length,
      CampaignSceneType.exploration => 1,
    };

    if (_lineIndex < itemCount - 1) {
      setState(() => _lineIndex++);
      return;
    }

    if (_sceneIndex < campaignScenes.length - 1) {
      setState(() {
        _sceneIndex++;
        _lineIndex = 0;
      });
    }
  }

  void _skipIntro() {
    setState(() {
      _sceneIndex = campaignScenes.length - 1;
      _lineIndex = 0;
    });
  }

  Future<void> _startH15Tutorial() async {
    final game = context.read<GameController>();
    game.enterEncounter(h15RegionIndex, 0);
    game.startBattle();

    final won = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(playerName: widget.playerName),
      ),
    );

    if (!mounted || won != true) return;
    context.read<CampaignController>().completeTutorial();
  }

  void _openRegion(int regionIndex) {
    context.read<GameController>().enterRegion(regionIndex);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegionExploreScreen(
          regionIndex: regionIndex,
          playerName: widget.playerName,
        ),
      ),
    );
  }

  void _tryOpenRegion(int regionIndex) {
    final campaign = context.read<CampaignController>();
    final pontos = context.read<PontosController>();

    if (!campaign.isRegionUnlocked(regionIndex)) {
      _showMessage('Esta região ainda está bloqueada pela história.');
      return;
    }

    if (!campaign.freeStoryMode &&
        pontos.pontoAtual != _ambienteId(regionIndex)) {
      _showMessage(
        'Vá até ${gameRegions[regionIndex].name} para liberar esta parte.',
      );
      return;
    }

    _openRegion(regionIndex);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final campaign = context.watch<CampaignController>();

    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Column(
          children: [
            _CampaignTopBar(onBack: () => Navigator.pop(context)),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _viewportFor(campaign),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '◆  CAMPANHA  ◆',
                style: TextStyle(
                  color: kGoldDark,
                  fontSize: 10,
                  letterSpacing: 4,
                ),
              ),
            ),
            Expanded(
              flex: 37,
              child: _CampaignControls(
                onA: _onA(campaign),
                onB: _onB(campaign),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewportFor(CampaignController campaign) {
    if (!_introFinished && campaign.stage == CampaignStage.intro) {
      return _StorySceneViewport(
        key: ValueKey('scene_${_sceneIndex}_$_lineIndex'),
        scene: _scene,
        lineIndex: _lineIndex,
      );
    }

    if (campaign.stage == CampaignStage.intro ||
        campaign.stage == CampaignStage.h15TutorialBattle) {
      return _TutorialViewport(key: const ValueKey('tutorial'));
    }

    if (campaign.stage == CampaignStage.goToFoodCourt) {
      return _GeofenceGateViewport(
        key: const ValueKey('food_gate'),
        regionIndex: 0,
        message: 'Dirija-se até a Praça de Alimentação para continuar.',
      );
    }

    return _RegionSelectViewport(
      key: ValueKey('regions_${campaign.defeatedBossRegions.length}'),
      onSelect: _tryOpenRegion,
    );
  }

  VoidCallback? _onA(CampaignController campaign) {
    if (!_introFinished && campaign.stage == CampaignStage.intro) {
      return _advanceIntro;
    }

    if (campaign.stage == CampaignStage.intro ||
        campaign.stage == CampaignStage.h15TutorialBattle) {
      return _startH15Tutorial;
    }

    if (campaign.stage == CampaignStage.goToFoodCourt) {
      return () => _tryOpenRegion(0);
    }

    return null;
  }

  VoidCallback? _onB(CampaignController campaign) {
    if (!_introFinished && campaign.stage == CampaignStage.intro) {
      return _skipIntro;
    }
    return () => Navigator.pop(context);
  }
}

class _CampaignTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _CampaignTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final campaign = context.watch<CampaignController>();

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
          const Text('📖', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HISTÓRIA',
                  style: TextStyle(
                    color: kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  campaign.freeStoryMode ? 'Modo livre' : 'Modo geofence',
                  style: kDimStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StorySceneViewport extends StatelessWidget {
  final CampaignScene scene;
  final int lineIndex;

  const _StorySceneViewport({
    super.key,
    required this.scene,
    required this.lineIndex,
  });

  @override
  Widget build(BuildContext context) {
    return switch (scene.type) {
      CampaignSceneType.cinematicText => _CinematicViewport(
        title: scene.title,
        text: scene.textPages[lineIndex],
      ),
      CampaignSceneType.dialogue => _DialogueViewport(
        scene: scene,
        line: scene.dialogue[lineIndex],
        progress: '${lineIndex + 1}/${scene.dialogue.length}',
      ),
      CampaignSceneType.exploration => const _TutorialViewport(),
    };
  }
}

class _CinematicViewport extends StatelessWidget {
  final String title;
  final String text;

  const _CinematicViewport({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title.toUpperCase(), style: kDimStyle),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            const Text('[ A ] Continuar    [ B ] Pular', style: kDimStyle),
          ],
        ),
      ),
    );
  }
}

class _DialogueViewport extends StatelessWidget {
  final CampaignScene scene;
  final CampaignDialogueLine line;
  final String progress;

  const _DialogueViewport({
    required this.scene,
    required this.line,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final hasTwoActors =
        scene.leftName != null &&
        scene.leftPortrait != null &&
        scene.rightName != null &&
        scene.rightPortrait != null;
    final leftActive = line.side == DialogueSide.left;
    final leftPortrait = leftActive ? line.portrait : scene.leftPortrait!;
    final rightPortrait = leftActive ? scene.rightPortrait! : line.portrait;

    return Container(
      color: kNavy,
      child: Stack(
        children: [
          if (hasTwoActors) ...[
            Positioned(
              left: 8,
              bottom: 70,
              child: _CampaignPortraitActor(
                name: scene.leftName!,
                portrait: leftPortrait,
                active: leftActive,
                alignRight: false,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 70,
              child: _CampaignPortraitActor(
                name: scene.rightName!,
                portrait: rightPortrait,
                active: !leftActive,
                alignRight: true,
              ),
            ),
          ] else
            Center(
              child: Text(line.portrait, style: const TextStyle(fontSize: 76)),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: const BoxDecoration(
                color: kNavy,
                border: Border(top: BorderSide(color: kGold, width: 2)),
              ),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('$progress  ▼', style: kDimStyle),
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

class _CampaignPortraitActor extends StatelessWidget {
  final String name;
  final String portrait;
  final bool active;
  final bool alignRight;

  const _CampaignPortraitActor({
    required this.name,
    required this.portrait,
    required this.active,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: active ? 1 : 0.42,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 280),
        scale: active ? 1.08 : 0.96,
        curve: Curves.easeOutCubic,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: active ? 0 : 1.8,
            sigmaY: active ? 0 : 1.8,
          ),
          child: Column(
            crossAxisAlignment: alignRight
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              _PortraitVisual(portrait: portrait, active: active),
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
      ),
    );
  }
}

class _PortraitVisual extends StatelessWidget {
  final String portrait;
  final bool active;

  const _PortraitVisual({required this.portrait, required this.active});

  @override
  Widget build(BuildContext context) {
    if (portrait.startsWith('assets/')) {
      return Image.asset(
        portrait,
        width: active ? 92 : 80,
        height: active ? 92 : 80,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            Text('?', style: TextStyle(fontSize: active ? 64 : 56)),
      );
    }

    return Text(
      portrait,
      style: TextStyle(
        fontSize: active ? 64 : 56,
        shadows: active
            ? [Shadow(color: kGold.withValues(alpha: 0.45), blurRadius: 18)]
            : null,
      ),
    );
  }
}

class _TutorialViewport extends StatelessWidget {
  const _TutorialViewport({super.key});

  @override
  Widget build(BuildContext context) {
    final h15 = gameRegions[h15RegionIndex];

    return Container(
      color: h15.backgroundColor,
      padding: const EdgeInsets.all(18),
      child: Center(
        child: FfCornerBox(
          borderColor: h15.primaryColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(h15.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text('TUTORIAL DE COMBATE', style: kTitleStyle),
              const SizedBox(height: 8),
              Text(
                'No H15, Vini testa os poderes dados pelo Mago antes de seguir para a Praça de Alimentação.',
                textAlign: TextAlign.center,
                style: kBodyStyle.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 14),
              const Text('[ A ] Iniciar batalha', style: kDimStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeofenceGateViewport extends StatelessWidget {
  final int regionIndex;
  final String message;

  const _GeofenceGateViewport({
    super.key,
    required this.regionIndex,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final campaign = context.watch<CampaignController>();
    final pontos = context.watch<PontosController>();
    final region = gameRegions[regionIndex];
    final inside = pontos.pontoAtual == _ambienteId(regionIndex);
    final canEnter = campaign.freeStoryMode || inside;

    return Container(
      color: region.backgroundColor,
      padding: const EdgeInsets.all(18),
      child: Center(
        child: FfCornerBox(
          borderColor: canEnter ? region.primaryColor : kGoldDark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(region.emoji, style: const TextStyle(fontSize: 46)),
              const SizedBox(height: 8),
              Text(region.name.toUpperCase(), style: kTitleStyle),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: kBodyStyle),
              const SizedBox(height: 12),
              Text(
                canEnter ? '[ A ] Entrar' : 'Aguardando geofence...',
                style: TextStyle(
                  color: canEnter ? kGold : kParchmentDim,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegionSelectViewport extends StatelessWidget {
  final void Function(int) onSelect;

  const _RegionSelectViewport({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final campaign = context.watch<CampaignController>();

    return Container(
      color: kNavy,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('ESCOLHA A REGIÃO', style: kDimStyle),
          const SizedBox(height: 10),
          for (final index in [0, 3, 2, 1, 4])
            _RegionStoryTile(
              regionIndex: index,
              unlocked: campaign.isRegionUnlocked(index),
              defeated: campaign.defeatedBossRegions.contains(index),
              onTap: () => onSelect(index),
            ),
        ],
      ),
    );
  }
}

class _RegionStoryTile extends StatelessWidget {
  final int regionIndex;
  final bool unlocked;
  final bool defeated;
  final VoidCallback onTap;

  const _RegionStoryTile({
    required this.regionIndex,
    required this.unlocked,
    required this.defeated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final region = gameRegions[regionIndex];

    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: ffBox(
          borderColor: defeated
              ? kGreenHPLight
              : unlocked
              ? region.primaryColor
              : kBorder,
          bgColor: unlocked ? region.backgroundColor : kNavy,
        ),
        child: Row(
          children: [
            Text(
              unlocked ? region.emoji : '🔒',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                region.name,
                style: TextStyle(
                  color: unlocked ? kParchment : kBorder,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              defeated
                  ? 'Lord derrotado'
                  : unlocked
                  ? 'Entrar'
                  : 'Bloqueado',
              style: const TextStyle(color: kGoldDark, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignControls extends StatelessWidget {
  final VoidCallback? onA;
  final VoidCallback? onB;

  const _CampaignControls({required this.onA, required this.onB});

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
          ActionButtonsWidget(onA: onA, onB: onB),
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

String _ambienteId(int regionIndex) {
  return switch (regionIndex) {
    0 => 'refeitorio',
    1 => 'h15',
    2 => 'manacas',
    3 => 'biblioteca',
    4 => 'capela',
    _ => '',
  };
}
