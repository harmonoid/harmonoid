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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant DesktopNowPlayingVideoVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      if (widget.active) {
        _player.play();
      } else {
        _player.pause();
      }
    }
    if (oldWidget.path != widget.path) {
      _player.open(Media(widget.path), play: widget.active);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.active) {
      _player.play();
    } else {
      _player.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  void _initPlayer() {
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
    // Background visuals must be silent to avoid clashing with music playback
    _player.setVolume(0.0);
    _player.setAudioTrack(AudioTrack.no());
    _player.setPlaylistMode(PlaylistMode.loop);
    _player.open(Media(widget.path), play: widget.active);
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: _controller,
      fit: BoxFit.cover,
      controls: NoVideoControls,
    );
  }
}
