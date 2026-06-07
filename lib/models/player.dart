class Player {
  String name;
  int hp;
  int maxHp;
  int xp;
  int level;
  int currentRegion;
  String assetPath;
  Map<String, int> progresso;
  Set<String> encontrosDerrotados;

  Player({
    required this.name,
    this.hp = 100,
    this.maxHp = 100,
    this.xp = 0,
    this.level = 1,
    this.currentRegion = 0,
    this.assetPath = 'assets/images/16x32 Idle-Sheet.png',
    Map<String, int>? progresso,
    Set<String>? encontrosDerrotados,
  }) : progresso =
           progresso ??
           {
             'h15': 0,
             'biblioteca': 0,
             'refeitorio': 0,
             'manacas': 0,
             'capela': 0,
           },
       encontrosDerrotados = encontrosDerrotados ?? <String>{};

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static Map<String, int> _progressoFrom(dynamic value) {
    final defaults = {
      'h15': 0,
      'biblioteca': 0,
      'refeitorio': 0,
      'manacas': 0,
      'capela': 0,
    };

    if (value is! Map) return defaults;

    return {
      ...defaults,
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: _asInt(entry.value, 0),
    };
  }

  factory Player.fromFirestore(Map<String, dynamic> data) {
    final level = _asInt(data['level'] ?? data['nivel'], 1);
    final maxHp = 100 + ((level - 1).clamp(0, 9999) * 20);

    return Player(
      name: (data['nome'] as String?) ?? '',
      xp: _asInt(data['xp'], 0),
      level: level,
      hp: _asInt(data['hp'], maxHp).clamp(1, maxHp),
      maxHp: _asInt(data['maxHp'], maxHp),
      currentRegion: _asInt(data['currentRegion'], 0),
      assetPath:
          (data['assetPath'] as String?) ??
          (data['spritePath'] as String?) ??
          'assets/images/16x32 Idle-Sheet.png',
      progresso: _progressoFrom(data['progresso']),
      encontrosDerrotados: {
        for (final id
            in (data['encontrosDerrotados'] as List<dynamic>? ?? const []))
          if (id is String) id,
      },
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': name,
      'xp': xp,
      'hp': hp,
      'maxHp': maxHp,
      'level': level,
      'assetPath': assetPath,
      'progresso': progresso,
      'encontrosDerrotados': encontrosDerrotados.toList(),
    };
  }

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
