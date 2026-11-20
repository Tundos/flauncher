/*
 * Placeholder home-screen background until brand_bg.mp4 is wired via video_player.
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

  @override
  Widget build(BuildContext context) {
  // TODO(postlounge): replace gradient layer with looping muted VideoPlayer when brand_bg.mp4 ships.
    if (wallpaperImage != null) {
      return Image.memory(
        wallpaperImage!,
        key: const Key('background'),
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      );
    }
    return Container(
      key: const Key('background'),
      decoration: BoxDecoration(gradient: gradient),
    );
  }
}