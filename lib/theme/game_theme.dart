import 'package:flutter/material.dart';

// ── Palette Medieval / Final Fantasy ─────────────────────────────
const Color kNavy = Color(0xFF080D1A);
const Color kDarkBlue = Color(0xFF111A30);
const Color kGold = Color(0xFFC9A84C);
const Color kGoldLight = Color(0xFFE8C870);
const Color kGoldDark = Color(0xFF7A6020);
const Color kCrimson = Color(0xFF8B1A1A);
const Color kCrimsonLight = Color(0xFFBF3030);
const Color kParchment = Color(0xFFE8D5A3);
const Color kParchmentDim = Color(0xFF9A8A60);
const Color kGreenHP = Color(0xFF2E7D32);
const Color kGreenHPLight = Color(0xFF4CAF50);
const Color kBlueXP = Color(0xFF1565C0);
const Color kBlueXPLight = Color(0xFF1E88E5);
const Color kBorder = Color(0xFF3A2E10);

// ── Text styles ───────────────────────────────────────────────────
const TextStyle kTitleStyle = TextStyle(
  color: kGold,
  fontSize: 17,
  fontWeight: FontWeight.bold,
  letterSpacing: 3,
);

const TextStyle kBodyStyle = TextStyle(
  color: kParchment,
  fontSize: 14,
  height: 1.65,
);

const TextStyle kDimStyle = TextStyle(
  color: kParchmentDim,
  fontSize: 11,
  letterSpacing: 1.5,
);

// ── Shared BoxDecoration builders ─────────────────────────────────
BoxDecoration ffBox({
  Color borderColor = kGold, 
  Color bgColor = kDarkBlue,
  double width = 2,
}) {
  return BoxDecoration(
    color: bgColor,
    border: Border.all(color: borderColor, width: width),
    borderRadius: BorderRadius.circular(4),
  );
}

// ── HP/XP bar ─────────────────────────────────────────────────────
class FfBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final Color lightColor;

  const FfBar({
    super.key,
    required this.label, 
    required this.current,
    required this.max,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text(
            label,
            style: const TextStyle(
              color: kGoldDark,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: kBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio > 0.4 ? lightColor : kCrimsonLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$current/$max',
          style: const TextStyle(color: kParchmentDim, fontSize: 9),
        ),
      ],
    );
  }
}

// ── Ornate corner decoration ──────────────────────────────────────
class FfCornerBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;

  const FfCornerBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor = kGold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ffBox(borderColor: borderColor),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          // Corner ornaments
          Positioned(top: 2, left: 2, child: _corner()),
          Positioned(top: 2, right: 2, child: _corner()),
          Positioned(bottom: 2, left: 2, child: _corner()),
          Positioned(bottom: 2, right: 2, child: _corner()),
        ],
      ),
    );
  }

  Widget _corner() => Text(
    '◆',
    style: TextStyle(color: borderColor.withValues(alpha: 0.6), fontSize: 7),
  );
}
