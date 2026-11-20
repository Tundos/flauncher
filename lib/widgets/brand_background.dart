/*
 * Postlounge TV home-screen background (gradient + branded assets until video ships).
 */

import 'dart:typed_data';

import 'package:flutter/material.dart';

class BrandBackground extends StatelessWidget {
  final Uint8List? wallpaperImage;
  final Gradient gradient;

  const BrandBackground({
    Key? key,
    required this.wallpaperImage,
    required this.gradient,
  }) : super(key: key);

  static const _fallbackAsset = 'assets/images/fallback_bg.png';
  static const _logoAsset = 'assets/images/logo.png';

  // TODO(postlounge): replace asset stack with looping muted VideoPlayer when brand_bg.mp4 ships.

  @override
  Widget build(BuildContext context) {
    if (wallpaperImage != null) {
      return Image.memory(
        wallpaperImage!,
        key: const Key('background'),
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      );
    }

    final size = MediaQuery.of(context).size;

    return Stack(
      key: const Key('background'),
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
        Image.asset(
          _fallbackAsset,
          fit: BoxFit.cover,
          width: size.width,
          height: size.height,
          opacity: const AlwaysStoppedAnimation(0.55),
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.05),
                Colors.black.withOpacity(0.35),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Image.asset(
              _logoAsset,
              height: size.height * 0.22,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}