import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/album.dart';
import 'package:harmonoid/features/media_library/desktop/desktop_media_library_header.dart';
import 'package:harmonoid/features/media_library/albums/album_item.dart';
import 'package:harmonoid/features/media_library/albums/albums_artists_screen.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_header.dart';
import 'package:harmonoid/features/media_library/state/media_library_scroll_view_builder_data_provider.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

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
    return LayoutBuilder(
      builder: (context, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Consumer<MediaLibrary>(
            builder: (context, mediaLibrary, _) {
              if (mediaLibrary.albumSortType == AlbumSortType.albumArtist) {
                return const AlbumsArtistsScreen();
              }

              final scrollViewBuilderHelperData = MediaLibraryScrollViewBuilderDataProvider(context).album;

              return KeyedSubtree(
                key: ValueKey((
                  mediaLibrary.albumSortType,
                  mediaLibrary.albumSortAscending,
                  mediaLibrary.albums.length,
                )),
                child: ScrollViewBuilder(
                  key: const PageStorageKey(AlbumsScreen),
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
                  displayLabel: true,
                  labelTextStyle: scrollViewBuilderHelperData.labelTextStyle,
                  itemWidth: scrollViewBuilderHelperData.itemWidth,
                  itemHeight: scrollViewBuilderHelperData.itemHeight,
                  padding: MediaLibraryScrollViewBuilderDataProvider(context).padding,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
