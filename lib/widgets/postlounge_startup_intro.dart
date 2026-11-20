/*
 * Startup intro video — plays on each cold start of the launcher (new process).
 */

import 'package:flauncher/postlounge_video_assets.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostloungeStartupIntro extends StatefulWidget {
  final Widget child;

  const PostloungeStartupIntro({
    super.key,
    required this.child,
  });

  @override
  State<PostloungeStartupIntro> createState() => _PostloungeStartupIntroState();
}

class _PostloungeStartupIntroState extends State<PostloungeStartupIntro> {
  VideoPlayerController? _controller;
  bool _introDone = false;
  bool _ready = false;
  bool _finishing = false;
  bool _endDetectionArmed = false;

  @override
  void initState() {
    super.initState();
    _prepareIntro();
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
      if (!mounted) return;
      setState(() => _ready = true);
      await controller.play();
      await _armEndDetection(controller);
    } catch (_) {
      if (mounted) setState(() => _introDone = true);
    }
  }

  Future<void> _armEndDetection(VideoPlayerController controller) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted || _finishing) return;
    for (var i = 0; i < 30 && controller.value.duration == Duration.zero; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    _endDetectionArmed = true;
    controller.addListener(_onPlaybackUpdate);
  }

  void _onPlaybackUpdate() {
    if (!_endDetectionArmed || _finishing) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.position < const Duration(milliseconds: 800)) return;
    if (controller.value.isCompleted) {
      _finishIntro();
    }
  }

  Future<void> _finishIntro() async {
    if (_finishing) return;
    _finishing = true;
    _controller?.removeListener(_onPlaybackUpdate);
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

  Future<void> _skipIntro() => _finishIntro();

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