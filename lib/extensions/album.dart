import 'package:flutter/material.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/date_time.dart';

/// Extensions for [Album].
extension AlbumExtensions on Album {
  /// [ValueKey] for [ScrollViewBuilder].
  ValueKey<String> get scrollViewBuilderKey {
    switch (Configuration.instance.mediaLibraryAlbumSortType) {
      case AlbumSortType.album:
        return ValueKey(
          album.isEmpty ? kDefaultAlbum[0] : album[0],
        );
      case AlbumSortType.timestamp:
        return ValueKey(
          timestamp.label,
        );
      case AlbumSortType.year:
        return ValueKey(
          year == 0 ? kDefaultYear : year.toString(),
        );
      case AlbumSortType.albumArtist:
        return ValueKey(
          album.isEmpty ? kDefaultAlbum[0] : album[0],
        );
    }
  }
}
