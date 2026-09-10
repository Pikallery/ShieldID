import 'package:flutter/material.dart';

/// Reusable ShieldID logo badge using the official shield+globe+circuit PNG asset.
/// [size] — outer container size (default 36)
/// [padding] — inner padding around the image (default 4)
/// [withBackground] — wrap in a rounded dark/tinted container (default true for AppBars)
class ShieldLogo extends StatelessWidget {
  final double size;
  final double padding;
  final bool withBackground;

  const ShieldLogo({
    super.key,
    this.size = 36,
    this.padding = 4,
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/images/shieldid_logo.png',
      width: size - (padding * 2),
      height: size - (padding * 2),
      fit: BoxFit.contain,
    );

    if (!withBackground) return img;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: img,
    );
  }
}
