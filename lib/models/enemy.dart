import 'package:flutter/material.dart';
import 'quiz_question.dart';

// aqui temos as caracteristicas dos inimigos
class Enemy {
  final String name;
  int hp;
  final int maxHp;
  final int xpReward;
  final String emoji;
  final Color color;
  final List<QuizQuestion> questions;
  int _questionIndex = 0;

  Enemy({
    required this.name,
    required this.maxHp,
    required this.xpReward,
    required this.emoji,
    required this.color,
    required this.questions,
  }) : hp = maxHp;

  QuizQuestion get currentQuestion =>
      questions[_questionIndex % questions.length];

  void nextQuestion() => _questionIndex++;

  void takeDamage(int damage) {
    hp = (hp - damage).clamp(0, maxHp);
  }

  bool get isDefeated => hp <= 0;

  Enemy clone() => Enemy(
    name: name,
    maxHp: maxHp,
    xpReward: xpReward,
    emoji: emoji,
    color: color,
    questions: questions,
  );
}
