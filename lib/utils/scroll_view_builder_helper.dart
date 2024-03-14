import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/constants.dart';
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
  static const ScrollViewBuilderHelper instance = ScrollViewBuilderHelper._();

  /// {@macro scroll_view_builder_helper}
  const ScrollViewBuilderHelper._();

  ScrollViewBuilderHelperData get album {
    final span = isDesktop ? null : Configuration.instance.mobileAlbumGridSpan;
    final itemWidth = span != 1 ? albumTileWidth : double.infinity;
    final itemHeight = span != 1 ? albumTileHeight : linearTileHeight;
    final BoxConstraints labelConstraints;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryAlbumSortType) {
      case AlbumSortType.album:
        labelConstraints = const BoxConstraints(
          maxWidth: 56.0,
          maxHeight: 56.0,
        );
        break;
      case AlbumSortType.timestamp:
        labelConstraints = const BoxConstraints(
          maxWidth: 128.0,
          maxHeight: 28.0,
        );
        break;
      case AlbumSortType.year:
        labelConstraints = const BoxConstraints(
          maxWidth: 128.0,
          maxHeight: 28.0,
        );
        break;
      case AlbumSortType.albumArtist:
        labelConstraints = const BoxConstraints(
          maxWidth: 56.0,
          maxHeight: 56.0,
        );
        break;
    }
    switch (Configuration.instance.mediaLibraryAlbumSortType) {
      case AlbumSortType.album:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.titleLarge!;
        break;
      case AlbumSortType.timestamp:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
      case AlbumSortType.year:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
      case AlbumSortType.albumArtist:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.titleLarge!;
        break;
    }
    return ScrollViewBuilderHelperData(
      span,
      itemWidth,
      itemHeight,
      labelConstraints,
      labelTextStyle,
    );
  }

  ScrollViewBuilderHelperData get track {
    const span = 1;
    const itemWidth = double.infinity;
    final itemHeight = linearTileHeight;
    final BoxConstraints labelConstraints;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryTrackSortType) {
      case TrackSortType.title:
        labelConstraints = const BoxConstraints(
          maxWidth: 56.0,
          maxHeight: 56.0,
        );
        break;
      case TrackSortType.timestamp:
        labelConstraints = const BoxConstraints(
          maxWidth: 128.0,
          maxHeight: 28.0,
        );
        break;
      case TrackSortType.year:
        labelConstraints = const BoxConstraints(
          maxWidth: 128.0,
          maxHeight: 28.0,
        );
        break;
    }
    switch (Configuration.instance.mediaLibraryTrackSortType) {
      case TrackSortType.title:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.titleLarge!;
        break;
      case TrackSortType.timestamp:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
      case TrackSortType.year:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.titleLarge!;
        break;
    }
    return ScrollViewBuilderHelperData(
      span,
      itemWidth,
      itemHeight,
      labelConstraints,
      labelTextStyle,
    );
  }

  ScrollViewBuilderHelperData get artist {
    final span = isDesktop ? null : Configuration.instance.mobileArtistGridSpan;
    final itemWidth = span != 1 ? kArtistTileWidth : double.infinity;
    final itemHeight = span != 1 ? kArtistTileHeight : linearTileHeight;
    final BoxConstraints labelConstraints;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryArtistSortType) {
      case ArtistSortType.artist:
        labelConstraints = const BoxConstraints(
          maxWidth: 56.0,
          maxHeight: 56.0,
        );
        break;
      case ArtistSortType.timestamp:
        labelConstraints = const BoxConstraints(
          maxWidth: 128.0,
          maxHeight: 28.0,
        );
        break;
    }
    switch (Configuration.instance.mediaLibraryArtistSortType) {
      case ArtistSortType.artist:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.titleLarge!;
        break;
      case ArtistSortType.timestamp:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
    }
    return ScrollViewBuilderHelperData(
      span,
      itemWidth,
      itemHeight,
      labelConstraints,
      labelTextStyle,
    );
  }

  ScrollViewBuilderHelperData get genre {
    final span = isDesktop ? null : Configuration.instance.mobileGenreGridSpan;
    final itemWidth = span != 1 ? kGenreTileWidth : double.infinity;
    final itemHeight = span != 1 ? kGenreTileHeight : linearTileHeight;
    final BoxConstraints labelConstraints;
    final TextStyle labelTextStyle;
    switch (Configuration.instance.mediaLibraryGenreSortType) {
      case GenreSortType.genre:
        labelConstraints = const BoxConstraints(
          maxWidth: 56.0,
          maxHeight: 56.0,
        );
        break;
      case GenreSortType.timestamp:
        labelConstraints = const BoxConstraints(
          maxWidth: 128.0,
          maxHeight: 28.0,
        );
        break;
    }
    switch (Configuration.instance.mediaLibraryGenreSortType) {
      case GenreSortType.genre:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.titleLarge!;
        break;
      case GenreSortType.timestamp:
        labelTextStyle = Theme.of(navigatorKey.currentContext!).textTheme.bodyLarge!;
        break;
    }
    return ScrollViewBuilderHelperData(
      span,
      itemWidth,
      itemHeight,
      labelConstraints,
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
  final BoxConstraints labelConstraints;
  final TextStyle labelTextStyle;

  /// {@macro scroll_view_builder_helper_data}
  const ScrollViewBuilderHelperData(
    this.span,
    this.itemWidth,
    this.itemHeight,
    this.labelConstraints,
    this.labelTextStyle,
  );
}
