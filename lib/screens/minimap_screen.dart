import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/campaign_controller.dart';
import '../controllers/game_controller.dart';
import '../data/ambientes_mock.dart';
import '../models/ambiente.dart';
import '../services/pontos_controller.dart';
import '../theme/game_theme.dart';

class MinimapScreen extends StatelessWidget {
  const MinimapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pontos = context.watch<PontosController>();
    final campaign = context.watch<CampaignController>();
    final ambientes = _orderedAmbientes(
      pontos.ambientes.isEmpty ? ambientesMock : pontos.ambientes,
    );
    final currentAmbId = pontos.pontoAtual;
    final targetAmbId = _targetAmbienteId(campaign);
    final playerOffset = _playerOffset(ambientes, pontos.lati, pontos.long);

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
                        child: CustomPaint(
                          painter: _CampusMapPainter(
                            ambientes: ambientes,
                            currentAmbId: currentAmbId,
                            targetAmbId: targetAmbId,
                            campaign: campaign,
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

  const _RegionPin({
    required this.ambiente,
    required this.position,
    required this.size,
    required this.active,
    required this.target,
    required this.unlocked,
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

  const _StatusPanel({
    required this.currentAmbiente,
    required this.targetAmbiente,
    required this.campaign,
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

class _CampusMapPainter extends CustomPainter {
  final List<Ambiente> ambientes;
  final String? currentAmbId;
  final String? targetAmbId;
  final CampaignController campaign;

  const _CampusMapPainter({
    required this.ambientes,
    required this.currentAmbId,
    required this.targetAmbId,
    required this.campaign,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = kDarkBlue;
    final border = Paint()
      ..color = kGoldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      bg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        const Radius.circular(8),
      ),
      border,
    );

    _drawTerrain(canvas, size);
    _drawPaths(canvas, size);
    _drawRegions(canvas, size);
  }

  void _drawTerrain(Canvas canvas, Size size) {
    final grass = Paint()..color = const Color(0xFF1D3A2A);
    final plaza = Paint()..color = const Color(0xFF25314D);
    final water = Paint()..color = const Color(0xFF12395A);

    final ground = Path()
      ..moveTo(0, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.02,
        size.width * 0.48,
        size.height * 0.12,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.22,
        size.width,
        size.height * 0.08,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, grass);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.23, size.height * 0.86),
        width: size.width * 0.62,
        height: size.height * 0.22,
      ),
      water,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.53, size.height * 0.54),
        width: size.width * 0.34,
        height: size.height * 0.22,
      ),
      plaza,
    );
  }

  void _drawPaths(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = const Color(0xFFC4A56B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pathShade = Paint()
      ..color = const Color(0xFF5E4B2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final byId = {for (final amb in ambientes) amb.id: amb};
    final routeAmbientes = [
      byId['h15'],
      byId['refeitorio'],
      byId['manacas'],
      byId['biblioteca'],
      byId['capela'],
    ].whereType<Ambiente>().toList();
    final points = routeAmbientes
        .map((amb) => _ambienteOffset(ambientes, amb))
        .map(
          (offset) => Offset(offset.dx * size.width, offset.dy * size.height),
        )
        .toList();

    if (points.length < 2) return;

    final route = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      route.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.52,
        point.dx,
        point.dy,
      );
    }

    canvas.drawPath(route, pathShade);
    canvas.drawPath(route, pathPaint);
  }

  void _drawRegions(Canvas canvas, Size size) {
    for (final amb in ambientes) {
      final centerN = _ambienteOffset(ambientes, amb);
      final center = Offset(centerN.dx * size.width, centerN.dy * size.height);
      final active = amb.id == currentAmbId;
      final target = amb.id == targetAmbId;
      final unlocked = _isUnlocked(campaign, amb.id);
      final radius = target
          ? 38.0
          : active
          ? 34.0
          : 29.0;
      final fill = Paint()
        ..color =
            (active
                    ? kGold
                    : target
                    ? kCrimson
                    : unlocked
                    ? const Color(0xFF35564A)
                    : const Color(0xFF202535))
                .withValues(alpha: active || target ? 0.32 : 0.72);
      final outline = Paint()
        ..color = active
            ? kGold
            : target
            ? kCrimsonLight
            : unlocked
            ? kParchmentDim
            : kBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = active || target ? 3 : 1.3;

      canvas.drawCircle(center, radius, fill);
      canvas.drawCircle(center, radius, outline);
      if (target) {
        canvas.drawCircle(
          center,
          radius + 9,
          Paint()
            ..color = kCrimsonLight.withValues(alpha: 0.26)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CampusMapPainter oldDelegate) {
    return oldDelegate.currentAmbId != currentAmbId ||
        oldDelegate.targetAmbId != targetAmbId ||
        oldDelegate.campaign.stage != campaign.stage ||
        oldDelegate.campaign.defeatedBossRegions !=
            campaign.defeatedBossRegions ||
        oldDelegate.ambientes != ambientes;
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
    return _ambienteOffset(
      ambientes,
      ambientes.firstWhere(
        (amb) => amb.id == 'h15',
        orElse: () => ambientes.first,
      ),
    );
  }

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

Offset _ambienteOffset(List<Ambiente> ambientes, Ambiente ambiente) {
  const curated = {
    'biblioteca': Offset(0.20, 0.28),
    'manacas': Offset(0.60, 0.23),
    'h15': Offset(0.72, 0.50),
    'refeitorio': Offset(0.42, 0.58),
    'capela': Offset(0.25, 0.72),
  };
  return curated[ambiente.id] ??
      _playerOffset(ambientes, ambiente.latitude, ambiente.longitude);
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
