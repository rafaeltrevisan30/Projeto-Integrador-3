enum CampaignSceneType { cinematicText, dialogue, exploration }

enum DialogueSide { left, right }

class CampaignDialogueLine {
  final String speaker;
  final String portrait;
  final String text;
  final DialogueSide side;

  const CampaignDialogueLine({
    required this.speaker,
    required this.portrait,
    required this.text,
    this.side = DialogueSide.left,
  });
}

class CampaignScene {
  final CampaignSceneType type;
  final String title;
  final List<String> textPages;
  final List<CampaignDialogueLine> dialogue;
  final String? leftName;
  final String? leftPortrait;
  final String? rightName;
  final String? rightPortrait;
  final int? regionIndex;

  const CampaignScene.cinematic({required this.title, required this.textPages})
    : type = CampaignSceneType.cinematicText,
      dialogue = const [],
      leftName = null,
      leftPortrait = null,
      rightName = null,
      rightPortrait = null,
      regionIndex = null;

  const CampaignScene.dialogue({
    required this.title,
    required this.dialogue,
    this.leftName,
    this.leftPortrait,
    this.rightName,
    this.rightPortrait,
  }) : type = CampaignSceneType.dialogue,
       textPages = const [],
       regionIndex = null;

  const CampaignScene.exploration({
    required this.title,
    required this.regionIndex,
  }) : type = CampaignSceneType.exploration,
       textPages = const [],
       dialogue = const [],
       leftName = null,
       leftPortrait = null,
       rightName = null,
       rightPortrait = null;
}

class RegionIntroLine {
  final String speaker;
  final String text;
  final DialogueSide side;
  final String? portrait;

  const RegionIntroLine({
    required this.speaker,
    required this.text,
    required this.side,
    this.portrait,
  });
}

class RegionIntroScene {
  final String title;
  final String objective;
  final String leftName;
  final String leftPortrait;
  final String rightName;
  final String rightPortrait;
  final List<RegionIntroLine> dialogue;

  const RegionIntroScene({
    required this.title,
    required this.objective,
    required this.leftName,
    required this.leftPortrait,
    required this.rightName,
    required this.rightPortrait,
    required this.dialogue,
  });
}
