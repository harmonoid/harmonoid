import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/album.dart';
import 'package:harmonoid/ui/media_library/albums/album_item.dart';
import 'package:harmonoid/ui/media_library/albums/albums_artists_screen.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/scroll_view_builder_helper.dart';
import 'package:harmonoid/utils/widgets.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => AlbumsScreenState();
}

class AlbumsScreenState extends State<AlbumsScreen> {
  double get headerHeight {
    if (isDesktop) {
      return kDesktopHeaderHeight;
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      return kMobileHeaderHeight;
    }
    throw UnimplementedError();
  }

  Widget headerBuilder(BuildContext context, int i, double h) {
    if (isDesktop) {
      return const DesktopMediaLibraryHeader(key: ValueKey(''));
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      return const MobileMediaLibraryHeader(key: ValueKey(''));
    }
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          if (mediaLibrary.albumSortType == AlbumSortType.albumArtist) {
            return const AlbumsArtistsScreen();
          }

          final scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.album;

          return ScrollViewBuilder(
            margin: margin,
            span: scrollViewBuilderHelperData.span,
            headerCount: 1,
            headerBuilder: headerBuilder,
            headerHeight: headerHeight,
            itemCounts: [mediaLibrary.albums.length],
            itemBuilder: (context, i, j, w, h) => AlbumItem(
              key: mediaLibrary.albums[j].scrollViewBuilderKey,
              album: mediaLibrary.albums[j],
              width: w,
              height: h,
            ),
            labelConstraints: scrollViewBuilderHelperData.labelConstraints,
            labelTextStyle: scrollViewBuilderHelperData.labelTextStyle,
            itemWidth: scrollViewBuilderHelperData.itemWidth,
            itemHeight: scrollViewBuilderHelperData.itemHeight,
          );
        },
      ),
    );
  }
}
