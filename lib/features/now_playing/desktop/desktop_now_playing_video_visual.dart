import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// {@template desktop_now_playing_video_visual}
///
/// DesktopNowPlayingVideoVisual
/// ----------------------------
/// Renders a looping video visual for the now playing screen.
///
/// {@endtemplate}
class DesktopNowPlayingVideoVisual extends StatefulWidget {
  /// File path of the video.
  final String path;

  /// Whether the visual is currently active in the carousel.
  final bool active;

  /// {@macro desktop_now_playing_video_visual}
  const DesktopNowPlayingVideoVisual({
    super.key,
    required this.path,
    required this.active,
  });

  @override
  State<DesktopNowPlayingVideoVisual> createState() => _DesktopNowPlayingVideoVisualState();
}

class _DesktopNowPlayingVideoVisualState extends State<DesktopNowPlayingVideoVisual> with WidgetsBindingObserver {
  late final Player _player;
  late final VideoController _controller;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initPlayer());
  }

  @override
  void didUpdateWidget(covariant DesktopNowPlayingVideoVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _player.open(Media(widget.path), play: widget.active);
    } else if (oldWidget.active != widget.active) {
      if (widget.active) {
        _player.play();
      } else {
        _player.pause();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.active) {
      _player.play();
    } else if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _player.pause();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 16 * 1024 * 1024,
      ),
    );
    _controller = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );
    // Background visuals must be silent to avoid clashing with music playback.
    if (_player.platform is NativePlayer) {
      await (_player.platform as NativePlayer).setProperty('aid', 'no');
    }
    if (_disposed) return;
    await _player.setVolume(0.0);
    if (_disposed) return;
    await _player.setAudioTrack(AudioTrack.no());
    if (_disposed) return;
    await _player.setPlaylistMode(PlaylistMode.loop);
    if (_disposed) return;
    await _player.open(Media(widget.path), play: widget.active);
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: _controller,
      fit: BoxFit.cover,
      controls: NoVideoControls,
      wakelock: false,
      pauseUponEnteringBackgroundMode: false,
    );
  }
}
