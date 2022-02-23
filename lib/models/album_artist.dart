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

part of 'media.dart';

/// Used for ordering album artists correctly in [SplayTreeMap].
/// Wraps [String] such that uppercase & lowercase album artist
/// name strings are sorted regardless of their case.
class AlbumArtist extends Comparable<AlbumArtist> {
  final String name;

  AlbumArtist(this.name);

  @override
  operator ==(Object other) {
    if (other is AlbumArtist) {
      return name.toLowerCase() == other.name.toLowerCase();
    }
    // Why would one ever...
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  int compareTo(AlbumArtist other) {
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }
}
