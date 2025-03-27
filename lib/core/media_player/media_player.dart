import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide Playable;
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tag_reader/tag_reader.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/core/media_player/mixin/audio_service_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/discord_rpc_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/history_playlist_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/mpris_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/system_media_transport_controls_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/windows_taskbar_mixin.dart';
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
import 'package:harmonoid/utils/actions.dart';
import 'package:harmonoid/utils/constants.dart';

/// {@template media_player}
///
/// MediaPlayer
/// -----------
/// Implementation to handle the media playback & other related functionalities.
///
/// {@endtemplate}
class MediaPlayer extends ChangeNotifier with AudioServiceMixin, DiscordRpcMixin, HistoryPlaylistMixin, MprisMixin, SystemMediaTransportControlsMixin, WindowsTaskbarMixin implements BaseMediaPlayer {
  /// Singleton instance.
  static final MediaPlayer instance = MediaPlayer._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro media_player}
  MediaPlayer._() {
    mapPlayerToState();
  }

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    await instance._ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    await Future.wait(
      [
        ensureInitializedPlayer(),
        ensureInitializedAudioService(),
        ensureInitializedDiscordRpc(),
        ensureInitializedHistoryPlaylist(),
        ensureInitializedMpris(),
        ensureInitializedSystemMediaTransportControls(),
        ensureInitializedWindowsTaskbar(),
      ],
    );
  }

  @override
  Playable get current => _current ?? state.playables[state.index];

  @override
  MediaPlayerState get state => _state;

  set state(MediaPlayerState state) {
    if (_state != state) {
      _state = state;
      notifyListeners();

      updateCurrent();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> playOrPause() => _player.playOrPause();

  @override
  Future<void> next() => _player.next();

  @override
  Future<void> previous() => _player.previous();

  @override
  Future<void> jump(int index) => _player.jump(index);

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setLoop(Loop loop) => _player.setPlaylistMode(loop.toPlaylistMode());

  @override
  Future<void> setRate(double rate) => _player.setRate(rate);

  @override
  Future<void> setPitch(double pitch) => _player.setPitch(pitch);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setMute(bool mute) {
    if (mute) {
      _setMuteVolume = state.volume;
      return setVolume(0.0);
    } else {
      return setVolume(_setMuteVolume == 0.0 ? 100.0 : _setMuteVolume);
    }
  }

  @override
  Future<void> setShuffle(bool shuffle) => _player.setShuffle(shuffle).then((_) => state = state.copyWith(shuffle: shuffle));

  @override
  Future<void> muteOrUnmute() => setMute(state.volume != 0.0);

  Future<void> shuffleOrUnshuffle() => _player.setShuffle(!state.shuffle).then((_) => state = state.copyWith(shuffle: !state.shuffle));

  @override
  Future<void> open(
    List<Playable> playables, {
    int index = 0,
    bool play = true,
    void Function()? onOpen = mediaPlayerOpenOnOpen,
  }) async {
    await _player.open(Playlist(playables.map((playable) => playable.toMedia()).toList(), index: index), play: play);
    state = state.copyWith(index: index, playables: playables, duration: Duration.zero);
    onOpen?.call();
  }

  @override
  Future<void> add(List<Playable> playables) async {
    for (final playable in playables) {
      await _player.add(playable.toMedia());
    }
    state = state.copyWith(playables: [...state.playables, ...playables]);
  }

  Future<void> setPlaybackState(
    PlaybackState playbackState, {
    void Function()? onOpen,
  }) async {
    state = playbackState.toMediaPlayerState();
    await setRate(state.rate);
    await setPitch(state.pitch);
    await setVolume(state.volume);
    await setShuffle(state.shuffle);
    await setLoop(state.loop);
    if (onOpen != null) {
      await open(
        state.playables,
        index: state.index,
        // --------------------------------------------------
        play: false,
        onOpen: onOpen,
        // --------------------------------------------------
      );
    }
  }

  Future<void> mapPlayerToState() async {
    _player.stream.playlist.listen((e) => state = state.copyWith(index: e.index, playables: e.medias.map((e) => e.toPlayable()).toList(), duration: Duration.zero));
    _player.stream.rate.listen((e) => state = state.copyWith(rate: e));
    _player.stream.pitch.listen((e) => state = state.copyWith(pitch: e));
    _player.stream.volume.listen((e) => state = state.copyWith(volume: e));
    _player.stream.playlistMode.listen((e) => state = state.copyWith(loop: e.toLoop()));
    _player.stream.position.listen((e) => state = state.copyWith(position: e));
    _player.stream.duration.listen((e) => state = state.copyWith(duration: e));
    _player.stream.playing.listen((e) => state = state.copyWith(playing: e));
    _player.stream.buffering.listen((e) => state = state.copyWith(buffering: e));
    _player.stream.completed.listen((e) => state = state.copyWith(completed: e));
    _player.stream.audioBitrate.listen((e) => state = state.copyWith(audioBitrate: e));
    _player.stream.audioParams.listen((e) => state = state.copyWith(audioParams: e));
    _player.stream.error.listen((e) => debugPrint(e));
  }

  Future<void> updateCurrent({void Function(String)? onUpdateCurrent = mediaPlayerUpdateCurrentOnUpdateCurrent}) {
    return _updateCurrentLock.synchronized(() async {
      try {
        final uri = state.playables[state.index].uri;

        if (_updateCurrentFlagUri == uri) return;
        _updateCurrentFlagUri = uri;

        _current = null;
        notifyListeners();

        final cover = MediaLibrary.instance.uriToCoverFile(uri);

        // NOTE: Since the cover file already exists, the previously fetched tags are certainly correct, so there is no need to fetch them again.
        if (await cover.exists_() && await cover.length_() > 0) return;

        final tags = await _tagReader.parse(
          uri,
          cover: cover,
          timeout: const Duration(minutes: 1),
        );
        _current = tags.toTrack().toPlayable();
        notifyListeners();

        onUpdateCurrent?.call(uri);

        debugPrint('MediaPlayer: updateCurrent: URI: $uri');
        debugPrint('MediaPlayer: updateCurrent: Tags: $tags');
        debugPrint('MediaPlayer: updateCurrent: Current: $current');
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    });
  }

  Future<void> ensureInitializedPlayer() async {
    for (final MapEntry(key: property, value: value) in Configuration.instance.mpvOptions.entries) {
      final platform = _player.platform as NativePlayer;
      await platform.setProperty(property, value);
    }
    if (Platform.isAndroid) {
      final platform = _player.platform as NativePlayer;
      await platform.setProperty('ao', 'audiotrack');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    _tagReader.dispose();
    disposeAudioService();
    disposeDiscordRpc();
    disposeHistoryPlaylist();
    disposeMpris();
    disposeSystemMediaTransportControls();
    disposeWindowsTaskbar();
  }

  final Player _player = Player(configuration: const PlayerConfiguration(title: kTitle, pitch: true));

  final TagReader _tagReader = TagReader();

  Playable? _current;

  MediaPlayerState _state = MediaPlayerState.defaults();

  double _setMuteVolume = 100.0;

  String? _updateCurrentFlagUri;
  final Lock _updateCurrentLock = Lock();
}
