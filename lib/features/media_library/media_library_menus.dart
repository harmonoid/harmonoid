import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:provider/provider.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/go_router.dart';
import 'package:harmonoid/extensions/track.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/state/lyrics/lyrics_notifier.dart';
import 'package:harmonoid/features/media_library/utils/rendering.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_search_bar.dart';
import 'package:harmonoid/features/media_library/playlists/utils/rendering.dart';
import 'package:harmonoid/routing/router.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/utils/android_storage_controller.dart';
import 'package:harmonoid/utils/rendering.dart';

enum TrackMenuAction {
  playNext,
  addToNowPlaying,
  addToPlaylist,
  showAlbum,
  showArtists,
  setOrClearLrcFile,
  share,
  showInFileManager,
  fileInformation,
  editTags,
  refresh,
  delete,
}

class TrackMenuProvider {
  TrackMenuProvider(this.context, this.track);

  final BuildContext context;
  final Track track;

  Future<List<PopupMenuItem<int>>> getPopupMenuItems() {
    return _buildPopupMenuItems(
      context: context,
      actions: TrackMenuAction.values,
      getVisible: getVisible,
      getIcon: getIcon,
      getLabel: getLabel,
    );
  }

  Future<void> handlePopupMenuAction(int? result, {Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    if (result == null) return;

    final action = TrackMenuAction.values[result];

    return switch (action) {
      TrackMenuAction.playNext => playNext(),
      TrackMenuAction.addToNowPlaying => addToNowPlaying(),
      TrackMenuAction.addToPlaylist => addToPlaylist(),
      TrackMenuAction.showAlbum => showAlbum(),
      TrackMenuAction.showArtists => showArtists(),
      TrackMenuAction.setOrClearLrcFile => setOrClearLrcFile(),
      TrackMenuAction.share => share(),
      TrackMenuAction.showInFileManager => showInFileManager(),
      TrackMenuAction.fileInformation => fileInformation(),
      TrackMenuAction.editTags => editTags(),
      TrackMenuAction.refresh => refresh(recursivelyPopNavigatorOnDeleteIf: recursivelyPopNavigatorOnDeleteIf),
      TrackMenuAction.delete => delete(recursivelyPopNavigatorOnDeleteIf: recursivelyPopNavigatorOnDeleteIf),
    };
  }

  Future<void> playNext() async {
    await _mediaPlayer.insert(_mediaPlayer.state.index, track.toPlayable());
  }

  Future<void> addToNowPlaying() async {
    await _mediaPlayer.add([track.toPlayable()]);
  }

  Future<void> addToPlaylist() async {
    await showAddToPlaylistDialog(context, track: track);
  }

  Future<void> showAlbum() async {
    await navigateToAlbum(context, AlbumLookupKey(album: track.album, albumArtist: track.albumArtist, year: track.year));
  }

  Future<void> showArtists() async {
    if (track.artists.isEmpty) {
      await navigateToArtist(context, const ArtistLookupKey(artist: ''));
      return;
    }
    if (track.artists.length == 1) {
      await navigateToArtist(context, ArtistLookupKey(artist: track.artists.first));
      return;
    }

    final artist = await showSelection<String>(
      context,
      Localization.instance.ARTISTS,
      track.artists.toList(),
      null,
      (artist) => artist,
      radio: false,
      actions: false,
    );
    if (artist != null) {
      await navigateToArtist(context, ArtistLookupKey(artist: artist));
    }
  }

  Future<void> setOrClearLrcFile() async {
    if (await _lyricsNotifier.contains(track)) {
      await _lyricsNotifier.remove(track);
    } else {
      final file = await pickFile(extensions: Platform.isAndroid ? null : {'LRC'});
      if (file != null) {
        final result = await _lyricsNotifier.add(track, file);
        if (!result) {
          await showMessage(
            context,
            Localization.instance.ERROR,
            Localization.instance.CORRUPT_LRC_FILE,
          );
        }
      }
    }
  }

  Future<void> share() async {
    await Share.shareXFiles([XFile(track.uri)], subject: track.shareSubject);
  }

  Future<void> showInFileManager() async {
    File(track.uri).explore_();
  }

  Future<void> fileInformation() async {
    await context.push(Uri(path: '/$kFileInfoPath', queryParameters: {kFileInfoArgResource: track.uri.toString()}).toString());
  }

  Future<void> editTags() async {
    return _subscriptionNotifier.accessSubscriptionFeature(
      context,
      () async {
        final bool canWrite;
        if (Platform.isAndroid) {
          canWrite = await AndroidStorageController.instance.write([File(track.uri)]);
        } else {
          canWrite = true;
        }
        if (!canWrite) return;
        await context.push(Uri(path: '/$kTagEditorPath', queryParameters: {kTagEditorArgResource: track.uri.toString()}).toString());
      },
    );
  }

  Future<void> refresh({Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    await _fileSystemMediaLibrary?.remove([track], delete: false);
    if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
      await recursivelyPopNavigator();
    }
    await _fileSystemMediaLibrary?.add(File(track.uri));
    await _fileSystemMediaLibrary?.populate();
  }

  Future<void> delete({Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    if (Platform.isAndroid) {
      final sdk = AndroidStorageController.instance.version;
      if (sdk >= 30) {
        // SDK 30 or higher will ask for permissions from the user before deletion.
        await _fileSystemMediaLibrary?.remove([track]);
        if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
          await recursivelyPopNavigator();
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
      await _fileSystemMediaLibrary?.remove([track]);
      if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
        await recursivelyPopNavigator();
      }
    }
  }

  bool getVisible(TrackMenuAction action) {
    return switch (action) {
      TrackMenuAction.share => _fileSystemMediaLibrary != null && (Platform.isAndroid || Platform.isIOS),
      TrackMenuAction.showInFileManager => _fileSystemMediaLibrary != null && (Platform.isLinux || Platform.isMacOS || Platform.isWindows),
      TrackMenuAction.fileInformation => _fileSystemMediaLibrary != null,
      TrackMenuAction.editTags => _fileSystemMediaLibrary != null,
      TrackMenuAction.refresh => _fileSystemMediaLibrary != null,
      TrackMenuAction.delete => _fileSystemMediaLibrary != null,
      _ => true,
    };
  }

  IconData getIcon(TrackMenuAction action) {
    return switch (action) {
      TrackMenuAction.playNext => Icons.playlist_play,
      TrackMenuAction.addToNowPlaying => Icons.playlist_add_check,
      TrackMenuAction.addToPlaylist => Icons.playlist_add,
      TrackMenuAction.showAlbum => Icons.album,
      TrackMenuAction.showArtists => Icons.people,
      TrackMenuAction.setOrClearLrcFile => Icons.abc,
      TrackMenuAction.share => Icons.share,
      TrackMenuAction.showInFileManager => Icons.folder,
      TrackMenuAction.fileInformation => Icons.info,
      TrackMenuAction.editTags => Icons.label,
      TrackMenuAction.refresh => Icons.refresh,
      TrackMenuAction.delete => Icons.delete,
    };
  }

  Future<String> getLabel(TrackMenuAction action) async {
    return switch (action) {
      TrackMenuAction.playNext => Localization.instance.PLAY_NEXT,
      TrackMenuAction.addToNowPlaying => Localization.instance.ADD_TO_NOW_PLAYING,
      TrackMenuAction.addToPlaylist => Localization.instance.ADD_TO_PLAYLIST,
      TrackMenuAction.showAlbum => Localization.instance.SHOW_ALBUM,
      TrackMenuAction.showArtists => Localization.instance.SHOW_ARTIST,
      TrackMenuAction.setOrClearLrcFile => await _lyricsNotifier.contains(track) ? Localization.instance.CLEAR_LRC_FILE : Localization.instance.SET_LRC_FILE,
      TrackMenuAction.share => Localization.instance.SHARE,
      TrackMenuAction.showInFileManager => Localization.instance.SHOW_IN_FILE_MANAGER,
      TrackMenuAction.fileInformation => Localization.instance.FILE_INFORMATION,
      TrackMenuAction.editTags => Localization.instance.EDIT_TAGS,
      TrackMenuAction.refresh => Localization.instance.REFRESH,
      TrackMenuAction.delete => Localization.instance.DELETE,
    };
  }

  late final MediaPlayer _mediaPlayer = context.read<MediaPlayer>();
  late final MediaLibrary _mediaLibrary = context.read<MediaLibrary>();
  late final LyricsNotifier _lyricsNotifier = context.read<LyricsNotifier>();
  late final SubscriptionNotifier _subscriptionNotifier = context.read<SubscriptionNotifier>();

  FileSystemMediaLibrary? get _fileSystemMediaLibrary {
    if (_mediaLibrary is FileSystemMediaLibrary) {
      return _mediaLibrary;
    }
    return null;
  }
}

abstract class _BaseTracksMenuProvider {
  _BaseTracksMenuProvider(this.context);

  final BuildContext context;

  Future<void> play(List<Track> tracks) async {
    await _mediaPlayer.open(tracks.map((e) => e.toPlayable()));
  }

  Future<void> shuffle(List<Track> tracks) async {
    await _mediaPlayer.open(tracks.map((e) => e.toPlayable()), shuffle: true);
  }

  Future<void> playNext(List<Track> tracks) async {
    await _mediaPlayer.disablePlayerPlaylistUpdates();
    for (final track in tracks.reversed) {
      await _mediaPlayer.insert(_mediaPlayer.state.index, track.toPlayable());
    }
    await _mediaPlayer.enablePlayerPlaylistUpdates();
  }

  Future<void> addToNowPlaying(List<Track> tracks) async {
    await _mediaPlayer.disablePlayerPlaylistUpdates();
    await _mediaPlayer.add(tracks.map((e) => e.toPlayable()));
    await _mediaPlayer.enablePlayerPlaylistUpdates();
  }

  Future<void> addToPlaylist(List<Track> tracks) async {
    await showAddToPlaylistDialog(context, tracks: tracks);
  }

  Future<void> delete(List<Track> tracks, {Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    if (Platform.isAndroid) {
      final sdk = AndroidStorageController.instance.version;
      if (sdk >= 30) {
        // SDK 30 or higher will ask for permissions from the user before deletion.
        await _fileSystemMediaLibrary?.remove(tracks);
        if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
          await recursivelyPopNavigator();
        }
        return;
      }
    }

    final result = await showConfirmation(
      context,
      Localization.instance.DELETE,
      tracks.length > 1
          ? Localization.instance.TRACKS_DELETE_DIALOG_SUBTITLE.replaceAll('"N"', tracks.length.toString())
          : Localization.instance.TRACK_DELETE_DIALOG_SUBTITLE.replaceAll('"NAME"', tracks.firstOrNull?.title ?? ''),
    );
    if (result) {
      await _fileSystemMediaLibrary?.remove(tracks);
      if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
        await recursivelyPopNavigator();
      }
    }
  }

  late final MediaPlayer _mediaPlayer = context.read<MediaPlayer>();
  late final MediaLibrary _mediaLibrary = context.read<MediaLibrary>();

  FileSystemMediaLibrary? get _fileSystemMediaLibrary {
    if (_mediaLibrary is FileSystemMediaLibrary) {
      return _mediaLibrary;
    }
    return null;
  }
}

enum TracksMenuAction {
  playAll,
  shuffle,
  playNext,
  addToNowPlaying,
  addToPlaylist,
  delete,
}

class TracksMenuProvider extends _BaseTracksMenuProvider {
  TracksMenuProvider(super.context, this.tracks);

  final List<Track> tracks;

  Future<List<PopupMenuItem<int>>> getPopupMenuItems() {
    return _buildPopupMenuItems(
      context: context,
      actions: TracksMenuAction.values,
      getVisible: getVisible,
      getIcon: getIcon,
      getLabel: getLabel,
    );
  }

  Future<void> handlePopupMenuAction(int? result, {Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    if (result == null) return;

    final action = TracksMenuAction.values[result];

    return switch (action) {
      TracksMenuAction.playAll => play(tracks),
      TracksMenuAction.shuffle => shuffle(tracks),
      TracksMenuAction.playNext => playNext(tracks),
      TracksMenuAction.addToNowPlaying => addToNowPlaying(tracks),
      TracksMenuAction.addToPlaylist => addToPlaylist(tracks),
      TracksMenuAction.delete => delete(tracks, recursivelyPopNavigatorOnDeleteIf: recursivelyPopNavigatorOnDeleteIf),
    };
  }

  bool getVisible(TracksMenuAction action) {
    return switch (action) {
      // SDK 29 cannot delete multiple files at once.
      TracksMenuAction.delete => _fileSystemMediaLibrary != null && (!Platform.isAndroid || AndroidStorageController.instance.version != 29),
      _ => true,
    };
  }

  IconData getIcon(TracksMenuAction action) {
    return switch (action) {
      TracksMenuAction.playAll => Icons.play_arrow,
      TracksMenuAction.shuffle => Icons.shuffle,
      TracksMenuAction.playNext => Icons.playlist_play,
      TracksMenuAction.addToNowPlaying => Icons.playlist_add_check,
      TracksMenuAction.addToPlaylist => Icons.playlist_add,
      TracksMenuAction.delete => Icons.delete,
    };
  }

  Future<String> getLabel(TracksMenuAction action) async {
    return switch (action) {
      TracksMenuAction.playAll => Localization.instance.PLAY_ALL,
      TracksMenuAction.shuffle => Localization.instance.SHUFFLE,
      TracksMenuAction.playNext => Localization.instance.PLAY_NEXT,
      TracksMenuAction.addToNowPlaying => Localization.instance.ADD_TO_NOW_PLAYING,
      TracksMenuAction.addToPlaylist => Localization.instance.ADD_TO_PLAYLIST,
      TracksMenuAction.delete => Localization.instance.DELETE,
    };
  }
}

enum DirectoryMenuAction {
  playAll,
  shuffle,
  playNext,
  addToNowPlaying,
  addToPlaylist,
}

class DirectoryMenuProvider extends _BaseTracksMenuProvider {
  DirectoryMenuProvider(super.context, this.directory);

  final Directory directory;

  Future<List<PopupMenuItem<int>>> getPopupMenuItems() {
    return _buildPopupMenuItems(
      context: context,
      actions: DirectoryMenuAction.values,
      getVisible: (_) => true,
      getIcon: getIcon,
      getLabel: getLabel,
    );
  }

  Future<void> handlePopupMenuAction(int? result, {Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    if (result == null) return;

    final action = DirectoryMenuAction.values[result];

    final files = await directory.list_(predicate: (e) => FileSystemMediaLibrary.instance.supportedFileTypes.contains(e.extension));
    final tracks = <Track>[];
    for (final file in files) {
      final track = _mediaLibrary.lookupTrack(TrackLookupKey(uri: file.path));
      if (track != null) {
        tracks.add(track);
      }
    }

    if (tracks.isEmpty) {
      await showMessage(
        context,
        Localization.instance.FOLDERS_NO_ITEMS_TITLE,
        Localization.instance.FOLDERS_NO_ITEMS_SUBTITLE,
      );
      return;
    }

    return switch (action) {
      DirectoryMenuAction.playAll => play(tracks),
      DirectoryMenuAction.shuffle => shuffle(tracks),
      DirectoryMenuAction.playNext => playNext(tracks),
      DirectoryMenuAction.addToNowPlaying => addToNowPlaying(tracks),
      DirectoryMenuAction.addToPlaylist => addToPlaylist(tracks),
    };
  }

  IconData getIcon(DirectoryMenuAction action) {
    return switch (action) {
      DirectoryMenuAction.playAll => Icons.play_arrow,
      DirectoryMenuAction.shuffle => Icons.shuffle,
      DirectoryMenuAction.playNext => Icons.playlist_play,
      DirectoryMenuAction.addToNowPlaying => Icons.playlist_add_check,
      DirectoryMenuAction.addToPlaylist => Icons.playlist_add,
    };
  }

  Future<String> getLabel(DirectoryMenuAction action) async {
    return switch (action) {
      DirectoryMenuAction.playAll => Localization.instance.PLAY_ALL,
      DirectoryMenuAction.shuffle => Localization.instance.SHUFFLE,
      DirectoryMenuAction.playNext => Localization.instance.PLAY_NEXT,
      DirectoryMenuAction.addToNowPlaying => Localization.instance.ADD_TO_NOW_PLAYING,
      DirectoryMenuAction.addToPlaylist => Localization.instance.ADD_TO_PLAYLIST,
    };
  }
}

enum PlaylistMenuAction {
  rename,
  delete,
}

class PlaylistMenuProvider {
  PlaylistMenuProvider(this.context, this.playlist);

  final BuildContext context;
  final Playlist playlist;

  Future<List<PopupMenuItem<int>>> getPopupMenuItems() async {
    final mediaLibrary = context.read<MediaLibrary>();
    if (playlist == mediaLibrary.playlists.likedPlaylist || playlist == mediaLibrary.playlists.historyPlaylist) {
      return [];
    }

    return await _buildPopupMenuItems(
      context: context,
      actions: PlaylistMenuAction.values,
      getVisible: getVisible,
      getIcon: getIcon,
      getLabel: getLabel,
    );
  }

  Future<void> handlePopupMenuAction(int? result) async {
    if (result == null) return;

    final action = PlaylistMenuAction.values[result];

    return switch (action) {
      PlaylistMenuAction.rename => rename(),
      PlaylistMenuAction.delete => delete(),
    };
  }

  Future<void> rename() async {
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
      await _mediaLibrary.playlists.rename(playlist, name);
    }
  }

  Future<void> delete() async {
    final result = await showConfirmation(
      context,
      Localization.instance.DELETE,
      Localization.instance.PLAYLIST_DELETE_DIALOG_SUBTITLE.replaceAll('"NAME"', playlist.name),
    );
    if (result) {
      await _mediaLibrary.playlists.delete(playlist);
    }
  }

  bool getVisible(PlaylistMenuAction action) {
    return true;
  }

  IconData getIcon(PlaylistMenuAction action) {
    return switch (action) {
      PlaylistMenuAction.rename => Icons.drive_file_rename_outline,
      PlaylistMenuAction.delete => Icons.delete,
    };
  }

  Future<String> getLabel(PlaylistMenuAction action) async {
    return switch (action) {
      PlaylistMenuAction.rename => Localization.instance.RENAME,
      PlaylistMenuAction.delete => Localization.instance.DELETE,
    };
  }

  late final MediaLibrary _mediaLibrary = context.read<MediaLibrary>();
}

enum PlaylistEntryMenuAction {
  remove,
}

class PlaylistEntryMenuProvider {
  PlaylistEntryMenuProvider(this.context, this.playlist, this.playlistEntry);

  final BuildContext context;
  final Playlist playlist;
  final PlaylistEntry playlistEntry;

  Future<List<PopupMenuItem<int>>> getPopupMenuItems() {
    return _buildPopupMenuItems(
      context: context,
      actions: PlaylistEntryMenuAction.values,
      getVisible: getVisible,
      getIcon: getIcon,
      getLabel: getLabel,
    );
  }

  Future<void> handlePopupMenuAction(int? result) async {
    if (result == null) return;

    final action = PlaylistEntryMenuAction.values[result];

    return switch (action) {
      PlaylistEntryMenuAction.remove => remove(),
    };
  }

  Future<void> remove() async {
    final result = await showConfirmation(
      context,
      Localization.instance.REMOVE,
      Localization.instance.PLAYLIST_ENTRY_REMOVE_DIALOG_SUBTITLE.replaceAll('"ENTRY"', playlistEntry.title).replaceAll('"PLAYLIST"', playlist.name),
    );
    if (result) {
      await _mediaLibrary.playlists.deleteEntry(playlistEntry);
    }
  }

  bool getVisible(PlaylistEntryMenuAction action) {
    return true;
  }

  IconData getIcon(PlaylistEntryMenuAction action) {
    return switch (action) {
      PlaylistEntryMenuAction.remove => Icons.delete,
    };
  }

  Future<String> getLabel(PlaylistEntryMenuAction action) async {
    return switch (action) {
      PlaylistEntryMenuAction.remove => Localization.instance.REMOVE,
    };
  }

  late final MediaLibrary _mediaLibrary = context.read<MediaLibrary>();
}

Future<void> recursivelyPopNavigator() async {
  try {
    mediaLibraryAlbumOpenContainerBuildContext?.pop();
  } catch (e) {
    // Ignore.
  }
  try {
    mediaLibraryArtistOpenContainerBuildContext?.pop();
  } catch (e) {
    // Ignore.
  }
  try {
    mediaLibraryGenreOpenContainerBuildContext?.pop();
  } catch (e) {
    // Ignore.
  }
  mediaLibraryAlbumOpenContainerBuildContext = null;
  mediaLibraryArtistOpenContainerBuildContext = null;
  mediaLibraryGenreOpenContainerBuildContext = null;

  if (mediaLibrarySearchController.isAttached && mediaLibrarySearchController.isOpen) {
    mediaLibrarySearchController.closeView('');
  }

  while (router.canPop()) {
    if ([kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath, kSearchPath].contains(router.location.split('/').last)) {
      break;
    }
    router.pop();
  }
}

Future<List<PopupMenuItem<int>>> _buildPopupMenuItems<T extends Enum>({
  required BuildContext context,
  required Iterable<T> actions,
  required bool Function(T action) getVisible,
  required IconData Function(T action) getIcon,
  required Future<String> Function(T action) getLabel,
}) async {
  final style = isDesktop ? Theme.of(context).textTheme.bodyLarge : null;
  final items = <PopupMenuItem<int>>[];
  for (final action in actions) {
    if (!getVisible(action)) continue;
    items.add(
      PopupMenuItem<int>(
        value: action.index,
        child: ListTile(
          leading: Icon(getIcon(action)),
          title: Text(
            await getLabel(action),
            style: style,
          ),
        ),
      ),
    );
  }
  return items;
}
