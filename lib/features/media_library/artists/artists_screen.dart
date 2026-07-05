import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/artist.dart';
import 'package:harmonoid/features/media_library/artists/artist_item.dart';
import 'package:harmonoid/features/media_library/desktop/desktop_media_library_header.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_header.dart';
import 'package:harmonoid/features/media_library/state/media_library_scroll_view_builder_data_provider.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/rendering.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => ArtistsScreenState();
}

class ArtistsScreenState extends State<ArtistsScreen> {
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
              final scrollViewBuilderHelperData = MediaLibraryScrollViewBuilderDataProvider(context).artist;

              return KeyedSubtree(
                key: ValueKey((
                  mediaLibrary.artistSortType,
                  mediaLibrary.artistSortAscending,
                  mediaLibrary.artists.length,
                )),
                child: ScrollViewBuilder(
                  key: const PageStorageKey(ArtistsScreen),
                  margin: margin,
                  span: scrollViewBuilderHelperData.span,
                  headerCount: 1,
                  headerBuilder: headerBuilder,
                  headerHeight: headerHeight,
                  itemCounts: [mediaLibrary.artists.length],
                  itemBuilder: (context, i, j, w, h) => ArtistItem(
                    key: mediaLibrary.artists[j].scrollViewBuilderKey,
                    artist: mediaLibrary.artists[j],
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
