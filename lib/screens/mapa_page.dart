import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/pontos_controller.dart';


class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PontosController>();

    if (controller.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.erro.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(controller.erro)),
      );
    }

    final posicaoUsuario = LatLng(controller.lati, controller.long);
    mapController?.animateCamera(
      CameraUpdate.newLatLng(posicaoUsuario),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: posicaoUsuario,
          zoom: 18,
        ),
        onMapCreated: (mapCtrl) {
          mapController = mapCtrl;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,

        markers: {
          // jogador
          Marker(
            markerId: const MarkerId('jogador'),
            position: posicaoUsuario,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),

          ...controller.ambientes.map((amb) {
              return Marker(
                markerId: MarkerId(amb.id),
                position: LatLng(amb.latitude, amb.longitude),
                infoWindow: InfoWindow(
                  title: amb.nome,
                  snippet: amb.descricao,
                ),
              );
            }),
          },
          circles: controller.ambientes.map((amb) {
          final dentro = controller.pontoAtual == amb.id;

          return Circle(
            circleId: CircleId(amb.id),
            center: LatLng(amb.latitude, amb.longitude),
            radius: amb.raioMetros,
            strokeWidth: 2,
            strokeColor: dentro ? Colors.green : Colors.red,
            fillColor: dentro
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.1),
          );
        }).toSet(),
      ),
    );
  }
}