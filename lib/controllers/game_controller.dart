import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/game_region.dart';

enum GameState {
  cutscene,
  exploring,
  combat,
  victory,
  defeat,
  regionComplete,
  gameComplete,
}

class GameController extends ChangeNotifier {
  Player player = Player(name: '');
  GameState _state = GameState.cutscene;
  int _cutsceneLine = 0;
  Enemy? _currentEnemy;
  int _currentEnemyIndex = 0;
  bool? _lastAnswerCorrect;
  bool _leveledUp = false;
  bool _answerLocked = false;
  bool _singleEncounterMode = false;

  GameState get state => _state;
  int get cutsceneLine => _cutsceneLine;
  Enemy? get currentEnemy => _currentEnemy;
  bool? get lastAnswerCorrect => _lastAnswerCorrect;
  bool get leveledUp => _leveledUp;
  bool get answerLocked => _answerLocked;
  bool get singleEncounterMode => _singleEncounterMode;

  GameRegion get currentRegion =>
      gameRegions[_clampedRegionIndex(player.currentRegion)];
  int get totalRegions => gameRegions.length;

  // Mapa de amb.id → índice de região
  static const Map<String, int> _ambienteToRegion = {
    'refeitorio': 0,
    'h15': 1,
    'manacas': 2,
    'biblioteca': 3,
    'capela': 4,
  };

  static int? regionIndexForAmbiente(String ambId) => _ambienteToRegion[ambId];

  int _clampedRegionIndex(int index) =>
      index.clamp(0, gameRegions.length - 1).toInt();

  void init(String playerName) {
    player = Player(name: playerName, currentRegion: 1);
    _state = GameState.cutscene;
    _cutsceneLine = 0;
    _currentEnemyIndex = 0;
    _lastAnswerCorrect = null;
    _leveledUp = false;
    _answerLocked = false;
    _singleEncounterMode = false;
    notifyListeners();
  }

  // Chamado quando entra num geofence — preserva HP/XP/level do jogador
  void enterRegion(int regionIndex) {
    player.currentRegion = _clampedRegionIndex(regionIndex);
    _cutsceneLine = 0;
    _currentEnemyIndex = 0;
    _lastAnswerCorrect = null;
    _leveledUp = false;
    _answerLocked = false;
    _singleEncounterMode = false;
    _state = GameState.cutscene;
    notifyListeners();
  }

  void enterEncounter(int regionIndex, int enemyIndex) {
    player.currentRegion = _clampedRegionIndex(regionIndex);
    _cutsceneLine = currentRegion.cutsceneLines.length - 1;
    _currentEnemyIndex = enemyIndex
        .clamp(0, currentRegion.enemies.length - 1)
        .toInt();
    _lastAnswerCorrect = null;
    _leveledUp = false;
    _answerLocked = false;
    _singleEncounterMode = true;
    _state = GameState.exploring;
    notifyListeners();
  }

  void advanceCutscene() {
    if (_cutsceneLine < currentRegion.cutsceneLines.length - 1) {
      _cutsceneLine++;
    } else {
      _state = GameState.exploring;
    }
    notifyListeners();
  }

  void skipCutscene() {
    _cutsceneLine = currentRegion.cutsceneLines.length - 1;
    _state = GameState.exploring;
    notifyListeners();
  }

  void startBattle() {
    final enemies = currentRegion.enemies;
    if (enemies.isEmpty) return;
    _currentEnemy = enemies[_currentEnemyIndex % enemies.length].clone();
    _lastAnswerCorrect = null;
    _answerLocked = false;
    _state = GameState.combat;
    notifyListeners();
  }

  void answerQuestion(int selectedIndex) {
    if (_currentEnemy == null || _state != GameState.combat || _answerLocked) {
      return;
    }

    final question = _currentEnemy!.currentQuestion;
    final isCorrect = selectedIndex == question.correctIndex;
    _lastAnswerCorrect = isCorrect;
    _answerLocked = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (isCorrect) {
        _currentEnemy!.takeDamage(question.attackPower);
      } else {
        player.takeDamage(question.damage);
      }

      if (!player.isAlive) {
        _state = GameState.defeat;
        _answerLocked = false;
        notifyListeners();
        return;
      }

      if (_currentEnemy!.isDefeated) {
        final leveled = player.gainXp(_currentEnemy!.xpReward);
        _leveledUp = leveled;
        if (_singleEncounterMode) {
          _state = GameState.victory;
          _answerLocked = false;
          notifyListeners();
          return;
        }
        _currentEnemyIndex++;

        final allDefeated = _currentEnemyIndex >= currentRegion.enemies.length;
        if (allDefeated) {
          _currentEnemyIndex = 0;
          final isLastRegion = player.currentRegion >= gameRegions.length - 1;
          _state = isLastRegion
              ? GameState.gameComplete
              : GameState.regionComplete;
        } else {
          _state = GameState.victory;
        }
      } else {
        _currentEnemy!.nextQuestion();
        _lastAnswerCorrect = null;
      }

      _answerLocked = false;
      notifyListeners();
    });
  }

  void continueAfterVictory() {
    _leveledUp = false;
    _lastAnswerCorrect = null;
    if (_singleEncounterMode) {
      _state = GameState.exploring;
      notifyListeners();
      return;
    }
    startBattle();
  }

  void moveToNextRegion() {
    player.currentRegion = _clampedRegionIndex(player.currentRegion + 1);
    _cutsceneLine = 0;
    _currentEnemyIndex = 0;
    _leveledUp = false;
    _state = GameState.cutscene;
    notifyListeners();
  }

  void restartAfterDefeat() {
    player.hp = (player.maxHp * 0.6).round();
    _currentEnemyIndex = 0;
    _lastAnswerCorrect = null;
    _state = GameState.exploring;
    notifyListeners();
  }

  void healPlayer() {
    player.heal((player.maxHp * 0.3).round());
    notifyListeners();
  }
}
