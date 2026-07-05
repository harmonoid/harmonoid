import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/features/media_library/desktop/desktop_media_library_header.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_header.dart';
import 'package:harmonoid/features/media_library/state/media_library_scroll_view_builder_data_provider.dart';
import 'package:harmonoid/features/media_library/tracks/tracks_table.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/debouncer.dart';
import 'package:harmonoid/utils/rendering.dart';

class TracksScreen extends StatefulWidget {
  const TracksScreen({super.key});

  @override
  State<TracksScreen> createState() => TracksScreenState();
}

class TracksScreenState extends State<TracksScreen> {
  final Debouncer _desktopColumnWidthsDebouncer = Debouncer();

  @override
  void dispose() {
    super.dispose();
    _desktopColumnWidthsDebouncer.dispose();
  }

  Widget _buildHeader(BuildContext context) {
    if (isDesktop) {
      return Container(
        height: kDesktopHeaderHeight,
        margin: MediaLibraryScrollViewBuilderDataProvider(context).padding,
        child: const DesktopMediaLibraryHeader(key: ValueKey('')),
      );
    }
    if (isMobile) {
      return Container(
        height: kMobileHeaderHeight,
        margin: MediaLibraryScrollViewBuilderDataProvider(context).padding.copyWith(bottom: 0.0),
        child: const MobileMediaLibraryHeader(key: ValueKey('')),
      );
    }
    throw UnimplementedError();
  }

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
