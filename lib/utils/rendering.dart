import 'dart:async';
import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/track.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/state/mobile_now_playing_notifier.dart';
// import 'package:harmonoid/ui/media_library/playlist.dart';
// import 'package:harmonoid/ui/directory_picker_screen.dart';
// import 'package:harmonoid/ui/edit_details_screen.dart';
// import 'package:harmonoid/ui/file_info_screen.dart';
// import 'package:harmonoid/ui/home_screen.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/constants.dart';

bool get isMaterial3 => Theme.of(navigatorKey.currentContext!).extension<MaterialStandard>()?.value == 3;

bool get isMaterial2 => Theme.of(navigatorKey.currentContext!).extension<MaterialStandard>()?.value == 2;

bool get isDesktop => Theme.of(navigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.desktop;

bool get isTablet => Theme.of(navigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.tablet;

bool get isMobile => Theme.of(navigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.mobile;

double get margin {
  if (isDesktop) {
    return kDesktopMargin;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileMargin;
  }
  throw UnimplementedError();
}

double get captionHeight {
  try {
    return WindowPlus.instance.captionHeight;
  } catch (_) {
    return 0.0;
  }
}

double get navigationBarHeight => isMaterial3 ? 80.0 : kBottomNavigationBarHeight;

String label(String value) => isMaterial2 ? value.toUpperCase() : value;

ImageProvider cover({MediaLibraryItem? item, String? uri, int? cacheWidth, int? cacheHeight}) {
  final key = '${item.runtimeType}-${item.hashCode}';

  final Future<File?> file;
  if (item != null) {
    file = MediaLibrary.instance.coverForMediaLibraryItem(item, fallback: Configuration.instance.mediaLibraryCoverFallback);
  } else if (uri != null) {
    file = MediaLibrary.instance.coverForUri(uri, fallback: Configuration.instance.mediaLibraryCoverFallback);
  } else {
    throw ArgumentError('Both item & uri are null.');
  }

  final result = AsyncFileImage.cache[key];

  final ImageProvider image;
  if (result == null) {
    image = AsyncFileImage(
      key,
      file,
      () async {
        // Save default cover, if it does not exist.
        final cover = File(join(MediaLibrary.instance.covers.path, kCoverDefaultFileName));
        if (!await cover.exists_()) {
          final data = await rootBundle.load(kCoverDefaultAssetKey);
          await cover.write_(data.buffer.asUint8List());
        }
        return cover;
      },
    );
  } else {
    image = result;
  }

  if (cacheWidth != null || cacheHeight != null) {
    return ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, image);
  }
  return image;
}

List<PopupMenuItem<int>> trackPopupMenuItems(BuildContext context, Track track) => [
      PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: Icon(Platform.isWindows ? FluentIcons.delete_16_regular : Icons.delete),
          title: Text(
            Language.instance.DELETE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      if (Platform.isAndroid || Platform.isIOS)
        PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(Platform.isWindows ? FluentIcons.share_16_regular : Icons.share),
            title: Text(
              Language.instance.SHARE,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ),
      PopupMenuItem<int>(
        value: 3,
        child: ListTile(
          leading: Icon(Platform.isWindows ? FluentIcons.music_note_2_16_regular : Icons.music_note),
          title: Text(
            Language.instance.ADD_TO_NOW_PLAYING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: Icon(Platform.isWindows ? FluentIcons.list_16_regular : Icons.queue_music),
          title: Text(
            Language.instance.ADD_TO_PLAYLIST,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
        PopupMenuItem<int>(
          value: 5,
          child: ListTile(
            leading: Icon(Platform.isWindows ? FluentIcons.folder_24_regular : Icons.folder),
            title: Text(
              Language.instance.SHOW_IN_FILE_MANAGER,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ),
      PopupMenuItem<int>(
        value: 6,
        child: ListTile(
          leading: Icon(Platform.isWindows ? FluentIcons.edit_24_regular : Icons.edit),
          title: Text(
            Language.instance.EDIT_DETAILS,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 4,
        child: ListTile(
          leading: Icon(Platform.isWindows ? FluentIcons.album_24_regular : Icons.album),
          title: Text(
            Language.instance.SHOW_ALBUM,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 7,
        child: ListTile(
          leading: Icon(Platform.isWindows ? FluentIcons.info_24_regular : Icons.info),
          title: Text(
            Language.instance.FILE_INFORMATION,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      if (LyricsNotifier.instance.contains(track.toPlayable()))
        PopupMenuItem<int>(
          value: 9,
          child: ListTile(
            leading: Icon(
              Platform.isWindows ? FluentIcons.clear_formatting_24_regular : Icons.clear,
            ),
            title: Text(
              Language.instance.CLEAR_LRC_FILE,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        )
      else
        PopupMenuItem<int>(
          value: 8,
          child: ListTile(
            leading: Icon(
              Platform.isWindows ? FluentIcons.text_font_24_regular : Icons.abc,
            ),
            title: Text(
              Language.instance.SET_LRC_FILE,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ),
      if (!isDesktop && MobileNowPlayingNotifier.instance.restored)
        const PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          child: SizedBox(height: kMobileNowPlayingBarHeight),
        ),
    ];

List<PopupMenuItem<int>> albumPopupMenuItems(BuildContext context, Album album) => [
      PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: Icon(
            Platform.isWindows ? FluentIcons.play_24_regular : Icons.play_circle,
          ),
          title: Text(
            Language.instance.PLAY,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: Icon(
            Platform.isWindows ? FluentIcons.arrow_shuffle_24_regular : Icons.shuffle,
          ),
          title: Text(
            Language.instance.SHUFFLE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: Icon(
            Platform.isWindows ? FluentIcons.delete_16_regular : Icons.delete,
          ),
          title: Text(
            Language.instance.DELETE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 3,
        child: ListTile(
          leading: Icon(
            Platform.isWindows ? FluentIcons.music_note_2_16_regular : Icons.queue_music,
          ),
          title: Text(
            Language.instance.ADD_TO_NOW_PLAYING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      if (!isDesktop && MobileNowPlayingNotifier.instance.restored)
        const PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          child: SizedBox(height: kMobileNowPlayingBarHeight),
        ),
    ];

Future<void> trackPopupMenuHandle(BuildContext context, Track track, int? result, {bool Function()? recursivelyPopNavigatorOnDeleteIf}) async {
  if (result == null) return;
  switch (result) {
    case 0:
      if (Platform.isAndroid) {
        final sdk = AndroidStorageController.instance.version;
        if (sdk >= 30) {
          // No [AlertDialog] required for confirmation.
          // Android 11 or higher (API level 30) will ask for permissions from the user before deletion.
          await MediaLibrary.instance.remove([track]);
          if (recursivelyPopNavigatorOnDeleteIf != null) {
            if (recursivelyPopNavigatorOnDeleteIf()) {
              while (Navigator.of(context).canPop()) {
                await Navigator.of(context).maybePop();
              }
              // if (floatingSearchBarController.isOpen) {
              //   floatingSearchBarController.close();
              // }
            }
          }
          return;
        }
      }
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(Language.instance.DELETE),
          content: Text(Language.instance.TRACK_DELETE_DIALOG_SUBTITLE.replaceAll('NAME', track.title)),
          actions: [
            TextButton(
              onPressed: () async {
                await MediaLibrary.instance.remove([track]);
                await Navigator.of(ctx).maybePop();
                if (recursivelyPopNavigatorOnDeleteIf != null) {
                  if (recursivelyPopNavigatorOnDeleteIf()) {
                    while (Navigator.of(context).canPop()) {
                      await Navigator.of(context).maybePop();
                    }
                    // if (floatingSearchBarController.isOpen) {
                    //   floatingSearchBarController.close();
                    // }
                  }
                }
              },
              child: Text(label(Language.instance.YES)),
            ),
            TextButton(
              onPressed: Navigator.of(ctx).pop,
              child: Text(label(Language.instance.NO)),
            ),
          ],
        ),
      );
      break;
    case 1:
      await Share.shareFiles(
        [track.uri],
        subject: track.shareSubject,
      );
      break;
    case 2:
      await showAddToPlaylistDialog(context, track);
      break;
    case 3:
      await MediaPlayer.instance.add([track.toPlayable()]);
      break;
    case 4:
      {
        // TODO:
        break;
      }
    case 5:
      File(track.uri).explore_();
      break;
    // case 6:
    //   await Navigator.of(context).push(MaterialRoute(builder: (context) => EditDetailsScreen(track: track)));
    //   break;
    // case 7:
    //   await FileInfoScreen.show(context, uri: Uri.file(track.uri));
    //   break;
    case 8:
      final file = await pickFile(
        label: 'LRC',
        // Compatiblitity issues with Android 5.0: SDK 21.
        extensions: Platform.isAndroid ? null : {'lrc'},
      );
      if (file != null) {
        final result = await LyricsNotifier.instance.add(track.toPlayable(), file);
        if (!result) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              title: Text(Language.instance.ERROR),
              content: Text(Language.instance.CORRUPT_LRC_FILE),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(label(Language.instance.OK)),
                ),
              ],
            ),
          );
        }
      }
      break;
    case 9:
      LyricsNotifier.instance.remove(track.toPlayable());
      break;
  }
}

Future<void> albumPopupMenuHandle(BuildContext context, Album album, int? result) async {
  if (result == null) return;
  final tracks = await MediaLibrary.instance.tracksFromAlbum(album);
  switch (result) {
    case 0:
      await MediaPlayer.instance.open(tracks.map((e) => e.toPlayable()).toList());
      break;
    case 1:
      tracks.shuffle();
      await MediaPlayer.instance.open(tracks.map((e) => e.toPlayable()).toList());
      break;
    case 2:
      if (Platform.isAndroid) {
        final sdk = AndroidStorageController.instance.version;
        if (sdk >= 30) {
          // No [AlertDialog] required for confirmation.
          // Android 11 or higher (API level 30) will ask for permissions from the user before deletion.
          await MediaLibrary.instance.remove(tracks);
          while (Navigator.of(context).canPop()) {
            await Navigator.of(context).maybePop();
          }
          // if (floatingSearchBarController.isOpen) {
          //   floatingSearchBarController.close();
          // }
          return;
        }
      }
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(Language.instance.DELETE),
          content: Text(Language.instance.ALBUM_DELETE_DIALOG_SUBTITLE.replaceAll('NAME', album.album)),
          actions: [
            TextButton(
              onPressed: () async {
                await MediaLibrary.instance.remove(tracks);
                await Navigator.of(ctx).maybePop();
                while (Navigator.of(context).canPop()) {
                  await Navigator.of(context).maybePop();
                }
                // if (floatingSearchBarController.isOpen) {
                //   floatingSearchBarController.close();
                // }
              },
              child: Text(
                label(Language.instance.YES),
              ),
            ),
            TextButton(
              onPressed: Navigator.of(ctx).pop,
              child: Text(
                label(Language.instance.NO),
              ),
            ),
          ],
        ),
      );
      break;
    case 3:
      await MediaPlayer.instance.add(tracks.map((e) => e.toPlayable()).toList());
      break;
  }
}

Future<File?> pickFile({required String label, Set<String>? extensions}) async {
  final result = await FilePicker.platform.pickFiles(
    type: extensions == null ? FileType.any : FileType.custom,
    allowedExtensions: extensions == null
        ? null
        : {
            ...extensions.map((e) => e.toLowerCase()),
            ...extensions.map((e) => e.toUpperCase()),
          }.toList(),
  );
  if ((result?.count ?? 0) > 0) {
    final path = result?.files.first.path;
    return path != null ? File(path) : null;
  }
  return null;
}

Future<Directory?> pickDirectory({bool native = false}) async {
  if (!Platform.isAndroid || native) {
    final path = await FilePicker.platform.getDirectoryPath();
    return path != null ? Directory(path) : null;
  } else {
    // return showGeneralDialog(
    //   context: navigatorKey.currentContext!,
    //   useRootNavigator: true,
    //   barrierDismissible: false,
    //   barrierColor: Colors.transparent,
    //   pageBuilder: (context, animation, secondaryAnimation) => DirectoryPickerScreen(),
    // );
  }
}

Future<void> showAddToPlaylistDialog(BuildContext context, Track track) {
  final playlists = MediaLibrary.instance.playlists.playlists;
  if (isDesktop) {
    return showDialog(
      context: context,
      builder: (subContext) => AlertDialog(
        contentPadding: const EdgeInsets.only(top: 20.0),
        title: Text(Language.instance.PLAYLIST_ADD_DIALOG_TITLE),
        content: SizedBox(
          height: 480.0,
          width: 512.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1.0),
              // Expanded(
              //   child: ListView.builder(
              //     shrinkWrap: true,
              //     itemCount: playlists.length,
              //     itemBuilder: (context, i) => PlaylistTile(
              //       playlist: playlists[i],
              //       onTap: () async {
              //         await MediaLibrary.instance.playlists.createEntry(playlists[i], track.uri, track.playlistEntryTitle);
              //         Navigator.of(subContext).pop();
              //       },
              //     ),
              //   ),
              // ),
              const Divider(height: 1.0),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(subContext).pop,
            child: Text(label(Language.instance.CANCEL)),
          ),
        ],
      ),
    );
  } else {
    // return showModalBottomSheet(
    //   isScrollControlled: true,
    //   context: context,
    //   builder: (context) => DraggableScrollableSheet(
    //     initialChildSize: 0.6,
    //     maxChildSize: 0.8,
    //     expand: false,
    //     builder: (context, controller) => ListView.builder(
    //       padding: EdgeInsets.zero,
    //       controller: controller,
    //       shrinkWrap: true,
    //       itemCount: playlists.length,
    //       itemBuilder: (context, i) {
    //         return PlaylistTile(
    //           playlist: playlists[i],
    //           onTap: () async {
    //             await MediaLibrary.instance.playlists.createEntry(playlists[i], track.uri, track.playlistEntryTitle);
    //             Navigator.of(context).pop();
    //           },
    //         );
    //       },
    //     ),
    //   ),
    // );
    return Future.value();
  }
}

InputDecoration inputDecoration(BuildContext context, String hintText, {Widget? suffixIcon, VoidCallback? onSuffixIconPressed, Color? fillColor}) {
  return InputDecoration(
    // A [suffixIcon] keeps the [TextField]'s content (label / text) centered for some reason at all heights.
    suffixIcon: suffixIcon == null
        ? const SizedBox(height: 48.0)
        : Container(
            alignment: Alignment.center,
            height: 48.0,
            width: 48.0,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: suffixIcon,
                iconSize: 18.0,
                splashRadius: 12.0,
                onPressed: onSuffixIconPressed,
                highlightColor: Colors.transparent,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
    suffixIconConstraints: suffixIcon == null
        ? const BoxConstraints(
            minHeight: 48.0,
            minWidth: 0.0,
          )
        : null,
    contentPadding: EdgeInsets.only(
      left: 12.0,
      right: 12.0,
      bottom: Platform.isWindows || Platform.isLinux || Platform.isMacOS ? 8.0 : 2.0,
    ),
    hintText: hintText,
    filled: true,
    fillColor: fillColor ?? Theme.of(context).colorScheme.surfaceVariant,
    border: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        width: 1.8,
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        width: 1.8,
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.8,
      ),
    ),
    hintMaxLines: 1,
    errorMaxLines: 1,
    helperMaxLines: 1,
    errorStyle: const TextStyle(height: 0.0),
  );
}

InputDecoration inputDecorationMobile(BuildContext context, String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        width: 1.8,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        width: 1.8,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.8,
      ),
    ),
    hintMaxLines: 1,
    errorMaxLines: 1,
    helperMaxLines: 1,
    errorStyle: const TextStyle(height: 0.0),
  );
}
