/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
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
