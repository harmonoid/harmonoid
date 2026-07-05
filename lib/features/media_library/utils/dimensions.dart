import 'package:harmonoid/utils/rendering.dart';

const double kDesktopAlbumItemWidth = 148.0;
const double kDesktopAlbumItemHeight = 148.0 + 64.0;
const double kMobileAlbumItemWidth = 168.0;
const double kMobileAlbumItemHeight = 168.0 + 72.0;

const double kDesktopArtistItemWidth = 142.0;
const double kDesktopArtistItemHeight = 142.0 + 36.0;
const double kMobileArtistItemWidth = 112.0;
const double kMobileArtistItemHeight = 112.0 + 36.0;

const double kDesktopGenreItemWidth = 142.0;
const double kDesktopGenreItemHeight = 142.0;
const double kMobileGenreItemWidth = 112.0;
const double kMobileGenreItemHeight = 112.0 + 36.0;

double get albumItemWidth {
  if (isDesktop) {
    return kDesktopAlbumItemWidth;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileAlbumItemWidth;
  }
  throw UnimplementedError();
}

double get albumItemHeight {
  if (isDesktop) {
    return kDesktopAlbumItemHeight;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileAlbumItemHeight;
  }
  throw UnimplementedError();
}

double get artistItemWidth {
  if (isDesktop) {
    return kDesktopArtistItemWidth;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileArtistItemWidth;
  }
  throw UnimplementedError();
}

double get artistItemHeight {
  if (isDesktop) {
    return kDesktopArtistItemHeight;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileArtistItemHeight;
  }
  throw UnimplementedError();
}

double get genreItemWidth {
  if (isDesktop) {
    return kDesktopGenreItemWidth;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileGenreItemWidth;
  }
  throw UnimplementedError();
}

double get genreItemHeight {
  if (isDesktop) {
    return kDesktopGenreItemHeight;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileGenreItemHeight;
  }
  throw UnimplementedError();
}
