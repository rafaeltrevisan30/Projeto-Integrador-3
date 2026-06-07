import 'package:flutter/material.dart';
import '../data/campaign_story_data.dart';
import '../models/campaign_scene.dart';
import '../theme/game_theme.dart';
import '../widgets/action_buttons_widget.dart';
import '../widgets/dpad_widget.dart';
import 'story_explore_screen.dart';

class RegionConclusionScreen extends StatefulWidget {
  final int regionIndex;
  final String playerName;

  const RegionConclusionScreen({
    super.key,
    required this.regionIndex,
    required this.playerName,
  });

  @override
  State<RegionConclusionScreen> createState() => _RegionConclusionScreenState();
}

class _RegionConclusionScreenState extends State<RegionConclusionScreen> {
  int _sceneIndex = 0;
  int _lineIndex = 0;

  List<CampaignScene> get _scenes =>
      regionConclusionScenes[widget.regionIndex] ?? const [];

  CampaignScene get _scene => _scenes[_sceneIndex];

  void _advance() {
    if (_scenes.isEmpty) {
      _finish();
      return;
    }

    final itemCount = switch (_scene.type) {
      CampaignSceneType.cinematicText => _scene.textPages.length,
      CampaignSceneType.dialogue => _scene.dialogue.length,
      CampaignSceneType.exploration => 1,
    };

    if (_lineIndex < itemCount - 1) {
      setState(() => _lineIndex++);
      return;
    }

    if (_sceneIndex < _scenes.length - 1) {
      setState(() {
        _sceneIndex++;
        _lineIndex = 0;
      });
      return;
    }

    _finish();
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StoryExploreScreen(playerName: widget.playerName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
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
                child: _scenes.isEmpty
                    ? _ObjectiveViewport(regionIndex: widget.regionIndex)
                    : _ConclusionViewport(
                        scene: _scene,
                        lineIndex: _lineIndex,
                        regionIndex: widget.regionIndex,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '◆  CONCLUSÃO  ◆',
                style: TextStyle(
                  color: kGoldDark,
                  fontSize: 10,
                  letterSpacing: 4,
                ),
              ),
            ),
            Expanded(
              flex: 37,
              child: Container(
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
                    ActionButtonsWidget(onA: _advance, onB: _finish),
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

class _ConclusionViewport extends StatelessWidget {
  final CampaignScene scene;
  final int lineIndex;
  final int regionIndex;

  const _ConclusionViewport({
    required this.scene,
    required this.lineIndex,
    required this.regionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return switch (scene.type) {
      CampaignSceneType.cinematicText => _Cinematic(
        title: scene.title,
        text: scene.textPages[lineIndex],
        objective: nextObjectiveByRegion[regionIndex] ?? '',
      ),
      CampaignSceneType.dialogue => _Dialogue(
        line: scene.dialogue[lineIndex],
        progress: '${lineIndex + 1}/${scene.dialogue.length}',
        objective: nextObjectiveByRegion[regionIndex] ?? '',
      ),
      CampaignSceneType.exploration => _ObjectiveViewport(
        regionIndex: regionIndex,
      ),
    };
  }
}

class _Cinematic extends StatelessWidget {
  final String title;
  final String text;
  final String objective;

  const _Cinematic({
    required this.title,
    required this.text,
    required this.objective,
  });

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
            const SizedBox(height: 16),
            Text(objective, textAlign: TextAlign.center, style: kDimStyle),
          ],
        ),
      ),
    );
  }
}

class _Dialogue extends StatelessWidget {
  final CampaignDialogueLine line;
  final String progress;
  final String objective;

  const _Dialogue({
    required this.line,
    required this.progress,
    required this.objective,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kNavy,
      child: Stack(
        children: [
          Center(child: _DialoguePortrait(portrait: line.portrait)),
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
                  Text(objective, style: kDimStyle),
                  const SizedBox(height: 6),
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

class _DialoguePortrait extends StatelessWidget {
  final String portrait;

  const _DialoguePortrait({required this.portrait});

  @override
  Widget build(BuildContext context) {
    if (portrait.startsWith('assets/')) {
      return Image.asset(
        portrait,
        width: 128,
        height: 128,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.person, color: kGold, size: 76),
      );
    }

    return Text(portrait, style: const TextStyle(fontSize: 76));
  }
}

class _ObjectiveViewport extends StatelessWidget {
  final int regionIndex;

  const _ObjectiveViewport({required this.regionIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kNavy,
      padding: const EdgeInsets.all(18),
      child: Center(
        child: FfCornerBox(
          child: Text(
            nextObjectiveByRegion[regionIndex] ?? 'Objetivo atualizado.',
            textAlign: TextAlign.center,
            style: kBodyStyle,
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kGoldDark, width: 1)),
      ),
      child: const Row(
        children: [
          Text('🏆', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text(
            'REGIÃO CONCLUÍDA',
            style: TextStyle(
              color: kGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
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
