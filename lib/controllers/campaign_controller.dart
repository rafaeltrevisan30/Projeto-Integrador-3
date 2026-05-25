import 'package:flutter/material.dart';

enum CampaignStage {
  intro,
  h15TutorialBattle,
  goToFoodCourt,
  foodCourtExploration,
  openRegions,
  chapelUnlocked,
  complete,
}

class CampaignController extends ChangeNotifier {
  CampaignStage _stage = CampaignStage.intro;
  bool _freeStoryMode = false;
  final Set<int> _defeatedBossRegions = {};

  CampaignStage get stage => _stage;
  bool get freeStoryMode => _freeStoryMode;
  Set<int> get defeatedBossRegions => Set.unmodifiable(_defeatedBossRegions);

  bool get tutorialComplete =>
      _stage.index > CampaignStage.h15TutorialBattle.index;
  bool get chapelUnlocked => _defeatedBossRegions.containsAll({0, 1, 2, 3});

  void setFreeStoryMode(bool value) {
    if (_freeStoryMode == value) return;
    _freeStoryMode = value;
    notifyListeners();
  }

  void toggleFreeStoryMode() {
    setFreeStoryMode(!_freeStoryMode);
  }

  void advanceTo(CampaignStage stage) {
    if (_stage == stage) return;
    _stage = stage;
    notifyListeners();
  }

  void completeTutorial() {
    if (_stage.index < CampaignStage.goToFoodCourt.index) {
      _stage = CampaignStage.goToFoodCourt;
      notifyListeners();
    }
  }

  void markBossDefeated(int regionIndex) {
    if (!_defeatedBossRegions.add(regionIndex)) return;

    if (regionIndex == 4) {
      _stage = CampaignStage.complete;
    } else if (chapelUnlocked) {
      _stage = CampaignStage.chapelUnlocked;
    } else if (_stage.index < CampaignStage.openRegions.index) {
      _stage = CampaignStage.openRegions;
    }

    notifyListeners();
  }

  bool isRegionUnlocked(int regionIndex) {
    if (_freeStoryMode) return true;
    if (regionIndex == 0) return tutorialComplete;
    if (regionIndex == 4) return chapelUnlocked;
    return _stage.index >= CampaignStage.openRegions.index;
  }
}
