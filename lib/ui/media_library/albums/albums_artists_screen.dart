import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/extensions/album.dart';
import 'package:harmonoid/ui/media_library/albums/album_item.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/scroll_view_builder_helper.dart';
import 'package:harmonoid/utils/widgets.dart';

class AlbumsArtistsScreen extends StatefulWidget {
  const AlbumsArtistsScreen({super.key});

  @override
  State<AlbumsArtistsScreen> createState() => AlbumsArtistsScreenState();
}

class AlbumsArtistsScreenState extends State<AlbumsArtistsScreen> {
  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return const DesktopAlbumsArtistsScreen();
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      throw UnimplementedError();
    }
    throw UnimplementedError();
  }
}

class DesktopAlbumsArtistsScreen extends StatefulWidget {
  const DesktopAlbumsArtistsScreen({super.key});

  @override
  State<DesktopAlbumsArtistsScreen> createState() => DesktopAlbumsArtistsScreenState();
}

class DesktopAlbumsArtistsScreenState extends State<DesktopAlbumsArtistsScreen> {
  final _key = GlobalKey<ScrollViewBuilderState>();
  final _floatingNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          final scrollViewBuilderHelperData = ScrollViewBuilderHelper.instance.album;

          final albumArtists = mediaLibrary.albumArtists.entries.toList();

          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 172.0,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (_) => true,
                  child: ScrollViewBuilder(
                    margin: 0.0,
                    span: 1,
                    displayHeaders: false,
                    headerCount: albumArtists.length,
                    headerBuilder: (context, i, h) => const SizedBox.shrink(),
                    headerHeight: 0.0,
                    itemCounts: albumArtists.map((_) => 1).toList(),
                    itemBuilder: (context, i, j, w, h) {
                      return InkWell(
                        key: const ValueKey(''),
                        onTap: () {
                          _key.currentState?.jumpToHeader(
                            i + 1,
                            difference: -8.0,
                          );
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            albumArtists[i].key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                    itemWidth: double.infinity,
                    itemHeight: 28.0,
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                  ),
                ),
              ),
              const VerticalDivider(
                width: 1.0,
                thickness: 1.0,
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    _floatingNotifier.value = notification.metrics.pixels > 0.0;
                    return false;
                  },
                  child: ScrollViewBuilder(
                    key: _key,
                    margin: margin,
                    span: scrollViewBuilderHelperData.span,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    headerCount: 1 + albumArtists.length,
                    headerBuilder: (context, i, h) {
                      if (i == 0) {
                        return DesktopMediaLibraryHeader(
                          key: const ValueKey(''),
                          floatingNotifier: _floatingNotifier,
                        );
                      } else {
                        return SubHeader(
                          key: albumArtists[i - 1].value[0].scrollViewBuilderKey,
                          albumArtists[i - 1].key,
                          padding: EdgeInsets.only(
                            left: margin,
                            right: margin,
                            bottom: margin,
                          ),
                        );
                      }
                    },
                    headerHeight: kDesktopHeaderHeight,
                    itemCounts: [0, ...albumArtists.map((e) => e.value.length)],
                    itemBuilder: (context, i, j, w, h) => AlbumItem(
                      key: albumArtists[i - 1].value[j].scrollViewBuilderKey,
                      album: albumArtists[i - 1].value[j],
                      width: w,
                      height: h,
                    ),
                    itemWidth: scrollViewBuilderHelperData.itemWidth,
                    itemHeight: scrollViewBuilderHelperData.itemHeight,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
