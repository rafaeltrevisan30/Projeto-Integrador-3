import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/pontos_controller.dart';
import '../controllers/game_controller.dart';
import '../controllers/campaign_controller.dart';
import '../models/game_region.dart';
import '../theme/game_theme.dart';
import 'game_screen.dart';
import 'hero_screen.dart';
import 'missions_screen.dart';
import 'minimap_screen.dart';
import 'story_explore_screen.dart';
import 'combat_training_screen.dart';
import 'region_explore_screen.dart';

class MapaGameScreen extends StatefulWidget {
  final String playerName;
  const MapaGameScreen({super.key, required this.playerName});

  @override
  State<MapaGameScreen> createState() => _MapaGameScreenState();
}

class _MapaGameScreenState extends State<MapaGameScreen> {
  int _tabIndex = 0;
  GoogleMapController? _mapController;
  bool _battleBannerDismissed = false;
  String? _lastPontoAtual;

  @override
  Widget build(BuildContext context) {
    final pontos = context.watch<PontosController>();
    final game = context.watch<GameController>();
    final campaign = context.watch<CampaignController>();

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
                campaign: campaign,
                playerName: widget.playerName,
                onEntrarNaBatalha: () =>
                    _entrarNaBatalha(context, pontos, game),
                onExplorar: () => _explorarRegiao(context, pontos),
              ),
              const MinimapScreen(),
              const HeroScreen(),
              _StoryTab(playerName: widget.playerName),
              const MissionsScreen(),
              _SettingsTab(playerName: widget.playerName),
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
                onExplorar: () => _explorarRegiao(context, pontos),
                onDismiss: () => setState(() => _battleBannerDismissed = true),
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
    if (regionIndex == null) {
      _mostrarAmbienteInvalido(context);
      return;
    }
    game.enterRegion(regionIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => GameScreen(playerName: widget.playerName),
      ),
    );
  }

  void _explorarRegiao(BuildContext context, PontosController pontos) {
    final ambId = pontos.pontoAtual;
    if (ambId == null) return;

    final regionIndex = GameController.regionIndexForAmbiente(ambId);
    if (regionIndex == null) {
      _mostrarAmbienteInvalido(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RegionExploreScreen(
          regionIndex: regionIndex,
          playerName: widget.playerName,
        ),
      ),
    );
  }

  void _mostrarAmbienteInvalido(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Este ponto ainda não está ligado a uma região do jogo.'),
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
  final CampaignController campaign;
  final String playerName;
  final VoidCallback onEntrarNaBatalha;
  final VoidCallback onExplorar;

  const _MapTab({
    required this.mapController,
    required this.onMapCreated,
    required this.pontos,
    required this.campaign,
    required this.playerName,
    required this.onEntrarNaBatalha,
    required this.onExplorar,
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

    final double lat = pontos.lati != 0 ? pontos.lati : -22.9842;
    final double lng = pontos.long != 0 ? pontos.long : -47.0756;
    final pos = LatLng(lat, lng);

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
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: '⚔ Você está aqui'),
        ),

        ...pontos.ambientes.map(
          (amb) => Marker(
            markerId: MarkerId(amb.id),
            position: LatLng(amb.latitude, amb.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              pontos.pontoAtual == amb.id
                  ? BitmapDescriptor.hueYellow
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(title: amb.nome, snippet: amb.descricao),
            onTap: campaign.freeStoryMode
                ? () => _showRegionDialog(
                    context,
                    amb.nome,
                    onEntrarNaBatalha,
                    onExplorar,
                  )
                : null,
          ),
        ),
      },
      circles: pontos.ambientes.map((amb) {
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

  void _showRegionDialog(
    BuildContext ctx,
    String regionName,
    VoidCallback onBatalhar,
    VoidCallback onExplorar,
  ) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: kNavy,
        title: Text(
          regionName,
          style: const TextStyle(color: kGold, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Modo Livre ativado - escolha uma ação',
          style: TextStyle(color: kParchment),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              onExplorar();
            },
            child: const Text(
              '🗺️ Explorar',
              style: TextStyle(color: kParchment),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              onBatalhar();
            },
            child: const Text('⚔️ Batalhar', style: TextStyle(color: kGold)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// GEOFENCE BATTLE BANNER
// ══════════════════════════════════════════════════════════════════
class _GeofenceBanner extends StatelessWidget {
  final String ambienteName;
  final VoidCallback onBatalhar;
  final VoidCallback onExplorar;
  final VoidCallback onDismiss;

  const _GeofenceBanner({
    required this.ambienteName,
    required this.onBatalhar,
    required this.onExplorar,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kNavy.withValues(alpha: 0.97),
        border: Border.all(color: kGold, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
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
                      'Zona detectada — o que deseja fazer?',
                      style: TextStyle(color: kParchmentDim, fontSize: 10),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close, color: kParchmentDim, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Botões ───────────────────────────────────────
          Row(
            children: [
              // EXPLORAR
              Expanded(
                child: GestureDetector(
                  onTap: onExplorar,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: kDarkBlue,
                      border: Border.all(color: kGoldDark),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🗺️', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'EXPLORAR',
                          style: TextStyle(
                            color: kParchment,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // BATALHAR
              Expanded(
                child: GestureDetector(
                  onTap: onBatalhar,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: kGold.withValues(alpha: 0.15),
                      border: Border.all(color: kGold),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⚔️', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'BATALHAR',
                          style: TextStyle(
                            color: kGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 1.2),
        items: const [
          BottomNavigationBarItem(
            icon: Text('🗺️', style: TextStyle(fontSize: 22)),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Text('🧭', style: TextStyle(fontSize: 22)),
            label: 'Campus',
          ),
          BottomNavigationBarItem(
            icon: Text('⚔️', style: TextStyle(fontSize: 22)),
            label: 'Herói',
          ),
          BottomNavigationBarItem(
            icon: Text('📖', style: TextStyle(fontSize: 22)),
            label: 'História',
          ),
          BottomNavigationBarItem(
            icon: Text('📜', style: TextStyle(fontSize: 22)),
            label: 'Missões',
          ),
          BottomNavigationBarItem(
            icon: Text('⚙️', style: TextStyle(fontSize: 20)),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// STORY TAB
// ══════════════════════════════════════════════════════════════════
class _StoryTab extends StatelessWidget {
  final String playerName;

  const _StoryTab({required this.playerName});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final h15 = gameRegions[1];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          const Text('HISTÓRIA + EXPLORAÇÃO', style: kTitleStyle),
          const Divider(color: kGoldDark, height: 20),
          Text(
            'Comece pelo tutorial cinematográfico e avance pela campanha.',
            style: kBodyStyle.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoryExploreScreen(playerName: playerName),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: ffBox(
                borderColor: h15.primaryColor,
                bgColor: h15.backgroundColor,
              ),
              child: Row(
                children: [
                  Text(h15.emoji, style: const TextStyle(fontSize: 38)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONTINUAR CAMPANHA',
                          style: TextStyle(
                            color: kGold,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Prólogo, tutorial, geofence, exploração e bosses.',
                          style: kBodyStyle.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_arrow, color: kGold),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('ATALHOS DE TESTE', style: kDimStyle),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              game.enterRegion(1);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegionExploreScreen(
                    regionIndex: 1,
                    playerName: playerName,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: ffBox(borderColor: kGoldDark, bgColor: kDarkBlue),
              child: const Row(
                children: [
                  Text('🗺️', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Entrar direto na exploração do H15',
                      style: kBodyStyle,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: kGoldDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SETTINGS TAB
// ══════════════════════════════════════════════════════════════════
class _SettingsTab extends StatelessWidget {
  final String playerName;
  const _SettingsTab({required this.playerName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('CONFIGURAÇÕES', style: kTitleStyle),
            const Divider(color: kGoldDark, height: 20),

            // ── TREINO DE COMBATE (destaque principal) ────────
            const Text('PRÁTICA', style: kDimStyle),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CombatTrainingScreen(playerName: playerName),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGold.withValues(alpha: 0.08),
                  border: Border.all(color: kGold, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: ffBox(borderColor: kGoldDark, bgColor: kNavy),
                      child: const Center(
                        child: Text('⚔️', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TREINO DE COMBATE',
                            style: TextStyle(
                              color: kGold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pratique o quiz sem precisar\nir ao campus. XP real garantido!',
                            style: TextStyle(
                              color: kParchmentDim,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: kGold, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: kGoldDark),
            const SizedBox(height: 12),

            // ── AUDIO ─────────────────────────────────────────
            const Text('ÁUDIO', style: kDimStyle),
            const SizedBox(height: 10),
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

            const SizedBox(height: 16),
            const Divider(color: kGoldDark),
            const SizedBox(height: 12),

            // ── SISTEMA ───────────────────────────────────────
            const Text('SISTEMA', style: kDimStyle),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: '📍',
              label: 'Localização GPS',
              value: 'Ativo',
              onTap: () {},
            ),
            _SettingsTile(
              icon: '🛡️',
              label: 'Jogador',
              value: playerName,
              onTap: () {},
            ),

            const SizedBox(height: 16),
            const Divider(color: kGoldDark),
            const SizedBox(height: 12),

            // ── MODO TESTE ────────────────────────────────────
            const Text('MODO TESTE', style: kDimStyle),
            const SizedBox(height: 10),
            Consumer<CampaignController>(
              builder: (context, campaign, _) {
                return GestureDetector(
                  onTap: () => campaign.toggleFreeStoryMode(),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: ffBox(
                      borderColor: kGoldDark,
                      bgColor: kDarkBlue,
                    ),
                    child: Row(
                      children: [
                        Text(
                          campaign.freeStoryMode ? '✓' : '✗',
                          style: TextStyle(
                            fontSize: 18,
                            color: campaign.freeStoryMode
                                ? kGold
                                : kParchmentDim,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exploração Livre',
                                style: TextStyle(
                                  color: kParchment,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Visitar regiões sem geofence',
                                style: TextStyle(
                                  color: kParchmentDim,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 24,
                          decoration: BoxDecoration(
                            color: campaign.freeStoryMode
                                ? kGold.withValues(alpha: 0.3)
                                : kDarkBlue,
                            border: Border.all(
                              color: campaign.freeStoryMode ? kGold : kGoldDark,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              campaign.freeStoryMode ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: campaign.freeStoryMode
                                    ? kGold
                                    : kParchmentDim,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            Center(
              child: Text(
                'PROJETO INTEGRADOR 3  •  PUC CAMPINAS',
                style: TextStyle(color: kBorder, fontSize: 9, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
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
            Expanded(child: Text(label, style: kBodyStyle)),
            Text(value, style: const TextStyle(color: kGold, fontSize: 12)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: kGoldDark, size: 18),
          ],
        ),
      ),
    );
  }
}
