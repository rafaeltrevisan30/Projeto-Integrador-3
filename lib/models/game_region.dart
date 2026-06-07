import 'package:flutter/material.dart';
import 'enemy.dart';
import 'quiz_question.dart';

// aqui temos as descrições de cada região e os quizzes que elas vão possuir,
// além dos inimigos de cada uma delas.
class GameRegion {
  final String name;
  final String description;
  final String emoji;
  final Color primaryColor;
  final Color backgroundColor;
  final List<String> cutsceneLines;
  final List<Enemy> enemies;

  const GameRegion({
    required this.name,
    required this.description,
    required this.emoji,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cutsceneLines,
    required this.enemies,
  });
}

List<GameRegion> get gameRegions => [
  GameRegion(
    name: 'Praça de Alimentação',
    description:
        'O primeiro território dominado. Lacaios vagam entre as mesas!',
    emoji: '🍽️',
    primaryColor: const Color(0xFF4CAF50),
    backgroundColor: const Color(0xFF071A07),
    cutsceneLines: const [
      'Bem-vindo à Invasão da PUC!',
      'Você é o último estudante capaz de salvar o campus...',
      'Bugs e erros lógicos tomaram o Refeitório!',
      'Use seu conhecimento para derrotá-los!',
    ],
    enemies: [
      Enemy(
        name: 'Bug de Sintaxe',
        maxHp: 50,
        xpReward: 25,
        assetPath: 'assets/images/refeitorio/refeitorio-bug-sintaxe.png',
        color: const Color(0xFF66BB6A),
        questions: const [
          QuizQuestion(
            question: 'O que é uma variável em programação?',
            options: [
              'Um erro no código',
              'Espaço para armazenar dados',
              'Um tipo de loop',
              'Uma função',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Qual símbolo representa "diferente de" em Dart?',
            options: ['<>', '!=', '=/=', '!=='],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que faz um loop "for"?',
            options: [
              'Para o programa',
              'Repete um bloco de código',
              'Declara uma variável',
              'Chama uma função',
            ],
            correctIndex: 1,
          ),
        ],
      ),
      Enemy(
        name: 'NullPointer',
        maxHp: 70,
        xpReward: 45,
        assetPath: 'assets/images/refeitorio/refeitorio-nullpointer.png',
        color: const Color(0xFFB0BEC5),
        questions: const [
          QuizQuestion(
            question: 'O que causa um NullPointerException?',
            options: [
              'Variável não declarada',
              'Acessar objeto nulo',
              'Loop infinito',
              'Erro de sintaxe',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Qual keyword define uma constante em Dart?',
            options: ['var', 'let', 'const', 'static'],
            correctIndex: 2,
          ),
          QuizQuestion(
            question: 'O que é uma função em programação?',
            options: [
              'Tipo de variável',
              'Bloco de código reutilizável',
              'Estrutura de dados',
              'Operador lógico',
            ],
            correctIndex: 1,
          ),
        ],
      ),
      Enemy(
        name: 'Ms. Hamburgão do Mal',
        maxHp: 140,
        xpReward: 120,
        assetPath: 'assets/images/refeitorio/refeitorio-hamburgao.png',
        color: const Color(0xFFFFB300),
        questions: const [
          QuizQuestion(
            question:
                'Qual estrutura repete um bloco enquanto uma condição for verdadeira?',
            options: ['Classe', 'Loop while', 'Variável', 'Comentário'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Qual palavra-chave cria uma função sem retorno em Dart?',
            options: ['void', 'null', 'final', 'break'],
            correctIndex: 0,
          ),
          QuizQuestion(
            question: 'Qual operador representa o E lógico em Dart?',
            options: ['||', '&&', '==', '++'],
            correctIndex: 1,
          ),
        ],
      ),
    ],
  ),

  GameRegion(
    name: 'Bloco H15',
    description: 'Os corredores do saber. Algoritmos complexos te aguardam!',
    emoji: '🏛️',
    primaryColor: const Color(0xFF2196F3),
    backgroundColor: const Color(0xFF070A1A),
    cutsceneLines: const [
      'Você chegou ao Bloco H15!',
      'As salas de aula escondem criaturas de algoritmos!',
      'Apenas quem domina estruturas de dados sobrevive.',
      'Prepare-se para o desafio intelectual!',
    ],
    enemies: [
      Enemy(
        name: 'Loop Infinito',
        maxHp: 80,
        xpReward: 55,
        assetPath: 'assets/images/h15/h15-Loop.png',
        color: const Color(0xFF42A5F5),
        questions: const [
          QuizQuestion(
            question: 'Qual a complexidade do Bubble Sort no pior caso?',
            options: ['O(n)', 'O(n log n)', 'O(n²)', 'O(1)'],
            correctIndex: 2,
          ),
          QuizQuestion(
            question: 'FIFO é o princípio de qual estrutura de dados?',
            options: [
              'Pilha (Stack)',
              'Fila (Queue)',
              'Árvore Binária',
              'Grafo',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que é uma lista encadeada?',
            options: [
              'Array com índice',
              'Nós conectados por ponteiros',
              'Fila circular',
              'Hash table',
            ],
            correctIndex: 1,
          ),
        ],
      ),
      Enemy(
        name: 'Recursão Selvagem',
        maxHp: 100,
        xpReward: 70,
        assetPath: 'assets/images/h15/h15-Recursao.png',
        color: const Color(0xFF7E57C2),
        questions: const [
          QuizQuestion(
            question: 'O que é recursão em programação?',
            options: [
              'Um tipo de loop externo',
              'Função que chama a si mesma',
              'Herança em OOP',
              'Padrão de projeto',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que é necessário para evitar recursão infinita?',
            options: [
              'Mais memória RAM',
              'Um caso base (base case)',
              'Usar variáveis globais',
              'Remover o retorno',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question:
                'Qual estrutura de dados é usada implicitamente na recursão?',
            options: ['Fila', 'Heap', 'Pilha (Stack)', 'Grafo'],
            correctIndex: 2,
          ),
        ],
      ),
    ],
  ),

  GameRegion(
    name: 'Área das Manacas',
    description: 'A floresta de dados. Bancos relacionais dominam aqui!',
    emoji: '🌳',
    primaryColor: const Color(0xFF8BC34A),
    backgroundColor: const Color(0xFF071507),
    cutsceneLines: const [
      'A Área das Manacas... serena, mas perigosa.',
      'Entidades de banco de dados habitam estas árvores.',
      'Seus conhecimentos em SQL serão testados!',
      'Não deixe suas queries falharem aqui!',
    ],
    enemies: [
      Enemy(
        name: 'SQL Injection',
        maxHp: 100,
        xpReward: 70,
        assetPath: 'assets/images/manacas/manacas-SQL_Injection.png',
        color: const Color(0xFFEF5350),
        questions: const [
          QuizQuestion(
            question: 'O que é SQL Injection?',
            options: [
              'Erro de compilação SQL',
              'Ataque via inputs maliciosos em queries',
              'Tipo de JOIN avançado',
              'Índice de tabela corrompido',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question:
                'Qual comando SQL remove todos os dados sem apagar a tabela?',
            options: ['DELETE', 'DROP TABLE', 'TRUNCATE', 'REMOVE ALL'],
            correctIndex: 2,
          ),
          QuizQuestion(
            question: 'O que faz o comando JOIN em SQL?',
            options: [
              'Divide tabelas em partes',
              'Combina linhas de tabelas relacionadas',
              'Cria novos índices',
              'Ordena resultados automaticamente',
            ],
            correctIndex: 1,
          ),
        ],
      ),
      Enemy(
        name: 'DeadLock',
        maxHp: 130,
        xpReward: 90,
        assetPath: 'assets/images/manacas/manacas-deadlock.png',
        color: const Color(0xFFFF7043),
        questions: const [
          QuizQuestion(
            question: 'O que é um DeadLock em banco de dados?',
            options: [
              'Erro de sintaxe SQL',
              'Processos bloqueados esperando recursos mútuos',
              'Timeout de conexão TCP',
              'Índice duplicado',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que significa ACID em banco de dados?',
            options: [
              'Array, Class, Interface, Data',
              'Atomicity, Consistency, Isolation, Durability',
              'Access, Create, Index, Delete',
              'Async, Cache, Integrity, Data',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que é uma chave primária (PRIMARY KEY)?',
            options: [
              'Senha do banco de dados',
              'Identificador único de cada registro',
              'Índice de performance',
              'Relacionamento entre tabelas',
            ],
            correctIndex: 1,
          ),
        ],
      ),
    ],
  ),

  GameRegion(
    name: 'Biblioteca',
    description: 'O templo do saber. Protocolos de rede te cercam!',
    emoji: '📚',
    primaryColor: const Color(0xFFFF9800),
    backgroundColor: const Color(0xFF1A0F00),
    cutsceneLines: const [
      'A Biblioteca guarda segredos antigos...',
      'Protocolos e redes vagam pelas prateleiras digitais.',
      'Conhecimento em segurança é sua única arma aqui!',
      'Mostre que você domina as redes!',
    ],
    enemies: [
      Enemy(
        name: 'Vírus de Rede',
        maxHp: 120,
        xpReward: 85,
        assetPath: 'assets/images/biblioteca/biblioteca-Virus.png',
        color: const Color(0xFFEF9A9A),
        questions: const [
          QuizQuestion(
            question: 'O que é o protocolo HTTP?',
            options: [
              'Sistema de arquivos distribuído',
              'Protocolo de transferência de hipertexto',
              'Linguagem de marcação web',
              'Banco de dados em rede',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Qual a principal diferença entre TCP e UDP?',
            options: [
              'TCP é mais rápido que UDP',
              'TCP garante entrega dos dados, UDP não',
              'UDP é mais seguro que TCP',
              'Não há diferença prática',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que é uma API REST?',
            options: [
              'Banco de dados relacional',
              'Interface de programação via HTTP/HTTPS',
              'Framework de frontend',
              'Sistema operacional distribuído',
            ],
            correctIndex: 1,
          ),
        ],
      ),
      Enemy(
        name: 'Firewall Corrompido',
        maxHp: 160,
        xpReward: 110,
        assetPath: 'assets/images/biblioteca/biblioteca-firewall.png',
        color: const Color(0xFFFFA726),
        questions: const [
          QuizQuestion(
            question: 'O que é criptografia simétrica?',
            options: [
              'Mesma chave para cifrar e decifrar',
              'Chaves diferentes para cifrar e decifrar',
              'Sem uso de chaves',
              'Hash unidirecional',
            ],
            correctIndex: 0,
          ),
          QuizQuestion(
            question: 'O que significa HTTPS na URL?',
            options: [
              'HTTP mais rápido',
              'HTTP com camada de segurança SSL/TLS',
              'HTTP sem cookies',
              'HTTP com cache obrigatório',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que é um ataque DDoS?',
            options: [
              'Roubo de senha por força bruta',
              'Sobrecarga de sistema com requisições massivas',
              'Injeção de código malicioso',
              'Intercepção de tráfego de rede',
            ],
            correctIndex: 1,
          ),
        ],
      ),
    ],
  ),

  GameRegion(
    name: 'Capela',
    description: 'O sanctum da IA. O guardião final te aguarda!',
    emoji: '⛪',
    primaryColor: const Color(0xFF9C27B0),
    backgroundColor: const Color(0xFF0F000F),
    cutsceneLines: const [
      'A Capela... o local mais sagrado do campus.',
      'Aqui reside o guardião final: a Inteligência Artificial!',
      'Apenas os mais sábios chegaram até aqui.',
      'Este é o momento da verdade. Lute com tudo!',
    ],
    enemies: [
      Enemy(
        name: 'Neural Network',
        maxHp: 150,
        xpReward: 110,
        assetPath: 'assets/images/capela/capela-Neural_Network.png',
        color: const Color(0xFFCE93D8),
        questions: const [
          QuizQuestion(
            question: 'O que é Machine Learning?',
            options: [
              'Programação manual de todas as regras',
              'Sistema que aprende padrões a partir de dados',
              'Banco de dados inteligente',
              'Framework de desenvolvimento web',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que é overfitting em ML?',
            options: [
              'Modelo muito simples para os dados',
              'Erro de hardware na GPU',
              'Falta de dados de treinamento',
              'Modelo excessivamente ajustado ao treino perdendo generalização',
            ],
            correctIndex: 3,
          ),
          QuizQuestion(
            question: 'O que faz uma função de ativação em redes neurais?',
            options: [
              'Inicia o processo de treinamento',
              'Introduz não-linearidade ao modelo',
              'Reduz o número de parâmetros',
              'Normaliza os dados de entrada',
            ],
            correctIndex: 1,
          ),
        ],
      ),
      Enemy(
        name: 'GUARDIÃO FINAL',
        maxHp: 250,
        xpReward: 250,
        assetPath: 'assets/images/capela/capela-maligno-luta.png',
        color: const Color(0xFFAB47BC),
        questions: const [
          QuizQuestion(
            question: 'O que é um Transformer em IA?',
            options: [
              'Tipo de robô autônomo',
              'Arquitetura com mecanismo de atenção (attention)',
              'Framework de treinamento de modelos',
              'Dataset de grande escala',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que significa GPT (como no ChatGPT)?',
            options: [
              'General Program Tool',
              'Generative Pre-trained Transformer',
              'Global Processing Technology',
              'Guided Pattern Training',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'O que é Reinforcement Learning?',
            options: [
              'Aprendizado com dados rotulados',
              'Aprender por meio de recompensas e punições',
              'Transfer learning de outro modelo',
              'Aprendizado não supervisionado por clusters',
            ],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'Qual o principal objetivo do Projeto Integrador?',
            options: [
              'Reproduzir um sistema existente',
              'Integrar conhecimentos em uma solução real e criativa',
              'Decorar conceitos teóricos',
              'Fazer o menor esforço possível',
            ],
            correctIndex: 1,
          ),
        ],
      ),
    ],
  ),
];
