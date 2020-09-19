library getsavedmusic;

import 'dart:io';
import 'dart:convert' as convert;
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;

class GetSavedMusic {

  static Future<Map<String, dynamic>> albums() async {

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));

    if (!(await applicationDirectory.exists())) {
      await musicDirectory.create(recursive: true);
    }

    Map<String, dynamic> albums = {'albums': ''};

    List<FileSystemEntity> savedAlbumsFolder = musicDirectory.listSync();
    List<Map<String, dynamic>> savedAlbums = new List<Map<String, dynamic>>();

    for (Directory file in savedAlbumsFolder) {
      File albumAssetsFile = File(path.join(file.path, 'albumAssets.json'));
      Map<String, dynamic> album = convert.jsonDecode(await albumAssetsFile.readAsString());
      savedAlbums.add(album);
    }
    albums['albums'] = savedAlbums;

    return albums;
  }

  static Future<void> deleteAlbum(String albumId) async {

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));

    Directory albumDirectory = Directory(path.join(musicDirectory.path, albumId));
    await albumDirectory.delete(recursive: true);
  }

  static Future<int> deleteTrack(String albumId, int trackNumber) async {

    bool isNumeric(String str) {
      if(str == null) {
        return false;
      }
      return double.tryParse(str) != null;
    }

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));
    List<FileSystemEntity> albumDirectory = Directory(path.join(musicDirectory.path, albumId)).listSync();

    File trackJson = File(path.join(musicDirectory.path, albumId, '$trackNumber.json'));
    File trackFile0 = File(path.join(musicDirectory.path, albumId, '$trackNumber.m4a'));
    File trackFile1 = File(path.join(musicDirectory.path, albumId, '$trackNumber.m4a'));

    int tracksNumber = 0;
    for (int index = 0; index < albumDirectory.length; index++) {
      if (path.basename(albumDirectory[index].path).split('.')[1] == 'json' && isNumeric(path.basename(albumDirectory[index].path).split('.')[0])) {
        tracksNumber++;
      }
    }

    try {await trackJson.delete();} catch(e) {}
    try {await trackFile0.delete();} catch(e) {}
    try {await trackFile1.delete();} catch(e) {}

    return tracksNumber;
  }

  static Future<Map<String, dynamic>> tracks(String albumId) async {

    bool isNumeric(String str) {
      if(str == null) {
        return false;
      }
      return double.tryParse(str) != null;
    }

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));

    List<Map<String, dynamic>> savedTracks = new List<Map<String, dynamic>>();
    List<Map<String, dynamic>> sortedSavedTracks = new List<Map<String, dynamic>>();

    List<FileSystemEntity> albumDirectory = Directory(path.join(musicDirectory.path, albumId)).listSync();
    
    for (int index = 0; index < albumDirectory.length; index++) {
      if (path.basename(albumDirectory[index].path).split('.')[1] == 'json' && isNumeric(path.basename(albumDirectory[index].path).split('.')[0])) {
        File trackFile = File(albumDirectory[index].path);
        Map<String, dynamic> trackJson = convert.jsonDecode(await trackFile.readAsString());
        savedTracks.add(trackJson);
      }
    }

    while (savedTracks.length > 0) {
      int minTrackNumber = 0;
      int switchIndex = 0;
      for (int index = 0; index < savedTracks.length; index++) {
        if (savedTracks[index]['track_number'] > minTrackNumber) {
          minTrackNumber = savedTracks[index]['track_number'];
          switchIndex = index;
        }
      }
      sortedSavedTracks.insert(0, savedTracks[switchIndex]);
      savedTracks.removeAt(switchIndex);
    }

    return {'tracks' : sortedSavedTracks};
  }

  static Future<List<File>> albumArts() async {

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));

    if (!(await applicationDirectory.exists())) {
      await musicDirectory.create(recursive: true);
    }

    List<File> albumArts = new List<File>();

    List<FileSystemEntity> savedAlbumsFolder = musicDirectory.listSync();

    for (Directory file in savedAlbumsFolder) {
      File albumArt = File(path.join(file.path, 'albumArt.png'));
      albumArts.add(albumArt);
    }

    return albumArts;
  }
}