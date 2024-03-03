import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/date_time.dart';
import 'package:harmonoid/utils/constants.dart';

/// Extensions for [Track].
extension TrackExtensions on Track {
  /// Share subject.
  String get shareSubject => [
        title,
        artists.take(2).join(', '),
        album,
        year.toString(),
      ].where((e) => e.isNotEmpty).join(' • ');

  /// Playlist entry title.
  String get playlistEntryTitle => [
        title,
        artists.take(2).join(', '),
      ].where((e) => e.isNotEmpty).join(' • ');

  /// [ValueKey] for [ScrollViewBuilder].
  ValueKey<String> get scrollViewBuilderKey {
    switch (Configuration.instance.mediaLibraryTrackSortType) {
      case TrackSortType.title:
        return ValueKey(
          title[0],
        );
      case TrackSortType.timestamp:
        return ValueKey(
          timestamp.label,
        );
      case TrackSortType.year:
        return ValueKey(
          year == 0 ? kDefaultYear : year.toString(),
        );
    }
  }
}
