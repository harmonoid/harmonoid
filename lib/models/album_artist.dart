/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

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
