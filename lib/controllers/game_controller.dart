import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
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
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _playerSubscription;

  Player player = Player(name: '');
  GameState _state = GameState.cutscene;
  int _cutsceneLine = 0;
  Enemy? _currentEnemy;
  int _currentEnemyIndex = 0;
  bool? _lastAnswerCorrect;
  bool _leveledUp = false;
  bool _answerLocked = false;
  bool _singleEncounterMode = false;
  bool _loadingPlayer = false;

  GameState get state => _state;
  int get cutsceneLine => _cutsceneLine;
  Enemy? get currentEnemy => _currentEnemy;
  bool? get lastAnswerCorrect => _lastAnswerCorrect;
  bool get leveledUp => _leveledUp;
  bool get answerLocked => _answerLocked;
  bool get singleEncounterMode => _singleEncounterMode;
  bool get loadingPlayer => _loadingPlayer;

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

  static const Map<int, String> _regionToAmbiente = {
    0: 'refeitorio',
    1: 'h15',
    2: 'manacas',
    3: 'biblioteca',
    4: 'capela',
  };

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static int? regionIndexForAmbiente(String ambId) => _ambienteToRegion[ambId];

  int _clampedRegionIndex(int index) =>
      index.clamp(0, gameRegions.length - 1).toInt();

  int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  void observarJogador() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _playerSubscription != null) return;

    _loadingPlayer = true;
    notifyListeners();

    _playerSubscription = _db
        .collection('jogadores')
        .doc(uid)
        .snapshots()
        .listen(
          (doc) {
            _loadingPlayer = false;
            if (!doc.exists) return;

            final data = doc.data();
            if (data == null) return;

            final loadedPlayer = Player.fromFirestore(
              Map<String, dynamic>.from(data),
            );

            if (!data.containsKey('currentRegion')) {
              loadedPlayer.currentRegion = player.currentRegion;
            }
            if (!data.containsKey('hp')) {
              loadedPlayer.hp = player.hp.clamp(1, loadedPlayer.maxHp);
            }

            player = loadedPlayer;

            notifyListeners();
          },
          onError: (_) {
            _loadingPlayer = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    super.dispose();
  }

  Future<void> salvarJogador({bool incrementProgress = false}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ambienteId =
        _regionToAmbiente[_clampedRegionIndex(player.currentRegion)];

    await _db.runTransaction((transaction) async {
      final docRef = _db.collection('jogadores').doc(uid);
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? <String, dynamic>{};
      final progresso = Map<String, dynamic>.from(
        (data['progresso'] as Map<String, dynamic>?) ?? const {},
      );

      if (incrementProgress && ambienteId != null) {
        progresso[ambienteId] = _asInt(progresso[ambienteId], 0) + 1;
        player.progresso[ambienteId] = _asInt(progresso[ambienteId], 0);
      }

      transaction.set(docRef, {
        ...player.toFirestore(),
        'progresso': progresso,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> marcarEncontroDerrotado(String encounterId) async {
    if (!player.encontrosDerrotados.add(encounterId)) return;
    notifyListeners();
    await salvarJogador();
  }

  void init([String? playerName, bool resetGame = true]) {
    if (playerName != null && playerName.trim().isNotEmpty) {
      player.name = playerName.trim();
    }

    observarJogador();

    if (resetGame) {
      _state = GameState.cutscene;
      _cutsceneLine = 0;
      _currentEnemyIndex = 0;
      _lastAnswerCorrect = null;
      _leveledUp = false;
      _answerLocked = false;
      _singleEncounterMode = false;
    }

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

  void answerQuestion(int selectedIndex) async {
    if (_currentEnemy == null || _state != GameState.combat || _answerLocked) {
      return;
    }

    final question = _currentEnemy!.currentQuestion;
    final isCorrect = selectedIndex == question.correctIndex;
    _lastAnswerCorrect = isCorrect;
    _answerLocked = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1200), () async {
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
        await salvarJogador(incrementProgress: true);
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
