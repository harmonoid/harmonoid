import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/ui/media_library/albums/albums_screen.dart';
import 'package:harmonoid/ui/media_library/artists/artists_screen.dart';
import 'package:harmonoid/ui/media_library/genres/genres_screen.dart';
import 'package:harmonoid/ui/media_library/media_library_screen.dart';
import 'package:harmonoid/ui/media_library/tracks/tracks_screen.dart';

const String kMediaLibraryPath = 'media-library';
const String kAlbumsPath = 'albums';
const String kTracksPath = 'tracks';
const String kArtistsPath = 'artists';
const String kGenresPath = 'genres';
const String kPlaylistsPath = 'playlists';
const String kAlbumPath = 'album';
const String kArtistPath = 'artist';
const String kGenrePath = 'genre';
const String kPlaylistPath = 'playlist';
const String kSearchPath = 'search';
const String kSettingsPath = 'settings';
const String kModernNowPlayingPath = 'modern-now-playing-screen';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) => '/$kMediaLibraryPath/${Configuration.instance.mediaLibraryPath}',
    ),
    GoRoute(
      path: '/$kMediaLibraryPath',
      redirect: (_, state) => state.fullPath,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return MediaLibraryScreen(child: child);
          },
          routes: [
            GoRoute(
              path: kAlbumsPath,
              pageBuilder: (context, state) {
                return buildPageWithMediaLibraryTransition(
                  context: context,
                  state: state,
                  child: const AlbumsScreen(),
                );
              },
            ),
            GoRoute(
              path: kTracksPath,
              pageBuilder: (context, state) {
                return buildPageWithMediaLibraryTransition(
                  context: context,
                  state: state,
                  child: const TracksScreen(),
                );
              },
            ),
            GoRoute(
              path: kArtistsPath,
              pageBuilder: (context, state) {
                return buildPageWithMediaLibraryTransition(
                  context: context,
                  state: state,
                  child: const ArtistsScreen(),
                );
              },
            ),
            GoRoute(
              path: kGenresPath,
              pageBuilder: (context, state) {
                return buildPageWithMediaLibraryTransition(
                  context: context,
                  state: state,
                  child: const GenresScreen(),
                );
              },
            ),
            GoRoute(
              path: kPlaylistsPath,
              builder: (context, state) {
                return const SizedBox();
              },
            ),
            GoRoute(
              path: kAlbumPath,
              builder: (context, state) {
                return const SizedBox();
              },
            ),
            GoRoute(
              path: kArtistPath,
              builder: (context, state) {
                return const SizedBox();
              },
            ),
            GoRoute(
              path: kGenrePath,
              builder: (context, state) {
                return const SizedBox();
              },
            ),
            GoRoute(
              path: kPlaylistPath,
              builder: (context, state) {
                return const SizedBox();
              },
            ),
            GoRoute(
              path: kSearchPath,
              builder: (context, state) {
                return const SizedBox();
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/$kSettingsPath',
      builder: (context, state) {
        return const SizedBox();
      },
    ),
    GoRoute(
      path: '/$kModernNowPlayingPath',
      builder: (context, state) {
        return const SizedBox();
      },
    ),
  ],
);

CustomTransitionPage buildPageWithMediaLibraryTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
    reverseTransitionDuration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.vertical,
      child: child,
    ),
  );
}
