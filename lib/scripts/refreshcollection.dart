library refresh_collection;

import 'package:harmonoid/globals.dart' as Globals;
import 'package:harmonoid/scripts/getsavedmusic.dart';


class RefreshCollection {
  static Future<void> refreshAlbumsCollection() async {
    Globals.albums = (await GetSavedMusic.albums())['albums'];
    Globals.albumArts = await GetSavedMusic.albumArts();
    Globals.tracksList = new List<List<dynamic>>();

    for (int index = 0; index < Globals.albums.length; index++) {
      Globals.tracksList.add(
        (await GetSavedMusic.tracks(Globals.albums[index]['album_id']))['tracks']
      );
    }
  }
}