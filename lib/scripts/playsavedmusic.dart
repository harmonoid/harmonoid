library playsavedmusic;

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;

class PlaySavedMusic {
  static Future<void> playTrack(String albumId, int trackNumber) async {

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));

    String trackPath = path.join(musicDirectory.path, albumId, '$trackNumber.m4a');

    AudioPlayer audioPlayer = new AudioPlayer();
    await audioPlayer.play(trackPath, isLocal: true);
  }
}