// AUTO GENERATED FILE, DO NOT EDIT.

part of 'configuration.dart';

class ConfigurationBase {

  final Directory directory;
  final Database db;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  ConfigurationBase({required this.directory, required this.db});

  bool get audioFormatDisplay => _audioFormatDisplay!;
  bool get desktopNowPlayingBarColorPalette => _desktopNowPlayingBarColorPalette!;
  int get desktopNowPlayingScreenCarousel => _desktopNowPlayingScreenCarousel!;
  bool get desktopNowPlayingScreenLyrics => _desktopNowPlayingScreenLyrics!;
  bool get discordRpc => _discordRpc!;
  LocalizationData get localization => _localization!;
  bool get lrcFromDirectory => _lrcFromDirectory!;
  double get lyricsViewFocusedFontSize => _lyricsViewFocusedFontSize!;
  double get lyricsViewFocusedLineHeight => _lyricsViewFocusedLineHeight!;
  TextAlign get lyricsViewTextAlign => _lyricsViewTextAlign!;
  double get lyricsViewUnfocusedFontSize => _lyricsViewUnfocusedFontSize!;
  double get lyricsViewUnfocusedLineHeight => _lyricsViewUnfocusedLineHeight!;
  bool get mediaLibraryAddTracksToPlaylist => _mediaLibraryAddTracksToPlaylist!;
  Set<AlbumGroupingParameter> get mediaLibraryAlbumGroupingParameters => _mediaLibraryAlbumGroupingParameters!;
  bool get mediaLibraryAlbumSortAscending => _mediaLibraryAlbumSortAscending!;
  AlbumSortType get mediaLibraryAlbumSortType => _mediaLibraryAlbumSortType!;
  bool get mediaLibraryArtistSortAscending => _mediaLibraryArtistSortAscending!;
  ArtistSortType get mediaLibraryArtistSortType => _mediaLibraryArtistSortType!;
  bool get mediaLibraryCoverFallback => _mediaLibraryCoverFallback!;
  Map<String, double> get mediaLibraryDesktopTracksScreenColumnWidths => _mediaLibraryDesktopTracksScreenColumnWidths!;
  Set<Directory> get mediaLibraryDirectories => _mediaLibraryDirectories!;
  bool get mediaLibraryGenreSortAscending => _mediaLibraryGenreSortAscending!;
  GenreSortType get mediaLibraryGenreSortType => _mediaLibraryGenreSortType!;
  int get mediaLibraryMinimumFileSize => _mediaLibraryMinimumFileSize!;
  String get mediaLibraryPath => _mediaLibraryPath!;
  bool get mediaLibraryRefreshOnLaunch => _mediaLibraryRefreshOnLaunch!;
  bool get mediaLibraryTrackSortAscending => _mediaLibraryTrackSortAscending!;
  TrackSortType get mediaLibraryTrackSortType => _mediaLibraryTrackSortType!;
  int get mobileAlbumGridSpan => _mobileAlbumGridSpan!;
  int get mobileArtistGridSpan => _mobileArtistGridSpan!;
  int get mobileGenreGridSpan => _mobileGenreGridSpan!;
  bool get mobileNowPlayingRipple => _mobileNowPlayingRipple!;
  bool get mobileNowPlayingSlider => _mobileNowPlayingSlider!;
  Map<String, String> get mpvOptions => _mpvOptions!;
  String get mpvPath => _mpvPath!;
  bool get notificationLyrics => _notificationLyrics!;
  PlaybackState get playbackState => _playbackState!;
  AnimationDuration get themeAnimationDuration => _themeAnimationDuration!;
  int get themeMaterialStandard => _themeMaterialStandard!;
  ThemeMode get themeMode => _themeMode!;
  bool get themeSystemColorScheme => _themeSystemColorScheme!;
  bool get windowsTaskbarProgress => _windowsTaskbarProgress!;

  Future<void> set({
    bool? audioFormatDisplay,
    bool? desktopNowPlayingBarColorPalette,
    int? desktopNowPlayingScreenCarousel,
    bool? desktopNowPlayingScreenLyrics,
    bool? discordRpc,
    LocalizationData? localization,
    bool? lrcFromDirectory,
    double? lyricsViewFocusedFontSize,
    double? lyricsViewFocusedLineHeight,
    TextAlign? lyricsViewTextAlign,
    double? lyricsViewUnfocusedFontSize,
    double? lyricsViewUnfocusedLineHeight,
    bool? mediaLibraryAddTracksToPlaylist,
    Set<AlbumGroupingParameter>? mediaLibraryAlbumGroupingParameters,
    bool? mediaLibraryAlbumSortAscending,
    AlbumSortType? mediaLibraryAlbumSortType,
    bool? mediaLibraryArtistSortAscending,
    ArtistSortType? mediaLibraryArtistSortType,
    bool? mediaLibraryCoverFallback,
    Map<String, double>? mediaLibraryDesktopTracksScreenColumnWidths,
    Set<Directory>? mediaLibraryDirectories,
    bool? mediaLibraryGenreSortAscending,
    GenreSortType? mediaLibraryGenreSortType,
    int? mediaLibraryMinimumFileSize,
    String? mediaLibraryPath,
    bool? mediaLibraryRefreshOnLaunch,
    bool? mediaLibraryTrackSortAscending,
    TrackSortType? mediaLibraryTrackSortType,
    int? mobileAlbumGridSpan,
    int? mobileArtistGridSpan,
    int? mobileGenreGridSpan,
    bool? mobileNowPlayingRipple,
    bool? mobileNowPlayingSlider,
    Map<String, String>? mpvOptions,
    String? mpvPath,
    bool? notificationLyrics,
    PlaybackState? playbackState,
    AnimationDuration? themeAnimationDuration,
    int? themeMaterialStandard,
    ThemeMode? themeMode,
    bool? themeSystemColorScheme,
    bool? windowsTaskbarProgress,
  }) async {
    if (audioFormatDisplay != null) {
      _audioFormatDisplay = audioFormatDisplay;
      await db.setValue(kKeyAudioFormatDisplay, kTypeBoolean, booleanValue: audioFormatDisplay);
    }
    if (desktopNowPlayingBarColorPalette != null) {
      _desktopNowPlayingBarColorPalette = desktopNowPlayingBarColorPalette;
      await db.setValue(kKeyDesktopNowPlayingBarColorPalette, kTypeBoolean, booleanValue: desktopNowPlayingBarColorPalette);
    }
    if (desktopNowPlayingScreenCarousel != null) {
      _desktopNowPlayingScreenCarousel = desktopNowPlayingScreenCarousel;
      await db.setValue(kKeyDesktopNowPlayingScreenCarousel, kTypeInteger, integerValue: desktopNowPlayingScreenCarousel);
    }
    if (desktopNowPlayingScreenLyrics != null) {
      _desktopNowPlayingScreenLyrics = desktopNowPlayingScreenLyrics;
      await db.setValue(kKeyDesktopNowPlayingScreenLyrics, kTypeBoolean, booleanValue: desktopNowPlayingScreenLyrics);
    }
    if (discordRpc != null) {
      _discordRpc = discordRpc;
      await db.setValue(kKeyDiscordRpc, kTypeBoolean, booleanValue: discordRpc);
    }
    if (localization != null) {
      _localization = localization;
      await db.setValue(kKeyLocalization, kTypeJson, jsonValue: localization.toJson());
    }
    if (lrcFromDirectory != null) {
      _lrcFromDirectory = lrcFromDirectory;
      await db.setValue(kKeyLrcFromDirectory, kTypeBoolean, booleanValue: lrcFromDirectory);
    }
    if (lyricsViewFocusedFontSize != null) {
      _lyricsViewFocusedFontSize = lyricsViewFocusedFontSize;
      await db.setValue(kKeyLyricsViewFocusedFontSize, kTypeDouble, doubleValue: lyricsViewFocusedFontSize);
    }
    if (lyricsViewFocusedLineHeight != null) {
      _lyricsViewFocusedLineHeight = lyricsViewFocusedLineHeight;
      await db.setValue(kKeyLyricsViewFocusedLineHeight, kTypeDouble, doubleValue: lyricsViewFocusedLineHeight);
    }
    if (lyricsViewTextAlign != null) {
      _lyricsViewTextAlign = lyricsViewTextAlign;
      await db.setValue(kKeyLyricsViewTextAlign, kTypeInteger, integerValue: lyricsViewTextAlign.index);
    }
    if (lyricsViewUnfocusedFontSize != null) {
      _lyricsViewUnfocusedFontSize = lyricsViewUnfocusedFontSize;
      await db.setValue(kKeyLyricsViewUnfocusedFontSize, kTypeDouble, doubleValue: lyricsViewUnfocusedFontSize);
    }
    if (lyricsViewUnfocusedLineHeight != null) {
      _lyricsViewUnfocusedLineHeight = lyricsViewUnfocusedLineHeight;
      await db.setValue(kKeyLyricsViewUnfocusedLineHeight, kTypeDouble, doubleValue: lyricsViewUnfocusedLineHeight);
    }
    if (mediaLibraryAddTracksToPlaylist != null) {
      _mediaLibraryAddTracksToPlaylist = mediaLibraryAddTracksToPlaylist;
      await db.setValue(kKeyMediaLibraryAddTracksToPlaylist, kTypeBoolean, booleanValue: mediaLibraryAddTracksToPlaylist);
    }
    if (mediaLibraryAlbumGroupingParameters != null) {
      _mediaLibraryAlbumGroupingParameters = mediaLibraryAlbumGroupingParameters;
      await db.setValue(kKeyMediaLibraryAlbumGroupingParameters, kTypeJson, jsonValue: mediaLibraryAlbumGroupingParameters.toJson());
    }
    if (mediaLibraryAlbumSortAscending != null) {
      _mediaLibraryAlbumSortAscending = mediaLibraryAlbumSortAscending;
      await db.setValue(kKeyMediaLibraryAlbumSortAscending, kTypeBoolean, booleanValue: mediaLibraryAlbumSortAscending);
    }
    if (mediaLibraryAlbumSortType != null) {
      _mediaLibraryAlbumSortType = mediaLibraryAlbumSortType;
      await db.setValue(kKeyMediaLibraryAlbumSortType, kTypeInteger, integerValue: mediaLibraryAlbumSortType.index);
    }
    if (mediaLibraryArtistSortAscending != null) {
      _mediaLibraryArtistSortAscending = mediaLibraryArtistSortAscending;
      await db.setValue(kKeyMediaLibraryArtistSortAscending, kTypeBoolean, booleanValue: mediaLibraryArtistSortAscending);
    }
    if (mediaLibraryArtistSortType != null) {
      _mediaLibraryArtistSortType = mediaLibraryArtistSortType;
      await db.setValue(kKeyMediaLibraryArtistSortType, kTypeInteger, integerValue: mediaLibraryArtistSortType.index);
    }
    if (mediaLibraryCoverFallback != null) {
      _mediaLibraryCoverFallback = mediaLibraryCoverFallback;
      await db.setValue(kKeyMediaLibraryCoverFallback, kTypeBoolean, booleanValue: mediaLibraryCoverFallback);
    }
    if (mediaLibraryDesktopTracksScreenColumnWidths != null) {
      _mediaLibraryDesktopTracksScreenColumnWidths = mediaLibraryDesktopTracksScreenColumnWidths;
      await db.setValue(kKeyMediaLibraryDesktopTracksScreenColumnWidths, kTypeJson, jsonValue: mediaLibraryDesktopTracksScreenColumnWidths);
    }
    if (mediaLibraryDirectories != null) {
      _mediaLibraryDirectories = mediaLibraryDirectories;
      await db.setValue(kKeyMediaLibraryDirectories, kTypeJson, jsonValue: mediaLibraryDirectories.toJson());
    }
    if (mediaLibraryGenreSortAscending != null) {
      _mediaLibraryGenreSortAscending = mediaLibraryGenreSortAscending;
      await db.setValue(kKeyMediaLibraryGenreSortAscending, kTypeBoolean, booleanValue: mediaLibraryGenreSortAscending);
    }
    if (mediaLibraryGenreSortType != null) {
      _mediaLibraryGenreSortType = mediaLibraryGenreSortType;
      await db.setValue(kKeyMediaLibraryGenreSortType, kTypeInteger, integerValue: mediaLibraryGenreSortType.index);
    }
    if (mediaLibraryMinimumFileSize != null) {
      _mediaLibraryMinimumFileSize = mediaLibraryMinimumFileSize;
      await db.setValue(kKeyMediaLibraryMinimumFileSize, kTypeInteger, integerValue: mediaLibraryMinimumFileSize);
    }
    if (mediaLibraryPath != null) {
      _mediaLibraryPath = mediaLibraryPath;
      await db.setValue(kKeyMediaLibraryPath, kTypeString, stringValue: mediaLibraryPath);
    }
    if (mediaLibraryRefreshOnLaunch != null) {
      _mediaLibraryRefreshOnLaunch = mediaLibraryRefreshOnLaunch;
      await db.setValue(kKeyMediaLibraryRefreshOnLaunch, kTypeBoolean, booleanValue: mediaLibraryRefreshOnLaunch);
    }
    if (mediaLibraryTrackSortAscending != null) {
      _mediaLibraryTrackSortAscending = mediaLibraryTrackSortAscending;
      await db.setValue(kKeyMediaLibraryTrackSortAscending, kTypeBoolean, booleanValue: mediaLibraryTrackSortAscending);
    }
    if (mediaLibraryTrackSortType != null) {
      _mediaLibraryTrackSortType = mediaLibraryTrackSortType;
      await db.setValue(kKeyMediaLibraryTrackSortType, kTypeInteger, integerValue: mediaLibraryTrackSortType.index);
    }
    if (mobileAlbumGridSpan != null) {
      _mobileAlbumGridSpan = mobileAlbumGridSpan;
      await db.setValue(kKeyMobileAlbumGridSpan, kTypeInteger, integerValue: mobileAlbumGridSpan);
    }
    if (mobileArtistGridSpan != null) {
      _mobileArtistGridSpan = mobileArtistGridSpan;
      await db.setValue(kKeyMobileArtistGridSpan, kTypeInteger, integerValue: mobileArtistGridSpan);
    }
    if (mobileGenreGridSpan != null) {
      _mobileGenreGridSpan = mobileGenreGridSpan;
      await db.setValue(kKeyMobileGenreGridSpan, kTypeInteger, integerValue: mobileGenreGridSpan);
    }
    if (mobileNowPlayingRipple != null) {
      _mobileNowPlayingRipple = mobileNowPlayingRipple;
      await db.setValue(kKeyMobileNowPlayingRipple, kTypeBoolean, booleanValue: mobileNowPlayingRipple);
    }
    if (mobileNowPlayingSlider != null) {
      _mobileNowPlayingSlider = mobileNowPlayingSlider;
      await db.setValue(kKeyMobileNowPlayingSlider, kTypeBoolean, booleanValue: mobileNowPlayingSlider);
    }
    if (mpvOptions != null) {
      _mpvOptions = mpvOptions;
      await db.setValue(kKeyMpvOptions, kTypeJson, jsonValue: mpvOptions);
    }
    if (mpvPath != null) {
      _mpvPath = mpvPath;
      await db.setValue(kKeyMpvPath, kTypeString, stringValue: mpvPath);
    }
    if (notificationLyrics != null) {
      _notificationLyrics = notificationLyrics;
      await db.setValue(kKeyNotificationLyrics, kTypeBoolean, booleanValue: notificationLyrics);
    }
    if (playbackState != null) {
      _playbackState = playbackState;
      await db.setValue(kKeyPlaybackState, kTypeJson, jsonValue: playbackState.toJson());
    }
    if (themeAnimationDuration != null) {
      _themeAnimationDuration = themeAnimationDuration;
      await db.setValue(kKeyThemeAnimationDuration, kTypeJson, jsonValue: themeAnimationDuration.toJson());
    }
    if (themeMaterialStandard != null) {
      _themeMaterialStandard = themeMaterialStandard;
      await db.setValue(kKeyThemeMaterialStandard, kTypeInteger, integerValue: themeMaterialStandard);
    }
    if (themeMode != null) {
      _themeMode = themeMode;
      await db.setValue(kKeyThemeMode, kTypeInteger, integerValue: themeMode.index);
    }
    if (themeSystemColorScheme != null) {
      _themeSystemColorScheme = themeSystemColorScheme;
      await db.setValue(kKeyThemeSystemColorScheme, kTypeBoolean, booleanValue: themeSystemColorScheme);
    }
    if (windowsTaskbarProgress != null) {
      _windowsTaskbarProgress = windowsTaskbarProgress;
      await db.setValue(kKeyWindowsTaskbarProgress, kTypeBoolean, booleanValue: windowsTaskbarProgress);
    }
  }

  Future<Map<String, dynamic>> getDefaults() async {
    return {
      /* Boolean */ kKeyAudioFormatDisplay: true,
      /* Boolean */ kKeyDesktopNowPlayingBarColorPalette: true,
      /* Integer */ kKeyDesktopNowPlayingScreenCarousel: 0,
      /* Boolean */ kKeyDesktopNowPlayingScreenLyrics: true,
      /* Boolean */ kKeyDiscordRpc: true,
      /* Json    */ kKeyLocalization: const LocalizationData(code: 'en_US', name: 'English (United States)', country: 'United States'),
      /* Boolean */ kKeyLrcFromDirectory: false,
      /* Double  */ kKeyLyricsViewFocusedFontSize: 64.0,
      /* Double  */ kKeyLyricsViewFocusedLineHeight: 1.2,
      /* Integer */ kKeyLyricsViewTextAlign: TextAlign.start.index,
      /* Double  */ kKeyLyricsViewUnfocusedFontSize: 28.0,
      /* Double  */ kKeyLyricsViewUnfocusedLineHeight: 1.2,
      /* Boolean */ kKeyMediaLibraryAddTracksToPlaylist: true,
      /* Json    */ kKeyMediaLibraryAlbumGroupingParameters: [AlbumGroupingParameter.album.index],
      /* Boolean */ kKeyMediaLibraryAlbumSortAscending: true,
      /* Integer */ kKeyMediaLibraryAlbumSortType: isDesktop ? AlbumSortType.albumArtist.index : AlbumSortType.album.index,
      /* Boolean */ kKeyMediaLibraryArtistSortAscending: true,
      /* Integer */ kKeyMediaLibraryArtistSortType: ArtistSortType.artist.index,
      /* Boolean */ kKeyMediaLibraryCoverFallback: false,
      /* Json    */ kKeyMediaLibraryDesktopTracksScreenColumnWidths: <String, double>{},
      /* Json    */ kKeyMediaLibraryDirectories: [await getDefaultMediaLibraryDirectory()],
      /* Boolean */ kKeyMediaLibraryGenreSortAscending: true,
      /* Integer */ kKeyMediaLibraryGenreSortType: GenreSortType.genre.index,
      /* Integer */ kKeyMediaLibraryMinimumFileSize: 0,
      /* String  */ kKeyMediaLibraryPath: kAlbumsPath,
      /* Boolean */ kKeyMediaLibraryRefreshOnLaunch: true,
      /* Boolean */ kKeyMediaLibraryTrackSortAscending: true,
      /* Integer */ kKeyMediaLibraryTrackSortType: TrackSortType.title.index,
      /* Integer */ kKeyMobileAlbumGridSpan: 2,
      /* Integer */ kKeyMobileArtistGridSpan: 3,
      /* Integer */ kKeyMobileGenreGridSpan: 3,
      /* Boolean */ kKeyMobileNowPlayingRipple: true,
      /* Boolean */ kKeyMobileNowPlayingSlider: true,
      /* Json    */ kKeyMpvOptions: <String, String>{},
      /* String  */ kKeyMpvPath: '',
      /* Boolean */ kKeyNotificationLyrics: true,
      /* Json    */ kKeyPlaybackState: PlaybackState.defaults(),
      /* Json    */ kKeyThemeAnimationDuration: const AnimationDuration(),
      /* Integer */ kKeyThemeMaterialStandard: isDesktop ? 2 : 3,
      /* Integer */ kKeyThemeMode: ThemeMode.system.index,
      /* Boolean */ kKeyThemeSystemColorScheme: isMobile,
      /* Boolean */ kKeyWindowsTaskbarProgress: false,
    };
  }

  bool? _audioFormatDisplay;
  bool? _desktopNowPlayingBarColorPalette;
  int? _desktopNowPlayingScreenCarousel;
  bool? _desktopNowPlayingScreenLyrics;
  bool? _discordRpc;
  LocalizationData? _localization;
  bool? _lrcFromDirectory;
  double? _lyricsViewFocusedFontSize;
  double? _lyricsViewFocusedLineHeight;
  TextAlign? _lyricsViewTextAlign;
  double? _lyricsViewUnfocusedFontSize;
  double? _lyricsViewUnfocusedLineHeight;
  bool? _mediaLibraryAddTracksToPlaylist;
  Set<AlbumGroupingParameter>? _mediaLibraryAlbumGroupingParameters;
  bool? _mediaLibraryAlbumSortAscending;
  AlbumSortType? _mediaLibraryAlbumSortType;
  bool? _mediaLibraryArtistSortAscending;
  ArtistSortType? _mediaLibraryArtistSortType;
  bool? _mediaLibraryCoverFallback;
  Map<String, double>? _mediaLibraryDesktopTracksScreenColumnWidths;
  Set<Directory>? _mediaLibraryDirectories;
  bool? _mediaLibraryGenreSortAscending;
  GenreSortType? _mediaLibraryGenreSortType;
  int? _mediaLibraryMinimumFileSize;
  String? _mediaLibraryPath;
  bool? _mediaLibraryRefreshOnLaunch;
  bool? _mediaLibraryTrackSortAscending;
  TrackSortType? _mediaLibraryTrackSortType;
  int? _mobileAlbumGridSpan;
  int? _mobileArtistGridSpan;
  int? _mobileGenreGridSpan;
  bool? _mobileNowPlayingRipple;
  bool? _mobileNowPlayingSlider;
  Map<String, String>? _mpvOptions;
  String? _mpvPath;
  bool? _notificationLyrics;
  PlaybackState? _playbackState;
  AnimationDuration? _themeAnimationDuration;
  int? _themeMaterialStandard;
  ThemeMode? _themeMode;
  bool? _themeSystemColorScheme;
  bool? _windowsTaskbarProgress;
}

// ----- Keys -----

const kKeyAudioFormatDisplay = 'AUDIO_FORMAT_DISPLAY';
const kKeyDesktopNowPlayingBarColorPalette = 'DESKTOP_NOW_PLAYING_BAR_COLOR_PALETTE';
const kKeyDesktopNowPlayingScreenCarousel = 'DESKTOP_NOW_PLAYING_SCREEN_CAROUSEL';
const kKeyDesktopNowPlayingScreenLyrics = 'DESKTOP_NOW_PLAYING_SCREEN_LYRICS';
const kKeyDiscordRpc = 'DISCORD_RPC';
const kKeyLocalization = 'LOCALIZATION';
const kKeyLrcFromDirectory = 'LRC_FROM_DIRECTORY';
const kKeyLyricsViewFocusedFontSize = 'LYRICS_VIEW_FOCUSED_FONT_SIZE';
const kKeyLyricsViewFocusedLineHeight = 'LYRICS_VIEW_FOCUSED_LINE_HEIGHT';
const kKeyLyricsViewTextAlign = 'LYRICS_VIEW_TEXT_ALIGN';
const kKeyLyricsViewUnfocusedFontSize = 'LYRICS_VIEW_UNFOCUSED_FONT_SIZE';
const kKeyLyricsViewUnfocusedLineHeight = 'LYRICS_VIEW_UNFOCUSED_LINE_HEIGHT';
const kKeyMediaLibraryAddTracksToPlaylist = 'MEDIA_LIBRARY_ADD_TRACKS_TO_PLAYLIST';
const kKeyMediaLibraryAlbumGroupingParameters = 'MEDIA_LIBRARY_ALBUM_GROUPING_PARAMETERS';
const kKeyMediaLibraryAlbumSortAscending = 'MEDIA_LIBRARY_ALBUM_SORT_ASCENDING';
const kKeyMediaLibraryAlbumSortType = 'MEDIA_LIBRARY_ALBUM_SORT_TYPE';
const kKeyMediaLibraryArtistSortAscending = 'MEDIA_LIBRARY_ARTIST_SORT_ASCENDING';
const kKeyMediaLibraryArtistSortType = 'MEDIA_LIBRARY_ARTIST_SORT_TYPE';
const kKeyMediaLibraryCoverFallback = 'MEDIA_LIBRARY_COVER_FALLBACK';
const kKeyMediaLibraryDesktopTracksScreenColumnWidths = 'MEDIA_LIBRARY_DESKTOP_TRACKS_SCREEN_COLUMN_WIDTHS';
const kKeyMediaLibraryDirectories = 'MEDIA_LIBRARY_DIRECTORIES';
const kKeyMediaLibraryGenreSortAscending = 'MEDIA_LIBRARY_GENRE_SORT_ASCENDING';
const kKeyMediaLibraryGenreSortType = 'MEDIA_LIBRARY_GENRE_SORT_TYPE';
const kKeyMediaLibraryMinimumFileSize = 'MEDIA_LIBRARY_MINIMUM_FILE_SIZE';
const kKeyMediaLibraryPath = 'MEDIA_LIBRARY_PATH';
const kKeyMediaLibraryRefreshOnLaunch = 'MEDIA_LIBRARY_REFRESH_ON_LAUNCH';
const kKeyMediaLibraryTrackSortAscending = 'MEDIA_LIBRARY_TRACK_SORT_ASCENDING';
const kKeyMediaLibraryTrackSortType = 'MEDIA_LIBRARY_TRACK_SORT_TYPE';
const kKeyMobileAlbumGridSpan = 'MOBILE_ALBUM_GRID_SPAN';
const kKeyMobileArtistGridSpan = 'MOBILE_ARTIST_GRID_SPAN';
const kKeyMobileGenreGridSpan = 'MOBILE_GENRE_GRID_SPAN';
const kKeyMobileNowPlayingRipple = 'MOBILE_NOW_PLAYING_RIPPLE';
const kKeyMobileNowPlayingSlider = 'MOBILE_NOW_PLAYING_SLIDER';
const kKeyMpvOptions = 'MPV_OPTIONS';
const kKeyMpvPath = 'MPV_PATH';
const kKeyNotificationLyrics = 'NOTIFICATION_LYRICS';
const kKeyPlaybackState = 'PLAYBACK_STATE';
const kKeyThemeAnimationDuration = 'THEME_ANIMATION_DURATION';
const kKeyThemeMaterialStandard = 'THEME_MATERIAL_STANDARD';
const kKeyThemeMode = 'THEME_MODE';
const kKeyThemeSystemColorScheme = 'THEME_SYSTEM_COLOR_SCHEME';
const kKeyWindowsTaskbarProgress = 'WINDOWS_TASKBAR_PROGRESS';
