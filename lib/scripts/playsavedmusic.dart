library playsavedmusic;

import 'package:audio_service/audio_service.dart';

import 'dart:io';
import 'dart:convert' as convert;
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;
import 'package:harmonoid/main.dart';
import 'package:harmonoid/scripts/getsavedmusic.dart';

class PlaySavedMusic {
  static Future<void> playTrack(String albumId, int trackNumber) async {

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));

    File albumAssetsFile = File(path.join(musicDirectory.path, albumId, 'albumAssets.json'));

    Map<String, dynamic> albumAssets = convert.jsonDecode(await albumAssetsFile.readAsString());

    List<Map<String, dynamic>> albumTracks = (await GetSavedMusic.tracks(albumId))['tracks'];
    List<MediaItem> trackQueue = new List<MediaItem>();

    await AudioService.start(
      backgroundTaskEntrypoint: backgroundTaskEntryPoint,
      androidNotificationChannelName: 'com.alexmercerind.harmonoid',
      androidNotificationColor: 0xFF6200EA,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidStopForegroundOnPause: true,
      androidNotificationChannelDescription: 'Harmonoid Music Playing Service' 
    );

    for (int index = 0; index < albumTracks.length; index++) {
      trackQueue.add(
        MediaItem(
          id: albumAssets['album_id'] + '_' + albumTracks[index]['track_number'].toString(),
          title: albumTracks[index]['track_name'].split('(')[0].trim().split('-')[0].trim(),
          album: albumAssets['album_name'].split('(')[0].trim().split('-')[0].trim(),
          artist: albumAssets['album_artists'][0],
          artUri: 'file://${path.join(musicDirectory.path, albumId, 'albumArt.png')}',
          extras: {
            'album_id': albumAssets['album_id'], 
            'track_id': albumTracks[index]['track_id'],
            'track_number': albumTracks[index]['track_number'],
            'track_path': path.join(musicDirectory.path, albumId, '${albumTracks[index]['track_number']}.m4a')
          },
        ),
      );
    }

    await AudioService.updateQueue(trackQueue);
    await AudioService.playFromMediaId(albumAssets['album_id'] + '_' + trackNumber.toString());
  }
}