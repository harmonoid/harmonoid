
import 'dart:io';

import 'package:harmonoid/language/constants.dart';
import 'package:harmonoid/scripts/collection.dart';


abstract class Methods {

  static int binaryIndexOf(List<List<String>> collectionList, List<String> keywordList) {
    int indexOfKeywordList = -1;
    for (int index = 0; index < collectionList.length; index++) {
      List<String> object = collectionList[index];
      if (object[0] == keywordList[0] && object[1] == keywordList[1]) {
        indexOfKeywordList = index;
        break;
      }
    }
    return indexOfKeywordList;
  }

  static bool binaryContains(List<List<String>> collectionList, List<String> keywordList) => binaryIndexOf(collectionList, keywordList) != -1 ? true : false;

  static bool isFileSupported(FileSystemEntity file) {
    if (file is File && SUPPORTED_FILE_TYPES.contains(file.path.split('.').last.toUpperCase())) {
      return true;
    }
    else {
      return false;
    }
  }

  static String mediaTypeToLanguage(MediaType mediaType) {
    if (mediaType is Album)
      return Constants.STRING_ALBUM;
    else if (mediaType is Track)
      return Constants.STRING_TRACK;
    else if (mediaType is Artist)
      return Constants.STRING_ARTIST;
    else if (mediaType is Playlist)
      return Constants.STRING_PLAYLIST;
    else
      return null;
  }
}
