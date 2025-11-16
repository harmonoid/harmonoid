import 'package:flutter/material.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/ui/media_library/artists/state/artist_image_notifier.dart';

class ArtistImage extends StatelessWidget {
  final Artist artist;
  final int? cacheWidth;
  const ArtistImage({
    super.key,
    required this.artist,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtistImageNotifier>(
      builder: (context, notifier, _) {
        return Image(
          key: notifier.key,
          image: cover(
            item: artist,
            cacheWidth: cacheWidth,
          ),
          fit: BoxFit.cover,
        );
      },
    );
  }
}
