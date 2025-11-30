import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';
import 'package:safe_local_storage/safe_local_storage.dart';
import 'package:share_plus/share_plus.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/go_router.dart';
import 'package:harmonoid/extensions/track.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/state/lyrics_notifier.dart';
import 'package:harmonoid/ui/media_library/media_library_flags.dart';
import 'package:harmonoid/ui/media_library/media_library_hyperlinks.dart';
import 'package:harmonoid/ui/media_library/media_library_search_bar.dart';
import 'package:harmonoid/ui/router.dart';
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
  refresh,
  delete,
}

class TrackMenuProvider {
  TrackMenuProvider(this.context, this.track);

  final BuildContext context;
  final Track track;

  List<PopupMenuItem<int>> getPopupMenuItems() {
    return TrackMenuAction.values
        .where((action) => _getVisible(action))
        .map(
          (action) => PopupMenuItem<int>(
            value: action.index,
            child: ListTile(
              leading: Icon(_getIcon(action)),
              title: Text(
                _getLabel(action),
                style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
              ),
            ),
          ),
        )
        .toList();
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
    if (_lyricsNotifier.contains(track.toPlayable())) {
      await _lyricsNotifier.remove(track.toPlayable());
    } else {
      final file = await pickFile(extensions: Platform.isAndroid ? null : {'LRC'});
      if (file != null) {
        final result = await _lyricsNotifier.add(track.toPlayable(), file);
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
    context.push(Uri(path: '/$kFileInfoPath', queryParameters: {kFileInfoArgResource: track.uri.toString()}).toString());
  }

  Future<void> refresh({Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    await _mediaLibrary.remove([track], delete: false);
    if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
      await recursivelyPopNavigator();
    }
    await _mediaLibrary.add(File(track.uri));
    await _mediaLibrary.populate();
  }

  Future<void> delete({Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    if (Platform.isAndroid) {
      final sdk = AndroidStorageController.instance.version;
      if (sdk >= 30) {
        // SDK 30 or higher will ask for permissions from the user before deletion.
        await _mediaLibrary.remove([track]);
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
      await _mediaLibrary.remove([track]);
      if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
        await recursivelyPopNavigator();
      }
    }
  }

  bool _getVisible(TrackMenuAction action) {
    return switch (action) {
      TrackMenuAction.share => Platform.isAndroid || Platform.isIOS,
      TrackMenuAction.showInFileManager => Platform.isLinux || Platform.isMacOS || Platform.isWindows,
      _ => true,
    };
  }

  IconData _getIcon(TrackMenuAction action) {
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
      TrackMenuAction.refresh => Icons.refresh,
      TrackMenuAction.delete => Icons.delete,
    };
  }

  String _getLabel(TrackMenuAction action) {
    return switch (action) {
      TrackMenuAction.playNext => Localization.instance.PLAY_NEXT,
      TrackMenuAction.addToNowPlaying => Localization.instance.ADD_TO_NOW_PLAYING,
      TrackMenuAction.addToPlaylist => Localization.instance.ADD_TO_PLAYLIST,
      TrackMenuAction.showAlbum => Localization.instance.SHOW_ALBUM,
      TrackMenuAction.showArtists => Localization.instance.SHOW_ARTIST,
      TrackMenuAction.setOrClearLrcFile => _lyricsNotifier.contains(track.toPlayable()) ? Localization.instance.CLEAR_LRC_FILE : Localization.instance.SET_LRC_FILE,
      TrackMenuAction.share => Localization.instance.SHARE,
      TrackMenuAction.showInFileManager => Localization.instance.SHOW_IN_FILE_MANAGER,
      TrackMenuAction.fileInformation => Localization.instance.FILE_INFORMATION,
      TrackMenuAction.refresh => Localization.instance.REFRESH,
      TrackMenuAction.delete => Localization.instance.DELETE,
    };
  }

  MediaPlayer get _mediaPlayer => context.read<MediaPlayer>();
  MediaLibrary get _mediaLibrary => context.read<MediaLibrary>();
  LyricsNotifier get _lyricsNotifier => context.read<LyricsNotifier>();
}

enum TracksMenuAction {
  playAll,
  shuffle,
  playNext,
  addToNowPlaying,
  addToPlaylist,
  delete,
}

class TracksMenuProvider {
  TracksMenuProvider(this.context, this.tracks);

  final BuildContext context;
  final List<Track> tracks;

  List<PopupMenuItem<int>> getPopupMenuItems() {
    return TracksMenuAction.values
        .where((action) => _getVisible(action))
        .map(
          (action) => PopupMenuItem<int>(
            value: action.index,
            child: ListTile(
              leading: Icon(_getIcon(action)),
              title: Text(
                _getLabel(action),
                style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
              ),
            ),
          ),
        )
        .toList();
  }

  Future<void> handlePopupMenuAction(int? result, {Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    if (result == null) return;

    final action = TracksMenuAction.values[result];

    return switch (action) {
      TracksMenuAction.playAll => play(),
      TracksMenuAction.shuffle => shuffle(),
      TracksMenuAction.playNext => playNext(),
      TracksMenuAction.addToNowPlaying => addToNowPlaying(),
      TracksMenuAction.addToPlaylist => addToPlaylist(),
      TracksMenuAction.delete => delete(recursivelyPopNavigatorOnDeleteIf: recursivelyPopNavigatorOnDeleteIf),
    };
  }

  Future<void> play() async {
    await _mediaPlayer.open(tracks.map((e) => e.toPlayable()));
  }

  Future<void> shuffle() async {
    await _mediaPlayer.open(tracks.map((e) => e.toPlayable()), shuffle: true);
  }

  Future<void> playNext() async {
    for (final track in tracks.reversed) {
      await _mediaPlayer.insert(_mediaPlayer.state.index, track.toPlayable());
    }
  }

  Future<void> addToNowPlaying() async {
    await _mediaPlayer.add(tracks.map((e) => e.toPlayable()));
  }

  Future<void> addToPlaylist() async {
    await showAddToPlaylistDialog(context, tracks: tracks);
  }

  Future<void> delete({Future<bool> Function()? recursivelyPopNavigatorOnDeleteIf}) async {
    if (Platform.isAndroid) {
      final sdk = AndroidStorageController.instance.version;
      if (sdk >= 30) {
        // SDK 30 or higher will ask for permissions from the user before deletion.
        await _mediaLibrary.remove(tracks);
        if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
          await recursivelyPopNavigator();
        }
        return;
      }
    }

    final result = await showConfirmation(
      context,
      Localization.instance.DELETE,
      Localization.instance.TRACKS_DELETE_DIALOG_SUBTITLE.replaceAll('"N"', tracks.length.toString()),
    );
    if (result) {
      await _mediaLibrary.remove(tracks);
      if (await recursivelyPopNavigatorOnDeleteIf?.call() ?? false) {
        await recursivelyPopNavigator();
      }
    }
  }

  bool _getVisible(TracksMenuAction action) {
    return switch (action) {
      // SDK 29 cannot delete multiple files at once.
      TracksMenuAction.delete => !Platform.isAndroid || AndroidStorageController.instance.version != 29,
      _ => true,
    };
  }

  IconData _getIcon(TracksMenuAction action) {
    return switch (action) {
      TracksMenuAction.playAll => Icons.play_arrow,
      TracksMenuAction.shuffle => Icons.shuffle,
      TracksMenuAction.playNext => Icons.playlist_play,
      TracksMenuAction.addToNowPlaying => Icons.playlist_add_check,
      TracksMenuAction.addToPlaylist => Icons.playlist_add,
      TracksMenuAction.delete => Icons.delete,
    };
  }

  String _getLabel(TracksMenuAction action) {
    return switch (action) {
      TracksMenuAction.playAll => Localization.instance.PLAY_ALL,
      TracksMenuAction.shuffle => Localization.instance.SHUFFLE,
      TracksMenuAction.playNext => Localization.instance.PLAY_NEXT,
      TracksMenuAction.addToNowPlaying => Localization.instance.ADD_TO_NOW_PLAYING,
      TracksMenuAction.addToPlaylist => Localization.instance.ADD_TO_PLAYLIST,
      TracksMenuAction.delete => Localization.instance.DELETE,
    };
  }

  MediaPlayer get _mediaPlayer => context.read<MediaPlayer>();
  MediaLibrary get _mediaLibrary => context.read<MediaLibrary>();
}

enum PlaylistMenuAction {
  rename,
  delete,
}

class PlaylistMenuProvider {
  PlaylistMenuProvider(this.context, this.playlist);

  final BuildContext context;
  final Playlist playlist;

  List<PopupMenuItem<int>> getPopupMenuItems() {
    final mediaLibrary = context.read<MediaLibrary>();
    if (playlist == mediaLibrary.playlists.likedPlaylist || playlist == mediaLibrary.playlists.historyPlaylist) {
      return [];
    }

    return PlaylistMenuAction.values
        .where((action) => _getVisible(action))
        .map(
          (action) => PopupMenuItem<int>(
            value: action.index,
            child: ListTile(
              leading: Icon(_getIcon(action)),
              title: Text(
                _getLabel(action),
                style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
              ),
            ),
          ),
        )
        .toList();
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

  bool _getVisible(PlaylistMenuAction action) {
    return true;
  }

  IconData _getIcon(PlaylistMenuAction action) {
    return switch (action) {
      PlaylistMenuAction.rename => Icons.drive_file_rename_outline,
      PlaylistMenuAction.delete => Icons.delete,
    };
  }

  String _getLabel(PlaylistMenuAction action) {
    return switch (action) {
      PlaylistMenuAction.rename => Localization.instance.RENAME,
      PlaylistMenuAction.delete => Localization.instance.DELETE,
    };
  }

  MediaLibrary get _mediaLibrary => context.read<MediaLibrary>();
}

enum PlaylistEntryMenuAction {
  remove,
}

class PlaylistEntryMenuProvider {
  PlaylistEntryMenuProvider(this.context, this.playlist, this.playlistEntry);

  final BuildContext context;
  final Playlist playlist;
  final PlaylistEntry playlistEntry;

  List<PopupMenuItem<int>> getPopupMenuItems() {
    return PlaylistEntryMenuAction.values
        .where((action) => _getVisible(action))
        .map(
          (action) => PopupMenuItem<int>(
            value: action.index,
            child: ListTile(
              leading: Icon(_getIcon(action)),
              title: Text(
                _getLabel(action),
                style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
              ),
            ),
          ),
        )
        .toList();
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

  bool _getVisible(PlaylistEntryMenuAction action) {
    return true;
  }

  IconData _getIcon(PlaylistEntryMenuAction action) {
    return switch (action) {
      PlaylistEntryMenuAction.remove => Icons.delete,
    };
  }

  String _getLabel(PlaylistEntryMenuAction action) {
    return switch (action) {
      PlaylistEntryMenuAction.remove => Localization.instance.REMOVE,
    };
  }

  MediaLibrary get _mediaLibrary => context.read<MediaLibrary>();
}

Future<void> recursivelyPopNavigator() async {
  mediaLibraryAlbumOpenContainerBuildContext?.pop();
  mediaLibraryArtistOpenContainerBuildContext?.pop();
  mediaLibraryGenreOpenContainerBuildContext?.pop();
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
