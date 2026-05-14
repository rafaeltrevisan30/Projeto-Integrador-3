import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import 'mapa_game_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

void entrar() async {
  if (_formKey.currentState!.validate()) {

    final nome = _nomeController.text;

    final userCredential =
        await FirebaseAuth.instance.signInAnonymously();

    final uid = userCredential.user!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('jogadores')
        .doc(uid)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance
          .collection('jogadores')
          .doc(uid)
          .set({
            'nome': nome,
            'xp': 0,
            'level': 1,

            'progresso': {
              'h15': 0,
              'biblioteca': 0,
              'refeitorio': 0,
              'manacas': 0,
              'capela': 0,
            },

            'createdAt': FieldValue.serverTimestamp(),
          });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapaGameScreen(),
      ),
    );
  }
}

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo / título ──────────────────────────────
                  const Text('⚔️', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  const Text(
                    'INVASÃO DA PUC',
                    style: TextStyle(
                      color: kGold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'RPG  •  QUIZ  •  AVENTURA',
                    style: TextStyle(
                      color: kParchmentDim,
                      fontSize: 11,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Separador decorativo ───────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider(color: kGoldDark)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('◆',
                            style: TextStyle(
                                color: kGoldDark, fontSize: 14)),
                      ),
                      const Expanded(child: Divider(color: kGoldDark)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Preview das regiões ────────────────────────
                  FfCornerBox(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      children: [
                        const Text('REGIÕES DO CAMPUS',
                            style: kDimStyle),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _RegionBadge('🍽️', 'Refeitório'),
                            _RegionBadge('🏛️', 'H15'),
                            _RegionBadge('🌳', 'Manacas'),
                            _RegionBadge('📚', 'Biblioteca'),
                            _RegionBadge('⛪', 'Capela'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Explore a PUC com GPS ativo',
                          style: TextStyle(
                              color: kParchmentDim, fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Campo de nome ──────────────────────────────
                  TextFormField(
                    controller: _nomeController,
                    style: const TextStyle(color: kParchment),
                    cursorColor: kGold,
                    decoration: InputDecoration(
                      labelText: 'Nome do Herói',
                      labelStyle: const TextStyle(color: kParchmentDim),
                      prefixIcon: const Icon(Icons.person_outline,
                          color: kGoldDark),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            const BorderSide(color: kGoldDark, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            const BorderSide(color: kGold, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            const BorderSide(color: kCrimsonLight),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: kCrimsonLight, width: 2),
                      ),
                      errorStyle:
                          const TextStyle(color: kCrimsonLight),
                      filled: true,
                      fillColor: kDarkBlue,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Digite seu nome';
                      }
                      if (v.trim().length < 3) {
                        return 'Nome muito curto (mín. 3 letras)';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => entrar,
                  ),

                  const SizedBox(height: 20),

                  // ── Botão iniciar ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: entrar,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        decoration: ffBox(
                          borderColor: kGold,
                          bgColor: kGold.withValues(alpha: 0.1),
                          width: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('⚔️', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 10),
                            Text(
                              'INICIAR AVENTURA',
                              style: TextStyle(
                                color: kGold,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'PROJETO INTEGRADOR 3  •  PUC CAMPINAS',
                    style: TextStyle(
                      color: kBorder,
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionBadge extends StatelessWidget {
  final String emoji;
  final String label;
  const _RegionBadge(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: kParchmentDim, fontSize: 8)),
      ],
    );
  }
}
