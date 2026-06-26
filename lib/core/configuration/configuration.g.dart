// AUTO GENERATED FILE, DO NOT EDIT.

part of 'configuration.dart';

class ConfigurationBase {

  final Directory directory;
  final Database db;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  ConfigurationBase({required this.directory, required this.db});

  String get apiBaseUrl => _apiBaseUrl!;
  List<double> get desktopMediaLibraryFoldersScreenColumnWidths => _desktopMediaLibraryFoldersScreenColumnWidths!;
  List<double> get desktopMediaLibraryTracksScreenColumnWidths => _desktopMediaLibraryTracksScreenColumnWidths!;
  bool get desktopNowPlayingBarColorPalette => _desktopNowPlayingBarColorPalette!;
  int get desktopNowPlayingCarousel => _desktopNowPlayingCarousel!;
  bool get desktopNowPlayingLyrics => _desktopNowPlayingLyrics!;
  bool get discordRpc => _discordRpc!;
  String get identifier => _identifier!;
  Session get lastfmSession => _lastfmSession!;
  LocalizationData get localization => _localization!;
  bool get lrcFromDirectory => _lrcFromDirectory!;
  double get lyricsViewFocusedFontSize => _lyricsViewFocusedFontSize!;
  double get lyricsViewFocusedLineHeight => _lyricsViewFocusedLineHeight!;
  String get lyricsViewFontFamily => _lyricsViewFontFamily!;
  TextAlign get lyricsViewTextAlign => _lyricsViewTextAlign!;
  double get lyricsViewUnfocusedFontSize => _lyricsViewUnfocusedFontSize!;
  double get lyricsViewUnfocusedLineHeight => _lyricsViewUnfocusedLineHeight!;
  Language get lyricsTranslationLanguage => _lyricsTranslationLanguage!;
  bool get mediaLibraryAddPlaylistToNowPlaying => _mediaLibraryAddPlaylistToNowPlaying!;
  Set<AlbumGroupingParameter> get mediaLibraryAlbumGroupingParameters => _mediaLibraryAlbumGroupingParameters!;
  bool get mediaLibraryAlbumSortAscending => _mediaLibraryAlbumSortAscending!;
  AlbumSortType get mediaLibraryAlbumSortType => _mediaLibraryAlbumSortType!;
  bool get mediaLibraryArtistImages => _mediaLibraryArtistImages!;
  bool get mediaLibraryArtistSortAscending => _mediaLibraryArtistSortAscending!;
  ArtistSortType get mediaLibraryArtistSortType => _mediaLibraryArtistSortType!;
  bool get mediaLibraryCoverFallback => _mediaLibraryCoverFallback!;
  Set<Directory> get mediaLibraryDirectories => _mediaLibraryDirectories!;
  FileExplorerViewType get mediaLibraryFolderFileExplorerViewType => _mediaLibraryFolderFileExplorerViewType!;
  FileExplorerSortType get mediaLibraryFolderFileExplorerSortType => _mediaLibraryFolderFileExplorerSortType!;
  bool get mediaLibraryFolderFileExplorerSortAscending => _mediaLibraryFolderFileExplorerSortAscending!;
  bool get mediaLibraryFolderFileExplorerShowHiddenFiles => _mediaLibraryFolderFileExplorerShowHiddenFiles!;
  bool get mediaLibraryGenreSortAscending => _mediaLibraryGenreSortAscending!;
  GenreSortType get mediaLibraryGenreSortType => _mediaLibraryGenreSortType!;
  bool get mediaLibraryHideSecondaryArtists => _mediaLibraryHideSecondaryArtists!;
  int get mediaLibraryMinimumFileSize => _mediaLibraryMinimumFileSize!;
  String get mediaLibraryPath => _mediaLibraryPath!;
  bool get mediaLibraryRefreshUponStart => _mediaLibraryRefreshUponStart!;
  bool get mediaLibraryTagReaderFallback => _mediaLibraryTagReaderFallback!;
  bool get mediaLibraryTrackSortAscending => _mediaLibraryTrackSortAscending!;
  TrackSortType get mediaLibraryTrackSortType => _mediaLibraryTrackSortType!;
  Set<MediaLibraryTab> get mediaLibraryVisibleTabs => _mediaLibraryVisibleTabs!;
  PlaybackState get mediaPlayerPlaybackState => _mediaPlayerPlaybackState!;
  int get mobileMediaLibraryAlbumGridSpan => _mobileMediaLibraryAlbumGridSpan!;
  int get mobileMediaLibraryArtistGridSpan => _mobileMediaLibraryArtistGridSpan!;
  int get mobileMediaLibraryGenreGridSpan => _mobileMediaLibraryGenreGridSpan!;
  bool get mobileNotificationLyricsHidden => _mobileNotificationLyricsHidden!;
  bool get mobileNowPlayingRipple => _mobileNowPlayingRipple!;
  bool get mobileNowPlayingVolumeSlider => _mobileNowPlayingVolumeSlider!;
  Map<String, String> get mpvOptions => _mpvOptions!;
  String get mpvPath => _mpvPath!;
  bool get notificationLyrics => _notificationLyrics!;
  bool get nowPlayingAudioFormat => _nowPlayingAudioFormat!;
  bool get nowPlayingDisplayUponPlay => _nowPlayingDisplayUponPlay!;
  int get nowPlayingLyricsFtuxCount => _nowPlayingLyricsFtuxCount!;
  bool get nowPlayingStartMixAfterEnding => _nowPlayingStartMixAfterEnding!;
  AnimationDuration get themeAnimationDuration => _themeAnimationDuration!;
  int get themeMaterialStandard => _themeMaterialStandard!;
  ThemeMode get themeMode => _themeMode!;
  bool get themeSystemColorScheme => _themeSystemColorScheme!;
  String get updateCheckVersion => _updateCheckVersion!;
  bool get windowsTaskbarProgress => _windowsTaskbarProgress!;

  Future<void> set({
    String? apiBaseUrl,
    List<double>? desktopMediaLibraryFoldersScreenColumnWidths,
    List<double>? desktopMediaLibraryTracksScreenColumnWidths,
    bool? desktopNowPlayingBarColorPalette,
    int? desktopNowPlayingCarousel,
    bool? desktopNowPlayingLyrics,
    bool? discordRpc,
    String? identifier,
    Session? lastfmSession,
    LocalizationData? localization,
    bool? lrcFromDirectory,
    double? lyricsViewFocusedFontSize,
    double? lyricsViewFocusedLineHeight,
    String? lyricsViewFontFamily,
    TextAlign? lyricsViewTextAlign,
    double? lyricsViewUnfocusedFontSize,
    double? lyricsViewUnfocusedLineHeight,
    Language? lyricsTranslationLanguage,
    bool? mediaLibraryAddPlaylistToNowPlaying,
    Set<AlbumGroupingParameter>? mediaLibraryAlbumGroupingParameters,
    bool? mediaLibraryAlbumSortAscending,
    AlbumSortType? mediaLibraryAlbumSortType,
    bool? mediaLibraryArtistImages,
    bool? mediaLibraryArtistSortAscending,
    ArtistSortType? mediaLibraryArtistSortType,
    bool? mediaLibraryCoverFallback,
    Set<Directory>? mediaLibraryDirectories,
    FileExplorerViewType? mediaLibraryFolderFileExplorerViewType,
    FileExplorerSortType? mediaLibraryFolderFileExplorerSortType,
    bool? mediaLibraryFolderFileExplorerSortAscending,
    bool? mediaLibraryFolderFileExplorerShowHiddenFiles,
    bool? mediaLibraryGenreSortAscending,
    GenreSortType? mediaLibraryGenreSortType,
    bool? mediaLibraryHideSecondaryArtists,
    int? mediaLibraryMinimumFileSize,
    String? mediaLibraryPath,
    bool? mediaLibraryRefreshUponStart,
    bool? mediaLibraryTagReaderFallback,
    bool? mediaLibraryTrackSortAscending,
    TrackSortType? mediaLibraryTrackSortType,
    Set<MediaLibraryTab>? mediaLibraryVisibleTabs,
    PlaybackState? mediaPlayerPlaybackState,
    int? mobileMediaLibraryAlbumGridSpan,
    int? mobileMediaLibraryArtistGridSpan,
    int? mobileMediaLibraryGenreGridSpan,
    bool? mobileNotificationLyricsHidden,
    bool? mobileNowPlayingRipple,
    bool? mobileNowPlayingVolumeSlider,
    Map<String, String>? mpvOptions,
    String? mpvPath,
    bool? notificationLyrics,
    bool? nowPlayingAudioFormat,
    bool? nowPlayingDisplayUponPlay,
    int? nowPlayingLyricsFtuxCount,
    bool? nowPlayingStartMixAfterEnding,
    AnimationDuration? themeAnimationDuration,
    int? themeMaterialStandard,
    ThemeMode? themeMode,
    bool? themeSystemColorScheme,
    String? updateCheckVersion,
    bool? windowsTaskbarProgress,
  }) async {
    if (apiBaseUrl != null) {
      _apiBaseUrl = apiBaseUrl;
      await db.setValue(kKeyApiBaseUrl, kTypeString, stringValue: apiBaseUrl);
    }
    if (desktopMediaLibraryFoldersScreenColumnWidths != null) {
      _desktopMediaLibraryFoldersScreenColumnWidths = desktopMediaLibraryFoldersScreenColumnWidths;
      await db.setValue(kKeyDesktopMediaLibraryFoldersScreenColumnWidths, kTypeJson, jsonValue: desktopMediaLibraryFoldersScreenColumnWidths);
    }
    if (desktopMediaLibraryTracksScreenColumnWidths != null) {
      _desktopMediaLibraryTracksScreenColumnWidths = desktopMediaLibraryTracksScreenColumnWidths;
      await db.setValue(kKeyDesktopMediaLibraryTracksScreenColumnWidths, kTypeJson, jsonValue: desktopMediaLibraryTracksScreenColumnWidths);
    }
    if (desktopNowPlayingBarColorPalette != null) {
      _desktopNowPlayingBarColorPalette = desktopNowPlayingBarColorPalette;
      await db.setValue(kKeyDesktopNowPlayingBarColorPalette, kTypeBoolean, booleanValue: desktopNowPlayingBarColorPalette);
    }
    if (desktopNowPlayingCarousel != null) {
      _desktopNowPlayingCarousel = desktopNowPlayingCarousel;
      await db.setValue(kKeyDesktopNowPlayingCarousel, kTypeInteger, integerValue: desktopNowPlayingCarousel);
    }
    if (desktopNowPlayingLyrics != null) {
      _desktopNowPlayingLyrics = desktopNowPlayingLyrics;
      await db.setValue(kKeyDesktopNowPlayingLyrics, kTypeBoolean, booleanValue: desktopNowPlayingLyrics);
    }
    if (discordRpc != null) {
      _discordRpc = discordRpc;
      await db.setValue(kKeyDiscordRpc, kTypeBoolean, booleanValue: discordRpc);
    }
    if (identifier != null) {
      _identifier = identifier;
      await db.setValue(kKeyIdentifier, kTypeString, stringValue: identifier);
    }
    if (lastfmSession != null) {
      _lastfmSession = lastfmSession;
      await db.setValue(kKeyLastfmSession, kTypeJson, jsonValue: lastfmSession.toJson());
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
    if (lyricsViewFontFamily != null) {
      _lyricsViewFontFamily = lyricsViewFontFamily;
      await db.setValue(kKeyLyricsViewFontFamily, kTypeString, stringValue: lyricsViewFontFamily);
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
    if (lyricsTranslationLanguage != null) {
      _lyricsTranslationLanguage = lyricsTranslationLanguage;
      await db.setValue(kKeyLyricsTranslationLanguage, kTypeJson, jsonValue: lyricsTranslationLanguage.toJson());
    }
    if (mediaLibraryAddPlaylistToNowPlaying != null) {
      _mediaLibraryAddPlaylistToNowPlaying = mediaLibraryAddPlaylistToNowPlaying;
      await db.setValue(kKeyMediaLibraryAddPlaylistToNowPlaying, kTypeBoolean, booleanValue: mediaLibraryAddPlaylistToNowPlaying);
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
    if (mediaLibraryArtistImages != null) {
      _mediaLibraryArtistImages = mediaLibraryArtistImages;
      await db.setValue(kKeyMediaLibraryArtistImages, kTypeBoolean, booleanValue: mediaLibraryArtistImages);
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
    if (mediaLibraryDirectories != null) {
      _mediaLibraryDirectories = mediaLibraryDirectories;
      await db.setValue(kKeyMediaLibraryDirectories, kTypeJson, jsonValue: mediaLibraryDirectories.toJson());
    }
    if (mediaLibraryFolderFileExplorerViewType != null) {
      _mediaLibraryFolderFileExplorerViewType = mediaLibraryFolderFileExplorerViewType;
      await db.setValue(kKeyMediaLibraryFolderFileExplorerViewType, kTypeInteger, integerValue: mediaLibraryFolderFileExplorerViewType.index);
    }
    if (mediaLibraryFolderFileExplorerSortType != null) {
      _mediaLibraryFolderFileExplorerSortType = mediaLibraryFolderFileExplorerSortType;
      await db.setValue(kKeyMediaLibraryFolderFileExplorerSortType, kTypeInteger, integerValue: mediaLibraryFolderFileExplorerSortType.index);
    }
    if (mediaLibraryFolderFileExplorerSortAscending != null) {
      _mediaLibraryFolderFileExplorerSortAscending = mediaLibraryFolderFileExplorerSortAscending;
      await db.setValue(kKeyMediaLibraryFolderFileExplorerSortAscending, kTypeBoolean, booleanValue: mediaLibraryFolderFileExplorerSortAscending);
    }
    if (mediaLibraryFolderFileExplorerShowHiddenFiles != null) {
      _mediaLibraryFolderFileExplorerShowHiddenFiles = mediaLibraryFolderFileExplorerShowHiddenFiles;
      await db.setValue(kKeyMediaLibraryFolderFileExplorerShowHiddenFiles, kTypeBoolean, booleanValue: mediaLibraryFolderFileExplorerShowHiddenFiles);
    }
    if (mediaLibraryGenreSortAscending != null) {
      _mediaLibraryGenreSortAscending = mediaLibraryGenreSortAscending;
      await db.setValue(kKeyMediaLibraryGenreSortAscending, kTypeBoolean, booleanValue: mediaLibraryGenreSortAscending);
    }
    if (mediaLibraryGenreSortType != null) {
      _mediaLibraryGenreSortType = mediaLibraryGenreSortType;
      await db.setValue(kKeyMediaLibraryGenreSortType, kTypeInteger, integerValue: mediaLibraryGenreSortType.index);
    }
    if (mediaLibraryHideSecondaryArtists != null) {
      _mediaLibraryHideSecondaryArtists = mediaLibraryHideSecondaryArtists;
      await db.setValue(kKeyMediaLibraryHideSecondaryArtists, kTypeBoolean, booleanValue: mediaLibraryHideSecondaryArtists);
    }
    if (mediaLibraryMinimumFileSize != null) {
      _mediaLibraryMinimumFileSize = mediaLibraryMinimumFileSize;
      await db.setValue(kKeyMediaLibraryMinimumFileSize, kTypeInteger, integerValue: mediaLibraryMinimumFileSize);
    }
    if (mediaLibraryPath != null) {
      _mediaLibraryPath = mediaLibraryPath;
      await db.setValue(kKeyMediaLibraryPath, kTypeString, stringValue: mediaLibraryPath);
    }
    if (mediaLibraryRefreshUponStart != null) {
      _mediaLibraryRefreshUponStart = mediaLibraryRefreshUponStart;
      await db.setValue(kKeyMediaLibraryRefreshUponStart, kTypeBoolean, booleanValue: mediaLibraryRefreshUponStart);
    }
    if (mediaLibraryTagReaderFallback != null) {
      _mediaLibraryTagReaderFallback = mediaLibraryTagReaderFallback;
      await db.setValue(kKeyMediaLibraryTagReaderFallback, kTypeBoolean, booleanValue: mediaLibraryTagReaderFallback);
    }
    if (mediaLibraryTrackSortAscending != null) {
      _mediaLibraryTrackSortAscending = mediaLibraryTrackSortAscending;
      await db.setValue(kKeyMediaLibraryTrackSortAscending, kTypeBoolean, booleanValue: mediaLibraryTrackSortAscending);
    }
    if (mediaLibraryTrackSortType != null) {
      _mediaLibraryTrackSortType = mediaLibraryTrackSortType;
      await db.setValue(kKeyMediaLibraryTrackSortType, kTypeInteger, integerValue: mediaLibraryTrackSortType.index);
    }
    if (mediaLibraryVisibleTabs != null) {
      _mediaLibraryVisibleTabs = mediaLibraryVisibleTabs;
      await db.setValue(kKeyMediaLibraryVisibleTabs, kTypeJson, jsonValue: mediaLibraryVisibleTabs.toJson());
    }
    if (mediaPlayerPlaybackState != null) {
      _mediaPlayerPlaybackState = mediaPlayerPlaybackState;
      await db.setValue(kKeyMediaPlayerPlaybackState, kTypeJson, jsonValue: mediaPlayerPlaybackState.toJson());
    }
    if (mobileMediaLibraryAlbumGridSpan != null) {
      _mobileMediaLibraryAlbumGridSpan = mobileMediaLibraryAlbumGridSpan;
      await db.setValue(kKeyMobileMediaLibraryAlbumGridSpan, kTypeInteger, integerValue: mobileMediaLibraryAlbumGridSpan);
    }
    if (mobileMediaLibraryArtistGridSpan != null) {
      _mobileMediaLibraryArtistGridSpan = mobileMediaLibraryArtistGridSpan;
      await db.setValue(kKeyMobileMediaLibraryArtistGridSpan, kTypeInteger, integerValue: mobileMediaLibraryArtistGridSpan);
    }
    if (mobileMediaLibraryGenreGridSpan != null) {
      _mobileMediaLibraryGenreGridSpan = mobileMediaLibraryGenreGridSpan;
      await db.setValue(kKeyMobileMediaLibraryGenreGridSpan, kTypeInteger, integerValue: mobileMediaLibraryGenreGridSpan);
    }
    if (mobileNotificationLyricsHidden != null) {
      _mobileNotificationLyricsHidden = mobileNotificationLyricsHidden;
      await db.setValue(kKeyMobileNotificationLyricsHidden, kTypeBoolean, booleanValue: mobileNotificationLyricsHidden);
    }
    if (mobileNowPlayingRipple != null) {
      _mobileNowPlayingRipple = mobileNowPlayingRipple;
      await db.setValue(kKeyMobileNowPlayingRipple, kTypeBoolean, booleanValue: mobileNowPlayingRipple);
    }
    if (mobileNowPlayingVolumeSlider != null) {
      _mobileNowPlayingVolumeSlider = mobileNowPlayingVolumeSlider;
      await db.setValue(kKeyMobileNowPlayingVolumeSlider, kTypeBoolean, booleanValue: mobileNowPlayingVolumeSlider);
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
    if (nowPlayingAudioFormat != null) {
      _nowPlayingAudioFormat = nowPlayingAudioFormat;
      await db.setValue(kKeyNowPlayingAudioFormat, kTypeBoolean, booleanValue: nowPlayingAudioFormat);
    }
    if (nowPlayingDisplayUponPlay != null) {
      _nowPlayingDisplayUponPlay = nowPlayingDisplayUponPlay;
      await db.setValue(kKeyNowPlayingDisplayUponPlay, kTypeBoolean, booleanValue: nowPlayingDisplayUponPlay);
    }
    if (nowPlayingLyricsFtuxCount != null) {
      _nowPlayingLyricsFtuxCount = nowPlayingLyricsFtuxCount;
      await db.setValue(kKeyNowPlayingLyricsFtuxCount, kTypeInteger, integerValue: nowPlayingLyricsFtuxCount);
    }
    if (nowPlayingStartMixAfterEnding != null) {
      _nowPlayingStartMixAfterEnding = nowPlayingStartMixAfterEnding;
      await db.setValue(kKeyNowPlayingStartMixAfterEnding, kTypeBoolean, booleanValue: nowPlayingStartMixAfterEnding);
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
    if (updateCheckVersion != null) {
      _updateCheckVersion = updateCheckVersion;
      await db.setValue(kKeyUpdateCheckVersion, kTypeString, stringValue: updateCheckVersion);
    }
    if (windowsTaskbarProgress != null) {
      _windowsTaskbarProgress = windowsTaskbarProgress;
      await db.setValue(kKeyWindowsTaskbarProgress, kTypeBoolean, booleanValue: windowsTaskbarProgress);
    }
  }

  Future<Map<String, dynamic>> getDefaults() async {
    return {
      /* String  */ kKeyApiBaseUrl: '',
      /* Json    */ kKeyDesktopMediaLibraryFoldersScreenColumnWidths: <double>[],
      /* Json    */ kKeyDesktopMediaLibraryTracksScreenColumnWidths: <double>[],
      /* Boolean */ kKeyDesktopNowPlayingBarColorPalette: true,
      /* Integer */ kKeyDesktopNowPlayingCarousel: 0,
      /* Boolean */ kKeyDesktopNowPlayingLyrics: true,
      /* Boolean */ kKeyDiscordRpc: true,
      /* String  */ kKeyIdentifier: const Uuid().v4(),
      /* Json    */ kKeyLastfmSession: const Session(name: '', key: ''),
      /* Json    */ kKeyLocalization: await getDefaultLocalization(),
      /* Boolean */ kKeyLrcFromDirectory: false,
      /* Double  */ kKeyLyricsViewFocusedFontSize: isDesktop ? 64.0: 48.0,
      /* Double  */ kKeyLyricsViewFocusedLineHeight: 1.2,
      /* String  */ kKeyLyricsViewFontFamily: '',
      /* Integer */ kKeyLyricsViewTextAlign: TextAlign.start.index,
      /* Double  */ kKeyLyricsViewUnfocusedFontSize: isDesktop ? 28.0: 24.0,
      /* Double  */ kKeyLyricsViewUnfocusedLineHeight: 1.2,
      /* Json    */ kKeyLyricsTranslationLanguage: await getDefaultLyricsTranslationLanguage(),
      /* Boolean */ kKeyMediaLibraryAddPlaylistToNowPlaying: true,
      /* Json    */ kKeyMediaLibraryAlbumGroupingParameters: [AlbumGroupingParameter.album.index],
      /* Boolean */ kKeyMediaLibraryAlbumSortAscending: true,
      /* Integer */ kKeyMediaLibraryAlbumSortType: AlbumSortType.album.index,
      /* Boolean */ kKeyMediaLibraryArtistImages: false,
      /* Boolean */ kKeyMediaLibraryArtistSortAscending: true,
      /* Integer */ kKeyMediaLibraryArtistSortType: ArtistSortType.artist.index,
      /* Boolean */ kKeyMediaLibraryCoverFallback: false,
      /* Json    */ kKeyMediaLibraryDirectories: await getDefaultMediaLibraryDirectories(),
      /* Integer */ kKeyMediaLibraryFolderFileExplorerViewType: FileExplorerViewType.grid.index,
      /* Integer */ kKeyMediaLibraryFolderFileExplorerSortType: FileExplorerSortType.name.index,
      /* Boolean */ kKeyMediaLibraryFolderFileExplorerSortAscending: true,
      /* Boolean */ kKeyMediaLibraryFolderFileExplorerShowHiddenFiles: false,
      /* Boolean */ kKeyMediaLibraryGenreSortAscending: true,
      /* Integer */ kKeyMediaLibraryGenreSortType: GenreSortType.genre.index,
      /* Boolean */ kKeyMediaLibraryHideSecondaryArtists: false,
      /* Integer */ kKeyMediaLibraryMinimumFileSize: 0,
      /* String  */ kKeyMediaLibraryPath: kAlbumsPath,
      /* Boolean */ kKeyMediaLibraryRefreshUponStart: false,
      /* Boolean */ kKeyMediaLibraryTagReaderFallback: false,
      /* Boolean */ kKeyMediaLibraryTrackSortAscending: true,
      /* Integer */ kKeyMediaLibraryTrackSortType: TrackSortType.title.index,
      /* Json    */ kKeyMediaLibraryVisibleTabs: [MediaLibraryTab.albums.index, MediaLibraryTab.tracks.index, MediaLibraryTab.artists.index, MediaLibraryTab.folders.index, MediaLibraryTab.playlists.index],
      /* Json    */ kKeyMediaPlayerPlaybackState: MediaPlayerState.defaults().toPlaybackState(),
      /* Integer */ kKeyMobileMediaLibraryAlbumGridSpan: 2,
      /* Integer */ kKeyMobileMediaLibraryArtistGridSpan: 3,
      /* Integer */ kKeyMobileMediaLibraryGenreGridSpan: 3,
      /* Boolean */ kKeyMobileNotificationLyricsHidden: false,
      /* Boolean */ kKeyMobileNowPlayingRipple: true,
      /* Boolean */ kKeyMobileNowPlayingVolumeSlider: true,
      /* Json    */ kKeyMpvOptions: <String, String>{},
      /* String  */ kKeyMpvPath: '',
      /* Boolean */ kKeyNotificationLyrics: true,
      /* Boolean */ kKeyNowPlayingAudioFormat: true,
      /* Boolean */ kKeyNowPlayingDisplayUponPlay: isDesktop,
      /* Integer */ kKeyNowPlayingLyricsFtuxCount: 0,
      /* Boolean */ kKeyNowPlayingStartMixAfterEnding: true,
      /* Json    */ kKeyThemeAnimationDuration: const AnimationDuration(),
      /* Integer */ kKeyThemeMaterialStandard: isDesktop ? 2 : 3,
      /* Integer */ kKeyThemeMode: isDesktop ? ThemeMode.light.index: ThemeMode.system.index,
      /* Boolean */ kKeyThemeSystemColorScheme: isMobile,
      /* String  */ kKeyUpdateCheckVersion: kVersion,
      /* Boolean */ kKeyWindowsTaskbarProgress: false,
    };
  }

  String? _apiBaseUrl;
  List<double>? _desktopMediaLibraryFoldersScreenColumnWidths;
  List<double>? _desktopMediaLibraryTracksScreenColumnWidths;
  bool? _desktopNowPlayingBarColorPalette;
  int? _desktopNowPlayingCarousel;
  bool? _desktopNowPlayingLyrics;
  bool? _discordRpc;
  String? _identifier;
  Session? _lastfmSession;
  LocalizationData? _localization;
  bool? _lrcFromDirectory;
  double? _lyricsViewFocusedFontSize;
  double? _lyricsViewFocusedLineHeight;
  String? _lyricsViewFontFamily;
  TextAlign? _lyricsViewTextAlign;
  double? _lyricsViewUnfocusedFontSize;
  double? _lyricsViewUnfocusedLineHeight;
  Language? _lyricsTranslationLanguage;
  bool? _mediaLibraryAddPlaylistToNowPlaying;
  Set<AlbumGroupingParameter>? _mediaLibraryAlbumGroupingParameters;
  bool? _mediaLibraryAlbumSortAscending;
  AlbumSortType? _mediaLibraryAlbumSortType;
  bool? _mediaLibraryArtistImages;
  bool? _mediaLibraryArtistSortAscending;
  ArtistSortType? _mediaLibraryArtistSortType;
  bool? _mediaLibraryCoverFallback;
  Set<Directory>? _mediaLibraryDirectories;
  FileExplorerViewType? _mediaLibraryFolderFileExplorerViewType;
  FileExplorerSortType? _mediaLibraryFolderFileExplorerSortType;
  bool? _mediaLibraryFolderFileExplorerSortAscending;
  bool? _mediaLibraryFolderFileExplorerShowHiddenFiles;
  bool? _mediaLibraryGenreSortAscending;
  GenreSortType? _mediaLibraryGenreSortType;
  bool? _mediaLibraryHideSecondaryArtists;
  int? _mediaLibraryMinimumFileSize;
  String? _mediaLibraryPath;
  bool? _mediaLibraryRefreshUponStart;
  bool? _mediaLibraryTagReaderFallback;
  bool? _mediaLibraryTrackSortAscending;
  TrackSortType? _mediaLibraryTrackSortType;
  Set<MediaLibraryTab>? _mediaLibraryVisibleTabs;
  PlaybackState? _mediaPlayerPlaybackState;
  int? _mobileMediaLibraryAlbumGridSpan;
  int? _mobileMediaLibraryArtistGridSpan;
  int? _mobileMediaLibraryGenreGridSpan;
  bool? _mobileNotificationLyricsHidden;
  bool? _mobileNowPlayingRipple;
  bool? _mobileNowPlayingVolumeSlider;
  Map<String, String>? _mpvOptions;
  String? _mpvPath;
  bool? _notificationLyrics;
  bool? _nowPlayingAudioFormat;
  bool? _nowPlayingDisplayUponPlay;
  int? _nowPlayingLyricsFtuxCount;
  bool? _nowPlayingStartMixAfterEnding;
  AnimationDuration? _themeAnimationDuration;
  int? _themeMaterialStandard;
  ThemeMode? _themeMode;
  bool? _themeSystemColorScheme;
  String? _updateCheckVersion;
  bool? _windowsTaskbarProgress;
}

// ----- Keys -----

const kKeyApiBaseUrl = 'API_BASE_URL';
const kKeyDesktopMediaLibraryFoldersScreenColumnWidths = 'DESKTOP_MEDIA_LIBRARY_FOLDERS_SCREEN_COLUMN_WIDTHS';
const kKeyDesktopMediaLibraryTracksScreenColumnWidths = 'DESKTOP_MEDIA_LIBRARY_TRACKS_SCREEN_COLUMN_WIDTHS';
const kKeyDesktopNowPlayingBarColorPalette = 'DESKTOP_NOW_PLAYING_BAR_COLOR_PALETTE';
const kKeyDesktopNowPlayingCarousel = 'DESKTOP_NOW_PLAYING_CAROUSEL';
const kKeyDesktopNowPlayingLyrics = 'DESKTOP_NOW_PLAYING_LYRICS';
const kKeyDiscordRpc = 'DISCORD_RPC';
const kKeyIdentifier = 'IDENTIFIER';
const kKeyLastfmSession = 'LASTFM_SESSION';
const kKeyLocalization = 'LOCALIZATION';
const kKeyLrcFromDirectory = 'LRC_FROM_DIRECTORY';
const kKeyLyricsViewFocusedFontSize = 'LYRICS_VIEW_FOCUSED_FONT_SIZE';
const kKeyLyricsViewFocusedLineHeight = 'LYRICS_VIEW_FOCUSED_LINE_HEIGHT';
const kKeyLyricsViewFontFamily = 'LYRICS_VIEW_FONT_FAMILY';
const kKeyLyricsViewTextAlign = 'LYRICS_VIEW_TEXT_ALIGN';
const kKeyLyricsViewUnfocusedFontSize = 'LYRICS_VIEW_UNFOCUSED_FONT_SIZE';
const kKeyLyricsViewUnfocusedLineHeight = 'LYRICS_VIEW_UNFOCUSED_LINE_HEIGHT';
const kKeyLyricsTranslationLanguage = 'LYRICS_TRANSLATION_LANGUAGE';
const kKeyMediaLibraryAddPlaylistToNowPlaying = 'MEDIA_LIBRARY_ADD_PLAYLIST_TO_NOW_PLAYING';
const kKeyMediaLibraryAlbumGroupingParameters = 'MEDIA_LIBRARY_ALBUM_GROUPING_PARAMETERS';
const kKeyMediaLibraryAlbumSortAscending = 'MEDIA_LIBRARY_ALBUM_SORT_ASCENDING';
const kKeyMediaLibraryAlbumSortType = 'MEDIA_LIBRARY_ALBUM_SORT_TYPE';
const kKeyMediaLibraryArtistImages = 'MEDIA_LIBRARY_ARTIST_IMAGES';
const kKeyMediaLibraryArtistSortAscending = 'MEDIA_LIBRARY_ARTIST_SORT_ASCENDING';
const kKeyMediaLibraryArtistSortType = 'MEDIA_LIBRARY_ARTIST_SORT_TYPE';
const kKeyMediaLibraryCoverFallback = 'MEDIA_LIBRARY_COVER_FALLBACK';
const kKeyMediaLibraryDirectories = 'MEDIA_LIBRARY_DIRECTORIES';
const kKeyMediaLibraryFolderFileExplorerViewType = 'MEDIA_LIBRARY_FOLDER_FILE_EXPLORER_VIEW_TYPE';
const kKeyMediaLibraryFolderFileExplorerSortType = 'MEDIA_LIBRARY_FOLDER_FILE_EXPLORER_SORT_TYPE';
const kKeyMediaLibraryFolderFileExplorerSortAscending = 'MEDIA_LIBRARY_FOLDER_FILE_EXPLORER_SORT_ASCENDING';
const kKeyMediaLibraryFolderFileExplorerShowHiddenFiles = 'MEDIA_LIBRARY_FOLDER_FILE_EXPLORER_SHOW_HIDDEN_FILES';
const kKeyMediaLibraryGenreSortAscending = 'MEDIA_LIBRARY_GENRE_SORT_ASCENDING';
const kKeyMediaLibraryGenreSortType = 'MEDIA_LIBRARY_GENRE_SORT_TYPE';
const kKeyMediaLibraryHideSecondaryArtists = 'MEDIA_LIBRARY_HIDE_SECONDARY_ARTISTS';
const kKeyMediaLibraryMinimumFileSize = 'MEDIA_LIBRARY_MINIMUM_FILE_SIZE';
const kKeyMediaLibraryPath = 'MEDIA_LIBRARY_PATH';
const kKeyMediaLibraryRefreshUponStart = 'MEDIA_LIBRARY_REFRESH_UPON_START';
const kKeyMediaLibraryTagReaderFallback = 'MEDIA_LIBRARY_TAG_READER_FALLBACK';
const kKeyMediaLibraryTrackSortAscending = 'MEDIA_LIBRARY_TRACK_SORT_ASCENDING';
const kKeyMediaLibraryTrackSortType = 'MEDIA_LIBRARY_TRACK_SORT_TYPE';
const kKeyMediaLibraryVisibleTabs = 'MEDIA_LIBRARY_VISIBLE_TABS';
const kKeyMediaPlayerPlaybackState = 'MEDIA_PLAYER_PLAYBACK_STATE';
const kKeyMobileMediaLibraryAlbumGridSpan = 'MOBILE_MEDIA_LIBRARY_ALBUM_GRID_SPAN';
const kKeyMobileMediaLibraryArtistGridSpan = 'MOBILE_MEDIA_LIBRARY_ARTIST_GRID_SPAN';
const kKeyMobileMediaLibraryGenreGridSpan = 'MOBILE_MEDIA_LIBRARY_GENRE_GRID_SPAN';
const kKeyMobileNotificationLyricsHidden = 'MOBILE_NOTIFICATION_LYRICS_HIDDEN';
const kKeyMobileNowPlayingRipple = 'MOBILE_NOW_PLAYING_RIPPLE';
const kKeyMobileNowPlayingVolumeSlider = 'MOBILE_NOW_PLAYING_VOLUME_SLIDER';
const kKeyMpvOptions = 'MPV_OPTIONS';
const kKeyMpvPath = 'MPV_PATH';
const kKeyNotificationLyrics = 'NOTIFICATION_LYRICS';
const kKeyNowPlayingAudioFormat = 'NOW_PLAYING_AUDIO_FORMAT';
const kKeyNowPlayingDisplayUponPlay = 'NOW_PLAYING_DISPLAY_UPON_PLAY';
const kKeyNowPlayingLyricsFtuxCount = 'NOW_PLAYING_LYRICS_FTUX_COUNT';
const kKeyNowPlayingStartMixAfterEnding = 'NOW_PLAYING_START_MIX_AFTER_ENDING';
const kKeyThemeAnimationDuration = 'THEME_ANIMATION_DURATION';
const kKeyThemeMaterialStandard = 'THEME_MATERIAL_STANDARD';
const kKeyThemeMode = 'THEME_MODE';
const kKeyThemeSystemColorScheme = 'THEME_SYSTEM_COLOR_SCHEME';
const kKeyUpdateCheckVersion = 'UPDATE_CHECK_VERSION';
const kKeyWindowsTaskbarProgress = 'WINDOWS_TASKBAR_PROGRESS';
