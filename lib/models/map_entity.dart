import 'package:flutter/material.dart';

enum EntityType { npc, enemy, boss, portal }

// aqui temos a parte do mini mapa para explorar cada região
// usando a definição como plano cartesiano, apenas como placeholder inicial.
// depois vamos mudar os dots por assets
// cada entidade tem um tipo (npc, inimigo, chefe, portal), um nome, uma cor e falas associadas
class MapEntity {
  final String id;
  final int x;
  final int y;
  final EntityType type;
  final String name;
  final Color color;
  final List<String> dialogues;
  final List<String> preCombatDialogues;
  final List<String> victoryDialogues;
  final int? enemyIndex;

  const MapEntity({
    required this.id,
    required this.x,
    required this.y,
    required this.type,
    required this.name,
    required this.color,
    required this.dialogues,
    this.preCombatDialogues = const [],
    this.victoryDialogues = const [],
    this.enemyIndex,
  });
}

// ── Mapas predefinidos por região ─────────────────────────────────

const int kMapW = 22;
const int kMapH = 15;

List<MapEntity> entitiesForRegion(int regionIndex) {
  switch (regionIndex) {
    case 0: // Refeitório
      return [
        MapEntity(
          id: 'refeitorio_zelador',
          x: 10,
          y: 4,
          type: EntityType.npc,
          name: 'Zelador João',
          color: const Color(0xFF42A5F5),
          dialogues: [
            'Ei, cuidado por aqui!',
            'Os bugs invadiram o refeitório...',
            'Boa sorte, jovem!',
          ],
        ),
        MapEntity(
          id: 'refeitorio_maria',
          x: 5,
          y: 8,
          type: EntityType.npc,
          name: 'Estudante Maria',
          color: const Color(0xFFAB47BC),
          dialogues: [
            'Não consigo terminar meu código!',
            'Esses bugs são impossíveis de derrotar.',
          ],
        ),
        MapEntity(
          id: 'refeitorio_dantas',
          x: 15,
          y: 10,
          type: EntityType.npc,
          name: 'Prof. Dantas',
          color: const Color(0xFF26C6DA),
          dialogues: [
            'Lembre-se: sintaxe correta é tudo!',
            'Um ponto-e-vírgula pode mudar o mundo.',
          ],
        ),
        MapEntity(
          id: 'refeitorio_bug_sintaxe',
          x: 7,
          y: 3,
          type: EntityType.enemy,
          name: 'Bug de Sintaxe',
          color: const Color(0xFF66BB6A),
          dialogues: [],
          enemyIndex: 0,
          preCombatDialogues: [
            'O Bug de Sintaxe range entre as bandejas.',
            'Ele parece vulnerável a conceitos básicos de programação.',
          ],
          victoryDialogues: [
            'O corredor fica mais silencioso.',
            'Você sente que a lógica voltou a fluir por aqui.',
          ],
        ),
        MapEntity(
          id: 'refeitorio_nullpointer',
          x: 13,
          y: 7,
          type: EntityType.enemy,
          name: 'NullPointer',
          color: const Color(0xFFEF5350),
          dialogues: [],
          enemyIndex: 1,
        ),
        MapEntity(
          id: 'refeitorio_hamburgao',
          x: 18,
          y: 5,
          type: EntityType.boss,
          name: 'O Hamburgão',
          color: const Color(0xFFFDD835),
          dialogues: [],
          enemyIndex: 1,
          preCombatDialogues: [
            'O Grande Hamburgão surge no fundo da praça, cercado por bandejas retorcidas.',
            'Ele ri como se já tivesse vencido antes mesmo do combate começar.',
            'Vini ergue a espada. É hora de libertar a Praça de Alimentação.',
          ],
        ),
      ];

    case 1: // Bloco H15
      return [
        MapEntity(
          id: 'h15_monitor_lucas',
          x: 8,
          y: 3,
          type: EntityType.npc,
          name: 'Monitor Lucas',
          color: const Color(0xFF42A5F5),
          dialogues: [
            'Complexidade O(n²) é lenta demais!',
            'Prefira sempre O(n log n) quando possível.',
          ],
        ),
        MapEntity(
          id: 'h15_veterana_ana',
          x: 14,
          y: 9,
          type: EntityType.npc,
          name: 'Veterana Ana',
          color: const Color(0xFFAB47BC),
          dialogues: [
            'Recursão parece mágica no início...',
            'Mas não esqueça do caso base!',
          ],
        ),
        MapEntity(
          id: 'h15_loop_infinito',
          x: 4,
          y: 11,
          type: EntityType.enemy,
          name: 'Loop Infinito',
          color: const Color(0xFFEF5350),
          dialogues: [],
          enemyIndex: 0,
          preCombatDialogues: [
            'As luzes do H15 piscam em um ritmo impossível.',
            'Um Loop Infinito bloqueia o corredor.',
          ],
          victoryDialogues: [
            'O ciclo se rompe.',
            'Agora você entende melhor como interromper repetições perigosas.',
          ],
        ),
        MapEntity(
          id: 'h15_stack_overflow',
          x: 17,
          y: 5,
          type: EntityType.enemy,
          name: 'Stack Overflow',
          color: const Color(0xFFFF7043),
          dialogues: [],
          enemyIndex: 1,
          preCombatDialogues: [
            'Uma pilha de chamadas cresce até o teto.',
            'Algo precisa de um caso base imediatamente.',
          ],
          victoryDialogues: [
            'A pilha desaba em silêncio.',
            'A Veterana Ana ficaria orgulhosa desse caso base.',
          ],
        ),
        MapEntity(
          id: 'h15_recursao_selvagem',
          x: 11,
          y: 2,
          type: EntityType.boss,
          name: 'Recursão Selvagem',
          color: const Color(0xFFFDD835),
          dialogues: [],
          enemyIndex: 1,
          preCombatDialogues: [
            'A Recursão Selvagem abre um portal no centro da sala.',
            'Este é o chefe do H15.',
          ],
          victoryDialogues: [
            'O portal fecha.',
            'O H15 respira outra vez, como se alguém tivesse depurado o mundo.',
          ],
        ),
      ];

    case 2: // Manacas
      return [
        MapEntity(
          id: 'manacas_dba_marcos',
          x: 6,
          y: 5,
          type: EntityType.npc,
          name: 'DBA Marcos',
          color: const Color(0xFF42A5F5),
          dialogues: [
            'Um banco sem índice é um livro sem páginas.',
            'Use EXPLAIN antes de otimizar!',
          ],
        ),
        MapEntity(
          id: 'manacas_estudante_lua',
          x: 16,
          y: 8,
          type: EntityType.npc,
          name: 'Estudante Lua',
          color: const Color(0xFFAB47BC),
          dialogues: [
            'Meu JOIN travou o banco de dados!',
            'Cuidado com queries sem WHERE...',
          ],
        ),
        MapEntity(
          id: 'manacas_sql_injection',
          x: 9,
          y: 12,
          type: EntityType.enemy,
          name: 'SQL Injection',
          color: const Color(0xFFEF5350),
          dialogues: [],
          enemyIndex: 0,
        ),
        MapEntity(
          id: 'manacas_deadlock',
          x: 3,
          y: 6,
          type: EntityType.enemy,
          name: 'DeadLock',
          color: const Color(0xFFFF7043),
          dialogues: [],
          enemyIndex: 1,
        ),
        MapEntity(
          id: 'manacas_corrupcao',
          x: 19,
          y: 3,
          type: EntityType.boss,
          name: 'Corrupção de Dados',
          color: const Color(0xFFFDD835),
          dialogues: [],
          enemyIndex: 1,
          preCombatDialogues: [
            'As árvores tremem quando a Corrupção de Dados aparece.',
            'O ar fica pesado, como se o próprio Manacás tentasse impedir Vini de respirar.',
            'Não há mais caminho para fugir. O Lord precisa cair.',
          ],
        ),
      ];

    case 3: // Biblioteca
      return [
        MapEntity(
          id: 'biblioteca_vera',
          x: 5,
          y: 6,
          type: EntityType.npc,
          name: 'Bibliotecária Sra. Vera',
          color: const Color(0xFF42A5F5),
          dialogues: [
            'Shh! Silêncio, por favor.',
            'O conhecimento é sua melhor arma aqui.',
          ],
        ),
        MapEntity(
          id: 'biblioteca_pedro',
          x: 12,
          y: 4,
          type: EntityType.npc,
          name: 'Hacker Ético Pedro',
          color: const Color(0xFF26C6DA),
          dialogues: [
            'Segurança não é luxo, é necessidade!',
            'Sempre use HTTPS. Sempre.',
          ],
        ),
        MapEntity(
          id: 'biblioteca_virus',
          x: 18,
          y: 10,
          type: EntityType.enemy,
          name: 'Vírus de Rede',
          color: const Color(0xFFEF5350),
          dialogues: [],
          enemyIndex: 0,
        ),
        MapEntity(
          id: 'biblioteca_phishing',
          x: 7,
          y: 12,
          type: EntityType.enemy,
          name: 'Phishing',
          color: const Color(0xFFFF7043),
          dialogues: [],
          enemyIndex: 1,
        ),
        MapEntity(
          id: 'biblioteca_firewall',
          x: 10,
          y: 2,
          type: EntityType.boss,
          name: 'Firewall Corrompido',
          color: const Color(0xFFFDD835),
          dialogues: [],
          enemyIndex: 1,
          preCombatDialogues: [
            'Uma porta brilhante se abre no fundo da Biblioteca.',
            'O Firewall Corrompido bloqueia a passagem com uma aura quente e instável.',
            'Vini sente que cada resposta errada aqui pode custar muito caro.',
          ],
        ),
      ];

    case 4: // Capela
      return [
        MapEntity(
          id: 'capela_padre_algoritmo',
          x: 11,
          y: 7,
          type: EntityType.npc,
          name: 'Padre Algoritmo',
          color: const Color(0xFF42A5F5),
          dialogues: [
            'Que a inteligência artificial ilumine seu caminho.',
            'Os dados são sagrados, filho.',
          ],
        ),
        MapEntity(
          id: 'capela_dra_silva',
          x: 4,
          y: 4,
          type: EntityType.npc,
          name: 'Pesquisadora Dra. Silva',
          color: const Color(0xFFAB47BC),
          dialogues: [
            'O GPT foi treinado em bilhões de tokens!',
            'Mas ainda erra matemática básica, hehe.',
          ],
        ),
        MapEntity(
          id: 'capela_neural_network',
          x: 16,
          y: 11,
          type: EntityType.enemy,
          name: 'Neural Network',
          color: const Color(0xFFEF5350),
          dialogues: [],
          enemyIndex: 0,
        ),
        MapEntity(
          id: 'capela_overfitting',
          x: 8,
          y: 2,
          type: EntityType.enemy,
          name: 'Overfitting',
          color: const Color(0xFFFF7043),
          dialogues: [],
          enemyIndex: 1,
        ),
        MapEntity(
          id: 'capela_maligno',
          x: 20,
          y: 7,
          type: EntityType.boss,
          name: 'Maligno',
          color: const Color(0xFFFDD835),
          dialogues: [],
          enemyIndex: 1,
          preCombatDialogues: [
            'A Capela mergulha em silêncio absoluto.',
            'O Guardião Final aparece diante do altar, envolto por fumaça escura.',
            'O Papa está perto. Para salvá-lo, Vini precisa vencer agora.',
          ],
        ),
      ];

    default:
      return [];
  }
}

int playerStartX(int regionIndex) => 3;
int playerStartY(int regionIndex) => 7;
