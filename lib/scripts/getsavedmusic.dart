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
      await musicDirectory.create();
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

  static Future<Map<String, dynamic>> tracks(String albumId) async {

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));

    File albumAssetsFile = File(path.join(musicDirectory.path, albumId, 'trackAssets.json'));
    Map<String, dynamic> tracks = convert.jsonDecode(await albumAssetsFile.readAsString());
    return tracks;
  }

  static Future<List<File>> albumArts() async {

    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));
    Directory musicDirectory = Directory(path.join(applicationDirectory.path, 'musicLibrary'));

    if (!(await applicationDirectory.exists())) {
      await musicDirectory.create();
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