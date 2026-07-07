import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/routing/models/album_path_extra.dart';
import 'package:harmonoid/routing/models/artist_path_extra.dart';
import 'package:harmonoid/routing/models/genre_path_extra.dart';
import 'package:harmonoid/routing/models/inaccessible_directories_path_extra.dart';
import 'package:harmonoid/routing/models/playlist_path_extra.dart';
import 'package:harmonoid/routing/models/search_items_path_extra.dart';
import 'package:harmonoid/routing/utils/constants.dart';
import 'package:harmonoid/routing/utils/rendering.dart';
import 'package:harmonoid/features/misc/about_screen.dart';
import 'package:harmonoid/utils/directory_picker_screen.dart';
import 'package:harmonoid/features/misc/file_info_screen.dart';
import 'package:harmonoid/features/media_library/albums/album_screen.dart';
import 'package:harmonoid/features/media_library/albums/albums_screen.dart';
import 'package:harmonoid/features/media_library/artists/artist_screen.dart';
import 'package:harmonoid/features/media_library/artists/artists_screen.dart';
import 'package:harmonoid/features/media_library/folders/folders_screen.dart';
import 'package:harmonoid/features/media_library/genres/genre_screen.dart';
import 'package:harmonoid/features/media_library/genres/genres_screen.dart';
import 'package:harmonoid/features/media_library/media_library_inaccessible_directories_screen.dart';
import 'package:harmonoid/features/media_library/media_library_screen.dart';
import 'package:harmonoid/features/media_library/media_library_shell_route.dart';
import 'package:harmonoid/features/media_library/playlists/playlist_screen.dart';
import 'package:harmonoid/features/media_library/playlists/playlists_screen.dart';
import 'package:harmonoid/features/media_library/search/search_items_screen.dart';
import 'package:harmonoid/features/media_library/search/search_screen.dart';
import 'package:harmonoid/features/media_library/tag_editor/tag_editor_screen.dart';
import 'package:harmonoid/features/media_library/tracks/tracks_screen.dart';
import 'package:harmonoid/features/now_playing/now_playing_lyrics_screen.dart';
import 'package:harmonoid/features/now_playing/now_playing_screen.dart';
import 'package:harmonoid/features/settings/settings_screen.dart';
import 'package:harmonoid/features/settings/state/settings_notifier.dart';
import 'package:harmonoid/features/user/login/login_screen.dart';
import 'package:harmonoid/features/user/login/state/login_notifier.dart';

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
                  path: kFoldersPath,
                  pageBuilder: (context, state) {
                    return buildPageWithSharedAxisTransition(
                      context: context,
                      state: state,
                      child: const FoldersScreen(),
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
                    albums: extra.albums,
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
        final highlightMediaLibraryAddFolder = state.uri.queryParameters[kSettingsArgFrom] == kSettingsArgFromMediaLibraryNoItems;
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: ChangeNotifierProvider(
            create: (_) => SettingsNotifier(
              highlightMediaLibraryAddFolder: highlightMediaLibraryAddFolder,
            ),
            child: const SettingsScreen(),
          ),
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
      path: '/$kTagEditorPath',
      pageBuilder: (context, state) {
        final resource = state.uri.queryParameters[kTagEditorArgResource]!;
        final demo = state.uri.queryParameters[kTagEditorArgDemo] == 'true';
        return buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: TagEditorScreen(resource: resource, demo: demo),
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
