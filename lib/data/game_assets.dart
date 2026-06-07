class GameAssets {
  static const campusMap = 'assets/images/mapas/mapa-campus.png';
  static const viniNeutro = 'assets/images/expressoes/vini_neutro.png';
  static const viniBattlePose = 'assets/images/battle/vini-pose-combate.png';

  static const _maps = <int, String>{
    0: 'assets/images/mapas/mapa-refeitorio.jpeg',
    1: 'assets/images/mapas/mapa-h15.jpeg',
    2: 'assets/images/mapas/mapa-manacas.jpeg',
    3: 'assets/images/mapas/mapa-biblioteca.jpeg',
    4: 'assets/images/mapas/mapa-capela.jpeg',
  };

  static const _entities = <String, String>{
    'refeitorio_zelador': 'assets/images/refeitorio/refeitorio-zelador.png',
    'refeitorio_maria': 'assets/images/refeitorio/refeitorio-maria.png',
    'refeitorio_dantas': 'assets/images/refeitorio/refeitorio-dantas.png',
    'refeitorio_bug_sintaxe':
        'assets/images/refeitorio/refeitorio-bug-sintaxe.png',
    'refeitorio_nullpointer':
        'assets/images/refeitorio/refeitorio-nullpointer.png',
    'refeitorio_hamburgao': 'assets/images/refeitorio/refeitorio-hamburgao.png',
    'h15_monitor_lucas': 'assets/images/h15/h15-monitorLucas.png',
    'h15_veterana_ana': 'assets/images/h15/h15-VeteranaAna.png',
    'h15_loop_infinito': 'assets/images/h15/h15-Loop.png',
    'h15_stack_overflow': 'assets/images/h15/h15-StackOverflow.png',
    'h15_recursao_selvagem': 'assets/images/h15/h15-Recursao.png',
    'manacas_dba_marcos': 'assets/images/manacas/manacas-dba_marcos.png',
    'manacas_estudante_lua': 'assets/images/manacas/manacas-estudante_lua.png',
    'manacas_sql_injection': 'assets/images/manacas/manacas-SQL_Injection.png',
    'manacas_deadlock': 'assets/images/manacas/manacas-deadlock.png',
    'manacas_corrupcao': 'assets/images/manacas/manacas-Corrupcao_de_Dados.png',
    'biblioteca_vera': 'assets/images/biblioteca/biblioteca-vera.png',
    'biblioteca_pedro': 'assets/images/biblioteca/biblioteca-pedro.png',
    'biblioteca_virus': 'assets/images/biblioteca/biblioteca-Virus.png',
    'biblioteca_phishing': 'assets/images/biblioteca/biblioteca-phishing.png',
    'biblioteca_firewall': 'assets/images/biblioteca/biblioteca-firewall.png',
    'capela_padre_algoritmo': 'assets/images/capela/capela-Padre_Algoritmo.png',
    'capela_dra_silva': 'assets/images/capela/capela-Pesquisadora_Silva.png',
    'capela_neural_network': 'assets/images/capela/capela-Neural_Network.png',
    'capela_overfitting': 'assets/images/capela/capela-Overfitting.png',
    'capela_guardiao_final': 'assets/images/capela/capela-maligno-idle.png',
  };

  static String mapForRegion(int regionIndex) =>
      _maps[regionIndex] ?? _maps[1]!;

  static String? entityForId(String entityId) => _entities[entityId];
}
