/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///

import 'dart:io';
import 'package:path/path.dart' as path;

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
