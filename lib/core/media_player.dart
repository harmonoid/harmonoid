import 'dart:io';
import 'package:audio_service/audio_service.dart' hide PlaybackState;
import 'package:flutter/foundation.dart';
import 'package:harmonoid/mappers/playback_state.dart';
import 'package:media_kit/media_kit.dart' hide Playable;

import 'package:harmonoid/mappers/loop.dart';
import 'package:harmonoid/mappers/media.dart';
import 'package:harmonoid/mappers/playable.dart';
import 'package:harmonoid/mappers/playlist_mode.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/models/playback_state.dart';

/// {@template media_player}
///
/// MediaPlayer
/// -----------
/// Implementation to handle the playback of playable resources & control the system interfaces e.g.
/// * Android   : Notification.MediaStyle
/// * GNU/Linux : D-Bus MPRIS Controls
/// * macOS     : MPNowPlayingInfoCenter
/// * Windows   : System Media Transport Controls, Windows Taskbar
///
/// {@endtemplate}
class MediaPlayer extends ChangeNotifier {
  /// Singleton instance.
  static final MediaPlayer instance = MediaPlayer._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro media_player}
  MediaPlayer._() {
    mapPlayerToState();
  }

  /// Initializes the [instance].
  Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
  }

  MediaPlayerState _state = MediaPlayerState.defaults();
  MediaPlayerState get state => _state;
  set state(MediaPlayerState state) {
    if (_state != state) {
      _state = state;
      notifyListeners();

      notifyStateToAudioService();
      notifyStateToMPRIS();
      notifyStateToSystemMediaTransportControls();
      notifyStateToWindowsTaskbar();
      notifyStateToDiscordRPC();
    }
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> playOrPause() => _player.playOrPause();

  Future<void> next() => _player.next();

  Future<void> previous() => _player.previous();

  Future<void> jump(int index) => _player.jump(index);

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setLoop(Loop loop) => _player.setPlaylistMode(loop.toPlaylistMode());

  Future<void> setRate(double rate) => _player.setRate(rate);

  Future<void> setPitch(double pitch) => _player.setPitch(pitch);

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> muteOrUnmute() => _player.setAudioTrack(_player.state.track.audio == AudioTrack.no() ? AudioTrack.auto() : AudioTrack.no());

  Future<void> shuffleOrUnshuffle() => _player.setShuffle(!state.shuffle).then((_) {
        // NOTE: Handled separately.
        state = state.copyWith(shuffle: state.shuffle);
        notifyListeners();
      });

  Future<void> open(
    List<Playable> playables, {
    int index = 0,
    bool play = true,
  }) async {
    await _player.open(Playlist(playables.map((playable) => playable.toMedia()).toList(), index: index), play: play);
    state = state.copyWith(index: index, playables: playables);
  }

  Future<void> add(List<Playable> playables) async {
    for (final playable in playables) {
      await _player.add(playable.toMedia());
    }
    state = state.copyWith(playables: [...state.playables, ...playables]);
  }

  Future<void> setPlaybackState(
    PlaybackState playbackState, {
    bool play = true,
  }) async {
    state = playbackState.toMediaPlayerState();
    await setRate(state.rate);
    await setPitch(state.pitch);
    await setVolume(state.volume);
    await setLoop(state.loop);
    if (play) {
      await open(
        state.playables,
        index: state.index,
        play: false,
      );
    }
  }

  Future<void> mapPlayerToState() async {
    _player.stream.playlist.map((event) => state = state.copyWith(index: event.index, playables: event.medias.map((event) => event.toPlayable()).toList()));
    _player.stream.rate.map((event) => state = state.copyWith(rate: event));
    _player.stream.pitch.map((event) => state = state.copyWith(pitch: event));
    _player.stream.volume.map((event) => state = state.copyWith(volume: event));
    // NOTE: Handled separately.
    // _player.stream.shuffle.map((event) => state = state.copyWith(shuffle: event));
    _player.stream.playlistMode.map((event) => state = state.copyWith(loop: event.toLoop()));
    // NOTE: Debounce for 200ms.
    _player.stream.position.distinct((previous, next) => (next - previous).abs() > const Duration(milliseconds: 200)).map((event) => state = state.copyWith(position: event));
    _player.stream.duration.map((event) => state = state.copyWith(duration: event));
    _player.stream.playing.map((event) => state = state.copyWith(playing: event));
    _player.stream.buffering.map((event) => state = state.copyWith(buffering: event));
    _player.stream.completed.map((event) => state = state.copyWith(completed: event));
    _player.stream.audioBitrate.map((event) => state = state.copyWith(audioBitrate: event));
    _player.stream.audioParams.map((event) => state = state.copyWith(audioParams: event));
  }

  Future<void> notifyStateToAudioService() async {
    if (!(Platform.isAndroid || Platform.isMacOS)) return;
    if (_audioServiceInstance == null) {
      _audioServiceInstance = await AudioService.init(
        builder: () => _AudioService(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.alexmercerind.harmonoid',
          androidNotificationChannelName: 'Harmonoid',
          androidNotificationIcon: 'drawable/ic_stat_music_note',
          androidNotificationClickStartsActivity: true,
          androidNotificationOngoing: true,
        ),
      );
    }
  }

  Future<void> notifyStateToMPRIS() async {
    if (!Platform.isLinux) return;
    // TODO:
  }

  Future<void> notifyStateToSystemMediaTransportControls() async {
    if (!Platform.isWindows) return;
    // TODO:
  }

  Future<void> notifyStateToWindowsTaskbar() async {
    if (!Platform.isWindows) return;
    // TODO:
  }

  Future<void> notifyStateToDiscordRPC() async {
    if (!(Platform.isLinux || Platform.isMacOS || Platform.isWindows)) return;
    // TODO:
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    _audioServiceInstance?.stop();
    // TODO:
  }

  late final Player _player = Player(configuration: PlayerConfiguration(title: 'Harmonoid', pitch: true));

  _AudioService? _audioServiceInstance;
  _AudioService? get _audioService => _audioServiceInstance;
}

class _AudioService extends BaseAudioHandler {}
