import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/campaign_controller.dart';
import '../controllers/game_controller.dart';
import '../data/game_assets.dart';
import '../models/ambiente.dart';
import '../models/map_entity.dart';
import '../services/pontos_controller.dart';
import '../theme/game_theme.dart';

class MinimapScreen extends StatelessWidget {
  const MinimapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pontos = context.watch<PontosController>();
    final campaign = context.watch<CampaignController>();
    final game = context.watch<GameController>();

    if (pontos.ambientes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final ambientes = _orderedAmbientes(pontos.ambientes);
    final currentAmbId = pontos.pontoAtual;
    final targetAmbId = _targetAmbienteId(campaign);
    final playerOffset = currentAmbId == null
        ? _playerOffset(ambientes, pontos.lati, pontos.long)
        : _campusRegionOffsets[currentAmbId] ??
              _playerOffset(ambientes, pontos.lati, pontos.long);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CAMPUS EM TEMPO REAL', style: kTitleStyle),
                      SizedBox(height: 4),
                      Text('Mapa ilustrado da jornada', style: kDimStyle),
                    ],
                  ),
                ),
                _GpsBadge(active: pontos.lati != 0 && pontos.long != 0),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                GameAssets.campusMap,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                              ColoredBox(color: kNavy.withValues(alpha: 0.12)),
                            ],
                          ),
                        ),
                      ),
                      ...ambientes.map(
                        (amb) => _RegionPin(
                          ambiente: amb,
                          position: _ambienteOffset(ambientes, amb),
                          size: constraints.biggest,
                          active: currentAmbId == amb.id,
                          target: targetAmbId == amb.id,
                          unlocked: _isUnlocked(campaign, amb.id),
                          progress: _regionProgress(amb.id, game, campaign),
                        ),
                      ),
                      _PlayerMarker(
                        position: playerOffset,
                        size: constraints.biggest,
                        hasGps: pontos.lati != 0 && pontos.long != 0,
                      ),
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: _StatusPanel(
                          currentAmbiente: _findAmbiente(
                            ambientes,
                            currentAmbId,
                          ),
                          targetAmbiente: _findAmbiente(ambientes, targetAmbId),
                          campaign: campaign,
                          progress: _regionProgress(
                            currentAmbId ?? targetAmbId ?? '',
                            game,
                            campaign,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsBadge extends StatelessWidget {
  final bool active;

  const _GpsBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: ffBox(
        borderColor: active ? kGold : kGoldDark,
        bgColor: kDarkBlue,
      ),
      child: Text(
        active ? 'GPS ON' : 'GPS BUSCANDO',
        style: TextStyle(
          color: active ? kGold : kParchmentDim,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _RegionPin extends StatelessWidget {
  final Ambiente ambiente;
  final Offset position;
  final Size size;
  final bool active;
  final bool target;
  final bool unlocked;
  final int progress;

  const _RegionPin({
    required this.ambiente,
    required this.position,
    required this.size,
    required this.active,
    required this.target,
    required this.unlocked,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final x = position.dx * size.width;
    final y = position.dy * size.height;
    final icon = _emojiForAmbiente(ambiente.id);
    final color = active
        ? kGold
        : target
        ? kCrimsonLight
        : unlocked
        ? kParchment
        : kParchmentDim;

    return Positioned(
      left: (x - 42).clamp(6, size.width - 86).toDouble(),
      top: (y - 40).clamp(6, size.height - 120).toDouble(),
      width: 84,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        scale: active || target ? 1.08 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: kNavy.withValues(alpha: unlocked ? 0.88 : 0.62),
            border: Border.all(
              color: active
                  ? kGold
                  : target
                  ? kCrimsonLight
                  : kGoldDark,
              width: active || target ? 2 : 1.2,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              if (active || target)
                BoxShadow(
                  color: (active ? kGold : kCrimsonLight).withValues(
                    alpha: 0.24,
                  ),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 3),
              Text(
                _shortName(ambiente.nome),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: progress / 100,
                  color: progress == 100 ? kGreenHPLight : kGold,
                  backgroundColor: kBorder,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$progress%',
                style: TextStyle(
                  color: progress == 100 ? kGreenHPLight : kParchmentDim,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (target) ...[
                const SizedBox(height: 3),
                const Text(
                  'OBJETIVO',
                  style: TextStyle(
                    color: kCrimsonLight,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerMarker extends StatelessWidget {
  final Offset position;
  final Size size;
  final bool hasGps;

  const _PlayerMarker({
    required this.position,
    required this.size,
    required this.hasGps,
  });

  @override
  Widget build(BuildContext context) {
    final x = position.dx * size.width;
    final y = position.dy * size.height;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      left: (x - 18).clamp(8, size.width - 42).toDouble(),
      top: (y - 18).clamp(8, size.height - 116).toDouble(),
      width: 36,
      height: 44,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, math.sin(value * math.pi * 2) * 2),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (hasGps ? kGold : kParchmentDim).withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(color: hasGps ? kGold : kParchmentDim),
              ),
            ),
            const Text('🧙', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final Ambiente? currentAmbiente;
  final Ambiente? targetAmbiente;
  final CampaignController campaign;
  final int progress;

  const _StatusPanel({
    required this.currentAmbiente,
    required this.targetAmbiente,
    required this.campaign,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final current = currentAmbiente?.nome ?? 'fora de uma região';
    final target = targetAmbiente?.nome ?? 'aguarde o próximo capítulo';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kNavy.withValues(alpha: 0.94),
        border: Border.all(color: kGoldDark, width: 1.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me, color: kGold, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Agora: $current',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kParchment,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                progress == 100 ? Icons.check_circle : Icons.analytics_outlined,
                color: progress == 100 ? kGreenHPLight : kGold,
                size: 15,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress / 100,
                    color: progress == 100 ? kGreenHPLight : kGold,
                    backgroundColor: kBorder,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$progress%',
                style: TextStyle(
                  color: progress == 100 ? kGreenHPLight : kGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(Icons.flag, color: kCrimsonLight, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _objectiveText(campaign, target),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kParchmentDim,
                    fontSize: 11,
                    height: 1.25,
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

List<Ambiente> _orderedAmbientes(List<Ambiente> ambientes) {
  const order = ['refeitorio', 'h15', 'manacas', 'biblioteca', 'capela'];
  final byId = {for (final amb in ambientes) amb.id: amb};
  return [
    for (final id in order)
      if (byId[id] != null) byId[id]!,
    for (final amb in ambientes)
      if (!order.contains(amb.id)) amb,
  ];
}

Offset _playerOffset(List<Ambiente> ambientes, double lat, double lng) {
  if (lat == 0 || lng == 0) {
    final h15 = ambientes.firstWhere(
      (amb) => amb.id == 'h15',
      orElse: () => ambientes.first,
    );
    return _coordinateOffset(ambientes, h15.latitude, h15.longitude);
  }

  return _coordinateOffset(ambientes, lat, lng);
}

Offset _ambienteOffset(List<Ambiente> ambientes, Ambiente ambiente) {
  return _campusRegionOffsets[ambiente.id] ??
      _coordinateOffset(ambientes, ambiente.latitude, ambiente.longitude);
}

const Map<String, Offset> _campusRegionOffsets = {
  'manacas': Offset(0.42, 0.16),
  'capela': Offset(0.70, 0.17),
  'refeitorio': Offset(0.50, 0.29),
  'biblioteca': Offset(0.65, 0.47),
  'h15': Offset(0.57, 0.72),
};

Offset _coordinateOffset(List<Ambiente> ambientes, double lat, double lng) {
  final latitudes = ambientes.map((amb) => amb.latitude);
  final longitudes = ambientes.map((amb) => amb.longitude);
  final minLat = latitudes.reduce(math.min);
  final maxLat = latitudes.reduce(math.max);
  final minLng = longitudes.reduce(math.min);
  final maxLng = longitudes.reduce(math.max);
  final latSpan = (maxLat - minLat).abs();
  final lngSpan = (maxLng - minLng).abs();
  final x = lngSpan == 0 ? 0.5 : (lng - minLng) / lngSpan;
  final y = latSpan == 0 ? 0.5 : (maxLat - lat) / latSpan;

  return Offset(
    _lerp(0.16, 0.84, x.clamp(-0.1, 1.1)),
    _lerp(0.16, 0.72, y.clamp(-0.1, 1.1)),
  );
}

Ambiente? _findAmbiente(List<Ambiente> ambientes, String? id) {
  if (id == null) return null;
  for (final amb in ambientes) {
    if (amb.id == id) return amb;
  }
  return null;
}

String? _targetAmbienteId(CampaignController campaign) {
  if (campaign.stage == CampaignStage.complete) return null;
  if (campaign.stage.index <= CampaignStage.h15TutorialBattle.index) {
    return 'h15';
  }
  if (campaign.stage.index <= CampaignStage.foodCourtExploration.index) {
    return 'refeitorio';
  }
  if (campaign.chapelUnlocked) return 'capela';

  const candidates = {0: 'refeitorio', 1: 'h15', 2: 'manacas', 3: 'biblioteca'};
  for (final entry in candidates.entries) {
    if (!campaign.defeatedBossRegions.contains(entry.key)) {
      return entry.value;
    }
  }
  return 'capela';
}

bool _isUnlocked(CampaignController campaign, String ambId) {
  final regionIndex = GameController.regionIndexForAmbiente(ambId);
  if (regionIndex == null) return true;
  return campaign.isRegionUnlocked(regionIndex);
}

String _objectiveText(CampaignController campaign, String target) {
  if (campaign.stage == CampaignStage.complete) {
    return 'Campanha concluida. O campus foi salvo.';
  }
  if (campaign.freeStoryMode) {
    return 'Modo livre ativo. Objetivo sugerido: $target.';
  }
  if (campaign.stage.index <= CampaignStage.h15TutorialBattle.index) {
    return 'Conclua o tutorial no H15.';
  }
  if (campaign.stage.index <= CampaignStage.foodCourtExploration.index) {
    return 'Siga para $target e entre no raio da geofence.';
  }
  if (campaign.chapelUnlocked) {
    return 'Todos os chefes cairam. A Capela foi liberada.';
  }
  return 'Proximo objetivo: libertar $target.';
}

String _emojiForAmbiente(String id) {
  switch (id) {
    case 'refeitorio':
      return '🍽️';
    case 'h15':
      return '🏛️';
    case 'manacas':
      return '🌳';
    case 'biblioteca':
      return '📚';
    case 'capela':
      return '⛪';
    default:
      return '📍';
  }
}

String _shortName(String name) {
  return name
      .replaceAll('Praça de Alimentação', 'Praca')
      .replaceAll('Área dos ', '')
      .replaceAll('Bloco ', '');
}

double _lerp(double min, double max, num t) {
  return min + (max - min) * t.toDouble();
}

int _regionProgress(
  String ambienteId,
  GameController game,
  CampaignController campaign,
) {
  final regionIndex = GameController.regionIndexForAmbiente(ambienteId);
  if (regionIndex == null) return 0;

  final combatEntities = entitiesForRegion(regionIndex)
      .where(
        (entity) =>
            entity.type == EntityType.enemy || entity.type == EntityType.boss,
      )
      .toList();
  final combatCount = combatEntities.length;
  if (combatCount == 0) return 0;

  final registeredVictories = combatEntities
      .where((entity) => game.player.encontrosDerrotados.contains(entity.id))
      .length;
  final legacyVictories = game.player.progresso[ambienteId] ?? 0;
  final bossFallback = campaign.defeatedBossRegions.contains(regionIndex)
      ? 1
      : 0;
  final victories = registeredVictories > 0
      ? registeredVictories
      : math.max(legacyVictories, bossFallback);
  return ((victories.clamp(0, combatCount) / combatCount) * 100).round();
}
