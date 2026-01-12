import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' hide Playable, Track;
import 'package:media_library/media_library.dart' hide Playlist, FileSystemMediaLibrary;
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tag_reader/tag_reader.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';
import 'package:harmonoid/core/media_player/mixin/audio_service_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/audio_session_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/discord_rpc_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/history_playlist_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/lastfm_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/mpris_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/system_media_transport_controls_mixin.dart';
import 'package:harmonoid/core/media_player/mixin/windows_taskbar_mixin.dart';
import 'package:harmonoid/mappers/loop.dart';
import 'package:harmonoid/mappers/media.dart';
import 'package:harmonoid/mappers/playable.dart';
import 'package:harmonoid/mappers/playback_state.dart';
import 'package:harmonoid/mappers/playlist_mode.dart';
import 'package:harmonoid/mappers/replaygain.dart';
import 'package:harmonoid/mappers/tags.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/models/loop.dart';
import 'package:harmonoid/models/media_player_state.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/models/playback_state.dart';
import 'package:harmonoid/models/replaygain.dart';
import 'package:harmonoid/ui/harmonoid.dart';
import 'package:harmonoid/utils/actions.dart';
import 'package:harmonoid/utils/constants.dart';

/// {@template media_player}
///
/// MediaPlayer
/// -----------
/// Implementation to handle the media playback & other related functionalities.
///
/// {@endtemplate}
class MediaPlayer extends ChangeNotifier
    with AudioServiceMixin, AudioSessionMixin, DiscordRpcMixin, HistoryPlaylistMixin, LastFmMixin, MprisMixin, SystemMediaTransportControlsMixin, WindowsTaskbarMixin
    implements BaseMediaPlayer {
  static const Duration kCrossfadeDefaultDuration = Duration(seconds: 5);
  static const Duration kCrossfadeMinDuration = Duration(seconds: 2);
  static const Duration kCrossfadeMaxDuration = Duration(seconds: 30);
  static const int kMixThreshold = 100;

  /// Singleton instance.
  static final MediaPlayer instance = MediaPlayer._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  MediaPlayer._();

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    await instance._ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    await Future.wait(
      [
        ensureInitializedAudioService(),
        ensureInitializedAudioSession(),
        ensureInitializedDiscordRpc(),
        ensureInitializedHistoryPlaylist(),
        ensureInitializedLastFm(),
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
  Future<void> muteOrUnmute() => setMute(state.volume != 0.0);

  @override
  Future<void> setShuffle(bool shuffle) => _player.setShuffle(shuffle).then((_) => state = state.copyWith(shuffle: shuffle));

  @override
  Future<void> shuffleOrUnshuffle() => _player.setShuffle(!state.shuffle).then((_) => state = state.copyWith(shuffle: !state.shuffle));

  @override
  Future<void> setMix(bool mix, {void Function(bool)? onMix = mediaPlayerSetMixOnMix}) async {
    if (_mixLock.locked) return;
    return _mixLock.synchronized(() async {
      final mixOffset = state.mixOffset;
      if (mix && mixOffset == null) {
        await open(state.playables, index: state.index, mix: true);
      } else if (!mix && mixOffset != null) {
        if (state.index < mixOffset) {
          await open(state.playables.sublist(0, mixOffset), index: state.index, mix: false);
        } else {
          state = state.copyWith(mixOffset: null);
        }
      }

      onMix?.call(mix);
    });
  }

  @override
  Future<void> mixOrUnmix() => setMix(state.mixOffset == null);

  @override
  Future<void> open(
    Iterable<Playable> playables, {
    int index = 0,
    bool play = true,
    bool shuffle = false,
    bool? mix,
    void Function()? onOpen = mediaPlayerOpenOnOpen,
  }) async {
    final medias = playables.map((playable) => playable.toMedia()).toList();

    if (shuffle) {
      medias.shuffle();
    }

    // UPDATE MIX OFFSET
    int? mixOffset;
    if ((mix ?? Configuration.instance.nowPlayingStartMixAfterEnding) && playables.length < kMixThreshold) {
      mixOffset = medias.length;
      medias.addAll(MediaLibraryProvider.instance.tracks.map((track) => track.toPlayable().toMedia()).toList()..shuffle());
    }

    state = state.copyWith(shuffle: false, mixOffset: mixOffset);

    await _player.open(Playlist(medias, index: index), play: play);
    onOpen?.call();
  }

  @override
  Future<void> move(int from, int to) async {
    await _player.move(from, to);

    // UPDATE MIX OFFSET
    final mixOffset = state.mixOffset;
    if (mixOffset != null) {
      final fromBeforeMix = from < mixOffset;
      final toBeforeMix = to < mixOffset;
      if (fromBeforeMix && !toBeforeMix) {
        state = state.copyWith(mixOffset: mixOffset - 1);
      } else if (!fromBeforeMix && toBeforeMix) {
        state = state.copyWith(mixOffset: mixOffset + 1);
      }
    }
  }

  @override
  Future<void> remove(int index) async {
    await _player.remove(index);

    // UPDATE MIX OFFSET
    final mixOffset = state.mixOffset;
    if (mixOffset != null && index < mixOffset) {
      state = state.copyWith(mixOffset: mixOffset - 1);
    }
  }

  @override
  Future<void> add(Iterable<Playable> playables) async {
    final mixOffset = state.mixOffset;
    if (mixOffset != null) {
      // CASE: MIX ENABLED
      int insertIndex = mixOffset;
      for (final playable in playables) {
        await _player.add(playable.toMedia());
        await _player.move(state.playables.length - 1, insertIndex);
        insertIndex++;
      }
      state = state.copyWith(mixOffset: mixOffset + playables.length);
    } else {
      // CASE: MIX DISABLED
      for (final playable in playables) {
        await _player.add(playable.toMedia());
      }
    }
  }

  @override
  Future<void> insert(int index, Playable playable) async {
    await _player.add(playable.toMedia());
    await _player.move(state.playables.length - 1, index + 1);

    // UPDATE MIX OFFSET
    final mixOffset = state.mixOffset;
    if (mixOffset != null && index + 1 <= mixOffset) {
      state = state.copyWith(mixOffset: mixOffset + 1);
    }
  }

  @override
  Future<void> setExclusiveAudio(
    bool exclusiveAudio, {
    void Function()? onError = mediaPlayerSetExclusiveAudioOnError,
  }) async {
    if (exclusiveAudio && state.crossfadeDuration != Duration.zero) {
      onError?.call();
      return;
    }
    final platform = _player.platform as dynamic;
    await platform.setProperty('audio-exclusive', exclusiveAudio ? 'yes' : 'no');
    state = state.copyWith(exclusiveAudio: exclusiveAudio);
  }

  @override
  Future<void> setReplayGain(ReplayGain replayGain) async {
    final platform = _player.platform as dynamic;
    await platform.setProperty('replaygain', replayGain.toProperty());
    state = state.copyWith(replayGain: replayGain);
  }

  @override
  Future<void> setReplayGainPreamp(double replayGainPreamp) async {
    final platform = _player.platform as dynamic;
    await platform.setProperty('replaygain-preamp', replayGainPreamp.toString());
    state = state.copyWith(replayGainPreamp: replayGainPreamp);
  }

  @override
  Future<void> setCrossfadeDuration(
    Duration crossfadeDuration, {
    void Function()? onError = mediaPlayerSetCrossfadeDurationOnError,
    void Function()? onPlayerReset = mediaPlayerSetCrossfadeDurationPlayerReset,
  }) async {
    if (crossfadeDuration != Duration.zero && state.exclusiveAudio) {
      onError?.call();
      return;
    }
    if ((state.crossfadeDuration != Duration.zero && crossfadeDuration == Duration.zero) || (state.crossfadeDuration == Duration.zero && crossfadeDuration != Duration.zero)) {
      state = MediaPlayerState.defaults();
      _current = null;
      onPlayerReset?.call();
      await ensureInitializedPlayer(crossfadeDuration: crossfadeDuration);
    }
    if (crossfadeDuration != Duration.zero) {
      final platform = _player.platform as CrossfadePlayer;
      await platform.setCrossfadeDuration(crossfadeDuration);
    }
    state = state.copyWith(crossfadeDuration: crossfadeDuration);
  }

  Future<void> setPlaybackState(
    PlaybackState playbackState, {
    void Function()? onOpen,
  }) async {
    await ensureInitializedPlayer(crossfadeDuration: playbackState.crossfadeDuration);

    state = playbackState.toMediaPlayerState();
    if (state.rate != 1.0) {
      await setRate(state.rate);
    }
    if (state.pitch != 1.0) {
      await setPitch(state.pitch);
    }

    // Both cannot work together. Disable one, otherwise bad things will happen.
    if (state.exclusiveAudio && state.crossfadeDuration > Duration.zero) {
      state = state.copyWith(crossfadeDuration: Duration.zero);
    }

    await setVolume(state.volume);
    await setLoop(state.loop);
    await setExclusiveAudio(state.exclusiveAudio);
    await setReplayGain(state.replayGain);
    await setReplayGainPreamp(state.replayGainPreamp);
    await setCrossfadeDuration(state.crossfadeDuration);
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

    // Must be done after calling open.
    await setShuffle(playbackState.shuffle);
  }

  Future<void> mapPlayerToState() async {
    _player.stream.playlist.listen((e) => _mapPlayerToStatePlaylistLock.synchronized(() => _applyPlayerPlaylistToState(e)));
    _player.stream.rate.listen((e) => state = state.copyWith(rate: e));
    _player.stream.pitch.listen((e) => state = state.copyWith(pitch: e));
    _player.stream.volume.listen((e) => state = state.copyWith(volume: e));
    _player.stream.playlistMode.listen((e) => state = state.copyWith(loop: e.toLoop()));
    _player.stream.position.listen((e) => state = state.copyWith(position: e));
    _player.stream.duration.listen((e) => state = state.copyWith(duration: e));
    _player.stream.playing.listen((e) => state = state.copyWith(playing: e));
    _player.stream.buffering.listen((e) => state = state.copyWith(buffering: e));
    _player.stream.completed.listen((e) => state = state.copyWith(completed: e));
    _player.stream.audioBitrate.listen((e) => e == null ? true : state = state.copyWith(audioBitrate: e));
    _player.stream.audioParams.listen((e) => state = state.copyWith(audioParams: e));
    _player.stream.error.listen((e) {
      debugPrint(e);
      // mediaPlayerOnError(e);
    });
  }

  Future<void> updateCurrent({void Function(String)? onUpdateCurrent = mediaPlayerUpdateCurrentOnUpdateCurrent}) {
    return _updateCurrentLock.synchronized(() async {
      try {
        final uri = state.playables.elementAtOrNull(state.index)?.uri;

        if (uri == null || _updateCurrentFlagUri == uri) return;
        _updateCurrentFlagUri = uri;

        _current = null;
        notifyListeners();

        File? cover = MediaLibrary.trackUriToCoverFile(FileSystemMediaLibrary.instance.covers, uri);
        if (await cover.exists_() && await cover.length_() > 0) {
          cover = null;
        }

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

  Future<void> ensureInitializedPlayer({required Duration crossfadeDuration}) async {
    try {
      await _player.dispose();
    } catch (_) {}

    if (crossfadeDuration != Duration.zero) {
      _player = Player(
        platformPlayer: CrossfadePlayer(
          configuration: CrossfadePlayerConfiguration(title: kTitle, pitch: true, crossfadeDuration: crossfadeDuration),
        ),
      );
    } else {
      _player = Player(configuration: const PlayerConfiguration(title: kTitle, pitch: true));
    }

    mapPlayerToState();

    final platform = _player.platform as dynamic;
    if (Platform.isAndroid) {
      await platform.setProperty('ao', 'audiotrack,opensles');
    }
    if (Platform.isMacOS) {
      await platform.setProperty('ao', 'coreaudio');
    }
    if (Platform.isWindows) {
      await platform.setProperty('ao', 'wasapi');
    }
    await platform.setProperty('audio-stream-silence', 'yes');
    // https://github.com/harmonoid/harmonoid/issues/527
    // https://discord.com/channels/935994617663483916/936215125772341289/1450093460127219743
    await platform.setProperty('sub-auto', 'no');
    for (final MapEntry(key: property, value: value) in Configuration.instance.mpvOptions.entries) {
      await platform.setProperty(property, value);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    _tagReader.dispose();
    disposeAudioService();
    disposeAudioSession();
    disposeDiscordRpc();
    disposeHistoryPlaylist();
    disposeLastFm();
    disposeMpris();
    disposeSystemMediaTransportControls();
    disposeWindowsTaskbar();
  }

  // HACK:
  Future<void> disablePlayerPlaylistUpdates() async {
    _disablePlayerPlaylistUpdates = true;
  }

  // HACK:
  Future<void> enablePlayerPlaylistUpdates() async {
    _disablePlayerPlaylistUpdates = false;

    await _applyPlayerPlaylistToState(_player.state.playlist);
  }

  Future<void> _applyPlayerPlaylistToState(Playlist playlist) async {
    if (_disablePlayerPlaylistUpdates) return;

    final previousIndex = state.index;
    final previousPlayables = state.playables;
    final previousPlayableAtIndex = previousPlayables.elementAtOrNull(previousIndex);

    final currentIndex = playlist.index;
    final currentMediaAtIndex = playlist.medias.elementAtOrNull(currentIndex);

    // Avoid heavy deserialization.
    final shouldUpdatePlayables = previousPlayables.length != playlist.medias.length || !_comparePlayableListAndMediaList(previousPlayables, playlist.medias);
    // Avoid fucking up the lyrics accuracy.
    final shouldResetPosition = previousPlayableAtIndex?.uri != currentMediaAtIndex?.uri;

    final currentPlayables = shouldUpdatePlayables ? await Future.wait(playlist.medias.map((e) => e.toPlayable())) : previousPlayables;

    if (shouldResetPosition) {
      state = state.copyWith(
        position: Duration.zero,
        index: currentIndex,
        playables: currentPlayables,
      );
    } else {
      state = state.copyWith(
        index: currentIndex,
        playables: currentPlayables,
      );
    }
  }

  bool _comparePlayableListAndMediaList(List<Playable> playables, List<Media> medias) {
    if (playables.length != medias.length) return false;
    for (int i = 0; i < playables.length; i++) {
      if (playables[i].uri != medias[i].uri) return false;
    }
    return true;
  }

  // mapPlayerToState

  bool _disablePlayerPlaylistUpdates = false;
  final Lock _mapPlayerToStatePlaylistLock = Lock();

  // updateCurrent

  Playable? _current;
  String? _updateCurrentFlagUri;
  final Lock _updateCurrentLock = Lock();

  // setMute; muteOrUnmute

  double _setMuteVolume = 100.0;

  // setMix; mixOrUnmix

  final Lock _mixLock = Lock();

  // -----

  MediaPlayerState _state = MediaPlayerState.defaults();

  late Player _player;
  final TagReader _tagReader = TagReader();
}
