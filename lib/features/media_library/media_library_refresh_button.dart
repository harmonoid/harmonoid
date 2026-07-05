import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/localization/localization.dart';

class MediaLibraryRefreshButton extends StatelessWidget {
  const MediaLibraryRefreshButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) => mediaLibrary.refreshing
          ? const SizedBox.shrink()
          : FloatingActionButton(
              heroTag: 'media-library-refresh-button',
              tooltip: Localization.instance.REFRESH,
              onPressed: mediaLibrary.refresh,
              child: const Icon(Icons.refresh),
            ),
    );
  }
}
