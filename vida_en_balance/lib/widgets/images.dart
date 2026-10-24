import 'package:flutter/material.dart';

import '../theme.dart';

/// Pantalla «placeholder» para ilustraciones: sustituir por Image.asset
/// cuando se tengan los PNG definitivos.
class IllustrationPlaceholder extends StatelessWidget {
  const IllustrationPlaceholder({super.key, required this.icons, this.size = 180});
  final List<IconData> icons;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Colors.white, AppColors.sageSoft]),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final i in icons)
            Icon(i, size: size * 0.38, color: AppColors.forest),
        ],
      ),
    );
  }
}

/// Imagen de `assets/` con respaldo: si el archivo no existe todavía, muestra
/// [fallback] (o nada) en lugar de romper la pantalla.
class AppImage extends StatelessWidget {
  const AppImage(this.asset,
      {super.key, this.width, this.height, this.fit = BoxFit.contain, this.fallback});
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      excludeFromSemantics: true,
      errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
    );
  }
}

/// Ícono de cápsula (inclinada, con línea al centro) como en el diseño.
class CapsuleIcon extends StatelessWidget {
  const CapsuleIcon({super.key, this.size = 22, this.color = AppColors.forest});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.785398, // -45°
      child: Container(
        width: size * 0.95,
        height: size * 0.48,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.8),
          borderRadius: BorderRadius.circular(size),
        ),
        child: Center(
          child: Container(width: 1.8, color: color),
        ),
      ),
    );
  }
}
