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
    countryCode: 'Se',
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
  static const mg = LanguageRegion(
    code: 'mg',
    countryCode: 'MG',
    name: 'Malagasy',
    country: 'Madagascar',
    translator: 'Dominick',
    github: 'https://github.com/c3k4ah',
  );

  static const values = <LanguageRegion?>[
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
    mg
  ];

  int get index => values.indexOf(this);
}

class Language extends Strings with ChangeNotifier {
  LanguageRegion? current;

  static Language? get() => language;

  static Future<void> initialize(
      {required LanguageRegion languageRegion}) async {
    language = Language();
    await language!.set(languageRegion: languageRegion);
  }

  Future<void> set({required LanguageRegion languageRegion}) async {
    var string = await rootBundle.loadString(
        'assets/translations/${languageRegion.code}_${languageRegion.countryCode}.json');
    var asset = jsonDecode(string);
    this.STRING_INTERNET_ERROR = asset['STRING_INTERNET_ERROR']!;
    this.STRING_SEARCH_HEADER = asset['STRING_SEARCH_HEADER']!;
    this.STRING_SEARCH_MODE_SUBHEADER = asset['STRING_SEARCH_MODE_SUBHEADER']!;
    this.STRING_COLLECTION = asset['STRING_COLLECTION']!;
    this.STRING_NOW_PLAYING = asset['STRING_NOW_PLAYING']!;
    this.STRING_SETTING = asset['STRING_SETTING']!;
    this.STRING_OK = asset['STRING_OK']!;
    this.STRING_YES = asset['STRING_YES']!;
    this.STRING_NO = asset['STRING_NO']!;
    this.STRING_ALBUM = asset['STRING_ALBUM']!;
    this.STRING_TRACK = asset['STRING_TRACK']!;
    this.STRING_TOP_TRACKS = asset['STRING_TOP_TRACKS']!;
    this.STRING_ARTIST = asset['STRING_ARTIST']!;
    this.STRING_SAVED = asset['STRING_SAVED']!;
    this.STRING_THEME_MODE_LIGHT = asset['STRING_THEME_MODE_LIGHT']!;
    this.STRING_THEME_MODE_DARK = asset['STRING_THEME_MODE_DARK']!;
    this.STRING_THEME_MODE_SYSTEM = asset['STRING_THEME_MODE_SYSTEM']!;
    this.STRING_OPTIONS = asset['STRING_OPTIONS']!;
    this.STRING_FOLLOWERS = asset['STRING_FOLLOWERS']!;
    this.STRING_PLAYS = asset['STRING_PLAYS']!;
    this.STRING_EXPORT_TRACK = asset['STRING_EXPORT_TRACK']!;
    this.STRING_DELETE_TRACK = asset['STRING_DELETE_TRACK']!;
    this.STRING_SEARCH_MODE_SUBTITLE_ALBUM =
        asset['STRING_SEARCH_MODE_SUBTITLE_ALBUM']!;
    this.STRING_SEARCH_MODE_SUBTITLE_TRACK =
        asset['STRING_SEARCH_MODE_SUBTITLE_TRACK']!;
    this.STRING_SEARCH_MODE_SUBTITLE_ARTIST =
        asset['STRING_SEARCH_MODE_SUBTITLE_ARTIST']!;
    this.STRING_SEARCH_HISTORY_SUBHEADER =
        asset['STRING_SEARCH_HISTORY_SUBHEADER']!;
    this.STRING_SEARCH_RESULT_LOADER_LABEL =
        asset['STRING_SEARCH_RESULT_LOADER_LABEL']!;
    this.STRING_SEARCH_RESULT_TOP_SUBHEADER_ALBUM =
        asset['STRING_SEARCH_RESULT_TOP_SUBHEADER_ALBUM']!;
    this.STRING_SEARCH_RESULT_TOP_SUBHEADER_TRACK =
        asset['STRING_SEARCH_RESULT_TOP_SUBHEADER_TRACK']!;
    this.STRING_SEARCH_RESULT_TOP_SUBHEADER_ARTIST =
        asset['STRING_SEARCH_RESULT_TOP_SUBHEADER_ARTIST']!;
    this.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_ALBUM =
        asset['STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_ALBUM']!;
    this.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_TRACK =
        asset['STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_TRACK']!;
    this.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_ARTIST =
        asset['STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_0_ARTIST']!;
    this.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_ALBUM =
        asset['STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_ALBUM']!;
    this.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_TRACK =
        asset['STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_TRACK']!;
    this.STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_ARTIST =
        asset['STRING_SEARCH_RESULT_TOP_BUTTON_LABEL_1_ARTIST']!;
    this.STRING_SEARCH_RESULT_OTHER_SUBHEADER_ALBUM =
        asset['STRING_SEARCH_RESULT_OTHER_SUBHEADER_ALBUM']!;
    this.STRING_SEARCH_RESULT_OTHER_SUBHEADER_TRACK =
        asset['STRING_SEARCH_RESULT_OTHER_SUBHEADER_TRACK']!;
    this.STRING_SEARCH_RESULT_OTHER_SUBHEADER_ARTIST =
        asset['STRING_SEARCH_RESULT_OTHER_SUBHEADER_ARTIST']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_BACK_TITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_BACK_TITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_BACK_SUBTITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_BACK_SUBTITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_TITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_TITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_SUBTITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_ERROR_NETWORK_SUBTITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_TITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_TITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_SUBTITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_ERROR_RATE_SUBTITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_DOUBLE_TITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_DOUBLE_TITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_DOUBLE_SUBTITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_DOUBLE_SUBTITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_ALREADY_SAVED_TITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_ALREADY_SAVED_TITLE']!;
    this.STRING_ALBUM_VIEW_DOWNLOAD_ALREADY_SAVED_SUBTITLE =
        asset['STRING_ALBUM_VIEW_DOWNLOAD_ALREADY_SAVED_SUBTITLE']!;
    this.STRING_ALBUM_VIEW_LOADER_LABEL =
        asset['STRING_ALBUM_VIEW_LOADER_LABEL']!;
    this.STRING_ALBUM_VIEW_TRACKS_SUBHEADER =
        asset['STRING_ALBUM_VIEW_TRACKS_SUBHEADER']!;
    this.STRING_ALBUM_VIEW_INFO_SUBHEADER =
        asset['STRING_ALBUM_VIEW_INFO_SUBHEADER']!;
    this.STRING_LOCAL_TOP_BODY_ALBUM_EMPTY =
        asset['STRING_LOCAL_TOP_BODY_ALBUM_EMPTY']!;
    this.STRING_LOCAL_TOP_SUBHEADER_ALBUM =
        asset['STRING_LOCAL_TOP_SUBHEADER_ALBUM']!;
    this.STRING_LOCAL_OTHER_SUBHEADER_ALBUM =
        asset['STRING_LOCAL_OTHER_SUBHEADER_ALBUM']!;
    this.STRING_LOCAL_TOP_SUBHEADER_TRACK =
        asset['STRING_LOCAL_TOP_SUBHEADER_TRACK']!;
    this.STRING_LOCAL_OTHER_SUBHEADER_TRACK =
        asset['STRING_LOCAL_OTHER_SUBHEADER_TRACK']!;
    this.STRING_LOCAL_TOP_SUBHEADER_ARTIST =
        asset['STRING_LOCAL_TOP_SUBHEADER_ARTIST']!;
    this.STRING_LOCAL_OTHER_SUBHEADER_ARTIST =
        asset['STRING_LOCAL_OTHER_SUBHEADER_ARTIST']!;
    this.STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER =
        asset['STRING_LOCAL_ALBUM_VIEW_TRACKS_SUBHEADER']!;
    this.STRING_LOCAL_ALBUM_VIEW_INFO_SUBHEADER =
        asset['STRING_LOCAL_ALBUM_VIEW_INFO_SUBHEADER']!;
    this.STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_HEADER =
        asset['STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_HEADER']!;
    this.STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_BODY =
        asset['STRING_LOCAL_ALBUM_VIEW_ALBUM_DELETE_DIALOG_BODY']!;
    this.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER =
        asset['STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER']!;
    this.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY =
        asset['STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY']!;
    this.STRING_NOW_PLAYING_NEXT_TRACK =
        asset['STRING_NOW_PLAYING_NEXT_TRACK']!;
    this.STRING_NOW_PLAYING_PREVIOUS_TRACK =
        asset['STRING_NOW_PLAYING_PREVIOUS_TRACK']!;
    this.STRING_NOW_PLAYING_NOT_PLAYING_TITLE =
        asset['STRING_NOW_PLAYING_NOT_PLAYING_TITLE']!;
    this.STRING_NOW_PLAYING_NOT_PLAYING_SUBTITLE =
        asset['STRING_NOW_PLAYING_NOT_PLAYING_SUBTITLE']!;
    this.STRING_NOW_PLAYING_NOT_PLAYING_HEADER =
        asset['STRING_NOW_PLAYING_NOT_PLAYING_HEADER']!;
    this.STRING_SETTING_GITHUB = asset['STRING_SETTING_GITHUB']!;
    this.STRING_SETTING_STAR_GITHUB = asset['STRING_SETTING_STAR_GITHUB']!;
    this.STRING_SETTING_STARGAZERS_TITLE =
        asset['STRING_SETTING_STARGAZERS_TITLE']!;
    this.STRING_SETTING_STARGAZERS_SUBTITLE =
        asset['STRING_SETTING_STARGAZERS_SUBTITLE']!;
    this.STRING_SETTING_LANGUAGE_TITLE =
        asset['STRING_SETTING_LANGUAGE_TITLE']!;
    this.STRING_SETTING_LANGUAGE_SUBTITLE =
        asset['STRING_SETTING_LANGUAGE_SUBTITLE']!;
    this.STRING_SETTING_LANGUAGE_RESTART_DIALOG_TITLE =
        asset['STRING_SETTING_LANGUAGE_RESTART_DIALOG_TITLE']!;
    this.STRING_SETTING_LANGUAGE_RESTART_DIALOG_SUBTITLE =
        asset['STRING_SETTING_LANGUAGE_RESTART_DIALOG_SUBTITLE']!;
    this.STRING_SETTING_SERVER_CHANGE_TITLE =
        asset['STRING_SETTING_SERVER_CHANGE_TITLE']!;
    this.STRING_SETTING_SERVER_CHANGE_SUBTITLE =
        asset['STRING_SETTING_SERVER_CHANGE_SUBTITLE']!;
    this.STRING_SETTING_SERVER_CHANGE_SERVER_HINT =
        asset['STRING_SETTING_SERVER_CHANGE_SERVER_HINT']!;
    this.STRING_SETTING_SERVER_CHANGE_SERVER_LABEL =
        asset['STRING_SETTING_SERVER_CHANGE_SERVER_LABEL']!;
    this.STRING_SETTING_SERVER_CHANGE_ERROR_INVALID =
        asset['STRING_SETTING_SERVER_CHANGE_ERROR_INVALID']!;
    this.STRING_SETTING_SERVER_CHANGE_ERROR_NETWORK =
        asset['STRING_SETTING_SERVER_CHANGE_ERROR_NETWORK']!;
    this.STRING_SETTING_SERVER_CHANGE_DONE =
        asset['STRING_SETTING_SERVER_CHANGE_DONE']!;
    this.STRING_SETTING_SERVER_CHANGE_CHANGING =
        asset['STRING_SETTING_SERVER_CHANGE_CHANGING']!;
    this.STRING_SETTING_LANGUAGE_PROVIDERS_TITLE =
        asset['STRING_SETTING_LANGUAGE_PROVIDERS_TITLE']!;
    this.STRING_SETTING_LANGUAGE_PROVIDERS_SUBTITLE =
        asset['STRING_SETTING_LANGUAGE_PROVIDERS_SUBTITLE']!;
    this.STRING_SETTING_ACCENT_COLOR_TITLE =
        asset['STRING_SETTING_ACCENT_COLOR_TITLE']!;
    this.STRING_SETTING_ACCENT_COLOR_SUBTITLE =
        asset['STRING_SETTING_ACCENT_COLOR_SUBTITLE']!;
    this.STRING_SETTING_THEME_TITLE = asset['STRING_SETTING_THEME_TITLE']!;
    this.STRING_SETTING_THEME_SUBTITLE =
        asset['STRING_SETTING_THEME_SUBTITLE']!;
    this.STRING_ABOUT_TITLE = asset['STRING_ABOUT_TITLE']!;
    this.STRING_ABOUT_SUBTITLE = asset['STRING_ABOUT_SUBTITLE']!;
    this.STRING_NO_DOWNLOAD_UPDATE = asset['STRING_NO_DOWNLOAD_UPDATE']!;
    this.STRING_DOWNLOAD_UPDATE = asset['STRING_DOWNLOAD_UPDATE']!;
    this.STRING_SETTING_APP_VERSION_TITLE =
        asset['STRING_SETTING_APP_VERSION_TITLE']!;
    this.STRING_SETTING_APP_VERSION_SUBTITLE =
        asset['STRING_SETTING_APP_VERSION_SUBTITLE']!;
    this.STRING_SETTING_APP_VERSION_INSTALLED =
        asset['STRING_SETTING_APP_VERSION_INSTALLED']!;
    this.STRING_SETTING_APP_VERSION_LATEST =
        asset['STRING_SETTING_APP_VERSION_LATEST']!;
    this.STRING_MENU = asset['STRING_MENU']!;
    this.STRING_SEARCH_COLLECTION = asset['STRING_SEARCH_COLLECTION']!;
    this.STRING_SWITCH_THEME = asset['STRING_SWITCH_THEME']!;
    this.STRING_PLAY = asset['STRING_PLAY']!;
    this.STRING_PAUSE = asset['STRING_PAUSE']!;
    this.STRING_DELETE = asset['STRING_DELETE']!;
    this.STRING_SHARE = asset['STRING_SHARE']!;
    this.STRING_ADD_TO_PLAYLIST = asset['STRING_ADD_TO_PLAYLIST']!;
    this.STRING_SAVE_TO_DOWNLOADS = asset['STRING_SAVE_TO_DOWNLOADS']!;
    this.STRING_LOCAL_SEARCH_WELCOME = asset['STRING_LOCAL_SEARCH_WELCOME']!;
    this.STRING_LOCAL_SEARCH_NO_RESULTS =
        asset['STRING_LOCAL_SEARCH_NO_RESULTS']!;
    this.STRING_PLAYLISTS = asset['STRING_PLAYLISTS']!;
    this.STRING_PLAYLIST = asset['STRING_PLAYLIST']!;
    this.STRING_PLAYLISTS_SUBHEADER = asset['STRING_PLAYLISTS_SUBHEADER']!;
    this.STRING_PLAYLISTS_CREATE = asset['STRING_PLAYLISTS_CREATE']!;
    this.STRING_PLAYLISTS_TEXT_FIELD_LABEL =
        asset['STRING_PLAYLISTS_TEXT_FIELD_LABEL']!;
    this.STRING_PLAYLISTS_TEXT_FIELD_HINT =
        asset['STRING_PLAYLISTS_TEXT_FIELD_HINT']!;
    this.STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_HEADER =
        asset['STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_HEADER']!;
    this.STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_BODY =
        asset['STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_BODY']!;
    this.STRING_CANCEL = asset['STRING_CANCEL']!;
    this.STRING_PLAYLIST_ADD_DIALOG_TITLE =
        asset['STRING_PLAYLIST_ADD_DIALOG_TITLE']!;
    this.STRING_PLAYLIST_ADD_DIALOG_BODY =
        asset['STRING_PLAYLIST_ADD_DIALOG_BODY']!;
    this.STRING_PLAYLIST_TRACKS_SUBHEADER =
        asset['STRING_PLAYLIST_TRACKS_SUBHEADER']!;
    this.STRING_TRANSFERS = asset['STRING_TRANSFERS']!;
    this.STRING_SETTING_INDEXING_TITLE =
        asset['STRING_SETTING_INDEXING_TITLE']!;
    this.STRING_SETTING_INDEXING_SUBTITLE =
        asset['STRING_SETTING_INDEXING_SUBTITLE']!;
    this.STRING_SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR =
        asset['STRING_SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR']!;
    this.STRING_SETTING_INDEXING_DONE = asset['STRING_SETTING_INDEXING_DONE']!;
    this.STRING_SETTING_INDEXING_WARNING =
        asset['STRING_SETTING_INDEXING_WARNING']!;
    this.STRING_REFRESH = asset['STRING_REFRESH']!;
    this.STRING_SEARCH_NO_RECENT_SEARCHES =
        asset['STRING_SEARCH_NO_RECENT_SEARCHES']!;
    this.STRING_NO_INTERNET_TITLE = asset['STRING_NO_INTERNET_TITLE']!;
    this.STRING_NO_INTERNET_SUBTITLE = asset['STRING_NO_INTERNET_SUBTITLE']!;
    this.STRING_NO_COLLECTION_TITLE = asset['STRING_NO_COLLECTION_TITLE']!;
    this.STRING_NO_COLLECTION_SUBTITLE =
        asset['STRING_NO_COLLECTION_SUBTITLE']!;
    this.STRING_DOWNLOAD_COMPLETED = asset['STRING_DOWNLOAD_COMPLETED']!;
    this.STRING_DOWNLOAD_FAILED = asset['STRING_DOWNLOAD_FAILED']!;
    this.STRING_DISCORD = asset['STRING_DISCORD']!;
    this.STRING_EXIT_TITLE = asset['STRING_EXIT_TITLE']!;
    this.STRING_EXIT_SUBTITLE = asset['STRING_EXIT_SUBTITLE']!;
    this.STRING_A_TO_Z = asset['STRING_A_TO_Z']!;
    this.STRING_DATE_ADDED = asset['STRING_DATE_ADDED']!;
    this.STRING_SETTING_ACCENT_COLOR_AUTOMATIC =
        asset['STRING_SETTING_ACCENT_COLOR_AUTOMATIC']!;
    this.STRING_SETTING_MISCELLANEOUS_TITLE =
        asset['STRING_SETTING_MISCELLANEOUS_TITLE']!;
    this.STRING_SETTING_MISCELLANEOUS_SUBTITLE =
        asset['STRING_SETTING_MISCELLANEOUS_SUBTITLE']!;
    this.STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_TITLE =
        asset['STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_TITLE']!;
    this.STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_SUBTITLE =
        asset['STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_SUBTITLE']!;
    this.STRING_SELECTED_DIRECTORY = asset['STRING_SELECTED_DIRECTORY']!;
    this.STRING_LYRICS = asset['STRING_LYRICS']!;
    this.STRING_NOTIFICATION_LYRICS_TITLE =
        asset['STRING_NOTIFICATION_LYRICS_TITLE']!;
    this.STRING_NOTIFICATION_LYRICS_SUBTITLE =
        asset['STRING_NOTIFICATION_LYRICS_SUBTITLE']!;
    this.STRING_LYRICS_RETRIEVING = asset['STRING_LYRICS_RETRIEVING']!;
    this.STRING_LYRICS_NOT_FOUND = asset['STRING_LYRICS_NOT_FOUND']!;
    this.STRING_COMING_UP = asset['STRING_COMING_UP']!;
    this.STRING_ALBUM_SINGLE = asset['STRING_ALBUM_SINGLE']!;
    this.STRING_TRACK_SINGLE = asset['STRING_TRACK_SINGLE']!;
    this.STRING_ARTIST_SINGLE = asset['STRING_ARTIST_SINGLE']!;
    this.STRING_SEARCH = asset['STRING_SEARCH']!;
    this.STRING_ALBUMS_FROM_ARTIST = asset['STRING_ALBUMS_FROM_ARTIST']!;
    this.STRING_TRACKS_FROM_ARTIST = asset['STRING_TRACKS_FROM_ARTIST']!;
    this.STRING_REMOVE = asset['STRING_REMOVE']!;
    this.STRING_ADD_NEW_FOLDER = asset['STRING_ADD_NEW_FOLDER']!;
    this.STRING_ADD_TO_NOW_PLAYING = asset['STRING_ADD_TO_NOW_PLAYING']!;
    this.STRING_PLAY_NOW = asset['STRING_PLAY_NOW']!;
    this.STRING_COLLECTION_SEARCH_LABEL =
        asset['STRING_COLLECTION_SEARCH_LABEL']!;
    this.STRING_SELECTED_DIRECTORIES = asset['STRING_SELECTED_DIRECTORIES']!;
    this.STRING_ENABLE_ACRYLIC_BLUR = asset['STRING_ENABLE_ACRYLIC_BLUR']!;
    this.STRING_COLLECTION_INDEXING_LABEL =
        asset['STRING_COLLECTION_INDEXING_LABEL']!;
    this.STRING_RECOMMENDATIONS = asset['STRING_RECOMMENDATIONS']!;
    this.STRING_YOUTUBE_WELCOME = asset['STRING_YOUTUBE_WELCOME']!;
    this.STRING_YOUTUBE_NO_RESULTS = asset['STRING_YOUTUBE_NO_RESULTS']!;
    this.STRING_YOUTUBE_INTERNET_ERROR =
        asset['STRING_YOUTUBE_INTERNET_ERROR']!;
    this.STRING_RETRIEVING_INFO = asset['STRING_RETRIEVING_INFO']!;
    this.STRING_RETRIEVING_LINK = asset['STRING_RETRIEVING_LINK']!;
    this.STRING_STARTING_PLAYBACK = asset['STRING_STARTING_PLAYBACK']!;
    this.STRING_BUFFERING = asset['STRING_BUFFERING']!;
    this.STRING_WARNING = asset['STRING_WARNING']!;
    this.STRING_LAST_COLLECTION_DIRECTORY_REMOVED =
        asset['STRING_LAST_COLLECTION_DIRECTORY_REMOVED']!;
    this.STRING_ENABLE_125_SCALING = asset['STRING_ENABLE_125_SCALING']!;
    this.STRING_REPORT = asset['STRING_REPORT']!;
    configuration.save(languageRegion: languageRegion);
    this.current = languageRegion;
    this.notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}

/// Late initialized [Language] ojbect instance.
Language? language;
