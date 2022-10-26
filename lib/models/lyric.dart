/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

class Lyric {
  final int time;
  final String words;

  Lyric({
    required this.time,
    required this.words,
  });

  Map<String, dynamic> toJson() => {
        'time': this.time,
        'words': this.words,
      };

  static Lyric fromJson(dynamic map) => Lyric(
        time: map['time'],
        words: map['words']?.replaceAll('\n', ' ')?.replaceAll('  ', ' '),
      );
}
