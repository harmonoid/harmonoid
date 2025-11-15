import 'dart:io';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:media_library/media_library.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/ui/about_screen.dart';
import 'package:harmonoid/ui/directory_picker_screen.dart';
import 'package:harmonoid/ui/file_info_screen.dart';
import 'package:harmonoid/ui/media_library/albums/album_screen.dart';
import 'package:harmonoid/ui/media_library/albums/albums_screen.dart';
import 'package:harmonoid/ui/media_library/artists/artist_screen.dart';
import 'package:harmonoid/ui/media_library/artists/artists_screen.dart';
import 'package:harmonoid/ui/media_library/genres/genre_screen.dart';
import 'package:harmonoid/ui/media_library/genres/genres_screen.dart';
import 'package:harmonoid/ui/media_library/media_library_inaccessible_directories_screen.dart';
import 'package:harmonoid/ui/media_library/media_library_screen.dart';
import 'package:harmonoid/ui/media_library/media_library_shell_route.dart';
import 'package:harmonoid/ui/media_library/playlists/playlist_screen.dart';
import 'package:harmonoid/ui/media_library/playlists/playlists_screen.dart';
import 'package:harmonoid/ui/media_library/search/search_items_screen.dart';
import 'package:harmonoid/ui/media_library/search/search_screen.dart';
import 'package:harmonoid/ui/media_library/tracks/tracks_screen.dart';
import 'package:harmonoid/ui/now_playing/now_playing_lyrics_screen.dart';
import 'package:harmonoid/ui/now_playing/now_playing_screen.dart';
import 'package:harmonoid/ui/settings/settings_screen.dart';
import 'package:harmonoid/ui/user/login/login_screen.dart';
import 'package:harmonoid/ui/user/login/state/login_notifier.dart';
import 'package:harmonoid/utils/material_transition_page.dart';

const String kMediaLibraryPath = 'media-library';

const String kAlbumsPath = 'albums';

const String kTracksPath = 'tracks';

const String kArtistsPath = 'artists';

const String kGenresPath = 'genres';

const String kPlaylistsPath = 'playlists';

const String kSearchPath = 'search';
const String kSearchArgQuery = 'query';

const String kSearchItemsPath = 'search-items';

class SearchItemsPathExtra {
  final String query;
  final List<MediaLibraryItem> items;

  const SearchItemsPathExtra({
    required this.query,
    required this.items,
  });
}

const String kAlbumPath = 'album';

class AlbumPathExtra {
  final Album album;
  final List<Track> tracks;
  final List<Color>? palette;

  const AlbumPathExtra({
    required this.album,
    required this.tracks,
    required this.palette,
  });
}

const String kArtistPath = 'artist';

class ArtistPathExtra {
  final Artist artist;
  final List<Track> tracks;
  final List<Color>? palette;

  const ArtistPathExtra({
    required this.artist,
    required this.tracks,
    required this.palette,
  });
}

const String kGenrePath = 'genre';

class GenrePathExtra {
  final Genre genre;
  final List<Track> tracks;
  final List<Color>? palette;

  const GenrePathExtra({
    required this.genre,
    required this.tracks,
    required this.palette,
  });
}

const String kPlaylistPath = 'playlist';

class PlaylistPathExtra {
  final Playlist playlist;
  final List<PlaylistEntry> entries;
  final List<Color>? palette;

  const PlaylistPathExtra({
    required this.playlist,
    required this.entries,
    required this.palette,
  });
}

const String kInaccessibleDirectoriesPath = 'inaccessible-directories';

class InaccessibleDirectoriesPathExtra {
  final List<Directory> directories;

  const InaccessibleDirectoriesPathExtra({
    required this.directories,
  });
}

const String kSettingsPath = 'settings';

const String kAboutPath = 'about';

const String kNowPlayingPath = 'now-playing';

const String kFileInfoPath = 'file-info';

const String kFileInfoArgResource = 'resource';

const String kNowPlayingLyricsPath = 'now-playing-lyrics';

const String kDirectoryPickerPath = 'directory-picker';

const String kLoginPath = 'login';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  observers: [SubscriptionNavigationObserver()],
  navigatorKey: rootNavigatorKey,
  routes: [
    ShellRoute(
      observers: [SubscriptionNavigationObserver()],
      navigatorKey: homeNavigatorKey,
      builder: (context, state, child) {
        return MediaLibraryShellRoute(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, _) => '/$kMediaLibraryPath/${Configuration.instance.mediaLibraryPath}',
        ),
        GoRoute(
          path: '/$kMediaLibraryPath',
          redirect: (_, state) => state.uri.toString(),
          routes: [
            ShellRoute(
              observers: [SubscriptionNavigationObserver()],
              builder: (context, state, child) {
                return MediaLibraryScreen(child: child);
              },
              routes: [
                GoRoute(
                  path: kAlbumsPath,
                  pageBuilder: (context, state) {
                    return buildPageWithSharedAxisTransition(
                      context: context,
                      state: state,
                      child: const AlbumsScreen(),
                    );
                  },
                ),
                GoRoute(
                  path: kTracksPath,
                  pageBuilder: (context, state) {
                    return buildPageWithSharedAxisTransition(
                      context: context,
                      state: state,
                      child: const TracksScreen(),
                    );
                  },
                ),
                GoRoute(
                  path: kArtistsPath,
                  pageBuilder: (context, state) {
                    return buildPageWithSharedAxisTransition(
                      context: context,
                      state: state,
                      child: const ArtistsScreen(),
                    );
                  },
                ),
                GoRoute(
                  path: kGenresPath,
                  pageBuilder: (context, state) {
                    return buildPageWithSharedAxisTransition(
                      context: context,
                      state: state,
                      child: const GenresScreen(),
                    );
                  },
                ),
                GoRoute(
                  path: kPlaylistsPath,
                  pageBuilder: (context, state) {
                    return buildPageWithSharedAxisTransition(
                      context: context,
                      state: state,
                      child: const PlaylistsScreen(),
                    );
                  },
                ),
                GoRoute(
                  path: kSearchPath,
                  pageBuilder: (context, state) {
                    final query = state.uri.queryParameters[kSearchArgQuery] ?? '';
                    return buildPageWithSharedAxisTransition(
                      context: context,
                      state: state,
                      child: SearchScreen(query: query),
                      key: ValueKey(state.uri.toString()),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: kSearchItemsPath,
              pageBuilder: (context, state) {
                final extra = state.extra as SearchItemsPathExtra;
                return buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: SearchItemsScreen(
                    query: extra.query,
                    items: extra.items,
                  ),
                );
              },
            ),
            GoRoute(
              path: kAlbumPath,
              pageBuilder: (context, state) {
                final extra = state.extra as AlbumPathExtra;
                return buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: AlbumScreen(
                    album: extra.album,
                    tracks: extra.tracks,
                    palette: extra.palette,
                  ),
                );
              },
            ),
            GoRoute(
              path: kArtistPath,
              pageBuilder: (context, state) {
                final extra = state.extra as ArtistPathExtra;
                return buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: ArtistScreen(
                    artist: extra.artist,
                    tracks: extra.tracks,
                    palette: extra.palette,
                  ),
                );
              },
            ),
            GoRoute(
              path: kGenrePath,
              pageBuilder: (context, state) {
                final extra = state.extra as GenrePathExtra;
                return buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: GenreScreen(
                    genre: extra.genre,
                    tracks: extra.tracks,
                    palette: extra.palette,
                  ),
                );
              },
            ),
            GoRoute(
              path: kPlaylistPath,
              pageBuilder: (context, state) {
                final extra = state.extra as PlaylistPathExtra;
                return buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: PlaylistScreen(
                    playlist: extra.playlist,
                    entries: extra.entries,
                    palette: extra.palette,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/$kInaccessibleDirectoriesPath',
      pageBuilder: (context, state) {
        final extra = state.extra as InaccessibleDirectoriesPathExtra;
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: MediaLibraryInaccessibleDirectoriesScreen(
            directories: extra.directories,
          ),
        );
      },
    ),
    GoRoute(
      path: '/$kSettingsPath',
      pageBuilder: (context, state) {
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        );
      },
    ),
    GoRoute(
      path: '/$kAboutPath',
      pageBuilder: (context, state) {
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AboutScreen(),
        );
      },
    ),
    GoRoute(
      path: '/$kNowPlayingPath',
      pageBuilder: (context, state) {
        return buildPageWithSharedAxisTransition(
          context: context,
          state: state,
          child: const NowPlayingScreen(),
        );
      },
    ),
    GoRoute(
      path: '/$kFileInfoPath',
      pageBuilder: (context, state) {
        final resource = state.uri.queryParameters[kFileInfoArgResource]!;
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: FileInfoScreen(resource: resource),
        );
      },
    ),
    GoRoute(
      path: '/$kNowPlayingLyricsPath',
      pageBuilder: (context, state) {
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const NowPlayingLyricsScreen(),
        );
      },
    ),
    GoRoute(
      path: '/$kDirectoryPickerPath',
      pageBuilder: (context, state) {
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const DirectoryPickerScreen(),
        );
      },
    ),
    GoRoute(
      path: '/$kLoginPath',
      pageBuilder: (context, state) {
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: ChangeNotifierProvider(
            create: (_) => LoginNotifier(
              userNotifier: context.read(),
              onSuccess: context.pop,
            ),
            child: const LoginScreen(),
          ),
        );
      },
    ),
  ],
);

MaterialTransitionPage<T> buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  ValueKey? key,
}) {
  return MaterialTransitionPage<T>(
    key: key ?? state.pageKey,
    child: child,
  );
}

CustomTransitionPage<T> buildPageWithSharedAxisTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  ValueKey? key,
}) {
  return CustomTransitionPage<T>(
    key: key ?? state.pageKey,
    child: child,
    transitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
    reverseTransitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.vertical,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    ),
  );
}
