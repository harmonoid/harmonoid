import 'package:flutter/material.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/date_time.dart';

/// Extensions for [Artist].
extension ArtistExtensions on Artist {
  /// [ValueKey] for [ScrollViewBuilder].
  ValueKey<String> get scrollViewBuilderKey {
    switch (Configuration.instance.mediaLibraryArtistSortType) {
      case ArtistSortType.artist:
        return ValueKey(
          artist.isEmpty ? kDefaultArtist[0].toUpperCase() : artist[0].toUpperCase(),
        );
      case ArtistSortType.timestamp:
        return ValueKey(
          timestamp.label,
        );
    }
  }
}
