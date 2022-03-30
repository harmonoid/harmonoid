/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:libmpv/libmpv.dart';
import 'package:ytm_client/ytm_client.dart';

import 'package:harmonoid/models/media.dart' as media;
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';

abstract class Web {
  /// Plays:
  /// * [Track]
  /// * [Video]
  /// * [List] of [Track]s
  ///
  /// Automatically handling conversion to local model [media.Track].
  static Future<void> open(
    value, {
    int index = 0,
  }) async {
    if (value is Track) {
      final id = Plugins.redirect(value.uri).queryParameters['id']!;
      Playback.instance.open(
        [media.Track.fromWebTrack(value.toJson())],
      );
      await Configuration.instance.save(webRecent: [id]);
      Playback.instance.add(
        (await YTMClient.next(id))
            .sublist(1)
            .map((e) => media.Track.fromJson(e.toJson()))
            .toList(),
      );
    } else if (value is Video) {
      final id = Plugins.redirect(value.uri).queryParameters['id']!;
      Playback.instance.open(
        [media.Track.fromWebVideo(value.toJson())],
      );
      await Configuration.instance.save(
        webRecent: [Plugins.redirect(value.uri).queryParameters['id']!],
      );
      Playback.instance.add(
        (await YTMClient.next(id))
            .sublist(1)
            .map((e) => media.Track.fromJson(e.toJson()))
            .toList(),
      );
    } else if (value is List<Track>) {
      Playback.instance.open(
        value.map((e) => media.Track.fromWebTrack(e.toJson())).toList(),
        index: index,
      );
      await Configuration.instance.save(
        webRecent: [Plugins.redirect(value.first.uri).queryParameters['id']!],
      );
    }
  }
}
