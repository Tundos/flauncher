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
  bool _showIntro = false;
  bool _introVisible = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _showIntro = postloungeShouldPlayStartupIntro(widget.sharedPreferences);
    if (_showIntro) {
      _prepareIntro();
    }
  }

  Future<void> _prepareIntro() async {
    final controller = VideoPlayerController.asset(kPostloungeStartupVideo);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(1);
      if (!mounted) return;
      setState(() => _introVisible = true);
      await controller.play();
      controller.addListener(_onTick);
    } catch (_) {
      await _completeIntro();
    }
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null || _finished) return;
    if (controller.value.isInitialized && controller.value.isCompleted) {
      _completeIntro();
    }
  }

  Future<void> _completeIntro() async {
    if (_finished) return;
    _finished = true;
    _controller?.removeListener(_onTick);
    await postloungeMarkStartupIntroPlayed(widget.sharedPreferences);
    await _controller?.pause();
    await _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _introVisible = false;
        _showIntro = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_introVisible && _controller != null)
          Material(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: TextButton(
                    onPressed: _completeIntro,
                    child: const Text('Overslaan · Skip'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}