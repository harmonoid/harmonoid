import 'package:flutter/material.dart';
import 'package:media_library/media_library.dart';

final ValueNotifier<Set<Track>> mediaLibrarySelectedTracks = ValueNotifier<Set<Track>>({});

BuildContext? mediaLibraryAlbumOpenContainerBuildContext;
BuildContext? mediaLibraryArtistOpenContainerBuildContext;
BuildContext? mediaLibraryGenreOpenContainerBuildContext;
bool mediaLibrarySearchViewVisible = false;
