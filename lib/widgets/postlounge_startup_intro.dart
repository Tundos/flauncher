/*
 * One-time startup intro video with audio (first launch per install).
 */

import 'package:flauncher/postlounge_video_assets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class PostloungeStartupIntro extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  final Widget child;

  const PostloungeStartupIntro({
    super.key,
    required this.sharedPreferences,
    required this.child,
  });

  @override
  State<PostloungeStartupIntro> createState() => _PostloungeStartupIntroState();
}

class _PostloungeStartupIntroState extends State<PostloungeStartupIntro> {
  VideoPlayerController? _controller;
  bool _introDone = false;
  bool _wantsIntro = false;
  bool _ready = false;
  bool _finishing = false;
  Object? _initError;

  @override
  void initState() {
    super.initState();
    _wantsIntro = postloungeShouldPlayStartupIntro(widget.sharedPreferences);
    if (_wantsIntro) {
      _prepareIntro();
    } else {
      _introDone = true;
    }
  }

  Future<void> _prepareIntro() async {
    final controller = VideoPlayerController.asset(
      kPostloungeStartupVideo,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(1);
      controller.addListener(_onPlaybackUpdate);
      if (!mounted) return;
      setState(() => _ready = true);
      await controller.play();
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e;
          _introDone = true;
        });
      }
    }
  }

  void _onPlaybackUpdate() {
    final controller = _controller;
    if (controller == null || _finishing || !_ready) return;
    if (!controller.value.isInitialized) return;

    final duration = controller.value.duration;
    final position = controller.value.position;
    if (controller.value.isCompleted) {
      _finishIntro(markPlayed: true);
      return;
    }
    if (duration > Duration.zero && position >= duration - const Duration(milliseconds: 300)) {
      _finishIntro(markPlayed: true);
    }
  }

  Future<void> _finishIntro({required bool markPlayed}) async {
    if (_finishing) return;
    _finishing = true;
    _controller?.removeListener(_onPlaybackUpdate);
    if (markPlayed) {
      await postloungeMarkStartupIntroPlayed(widget.sharedPreferences);
    }
    await _controller?.pause();
    await _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _introDone = true;
        _ready = false;
      });
    }
  }

  Future<void> _skipIntro() => _finishIntro(markPlayed: true);

  @override
  void dispose() {
    _controller?.removeListener(_onPlaybackUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_introDone) {
      return widget.child;
    }

    if (!_ready || _controller == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final controller = _controller!;
    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: TextButton(
              onPressed: _skipIntro,
              child: const Text('Overslaan · Skip'),
            ),
          ),
        ],
      ),
    );
  }
}