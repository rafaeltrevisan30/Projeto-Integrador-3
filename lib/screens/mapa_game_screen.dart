import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/pontos_controller.dart';
import '../controllers/game_controller.dart';
import '../data/ambientes_mock.dart';
import '../theme/game_theme.dart';
import 'game_screen.dart';
import 'hero_screen.dart';
import 'missions_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapaGameScreen extends StatefulWidget {
  const MapaGameScreen({super.key});

  @override
  State<MapaGameScreen> createState() => _MapaGameScreenState();
}

class _MapaGameScreenState extends State<MapaGameScreen> {
  int _tabIndex = 0;
  GoogleMapController? _mapController;
  bool _battleBannerDismissed = false;
  String? _lastPontoAtual;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final pontos = context.watch<PontosController>();
    final game = context.watch<GameController>();

    // Reseta o dismiss quando o geofence muda
    if (pontos.pontoAtual != _lastPontoAtual) {
      _lastPontoAtual = pontos.pontoAtual;
      _battleBannerDismissed = false;
    }

    final inGeofence = pontos.pontoAtual != null && !_battleBannerDismissed;
    final ambAtual = pontos.ambienteAtual;

    return Scaffold(
      backgroundColor: kNavy,
      bottomNavigationBar: _BottomNav(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
      body: Stack(
        children: [
          // ── Tab content ────────────────────────────────────────
          IndexedStack(
            index: _tabIndex,
            children: [
              _MapTab(
                mapController: _mapController,
                onMapCreated: (c) => setState(() => _mapController = c),
                pontos: pontos,
              ),
              const HeroScreen(),
              const MissionsScreen(),
              _SettingsTab(),
            ],
          ),

          // ── Geofence battle banner ─────────────────────────────
          if (inGeofence && ambAtual != null && _tabIndex == 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: _GeofenceBanner(
                ambienteName: ambAtual.nome,
                onBatalhar: () => _entrarNaBatalha(context, pontos, game),
                onDismiss: () =>
                    setState(() => _battleBannerDismissed = true),
              ),
            ),
        ],
      ),
    );
  }

  void _entrarNaBatalha(
    BuildContext context,
    PontosController pontos,
    GameController game,
  ) {
    final ambId = pontos.pontoAtual;
    if (ambId == null) return;

    final regionIndex = GameController.regionIndexForAmbiente(ambId);
    game.enterRegion(regionIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const GameScreen(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// MAP TAB
// ══════════════════════════════════════════════════════════════════
class _MapTab extends StatelessWidget {
  final GoogleMapController? mapController;
  final void Function(GoogleMapController) onMapCreated;
  final PontosController pontos;

  const _MapTab({
    required this.mapController,
    required this.onMapCreated,
    required this.pontos,
  });

  @override
  Widget build(BuildContext context) {
    if (pontos.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kGold),
            SizedBox(height: 16),
            Text('Localizando aventureiro...', style: kDimStyle),
          ],
        ),
      );
    }

    if (pontos.erro.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(pontos.erro,
                  textAlign: TextAlign.center, style: kBodyStyle),
            ],
          ),
        ),
      );
    }

    final pos = LatLng(pontos.lati, pontos.long);

    // Move a câmera quando a posição muda
    mapController?.animateCamera(CameraUpdate.newLatLng(pos));

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: pos, zoom: 18),
      onMapCreated: onMapCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('jogador'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: '⚔ Você está aqui'),
        ),
        ...ambientesMock.map((amb) => Marker(
              markerId: MarkerId(amb.id),
              position: LatLng(amb.latitude, amb.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                pontos.pontoAtual == amb.id
                    ? BitmapDescriptor.hueYellow
                    : BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: amb.nome,
                snippet: amb.descricao,
              ),
            )),
      },
      circles: ambientesMock.map((amb) {
        final dentro = pontos.pontoAtual == amb.id;
        return Circle(
          circleId: CircleId(amb.id),
          center: LatLng(amb.latitude, amb.longitude),
          radius: amb.raioMetros,
          strokeWidth: 2,
          strokeColor: dentro ? kGoldLight : kCrimsonLight,
          fillColor: dentro
              ? kGold.withValues(alpha: 0.2)
              : kCrimson.withValues(alpha: 0.1),
        );
      }).toSet(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// GEOFENCE BATTLE BANNER
// ══════════════════════════════════════════════════════════════════
class _GeofenceBanner extends StatelessWidget {
  final String ambienteName;
  final VoidCallback onBatalhar;
  final VoidCallback onDismiss;

  const _GeofenceBanner({
    required this.ambienteName,
    required this.onBatalhar,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kNavy.withValues(alpha: 0.96),
        border: Border.all(color: kGold, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ambienteName.toUpperCase(),
                  style: const TextStyle(
                    color: kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Zona de batalha detectada!',
                  style: TextStyle(color: kParchmentDim, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onBatalhar,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kGold.withValues(alpha: 0.15),
                border: Border.all(color: kGold),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'BATALHAR',
                style: TextStyle(
                  color: kGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: kParchmentDim, size: 18),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// BOTTOM NAVIGATION
// ══════════════════════════════════════════════════════════════════
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kNavy,
        border: Border(top: BorderSide(color: kGoldDark, width: 1.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kGold,
        unselectedItemColor: kParchmentDim,
        selectedLabelStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        unselectedLabelStyle:
            const TextStyle(fontSize: 10, letterSpacing: 1.2),
        items: const [
          BottomNavigationBarItem(icon: Text('🗺️', style: TextStyle(fontSize: 22)), label: 'Mapa'),
          BottomNavigationBarItem(icon: Text('⚔️', style: TextStyle(fontSize: 22)), label: 'Herói'),
          BottomNavigationBarItem(icon: Text('📜', style: TextStyle(fontSize: 22)), label: 'Missões'),
          BottomNavigationBarItem(icon: Text('⚙️', style: TextStyle(fontSize: 20)), label: 'Config'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SETTINGS TAB (placeholder)
// ══════════════════════════════════════════════════════════════════
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('jogadores')
          .doc(uid)
          .get(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>;

        final playerName = data['nome'] ?? 'Jogador';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'CONFIGURAÇÕES',
                  style: kTitleStyle,
                ),

                const SizedBox(height: 4),

                const Divider(color: kGoldDark),

                const SizedBox(height: 20),

                _SettingsTile(
                  icon: '🔊',
                  label: 'Sons do Jogo',
                  value: 'Ativado',
                  onTap: () {},
                ),

                _SettingsTile(
                  icon: '🎵',
                  label: 'Música de Fundo',
                  value: 'Ativado',
                  onTap: () {},
                ),

                _SettingsTile(
                  icon: '📍',
                  label: 'Localização',
                  value: 'GPS Ativo',
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                const Divider(color: kGoldDark),

                const SizedBox(height: 12),

                const Text(
                  'CONTA',
                  style: kDimStyle,
                ),

                const SizedBox(height: 12),

                _SettingsTile(
                  icon: '🛡️',
                  label: 'Jogador',
                  value: playerName,
                  onTap: () {},
                ),

                const Spacer(),

                Center(
                  child: Text(
                    'PROJETO INTEGRADOR 3  •  PUC CAMPINAS',
                    style: TextStyle(
                      color: kGoldDark,
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: ffBox(borderColor: kGoldDark, bgColor: kDarkBlue),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: kBodyStyle),
            ),
            Text(value,
                style:
                    const TextStyle(color: kGold, fontSize: 12)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: kGoldDark, size: 18),
          ],
        ),
      ),
    );
  }
}
