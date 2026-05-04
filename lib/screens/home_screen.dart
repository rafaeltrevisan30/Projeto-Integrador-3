import 'package:flutter/material.dart';
import 'package:projeto_integrador_3/screens/mapa_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void teste() {
    Text('hey');
  }

/*  void entrar() async {
    if (_formKey.currentState!.validate()) {
      final nome = nomeController.text;

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
          'nivel': 1,
          'xp': 0,
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MapaPage(),
        ),
      );
    }
  }
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invasão da PUC!'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bem-vindo ao jogo!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Seu nome:',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite seu nome';
                  }
                  if (value.length < 3) {
                    return 'Nome muito curto';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Entrar no jogo'),
                  onPressed: teste//entrar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}