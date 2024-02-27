import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ReorderableDragStartListener, Intent;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:media_library/media_library.dart' hide MediaLibrary;
import 'package:provider/provider.dart';
import 'package:uri_parser/uri_parser.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/core/media_player.dart';
import 'package:harmonoid/extensions/global_key.dart';
import 'package:harmonoid/interface/settings/about.dart';

import 'package:harmonoid/interface/file_info_screen.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/mappers/track.dart';
import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/state/mobile_now_playing_notifier.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/keyboard_shortcuts.dart';
import 'package:harmonoid/utils/rendering.dart';

class DesktopHeader extends StatefulWidget {
  final int tab;
  final ValueNotifier<bool> floatingNotifier;
  const DesktopHeader({
    super.key,
    required this.tab,
    required this.floatingNotifier,
  });

  @override
  DesktopHeaderState createState() => DesktopHeaderState();
}

class DesktopHeaderState extends State<DesktopHeader> {
  bool hover0 = false;
  bool hover1 = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: () async {
            switch (widget.tab) {
              case kAlbumTab:
                final playables = <Playable>[];
                for (final album in MediaLibrary.instance.albums) {
                  final tracks = await MediaLibrary.instance.tracksFromAlbum(album);
                  playables.addAll(tracks.map((e) => e.toPlayable()));
                }
                await MediaPlayer.instance.open(playables);
                break;
              case kTrackTab:
                await MediaPlayer.instance.open(MediaLibrary.instance.tracks.map((e) => e.toPlayable()).toList());
                break;
              case kArtistTab:
                final playables = <Playable>[];
                for (final artist in MediaLibrary.instance.artists) {
                  final tracks = await MediaLibrary.instance.tracksFromArtist(artist);
                  playables.addAll(tracks.map((e) => e.toPlayable()));
                }
                await MediaPlayer.instance.open(playables);
                break;
              case kGenreTab:
                final playables = <Playable>[];
                for (final genre in MediaLibrary.instance.genres) {
                  final tracks = await MediaLibrary.instance.tracksFromGenre(genre);
                  playables.addAll(tracks.map((e) => e.toPlayable()));
                }
                await MediaPlayer.instance.open(playables);
                break;
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() {
              hover0 = true;
            }),
            onExit: (_) => setState(() {
              hover0 = false;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    Language.instance.PLAY_ALL,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: hover0 ? TextDecoration.underline : TextDecoration.none,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: () {
            MediaPlayer.instance.open(
              [...MediaLibrary.instance.tracks.map((e) => e.toPlayable())]..shuffle(),
            );
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() {
              hover1 = true;
            }),
            onExit: (_) => setState(() {
              hover1 = false;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shuffle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    Language.instance.SHUFFLE,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: hover1 ? TextDecoration.underline : TextDecoration.none,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        ValueListenableBuilder<bool>(
          valueListenable: widget.floatingNotifier,
          builder: (context, floating, _) => AnimatedOpacity(
            opacity: floating ? 0.0 : 1.0,
            duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
          ),
          child: DesktopSortButton(
            tab: widget.tab,
            floating: false,
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------

class DesktopFloatingSortButton extends StatefulWidget {
  final int tab;
  final ValueNotifier<bool> floatingNotifier;
  const DesktopFloatingSortButton({
    super.key,
    required this.tab,
    required this.floatingNotifier,
  });

  @override
  State<DesktopFloatingSortButton> createState() => DesktopFloatingSortButtonState();
}

class DesktopFloatingSortButtonState extends State<DesktopFloatingSortButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.floatingNotifier,
      child: DesktopSortButton(
        tab: widget.tab,
        floating: true,
      ),
      builder: (context, floating, child) => AnimatedPositioned(
        curve: Curves.easeInOut,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        top: floating
            ? widget.tab == kTrackTab
                ? 28.0
                : 0
            : -72.0,
        right: tileMargin(context),
        child: Card(
          color: Theme.of(context).appBarTheme.backgroundColor,
          margin: EdgeInsets.only(top: tileMargin(context)),
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------

class DesktopSortButton extends StatefulWidget {
  final int tab;
  final bool floating;

  const DesktopSortButton({
    super.key,
    required this.tab,
    required this.floating,
  });

  @override
  State<DesktopSortButton> createState() => DesktopSortButtonState();
}

class DesktopSortButtonState extends State<DesktopSortButton> {
  bool _hover0 = false;
  bool _hover1 = false;
  final GlobalKey _key0 = GlobalKey();
  final GlobalKey _key1 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8.0),
          GestureDetector(
            key: _key0,
            onTap: () async {
              final value = await showMaterialMenu(
                elevation: 4.0,
                context: context,
                constraints: const BoxConstraints(maxWidth: double.infinity),
                position: RelativeRect.fromLTRB(
                  _key0.globalPaintBounds!.left - (widget.floating ? 8.0 : 0.0),
                  _key0.globalPaintBounds!.bottom + tileMargin(context) / (widget.floating ? 1.0 : 2.0),
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
                items: {
                  kAlbumTab: <PopupMenuItem>[
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.albumSortType == AlbumSortType.album,
                      value: AlbumSortType.album,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.A_TO_Z,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.albumSortType == AlbumSortType.timestamp,
                      value: AlbumSortType.timestamp,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.DATE_ADDED,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.albumSortType == AlbumSortType.year,
                      value: AlbumSortType.year,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.YEAR,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.albumSortType == AlbumSortType.albumArtist,
                      value: AlbumSortType.albumArtist,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.ALBUM_ARTIST,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                  ],
                  kTrackTab: <PopupMenuItem>[
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.trackSortType == TrackSortType.title,
                      value: TrackSortType.title,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.A_TO_Z,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.trackSortType == TrackSortType.timestamp,
                      value: TrackSortType.timestamp,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.DATE_ADDED,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.trackSortType == TrackSortType.year,
                      value: TrackSortType.year,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.YEAR,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                  ],
                  kArtistTab: <PopupMenuItem>[
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.artistSortType == ArtistSortType.artist,
                      value: ArtistSortType.artist,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.A_TO_Z,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.artistSortType == ArtistSortType.timestamp,
                      value: ArtistSortType.timestamp,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.DATE_ADDED,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                  ],
                  kGenreTab: <PopupMenuItem>[
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.genreSortType == GenreSortType.genre,
                      value: GenreSortType.genre,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.A_TO_Z,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                    CheckedPopupMenuItem(
                      checked: mediaLibrary.genreSortType == GenreSortType.timestamp,
                      value: GenreSortType.timestamp,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          Language.instance.DATE_ADDED,
                          style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                        ),
                      ),
                    ),
                  ],
                }[tab]!,
              );
              if (value is AlbumSortType) {
                mediaLibrary.populate(albumSortType: value);
                Configuration.instance.set(mediaLibraryAlbumSortType: value);
              } else if (value is TrackSortType) {
                mediaLibrary.populate(trackSortType: value);
                Configuration.instance.set(mediaLibraryTrackSortType: value);
              } else if (value is ArtistSortType) {
                mediaLibrary.populate(artistSortType: value);
                Configuration.instance.set(mediaLibraryArtistSortType: value);
              } else if (value is GenreSortType) {
                mediaLibrary.populate(genreSortType: value);
                Configuration.instance.set(mediaLibraryGenreSortType: value);
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => setState(() => _hover0 = true),
              onExit: (e) => setState(() => _hover0 = false),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                height: 28.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 4.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${Language.instance.SORT_BY}: ',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          TextSpan(
                            text: {
                              kAlbumTab: {
                                AlbumSortType.album: Language.instance.A_TO_Z,
                                AlbumSortType.timestamp: Language.instance.DATE_ADDED,
                                AlbumSortType.year: Language.instance.YEAR,
                                AlbumSortType.albumArtist: Language.instance.ALBUM_ARTIST,
                              }[mediaLibrary.albumSortType]!,
                              kTrackTab: {
                                TrackSortType.title: Language.instance.A_TO_Z,
                                TrackSortType.timestamp: Language.instance.DATE_ADDED,
                                TrackSortType.year: Language.instance.YEAR,
                              }[mediaLibrary.trackSortType]!,
                              kArtistTab: {
                                ArtistSortType.artist: Language.instance.A_TO_Z,
                                ArtistSortType.timestamp: Language.instance.DATE_ADDED,
                              }[mediaLibrary.artistSortType]!,
                              kGenreTab: {
                                GenreSortType.genre: Language.instance.A_TO_Z,
                                GenreSortType.timestamp: Language.instance.DATE_ADDED,
                              }[mediaLibrary.genreSortType]!,
                            }[tab]!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: _hover0 ? TextDecoration.underline : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
            key: _key1,
            onTap: () async {
              final value = await showMaterialMenu(
                elevation: 4.0,
                context: context,
                constraints: const BoxConstraints(maxWidth: double.infinity),
                position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width,
                  _key1.globalPaintBounds!.bottom + tileMargin(context) / (widget.floating ? 1.0 : 2.0),
                  tileMargin(context) + (widget.floating ? 0.0 : 8.0),
                  0.0,
                ),
                items: <PopupMenuEntry<bool>>[
                  CheckedPopupMenuItem<bool>(
                    checked: {
                      kAlbumTab: mediaLibrary.albumSortAscending,
                      kTrackTab: mediaLibrary.trackSortAscending,
                      kArtistTab: mediaLibrary.artistSortAscending,
                      kGenreTab: mediaLibrary.genreSortAscending,
                    }[tab]!,
                    value: true,
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        Language.instance.ASCENDING,
                        style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                      ),
                    ),
                  ),
                  CheckedPopupMenuItem<bool>(
                    checked: {
                      kAlbumTab: !mediaLibrary.albumSortAscending,
                      kTrackTab: !mediaLibrary.trackSortAscending,
                      kArtistTab: !mediaLibrary.artistSortAscending,
                      kGenreTab: !mediaLibrary.genreSortAscending,
                    }[tab]!,
                    value: false,
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        Language.instance.DESCENDING,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              );
              switch (tab) {
                case kAlbumTab:
                  mediaLibrary.populate(albumSortAscending: value!);
                  Configuration.instance.set(mediaLibraryAlbumSortAscending: value);
                  break;
                case kTrackTab:
                  mediaLibrary.populate(trackSortAscending: value!);
                  Configuration.instance.set(mediaLibraryTrackSortAscending: value);
                  break;
                case kArtistTab:
                  mediaLibrary.populate(artistSortAscending: value!);
                  Configuration.instance.set(mediaLibraryArtistSortAscending: value);
                  break;
                case kGenreTab:
                  mediaLibrary.populate(genreSortAscending: value!);
                  Configuration.instance.set(mediaLibraryGenreSortAscending: value);
                  break;
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => setState(() => _hover1 = true),
              onExit: (e) => setState(() => _hover1 = false),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                height: 28.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 4.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${Language.instance.ORDER}: ',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          TextSpan(
                            text: {
                              true: Language.instance.ASCENDING,
                              false: Language.instance.DESCENDING,
                            }[{
                              kAlbumTab: mediaLibrary.albumSortAscending,
                              kTrackTab: mediaLibrary.trackSortAscending,
                              kArtistTab: mediaLibrary.artistSortAscending,
                              kGenreTab: mediaLibrary.genreSortAscending,
                            }[tab]!]!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: _hover1 ? TextDecoration.underline : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class MobileHeader extends StatelessWidget {
  final int tab;
  const MobileHeader({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kMobileHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: tileMargin(context)),
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          const SizedBox(width: 8.0),
          if (tab == kAlbumTab)
            Text('${MediaLibrary.instance.albums.length} ${Language.instance.ALBUM}')
          else if (tab == kTrackTab)
            Text('${MediaLibrary.instance.tracks.length} ${Language.instance.TRACK}')
          else if (tab == kArtistTab)
            Text('${MediaLibrary.instance.artists.length} ${Language.instance.ARTIST}')
          else if (tab == kGenreTab)
            Text('${MediaLibrary.instance.genres.length} ${Language.instance.GENRE}'),
          const Spacer(),
          MobileSortByButton(tab: tab),
        ],
      ),
    );
  }
}

// --------------------------------------------------

class MobileSortByButton extends StatefulWidget {
  final int tab;
  const MobileSortByButton({super.key, required this.tab});

  @override
  State<MobileSortByButton> createState() => MobileSortByButtonState();
}

class MobileSortByButtonState extends State<MobileSortByButton> {
  Future<void> handle(dynamic value) async {
    if (value is AlbumSortType) {
      MediaLibrary.instance.populate(albumSortType: value);
      Configuration.instance.set(mediaLibraryAlbumSortType: value);
    } else if (value is TrackSortType) {
      MediaLibrary.instance.populate(trackSortType: value);
      Configuration.instance.set(mediaLibraryTrackSortType: value);
    } else if (value is ArtistSortType) {
      MediaLibrary.instance.populate(artistSortType: value);
      Configuration.instance.set(mediaLibraryArtistSortType: value);
    } else if (value is GenreSortType) {
      MediaLibrary.instance.populate(genreSortType: value);
      Configuration.instance.set(mediaLibraryGenreSortType: value);
    }
    if (value == true) {
      switch (widget.tab) {
        case kAlbumTab:
          MediaLibrary.instance.populate(albumSortAscending: true);
          Configuration.instance.set(mediaLibraryAlbumSortAscending: true);
          break;
        case kTrackTab:
          MediaLibrary.instance.populate(trackSortAscending: true);
          Configuration.instance.set(mediaLibraryTrackSortAscending: true);
          break;
        case kArtistTab:
          MediaLibrary.instance.populate(artistSortAscending: true);
          Configuration.instance.set(mediaLibraryArtistSortAscending: true);
          break;
        case kGenreTab:
          MediaLibrary.instance.populate(genreSortAscending: true);
          Configuration.instance.set(mediaLibraryGenreSortAscending: true);
          break;
      }
    } else if (value == false) {
      switch (widget.tab) {
        case kAlbumTab:
          MediaLibrary.instance.populate(albumSortAscending: false);
          Configuration.instance.set(mediaLibraryAlbumSortAscending: false);
          break;
        case kTrackTab:
          MediaLibrary.instance.populate(trackSortAscending: false);
          Configuration.instance.set(mediaLibraryTrackSortAscending: false);
          break;
        case kArtistTab:
          MediaLibrary.instance.populate(artistSortAscending: false);
          Configuration.instance.set(mediaLibraryArtistSortAscending: false);
          break;
        case kGenreTab:
          MediaLibrary.instance.populate(genreSortAscending: false);
          Configuration.instance.set(mediaLibraryGenreSortAscending: false);
          break;
      }
    }
    setStateCallback?.call(() {});
  }

  void Function(void Function())? setStateCallback;

  List<MobileSortButtonPopupMenuItem> get sort => {
        kAlbumTab: <MobileSortButtonPopupMenuItem>[
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(AlbumSortType.album),
            checked: MediaLibrary.instance.albumSortType == AlbumSortType.album,
            value: AlbumSortType.album,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.A_TO_Z,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(AlbumSortType.timestamp),
            checked: MediaLibrary.instance.albumSortType == AlbumSortType.timestamp,
            value: AlbumSortType.timestamp,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.DATE_ADDED,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(AlbumSortType.year),
            checked: MediaLibrary.instance.albumSortType == AlbumSortType.year,
            value: AlbumSortType.year,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.YEAR,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(AlbumSortType.albumArtist),
            checked: MediaLibrary.instance.albumSortType == AlbumSortType.albumArtist,
            value: AlbumSortType.albumArtist,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.ALBUM_ARTIST,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ],
        kTrackTab: <MobileSortButtonPopupMenuItem>[
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(TrackSortType.title),
            checked: MediaLibrary.instance.trackSortType == TrackSortType.title,
            value: TrackSortType.title,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.A_TO_Z,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(TrackSortType.timestamp),
            checked: MediaLibrary.instance.trackSortType == TrackSortType.timestamp,
            value: TrackSortType.timestamp,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.DATE_ADDED,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(TrackSortType.year),
            checked: MediaLibrary.instance.trackSortType == TrackSortType.year,
            value: TrackSortType.year,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.YEAR,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ],
        kArtistTab: <MobileSortButtonPopupMenuItem>[
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(ArtistSortType.artist),
            checked: MediaLibrary.instance.artistSortType == ArtistSortType.artist,
            value: ArtistSortType.artist,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.A_TO_Z,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(ArtistSortType.timestamp),
            checked: MediaLibrary.instance.artistSortType == ArtistSortType.timestamp,
            value: ArtistSortType.timestamp,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.DATE_ADDED,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ],
        kGenreTab: <MobileSortButtonPopupMenuItem>[
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(GenreSortType.genre),
            checked: MediaLibrary.instance.genreSortType == GenreSortType.genre,
            value: GenreSortType.genre,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.A_TO_Z,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
          MobileSortButtonPopupMenuItem(
            onTap: () => handle(GenreSortType.timestamp),
            checked: MediaLibrary.instance.genreSortType == GenreSortType.timestamp,
            value: GenreSortType.timestamp,
            padding: EdgeInsets.zero,
            child: Text(
              Language.instance.DATE_ADDED,
              style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
            ),
          ),
        ],
      }[widget.tab]!;

  List<MobileSortButtonPopupMenuItem> get order => [
        MobileSortButtonPopupMenuItem(
          onTap: () => handle(true),
          checked: {
            kAlbumTab: MediaLibrary.instance.albumSortAscending,
            kTrackTab: MediaLibrary.instance.trackSortAscending,
            kArtistTab: MediaLibrary.instance.artistSortAscending,
            kGenreTab: MediaLibrary.instance.genreSortAscending,
          }[widget.tab]!,
          value: true,
          padding: EdgeInsets.zero,
          child: Text(
            Language.instance.ASCENDING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
        MobileSortButtonPopupMenuItem(
          onTap: () => handle(false),
          checked: {
            kAlbumTab: !MediaLibrary.instance.albumSortAscending,
            kTrackTab: !MediaLibrary.instance.trackSortAscending,
            kArtistTab: !MediaLibrary.instance.artistSortAscending,
            kGenreTab: !MediaLibrary.instance.genreSortAscending,
          }[widget.tab]!,
          value: false,
          padding: EdgeInsets.zero,
          child: Text(
            Language.instance.DESCENDING,
            style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final color = isMaterial2(context) && Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color;
    return InkWell(
      borderRadius: isMaterial2(context) ? BorderRadius.circular(4.0) : BorderRadius.circular(20.0),
      onTap: () async {
        if (widget.tab == 3) return;
        await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          elevation: kDefaultHeavyElevation,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              setStateCallback = setState;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...sort,
                  const PopupMenuDivider(),
                  ...order,
                  if (!isDesktop && !MobileNowPlayingNotifier.instance.hidden) const SizedBox(height: kMobileNowPlayingBarHeight),
                ],
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              String.fromCharCode(order.firstWhere((e) => e.checked).value ? Icons.arrow_upward.codePoint : Icons.arrow_downward.codePoint),
              style: TextStyle(
                inherit: false,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                fontFamily: Icons.arrow_downward.fontFamily,
                package: Icons.arrow_downward.fontPackage,
                color: color,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              label(context, (sort.firstWhere((e) => e.checked).child as Text).data.toString()),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
            ),
            const SizedBox(width: 4.0),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------

class MobileSortButtonPopupMenuItem<T> extends StatelessWidget {
  final T value;
  final bool checked;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets? padding;

  const MobileSortButtonPopupMenuItem({
    super.key,
    required this.value,
    this.checked = false,
    required this.onTap,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem(
      padding: padding,
      child: ListTile(
        onTap: onTap,
        leading: AnimatedOpacity(
          opacity: checked ? 1.0 : 0.0,
          curve: Curves.easeInOut,
          duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
          child: const Icon(Icons.done),
        ),
        title: child,
      ),
    );
  }
}

// --------------------------------------------------

class ScaleOnHover extends StatefulWidget {
  final Widget child;
  const ScaleOnHover({super.key, required this.child});

  @override
  ScaleOnHoverState createState() => ScaleOnHoverState();
}

class ScaleOnHoverState extends State<ScaleOnHover> {
  double scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => scale = 1.05),
      onExit: (e) => setState(() => scale = 1.00),
      child: AnimatedScale(
        scale: scale,
        duration: Theme.of(context).extension<AnimationDuration>()?.fast ?? Duration.zero,
        child: widget.child,
      ),
    );
  }
}

// --------------------------------------------------

class SubHeader extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;
  final double height;

  const SubHeader(
    this.text, {
    super.key,
    this.padding,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = isDesktop ? 24.0 : 16.0;
    final fontSize = isDesktop ? 16.0 : null;
    final TextStyle? style;
    if (isMaterial2(context) && isMobile) {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: fontSize,
          );
    } else if (isMaterial2(context) && isDesktop) {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: fontSize,
          );
    } else {
      style = Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: fontSize,
          );
    }
    return Container(
      alignment: Alignment.centerLeft,
      height: height,
      padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

// --------------------------------------------------

class RefreshMediaLibraryButton extends StatefulWidget {
  const RefreshMediaLibraryButton({super.key});

  @override
  RefreshMediaLibraryButtonState createState() => RefreshMediaLibraryButtonState();
}

class RefreshMediaLibraryButtonState extends State<RefreshMediaLibraryButton> {
  bool lock = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaLibrary>(
      builder: (context, mediaLibrary, _) => mediaLibrary.done
          ? FloatingActionButton(
              heroTag: 'collection_refresh_button',
              child: const Icon(Icons.refresh),
              onPressed: () {
                if (lock) return;
                lock = true;
                mediaLibrary.refresh(progress: (current, total, done) {
                  mediaLibrary.progress(current, total, done);

                  if (done) {
                    lock = false;
                  }
                });
              },
            )
          : const SizedBox.shrink(),
    );
  }
}

// --------------------------------------------------

class HyperLink extends StatefulWidget {
  final TextSpan text;
  final TextStyle? style;
  const HyperLink({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<HyperLink> createState() => HyperLinkState();
}

class HyperLinkState extends State<HyperLink> {
  String hover = '';

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: widget.style,
        children: widget.text.children!
            .map(
              (e) => TextSpan(
                text: (e as TextSpan).text?.overflow,
                style: e.recognizer != null
                    ? widget.style?.copyWith(
                        decoration: hover == e.text! ? TextDecoration.underline : null,
                      )
                    : null,
                recognizer: e.recognizer,
                onEnter: (_) {
                  if (mounted) {
                    setState(() {
                      hover = e.text!;
                    });
                  }
                },
                onExit: (_) {
                  if (mounted) {
                    setState(() {
                      hover = '';
                    });
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

// --------------------------------------------------

class Banner extends StatelessWidget {
  final String title;
  final String subtitle;

  const Banner({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      width: 480.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.memory(
            {
              // TODO:
              // Language.instance.NO_COLLECTION_TITLE: VisualAssets.library,
              // Language.instance.NO_INTERNET_TITLE: VisualAssets.library,
              // Language.instance.COLLECTION_SEARCH_NO_RESULTS_TITLE: VisualAssets.searchPage,
              // Language.instance.WEB_WELCOME_TITLE: VisualAssets.searchNotes,
              // Language.instance.COLLECTION_SEARCH_LABEL: VisualAssets.searchPage,
            }[title]!,
            height: 164.0,
            width: 164.0,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (title == Language.instance.NO_COLLECTION_TITLE) ...[
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialRoute(
                    builder: (context) => Settings(),
                  ),
                );
              },
              child: Text(
                label(context, Language.instance.GO_TO_SETTINGS),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --------------------------------------------------

class MobileNavigationBar extends StatefulWidget {
  final ValueNotifier<TabRoute> tabRouteNotifier;
  const MobileNavigationBar({super.key, required this.tabRouteNotifier});

  @override
  State<MobileNavigationBar> createState() => MobileNavigationBarState();
}

class MobileNavigationBarState extends State<MobileNavigationBar> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.tabRouteNotifier.value.tab;
    widget.tabRouteNotifier.addListener(onChange);
  }

  @override
  void dispose() {
    widget.tabRouteNotifier.removeListener(onChange);
    super.dispose();
  }

  void onChange() {
    if (_tab != widget.tabRouteNotifier.value.tab) {
      setState(() => _tab = widget.tabRouteNotifier.value.tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isMaterial3(context)
        ? NavigationBar(
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.album),
                label: Language.instance.ALBUM,
              ),
              NavigationDestination(
                icon: const Icon(Icons.music_note),
                label: Language.instance.TRACK,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person),
                label: Language.instance.ARTIST,
              ),
              NavigationDestination(
                icon: const Icon(Icons.playlist_play),
                label: Language.instance.PLAYLIST,
              ),
            ],
          )
        : ValueListenableBuilder<Iterable<Color>?>(
            valueListenable: MobileNowPlayingNotifier.instance.palette,
            builder: (context, value, _) => TweenAnimationBuilder<Color?>(
              duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
              tween: ColorTween(
                begin: Theme.of(context).colorScheme.primary,
                end: value?.first ?? Theme.of(context).colorScheme.primary,
              ),
              builder: (context, color, _) => Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 8.0),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _tab,
                  selectedItemColor: (color?.computeLuminance() ?? 0.0) < 0.5 ? null : Colors.black87,
                  unselectedItemColor: (color?.computeLuminance() ?? 0.0) < 0.5 ? null : Colors.black45,
                  type: BottomNavigationBarType.shifting,
                  onTap: (tab) {
                    MobileNowPlayingNotifier.instance.restore();
                    if (tab != _tab) {
                      widget.tabRouteNotifier.value = TabRoute(tab, TabRouteSender.bottomNavigationBar);
                    }
                    setState(() {
                      _tab = tab;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.album),
                      label: Language.instance.ALBUM,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.music_note),
                      label: Language.instance.TRACK,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: Language.instance.ARTIST,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.playlist_play),
                      label: Language.instance.PLAYLIST,
                      backgroundColor: color ?? Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

// --------------------------------------------------

class ShowAllButton extends StatelessWidget {
  final void Function()? onPressed;
  const ShowAllButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Row(
          children: [
            Icon(
              Icons.view_list,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              width: 4.0,
            ),
            Text(
              Language.instance.SEE_ALL,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------

class ScrollableSlider extends StatelessWidget {
  final double min;
  final double max;
  final bool enabled;
  final double value;
  final Color? color;
  final Color? secondaryColor;
  final VoidCallback onScrolledUp;
  final VoidCallback onScrolledDown;
  final void Function(double) onChanged;
  final bool inferSliderInactiveTrackColor;
  final bool mobile;

  const ScrollableSlider({
    super.key,
    required this.min,
    required this.max,
    this.enabled = true,
    required this.value,
    this.color,
    this.secondaryColor,
    required this.onScrolledUp,
    required this.onScrolledDown,
    required this.onChanged,
    this.inferSliderInactiveTrackColor = true,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          if (event.scrollDelta.dy < 0) {
            onScrolledUp();
          }
          if (event.scrollDelta.dy > 0) {
            onScrolledDown();
          }
        }
      },
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: (mobile && isMobile) ? null : 2.0,
          trackShape: CustomTrackShape(),
          thumbShape: (mobile && isMobile) ? null : const RoundSliderThumbShape(enabledThumbRadius: 6.0, pressedElevation: 4.0, elevation: 2.0),
          overlayShape: (mobile && isMobile) ? null : const RoundSliderOverlayShape(overlayRadius: 12.0),
          overlayColor: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.4),
          thumbColor: enabled ? (color ?? Theme.of(context).colorScheme.primary) : Theme.of(context).disabledColor,
          activeTrackColor: enabled ? (color ?? Theme.of(context).colorScheme.primary) : Theme.of(context).disabledColor,
          inactiveTrackColor: enabled
              ? ((mobile && isMobile)
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : inferSliderInactiveTrackColor
                      ? ((secondaryColor != null ? (secondaryColor?.computeLuminance() ?? 0.0) < 0.5 : Theme.of(context).brightness == Brightness.dark)
                          ? Colors.white.withOpacity(0.4)
                          : Colors.black.withOpacity(0.2))
                      : Colors.white.withOpacity(0.4))
              : Theme.of(context).disabledColor.withOpacity(0.2),
        ),
        child: Slider(
          value: value,
          onChanged: enabled ? onChanged : null,
          min: min,
          max: max,
        ),
      ),
    );
  }
}

// --------------------------------------------------

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

// --------------------------------------------------

class DefaultTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? cursorWidth;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingComplete;
  final InputDecoration? decoration;
  final TextAlignVertical? textAlignVertical;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? readOnly;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ScrollPhysics? scrollPhysics;
  final TextAlign? textAlign;
  const DefaultTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.cursorWidth,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.decoration,
    this.textAlignVertical,
    this.autofocus,
    this.autocorrect,
    this.readOnly,
    this.style,
    this.keyboardType,
    this.textCapitalization,
    this.textInputAction,
    this.inputFormatters,
    this.scrollPhysics,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsInterceptor(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        cursorWidth: cursorWidth ?? 2.0,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        decoration: decoration,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus ?? false,
        autocorrect: autocorrect ?? true,
        readOnly: readOnly ?? false,
        style: style,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        scrollPhysics: scrollPhysics,
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}

// --------------------------------------------------

class DefaultTextFormField extends StatelessWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? cursorWidth;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final InputDecoration? decoration;
  final TextAlignVertical? textAlignVertical;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? readOnly;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ScrollPhysics? scrollPhysics;
  final TextAlign? textAlign;
  const DefaultTextFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.cursorWidth,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.decoration,
    this.textAlignVertical,
    this.autofocus,
    this.autocorrect,
    this.readOnly,
    this.style,
    this.keyboardType,
    this.textCapitalization,
    this.textInputAction,
    this.inputFormatters,
    this.scrollPhysics,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsInterceptor(
      child: TextFormField(
        initialValue: initialValue,
        controller: controller,
        focusNode: focusNode,
        cursorWidth: cursorWidth ?? 2.0,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        decoration: decoration,
        textAlignVertical: textAlignVertical,
        autofocus: autofocus ?? false,
        autocorrect: autocorrect ?? true,
        readOnly: readOnly ?? false,
        style: style,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        scrollPhysics: scrollPhysics,
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}

// --------------------------------------------------

class DefaultSwitchListTile extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  final String title;
  final String subtitle;
  const DefaultSwitchListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      title: Text(
        isDesktop ? subtitle : title,
        style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onChanged: (value) {
        onChanged.call(value);
      },
    );
  }
}

// --------------------------------------------------

class NowPlayingBarScrollHideNotifier extends StatelessWidget {
  final Widget child;
  const NowPlayingBarScrollHideNotifier({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return child;
    } else {
      return NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical &&
              [
                AxisDirection.up,
                AxisDirection.down,
              ].contains(notification.metrics.axisDirection)) {
            if (notification.direction == ScrollDirection.forward) {
              MobileNowPlayingNotifier.instance.show();
            } else if (notification.direction == ScrollDirection.reverse) {
              MobileNowPlayingNotifier.instance.hide();
            }
          }
          return true;
        },
        child: child,
      );
    }
  }
}

// --------------------------------------------------

class PlayFileOrURLButton extends StatelessWidget {
  const PlayFileOrURLButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: Language.instance.OPEN_FILE_OR_URL,
      icon: Icon(
        Icons.file_open,
        color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      splashRadius: 20.0,
      iconSize: 20.0,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(
              Language.instance.OPEN_FILE_OR_URL,
            ),
            children: [
              ListTile(
                onTap: () async {
                  final file = await pickFile(
                    label: Language.instance.MEDIA_FILES,
                    extensions: MediaLibrary.instance.supportedFileTypes,
                  );
                  if (file != null) {
                    await Navigator.of(ctx).maybePop();
                    await Intent.instance.play(file.uri.toString());
                  }
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(ctx).iconTheme.color,
                  child: const Icon(Icons.folder),
                ),
                title: Text(
                  Language.instance.FILE,
                  style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
                ),
              ),
              ListTile(
                onTap: () async {
                  await Navigator.of(ctx).maybePop();
                  String input = '';
                  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                  await showDialog(
                    context: ctx,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        Language.instance.OPEN_FILE_OR_URL,
                      ),
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
                                  validator: (value) {
                                    final parser = URIParser(value);
                                    if (!parser.validate()) {
                                      debugPrint(value);
                                      return '';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) async {
                                    if (value.isNotEmpty && (formKey.currentState?.validate() ?? false)) {
                                      Navigator.of(ctx).maybePop();
                                      await Intent.instance.play(value);
                                    }
                                  },
                                  textAlignVertical: TextAlignVertical.center,
                                  style: Theme.of(ctx).textTheme.bodyLarge,
                                  decoration: inputDecoration(
                                    ctx,
                                    Language.instance.PLAY_URL_SUBTITLE,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            label(
                              context,
                              Language.instance.PLAY,
                            ),
                          ),
                          onPressed: () async {
                            if (input.isNotEmpty && (formKey.currentState?.validate() ?? false)) {
                              Navigator.of(ctx).maybePop();
                              await Intent.instance.play(input);
                            }
                          },
                        ),
                        TextButton(
                          onPressed: Navigator.of(ctx).maybePop,
                          child: Text(label(context, Language.instance.CANCEL)),
                        ),
                      ],
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(ctx).iconTheme.color,
                  child: const Icon(Icons.link),
                ),
                title: Text(
                  Language.instance.URL,
                  style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --------------------------------------------------

class ReadFileOrURLMetadataButton extends StatelessWidget {
  const ReadFileOrURLMetadataButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: Language.instance.READ_METADATA,
      icon: Icon(
        Icons.file_open,
        color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      splashRadius: 20.0,
      iconSize: 20.0,
      onPressed: () async {
        FileInfoScreen.show(context);
      },
    );
  }
}

// --------------------------------------------------

class MobileAppBarOverflowButton extends StatefulWidget {
  const MobileAppBarOverflowButton({super.key});

  @override
  State<MobileAppBarOverflowButton> createState() => MobileAppBarOverflowButtonState();
}

class MobileAppBarOverflowButtonState extends State<MobileAppBarOverflowButton> {
  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      onPressed: () async {
        Completer<int> completer = Completer<int>();
        await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          elevation: kDefaultHeavyElevation,
          useRootNavigator: false,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuItem(
                onTap: () {
                  completer.complete(0);
                  Navigator.of(context).maybePop();
                },
                child: ListTile(
                  leading: const Icon(Icons.file_open),
                  title: Text(
                    Language.instance.OPEN_FILE_OR_URL,
                    style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                  ),
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  completer.complete(1);
                  Navigator.of(context).maybePop();
                },
                child: ListTile(
                  leading: const Icon(Icons.code),
                  title: Text(
                    Language.instance.READ_METADATA,
                    style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                  ),
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  completer.complete(2);
                  Navigator.of(context).maybePop();
                },
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(
                    Language.instance.SETTING,
                    style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                  ),
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  completer.complete(3);
                  Navigator.of(context).maybePop();
                },
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(
                    Language.instance.ABOUT_TITLE,
                    style: isDesktop ? Theme.of(context).textTheme.bodyLarge : null,
                  ),
                ),
              ),
              if (!isDesktop && !MobileNowPlayingNotifier.instance.hidden) const SizedBox(height: kMobileNowPlayingBarHeight),
            ],
          ),
        );
        completer.future.then((value) async {
          await Future.delayed(const Duration(milliseconds: 300));
          switch (value) {
            case 0:
              {
                await showDialog(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: Text(
                      Language.instance.OPEN_FILE_OR_URL,
                    ),
                    children: [
                      ListTile(
                        onTap: () async {
                          final file = await pickFile(
                            label: Language.instance.MEDIA_FILES,
                            extensions: MediaLibrary.instance.supportedFileTypes,
                          );
                          if (file != null) {
                            await Navigator.of(ctx).maybePop();
                            await Intent.instance.play(file.uri.toString());
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(ctx).iconTheme.color,
                          child: const Icon(Icons.folder),
                        ),
                        title: Text(
                          Language.instance.FILE,
                          style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          await Navigator.of(ctx).maybePop();
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
                                    bottom: MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).padding.bottom,
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
                                          validator: (value) {
                                            final parser = URIParser(value);
                                            if (!parser.validate()) {
                                              debugPrint(value);
                                              // Empty [String] prevents the message from showing & does not distort the UI.
                                              return '';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) => input = value,
                                          keyboardType: TextInputType.url,
                                          textCapitalization: TextCapitalization.none,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (value) async {
                                            if (formKey.currentState?.validate() ?? false) {
                                              await Navigator.of(context).maybePop();
                                              await Intent.instance.play(value);
                                            }
                                          },
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontSize: 16.0,
                                              ),
                                          decoration: inputDecorationMobile(context, Language.instance.FILE_PATH_OR_URL),
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (formKey.currentState?.validate() ?? false) {
                                            await Navigator.of(context).maybePop();
                                            await Intent.instance.play(input);
                                          }
                                        },
                                        child: Text(
                                          label(
                                            context,
                                            Language.instance.PLAY,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(ctx).iconTheme.color,
                          child: const Icon(Icons.link),
                        ),
                        title: Text(
                          Language.instance.URL,
                          style: isDesktop ? Theme.of(ctx).textTheme.bodyLarge : null,
                        ),
                      ),
                    ],
                  ),
                );
                break;
              }
            case 1:
              {
                await FileInfoScreen.show(context);
                break;
              }
            case 2:
              {
                await Navigator.push(
                  context,
                  MaterialRoute(
                    builder: (context) => Settings(),
                  ),
                );
                break;
              }
            case 3:
              {
                await Navigator.push(
                  context,
                  MaterialRoute(
                    builder: (context) => AboutPage(),
                  ),
                );
                break;
              }
          }
        });
      },
    );
  }
}

// --------------------------------------------------

class StillGIF extends StatefulWidget {
  final ImageProvider image;
  final double width;
  final double height;

  const StillGIF({
    super.key,
    required this.image,
    required this.width,
    required this.height,
  });

  factory StillGIF.asset(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: AssetImage(image),
        width: width,
        height: height,
      );

  factory StillGIF.file(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: FileImage(File(image)),
        width: width,
        height: height,
      );

  factory StillGIF.network(
    String image, {
    Key? key,
    required double width,
    required double height,
  }) =>
      StillGIF(
        key: key,
        image: NetworkImage(image),
        width: width,
        height: height,
      );

  @override
  State<StillGIF> createState() => StillGIFState();
}

class StillGIFState extends State<StillGIF> {
  RawImage? image;

  @override
  void initState() {
    super.initState();
    draw();
  }

  Future<void> draw() async {
    await widget.image.evict();
    if (widget.image is NetworkImage) {
      final resolved = Uri.base.resolve((widget.image as NetworkImage).url);
      final request = await HttpClient().getUrl(resolved);
      final HttpClientResponse response = await request.close();
      final data = await consolidateHttpClientResponseBytes(response);
      final buffer = await ImmutableBuffer.fromUint8List(data);
      final codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    } else if (widget.image is AssetImage) {
      final buffer = await ImmutableBuffer.fromAsset(
        (widget.image as AssetImage).assetName,
      );
      final codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    } else if (widget.image is FileImage) {
      final data = await (widget.image as FileImage).file.readAsBytes();
      final buffer = await ImmutableBuffer.fromUint8List(data);
      final codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
      final frame = await codec.getNextFrame();
      setState(() {
        image = RawImage(
          image: frame.image.clone(),
          height: widget.height,
          width: widget.width,
          fit: BoxFit.cover,
        );
      });
    }
  }

  @override
  void dispose() {
    widget.image.evict();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return image ??
        SizedBox(
          width: widget.width,
          height: widget.height,
        );
  }
}

// --------------------------------------------------

/// {@template tab_route}
///
/// TabRoute
/// --------
///
/// {@endtemplate}
class TabRoute {
  /// Tab.
  final int tab;

  /// Sender.
  final TabRouteSender sender;

  /// {@macro tab_route}
  const TabRoute(
    this.tab,
    this.sender,
  );
}

/// {@template tab_route_sender}
///
/// TabRouteSender
/// --------------
///
/// {@endtemplate}
enum TabRouteSender {
  pageView,
  bottomNavigationBar,
  systemNavigationBackButton,
}

// --------------------------------------------------
