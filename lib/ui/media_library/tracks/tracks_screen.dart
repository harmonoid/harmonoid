import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/ui/media_library/tracks/tracks_table.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/debouncer.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class TracksScreen extends StatefulWidget {
  const TracksScreen({super.key});

  @override
  State<TracksScreen> createState() => TracksScreenState();
}

class TracksScreenState extends State<TracksScreen> {
  final _desktopColumnWidthsDebouncer = Debouncer();

  @override
  void dispose() {
    super.dispose();
    _desktopColumnWidthsDebouncer.dispose();
  }

  Widget _buildHeader(BuildContext context) {
    if (isDesktop) {
      return Container(
        height: kDesktopHeaderHeight,
        margin: mediaLibraryScrollViewBuilderPadding,
        child: const DesktopMediaLibraryHeader(key: ValueKey('')),
      );
    }
    if (isMobile) {
      return Container(
        height: kMobileHeaderHeight,
        margin: mediaLibraryScrollViewBuilderPadding.copyWith(bottom: 0.0),
        child: const MobileMediaLibraryHeader(key: ValueKey('')),
      );
    }
    throw UnimplementedError();
  }

  WidgetBuilder? get _buildFooter => isDesktop
      ? null
      : (BuildContext context) {
          return const SizedBox(
            key: ValueKey(''),
            height: kMobileNowPlayingBarHeight,
          );
        };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          return KeyedSubtree(
            key: ValueKey((mediaLibrary.albumSortType, mediaLibrary.albumSortAscending)),
            child: TracksTable(
              key: const PageStorageKey(TracksScreen),
              tracks: mediaLibrary.tracks,
              headerBuilder: _buildHeader,
              footerBuilder: _buildFooter,
              desktopOnColumnResize: (widths) {
                _desktopColumnWidthsDebouncer.run(() {
                  Configuration.instance.set(desktopMediaLibraryTracksScreenColumnWidths: widths);
                });
              },
              mobileDisplayLabel: true,
            ),
          );
        },
      ),
    );
  }
}
