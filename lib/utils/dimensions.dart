/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/widgets.dart';

import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/core/configuration.dart';

const double kAlbumTileWidth = 148.0;
const double kAlbumTileHeight = 148.0 + 64.0;

const double kArtistTileWidth = 142.0;
const double kArtistTileHeight = 142.0 + 48.0;

const double kMobileArtistTileHeight = 64.0 + 8.0 + 1.0;
const double kMobileTrackTileHeight = 64.0 + 8.0 + 1.0;
const double kMobileTileMargin = 8.0;
const double kMobileBottomPaddingSmall = 12.0;
const double kMobileSearchBarHeight = 56.0;
const double kMobileNowPlayingBarHeight = 66.0;

const double kDesktopTileMargin = 16.0;
const double kDesktopAppBarHeight = 64.0;
const double kDesktopNowPlayingBarHeight = 84.0;

const double kWindowsScrollDelta = 40.0;

const int kAlbumTileSubTitleThreshold = 2;
const int kArtistTileSubTitleThreshold = 2;

const double kAlbumTileListViewHeight = 72.0 + 1.0;
const double kArtistTileListViewHeight = 72.0 + 1.0;

const double kDefaultCardElevation = 4.0;
const double kDefaultAppBarElevation = 4.0;
const double kDefaultHeavyElevation = 8.0;

/// DimensionsHelper
/// ----------------
///
/// An helper class used to calculate dimensions of various commonly used widgets.
///
class DimensionsHelper {
  final BuildContext context;

  const DimensionsHelper(this.context);

  int get albumElementsPerRow {
    if (isMobile) {
      return Configuration.instance.mobileAlbumsGridSize;
    }
    return (MediaQuery.of(context).size.width - tileMargin) ~/
        (kAlbumTileWidth + tileMargin);
  }

  double get albumTileWidth {
    if (isMobile) {
      return albumElementsPerRow == 1
          ? MediaQuery.of(context).size.width
          : (MediaQuery.of(context).size.width -
                  (albumElementsPerRow + 1) * tileMargin) /
              albumElementsPerRow;
    }
    return kAlbumTileWidth;
  }

  double get albumTileHeight {
    if (isMobile) {
      return albumElementsPerRow == 1
          ? kAlbumTileListViewHeight
          : albumTileWidth * kAlbumTileHeight / kAlbumTileWidth;
    }
    return kAlbumTileHeight;
  }

  bool get albumTileNormalDensity =>
      Configuration.instance.mobileAlbumsGridSize <=
      kAlbumTileSubTitleThreshold;

  int get artistElementsPerRow {
    if (isMobile) {
      return Configuration.instance.mobileArtistsGridSize;
    }
    return (MediaQuery.of(context).size.width - tileMargin) ~/
        (kArtistTileWidth + tileMargin);
  }

  double get artistTileWidth {
    if (isMobile) {
      return artistElementsPerRow == 1
          ? MediaQuery.of(context).size.width
          : (MediaQuery.of(context).size.width -
                  (artistElementsPerRow + 1) * tileMargin) /
              artistElementsPerRow;
    }
    return kArtistTileWidth;
  }

  double get artistTileHeight {
    if (isMobile) {
      return artistElementsPerRow == 1
          ? kArtistTileListViewHeight
          : artistTileWidth * kArtistTileHeight / kArtistTileWidth;
    }
    return kArtistTileHeight;
  }

  bool get artistTileNormalDensity =>
      Configuration.instance.mobileArtistsGridSize <=
      kArtistTileSubTitleThreshold;
}
