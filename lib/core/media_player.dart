import 'dart:io';
import 'package:audio_service/audio_service.dart' hide PlaybackState;
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide Playable;
import 'package:tag_reader/tag_reader.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/mappers/loop.dart';
import 'package:harmonoid/mappers/media.dart';
import 'package:harmonoid/mappers/playable.dart';
import 'package:harmonoid/mappers/playback_state.dart';
import 'package:harmonoid/mappers/playlist_mode.dart';
import 'package:harmonoid/mappers/tags.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/models/playback_state.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/methods.dart';

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
  static Future<void> ensureInitialized({required PlaybackState playbackState}) async {
    if (initialized) return;
    initialized = true;
    await instance.setPlaybackState(playbackState);
  }

  String? _notifyCurrentFlagUri;
  String? _notifyHistoryPlaylistFlagUri;

  // NOTE: A separate [TagReader] overrides the existing values etc. in the [Playable]s.

  Playable? _current;
  Playable get current => _current ?? state.playables[state.index];

  double _volumeBeforeMute = 100.0;

  MediaPlayerState _state = MediaPlayerState.defaults();
  MediaPlayerState get state => _state;
  set state(MediaPlayerState state) {
    if (_state != state) {
      _state = state;

      notifyCurrent();
      notifyHistoryPlaylist();
      notifyAudioService();
      notifyMPRIS();
      notifySystemMediaTransportControls();
      notifyWindowsTaskbar();
      notifyDiscordRPC();
      notifyListeners();
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

  Future<void> setMute(bool mute) {
    if (mute) {
      _volumeBeforeMute = state.volume;
      return setVolume(0.0);
    } else {
      return setVolume(_volumeBeforeMute == 0.0 ? 100.0 : _volumeBeforeMute);
    }
  }

  Future<void> setShuffle(bool shuffle) => _player.setShuffle(shuffle).then((_) {
        // NOTE: Handled separately.
        state = state.copyWith(shuffle: state.shuffle);
        notifyListeners();
      });

  Future<void> muteOrUnmute() => setMute(state.volume != 0.0);

  Future<void> shuffleOrUnshuffle() => _player.setShuffle(!state.shuffle).then((_) {
        // NOTE: Handled separately.
        state = state.copyWith(shuffle: !state.shuffle);
        notifyListeners();
      });

  Future<void> open(
    List<Playable> playables, {
    int index = 0,
    bool play = true,
    void Function() onOpen = mediaPlayerOpenOnOpen,
  }) async {
    await _player.open(Playlist(playables.map((playable) => playable.toMedia()).toList(), index: index), play: play);
    state = state.copyWith(index: index, playables: playables);
    mediaPlayerOpenOnOpen.call();
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
    await setShuffle(state.shuffle);
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
    _player.stream.playlist.listen((event) => state = state.copyWith(index: event.index, playables: event.medias.map((event) => event.toPlayable()).toList()));
    _player.stream.rate.listen((event) => state = state.copyWith(rate: event));
    _player.stream.pitch.listen((event) => state = state.copyWith(pitch: event));
    _player.stream.volume.listen((event) => state = state.copyWith(volume: event));
    // NOTE: Handled separately.
    // _player.stream.shuffle.listen((event) => state = state.copyWith(shuffle: event));
    _player.stream.playlistMode.listen((event) => state = state.copyWith(loop: event.toLoop()));
    // NOTE: Debounce for 200ms.
    _player.stream.position.distinct((previous, next) => (next - previous).abs() < const Duration(milliseconds: 200)).listen((event) => state = state.copyWith(position: event));
    _player.stream.duration.listen((event) => state = state.copyWith(duration: event));
    _player.stream.playing.listen((event) => state = state.copyWith(playing: event));
    _player.stream.buffering.listen((event) => state = state.copyWith(buffering: event));
    _player.stream.completed.listen((event) => state = state.copyWith(completed: event));
    _player.stream.audioBitrate.listen((event) => state = state.copyWith(audioBitrate: event));
    _player.stream.audioParams.listen((event) => state = state.copyWith(audioParams: event));
    _player.stream.log.listen((event) => debugPrint(event.toString()));
    _player.stream.error.listen((event) => debugPrint(event.toString()));
  }

  Future<void> notifyCurrent() async {
    if (state.playables.isEmpty) return;
    if (_notifyCurrentFlagUri == state.playables[state.index].uri) return;
    final uri = state.playables[state.index].uri;
    _notifyCurrentFlagUri = uri;

    _current = null;
    final tags = await _tagReader.parse(
      uri,
      cover: MediaLibrary.instance.uriToCoverFile(uri),
      timeout: const Duration(minutes: 1),
    );
    _current = tags.toTrack().toPlayable();

    debugPrint('MediaPlayer: notifyCurrent: URI: $uri');
    debugPrint('MediaPlayer: notifyCurrent: Tags: $tags');
    debugPrint('MediaPlayer: notifyCurrent: Current: $current');
  }

  Future<void> notifyHistoryPlaylist() async {
    if (state.playables.isEmpty) return;
    if (_notifyHistoryPlaylistFlagUri == state.playables[state.index].uri) return;
    final uri = state.playables[state.index].uri;
    _notifyHistoryPlaylistFlagUri = uri;

    if (await MediaLibrary.instance.db.contains(current.uri)) {
      // It is available in the media library. Save as hash + title.
      await MediaLibrary.instance.playlists.addToHistory(track: await MediaLibrary.instance.db.selectTrackByUri(uri));
    } else {
      // It is not available in the media library. Save as uri + title.
      await MediaLibrary.instance.playlists.addToHistory(uri: uri, title: current.playlistEntryTitle);
    }
  }

  Future<void> notifyAudioService() async {
    if (!(Platform.isAndroid || Platform.isMacOS)) return;
    _audioServiceInstance ??= await AudioService.init(
      builder: () => _AudioService(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.alexmercerind.harmonoid',
        androidNotificationChannelName: 'Harmonoid',
        androidNotificationIcon: 'drawable/ic_stat_music_note',
        androidNotificationClickStartsActivity: true,
        androidNotificationOngoing: true,
      ),
    );
    // TODO:
  }

  Future<void> notifyMPRIS() async {
    if (!Platform.isLinux) return;
    // TODO:
  }

  Future<void> notifySystemMediaTransportControls() async {
    if (!Platform.isWindows) return;
    // TODO:
  }

  Future<void> notifyWindowsTaskbar() async {
    if (!Platform.isWindows) return;
    // TODO:
  }

  Future<void> notifyDiscordRPC() async {
    if (!(Platform.isLinux || Platform.isMacOS || Platform.isWindows)) return;
    // TODO:
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    _tagReader.dispose();
    _audioServiceInstance?.stop();
    // TODO:
  }

  final Player _player = Player(configuration: const PlayerConfiguration(title: kTitle, pitch: true, logLevel: MPVLogLevel.v));
  final TagReader _tagReader = TagReader();

  _AudioService? _audioServiceInstance;
  _AudioService? get _audioService => _audioServiceInstance;
}

class _AudioService extends BaseAudioHandler {}
