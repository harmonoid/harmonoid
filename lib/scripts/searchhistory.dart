import 'dart:io';
import 'package:harmonoid/globals.dart' as Globals;
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;


class SearchHistory {

  static Future<Map<String, dynamic>> getSearchHistory() async {
    Map<String, dynamic> searchHistory;
    try {
      Directory applicationDirectory = Directory(path.join(Globals.APP_DIR, '.harmonoid'));

      File searchHistoryFile = File(path.join(applicationDirectory.path, 'search.json'));

      if (await searchHistoryFile.exists()) {
        searchHistory = convert.jsonDecode(await searchHistoryFile.readAsString());
      }
      else {
        await searchHistoryFile.create();
        await searchHistoryFile.writeAsString(convert.jsonEncode({'searches' : []}));
        searchHistory = {'searches' : []};
      }
    }
    catch(e) {
      searchHistory = {'searches' : []};
    }
    return searchHistory;
  }

  static Future<void> addSearchHistory(String keyword, String mode) async {
    Directory applicationDirectory = Directory(path.join(Globals.APP_DIR, '.harmonoid'));

    File searchHistoryFile = File(path.join(applicationDirectory.path, 'search.json'));
    
    List<dynamic> searchHistory = (await SearchHistory.getSearchHistory())['searches'];
    
    if (searchHistory.length > 5 && searchHistory.isNotEmpty) {
      searchHistory.removeAt(0);
    }
    Map<String, String> newHistory = {
      'keyword': keyword,
      'mode': mode,
    };
    bool isFresh = true;
    for (var element in searchHistory) {
      if (element.toString() == newHistory.toString()) {
        isFresh = false;
        break;
      }
    }
    if (isFresh) {
      searchHistory.add(newHistory);
    }
    await searchHistoryFile.writeAsString(convert.jsonEncode({'searches' : searchHistory}));
  }
}