import 'package:flutter/material.dart';

enum EntityType { npc, enemy, boss, portal }

// aqui temos a parte do mini mapa para explorar cada região
// usando a definição como plano cartesiano, apenas como placeholder inicial.
// depois vamos mudar os dots por assets
// cada entidade tem um tipo (npc, inimigo, chefe, portal), um nome, uma cor e falas associadas
class MapEntity {
  final int x;
  final int y;
  final EntityType type;
  final String name;
  final Color color;
  final List<String> dialogues;

  const MapEntity({
    required this.x,
    required this.y,
    required this.type,
    required this.name,
    required this.color,
    required this.dialogues,
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
          x: 7,
          y: 3,
          type: EntityType.enemy,
          name: 'Bug de Sintaxe',
          color: const Color(0xFF66BB6A),
          dialogues: [],
        ),
        MapEntity(
          x: 13,
          y: 7,
          type: EntityType.enemy,
          name: 'NullPointer',
          color: const Color(0xFFEF5350),
          dialogues: [],
        ),
        MapEntity(
          x: 18,
          y: 5,
          type: EntityType.boss,
          name: 'Grande Bug',
          color: const Color(0xFFFDD835),
          dialogues: [],
        ),
      ];

    case 1: // Bloco H15
      return [
        MapEntity(
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
          x: 4,
          y: 11,
          type: EntityType.enemy,
          name: 'Loop Infinito',
          color: const Color(0xFFEF5350),
          dialogues: [],
        ),
        MapEntity(
          x: 17,
          y: 5,
          type: EntityType.enemy,
          name: 'Stack Overflow',
          color: const Color(0xFFFF7043),
          dialogues: [],
        ),
        MapEntity(
          x: 11,
          y: 2,
          type: EntityType.boss,
          name: 'Recursão Selvagem',
          color: const Color(0xFFFDD835),
          dialogues: [],
        ),
      ];

    case 2: // Manacas
      return [
        MapEntity(
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
          x: 9,
          y: 12,
          type: EntityType.enemy,
          name: 'SQL Injection',
          color: const Color(0xFFEF5350),
          dialogues: [],
        ),
        MapEntity(
          x: 3,
          y: 6,
          type: EntityType.enemy,
          name: 'DeadLock',
          color: const Color(0xFFFF7043),
          dialogues: [],
        ),
        MapEntity(
          x: 19,
          y: 3,
          type: EntityType.boss,
          name: 'Corrupção de Dados',
          color: const Color(0xFFFDD835),
          dialogues: [],
        ),
      ];

    case 3: // Biblioteca
      return [
        MapEntity(
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
          x: 18,
          y: 10,
          type: EntityType.enemy,
          name: 'Vírus de Rede',
          color: const Color(0xFFEF5350),
          dialogues: [],
        ),
        MapEntity(
          x: 7,
          y: 12,
          type: EntityType.enemy,
          name: 'Phishing',
          color: const Color(0xFFFF7043),
          dialogues: [],
        ),
        MapEntity(
          x: 10,
          y: 2,
          type: EntityType.boss,
          name: 'Firewall Corrompido',
          color: const Color(0xFFFDD835),
          dialogues: [],
        ),
      ];

    case 4: // Capela
      return [
        MapEntity(
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
          x: 16,
          y: 11,
          type: EntityType.enemy,
          name: 'Neural Network',
          color: const Color(0xFFEF5350),
          dialogues: [],
        ),
        MapEntity(
          x: 8,
          y: 2,
          type: EntityType.enemy,
          name: 'Overfitting',
          color: const Color(0xFFFF7043),
          dialogues: [],
        ),
        MapEntity(
          x: 20,
          y: 7,
          type: EntityType.boss,
          name: 'GUARDIÃO FINAL',
          color: const Color(0xFFFDD835),
          dialogues: [],
        ),
      ];

    default:
      return [];
  }
}

int playerStartX(int regionIndex) => 3;
int playerStartY(int regionIndex) => 7;
