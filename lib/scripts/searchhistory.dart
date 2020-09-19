import 'dart:io';
import 'dart:convert' as convert;
import 'package:path_provider/path_provider.dart' as path;
import 'package:path/path.dart' as path;


class SearchHistory {

  static Future<Map<String, dynamic>> getSearchHistory() async {
    Map<String, dynamic> searchHistory;
    try {
      Directory externalDirectory = (await path.getExternalStorageDirectory());
      Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));

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
    Directory externalDirectory = (await path.getExternalStorageDirectory());
    Directory applicationDirectory = Directory(path.join(externalDirectory.path, '.harmonoid'));

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