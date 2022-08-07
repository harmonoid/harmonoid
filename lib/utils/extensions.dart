/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Yehuda Kremer <yehudakremer@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'package:flutter/widgets.dart';
import 'package:libmpv/libmpv.dart';
import 'package:media_library/media_library.dart';

extension IterableExtension<T> on Iterable<T> {
  /// Return distinct array by comparing hash codes.
  Iterable<T> distinct() {
    var distinct = <T>[];
    this.forEach((element) {
      if (!distinct.contains(element)) distinct.add(element);
    });

    return distinct;
  }
}

extension StringExtension on String {
  /// Return modified string which results in prettified [TextOverflow.ellipsis] effect.
  get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();

  /// Return modified string with all illegal file system path characters removed.
  get safePath => replaceAll(RegExp(kArtworkFileNameRegex), '');
}

extension DurationExtension on Duration {
  /// Return [Duration] as typical formatted string.
  String get label {
    if (this > Duration(days: 1)) {
      final days = inDays.toString().padLeft(3, '0');
      final hours = (inHours - (inDays * 24)).toString().padLeft(2, '0');
      final minutes = (inMinutes - (inHours * 60)).toString().padLeft(2, '0');
      final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
      return '$days:$hours:$minutes:$seconds';
    } else if (this > Duration(hours: 1)) {
      final hours = inHours.toString().padLeft(2, '0');
      final minutes = (inMinutes - (inHours * 60)).toString().padLeft(2, '0');
      final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    } else {
      final minutes = inMinutes.toString().padLeft(2, '0');
      final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }
  }
}

extension DateTimeExtension on DateTime {
  /// Format [DateTime] as `DD-MM-YYYY`.
  String get label =>
      '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
}

extension TrackExtension on Track {
  /// Whether the [Track] actually has meaningful actual track artists from metadata tags.
  bool get hasNoAvailableArtists {
    if (trackArtistNames.isEmpty) {
      return true;
    }
    if (trackArtistNames.length == 1) {
      if (['', kUnknownArtist].contains(trackArtistNames.first)) {
        return true;
      }
    }
    return false;
  }
}
