import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/artist.dart';
import 'package:harmonoid/ui/media_library/artists/artist_item.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/scroll_view_builder_helper.dart';
import 'package:harmonoid/utils/widgets.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => ArtistsScreenState();
}

class ArtistsScreenState extends State<ArtistsScreen> {
  final _floatingNotifier = ValueNotifier<bool>(false);

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
      return DesktopMediaLibraryHeader(
        key: const ValueKey(''),
        floatingNotifier: _floatingNotifier,
      );
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      return const MobileMediaLibraryHeader(
        key: ValueKey(''),
        tab: 0,
      );
    }
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          final scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.artist;

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical) {
                _floatingNotifier.value = notification.metrics.pixels > 0.0;
              }
              return false;
            },
            child: ScrollViewBuilder(
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
              labelConstraints: scrollViewBuilderHelperData.labelConstraints,
              labelTextStyle: scrollViewBuilderHelperData.labelTextStyle,
              itemWidth: scrollViewBuilderHelperData.itemWidth,
              itemHeight: scrollViewBuilderHelperData.itemHeight,
            ),
          );
        },
      ),
    );
  }
}
