import 'package:flutter/material.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/media_library/models/media_library_tab.dart';
import 'package:harmonoid/routing/utils/constants.dart';

/// Mappers for [MediaLibraryTab].
extension MediaLibraryTabMappers on MediaLibraryTab {
  /// Converts to path.
  String toPath() => switch (this) {
    MediaLibraryTab.albums => kAlbumsPath,
    MediaLibraryTab.tracks => kTracksPath,
    MediaLibraryTab.artists => kArtistsPath,
    MediaLibraryTab.genres => kGenresPath,
    MediaLibraryTab.folders => kFoldersPath,
    MediaLibraryTab.playlists => kPlaylistsPath,
  };

  /// Converts to label.
  String toLabel() => switch (this) {
    MediaLibraryTab.albums => Localization.instance.ALBUMS,
    MediaLibraryTab.tracks => Localization.instance.TRACKS,
    MediaLibraryTab.artists => Localization.instance.ARTISTS,
    MediaLibraryTab.genres => Localization.instance.GENRES,
    MediaLibraryTab.folders => Localization.instance.FOLDERS,
    MediaLibraryTab.playlists => Localization.instance.PLAYLISTS,
  };

  /// Converts to icon.
  IconData toIcon() => switch (this) {
    MediaLibraryTab.albums => Icons.album,
    MediaLibraryTab.tracks => Icons.music_note,
    MediaLibraryTab.artists => Icons.person,
    MediaLibraryTab.genres => Icons.piano,
    MediaLibraryTab.folders => Icons.folder,
    MediaLibraryTab.playlists => Icons.playlist_play,
  };
}
