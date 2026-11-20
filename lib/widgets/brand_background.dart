/*
 * Postlounge TV home-screen background (looping brand video or user wallpaper).
 */

import 'dart:typed_data';

import 'package:flauncher/postlounge_video_assets.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BrandBackground extends StatefulWidget {
  final Uint8List? wallpaperImage;
  final Gradient gradient;

  const BrandBackground({
    super.key,
    required this.wallpaperImage,
    required this.gradient,
  });

  @override
  State<BrandBackground> createState() => _BrandBackgroundState();
}

class _BrandBackgroundState extends State<BrandBackground> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _videoReady = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.wallpaperImage == null) {
      _initVideo();
    }
  }

  @override
  void didUpdateWidget(BrandBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wallpaperImage != widget.wallpaperImage) {
      if (widget.wallpaperImage != null) {
        _disposeVideo();
      } else if (_controller == null) {
        _initVideo();
      }
    }
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(kPostloungeBrandBgVideo);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted) return;
      setState(() {
        _videoReady = true;
        _videoFailed = false;
      });
      await controller.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _videoFailed = true);
      await controller.dispose();
      _controller = null;
    }
  }

  void _disposeVideo() {
    _controller?.dispose();
    _controller = null;
    _videoReady = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !_videoReady) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      controller.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wallpaperImage != null) {
      return Image.memory(
        widget.wallpaperImage!,
        key: const Key('background'),
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      );
    }

    if (_videoReady && _controller != null) {
      return Stack(
        key: const Key('background'),
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.22),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _StaticBrandFallback(gradient: widget.gradient, showSpinner: !_videoFailed && _controller != null);
  }
}

class _StaticBrandFallback extends StatelessWidget {
  static const _fallbackAsset = 'assets/images/fallback_bg.png';

  final Gradient gradient;
  final bool showSpinner;

  const _StaticBrandFallback({required this.gradient, required this.showSpinner});

  @override
  Widget build(BuildContext context) {
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
        if (showSpinner) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}