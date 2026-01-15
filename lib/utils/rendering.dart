import 'dart:async';
import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:provider/provider.dart';
import 'package:uri_parser/uri_parser.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/playable.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/media_library_item.dart';
import 'package:harmonoid/mappers/playlist_entry.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/ui/media_library/artists/state/artist_image_notifier.dart';
import 'package:harmonoid/ui/media_library/playlists/playlist_item.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/android_utils.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/macos_storage_controller.dart';
import 'package:harmonoid/utils/widgets.dart';

bool get isMaterial3 => Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value == 3;

bool get isMaterial2 => Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value == 2;

bool get isMaterial3OrGreater => (Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value ?? 0) >= 3;

bool get isMaterial2OrGreater => (Theme.of(rootNavigatorKey.currentContext!).extension<MaterialStandard>()?.value ?? 0) >= 2;

bool get isDesktop => Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.desktop;

bool get isTablet => Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.tablet;

bool get isMobile => Theme.of(rootNavigatorKey.currentContext!).extension<LayoutVariantThemeExtension>()?.value == LayoutVariant.mobile;

bool get isDarkMode => Theme.of(rootNavigatorKey.currentContext!).brightness == Brightness.dark;

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
    return EdgeInsets.only(
      top: MediaQuery.of(rootNavigatorKey.currentContext!).padding.top + margin + kMobileSearchBarHeight,
      bottom: kMobileNowPlayingBarHeight,
    );
  }
  throw UnimplementedError();
}

double get navigationBarHeight => isMaterial3 ? 80.0 : kBottomNavigationBarHeight;

double get textButtonPadding {
  if (isMaterial3) {
    return 12.0;
  }
  if (isMaterial2) {
    return 8.0;
  }
  return 0.0;
}

String get operatingSystem {
  if (Platform.isAndroid) {
    return 'Android';
  } else if (Platform.isIOS) {
    return 'iOS';
  } else if (Platform.isMacOS) {
    return 'macOS';
  } else if (Platform.isLinux) {
    return 'GNU/Linux';
  } else if (Platform.isWindows) {
    return 'Windows';
  } else {
    return 'operating system';
  }
}

String label(String value) => isMaterial3OrGreater ? value : value.uppercase();

ImageProvider cover({
  MediaLibraryItem? item,
  PlaylistEntry? playlistEntry,
  String? uri,
  int? cacheWidth,
  int? cacheHeight,
}) {
  final context = rootNavigatorKey.currentContext!;

  if (cacheWidth != null) cacheWidth *= 2;
  if (cacheHeight != null) cacheHeight *= 2;

  final key = switch ((item, playlistEntry, uri)) {
    (MediaLibraryItem e, _, _) => e.toImageKey(),
    (_, PlaylistEntry e, _) => e.toImageKey(),
    (_, _, String e) => e,
    _ => throw ArgumentError(),
  };

  // TODO: Add support for HTTP URIs.
  Future<File?> getFile() async {
    final mediaLibrary = context.read<MediaLibrary>();
    final mediaLibraryCoverFallback = Configuration.instance.mediaLibraryCoverFallback;

    if (item is Artist) {
      return context.read<ArtistImageNotifier>().getFile(item);
    } else if (item != null) {
      return mediaLibrary.cover(item, fallback: mediaLibraryCoverFallback).then((value) {
        if (value == null) return null;
        return File(value.toFilePath());
      });
    }

    if (playlistEntry != null) {
      if (playlistEntry.uri != null) {
        return mediaLibrary.coverForUri(playlistEntry.uri!).then((value) {
          if (value == null) return null;
          return File(value.toFilePath());
        });
      }
      if (playlistEntry.hash != null) {
        final track = await FileSystemMediaLibrary.instance.db.selectTrackByHash(playlistEntry.hash!);
        return mediaLibrary.cover(track!, fallback: mediaLibraryCoverFallback).then((value) {
          if (value == null) return null;
          return File(value.toFilePath());
        });
      }
    }

    if (uri != null) {
      return mediaLibrary.coverForUri(uri).then((value) {
        if (value == null) return null;
        return File(value.toFilePath());
      });
    }

    throw ArgumentError();
  }

  Future<File> getFallbackFile() async {
    // Save default artist image, if it does not exist.
    if (item is Artist) {
      return context.read<ArtistImageNotifier>().getDefaultFile();
    }
    // Save default album image, if it does not exist.
    return context.read<FileSystemMediaLibrary>().getDefaultCoverFile();
  }

  AsyncFileImage.attemptToResolveIfFallback(
    key,
    getFile,
    onResolve: () async {
      // Allow few things to update to the just resolved cover.
      String? result;
      if (item is Track) result ??= item.uri;
      result ??= playlistEntry?.uri;
      result ??= uri;
      if (MediaPlayer.instance.current.uri == result) {
        MediaPlayer.instance
          ..resetFlagsAudioService()
          ..resetFlagsDiscordRpc()
          ..resetFlagsMpris()
          ..resetFlagsSystemMediaTransportControls();
        NowPlayingColorPaletteNotifier.instance.resetCurrent();
      }
    },
  );

  final result = AsyncFileImage.getFileImage(key);

  final ImageProvider image = result ?? AsyncFileImage(key, getFile, getFallbackFile);

  if (cacheWidth != null || cacheHeight != null) {
    return ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, image);
  }
  return image;
}

Future<String> showInput(
  BuildContext context,
  String title,
  String subtitle,
  String action,
  String? Function(String? value) validator, {
  TextInputType keyboardType = TextInputType.text,
  TextCapitalization textCapitalization = TextCapitalization.none,
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
            Focus(
              child: Form(
                key: formKey,
                child: DefaultTextFormField(
                  autofocus: true,
                  onChanged: (value) => input = value,
                  validator: validator,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) {
                    input = value;
                    if (formKey.currentState!.validate()) {
                      done = true;
                      ctx.pop();
                    }
                  },
                  style: Theme.of(ctx).textTheme.bodyLarge,
                  decoration: InputDecoration(hintText: subtitle),
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
                ctx.pop();
              }
            },
            child: Text(label(action)),
          ),
          TextButton(
            onPressed: ctx.pop,
            child: Text(label(Localization.instance.CANCEL)),
          ),
        ],
      ),
    );
  } else {
    await showModalBottomSheet(
      context: context,
      showDragHandle: isMaterial3OrGreater,
      elevation: kDefaultHeavyElevation,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                        ctx.pop();
                      }
                    },
                    style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(fontSize: 16.0),
                    decoration: InputDecoration(hintText: subtitle),
                  ),
                ),
                const SizedBox(height: 4.0),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      done = true;
                      ctx.pop();
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

Future<bool> showConfirmation(
  BuildContext context,
  String title,
  String subtitle, {
  String? positiveAction,
  String? negativeAction,
  bool barrierDismissible = true,
}) async {
  bool result = false;
  await showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        TextButton(
          onPressed: () {
            result = true;
            ctx.pop();
          },
          child: Text(label(positiveAction ?? Localization.instance.YES)),
        ),
        TextButton(
          onPressed: ctx.pop,
          child: Text(label(negativeAction ?? Localization.instance.NO)),
        ),
      ],
    ),
  );
  return result;
}

Future<T?> showSelection<T>(
  BuildContext context,
  String title,
  List<T> values,
  T? selected,
  String Function(T) text, {
  Widget? Function(T)? leading,
  Widget? Function(T)? trailing,
  bool actions = true,
  bool radio = true,
}) async {
  T? result;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        void set(T? value) {
          if (value != null) {
            setState(() => result = value);
          }
          if (!actions) {
            context.pop();
          }
        }

        return AlertDialog(
          clipBehavior: Clip.antiAlias,
          titlePadding: (actions || values.length > 10) ? const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0) : const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 8.0),
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          content: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (actions || values.length > 10) const Divider(height: 1.0),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: values
                          .map(
                            (value) => ListItem(
                              leading:
                                  leading?.call(value) ??
                                  (radio
                                      ? Radio(
                                          value: value,
                                          groupValue: result ?? selected,
                                          onChanged: set,
                                        )
                                      : null),
                              trailing: trailing?.call(value),
                              onTap: () => set(value),
                              title: text(value),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                if (actions) const Divider(height: 1.0),
                if (!actions) const SizedBox(height: 8.0),
              ],
            ),
          ),
          actions: actions
              ? [
                  TextButton(
                    onPressed: ctx.pop,
                    child: Text(label(Localization.instance.OK)),
                  ),
                  TextButton(
                    onPressed: () {
                      result = null;
                      ctx.pop();
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

Future<File?> pickFile({Set<String>? extensions}) async {
  if (Platform.isMacOS) {
    return MacOSStorageController.instance.pickFile(extensions?.toList() ?? []);
  }

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

Future<Directory?> pickDirectory() async {
  if (Platform.isAndroid) {
    return router.push('/$kDirectoryPickerPath');
  }
  if (Platform.isMacOS) {
    return MacOSStorageController.instance.pickDirectory();
  }
  final path = await FilePicker.platform.getDirectoryPath();
  return path != null ? Directory(path) : null;
}

Future<String?> pickResource(BuildContext context, String title) async {
  String? result;

  await showDialog(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(title),
      children: [
        ListTile(
          onTap: () async {
            final file = await pickFile(extensions: kDefaultSupportedFileTypes);
            if (file != null) {
              result = file.path;
              ctx.pop();
            }
          },
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(ctx).iconTheme.color,
            child: const Icon(Icons.folder),
          ),
          title: Text(
            Localization.instance.FILE,
            style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
          ),
        ),
        ListTile(
          onTap: () async {
            ctx.pop();
            final resultValue = await showInput(
              context,
              title,
              Localization.instance.URL,
              Localization.instance.OK,
              (value) {
                final parser = URIParser(value);
                if (!parser.validate()) {
                  return '';
                }
                return null;
              },
              keyboardType: TextInputType.url,
              textCapitalization: TextCapitalization.none,
            );

            if (resultValue.isNotEmpty) {
              result = resultValue;
              ctx.pop();
            }
          },
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(ctx).iconTheme.color,
            child: const Icon(Icons.link),
          ),
          title: Text(
            Localization.instance.URL,
            style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
          ),
        ),
      ],
    ),
  );

  return result;
}

Future<String?> showCreatePlaylistDialog(BuildContext context) async {
  final name = await showInput(
    context,
    Localization.instance.CREATE_NEW_PLAYLIST,
    Localization.instance.PLAYLIST_CREATE_DIALOG_SUBTITLE,
    Localization.instance.CREATE,
    (value) {
      if (value?.isEmpty ?? true) {
        return '';
      }
      return null;
    },
    keyboardType: TextInputType.name,
    textCapitalization: TextCapitalization.words,
  );

  if (name.isNotEmpty) {
    final mediaLibrary = context.read<MediaLibrary>();
    await mediaLibrary.playlists.create(name);
    return name;
  }
  return null;
}

Future<void> showAddToPlaylistDialog(
  BuildContext context, {
  Track? track,
  Playable? playable,
  List<Track>? tracks,
}) {
  assert(track != null || playable != null || tracks != null);

  void onTap(MediaLibrary mediaLibrary, Playlist playlist) async {
    context.pop();

    if (track != null) {
      await mediaLibrary.playlists.createEntry(
        playlist,
        track: track,
      );
    }
    if (playable != null) {
      await mediaLibrary.playlists.createEntry(
        playlist,
        uri: playable.uri,
        title: playable.playlistEntryTitle,
      );
    }
    if (tracks != null) {
      for (final track in tracks) {
        await mediaLibrary.playlists.createEntry(
          playlist,
          track: track,
        );
      }
    }

    if (Platform.isAndroid) {
      final entry = track?.title ?? playable?.playlistEntryTitle;
      final playlistName = playlist.name;
      if (entry != null) {
        AndroidUtils.instance.showToast(Localization.instance.ADDED_ENTRY_TO_PLAYLIST.replaceAll('"ENTRY"', entry).replaceAll('"PLAYLIST"', playlistName));
      } else {
        AndroidUtils.instance.showToast(Localization.instance.ADDED_N_ENTRIES_TO_PLAYLIST.replaceAll('"N"', tracks?.length.toString() ?? '0').replaceAll('"PLAYLIST"', playlistName));
      }
    }
  }

  if (isDesktop) {
    return showDialog(
      context: context,
      builder: (ctx) => Consumer<MediaLibrary>(
        builder: (context, mediaLibrary, _) {
          final playlists = mediaLibrary.playlists.playlists;
          return AlertDialog(
            contentPadding: const EdgeInsets.only(top: 20.0),
            title: Text(Localization.instance.PLAYLIST_ADD_DIALOG_TITLE),
            content: SizedBox(
              width: 640.0,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1.0),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListItem(
                              leading: Container(
                                width: 56.0,
                                height: 56.0,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: const CircleAvatar(child: Icon(Icons.add)),
                              ),
                              title: Localization.instance.CREATE_NEW_PLAYLIST,
                              onTap: () => showCreatePlaylistDialog(context),
                            ),
                            const Divider(height: 1.0),
                            for (int i = 0; i < playlists.length; i++) ...[
                              PlaylistItem(
                                playlist: playlists[i],
                                onTap: () => onTap(mediaLibrary, playlists[i]),
                              ),
                              if (i < playlists.length - 1) const Divider(height: 1.0),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1.0),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: context.pop,
                child: Text(label(Localization.instance.CANCEL)),
              ),
            ],
          );
        },
      ),
    );
  } else {
    return showModalBottomSheet(
      context: context,
      showDragHandle: isMaterial3OrGreater,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, controller) => Consumer<MediaLibrary>(
          builder: (context, mediaLibrary, _) {
            final playlists = mediaLibrary.playlists.playlists;
            return ListView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              controller: controller,
              shrinkWrap: true,
              children: [
                ListItem(
                  leading: Container(
                    width: 56.0,
                    height: 56.0,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const CircleAvatar(child: Icon(Icons.add)),
                  ),
                  title: Localization.instance.CREATE_NEW_PLAYLIST,
                  onTap: () => showCreatePlaylistDialog(context),
                ),
                const Divider(height: 1.0),
                for (int i = 0; i < playlists.length; i++)
                  PlaylistItem(
                    playlist: playlists[i],
                    onTap: () => onTap(mediaLibrary, playlists[i]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
