/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
// ignore_for_file: non_constant_identifier_names
class Strings {
  late String ABOUT_SUBTITLE;
  late String ABOUT_TITLE;
  late String ADD_NEW_FOLDER;
  late String ADD_TO_NOW_PLAYING;
  late String ADD_TO_PLAYLIST;
  late String ALBUM;
  late String ALBUMS_FROM_ARTIST;
  late String ALBUM_SINGLE;
  late String ARTIST;
  late String ARTIST_SINGLE;
  late String ASCENDING;
  late String AUTOMATICALLY_ADD_OTHER_SONGS_TO_NOW_PLAYING;
  late String A_TO_Z;
  late String BUFFERING;
  late String CANCEL;
  late String COLLECTION;
  late String COLLECTION_ALBUM_DELETE_DIALOG_BODY;
  late String COLLECTION_ALBUM_DELETE_DIALOG_HEADER;
  late String COLLECTION_INDEXING_HINT;
  late String COLLECTION_INDEXING_LABEL;
  late String COLLECTION_INFO_SUBHEADER;
  late String COLLECTION_OTHER_SUBHEADER_ALBUM;
  late String COLLECTION_OTHER_SUBHEADER_ARTIST;
  late String COLLECTION_OTHER_SUBHEADER_TRACK;
  late String COLLECTION_PLAYLIST_DELETE_DIALOG_BODY;
  late String COLLECTION_PLAYLIST_DELETE_DIALOG_HEADER;
  late String COLLECTION_SEARCH_LABEL;
  late String COLLECTION_SEARCH_NO_RESULTS_SUBTITLE;
  late String COLLECTION_SEARCH_NO_RESULTS_TITLE;
  late String COLLECTION_SEARCH_WELCOME;
  late String COLLECTION_TOP_BODY_ALBUM_EMPTY;
  late String COLLECTION_TOP_SUBHEADER_ALBUM;
  late String COLLECTION_TOP_SUBHEADER_ARTIST;
  late String COLLECTION_TOP_SUBHEADER_TRACK;
  late String COLLECTION_TRACKS_SUBHEADER;
  late String COLLECTION_TRACK_DELETE_DIALOG_BODY;
  late String COLLECTION_TRACK_DELETE_DIALOG_HEADER;
  late String COMING_UP;
  late String CREATE;
  late String CREATE_NEW_PLAYLIST;
  late String CREATE_PLAYLIST_SUBHEADER;
  late String DATE_ADDED;
  late String DELETE;
  late String DELETE_TRACK;
  late String DESCENDING;
  late String DISCORD;
  late String DOWNLOAD_UPDATE;
  late String ENABLE_125_SCALING;
  late String ENABLE_ACRYLIC_BLUR;
  late String EXIT_NOW_PLAYING;
  late String EXIT_SUBTITLE;
  late String EXIT_TITLE;
  late String GO_TO_SETTINGS;
  late String INTERNET_ERROR;
  late String KNOW_MORE;
  late String LAST_COLLECTION_DIRECTORY_REMOVED;
  late String LISTENING_TO_MUSIC;
  late String LYRICS;
  late String LYRICS_NOT_FOUND;
  late String LYRICS_RETRIEVING;
  late String MENU;
  late String MUTE;
  late String M_TRACKS_AND_N_ALBUMS;
  late String NEXT;
  late String NO;
  late String NOTIFICATION_LYRICS_SUBTITLE;
  late String NOTIFICATION_LYRICS_TITLE;
  late String NOW_PLAYING;
  late String NOW_PLAYING_NEXT_TRACK;
  late String NOW_PLAYING_NOT_PLAYING_TITLE;
  late String NOW_PLAYING_PREVIOUS_TRACK;
  late String NO_COLLECTION_SUBTITLE;
  late String NO_COLLECTION_TITLE;
  late String NO_DOWNLOAD_UPDATE;
  late String NO_INTERNET_SUBTITLE;
  late String NO_INTERNET_TITLE;
  late String NO_PLAYLISTS_FOUND;
  late String N_TRACKS;
  late String OK;
  late String OPTIONS;
  late String ORDER;
  late String PAUSE;
  late String PLAY;
  late String PLAYLIST;
  late String PLAYLISTS_CREATE;
  late String PLAYLISTS_SUBHEADER;
  late String PLAYLISTS_TEXT_FIELD_HINT;
  late String PLAYLISTS_TEXT_FIELD_LABEL;
  late String PLAYLIST_ADD_DIALOG_BODY;
  late String PLAYLIST_ADD_DIALOG_TITLE;
  late String PLAYLIST_TRACKS_SUBHEADER;
  late String PLAY_NOW;
  late String PREVIOUS;
  late String RECOMMENDATIONS;
  late String REFRESH;
  late String REINDEX;
  late String REMOVE;
  late String REMOVE_FROM_PLAYLIST;
  late String REPEAT;
  late String RESULTS_FOR_QUERY;
  late String RETRIEVING_INFO;
  late String RETRIEVING_LINK;
  late String SAVE_TO_DOWNLOADS;
  late String SEARCH;
  late String SEARCH_COLLECTION;
  late String SEARCH_HISTORY_SUBHEADER;
  late String SEARCH_NO_RECENT_SEARCHES;
  late String SEARCH_RESULT_LOADER_LABEL;
  late String SEARCH_WELCOME;
  late String SEE_ALL;
  late String SELECTED_DIRECTORIES;
  late String SELECTED_DIRECTORY;
  late String SETTING;
  late String SETTING_ACCENT_COLOR_AUTOMATIC;
  late String SETTING_ACCENT_COLOR_SUBTITLE;
  late String SETTING_ACCENT_COLOR_TITLE;
  late String SETTING_APP_VERSION_INSTALLED;
  late String SETTING_APP_VERSION_LATEST;
  late String SETTING_APP_VERSION_SUBTITLE;
  late String SETTING_APP_VERSION_TITLE;
  late String SETTING_GITHUB;
  late String SETTING_INDEXING_DONE;
  late String SETTING_INDEXING_LINEAR_PROGRESS_INDICATOR;
  late String SETTING_INDEXING_SUBTITLE;
  late String SETTING_INDEXING_TITLE;
  late String SETTING_INDEXING_WARNING;
  late String SETTING_LANGUAGE_PROVIDERS_SUBTITLE;
  late String SETTING_LANGUAGE_PROVIDERS_TITLE;
  late String SETTING_LANGUAGE_RESTART_DIALOG_SUBTITLE;
  late String SETTING_LANGUAGE_RESTART_DIALOG_TITLE;
  late String SETTING_LANGUAGE_SUBTITLE;
  late String SETTING_LANGUAGE_TITLE;
  late String SETTING_MISCELLANEOUS_ENABLE_IOS_SUBTITLE;
  late String SETTING_MISCELLANEOUS_ENABLE_IOS_TITLE;
  late String SETTING_MISCELLANEOUS_SUBTITLE;
  late String SETTING_MISCELLANEOUS_TITLE;
  late String SETTING_STARGAZERS_SUBTITLE;
  late String SETTING_STARGAZERS_TITLE;
  late String SETTING_STAR_GITHUB;
  late String SETTING_THEME_SUBTITLE;
  late String SETTING_THEME_TITLE;
  late String SHARE;
  late String SHOW_ALBUM;
  late String SHOW_NOW_PLAYING_AFTER_PLAYING;
  late String SHOW_TRACK_PROGRESS_ON_TASKBAR;
  late String SHUFFLE;
  late String SORT;
  late String SORT_BY;
  late String SPEED;
  late String STARTING_PLAYBACK;
  late String SWITCH_THEME;
  late String THEME_MODE_DARK;
  late String THEME_MODE_LIGHT;
  late String THEME_MODE_SYSTEM;
  late String TRACK;
  late String TRACKS_FROM_ARTIST;
  late String TRACK_SINGLE;
  late String TRANSFERS;
  late String UNMUTE;
  late String WARNING;
  late String YEAR;
  late String YES;
  late String YOUTUBE;
  late String YOUTUBE_INTERNET_ERROR;
  late String YOUTUBE_NO_RESULTS;
  late String YOUTUBE_WELCOME;
  late String YOUTUBE_WELCOME_SUBTITLE;
  late String YOUTUBE_WELCOME_TITLE;
}
