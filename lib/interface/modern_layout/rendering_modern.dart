/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:media_library/media_library.dart';
import 'package:extended_image/extended_image.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/interface/modern_layout/buttons_widgets/buttons.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_playlist.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/home.dart';
import 'package:harmonoid/interface/file_info_screen.dart';
import 'package:harmonoid/interface/edit_details_screen.dart';
import 'package:harmonoid/interface/modern_layout/modern_collection/modern_album.dart';
import 'package:harmonoid/state/lyrics.dart';
import 'package:harmonoid/utils/widgets.dart';
export 'package:harmonoid/utils/extensions.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/palette_generator.dart';
import 'package:harmonoid/utils/storage_retriever.dart';
import 'package:harmonoid/constants/language.dart';

Future<void> showAddToPlaylistDialogModern(
  BuildContext context,
  List<Track> tracks, {
  bool elevated = false,
}) {
  final playlists = Collection.instance.playlists.toList();
  if (isDesktop) {
    return showDialog(
      context: context,
      builder: (subContext) => AlertDialog(
        contentPadding: EdgeInsets.only(top: 20.0),
        title: Text(Language.instance.PLAYLIST_ADD_DIALOG_TITLE),
        content: Container(
          height: 480.0,
          width: 512.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1.0,
              ),
              Expanded(
                child: CustomListViewBuilder(
                  itemExtents: List.generate(
                    playlists.length,
                    (index) => 64.0 + 9.0,
                  ),
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, i) => PlaylistTileModern(
                    playlistIndex: i,
                    playlist: playlists[i],
                    onTap: () async {
                      await Collection.instance.playlistAddTracks(
                        playlists[i],
                        tracks,
                      );
                      Navigator.of(subContext).pop();
                    },
                  ),
                ),
              ),
              Divider(
                height: 1.0,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(subContext).pop,
            child: Text(Language.instance.CANCEL),
          ),
        ],
      ),
    );
  } else {
    if (elevated) {
      return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) => Card(
          margin: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            bottom: kBottomNavigationBarHeight + 8.0,
          ),
          elevation: kDefaultHeavyElevation,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, controller) => ListView.builder(
              padding: EdgeInsets.zero,
              controller: controller,
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (context, i) {
                return PlaylistTileModern(
                  playlistIndex: i,
                  playlist: playlists[i],
                  onTap: () async {
                    await Collection.instance.playlistAddTracks(
                      playlists[i],
                      tracks,
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),
      );
    }
    return showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Dialog(
          clipBehavior: Clip.antiAlias,
          backgroundColor: Color.alphaBlend(
              NowPlayingColorPalette.instance.modernColor.withAlpha(20),
              Theme.of(context).brightness == Brightness.light
                  ? Color.fromARGB(255, 234, 234, 234)
                  : Color.fromARGB(255, 24, 24, 24)),
          insetPadding: EdgeInsets.all(30.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(
                  20.0 * Configuration.instance.borderRadiusMultiplier))),
          child: Consumer<Collection>(
            builder: (context, collection, _) {
              return Column(
                children: [
                  Container(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Broken.music_library_2,
                            size: 20.0,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Text(
                            "${Language.instance.ADD_TO_PLAYLIST}",
                            style: Theme.of(context).textTheme.displayMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )),
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: collection.playlists.length,
                      itemBuilder: (context, i) {
                        return PlaylistTileModern(
                          playlistIndex: i,
                          playlist: collection.playlists.toList()[i],
                          onTap: () async {
                            await Collection.instance.playlistAddTracks(
                              collection.playlists.toList()[i],
                              tracks,
                            );
                            // Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 12.0,
                        ),
                        Expanded(
                          child: Text(
                            "${Collection.instance.playlists.length}",
                            style: Theme.of(context).textTheme.displayMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FittedBox(child: ImportPlaylistButton()),
                        SizedBox(
                          width: 8.0,
                        ),
                        FittedBox(child: CreatePlaylistButton()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String getDateFormatted(String date) {
  final formatDate = DateFormat('${Configuration.instance.dateTimeFormat}');
  final dateFormatted =
      date.length == 8 ? formatDate.format(DateTime.parse(date)) : date;

  return dateFormatted;
}

/// Simple method to get total album duration in seconds
int getTotalTracksDuration({Album? album, required List<Track> tracks}) {
  int totalAlbumDuration = 0;
  for (int j = 0; j < tracks.length; j++) {
    totalAlbumDuration += tracks[j].duration!.inSeconds;
  }
  return totalAlbumDuration;
}

String getTotalTracksDurationFormatted(
    {Album? album, required List<Track> tracks}) {
  int totalAlbumDuration = getTotalTracksDuration(tracks: tracks);
  String formattedTotalAlbumDuration =
      "${Duration(seconds: totalAlbumDuration).inHours == 0 ? "" : "${Duration(seconds: totalAlbumDuration).inHours} h "}${Duration(seconds: totalAlbumDuration).inMinutes.remainder(60) == 0 ? "" : "${Duration(seconds: totalAlbumDuration).inMinutes.remainder(60) + 1} min"}";
  return formattedTotalAlbumDuration;
}

/// Simple method to get all artists inside an album
List<String> getArtistsInsideAlbum(
    {required Album album, required List<Track> tracks}) {
  List<String> allArtistsInsideAlbum = [];

  for (int j = 0; j < tracks.length; j++) {
    allArtistsInsideAlbum += tracks[j].trackArtistNames;
  }
  List<String> allArtistsInsideAlbumNoDuplicate =
      allArtistsInsideAlbum.toSet().toList();
  return allArtistsInsideAlbumNoDuplicate;
}

Future<Color?> getAlbumColorSingleModern(
    {required Media media, context}) async {
  Color? palette;
  final ImageProvider<Object> resizedImage = ResizeImage(
      getAlbumArt(
        media,
        // small: true,
        // cacheWidth: MediaQuery.of(context).devicePixelRatio ~/ 1,
      ),
      height: 10,
      width: null);

  final result = await PaletteGenerator.fromImageProvider(
    resizedImage,
  ).then((result) {
    palette = result.vibrantColor?.color ??
        result.darkMutedColor?.color ??
        result.mutedColor?.color;
    return palette;
  });

  return result;
}

Color getAlbumColorModifiedModern(List<Color>? value) {
  final Color color;
  if ((value?.length ?? 0) > 9) {
    color = Color.alphaBlend(
        value?.first.withAlpha(140) ?? Colors.transparent,
        Color.alphaBlend(
            value?.elementAt(7).withAlpha(155) ?? Colors.transparent,
            value?.elementAt(9) ?? Colors.transparent));
  } else {
    color = Color.alphaBlend(value?.last.withAlpha(50) ?? Colors.transparent,
        value?.first ?? Colors.transparent);
  }
  HSLColor hslColor = HSLColor.fromColor(color);
  Color colorDelightened;
  if (hslColor.lightness > 0.65) {
    hslColor = hslColor.withLightness(0.55);
    colorDelightened = hslColor.toColor();
  } else {
    colorDelightened = color;
  }
  colorDelightened =
      Color.alphaBlend(Colors.white.withAlpha(20), colorDelightened);
  return colorDelightened;
}

// Method to Get All Album Images Height for StaggeredGridView

// Future<int> getAllAlbumsImageHeight({required List<Album> albums}) async {
//   int imagesHeight = 0;

//   for (int j = 0; j < albums.length; j++) {
//     Completer<ImageInfo> completer = Completer();
//     Image albumImage = Image(
//       image: getAlbumArt(albums[j]),
//     );
//     albumImage.image
//         .resolve(new ImageConfiguration())
//         .addListener(ImageStreamListener((ImageInfo info, bool _) {
//       completer.complete(info);
//     }));
//     ImageInfo imageInfo = await completer.future;
//     int finalheight = imageInfo.image.height;
//     imagesHeight += finalheight;
//   }
//   print("images height: ${imagesHeight}");
//   // print("length: ${albums.length}");

//   int averageImagesHeight = imagesHeight ~/ (albums.length * 2) ~/ 2.1;
//   print("length: ${averageImagesHeight}");
//   return Future.value(averageImagesHeight);
// }

class CustomDialogueModern extends StatelessWidget {
  final Color? colorDelightened;
  final Widget child;
  CustomDialogueModern({super.key, this.colorDelightened, required this.child});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Dialog(
            clipBehavior: Clip.antiAlias,
            backgroundColor: Color.alphaBlend(
                colorDelightened?.withAlpha(20) ??
                    NowPlayingColorPalette.instance.modernColor.withAlpha(20),
                Theme.of(context).brightness == Brightness.light
                    ? Color.fromARGB(255, 234, 234, 234)
                    : Color.fromARGB(255, 24, 24, 24)),
            insetPadding: EdgeInsets.all(38.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(
                    20.0 * Configuration.instance.borderRadiusMultiplier))),
            child: Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.white.withAlpha(10),
                  listTileTheme: ListTileThemeData(
                    horizontalTitleGap: 4.0,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  ),
                ),
                child: child)));
  }
}

void showPlaylistDialog(
    BuildContext context, Playlist playlist, int playlistIndex,
    [Widget? leading]) async {
  int? result;
  final playlistItems = playlistPopupMenuItemsModern(context).map((item) {
    return PopupMenuItem<int>(
      value: item.value,
      onTap: () {
        result = item.value;
      },
      child: item.child,
    );
  }).toList();
  await showDialog(
    context: context,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                highlightColor: Color.fromARGB(60, 0, 0, 0),
                splashColor: Colors.transparent,
                onTap: () async {
                  PlaylistScreenModern(
                    playlist: playlist,
                    playlistIndex: playlistIndex,
                  );
                  Playback.instance.interceptPositionChangeRebuilds = true;
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FadeThroughTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        child: PlaylistScreenModern(
                          playlist: playlist,
                          playlistIndex: playlistIndex,
                        ),
                      ),
                    ),
                  );
                  Timer(
                    const Duration(milliseconds: 400),
                    () {
                      Playback.instance.interceptPositionChangeRebuilds = false;
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16.0),
                      leading ??
                          PlaylistThumbnailModern(
                              tracks: playlist.tracks, width: 64.0),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(playlist.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontSize: 17,
                                      color: Color.alphaBlend(
                                          NowPlayingColorPalette
                                              .instance.modernColor
                                              .withAlpha(40),
                                          Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .color!),
                                    )),
                            const SizedBox(
                              height: 1.0,
                            ),
                            Text(
                              playlist.tracks.length.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    fontSize: 14,
                                    color: Color.alphaBlend(
                                        NowPlayingColorPalette
                                            .instance.modernColor
                                            .withAlpha(80),
                                        Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .color!),
                                  ),
                            ),
                            const SizedBox(
                              height: 1.0,
                            ),
                            Text(
                              getTotalTracksDurationFormatted(
                                  tracks: playlist.tracks.toList()),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    fontSize: 13,
                                    color: Color.alphaBlend(
                                        NowPlayingColorPalette
                                            .instance.modernColor
                                            .withAlpha(40),
                                        Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color!),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      Icon(
                        Broken.arrow_right_3,
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: Theme.of(context).dividerColor.withAlpha(40),
                thickness: 1,
                height: 0,
              ),
              // const SizedBox(height: 4.0),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: playlistItems.sublist(0, playlistItems.length - 2),
              ),
              // const SizedBox(height: 4.0),
              Divider(
                color: Theme.of(context).dividerColor.withAlpha(40),
                thickness: 1,
                height: 0,
              ),
              Container(
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child:
                            playlistItems.elementAt(playlistItems.length - 2),
                      ),
                      VerticalDivider(
                        color: Theme.of(context).dividerColor.withAlpha(40),
                        thickness: 1,
                        width: 0,
                      ),
                      Expanded(
                        child:
                            playlistItems.elementAt(playlistItems.length - 1),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
  await playlistPopupMenuHandleModern(
    context,
    playlist,
    result,
  );
}

List<PopupMenuItem<int>> playlistPopupMenuItemsModern(
  BuildContext context,
  // Color playlistColor,
) {
  // playlistColor = Color.alphaBlend(playlistColor.withAlpha(170), Theme.of(context).colorScheme.onBackground);
  final TextStyle? textStyle =
      Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 15);

  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Icon(Platform.isWindows
            ? FluentIcons.play_24_regular
            : Broken.play_circle),
        title: Text(
          Language.instance.PLAY,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 1,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Icon(Platform.isWindows
            ? FluentIcons.arrow_shuffle_24_regular
            : Broken.shuffle),
        title: Text(
          Language.instance.SHUFFLE,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 5,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Icon(Platform.isWindows
            ? FluentIcons.add_12_filled
            : Broken.music_playlist),
        title: Text(
          Language.instance.ADD_TO_PLAYLIST,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Icon(Platform.isWindows
            ? FluentIcons.delete_16_regular
            : Broken.music_square_remove),
        title: Text(
          Language.instance.DELETE,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 6,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Icon(
          Platform.isWindows ? FluentIcons.rename_16_regular : Broken.text,
        ),
        title: Text(
          Language.instance.RENAME,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 4,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading:
            Icon(Platform.isWindows ? FluentIcons.next_16_filled : Broken.next),
        title: Text(
          Language.instance.PLAY_NEXT,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Icon(Platform.isWindows
            ? FluentIcons.music_note_2_16_regular
            : Iconsax.play_add),
        title: Text(
          Language.instance.PLAY_LAST,
          style: isDesktop ? Theme.of(context).textTheme.headlineMedium : null,
        ),
      ),
    ),
  ];
}

Future<void> playlistPopupMenuHandleModern(
  BuildContext context,
  Playlist playlist,
  int? result,
) async {
  final tracks = playlist.tracks.toList();
  tracks.sort(
    (first, second) =>
        first.discNumber.compareTo(second.discNumber) * 100000000 +
        first.trackNumber.compareTo(second.trackNumber) * 1000000 +
        first.trackName.compareTo(second.trackName) * 10000 +
        first.trackArtistNames
                .join()
                .compareTo(second.trackArtistNames.join()) *
            100 +
        first.uri.toString().compareTo(second.uri.toString()),
  );
  if (result != null) {
    switch (result) {
      case 0:
        await Playback.instance.open(tracks);
        break;
      case 1:
        await Playback.instance.open(tracks..shuffle());
        break;
      case 3:
        await Playback.instance.add(tracks);
        break;
      case 4:
        await Playback.instance.insertAt(tracks, Playback.instance.index + 1);
        break;
      case 5:
        await showAddToPlaylistDialogModern(context, tracks);
        break;
      case 2:
        {
          await showDialog(
            context: context,
            builder: (subContext) => AlertDialog(
              title: Text(
                Language.instance.COLLECTION_PLAYLIST_DELETE_DIALOG_HEADER,
              ),
              content: Text(
                Language.instance.COLLECTION_PLAYLIST_DELETE_DIALOG_BODY
                    .replaceAll(
                  'NAME',
                  '${playlist.name}',
                ),
                style: Theme.of(subContext).textTheme.displaySmall,
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Collection.instance.playlistDelete(playlist);
                    Navigator.of(subContext).pop();
                  },
                  child: Text(Language.instance.YES),
                ),
                TextButton(
                  onPressed: Navigator.of(subContext).pop,
                  child: Text(Language.instance.NO),
                ),
              ],
            ),
          );
          break;
        }
      case 6:
        {
          if (isDesktop) {
            String rename = playlist.name;
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  Language.instance.RENAME,
                ),
                content: Container(
                  height: 40.0,
                  width: 280.0,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                  padding: EdgeInsets.only(top: 2.0),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        HotKeys.instance.disableSpaceHotKey();
                      } else {
                        HotKeys.instance.enableSpaceHotKey();
                      }
                    },
                    child: TextFormField(
                      initialValue: playlist.name,
                      autofocus: true,
                      cursorWidth: 1.0,
                      onChanged: (value) => rename = value,
                      onFieldSubmitted: (String value) async {
                        if (value.isNotEmpty && value != playlist.name) {
                          playlist.name = value;
                          Collection.instance.playlistsSaveToCache();
                          Navigator.of(context).maybePop();
                          // setState(() {});
                        }
                      },
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: inputDecoration(
                        context,
                        Language.instance.PLAYLISTS_TEXT_FIELD_LABEL,
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(
                      Language.instance.OK,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () async {
                      if (rename.isNotEmpty && rename != playlist.name) {
                        playlist.name = rename;
                        Collection.instance.playlistsSaveToCache();
                        Navigator.of(context).maybePop();
                        // setState(() {});
                      }
                    },
                  ),
                  TextButton(
                    child: Text(
                      Language.instance.CANCEL,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: Navigator.of(context).maybePop,
                  ),
                ],
              ),
            );
          }
          if (isMobile) {
            await Navigator.of(context).maybePop();
            String input = '';
            final GlobalKey<FormState> formKey = GlobalKey<FormState>();
            await showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              elevation: kDefaultHeavyElevation,
              useRootNavigator: true,
              builder: (context) => StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4.0),
                        Form(
                          key: formKey,
                          child: TextFormField(
                            initialValue: playlist.name,
                            autofocus: true,
                            autocorrect: false,
                            onChanged: (value) => input = value,
                            keyboardType: TextInputType.url,
                            textCapitalization: TextCapitalization.none,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (value) async {
                              if (value.isNotEmpty && value != playlist.name) {
                                playlist.name = value;
                                Collection.instance.playlistsSaveToCache();
                                Navigator.of(context).maybePop();
                                setState(() {});
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(
                                12,
                                30,
                                12,
                                6,
                              ),
                              hintText:
                                  Language.instance.PLAYLISTS_TEXT_FIELD_LABEL,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color!
                                      .withOpacity(0.4),
                                  width: 1.8,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color!
                                      .withOpacity(0.4),
                                  width: 1.8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.8,
                                ),
                              ),
                              errorStyle: TextStyle(height: 0.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (input.isNotEmpty && input != playlist.name) {
                              playlist.name = input;
                              Collection.instance.playlistsSaveToCache();
                              Navigator.of(context).maybePop();
                              setState(() {});
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Text(
                            Language.instance.RENAME.toUpperCase(),
                            style: const TextStyle(
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          break;
        }

      default:
        break;
    }
  }
}

/*





*/
void showAlbumDialog(BuildContext context, Album album,
    [Widget? leading]) async {
  int? result;
  Iterable<Color>? palette;
  final colors = await PaletteGenerator.fromImageProvider(
    getAlbumArt(album, small: true),
  );
  palette = colors.colors;
  final colorDelightened = getAlbumColorModifiedModern(palette?.toList());
  final albumListItems =
      albumPopupMenuItemsModern(context, colorDelightened).map((item) {
    return PopupMenuItem<int>(
      value: item.value,
      onTap: () {
        result = item.value;
      },
      child: item.child,
    );
  }).toList();
  await showDialog(
    context: context,
    builder: (context) => CustomDialogueModern(
      colorDelightened: colorDelightened,
      child: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              highlightColor: Color.fromARGB(60, 0, 0, 0),
              splashColor: Colors.transparent,
              onTap: () async {
                AlbumScreenModern(
                  album: album,
                  palette: palette,
                );
                Playback.instance.interceptPositionChangeRebuilds = true;
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: AlbumScreenModern(
                        album: album,
                        palette: palette,
                      ),
                    ),
                  ),
                );
                Timer(
                  const Duration(milliseconds: 400),
                  () {
                    Playback.instance.interceptPositionChangeRebuilds = false;
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16.0),
                    leading ??
                        CustomTrackThumbnailModern(
                          scale: 1,
                          borderRadius: 8,
                          blur: 2,
                          media: album,
                        ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(album.albumName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(
                                    fontSize: 17,
                                    color: Color.alphaBlend(
                                        colorDelightened.withAlpha(40),
                                        Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .color!),
                                  )),
                          const SizedBox(
                            height: 1.0,
                          ),
                          Text(
                            getDateFormatted(album.year),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontSize: 14,
                                  color: Color.alphaBlend(
                                      colorDelightened.withAlpha(80),
                                      Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .color!),
                                ),
                          ),
                          const SizedBox(
                            height: 1.0,
                          ),
                          Text(
                            album.albumArtistName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  fontSize: 13,
                                  color: Color.alphaBlend(
                                      colorDelightened.withAlpha(40),
                                      Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .color!),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Icon(
                      Broken.arrow_right_3,
                      color: Color.alphaBlend(colorDelightened.withAlpha(150),
                          Theme.of(context).iconTheme.color!),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Theme.of(context).dividerColor.withAlpha(40),
              thickness: 1,
              height: 0,
            ),
            // const SizedBox(height: 4.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: albumListItems.sublist(0, albumListItems.length - 2),
            ),
            // const SizedBox(height: 4.0),
            Divider(
              color: Theme.of(context).dividerColor.withAlpha(40),
              thickness: 1,
              height: 0,
            ),
            Container(
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child:
                          albumListItems.elementAt(albumListItems.length - 2),
                    ),
                    VerticalDivider(
                      color: Theme.of(context).dividerColor.withAlpha(40),
                      thickness: 1,
                      width: 0,
                    ),
                    Expanded(
                      child:
                          albumListItems.elementAt(albumListItems.length - 1),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
  await albumPopupMenuHandleModern(
    context,
    album,
    result,
  );
}

List<PopupMenuItem<int>> albumPopupMenuItemsModern(
  BuildContext context,
  Color albumColor,
) {
  albumColor = Color.alphaBlend(
      albumColor.withAlpha(170), Theme.of(context).colorScheme.onBackground);
  final TextStyle? textStyle =
      Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 15);

  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.play_24_regular
                : Broken.play_circle,
            color: albumColor),
        title: Text(
          Language.instance.PLAY,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 1,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.arrow_shuffle_24_regular
                : Broken.shuffle,
            color: albumColor),
        title: Text(
          Language.instance.SHUFFLE,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 5,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.add_12_filled
                : Broken.music_playlist,
            color: albumColor),
        title: Text(
          Language.instance.ADD_TO_PLAYLIST,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.delete_16_regular
                : Broken.music_square_remove,
            color: albumColor),
        title: Text(
          Language.instance.DELETE,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 4,
      child: ListTile(
        leading: Icon(
            Platform.isWindows ? FluentIcons.next_16_filled : Broken.next,
            color: albumColor),
        title: Text(
          Language.instance.PLAY_NEXT,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.music_note_2_16_regular
                : Iconsax.play_add,
            color: albumColor),
        title: Text(
          Language.instance.PLAY_LAST,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
  ];
}

Future<void> albumPopupMenuHandleModern(
  BuildContext context,
  Album album,
  int? result,
) async {
  final tracks = album.tracks.toList();
  tracks.sort(
    (first, second) =>
        first.discNumber.compareTo(second.discNumber) * 100000000 +
        first.trackNumber.compareTo(second.trackNumber) * 1000000 +
        first.trackName.compareTo(second.trackName) * 10000 +
        first.trackArtistNames
                .join()
                .compareTo(second.trackArtistNames.join()) *
            100 +
        first.uri.toString().compareTo(second.uri.toString()),
  );
  if (result != null) {
    switch (result) {
      case 0:
        await Playback.instance.open(tracks);
        break;
      case 1:
        await Playback.instance.open(tracks..shuffle());
        break;
      case 2:
        if (Platform.isAndroid) {
          final sdk = StorageRetriever.instance.version;
          if (sdk >= 30) {
            // No [AlertDialog] required for confirmation.
            // Android 11 or higher (API level 30) will ask for permissions from the user before deletion.
            await Collection.instance.delete(album);
            while (Navigator.of(context).canPop()) {
              await Navigator.of(context).maybePop();
            }
            if (floatingSearchBarController.isOpen) {
              floatingSearchBarController.close();
            }
            return;
          }
        }
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              Language.instance.COLLECTION_ALBUM_DELETE_DIALOG_HEADER,
            ),
            content: Text(
              Language.instance.COLLECTION_ALBUM_DELETE_DIALOG_BODY.replaceAll(
                'NAME',
                album.albumName,
              ),
              style: Theme.of(ctx).textTheme.displaySmall,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Collection.instance.delete(album);
                  await Navigator.of(ctx).maybePop();
                  while (Navigator.of(context).canPop()) {
                    await Navigator.of(context).maybePop();
                  }
                  if (floatingSearchBarController.isOpen) {
                    floatingSearchBarController.close();
                  }
                },
                child: Text(Language.instance.YES),
              ),
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(Language.instance.NO),
              ),
            ],
          ),
        );
        break;
      case 3:
        await Playback.instance.add(tracks);
        break;
      case 4:
        await Playback.instance.insertAt(tracks, Playback.instance.index + 1);
        break;
      case 5:
        await showAddToPlaylistDialogModern(context, album.tracks.toList());
        break;
    }
  }
}

void showTrackDialog(BuildContext context, Track track,
    [Widget? leading, Playlist? playlist]) async {
  int? result;
  Iterable<Color>? palette;
  final colors = await PaletteGenerator.fromImageProvider(
    getAlbumArt(track, small: true),
  );
  palette = colors.colors;
  final colorDelightened = getAlbumColorModifiedModern(palette!.toList());
  final trackListItems =
      trackPopupMenuItemsModern(track, context, colorDelightened, playlist)
          .map((item) {
    return PopupMenuItem<int>(
      value: item.value,
      onTap: () {
        result = item.value;
      },
      child: item.child,
    );
  }).toList();
  await showDialog(
    context: context,
    builder: (context) => CustomDialogueModern(
      colorDelightened: colorDelightened,
      child: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              highlightColor: Color.fromARGB(60, 0, 0, 0),
              splashColor: Colors.transparent,
              onTap: () async {
                Iterable<Color>? palette;
                late final Album album;
                for (final item in Collection.instance.albums) {
                  if ((item.albumName == track.albumName &&
                          item.year == track.year) ||
                      (item.albumName == track.albumName &&
                          item.albumArtistName == track.albumArtistName)) {
                    album = item;
                    break;
                  }
                }
                if (isMobile) {
                  final result = await PaletteGenerator.fromImageProvider(
                    getAlbumArt(album, small: true),
                  );
                  palette = result.colors;
                }
                Playback.instance.interceptPositionChangeRebuilds = true;
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: AlbumScreenModern(
                        album: album,
                        palette: palette,
                      ),
                    ),
                  ),
                );
                Timer(
                  const Duration(milliseconds: 400),
                  () {
                    Playback.instance.interceptPositionChangeRebuilds = false;
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16.0),
                    leading ??
                        CustomTrackThumbnailModern(
                          scale: 1,
                          borderRadius: 8,
                          blur: 2,
                          media: track,
                        ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.trackArtistNames.take(5).join(', '),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(
                                    fontSize: 17,
                                    color: Color.alphaBlend(
                                        colorDelightened.withAlpha(40),
                                        Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .color!),
                                  )),
                          const SizedBox(
                            height: 1.0,
                          ),
                          Text(
                            track.trackName.overflow,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontSize: 14,
                                  color: Color.alphaBlend(
                                      colorDelightened.withAlpha(80),
                                      Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .color!),
                                ),
                          ),
                          const SizedBox(
                            height: 1.0,
                          ),
                          Text(
                            track.albumName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  fontSize: 13,
                                  color: Color.alphaBlend(
                                      colorDelightened.withAlpha(40),
                                      Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .color!),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Icon(
                      Broken.arrow_right_3,
                      color: Color.alphaBlend(colorDelightened.withAlpha(150),
                          Theme.of(context).iconTheme.color!),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Theme.of(context).dividerColor.withAlpha(40),
              thickness: 1,
              height: 0,
            ),
            // const SizedBox(height: 4.0),
            Column(
                mainAxisSize: MainAxisSize.min,
                children: trackListItems.sublist(0, trackListItems.length - 2)),
            // const SizedBox(height: 4.0),
            Divider(
              color: Theme.of(context).dividerColor.withAlpha(40),
              thickness: 1,
              height: 0,
            ),
            Container(
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child:
                          trackListItems.elementAt(trackListItems.length - 2),
                    ),
                    VerticalDivider(
                      color: Theme.of(context).dividerColor.withAlpha(40),
                      thickness: 1,
                      width: 0,
                    ),
                    Expanded(
                      child:
                          trackListItems.elementAt(trackListItems.length - 1),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
  await trackPopupMenuHandleModern(
    context,
    track,
    result,
    // Only used in [SearchTab].
    recursivelyPopNavigatorOnDeleteIf: () => true,
    playlist: playlist,
  );
}

List<PopupMenuItem<int>> trackPopupMenuItemsModern(
    Track track, BuildContext context, Color trackColor, Playlist? playlist) {
  trackColor = Color.alphaBlend(
      trackColor.withAlpha(170), Theme.of(context).colorScheme.onBackground);
  final TextStyle? textStyle =
      Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 15);
  return [
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 0,
      child: ListTile(
        leading: Icon(
          Platform.isWindows
              ? FluentIcons.delete_16_regular
              : Broken.music_square_remove,
          color: trackColor,
        ),
        title: Text(
          Language.instance.DELETE,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    if (Platform.isAndroid || Platform.isIOS)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 1,
        child: ListTile(
          leading: Icon(
            Platform.isWindows ? FluentIcons.share_16_regular : Broken.share,
            color: trackColor,
          ),
          title: Text(
            Language.instance.SHARE,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      ),

    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 2,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.list_16_regular
                : Broken.music_playlist,
            color: trackColor),
        title: Text(
          Language.instance.ADD_TO_PLAYLIST,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    // TODO: Add Android support.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 5,
        child: ListTile(
          leading: Icon(Platform.isWindows
              ? FluentIcons.folder_24_regular
              : Broken.folder),
          title: Text(
            Language.instance.SHOW_IN_FILE_MANAGER,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 6,
      child: ListTile(
        leading: Icon(
            Platform.isWindows ? FluentIcons.edit_24_regular : Broken.edit,
            color: trackColor),
        title: Text(
          Language.instance.EDIT_DETAILS,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 4,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.album_24_regular
                : Broken.music_dashboard,
            color: trackColor),
        title: Text(
          Language.instance.SHOW_ALBUM,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 7,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.info_24_regular
                : Broken.info_circle,
            color: trackColor),
        title: Text(
          Language.instance.FILE_INFORMATION,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    if (Lyrics.instance.hasLRCFile(track))
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 9,
        child: ListTile(
          leading: Icon(
              Platform.isWindows
                  ? FluentIcons.clear_formatting_24_regular
                  : Broken.note_remove,
              color: trackColor),
          title: Text(
            Language.instance.CLEAR_LRC_FILE,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      )
    else
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 8,
        child: ListTile(
          leading: Icon(
              Platform.isWindows
                  ? FluentIcons.text_font_24_regular
                  : Broken.note_2,
              color: trackColor),
          title: Text(
            Language.instance.SET_LRC_FILE,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      ),
    if (playlist != null)
      PopupMenuItem<int>(
        padding: EdgeInsets.zero,
        value: 20,
        child: ListTile(
          leading: Icon(Broken.box_remove, color: trackColor),
          title: Text(
            Language.instance.REMOVE_FROM_PLAYLIST,
            style: isDesktop
                ? Theme.of(context).textTheme.headlineMedium
                : textStyle,
          ),
        ),
      ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 10,
      child: ListTile(
        leading: Icon(
            Platform.isWindows
                ? FluentIcons.music_note_2_16_regular
                : Broken.next,
            color: trackColor),
        title: Text(
          Language.instance.PLAY_NEXT,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
    PopupMenuItem<int>(
      padding: EdgeInsets.zero,
      value: 3,
      child: ListTile(
        leading: Icon(
          Platform.isWindows
              ? FluentIcons.music_note_2_16_regular
              : Iconsax.play_add,
          color: trackColor,
        ),
        title: Text(
          Language.instance.PLAY_LAST,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : textStyle,
        ),
      ),
    ),
  ];
}

Future<void> trackPopupMenuHandleModern(
  BuildContext context,
  Track track,
  int? result, {
  bool Function()? recursivelyPopNavigatorOnDeleteIf,
  Playlist? playlist,
}) async {
  if (result != null) {
    switch (result) {
      case 0:
        if (Platform.isAndroid) {
          final sdk = StorageRetriever.instance.version;
          if (sdk >= 30) {
            // No [AlertDialog] required for confirmation.
            // Android 11 or higher (API level 30) will ask for permissions from the user before deletion.
            await Collection.instance.delete(track);
            if (recursivelyPopNavigatorOnDeleteIf != null) {
              if (recursivelyPopNavigatorOnDeleteIf()) {
                while (Navigator.of(context).canPop()) {
                  await Navigator.of(context).maybePop();
                }
                if (floatingSearchBarController.isOpen) {
                  floatingSearchBarController.close();
                }
              }
            }
            return;
          }
        }
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              Language.instance.COLLECTION_TRACK_DELETE_DIALOG_HEADER,
            ),
            content: Text(
              Language.instance.COLLECTION_TRACK_DELETE_DIALOG_BODY.replaceAll(
                'NAME',
                track.trackName,
              ),
              style: Theme.of(ctx).textTheme.displaySmall,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Collection.instance.delete(track);
                  await Navigator.of(ctx).maybePop();
                  if (recursivelyPopNavigatorOnDeleteIf != null) {
                    if (recursivelyPopNavigatorOnDeleteIf()) {
                      while (Navigator.of(context).canPop()) {
                        await Navigator.of(context).maybePop();
                      }
                      if (floatingSearchBarController.isOpen) {
                        floatingSearchBarController.close();
                      }
                    }
                  }
                },
                child: Text(Language.instance.YES),
              ),
              TextButton(
                onPressed: Navigator.of(ctx).pop,
                child: Text(Language.instance.NO),
              ),
            ],
          ),
        );
        break;
      case 1:
        if (track.uri.isScheme('FILE')) {
          await Share.shareFiles(
            [track.uri.toFilePath()],
            subject: '${track.trackName} • ${[
              '',
              kUnknownArtist,
            ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(', ') : track.albumArtistName}',
          );
        } else {
          await Share.share(
            '${track.trackName} • ${[
              '',
              kUnknownArtist,
            ].contains(track.albumArtistName) ? track.trackArtistNames.take(2).join(', ') : track.albumArtistName} • ${track.uri.toString()}',
          );
        }
        break;
      case 2:
        await showAddToPlaylistDialogModern(context, [track]);
        break;
      case 10:
        Playback.instance.insertAt([track], Playback.instance.index + 1);
        break;
      case 3:
        Playback.instance.add([track]);
        break;
      case 4:
        {
          Iterable<Color>? palette;
          late final Album album;
          for (final item in Collection.instance.albums) {
            // one more check for cases when album and the track are not in the same year
            if ((item.albumName == track.albumName &&
                    item.year == track.year) ||
                (item.albumName == track.albumName &&
                    item.albumArtistName == track.albumArtistName)) {
              album = item;
              break;
            }
          }
          if (isMobile) {
            final result = await PaletteGenerator.fromImageProvider(
              getAlbumArt(album, small: true),
            );
            palette = result.colors;
          }
          Playback.instance.interceptPositionChangeRebuilds = true;
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: AlbumScreenModern(
                  album: album,
                  palette: palette,
                ),
              ),
            ),
          );
          Timer(
            const Duration(milliseconds: 400),
            () {
              Playback.instance.interceptPositionChangeRebuilds = false;
            },
          );
          break;
        }
      case 5:
        File(track.uri.toFilePath()).explore_();
        break;
      case 6:
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: EditDetailsScreen(track: track),
            ),
          ),
        );
        break;
      case 7:
        await FileInfoScreen.show(
          context,
          uri: track.uri,
        );
        break;
      case 8:
        final file = await pickFile(
          label: 'LRC',
          // Compatiblitity issues with Android 5.0. SDK 21.
          extensions: Platform.isAndroid ? null : ['lrc'],
        );
        if (file != null) {
          final added = await Lyrics.instance.addLRCFile(
            track,
            file,
          );
          if (!added) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).cardTheme.color,
                title: Text(
                  Language.instance.ERROR,
                ),
                content: Text(
                  Language.instance.CORRUPT_LRC_FILE,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(Language.instance.OK),
                  ),
                ],
              ),
            );
          }
        }
        break;
      case 9:
        Lyrics.instance.removeLRCFile(track);
        break;
      case 20:
        showDialog(
          context: context,
          builder: (subContext) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: AlertDialog(
              // insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 100),
              clipBehavior: Clip.antiAlias,
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 24.0, bottom: 8.0),
              title: Container(
                  color: Theme.of(context).cardTheme.color,
                  padding: EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Broken.info_circle),
                      const SizedBox(
                        width: 12.0,
                      ),
                      Text(
                        Language.instance.WARNING,
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
              content: Text(
                Language.instance.COLLECTION_TRACK_PLAYLIST_REMOVE_DIALOG_BODY
                    .replaceAll(
                      'TRACK_NAME',
                      track.trackName,
                    )
                    .replaceAll('PLAYLIST_NAME', playlist!.name),
                style: Theme.of(subContext).textTheme.displayMedium,
              ),
              actions: [
                TextButton(
                  onPressed: Navigator.of(subContext).pop,
                  child: Text(Language.instance.NO),
                ),
                TextButton(
                  onPressed: () async {
                    await Collection.instance.playlistRemoveTrack(
                      playlist,
                      track,
                    );

                    Navigator.of(subContext).pop();
                  },
                  child: Text(Language.instance.YES),
                ),
              ],
            ),
          ),
        );
        break;
    }
  }
}

class CustomTrackThumbnailModern extends StatelessWidget {
  CustomTrackThumbnailModern(
      {super.key,
      this.child,
      this.scale = 1.0,
      this.borderRadius = 0.0,
      this.blur = 0.0,
      required this.media});

  final Widget? child;
  final double scale;
  final double borderRadius;
  final double blur;
  final Media media;
  @override
  Widget build(BuildContext context) {
    final extImageChild = ExtendedImage(
      image: Image(image: getAlbumArt(media, small: true)).image,
      fit: BoxFit.cover,
      width: Configuration.instance.forceSquaredTrackThumbnail
          ? MediaQuery.of(context).size.width
          : null,
      height: Configuration.instance.forceSquaredTrackThumbnail
          ? MediaQuery.of(context).size.width
          : null,
    );

    return Configuration.instance.enableGlowEffect
        ? SizedBox(
            width: Configuration.instance.trackThumbnailSizeinList * scale,
            height: Configuration.instance.trackThumbnailSizeinList * scale,
            child: Center(
              child: Configuration.instance.borderRadiusMultiplier == 0.0
                  ? DropShadow(
                      borderRadius: borderRadius *
                          Configuration.instance.borderRadiusMultiplier,
                      blurRadius: blur,
                      spread: 0.8,
                      offset: Offset(0, 1),
                      child: child ?? extImageChild,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius *
                          Configuration.instance.borderRadiusMultiplier),
                      child: DropShadow(
                        borderRadius: borderRadius *
                            Configuration.instance.borderRadiusMultiplier,
                        blurRadius: blur,
                        spread: 0.8,
                        offset: Offset(0, 1),
                        child: child ?? extImageChild,
                      ),
                    ),
            ),
          )
        : SizedBox(
            width: Configuration.instance.trackThumbnailSizeinList * scale,
            height: Configuration.instance.trackThumbnailSizeinList * scale,
            child: Center(
              child: Configuration.instance.borderRadiusMultiplier == 0.0
                  ? child ?? extImageChild
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius *
                          Configuration.instance.borderRadiusMultiplier),
                      child: child ?? extImageChild,
                    ),
            ),
          );
  }
}

class CustomSmallBlurryBoxModern extends StatelessWidget {
  final Widget? child;
  final double height;
  final double width;
  const CustomSmallBlurryBoxModern(
      {super.key, this.child, this.height = 20.0, this.width = 25.0});

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
        height: height,
        width: width,
        blur: Configuration.instance.enableBlurEffect ? 5 : 0,
        padding: EdgeInsets.symmetric(horizontal: 6),
        borderRadius: BorderRadius.circular(
            6 * Configuration.instance.borderRadiusMultiplier),
        color: Configuration.instance.enableBlurEffect
            ? Theme.of(context).brightness == Brightness.dark
                ? Colors.black12
                : Colors.white24
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.white70,
        child: Center(
          child: child,
        ));
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  final double scrollFactor;

  const CustomPageViewScrollPhysics(
      {this.scrollFactor = 2.3, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(
        scrollFactor: scrollFactor, parent: buildParent(ancestor)!);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics metrics, double offset) {
    return offset * scrollFactor;
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 200,
        stiffness: 100,
        damping: 0.8,
      );
}

void showSettingDialogWithTextField({
  required BuildContext context,
  required Function setState,
  Widget? topWidget,
  String? title,
  bool? trackThumbnailSizeinList,
  bool? trackListTileHeight,
  bool? albumThumbnailSizeinList,
  bool? albumListTileHeight,
  bool? queueSheetMinHeight,
  bool? queueSheetMaxHeight,
  bool? nowPlayingImageContainerHeight,
  bool? borderRadiusMultiplier,
  bool? fontScaleFactor,
  bool? dateTimeFormat,
  bool? trackTileSeparator,
}) async {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void showSnackBarWithTitle(String title, [Duration? duration]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        duration: duration ?? Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              24 * Configuration.instance.borderRadiusMultiplier),
        ),
        dismissDirection: DismissDirection.up,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 200,
            right: 20,
            left: 20),
        content: Text(
          '${Language.instance.RESET_TO_DEFAULT}: $title',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  void restartToApplyChangesSnackBar([String? title]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color.alphaBlend(
            NowPlayingColorPalette.instance.modernColor.withAlpha(150),
            Theme.of(context).cardTheme.color!),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              24 * Configuration.instance.borderRadiusMultiplier),
        ),
        dismissDirection: DismissDirection.up,
        margin: EdgeInsets.only(
          bottom: kMobileNowPlayingBarHeight,
          // bottom: MediaQuery.of(context).size.height - 200,
          right: 20,
          left: 20,
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              // width: 100,
              child: Text(
                '${title ?? ''} Restart to apply changes?',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Color.alphaBlend(
                      NowPlayingColorPalette.instance.modernColor
                          .withAlpha(150),
                      Theme.of(context).colorScheme.primary),
                ),
              ),
              onPressed: () => Restart.restartApp(),
              child: Text(
                'Restart',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          ],
        ),
      ),
    );
  }

  await showDialog(
    barrierColor: Colors.black.withAlpha(80),
    context: context,
    builder: (context) {
      return Form(
        key: _formKey,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 100),
            clipBehavior: Clip.antiAlias,
            titlePadding: EdgeInsets.zero,
            contentPadding:
                EdgeInsets.only(left: 14.0, right: 14.0, top: 0, bottom: 8.0),
            title: title != null
                ? Container(
                    color: Theme.of(context).cardTheme.color,
                    padding: EdgeInsets.all(16),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  )
                : null,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 0.0,
                ),
                topWidget != null
                    ? Expanded(
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                                controller: scrollController, child: topWidget),
                            Positioned(
                              bottom: 20,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(0.0),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardTheme.color,
                                    shape: BoxShape.circle),
                                child: IconButton(
                                  icon: Icon(Broken.arrow_circle_down),
                                  onPressed: () {
                                    scrollController.position.animateTo(
                                        scrollController
                                            .position.maxScrollExtent,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: TextFormField(
                    keyboardType:
                        dateTimeFormat != null || trackTileSeparator != null
                            ? TextInputType.text
                            : TextInputType.number,
                    controller: controller,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      errorMaxLines: 3,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(100),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withAlpha(100),
                            width: 1.0),
                      ),
                      hintText: Language.instance.VALUE,
                    ),
                    validator: (value) {
                      if (fontScaleFactor != null &&
                          (double.parse(value!) < 50 ||
                              double.parse(value) > 200)) {
                        return 'Value should be between 50% and 200%';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                  tooltip: Language.instance.RESTORE_DEFAULTS,
                  onPressed: () {
                    if (trackThumbnailSizeinList != null) {
                      Configuration.instance.save(
                        trackThumbnailSizeinList: 70.0,
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.trackThumbnailSizeinList}");
                    }
                    if (trackListTileHeight != null) {
                      Configuration.instance.save(
                        trackListTileHeight: 70.0,
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.trackListTileHeight}");
                    }
                    if (albumThumbnailSizeinList != null) {
                      Configuration.instance.save(
                        albumThumbnailSizeinList: 90.0,
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.albumThumbnailSizeinList}");
                    }
                    if (albumListTileHeight != null) {
                      Configuration.instance.save(
                        albumListTileHeight: 90.0,
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.albumListTileHeight}");
                    }
                    if (queueSheetMinHeight != null) {
                      Configuration.instance.save(
                        queueSheetMinHeight: 25.0,
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.queueSheetMinHeight}");
                    }
                    if (queueSheetMaxHeight != null) {
                      Configuration.instance.save(
                        queueSheetMaxHeight: 500.0,
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.queueSheetMaxHeight}");
                    }
                    if (nowPlayingImageContainerHeight != null) {
                      Configuration.instance.save(
                        nowPlayingImageContainerHeight: 400.0,
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.nowPlayingImageContainerHeight}");
                    }
                    if (borderRadiusMultiplier != null) {
                      Configuration.instance.save(
                        borderRadiusMultiplier: 1.0,
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.borderRadiusMultiplier}");
                    }
                    if (fontScaleFactor != null) {
                      Configuration.instance.save(
                        fontScaleFactor: 1.0,
                      );
                      // showSnackBarWithTitle(
                      //     "${Configuration.instance.fontScaleFactor}");
                      restartToApplyChangesSnackBar(
                          "Set to ${Configuration.instance.fontScaleFactor.toInt() * 100}%,");
                    }
                    if (dateTimeFormat != null) {
                      Configuration.instance.save(
                        dateTimeFormat: 'MMM yyyy',
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.dateTimeFormat}");
                    }
                    if (trackTileSeparator != null) {
                      Configuration.instance.save(
                        trackTileSeparator: '•',
                      );
                      showSnackBarWithTitle(
                          "${Configuration.instance.trackTileSeparator}");
                    }
                    Navigator.of(context).maybePop();
                    setState();
                  },
                  icon: Icon(Broken.refresh)),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).disabledColor)),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  child: Text(Language.instance.CANCEL)),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (trackThumbnailSizeinList != null) {
                        Configuration.instance.save(
                          trackThumbnailSizeinList:
                              double.parse(controller.text),
                        );
                      }
                      if (trackListTileHeight != null) {
                        Configuration.instance.save(
                          trackListTileHeight: double.parse(controller.text),
                        );
                      }
                      if (albumThumbnailSizeinList != null) {
                        Configuration.instance.save(
                          albumThumbnailSizeinList:
                              double.parse(controller.text),
                        );
                      }
                      if (albumListTileHeight != null) {
                        Configuration.instance.save(
                          albumListTileHeight: double.parse(controller.text),
                        );
                      }
                      if (queueSheetMinHeight != null) {
                        // handling the case where the use enter a min value higher than the max
                        if (double.parse(controller.text) >
                            Configuration.instance.queueSheetMaxHeight) {
                          Configuration.instance.save(
                            queueSheetMinHeight:
                                Configuration.instance.queueSheetMaxHeight,
                          );
                          showSnackBarWithTitle(
                            "${Configuration.instance.queueSheetMinHeight}, Minimum value can't be less than the maximum",
                            Duration(seconds: 4),
                          );
                        } else {
                          Configuration.instance.save(
                            queueSheetMinHeight: double.parse(controller.text),
                          );
                        }
                      }
                      if (queueSheetMaxHeight != null) {
                        if (double.parse(controller.text) <
                            Configuration.instance.queueSheetMinHeight) {
                          Configuration.instance.save(
                            queueSheetMaxHeight:
                                Configuration.instance.queueSheetMinHeight,
                          );
                          showSnackBarWithTitle(
                            "${Configuration.instance.queueSheetMaxHeight}, Maximum value can't be more than the minimum",
                            Duration(seconds: 4),
                          );
                        } else {
                          Configuration.instance.save(
                            queueSheetMaxHeight: double.parse(controller.text),
                          );
                        }
                      }
                      if (nowPlayingImageContainerHeight != null) {
                        Configuration.instance.save(
                          nowPlayingImageContainerHeight:
                              double.parse(controller.text),
                        );
                      }
                      if (borderRadiusMultiplier != null) {
                        Configuration.instance.save(
                          borderRadiusMultiplier: double.parse(controller.text),
                        );
                      }
                      if (fontScaleFactor != null) {
                        Configuration.instance.save(
                          fontScaleFactor: double.parse(controller.text) / 100,
                        );
                        restartToApplyChangesSnackBar();
                      }
                      if (dateTimeFormat != null) {
                        Configuration.instance.save(
                          dateTimeFormat: controller.text,
                        );
                      }
                      if (trackTileSeparator != null) {
                        Configuration.instance.save(
                          trackTileSeparator: controller.text,
                        );
                      }

                      Navigator.of(context).maybePop();
                      setState();
                    }
                  },
                  child: Text(Language.instance.OK))
            ],
          ),
        ),
      );
    },
  );
}
