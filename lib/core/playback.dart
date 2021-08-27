import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart'
    as AssetsAudioPlayer;
import 'package:libwinmedia/libwinmedia.dart' as LIBWINMEDIA;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/download.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/lyrics.dart';
import 'package:harmonoid/constants/language.dart';

final LIBWINMEDIA.Player player = LIBWINMEDIA.Player(id: 0)
  ..streams.isCompleted.listen((isCompleted) async {
    if (!isCompleted) {
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
    }
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
