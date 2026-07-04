import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/rendering.dart';

/// {@template scroll_view_builder_helper}
///
/// ScrollViewBuilderHelper
/// -----------------------
/// Implementation to retrieve span, width & height of items for usage in [ScrollViewBuilder].
///
/// {@endtemplate}
class ScrollViewBuilderHelper {
  /// Singleton instance.
  static final ScrollViewBuilderHelper instance = ScrollViewBuilderHelper._();

  /// {@macro scroll_view_builder_helper}
  ScrollViewBuilderHelper._();

  ScrollViewBuilderHelperData get album {
    final span = isDesktop
        ? null
        : (Configuration.instance.mobileMediaLibraryAlbumGridSpan == 0
              ? (MediaQuery.of(rootNavigatorKey.currentContext!).size.width - margin) ~/ (albumTileWidth + margin)
              : Configuration.instance.mobileMediaLibraryAlbumGridSpan);
    final itemWidth = span != 1 ? albumTileWidth : double.infinity;
    final itemHeight = span != 1 ? albumTileHeight : linearTileHeight;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryAlbumSortType) {
      case AlbumSortType.album:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.titleLarge!;
        break;
      case AlbumSortType.timestamp:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
      case AlbumSortType.year:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
      case AlbumSortType.albumArtist:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.titleLarge!;
        break;
    }
    return ScrollViewBuilderHelperData(
      span,
      itemWidth,
      itemHeight,
      labelTextStyle,
    );
  }

  ScrollViewBuilderHelperData get track {
    const span = 1;
    const itemWidth = double.infinity;
    final itemHeight = linearTileHeight;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryTrackSortType) {
      case TrackSortType.title:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.titleLarge!;
        break;
      case TrackSortType.timestamp:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
      case TrackSortType.year:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
    }
    return ScrollViewBuilderHelperData(
      span,
      itemWidth,
      itemHeight,
      labelTextStyle,
    );
  }

  ScrollViewBuilderHelperData get artist {
    final span = isDesktop
        ? null
        : (Configuration.instance.mobileMediaLibraryArtistGridSpan == 0
              ? (MediaQuery.of(rootNavigatorKey.currentContext!).size.width - margin) ~/ (artistTileWidth + margin)
              : Configuration.instance.mobileMediaLibraryArtistGridSpan);
    final itemWidth = span != 1 ? artistTileWidth : double.infinity;
    final itemHeight = span != 1 ? artistTileHeight : linearTileHeight;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryArtistSortType) {
      case ArtistSortType.artist:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.titleLarge!;
        break;
      case ArtistSortType.timestamp:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
    }
    return ScrollViewBuilderHelperData(
      span,
      itemWidth,
      itemHeight,
      labelTextStyle,
    );
  }

  ScrollViewBuilderHelperData get genre {
    final span = isDesktop
        ? null
        : (Configuration.instance.mobileMediaLibraryGenreGridSpan == 0
              ? (MediaQuery.of(rootNavigatorKey.currentContext!).size.width - margin) ~/ (genreTileWidth + margin)
              : Configuration.instance.mobileMediaLibraryGenreGridSpan);
    final itemWidth = span != 1 ? genreTileWidth : double.infinity;
    final itemHeight = span != 1 ? genreTileHeight : linearTileHeight;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryGenreSortType) {
      case GenreSortType.genre:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.titleLarge!;
        break;
      case GenreSortType.timestamp:
        labelTextStyle = Theme.of(rootNavigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
    }
    return ScrollViewBuilderHelperData(
      span,
      itemWidth,
      itemHeight,
      labelTextStyle,
    );
  }
}

/// {@template scroll_view_builder_helper_data}
///
/// ScrollViewBuilderHelperData
/// ---------------------------
///
/// {@endtemplate}
class ScrollViewBuilderHelperData {
  final int? span;
  final double itemWidth;
  final double itemHeight;
  final TextStyle labelTextStyle;

  /// {@macro scroll_view_builder_helper_data}
  const ScrollViewBuilderHelperData(
    this.span,
    this.itemWidth,
    this.itemHeight,
    this.labelTextStyle,
  );
}
