/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/rendering.dart';

class AlbumTileCustomization extends StatelessWidget {
  final Color? currentTrackColor;
  AlbumTileCustomization({super.key, this.currentTrackColor});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => ExpansionTile(
        leading: Stack(
          children: [
            Icon(
              Broken.brush,
              color: currentTrackColor,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).colorScheme.background,
                          spreadRadius: 1)
                    ]),
                child: Icon(
                  Broken.music_dashboard,
                  size: 14,
                  color: currentTrackColor,
                ),
              ),
            )
          ],
        ),
        title: Text(
          Language.instance.ALBUM_TILE_CUSTOMIZATION,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        trailing: Icon(
          Broken.arrow_down_2,
        ),
        children: [
          // Track Number in a small Box
          // Should be available only with the new style
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  icon: Broken.card_remove,
                  title: Language.instance.DISPLAY_TRACK_NUMBER_IN_ALBUM_PAGE,
                  subtitle: Language
                      .instance.DISPLAY_TRACK_NUMBER_IN_ALBUM_PAGE_SUBTITLE,
                  onChanged: (_) => Configuration.instance
                      .save(
                    displayTrackNumberinAlbumPage:
                        !Configuration.instance.displayTrackNumberinAlbumPage,
                  )
                      .then((_) {
                    setState(() {});
                  }),
                  value: Configuration.instance.displayTrackNumberinAlbumPage,
                ),
              ),
            ),
          if (isMobile)
            AbsorbPointer(
              absorbing: Configuration.instance.isModernLayout ? false : true,
              child: Opacity(
                opacity: Configuration.instance.isModernLayout ? 1.0 : 0.7,
                child: CustomSwitchListTileModern(
                  icon: Broken.notification_status,
                  title: Language.instance.DISPLAY_ALBUM_CARD_TOP_RIGHT_DATE,
                  subtitle: Language
                      .instance.DISPLAY_ALBUM_CARD_TOP_RIGHT_DATE_SUBTITLE,
                  onChanged: (_) => Configuration.instance
                      .save(
                    albumCardTopRightDate:
                        !Configuration.instance.albumCardTopRightDate,
                  )
                      .then((_) {
                    setState(() {});
                  }),
                  value: Configuration.instance.albumCardTopRightDate,
                ),
              ),
            ),
          CustomSwitchListTileModern(
            icon: Broken.crop,
            title: Language.instance.FORCE_SQUARED_ALBUM_THUMBNAIL,
            onChanged: (_) => Configuration.instance
                .save(
              forceSquaredAlbumThumbnail:
                  !Configuration.instance.forceSquaredAlbumThumbnail,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.forceSquaredAlbumThumbnail,
          ),
          CustomSwitchListTileModern(
            icon: Broken.element_4,
            title: Language.instance.STAGGERED_ALBUM_GRID_VIEW,
            onChanged: (_) => Configuration.instance
                .save(
              useAlbumStaggeredGridView:
                  !Configuration.instance.useAlbumStaggeredGridView,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.useAlbumStaggeredGridView,
          ),
          // Album Thumbnail Size in List
          CustomListTileModern(
            icon: Broken.maximize_3,
            title: Language.instance.ALBUM_THUMBNAIL_SIZE_IN_LIST,
            trailing: Text(
              "${Configuration.instance.albumThumbnailSizeinList.toInt()}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            onTap: () {
              showSettingDialogWithTextField(
                  title: Language.instance.ALBUM_THUMBNAIL_SIZE_IN_LIST,
                  context: context,
                  setState: () {
                    setState(() {});
                  },
                  albumThumbnailSizeinList: true);
            },
          ),
          // Album Tile Height
          CustomListTileModern(
            icon: Broken.pharagraphspacing,
            title: Language.instance.HEIGHT_OF_ALBUM_TILE,
            trailing: Text(
              "${Configuration.instance.albumListTileHeight.toInt()}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            onTap: () {
              showSettingDialogWithTextField(
                  title: Language.instance.HEIGHT_OF_ALBUM_TILE,
                  context: context,
                  setState: () {
                    setState(() {});
                  },
                  albumListTileHeight: true);
            },
          ),
        ],
      ),
    );
  }
}
