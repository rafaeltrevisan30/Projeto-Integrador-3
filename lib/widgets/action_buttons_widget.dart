import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onA;
  final VoidCallback? onB;
  final String labelA;
  final String labelB;
  final double buttonSize;
  final double gap;

  const ActionButtonsWidget({
    super.key,
    this.onA,
    this.onB,
    this.labelA = 'A',
    this.labelB = 'B',
    this.buttonSize = 52,
    this.gap = 8,
  });

  Widget _btn(String label, VoidCallback? onTap, {bool primary = false}) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? (primary ? kGold : kGoldDark) : kBorder,
            width: active ? 2 : 1.5,
          ),
          color: active
              ? (primary ? kGold.withValues(alpha: 0.15) : kDarkBlue)
              : kNavy,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? (primary ? kGoldLight : kParchmentDim) : kBorder,
              fontSize: buttonSize * 0.35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(labelA, onA, primary: true),
        SizedBox(height: gap),
        _btn(labelB, onB),
      ],
    );
  }
}
