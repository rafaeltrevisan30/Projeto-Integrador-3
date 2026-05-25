import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/game_theme.dart';
import 'mapa_game_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool carregando = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Cria documento do jogador caso não exista
  // ─────────────────────────────────────────────
  Future<void> _criarJogadorSeNaoExistir(String uid, String nome) async {
    final doc = await FirebaseFirestore.instance
        .collection('jogadores')
        .doc(uid)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance.collection('jogadores').doc(uid).set({
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
  }

  void _navegarParaMapa(String nome) {
    if (!mounted) return;
    context.read<GameController>().init(nome);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MapaGameScreen(playerName: nome)),
    );
  }

  // ─────────────────────────────────────────────
  // Login anônimo
  // ─────────────────────────────────────────────
  Future<void> _entrarAnonimo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => carregando = true);

    try {
      final nome = _nameController.text.trim();
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final uid = userCredential.user!.uid;
      await _criarJogadorSeNaoExistir(uid, nome);
      _navegarParaMapa(nome);
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao entrar no jogo')));
      }
    }

    if (mounted) setState(() => carregando = false);
  }

  // ─────────────────────────────────────────────
  // Login Google
  // ─────────────────────────────────────────────
  Future<void> _entrarComGoogle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => carregando = true);

    try {
      final nome = _nameController.text.trim();

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final uid = userCredential.user!.uid;
      await _criarJogadorSeNaoExistir(uid, nome);
      _navegarParaMapa(nome);
    } catch (e) {
      debugPrint('Erro Google Login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao entrar com Google')),
        );
      }
    }

    if (mounted) setState(() => carregando = false);
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
                        child: Text(
                          '◆',
                          style: TextStyle(color: kGoldDark, fontSize: 14),
                        ),
                      ),
                      const Expanded(child: Divider(color: kGoldDark)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Preview das regiões ────────────────────────
                  FfCornerBox(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        const Text('REGIÕES DO CAMPUS', style: kDimStyle),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _RegionBadge('🍽️', 'Praça'),
                            _RegionBadge('🏛️', 'H15'),
                            _RegionBadge('🌳', 'Manacas'),
                            _RegionBadge('📚', 'Biblioteca'),
                            _RegionBadge('⛪', 'Capela'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Explore a PUC com GPS ativo',
                          style: TextStyle(color: kParchmentDim, fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Campo de nome ──────────────────────────────
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: kParchment),
                    cursorColor: kGold,
                    decoration: InputDecoration(
                      labelText: 'Nome do Herói',
                      labelStyle: const TextStyle(color: kParchmentDim),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: kGoldDark,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: kGoldDark,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: kGold, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: kCrimsonLight),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: kCrimsonLight,
                          width: 2,
                        ),
                      ),
                      errorStyle: const TextStyle(color: kCrimsonLight),
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
                    onFieldSubmitted: (_) => _entrarAnonimo(),
                  ),

                  const SizedBox(height: 20),

                  // ── Botão anônimo ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: carregando ? null : _entrarAnonimo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: ffBox(
                          borderColor: kGold,
                          bgColor: kGold.withValues(alpha: 0.1),
                          width: 2,
                        ),
                        child: carregando
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: kGold,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Row(
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

                  const SizedBox(height: 12),

                  // ── Botão Google ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: carregando ? null : _entrarComGoogle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: ffBox(
                          borderColor: kGoldDark,
                          bgColor: kDarkBlue,
                          width: 1,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: kParchment, size: 18),
                            SizedBox(width: 10),
                            Text(
                              'ENTRAR COM GOOGLE',
                              style: TextStyle(
                                color: kParchment,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
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
        Text(label, style: const TextStyle(color: kParchmentDim, fontSize: 8)),
      ],
    );
  }
}
