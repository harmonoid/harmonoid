// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';

class MobileMediaLibraryGridSpanButton extends StatelessWidget {
  const MobileMediaLibraryGridSpanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.location.split('/').last;
    if (![kAlbumsPath, kArtistsPath, kGenresPath].contains(path)) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.view_list_outlined),
      onPressed: () async {
        final String title;
        final int groupValue;
        Future<void> Function(int?) onChanged;
        switch (path) {
          case kAlbumsPath:
            title = Localization.instance.MOBILE_ALBUM_GRID_SIZE;
            groupValue = Configuration.instance.mobileMediaLibraryAlbumScrollViewBuilderSpan;
            onChanged = (value) => Configuration.instance.set(mobileMediaLibraryAlbumScrollViewBuilderSpan: value);
            break;
          case kArtistsPath:
            title = Localization.instance.MOBILE_ARTIST_GRID_SIZE;
            groupValue = Configuration.instance.mobileMediaLibraryArtistScrollViewBuilderSpan;
            onChanged = (value) => Configuration.instance.set(mobileMediaLibraryArtistScrollViewBuilderSpan: value);
            break;
          case kGenresPath:
            title = Localization.instance.MOBILE_GENRE_GRID_SIZE;
            groupValue = Configuration.instance.mobileMediaLibraryGenreScrollViewBuilderSpan;
            onChanged = (value) => Configuration.instance.set(mobileMediaLibraryGenreScrollViewBuilderSpan: value);
            break;
          default:
            throw UnimplementedError();
        }

        await showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(title),
            children: [
              for (int i = 0; i <= 4; i++)
                RadioListTile<int?>(
                  value: i,
                  groupValue: groupValue,
                  onChanged: (value) {
                    final mediaLibrary = context.read<MediaLibrary>();
                    onChanged(value).then((_) => Navigator.of(context).pop()).then((_) => mediaLibrary.notify());
                  },
                  title: Text(
                    i == 0 ? '#' : i.toString(),
                    style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
