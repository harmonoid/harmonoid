import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'package:harmonoid/constants/strings.dart';
import 'package:harmonoid/core/configuration.dart';

class LanguageRegion {
  final String code;
  final String countryCode;
  final String name;
  final String country;
  final String translator;
  final String github;

  const LanguageRegion({
    required this.code,
    required this.countryCode,
    required this.name,
    required this.country,
    required this.translator,
    required this.github,
  });

  static const enUs = LanguageRegion(
    code: 'en',
    countryCode: 'US',
    name: 'English',
    country: 'United States',
    translator: 'alexmercerind',
    github: 'https://github.com/alexmercerind',
  );
  static const ruRu = LanguageRegion(
    code: 'ru',
    countryCode: 'RU',
    name: 'Русский',
    country: 'Россия',
    translator: 'raitonoberu',
    github: 'https://github.com/raitonoberu',
  );
  static const slSi = LanguageRegion(
    code: 'sl',
    countryCode: 'SI',
    name: 'slovenščina',
    country: 'Slovenija',
    translator: 'mytja',
    github: 'https://github.com/mytja',
  );
  static const ptBr = LanguageRegion(
    code: 'pt',
    countryCode: 'BR',
    name: 'Português',
    country: 'Brasil',
    translator: 'bdlukaa',
    github: 'https://github.com/bdlukaa',
  );
  static const hiIn = LanguageRegion(
    code: 'hi',
    countryCode: 'IN',
    name: 'हिंदी',
    country: 'भारत',
    translator: 'alexmercerind',
    github: 'https://github.com/alexmercerind',
  );
  static const deDe = LanguageRegion(
      code: 'de',
      countryCode: 'DE',
      name: 'Deutsche',
      country: 'Deutschland',
      translator: 'MickLesk',
      github: 'https://github.com/MickLesk');
  static const nlNl = LanguageRegion(
    code: 'nl',
    countryCode: 'NL',
    name: 'Nederlands',
    country: 'Nederland',
    translator: 'kebabinjeneus',
    github: 'https://github.com/kebabinjeneus',
  );
  static const svSe = LanguageRegion(
    code: 'sv',
    countryCode: 'SE',
    name: 'Svenska',
    country: 'Sverige',
    translator: 'Max Haureus',
    github: '',
  );
  static const frFr = LanguageRegion(
    code: 'fr',
    countryCode: 'FR',
    name: 'Français',
    country: 'France',
    translator: 'Gaetan Jonathan',
    github: 'https://github.com/gaetan1903',
  );
  static const huHu = LanguageRegion(
    code: 'hu',
    countryCode: 'HU',
    name: 'Magyar',
    country: 'Magyarország',
    translator: 'RedyAu',
    github: 'https://github.com/RedyAu',
  );
  static const mgMG = LanguageRegion(
    code: 'mg',
    countryCode: 'MG',
    name: 'Malagasy',
    country: 'Madagascar',
    translator: 'Dominick',
    github: 'https://github.com/c3k4ah',
  );
  static const zhCN = LanguageRegion(
    code: 'zh',
    countryCode: 'CN',
    name: '汉语',
    country: '中国',
    translator: 'stonegate',
    github: 'https://github.com/stonega',
  );

  static const values = <LanguageRegion>[
    enUs,
    ruRu,
    slSi,
    ptBr,
    hiIn,
    deDe,
    nlNl,
    svSe,
    frFr,
    huHu,
    mgMG,
    zhCN,
  ];

  int get index => values.indexOf(this);
}

class Language extends Strings with ChangeNotifier {
  late LanguageRegion current;

  static Language? get() => language;

  static Future<void> initialize() async {
    language = Language();
    await language.set(
      languageRegion: configuration.languageRegion!,
    );
  }

  Future<void> set({required LanguageRegion languageRegion}) async {
    var string = await rootBundle.loadString(
        'assets/translations/${languageRegion.code}_${languageRegion.countryCode}.json');
    var asset = jsonDecode(string);
    this.INTERNET_ERROR = asset['INTERNET_ERROR']!;
    this.COLLECTION = asset['COLLECTION']!;
    this.NOW_PLAYING = asset['NOW_PLAYING']!;
    this.SETTING = asset['SETTING']!;
    this.OK = asset['OK']!;
    this.YES = asset['YES']!;
    this.NO = asset['NO']!;
    this.ALBUM = asset['ALBUM']!;
    this.TRACK = asset['TRACK']!;
    this.ARTIST = asset['ARTIST']!;
    this.THEME_MODE_LIGHT = asset['THEME_MODE_LIGHT']!;
    this.THEME_MODE_DARK = asset['THEME_MODE_DARK']!;
    this.OPTIONS = asset['OPTIONS']!;
    this.DELETE_TRACK = asset['DELETE_TRACK']!;
    this.SEARCH_HISTORY_SUBHEADER = asset['SEARCH_HISTORY_SUBHEADER']!;
    this.SEARCH_RESULT_LOADER_LABEL = asset['SEARCH_RESULT_LOADER_LABEL']!;
    this.COLLECTION_TOP_BODY_ALBUM_EMPTY =
        asset['COLLECTION_TOP_BODY_ALBUM_EMPTY']!;
    this.COLLECTION_TOP_SUBHEADER_ALBUM =
        asset['COLLECTION_TOP_SUBHEADER_ALBUM']!;
    this.COLLECTION_OTHER_SUBHEADER_ALBUM =
        asset['COLLECTION_OTHER_SUBHEADER_ALBUM']!;
    this.COLLECTION_TOP_SUBHEADER_TRACK =
        asset['COLLECTION_TOP_SUBHEADER_TRACK']!;
    this.COLLECTION_OTHER_SUBHEADER_TRACK =
        asset['COLLECTION_OTHER_SUBHEADER_TRACK']!;
    this.COLLECTION_TOP_SUBHEADER_ARTIST =
        asset['COLLECTION_TOP_SUBHEADER_ARTIST']!;
    this.COLLECTION_OTHER_SUBHEADER_ARTIST =
        asset['COLLECTION_OTHER_SUBHEADER_ARTIST']!;
    this.COLLECTION_ALBUM_TRACKS_SUBHEADER =
        asset['COLLECTION_ALBUM_TRACKS_SUBHEADER']!;
    this.COLLECTION_ALBUM_INFO_SUBHEADER =
        asset['COLLECTION_ALBUM_INFO_SUBHEADER']!;
    this.COLLECTION_ALBUM_ALBUM_DELETE_DIALOG_HEADER =
        asset['COLLECTION_ALBUM_ALBUM_DELETE_DIALOG_HEADER']!;
    this.COLLECTION_ALBUM_ALBUM_DELETE_DIALOG_BODY =
        asset['COLLECTION_ALBUM_ALBUM_DELETE_DIALOG_BODY']!;
    this.COLLECTION_ALBUM_TRACK_DELETE_DIALOG_HEADER =
        asset['COLLECTION_ALBUM_TRACK_DELETE_DIALOG_HEADER']!;
    this.COLLECTION_ALBUM_TRACK_DELETE_DIALOG_BODY =
        asset['COLLECTION_ALBUM_TRACK_DELETE_DIALOG_BODY']!;
    this.NOW_PLAYING_NEXT_TRACK = asset['NOW_PLAYING_NEXT_TRACK']!;
    this.NOW_PLAYING_PREVIOUS_TRACK = asset['NOW_PLAYING_PREVIOUS_TRACK']!;
    this.NOW_PLAYING_NOT_PLAYING_TITLE =
        asset['NOW_PLAYING_NOT_PLAYING_TITLE']!;
    this.SETTING_GITHUB = asset['SETTING_GITHUB']!;
    this.SETTING_STAR_GITHUB = asset['SETTING_STAR_GITHUB']!;
    this.SETTING_STARGAZERS_TITLE = asset['SETTING_STARGAZERS_TITLE']!;
    this.SETTING_STARGAZERS_SUBTITLE = asset['SETTING_STARGAZERS_SUBTITLE']!;
    this.SETTING_LANGUAGE_TITLE = asset['SETTING_LANGUAGE_TITLE']!;
    this.SETTING_LANGUAGE_SUBTITLE = asset['SETTING_LANGUAGE_SUBTITLE']!;
    this.SETTING_LANGUAGE_RESTART_DIALOG_TITLE =
        asset['SETTING_LANGUAGE_RESTART_DIALOG_TITLE']!;
    this.SETTING_LANGUAGE_RESTART_DIALOG_SUBTITLE =
        asset['SETTING_LANGUAGE_RESTART_DIALOG_SUBTITLE']!;
    this.SETTING_LANGUAGE_PROVIDERS_TITLE =
        asset['SETTING_LANGUAGE_PROVIDERS_TITLE']!;
    this.SETTING_LANGUAGE_PROVIDERS_SUBTITLE =
        asset['SETTING_LANGUAGE_PROVIDERS_SUBTITLE']!;
    this.SETTING_ACCENT_COLOR_TITLE = asset['SETTING_ACCENT_COLOR_TITLE']!;
    this.SETTING_ACCENT_COLOR_SUBTITLE =
        asset['SETTING_ACCENT_COLOR_SUBTITLE']!;
    this.SETTING_THEME_TITLE = asset['SETTING_THEME_TITLE']!;
    this.SETTING_THEME_SUBTITLE = asset['SETTING_THEME_SUBTITLE']!;
    this.ABOUT_TITLE = asset['ABOUT_TITLE']!;
    this.ABOUT_SUBTITLE = asset['ABOUT_SUBTITLE']!;
    this.NO_DOWNLOAD_UPDATE = asset['NO_DOWNLOAD_UPDATE']!;
    this.DOWNLOAD_UPDATE = asset['DOWNLOAD_UPDATE']!;
    this.SETTING_APP_VERSION_TITLE = asset['SETTING_APP_VERSION_TITLE']!;
    this.SETTING_APP_VERSION_SUBTITLE = asset['SETTING_APP_VERSION_SUBTITLE']!;
    this.SETTING_APP_VERSION_INSTALLED =
        asset['SETTING_APP_VERSION_INSTALLED']!;
    this.SETTING_APP_VERSION_LATEST = asset['SETTING_APP_VERSION_LATEST']!;
    this.MENU = asset['MENU']!;
    this.SEARCH_COLLECTION = asset['SEARCH_COLLECTION']!;
    this.SWITCH_THEME = asset['SWITCH_THEME']!;
    this.PLAY = asset['PLAY']!;
    this.PAUSE = asset['PAUSE']!;
    this.DELETE = asset['DELETE']!;
    this.SHARE = asset['SHARE']!;
    this.ADD_TO_PLAYLIST = asset['ADD_TO_PLAYLIST']!;
    this.SAVE_TO_DOWNLOADS = asset['SAVE_TO_DOWNLOADS']!;
    this.COLLECTION_SEARCH_WELCOME = asset['COLLECTION_SEARCH_WELCOME']!;
    this.COLLECTION_SEARCH_NO_RESULTS = asset['COLLECTION_SEARCH_NO_RESULTS']!;
    this.PLAYLISTS = asset['PLAYLISTS']!;
    this.PLAYLIST = asset['PLAYLIST']!;
    this.PLAYLISTS_SUBHEADER = asset['PLAYLISTS_SUBHEADER']!;
    this.PLAYLISTS_CREATE = asset['PLAYLISTS_CREATE']!;
    this.PLAYLISTS_TEXT_FIELD_LABEL = asset['PLAYLISTS_TEXT_FIELD_LABEL']!;
    this.PLAYLISTS_TEXT_FIELD_HINT = asset['PLAYLISTS_TEXT_FIELD_HINT']!;
    this.COLLECTION_ALBUM_PLAYLIST_DELETE_DIALOG_HEADER =
        asset['COLLECTION_ALBUM_PLAYLIST_DELETE_DIALOG_HEADER']!;
    this.COLLECTION_ALBUM_PLAYLIST_DELETE_DIALOG_BODY =
        asset['COLLECTION_ALBUM_PLAYLIST_DELETE_DIALOG_BODY']!;
    this.CANCEL = asset['CANCEL']!;
    this.PLAYLIST_ADD_DIALOG_TITLE = asset['PLAYLIST_ADD_DIALOG_TITLE']!;
    this.PLAYLIST_ADD_DIALOG_BODY = asset['PLAYLIST_ADD_DIALOG_BODY']!;
    this.PLAYLIST_TRACKS_SUBHEADER = asset['PLAYLIST_TRACKS_SUBHEADER']!;
    this.TRANSFERS = asset['TRANSFERS']!;
    this.SETTING_INDEXING_TITLE = asset['SETTING_INDEXING_TITLE']!;
    this.SETTING_INDEXING_SUBTITLE = asset['SETTING_INDEXING_SUBTITLE']!;
    this.SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR =
        asset['SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR']!;
    this.SETTING_INDEXING_DONE = asset['SETTING_INDEXING_DONE']!;
    this.SETTING_INDEXING_WARNING = asset['SETTING_INDEXING_WARNING']!;
    this.REFRESH = asset['REFRESH']!;
    this.SEARCH_NO_RECENT_SEARCHES = asset['SEARCH_NO_RECENT_SEARCHES']!;
    this.NO_INTERNET_TITLE = asset['NO_INTERNET_TITLE']!;
    this.NO_INTERNET_SUBTITLE = asset['NO_INTERNET_SUBTITLE']!;
    this.NO_COLLECTION_TITLE = asset['NO_COLLECTION_TITLE']!;
    this.NO_COLLECTION_SUBTITLE = asset['NO_COLLECTION_SUBTITLE']!;
    this.DISCORD = asset['DISCORD']!;
    this.EXIT_TITLE = asset['EXIT_TITLE']!;
    this.EXIT_SUBTITLE = asset['EXIT_SUBTITLE']!;
    this.A_TO_Z = asset['A_TO_Z']!;
    this.DATE_ADDED = asset['DATE_ADDED']!;
    this.SETTING_ACCENT_COLOR_AUTOMATIC =
        asset['SETTING_ACCENT_COLOR_AUTOMATIC']!;
    this.SETTING_MISCELLANEOUS_TITLE = asset['SETTING_MISCELLANEOUS_TITLE']!;
    this.SETTING_MISCELLANEOUS_SUBTITLE =
        asset['SETTING_MISCELLANEOUS_SUBTITLE']!;
    this.SETTING_MISCELLANEOUS_ENABLE_IOS_TITLE =
        asset['SETTING_MISCELLANEOUS_ENABLE_IOS_TITLE']!;
    this.SETTING_MISCELLANEOUS_ENABLE_IOS_SUBTITLE =
        asset['SETTING_MISCELLANEOUS_ENABLE_IOS_SUBTITLE']!;
    this.SELECTED_DIRECTORY = asset['SELECTED_DIRECTORY']!;
    this.LYRICS = asset['LYRICS']!;
    this.NOTIFICATION_LYRICS_TITLE = asset['NOTIFICATION_LYRICS_TITLE']!;
    this.NOTIFICATION_LYRICS_SUBTITLE = asset['NOTIFICATION_LYRICS_SUBTITLE']!;
    this.LYRICS_RETRIEVING = asset['LYRICS_RETRIEVING']!;
    this.LYRICS_NOT_FOUND = asset['LYRICS_NOT_FOUND']!;
    this.COMING_UP = asset['COMING_UP']!;
    this.ALBUM_SINGLE = asset['ALBUM_SINGLE']!;
    this.TRACK_SINGLE = asset['TRACK_SINGLE']!;
    this.ARTIST_SINGLE = asset['ARTIST_SINGLE']!;
    this.SEARCH = asset['SEARCH']!;
    this.ALBUMS_FROM_ARTIST = asset['ALBUMS_FROM_ARTIST']!;
    this.TRACKS_FROM_ARTIST = asset['TRACKS_FROM_ARTIST']!;
    this.REMOVE = asset['REMOVE']!;
    this.ADD_NEW_FOLDER = asset['ADD_NEW_FOLDER']!;
    this.ADD_TO_NOW_PLAYING = asset['ADD_TO_NOW_PLAYING']!;
    this.PLAY_NOW = asset['PLAY_NOW']!;
    this.COLLECTION_SEARCH_LABEL = asset['COLLECTION_SEARCH_LABEL']!;
    this.SELECTED_DIRECTORIES = asset['SELECTED_DIRECTORIES']!;
    this.ENABLE_ACRYLIC_BLUR = asset['ENABLE_ACRYLIC_BLUR']!;
    this.COLLECTION_INDEXING_LABEL = asset['COLLECTION_INDEXING_LABEL']!;
    this.RECOMMENDATIONS = asset['RECOMMENDATIONS']!;
    this.YOUTUBE_WELCOME = asset['YOUTUBE_WELCOME']!;
    this.YOUTUBE_NO_RESULTS = asset['YOUTUBE_NO_RESULTS']!;
    this.YOUTUBE_INTERNET_ERROR = asset['YOUTUBE_INTERNET_ERROR']!;
    this.RETRIEVING_INFO = asset['RETRIEVING_INFO']!;
    this.RETRIEVING_LINK = asset['RETRIEVING_LINK']!;
    this.STARTING_PLAYBACK = asset['STARTING_PLAYBACK']!;
    this.BUFFERING = asset['BUFFERING']!;
    this.WARNING = asset['WARNING']!;
    this.LAST_COLLECTION_DIRECTORY_REMOVED =
        asset['LAST_COLLECTION_DIRECTORY_REMOVED']!;
    this.ENABLE_125_SCALING = asset['ENABLE_125_SCALING']!;
    this.YEAR = asset['YEAR']!;
    configuration.save(languageRegion: languageRegion);
    this.current = languageRegion;
    this.notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}

/// Late initialized [Language] object instance.
late Language language;
