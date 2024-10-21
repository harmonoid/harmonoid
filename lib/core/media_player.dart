import 'dart:collection';
import 'dart:io';
import 'package:audio_service/audio_service.dart' hide PlaybackState;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:media_kit/media_kit.dart' hide Playable;
import 'package:system_media_transport_controls/system_media_transport_controls.dart';
import 'package:tag_reader/tag_reader.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import 'package:harmonoid/api/activity_set.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/media_player_state.dart';
import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
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
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/methods.dart';
import 'package:harmonoid/utils/rendering.dart';

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

  Playable get current => _current ?? state.playables[state.index];
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
    notifyListeners();

    debugPrint('MediaPlayer: notifyCurrent: URI: $uri');
    debugPrint('MediaPlayer: notifyCurrent: Tags: $tags');
    debugPrint('MediaPlayer: notifyCurrent: Current: $current');
  }

  Future<void> notifyHistoryPlaylist() async {
    if (state.playables.isEmpty) return;
    if (_notifyHistoryPlaylistFlagPlayable == current) return;
    _notifyHistoryPlaylistFlagPlayable = current;

    if (await MediaLibrary.instance.db.contains(current.uri)) {
      // It is available in the media library. Save as hash + title.
      await MediaLibrary.instance.playlists.addToHistory(track: await MediaLibrary.instance.db.selectTrackByUri(current.uri));
    } else {
      // It is not available in the media library. Save as uri + title.
      await MediaLibrary.instance.playlists.addToHistory(uri: current.uri, title: current.playlistEntryTitle);
    }
  }

  Future<void> notifyAudioService() async {
    if (!(Platform.isAndroid || Platform.isMacOS)) return;
    _audioService ??= await AudioService.init(
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
    try {
      if (_systemMediaTransportControls == null) {
        SystemMediaTransportControls.ensureInitialized();
        _systemMediaTransportControls = SystemMediaTransportControls.instance
          ..create((event) {
            final fn = switch (event) {
              SMTCEvent.play => play,
              SMTCEvent.pause => pause,
              SMTCEvent.next => next,
              SMTCEvent.previous => previous,
              _ => null,
            };
            fn?.call();
          });
      }

      _systemMediaTransportControls
        ?..setStatus(state.playing ? SMTCStatus.playing : SMTCStatus.paused)
        ..setMusicData(
          albumTitle: current.description.firstOrNull,
          albumArtist: current.subtitle.firstOrNull,
          artist: current.subtitle.join(', '),
          title: current.title,
        )
        ..setTimelineData(
          endTime: state.duration.inMilliseconds,
          position: state.position.inMilliseconds,
        );

      if (_notifySystemMediaTransportControlsFlagPlayable == current) return;
      _notifySystemMediaTransportControlsFlagPlayable = current;
      final image = cover(uri: current.uri);
      final artwork = switch (image) {
        AsyncFileImage() => await image.file,
        FileImage() => image.file,
        NetworkImage() => image.url,
        _ => null,
      };
      await _systemMediaTransportControls?.setArtwork(artwork);
    } catch (_) {}
  }

  Future<void> notifyWindowsTaskbar() async {
    if (!Platform.isWindows) return;
    try {
      await WindowsTaskbar.setThumbnailToolbar(
        [
          ThumbnailToolbarButton(
            ThumbnailToolbarAssetIcon('assets/icons/previous.ico'),
            Localization.instance.PREVIOUS,
            previous,
            mode: state.isFirst ? ThumbnailToolbarButtonMode.disabled : 0,
          ),
          if (state.playing)
            ThumbnailToolbarButton(
              ThumbnailToolbarAssetIcon('assets/icons/pause.ico'),
              Localization.instance.PAUSE,
              pause,
            )
          else
            ThumbnailToolbarButton(
              ThumbnailToolbarAssetIcon('assets/icons/play.ico'),
              Localization.instance.PLAY,
              play,
            ),
          ThumbnailToolbarButton(
            ThumbnailToolbarAssetIcon('assets/icons/next.ico'),
            Localization.instance.NEXT,
            next,
            mode: state.isLast ? ThumbnailToolbarButtonMode.disabled : 0,
          ),
        ],
      );
      if (Configuration.instance.windowsTaskbarProgress) {
        const total = 1 << 16;
        final completed = (state.position.inSeconds / state.duration.inSeconds * total).round();
        await WindowsTaskbar.setProgress(total, completed);
      }
    } catch (_) {}
  }

  Future<void> notifyDiscordRPC() async {
    if (!(Platform.isLinux || Platform.isMacOS || Platform.isWindows)) return;
    if (!Configuration.instance.discordRpc) return;
    try {
      if (_flutterDiscordRPC == null) {
        await FlutterDiscordRPC.initialize('881480706545573918');
        _flutterDiscordRPC = FlutterDiscordRPC.instance..connect();
      }

      final deviceId = '${Platform.operatingSystem}-${Platform.localHostname}';

      final notify = _notifyDiscordRPCFlagPlayable != current ||
          _notifyDiscordRPCFlagPlaying != state.playing ||
          ((_notifyDiscordRPCFlagPosition ?? Duration.zero) - state.position).abs() > const Duration(seconds: 5);

      if (_notifyDiscordRPCFlagPlayable != current) {
        _notifyDiscordRPCFlagPlayable = current;
        try {
          final image = cover(uri: current.uri);
          _currentDiscordRPCLargeImage = switch (image) {
            AsyncFileImage() => await ActivitySet.instance.call(deviceId, current, await image.file),
            FileImage() => await ActivitySet.instance.call(deviceId, current, image.file),
            NetworkImage() => image.url,
            _ => null,
          }!;
        } catch (_) {
          _currentDiscordRPCLargeImage = 'cover_default';
        }
      }
      if (_notifyDiscordRPCFlagPlaying != state.playing) {
        _notifyDiscordRPCFlagPlaying = state.playing;
      }
      if (((_notifyDiscordRPCFlagPosition ?? Duration.zero) - state.position).abs() > const Duration(seconds: 5)) {
        _notifyDiscordRPCFlagPosition = state.position;
      }

      if (notify) {
        await _flutterDiscordRPC?.setActivity(
          activity: RPCActivity(
            state: current.subtitle.take(2).join(', ').ellipsis(128).nullIfBlank(),
            details: current.title.ellipsis(128).nullIfBlank(),
            timestamps: state.playing
                ? RPCTimestamps(
                    start: DateTime.now().subtract(state.position).millisecondsSinceEpoch,
                    end: DateTime.now().subtract(state.position).add(state.duration).millisecondsSinceEpoch,
                  )
                : null,
            assets: RPCAssets(
              largeImage: _currentDiscordRPCLargeImage,
              smallImage: state.playing ? 'play' : 'pause',
              largeText: state.getAudioFormatLabel().ellipsis(128).nullIfBlank(),
              smallText: state.playing ? 'Playing' : 'Paused',
            ),
            buttons: [
              RPCButton(
                label: 'Find',
                url: 'https://www.google.com/search?q=${Uri.encodeComponent([current.title, ...current.subtitle.take(2)].where((e) => e.isNotEmpty).join(' '))}',
              ),
            ],
            activityType: ActivityType.listening,
          ),
        );
      }
    } catch (_) {}
  }

  void resetNotifySystemMediaTransportControlsFlagPlayable() {
    _notifySystemMediaTransportControlsFlagPlayable = null;
  }

  void resetNotifyDiscordRPCFlagPlayable() {
    _notifyDiscordRPCFlagPlayable = null;
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    _tagReader.dispose();
    _audioService?.stop();
    _systemMediaTransportControls?.dispose();
    _flutterDiscordRPC?.dispose();
  }

  /// [Player] from package:media_kit.
  final Player _player = Player(configuration: const PlayerConfiguration(title: kTitle, pitch: true));

  /// [TagReader] from package:tag_reader.
  final TagReader _tagReader = TagReader();

  /// [AudioService] from package:audio_service.
  _AudioService? _audioService;

  /// [SystemMediaTransportControls] from package:system_media_transport_controls.
  SystemMediaTransportControls? _systemMediaTransportControls;

  /// [FlutterDiscordRPC] from package:flutter_discord_rpc.
  FlutterDiscordRPC? _flutterDiscordRPC;

  /// Flag to prevent duplicate [notifyCurrent] calls.
  String? _notifyCurrentFlagUri;

  /// Flag to prevent duplicate [notifyHistoryPlaylist] calls.
  Playable? _notifyHistoryPlaylistFlagPlayable;

  /// Flag to prevent duplicate [notifySystemMediaTransportControls] calls.
  Playable? _notifySystemMediaTransportControlsFlagPlayable;

  /// Flags to prevent duplicate [notifyDiscordRPC] calls.
  Playable? _notifyDiscordRPCFlagPlayable;
  bool? _notifyDiscordRPCFlagPlaying;
  Duration? _notifyDiscordRPCFlagPosition;

  /// Current large image for Discord RPC.
  String? _currentDiscordRPCLargeImage;

  // NOTE: A separate [TagReader] overrides the existing values etc. in the [Playable]s.

  /// Current [Playable] containing overridden values with freshly fetched tags.
  Playable? _current;

  /// Current [MediaPlayerState].
  MediaPlayerState _state = MediaPlayerState.defaults();

  /// Volume before mute.
  double _volumeBeforeMute = 100.0;
}

class _AudioService extends BaseAudioHandler {}
