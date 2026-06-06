import 'package:flutter/material.dart';

class SpriteImage extends StatelessWidget {
  final String assetPath;
  final String fallbackText;
  final double size;
  final BoxFit fit;

  const SpriteImage({
    super.key,
    required this.assetPath,
    required this.fallbackText,
    required this.size,
    this.fit = BoxFit.contain,
  });

  bool get _looksLikeImagePath {
    final lowerPath = assetPath.toLowerCase();
    return lowerPath.startsWith('assets/') &&
        (lowerPath.endsWith('.png') ||
            lowerPath.endsWith('.jpg') ||
            lowerPath.endsWith('.jpeg') ||
            lowerPath.endsWith('.webp'));
  }

  @override
  Widget build(BuildContext context) {
    if (!_looksLikeImagePath) {
      return _FallbackSprite(text: fallbackText, size: size);
    }

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, _, _) => _FallbackSprite(text: fallbackText, size: size),
    );
  }
}

class _FallbackSprite extends StatelessWidget {
  final String text;
  final double size;

  const _FallbackSprite({required this.text, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size * 0.6,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
