import 'dart:convert' as convert;
import 'package:harmonoid/constants/constants.dart';
import 'package:http/http.dart' as http;

import 'package:harmonoid/scripts/collection.dart';
import 'package:harmonoid/scripts/configuration.dart';


Discover discover;


class Discover {
  String homeAddress;

  Discover(this.homeAddress);

  static Future<void> init({String homeAddress}) async {
    discover = new Discover(homeAddress);
  }

  Future<List<dynamic>> search(String keyword, String mode) async {
    List<dynamic> result = <dynamic>[];
    String modeParam = mode.substring(0, mode.length - 1).toLowerCase();
    Uri uri = Uri.https(
      this.homeAddress,
      '/search', {
        'keyword': keyword,
        'mode': modeParam,
      },
    );
    try {
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        (convert.jsonDecode(response.body)[modeParam + 's'] as List).forEach((objectMap) {
          if (mode == Constants.STRING_ALBUM) result.add(Album.fromMap(objectMap));
          if (mode == Constants.STRING_TRACK) result.add(Track.fromMap(objectMap));
          if (mode == Constants.STRING_ARTIST) result.add(Artist.fromMap(objectMap));
        });
      }
      List<dynamic> searchRecents = await configuration.get(Configurations.discoverSearchRecents);
      if (searchRecents.length > 5) searchRecents.removeLast();
      if (!searchRecents.contains([keyword, mode])) searchRecents.insert(0, [keyword, mode]);
      await configuration.set(Configurations.discoverSearchRecents, searchRecents);
      return result;
    }
    catch(exception) {
      throw 'Please check your internet connection';
    }
  }
}
