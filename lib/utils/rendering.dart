import 'dart:async';
import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/track.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/state/mobile_now_playing_notifier.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
import 'package:harmonoid/ui/media_library/media_library_search_bar.dart';
import 'package:harmonoid/ui/media_library/playlists/playlist_item.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/widgets.dart';

bool get isMaterial3 => Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value == 3;

bool get isMaterial2 => Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value == 2;

bool get isMaterial3OrGreater => (Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value ?? 0) >= 3;

bool get isMaterial2OrGreater => (Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value ?? 0) >= 2;

bool get isDesktop => Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.desktop;

bool get isTablet => Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.tablet;

bool get isMobile => Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.mobile;

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

double get albumTileWidth {
  if (isDesktop) {
    return kDesktopAlbumTileWidth;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileAlbumTileWidth;
  }
  throw UnimplementedError();
}

double get albumTileHeight {
  if (isDesktop) {
    return kDesktopAlbumTileHeight;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileAlbumTileHeight;
  }
  throw UnimplementedError();
}

double get linearTileHeight {
  if (isDesktop) {
    return kDesktopLinearTileHeight;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return kMobileLinearTileHeight;
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

EdgeInsets get mediaLibraryScrollViewBuilderPadding {
  if (isDesktop) {
    return EdgeInsets.zero;
  } else if (isTablet) {
    throw UnimplementedError();
  } else if (isMobile) {
    return EdgeInsets.only(top: MediaQuery.of(rootNavigatorKey.currentContext!).padding.top + margin + kMobileSearchBarHeight);
  }
  throw UnimplementedError();
}

double get navigationBarHeight => isMaterial3 ? 80.0 : kBottomNavigationBarHeight;

String label(String value) => isMaterial3OrGreater ? value : value.toUpperCase();

ImageProvider cover({MediaLibraryItem? item, String? uri, int? cacheWidth, int? cacheHeight}) {
  if (cacheWidth != null) cacheWidth *= 2;
  if (cacheHeight != null) cacheHeight *= 2;

  final Future<File?> file;
  if (item != null) {
    file = MediaLibrary.instance.coverFileForMediaLibraryItem(item, fallback: Configuration.instance.mediaLibraryCoverFallback);
  } else if (uri != null) {
    file = MediaLibrary.instance.coverFileForUri(uri, fallback: Configuration.instance.mediaLibraryCoverFallback);
  } else {
    throw ArgumentError('Both item & uri are null.');
  }

  final key = item != null ? '${item.runtimeType}-${item.hashCode}' : '$uri';

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

Future<int?> showMenuItems(BuildContext context, List<PopupMenuItem<int>> items, {RelativeRect? position}) async {
  if (isDesktop) {
    return showMaterialMenu(
      context: context,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      position: position!,
      items: items,
    );
  } else {
    int? result;
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      elevation: kDefaultHeavyElevation,
      showDragHandle: isMaterial3OrGreater,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: () {
                result = i;
                Navigator.of(context).maybePop();
              },
              child: items[i].child,
            ),
          ],
        ],
      ),
    );
    return result;
  }
}

Future<String> showInput(
  BuildContext context,
  String title,
  String subtitle,
  String action,
  String? Function(String? value) validator, {
  TextInputType? keyboardType,
  TextCapitalization? textCapitalization,
}) async {
  bool done = false;
  String input = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  if (isDesktop) {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40.0,
              width: 420.0,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 2.0),
              child: Focus(
                child: Form(
                  key: formKey,
                  child: DefaultTextFormField(
                    autofocus: true,
                    cursorWidth: 1.0,
                    onChanged: (value) => input = value,
                    validator: validator,
                    keyboardType: keyboardType,
                    textCapitalization: textCapitalization,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) {
                      input = value;
                      if (formKey.currentState!.validate()) {
                        done = true;
                        Navigator.of(ctx).maybePop();
                      }
                    },
                    style: Theme.of(ctx).textTheme.bodyLarge,
                    decoration: inputDecoration(ctx, subtitle),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                done = true;
                Navigator.of(ctx).maybePop();
              }
            },
            child: Text(label(action)),
          ),
          TextButton(
            onPressed: Navigator.of(ctx).maybePop,
            child: Text(label(Localization.instance.CANCEL)),
          ),
        ],
      ),
    );
  } else {
    await showModalBottomSheet(
      context: context,
      showDragHandle: isMaterial3OrGreater,
      isScrollControlled: true,
      elevation: kDefaultHeavyElevation,
      useRootNavigator: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom - MediaQuery.of(ctx).padding.bottom,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4.0),
                Form(
                  key: formKey,
                  child: DefaultTextFormField(
                    autofocus: true,
                    autocorrect: false,
                    validator: validator,
                    onChanged: (value) => input = value,
                    keyboardType: keyboardType,
                    textCapitalization: textCapitalization,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) {
                      input = value;
                      if (formKey.currentState!.validate()) {
                        done = true;
                        Navigator.of(ctx).maybePop();
                      }
                    },
                    style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(fontSize: 16.0),
                    decoration: inputDecorationMobile(ctx, subtitle),
                  ),
                ),
                const SizedBox(height: 4.0),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      done = true;
                      Navigator.of(ctx).maybePop();
                    }
                  },
                  child: Text(label(action)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  if (!done) {
    input = '';
  }
  return input;
}

Future<bool> showConfirmation(BuildContext context, String title, String subtitle) async {
  bool result = false;
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        TextButton(
          onPressed: () {
            result = true;
            Navigator.of(ctx).maybePop();
          },
          child: Text(label(Localization.instance.YES)),
        ),
        TextButton(
          onPressed: Navigator.of(ctx).pop,
          child: Text(label(Localization.instance.NO)),
        ),
      ],
    ),
  );
  return result;
}

Future<T?> showSelection<T>(BuildContext context, String title, List<T> values, T? selected, String Function(T) text, {bool actions = true}) async {
  T? result;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        void set(T? value) {
          if (value != null) {
            setState(() => result = value);
          }
        }

        return AlertDialog(
          clipBehavior: Clip.antiAlias,
          titlePadding: actions ? const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0) : const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 8.0),
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          content: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (actions) const Divider(height: 1.0, thickness: 1.0),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: values
                          .map(
                            (value) => ListItem(
                              leading: Radio(
                                value: value,
                                groupValue: result ?? selected,
                                onChanged: set,
                              ),
                              onTap: () => set(value),
                              title: text(value),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                if (actions) const Divider(height: 1.0, thickness: 1.0),
                if (!actions) const SizedBox(height: 8.0),
              ],
            ),
          ),
          actions: actions
              ? [
                  TextButton(
                    onPressed: Navigator.of(ctx).maybePop,
                    child: Text(label(Localization.instance.OK)),
                  ),
                  TextButton(
                    onPressed: () {
                      result = null;
                      Navigator.of(ctx).maybePop();
                    },
                    child: Text(label(Localization.instance.CANCEL)),
                  ),
                ]
              : null,
        );
      },
    ),
  );
  return result;
}

Future<void> showMessage(BuildContext context, String title, String subtitle) async {
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        TextButton(
          onPressed: Navigator.of(ctx).pop,
          child: Text(label(Localization.instance.OK)),
        ),
      ],
    ),
  );
}

List<PopupMenuItem<int>> trackPopupMenuItems(BuildContext context, Track track) => [
      PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: Icon(Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.delete_16_regular : Icons.delete),
          title: Text(
            Localization.instance.DELETE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      if (Platform.isAndroid || Platform.isIOS)
        PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.share_16_regular : Icons.share),
            title: Text(
              Localization.instance.SHARE,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ),
      PopupMenuItem<int>(
        value: 3,
        child: ListTile(
          leading: Icon(Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.music_note_2_16_regular : Icons.music_note),
          title: Text(
            Localization.instance.ADD_TO_NOW_PLAYING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: Icon(Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.list_16_regular : Icons.queue_music),
          title: Text(
            Localization.instance.ADD_TO_PLAYLIST,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      if (Theme.of(context).platform == TargetPlatform.windows || Platform.isLinux || Platform.isMacOS)
        PopupMenuItem<int>(
          value: 5,
          child: ListTile(
            leading: Icon(Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.folder_24_regular : Icons.folder),
            title: Text(
              Localization.instance.SHOW_IN_FILE_MANAGER,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ),
      PopupMenuItem<int>(
        value: 6,
        child: ListTile(
          leading: Icon(Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.edit_24_regular : Icons.edit),
          title: Text(
            Localization.instance.EDIT_DETAILS,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 4,
        child: ListTile(
          leading: Icon(Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.album_24_regular : Icons.album),
          title: Text(
            Localization.instance.SHOW_ALBUM,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 7,
        child: ListTile(
          leading: Icon(Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.info_24_regular : Icons.info),
          title: Text(
            Localization.instance.FILE_INFORMATION,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      if (LyricsNotifier.instance.contains(track.toPlayable()))
        PopupMenuItem<int>(
          value: 9,
          child: ListTile(
            leading: Icon(
              Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.clear_formatting_24_regular : Icons.clear,
            ),
            title: Text(
              Localization.instance.CLEAR_LRC_FILE,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        )
      else
        PopupMenuItem<int>(
          value: 8,
          child: ListTile(
            leading: Icon(
              Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.text_font_24_regular : Icons.abc,
            ),
            title: Text(
              Localization.instance.SET_LRC_FILE,
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
            Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.play_24_regular : Icons.play_circle,
          ),
          title: Text(
            Localization.instance.PLAY,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: Icon(
            Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.arrow_shuffle_24_regular : Icons.shuffle,
          ),
          title: Text(
            Localization.instance.SHUFFLE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: Icon(
            Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.delete_16_regular : Icons.delete,
          ),
          title: Text(
            Localization.instance.DELETE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 3,
        child: ListTile(
          leading: Icon(
            Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.music_note_2_16_regular : Icons.queue_music,
          ),
          title: Text(
            Localization.instance.ADD_TO_NOW_PLAYING,
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

List<PopupMenuItem<int>> playlistPopupMenuItems(BuildContext context, Playlist playlist) => [
      PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: Icon(
            Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.delete_24_regular : Icons.delete,
          ),
          title: Text(
            Localization.instance.DELETE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: Icon(
            Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.rename_24_filled : Icons.drive_file_rename_outline,
          ),
          title: Text(
            Localization.instance.RENAME,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
    ];

List<PopupMenuItem<int>> playlistEntryPopupMenuItems(BuildContext context, PlaylistEntry entry) => [
      PopupMenuItem<int>(
        value: 0,
        child: ListTile(
          leading: Icon(
            Theme.of(context).platform == TargetPlatform.windows ? FluentIcons.delete_24_regular : Icons.delete,
          ),
          title: Text(
            Localization.instance.REMOVE,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ),
    ];

Future<void> trackPopupMenuHandle(BuildContext context, Track track, int? result, {Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
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
            if (await recursivelyPopNavigatorOnDeleteIf()) {
              if (isDesktop) {
                bool result;
                try {
                  result = ![kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath, kSearchPath].contains(GoRouterState.of(context).uri.pathSegments.last);
                } catch (_) {
                  result = true;
                }
                if (result) rootNavigatorKey.currentContext!.go('/');
                /* HACK: */ if (mediaLibrarySearchBarController.isAttached && mediaLibrarySearchBarController.isOpen) mediaLibrarySearchBarController.closeView(null);
              }
              if (isMobile) {
                while (Navigator.of(context).canPop()) {
                  await Navigator.of(context).maybePop();
                  if ([kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath].contains(router.routerDelegate.currentConfiguration.uri.pathSegments.last)) {
                    break;
                  }
                }
              }
            }
          }
          return;
        }
      }
      final result = await showConfirmation(
        context,
        Localization.instance.DELETE,
        Localization.instance.TRACK_DELETE_DIALOG_SUBTITLE.replaceAll('"NAME"', track.title),
      );
      if (result) {
        await MediaLibrary.instance.remove([track]);
        if (recursivelyPopNavigatorOnDeleteIf != null) {
          if (await recursivelyPopNavigatorOnDeleteIf()) {
            if (isDesktop) {
              bool result;
              try {
                result = ![kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath, kSearchPath].contains(GoRouterState.of(context).uri.pathSegments.last);
              } catch (_) {
                result = true;
              }
              if (result) rootNavigatorKey.currentContext!.go('/');
              /* HACK: */ if (mediaLibrarySearchBarController.isAttached && mediaLibrarySearchBarController.isOpen) mediaLibrarySearchBarController.closeView(null);
            }
            if (isMobile) {
              while (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
                if ([kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath].contains(router.routerDelegate.currentConfiguration.uri.pathSegments.last)) {
                  break;
                }
              }
            }
          }
        }
      }
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
        await navigateToAlbum(
          context,
          AlbumLookupKey(
            album: track.album,
            albumArtist: track.albumArtist,
            year: track.year,
          ),
        );
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
        extensions: Platform.isAndroid ? null : {'LRC'},
      );
      if (file != null) {
        final result = await LyricsNotifier.instance.add(track.toPlayable(), file);
        if (!result) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              title: Text(Localization.instance.ERROR),
              content: Text(Localization.instance.CORRUPT_LRC_FILE),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(label(Localization.instance.OK)),
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

          if (isDesktop) {
            bool result;
            try {
              result = ![kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath, kSearchPath].contains(GoRouterState.of(context).uri.pathSegments.last);
            } catch (_) {
              result = true;
            }
            if (result) rootNavigatorKey.currentContext!.go('/');
            /* HACK: */ if (mediaLibrarySearchBarController.isAttached && mediaLibrarySearchBarController.isOpen) mediaLibrarySearchBarController.closeView(null);
          }
          if (isMobile) {
            while (Navigator.of(context).canPop()) {
              await Navigator.of(context).maybePop();
              if ([kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath].contains(router.routerDelegate.currentConfiguration.uri.pathSegments.last)) {
                break;
              }
            }
          }
          return;
        }
      }
      final result = await showConfirmation(
        context,
        Localization.instance.DELETE,
        Localization.instance.ALBUM_DELETE_DIALOG_SUBTITLE.replaceAll('"NAME"', album.album),
      );
      if (result) {
        if (isDesktop) {
          bool result;
          try {
            result = ![kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath, kSearchPath].contains(GoRouterState.of(context).uri.pathSegments.last);
          } catch (_) {
            result = true;
          }
          if (result) rootNavigatorKey.currentContext!.go('/');
          /* HACK: */ if (mediaLibrarySearchBarController.isAttached && mediaLibrarySearchBarController.isOpen) mediaLibrarySearchBarController.closeView(null);
        }
        if (isMobile) {
          while (Navigator.of(context).canPop()) {
            await Navigator.of(context).maybePop();
            if ([kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath].contains(router.routerDelegate.currentConfiguration.uri.pathSegments.last)) {
              break;
            }
          }
        }
      }
      break;
    case 3:
      await MediaPlayer.instance.add(tracks.map((e) => e.toPlayable()).toList());
      break;
  }
}

Future<void> playlistPopupMenuHandle(BuildContext context, Playlist playlist, int? result) async {
  if (result == null) return;
  if ({
    MediaLibrary.instance.playlists.playlists[MediaLibrary.instance.playlists.playlists.length - 1],
    MediaLibrary.instance.playlists.playlists[MediaLibrary.instance.playlists.playlists.length - 2],
  }.contains(playlist)) return;
  switch (result) {
    case 0:
      final result = await showConfirmation(
        context,
        Localization.instance.DELETE,
        Localization.instance.PLAYLIST_DELETE_DIALOG_SUBTITLE.replaceAll('"NAME"', playlist.name),
      );
      if (result) {
        await MediaLibrary.instance.playlists.delete(playlist);
      }
      break;
    case 1:
      final name = await showInput(
        context,
        Localization.instance.RENAME,
        Localization.instance.PLAYLIST_RENAME_DIALOG_SUBTITLE.replaceAll('"NAME"', playlist.name),
        Localization.instance.OK,
        (value) {
          if (value?.isEmpty ?? true) {
            return '';
          }
          return null;
        },
      );
      if (name.isNotEmpty) {
        await MediaLibrary.instance.playlists.rename(playlist, name);
      }
      break;
    default:
      break;
  }
}

Future<void> playlistEntryPopupMenuHandle(BuildContext context, Playlist playlist, PlaylistEntry entry, int? result) async {
  if (result == null) return;
  switch (result) {
    case 0:
      final result = await showConfirmation(
        context,
        Localization.instance.REMOVE,
        Localization.instance.PLAYLIST_ENTRY_REMOVE_DIALOG_SUBTITLE.replaceAll('"ENTRY"', entry.title).replaceAll('"PLAYLIST"', playlist.name),
      );
      if (result) {
        await MediaLibrary.instance.playlists.deleteEntry(entry);
      }
      break;
    default:
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
    //   context: rootNavigatorKey.currentContext!,
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
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.only(top: 20.0),
        title: Text(Localization.instance.PLAYLIST_ADD_DIALOG_TITLE),
        content: SizedBox(
          height: 480.0,
          width: 512.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1.0),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, i) => PlaylistItem(
                    playlist: playlists[i],
                    onTap: () async {
                      await MediaLibrary.instance.playlists.createEntry(playlists[i], track: track);
                      await Navigator.of(ctx).maybePop();
                    },
                  ),
                  separatorBuilder: (context, i) => const Divider(height: 1.0),
                ),
              ),
              const Divider(height: 1.0),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text(label(Localization.instance.CANCEL)),
          ),
        ],
      ),
    );
  } else {
    return showModalBottomSheet(
      context: context,
      showDragHandle: isMaterial3OrGreater,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, controller) => ListView.builder(
          padding: EdgeInsets.zero,
          controller: controller,
          shrinkWrap: true,
          itemCount: playlists.length,
          itemBuilder: (context, i) {
            return PlaylistItem(
              playlist: playlists[i],
              onTap: () async {
                await MediaLibrary.instance.playlists.createEntry(playlists[i], track: track);
                await Navigator.of(context).maybePop();
              },
            );
          },
        ),
      ),
    );
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
    hintText: hintText,
    filled: true,
    isCollapsed: true,
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
