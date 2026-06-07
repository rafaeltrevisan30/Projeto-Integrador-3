import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class DPadWidget extends StatelessWidget {
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  final double buttonSize;
  final double gap;

  const DPadWidget({
    super.key,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
    this.buttonSize = 46,
    this.gap = 4,
  });

  Widget _btn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kGoldDark, width: 1.5),
          color: kDarkBlue,
        ),
        child: Icon(icon, color: kParchmentDim, size: buttonSize * 0.44),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(Icons.keyboard_arrow_up, onUp),
        SizedBox(height: gap),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn(Icons.keyboard_arrow_left, onLeft),
            SizedBox(width: gap),
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: kNavy,
                border: Border.all(color: kBorder, width: 1),
              ),
              child: const Center(
                child: Text(
                  '◆',
                  style: TextStyle(color: kBorder, fontSize: 10),
                ),
              ),
            ),
            SizedBox(width: gap),
            _btn(Icons.keyboard_arrow_right, onRight),
          ],
        ),
        SizedBox(height: gap),
        _btn(Icons.keyboard_arrow_down, onDown),
      ],
    );
  }
}
