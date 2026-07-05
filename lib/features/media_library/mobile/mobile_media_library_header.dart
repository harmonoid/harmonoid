import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_sort_button.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/dimensions.dart';

class MobileMediaLibraryHeader extends StatelessWidget {
  final Widget? leading;
  const MobileMediaLibraryHeader({super.key, this.leading});

  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;
    return Container(
      height: kMobileHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: margin),
      alignment: Alignment.centerRight,
      child: Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          return Row(
            children: [
              const SizedBox(width: 8.0),
              if (leading != null)
                leading!
              else if (path == kAlbumsPath)
                Text(mediaLibrary.albums.length == 1 ? Localization.instance.ONE_ALBUM : Localization.instance.N_ALBUMS.replaceAll('"N"', mediaLibrary.albums.length.toString()))
              else if (path == kTracksPath)
                Text(mediaLibrary.albums.length == 1 ? Localization.instance.ONE_TRACK : Localization.instance.N_TRACKS.replaceAll('"N"', mediaLibrary.tracks.length.toString()))
              else if (path == kArtistsPath)
                Text(mediaLibrary.albums.length == 1 ? Localization.instance.ONE_ARTIST : Localization.instance.N_ARTISTS.replaceAll('"N"', mediaLibrary.artists.length.toString()))
              else if (path == kGenresPath)
                Text(mediaLibrary.albums.length == 1 ? Localization.instance.ONE_GENRE : Localization.instance.N_GENRES.replaceAll('"N"', mediaLibrary.genres.length.toString())),
              const Spacer(),
              MobileMediaLibrarySortButton(path: path),
            ],
          );
        },
      ),
    );
  }
}
