class Player {
  String name;
  int hp;
  int maxHp;
  int xp;
  int level;
  int currentRegion;
  // aqui temos as infos do jogador, como nome, hp, xp, level e região atual
  Player({
    required this.name,
    this.hp = 100,
    this.maxHp = 100,
    this.xp = 0,
    this.level = 1,
    this.currentRegion = 0,
  });

  int get xpToNextLevel => level * 100;
  double get xpProgress => xp.toDouble() / xpToNextLevel.toDouble();

  bool gainXp(int amount) {
    xp += amount;
    bool leveledUp = false;
    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
      maxHp += 20;
      hp = maxHp;
      leveledUp = true;
    }
    return leveledUp;
  }

  void takeDamage(int damage) {
    hp = (hp - damage).clamp(0, maxHp);
  }

  void heal(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  bool get isAlive => hp > 0;
}
