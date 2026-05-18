import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AmbienteDetalheScreen extends StatelessWidget {

  final String ambienteId;

  const AmbienteDetalheScreen({
    super.key,
    required this.ambienteId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Ambiente'),
      ),

      body: FutureBuilder<DocumentSnapshot>(

        future: FirebaseFirestore.instance
            .collection('ambientes')
            .doc(ambienteId)
            .get(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Erro
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar ambiente',
              ),
            );
          }

          // Documento inexistente
          if (!snapshot.hasData ||
              !snapshot.data!.exists) {

            return const Center(
              child: Text(
                'Ambiente não encontrado',
              ),
            );
          }
          // Dados
          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  data['nome'] ?? 'Sem nome',

                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  data['descricao'] ??
                      'Sem descrição',

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Latitude: ${data['latitude']}',
                ),

                Text(
                  'Longitude: ${data['longitude']}',
                ),

                Text(
                  'Raio: ${data['raioMetros']}m',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}