import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart'
    as AssetsAudioPlayer;
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:libwinmedia/libwinmedia.dart' as LIBWINMEDIA;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/download.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/lyrics.dart';
import 'package:harmonoid/constants/language.dart';

/// Never listen to event Streams of any audio playback backend but use [CurrentlyPlaying] notifier.
/// This wil improve `Platform.isX` calls all around & keep code stream subscription cleaner.
/// It will also make things look more cross-platform on the surface & in the UI code.
///
/// For handling different platform specific calls, add methods inside the [Playback]
/// class below & then map within the UI code.
///

final LIBWINMEDIA.Player player = LIBWINMEDIA.Player(id: 0)
  ..streams.index.listen((index) {
    currentlyPlaying.index = index;
    try {
      List<LIBWINMEDIA.Media> medias = player.state.medias;
      int index = player.state.index;
      Track track = Track.fromMap(medias[index].extras)!;
      player.nativeControls.update(
        albumArtist: track.albumArtistName,
        album: track.albumName,
        title: track.trackName,
        artist: track.trackArtistNames?.join(', '),
        thumbnail: track.albumArt,
      );
    } catch (exception) {}
  })
  ..streams.medias.listen((medias) {
    currentlyPlaying.tracks = medias
        .map(
          (media) => Track.fromMap(media.extras)!,
        )
        .toList();
  })
  ..streams.isPlaying.listen((isPlaying) {
    currentlyPlaying.isPlaying = isPlaying;
  })
  ..streams.isBuffering.listen((isBuffering) {
    currentlyPlaying.isBuffering = isBuffering;
  })
  ..streams.isCompleted.listen((isCompleted) async {
    currentlyPlaying.isCompleted = isCompleted;
    if (!isCompleted) {
      try {
        List<LIBWINMEDIA.Media> medias = player.state.medias;
        int index = player.state.index;
        Track track = Track.fromMap(medias[index].extras)!;
        player.nativeControls.update(
          albumArtist: track.albumArtistName,
          album: track.albumName,
          title: track.trackName,
          artist: track.trackArtistNames?.join(', '),
          thumbnail: track.albumArt,
        );
      } catch (exception) {}
    }
  })
  ..streams.position.listen((position) {
    currentlyPlaying.position = position;
  })
  ..streams.duration.listen((duration) {
    currentlyPlaying.duration = duration;
  });

final AssetsAudioPlayer.AssetsAudioPlayer assetsAudioPlayer =
    AssetsAudioPlayer.AssetsAudioPlayer.withId('harmonoid')
      ..current.listen((AssetsAudioPlayer.Playing? current) async {
        if (current != null) {
          try {
            await lyrics.fromName(current.audio.audio.metas.title! +
                ' - ' +
                current.audio.audio.metas.artist!);
            const AndroidNotificationDetails settings =
                AndroidNotificationDetails(
              'com.alexmercerind.harmonoid',
              'Harmonoid',
              '',
              icon: 'mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.max,
              showWhen: false,
              onlyAlertOnce: true,
              playSound: false,
              enableVibration: false,
              showProgress: true,
              indeterminate: true,
            );
            await notification.show(
              100000,
              lyrics.query,
              language!.STRING_LYRICS_RETRIEVING,
              NotificationDetails(android: settings),
            );
          } catch (exception) {
            Future.delayed(
              Duration(seconds: 2),
              () => notification.cancel(
                100000,
              ),
            );
          }
        }
      })
      ..currentPosition.listen((Duration? position) async {
        if (lyrics.current.isNotEmpty &&
            position != null &&
            configuration.notificationLyrics!) {
          for (Lyric lyric in lyrics.current)
            if (lyric.time ~/ 1000 == position.inSeconds) {
              const AndroidNotificationDetails settings =
                  AndroidNotificationDetails(
                'com.alexmercerind.harmonoid',
                'Harmonoid',
                '',
                icon: 'mipmap/ic_launcher',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: false,
                onlyAlertOnce: true,
                playSound: false,
                enableVibration: false,
              );
              await notification.show(
                100000,
                lyrics.query,
                lyric.words,
                NotificationDetails(android: settings),
              );
              break;
            }
        }
      });

abstract class Playback {
  static Future<void> add(List<Track> tracks) async {
    if (Platform.isWindows) {
      tracks.forEach((track) {
        player.add(
          LIBWINMEDIA.Media(
            uri: track.filePath!,
          ),
        );
      });
    }
  }

  static Future<void> setRate(double rate) async {
    player.rate = rate;
  }

  static Future<void> setVolume(double volume) async {
    player.volume = volume;
  }

  static Future<void> back() async {
    if (Platform.isWindows) {
      player.back();
    }
  }

  static Future<void> next() async {
    if (Platform.isWindows) {
      player.next();
    }
  }

  static Future<void> seek(Duration position) async {
    if (Platform.isWindows) {
      player.seek(position);
    }
  }

  static Future<void> playOrPause() async {
    if (Platform.isWindows) {
      if (player.state.isPlaying)
        player.pause();
      else
        player.play();
    }
  }

  static Future<void> play(
      {required int index, required List<Track> tracks}) async {
    List<Track> _tracks = [...tracks];
    // libwinmedia.dart
    if (Platform.isWindows) {
      player.open(
        _tracks
            .map(
              (track) => LIBWINMEDIA.Media(
                uri: track.filePath!,
                extras: track.toMap(),
              ),
            )
            .toList(),
      );
      player.jump(index);
      player.play();
    }
    // assets_audio_player
    if (Platform.isAndroid) {
      assetsAudioPlayer.open(
        AssetsAudioPlayer.Playlist(
          audios: _tracks
              .map(
                (track) => AssetsAudioPlayer.Audio.file(
                  track.filePath!,
                  metas: AssetsAudioPlayer.Metas(
                    id: track.trackId,
                    image: AssetsAudioPlayer.MetasImage.file(
                      track.albumArt.path,
                    ),
                    title: track.trackName!,
                    album: track.albumName!,
                    artist: track.trackArtistNames!.join(', '),
                    extra: track.toMap(),
                  ),
                ),
              )
              .toList()
              .cast(),
          startIndex: index,
        ),
        showNotification: true,
        loopMode: AssetsAudioPlayer.LoopMode.playlist,
        notificationSettings: AssetsAudioPlayer.NotificationSettings(
          playPauseEnabled: true,
          nextEnabled: true,
          prevEnabled: true,
          seekBarEnabled: true,
          stopEnabled: false,
        ),
      );
    }
  }
}
