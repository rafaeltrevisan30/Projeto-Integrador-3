import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ambiente.dart';
import 'ambiente_detalhes.dart';

class AmbientesScreen extends StatelessWidget {

  const AmbientesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ambientes do Jogo',
        ),
      ),

      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('ambientes')
            .get(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return const Center(
              child: Text(
                'Erro ao carregar ambientes',
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text(
                'Nenhum ambiente encontrado',
              ),
            );
          }

          final ambientes =
              snapshot.data!.docs.map((doc) {

            final data =
                doc.data()
                    as Map<String, dynamic>;

            return Ambiente.fromFirestore(
              data,
              documentId: doc.id,
            );
          }).toList();

          return ListView.separated(

            padding:
                const EdgeInsets.all(16),
            itemCount: ambientes.length,
            separatorBuilder:
                (_, _) =>
                    const SizedBox(height: 12),

            itemBuilder: (context, index) {
              final amb = ambientes[index];
              return _AmbienteCard(
                ambiente: amb,
              );
            },
          );
        },
      ),
    );
  }
}

class _AmbienteCard extends StatelessWidget {

  final Ambiente ambiente;

  const _AmbienteCard({
    required this.ambiente,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AmbienteDetalheScreen(
                ambienteId: ambiente.id,
              ),
            ),
          );
        },

        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Text(
            ambiente.nome,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
