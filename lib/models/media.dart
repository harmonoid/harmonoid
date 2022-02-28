/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:harmonoid/utils/file_system.dart';

part 'album_artist.dart';
part 'album.dart';
part 'artist.dart';
part 'playlist.dart';
part 'track.dart';

const String kUnknownYear = 'Unknown Year';
const String kUnknownAlbum = 'Unknown Album';
const String kUnknownArtist = 'Unknown Artist';

abstract class Media {
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object media) {
    throw UnimplementedError();
  }

  @override
  int get hashCode => throw UnimplementedError();
}
