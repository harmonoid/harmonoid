/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:drop_shadow/drop_shadow.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/modern_layout/rendering_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/widgets_modern.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/utils/rendering.dart';

class TrackTileCustomization extends StatelessWidget {
  final Color? currentTrackColor;
  TrackTileCustomization({super.key, this.currentTrackColor});

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
                  Broken.music_circle,
                  size: 14,
                  color: currentTrackColor,
                ),
              ),
            )
          ],
        ),
        title: Text(
          Language.instance.TRACK_TILE_CUSTOMIZATION,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        trailing: Icon(
          Broken.arrow_down_2,
        ),
        children: [
          CustomSwitchListTileModern(
            icon: Broken.crop,
            title: Language.instance.FORCE_SQUARED_TRACK_THUMBNAIL,
            onChanged: (_) => Configuration.instance
                .save(
              forceSquaredTrackThumbnail:
                  !Configuration.instance.forceSquaredTrackThumbnail,
            )
                .then((_) {
              setState(() {});
            }),
            value: Configuration.instance.forceSquaredTrackThumbnail,
          ),
          CustomListTileModern(
            icon: Broken.maximize_3,
            title: Language.instance.TRACK_THUMBNAIL_SIZE_IN_LIST,
            trailing: Text(
              "${Configuration.instance.trackThumbnailSizeinList.toInt()}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            onTap: () {
              showSettingDialogWithTextField(
                  title: Language.instance.TRACK_THUMBNAIL_SIZE_IN_LIST,
                  context: context,
                  setState: () {
                    setState(() {});
                  },
                  trackThumbnailSizeinList: true);
            },
          ),
          CustomListTileModern(
            icon: Broken.pharagraphspacing,
            title: Language.instance.HEIGHT_OF_TRACK_TILE,
            trailing: Text(
              "${Configuration.instance.trackListTileHeight.toInt()}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            onTap: () {
              showSettingDialogWithTextField(
                  title: Language.instance.HEIGHT_OF_TRACK_TILE,
                  context: context,
                  setState: () {
                    setState(() {});
                  },
                  trackListTileHeight: true);
            },
          ),
          CustomSwitchListTileModern(
            leading: RotatedBox(
              quarterTurns: 3,
              child: Icon(
                Broken.coin,
                color: NowPlayingColorPalette.instance.modernColor,
              ),
            ),
            title: Language.instance.DISPLAY_THIRD_ITEM_IN_ROW_IN_TRACK_TILE,
            onChanged: (_) => Configuration.instance
                .save(
                  trackTileDisplayThirdItemInRows:
                      !Configuration.instance.trackTileDisplayThirdItemInRows,
                )
                .then((value) => setState(() {})),
            value: Configuration.instance.trackTileDisplayThirdItemInRows,
          ),
          CustomSwitchListTileModern(
            leading: RotatedBox(
              quarterTurns: 1,
              child: Icon(
                Broken.chart_1,
                color: NowPlayingColorPalette.instance.modernColor,
              ),
            ),
            title: Language.instance.DISPLAY_THIRD_ROW_IN_TRACK_TILE,
            onChanged: (_) => Configuration.instance
                .save(
                  trackTileDisplayThirdRow:
                      !Configuration.instance.trackTileDisplayThirdRow,
                )
                .then((value) => setState(() {})),
            value: Configuration.instance.trackTileDisplayThirdRow,
          ),
          CustomListTileModern(
            icon: Broken.minus_square,
            title: Language.instance.TRACK_TILE_ITEMS_SEPARATOR,
            trailing: Text(
              "${Configuration.instance.trackTileSeparator}",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            onTap: () {
              showSettingDialogWithTextField(
                  title: Language.instance.TRACK_TILE_ITEMS_SEPARATOR,
                  context: context,
                  setState: () {
                    setState(() {});
                  },
                  trackTileSeparator: true);
            },
          ),
          Container(
            color: Theme.of(context).cardTheme.color,
            width: MediaQuery.of(context).size.width,
            height: Configuration.instance.trackListTileHeight * 1.4,
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 6.0),
                SizedBox(
                  width: Configuration.instance.trackThumbnailSizeinList,
                  height: Configuration.instance.trackThumbnailSizeinList,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          12 * Configuration.instance.borderRadiusMultiplier),
                      child: DropShadow(
                        borderRadius:
                            8 * Configuration.instance.borderRadiusMultiplier,
                        blurRadius: 2,
                        spread: 1,
                        offset: Offset(0, 1),
                        child: ExtendedImage(
                          image: Image(
                            image: AssetImage(
                                "assets/images/default_album_art.png"),
                            height: 10,
                          ).image,
                          fit: BoxFit.cover,
                          width:
                              Configuration.instance.forceSquaredTrackThumbnail
                                  ? MediaQuery.of(context).size.width
                                  : null,
                          height:
                              Configuration.instance.forceSquaredTrackThumbnail
                                  ? MediaQuery.of(context).size.width
                                  : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6.0),
                Flexible(
                  flex: 15,
                  child: FittedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Row(
                            children: [
                              FittedBox(
                                child: TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8 *
                                                      Configuration.instance
                                                          .borderRadiusMultiplier))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).cardColor)),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialogueWithRadioList(
                                              context: context,
                                              valueToBeChanged: Configuration
                                                  .instance
                                                  .trackTileFirstRowFirstItem,
                                              functionToSaveTheValue:
                                                  (e) async {
                                                if (e != null) {
                                                  setState(() => Configuration
                                                      .instance
                                                      .trackTileFirstRowFirstItem = e);

                                                  await Configuration.instance
                                                      .save(
                                                    trackTileFirstRowFirstItem:
                                                        Configuration.instance
                                                            .trackTileFirstRowFirstItem,
                                                  );
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .maybePop();
                                                  setState(() {});
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500));
                                                }
                                              });
                                        });
                                  },
                                  child: Text(
                                    "${Configuration.instance.trackTileFirstRowFirstItem}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                "${Configuration.instance.trackTileSeparator}",
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              SizedBox(width: 6.0),
                              FittedBox(
                                child: TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8 *
                                                      Configuration.instance
                                                          .borderRadiusMultiplier))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).cardColor)),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialogueWithRadioList(
                                              context: context,
                                              valueToBeChanged: Configuration
                                                  .instance
                                                  .trackTileFirstRowSecondItem,
                                              functionToSaveTheValue:
                                                  (e) async {
                                                if (e != null) {
                                                  setState(() => Configuration
                                                      .instance
                                                      .trackTileFirstRowSecondItem = e);

                                                  await Configuration.instance
                                                      .save(
                                                    trackTileFirstRowSecondItem:
                                                        Configuration.instance
                                                            .trackTileFirstRowSecondItem,
                                                  );
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .maybePop();
                                                  setState(() {});
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500));
                                                }
                                              });
                                        });
                                  },
                                  child: Text(
                                    "${Configuration.instance.trackTileFirstRowSecondItem}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.0),
                              if (Configuration.instance
                                  .trackTileDisplayThirdItemInRows) ...[
                                Text(
                                  "${Configuration.instance.trackTileSeparator}",
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                SizedBox(width: 6.0),
                                FittedBox(
                                  child: TextButton(
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8 *
                                                        Configuration.instance
                                                            .borderRadiusMultiplier))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context).cardColor)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialogueWithRadioList(
                                                context: context,
                                                valueToBeChanged: Configuration
                                                    .instance
                                                    .trackTileFirstRowThirdItem,
                                                functionToSaveTheValue:
                                                    (e) async {
                                                  if (e != null) {
                                                    setState(() => Configuration
                                                        .instance
                                                        .trackTileFirstRowThirdItem = e);

                                                    await Configuration.instance
                                                        .save(
                                                      trackTileFirstRowThirdItem:
                                                          Configuration.instance
                                                              .trackTileFirstRowThirdItem,
                                                    );
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .maybePop();
                                                    setState(() {});
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500));
                                                  }
                                                });
                                          });
                                    },
                                    child: Text(
                                      "${Configuration.instance.trackTileFirstRowThirdItem}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium,
                                    ),
                                  ),
                                )
                              ],
                            ],
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              FittedBox(
                                child: TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8 *
                                                      Configuration.instance
                                                          .borderRadiusMultiplier))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).cardColor)),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialogueWithRadioList(
                                              context: context,
                                              valueToBeChanged: Configuration
                                                  .instance
                                                  .trackTileSecondRowFirstItem,
                                              functionToSaveTheValue:
                                                  (e) async {
                                                if (e != null) {
                                                  setState(() => Configuration
                                                      .instance
                                                      .trackTileSecondRowFirstItem = e);

                                                  await Configuration.instance
                                                      .save(
                                                    trackTileSecondRowFirstItem:
                                                        Configuration.instance
                                                            .trackTileSecondRowFirstItem,
                                                  );
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .maybePop();
                                                  setState(() {});
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500));
                                                }
                                              });
                                        });
                                  },
                                  child: Text(
                                    "${Configuration.instance.trackTileSecondRowFirstItem}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                "${Configuration.instance.trackTileSeparator}",
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              SizedBox(width: 6.0),
                              FittedBox(
                                child: TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8 *
                                                      Configuration.instance
                                                          .borderRadiusMultiplier))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).cardColor)),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialogueWithRadioList(
                                              context: context,
                                              valueToBeChanged: Configuration
                                                  .instance
                                                  .trackTileSecondRowSecondItem,
                                              functionToSaveTheValue:
                                                  (e) async {
                                                if (e != null) {
                                                  setState(() => Configuration
                                                      .instance
                                                      .trackTileSecondRowSecondItem = e);

                                                  await Configuration.instance
                                                      .save(
                                                    trackTileSecondRowSecondItem:
                                                        Configuration.instance
                                                            .trackTileSecondRowSecondItem,
                                                  );
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .maybePop();
                                                  setState(() {});
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500));
                                                }
                                              });
                                        });
                                  },
                                  child: Text(
                                    "${Configuration.instance.trackTileSecondRowSecondItem}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.0),
                              if (Configuration.instance
                                  .trackTileDisplayThirdItemInRows) ...[
                                Text(
                                  "${Configuration.instance.trackTileSeparator}",
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                SizedBox(width: 6.0),
                                FittedBox(
                                  child: TextButton(
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8 *
                                                        Configuration.instance
                                                            .borderRadiusMultiplier))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context).cardColor)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialogueWithRadioList(
                                                context: context,
                                                valueToBeChanged: Configuration
                                                    .instance
                                                    .trackTileSecondRowThirdItem,
                                                functionToSaveTheValue:
                                                    (e) async {
                                                  if (e != null) {
                                                    setState(() => Configuration
                                                        .instance
                                                        .trackTileSecondRowThirdItem = e);

                                                    await Configuration.instance
                                                        .save(
                                                      trackTileSecondRowThirdItem:
                                                          Configuration.instance
                                                              .trackTileSecondRowThirdItem,
                                                    );
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .maybePop();
                                                    setState(() {});
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500));
                                                  }
                                                });
                                          });
                                    },
                                    child: Text(
                                      "${Configuration.instance.trackTileSecondRowThirdItem}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                  ),
                                )
                              ],
                            ],
                          ),
                        ),
                        if (Configuration.instance.trackTileDisplayThirdRow)
                          FittedBox(
                            child: Row(
                              children: [
                                FittedBox(
                                  child: TextButton(
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8 *
                                                        Configuration.instance
                                                            .borderRadiusMultiplier))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context).cardColor)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialogueWithRadioList(
                                                context: context,
                                                valueToBeChanged: Configuration
                                                    .instance
                                                    .trackTileThirdRowFirstItem,
                                                functionToSaveTheValue:
                                                    (e) async {
                                                  if (e != null) {
                                                    setState(() => Configuration
                                                        .instance
                                                        .trackTileThirdRowFirstItem = e);

                                                    await Configuration.instance
                                                        .save(
                                                      trackTileThirdRowFirstItem:
                                                          Configuration.instance
                                                              .trackTileThirdRowFirstItem,
                                                    );
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .maybePop();
                                                    setState(() {});
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500));
                                                  }
                                                });
                                          });
                                    },
                                    child: Text(
                                      "${Configuration.instance.trackTileThirdRowFirstItem}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.0),
                                Text(
                                  "${Configuration.instance.trackTileSeparator}",
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                SizedBox(width: 6.0),
                                FittedBox(
                                  child: TextButton(
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8 *
                                                        Configuration.instance
                                                            .borderRadiusMultiplier))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context).cardColor)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialogueWithRadioList(
                                                context: context,
                                                valueToBeChanged: Configuration
                                                    .instance
                                                    .trackTileThirdRowSecondItem,
                                                functionToSaveTheValue:
                                                    (e) async {
                                                  if (e != null) {
                                                    setState(() => Configuration
                                                        .instance
                                                        .trackTileThirdRowSecondItem = e);

                                                    await Configuration.instance
                                                        .save(
                                                      trackTileThirdRowSecondItem:
                                                          Configuration.instance
                                                              .trackTileThirdRowSecondItem,
                                                    );
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .maybePop();
                                                    setState(() {});
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500));
                                                  }
                                                });
                                          });
                                    },
                                    child: Text(
                                      "${Configuration.instance.trackTileThirdRowSecondItem}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.0),
                                if (Configuration.instance
                                    .trackTileDisplayThirdItemInRows) ...[
                                  Text(
                                    "${Configuration.instance.trackTileSeparator}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                  SizedBox(width: 6.0),
                                  FittedBox(
                                    child: TextButton(
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8 *
                                                          Configuration.instance
                                                              .borderRadiusMultiplier))),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Theme.of(context).cardColor)),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialogueWithRadioList(
                                                  context: context,
                                                  valueToBeChanged: Configuration
                                                      .instance
                                                      .trackTileThirdRowThirdItem,
                                                  functionToSaveTheValue:
                                                      (e) async {
                                                    if (e != null) {
                                                      setState(() => Configuration
                                                          .instance
                                                          .trackTileThirdRowThirdItem = e);

                                                      await Configuration
                                                          .instance
                                                          .save(
                                                        trackTileThirdRowThirdItem:
                                                            Configuration
                                                                .instance
                                                                .trackTileThirdRowThirdItem,
                                                      );
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .maybePop();
                                                      setState(() {});
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500));
                                                    }
                                                  });
                                            });
                                      },
                                      child: Text(
                                        "${Configuration.instance.trackTileThirdRowThirdItem}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall,
                                      ),
                                    ),
                                  )
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        child: TextButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8 *
                                          Configuration.instance
                                              .borderRadiusMultiplier))),
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).cardColor)),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialogueWithRadioList(
                                      context: context,
                                      valueToBeChanged: Configuration
                                          .instance.trackTileRightFirstItem,
                                      functionToSaveTheValue: (e) async {
                                        if (e != null) {
                                          setState(() => Configuration.instance
                                              .trackTileRightFirstItem = e);

                                          await Configuration.instance.save(
                                            trackTileRightFirstItem:
                                                Configuration.instance
                                                    .trackTileRightFirstItem,
                                          );
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .maybePop();
                                          setState(() {});
                                          await Future.delayed(const Duration(
                                              milliseconds: 500));
                                        }
                                      });
                                });
                          },
                          child: Text(
                            "${Configuration.instance.trackTileRightFirstItem}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                      ),
                      FittedBox(
                        child: TextButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8 *
                                          Configuration.instance
                                              .borderRadiusMultiplier))),
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).cardColor)),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialogueWithRadioList(
                                      context: context,
                                      valueToBeChanged: Configuration
                                          .instance.trackTileRightSecondItem,
                                      functionToSaveTheValue: (e) async {
                                        if (e != null) {
                                          setState(() => Configuration.instance
                                              .trackTileRightSecondItem = e);

                                          await Configuration.instance.save(
                                            trackTileRightSecondItem:
                                                Configuration.instance
                                                    .trackTileRightSecondItem,
                                          );
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .maybePop();
                                          setState(() {});
                                          await Future.delayed(const Duration(
                                              milliseconds: 500));
                                        }
                                      });
                                });
                          },
                          child: Text(
                            "${Configuration.instance.trackTileRightSecondItem}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46.0,
                  height: 46.0,
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: null,
                    icon: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(Broken.more),
                    ),
                    iconSize: 24.0,
                    splashRadius: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListTileAlertDialogueWithRadioList extends StatefulWidget {
  final BuildContext context;
  final String valueToBeChanged;
  final Function(String?)? functionToSaveTheValue;
  ListTileAlertDialogueWithRadioList({
    super.key,
    required this.context,
    required this.valueToBeChanged,
    required this.functionToSaveTheValue,
  });

  @override
  State<ListTileAlertDialogueWithRadioList> createState() =>
      _ListTileAlertDialogueWithRadioListState();
}

class _ListTileAlertDialogueWithRadioListState
    extends State<ListTileAlertDialogueWithRadioList> {
  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return ListTile(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(
                      12.0 * Configuration.instance.borderRadiusMultiplier))),
              content: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: kDefaultTrackTileInfoChoose.entries
                          .map(
                            (e) => RadioListTile<String>(
                              activeColor:
                                  Theme.of(context).colorScheme.secondary,
                              groupValue: widget.valueToBeChanged,
                              value: e.key,
                              onChanged: widget.functionToSaveTheValue,
                              title: Text(
                                '${e.value}',
                                style: isDesktop
                                    ? Theme.of(context).textTheme.headlineMedium
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      leading: Text(
        Language.instance.DATE_TIME_FORMAT,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black),
      ),
      trailing: Text(
        "${Configuration.instance.trackTileFirstRowFirstItem}",
        style: Theme.of(context)
            .textTheme
            .displayMedium
            ?.copyWith(color: Colors.grey[500]),
      ),
    );
  }
}

class AlertDialogueWithRadioList extends StatefulWidget {
  final BuildContext context;
  final String valueToBeChanged;
  final Function(String?)? functionToSaveTheValue;
  AlertDialogueWithRadioList({
    super.key,
    required this.context,
    required this.valueToBeChanged,
    required this.functionToSaveTheValue,
  });

  @override
  State<AlertDialogueWithRadioList> createState() =>
      _AlertDialogueWithRadioListState();
}

class _AlertDialogueWithRadioListState
    extends State<AlertDialogueWithRadioList> {
  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      insetPadding: EdgeInsets.all(50),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(
              12.0 * Configuration.instance.borderRadiusMultiplier))),
      content: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: kDefaultTrackTileInfoChoose.entries
                  .map(
                    (e) => RadioListTile<String>(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      groupValue: widget.valueToBeChanged,
                      value: e.key,
                      onChanged: widget.functionToSaveTheValue,
                      title: Text(
                        '${e.value}',
                        style: isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

const kDefaultTrackTileInfoChoose = {
  'none': 'None',
  'trackName': 'Track Name',
  'artistNames': 'Artist Names',
  'albumName': 'Album Name',
  'albumArtistName': 'Album Artist Name',
  'genre': 'Genre',
  'duration': 'Duration',
  'year': 'Year',
  'trackNumber': 'Track Number',
  'discNumber': 'Disk Number',
  'filenamenoext': 'File Name Without Extension',
  'extension': 'Extension',
  'filename': 'File Name',
  'folder': 'Folder Name',
  'uri': 'File Full Path',
  'bitrate': 'Bitrate',
  'timeAddedDate': 'Time Added in Date',
  'timeAddedClock': 'Time Added in Hour',
  'timeAdded': 'Time Added (Date, Hour)',
};
