/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/widgets.dart';
import 'package:libmpv/libmpv.dart';
import 'package:ytm_client/ytm_client.dart';

import 'package:harmonoid/models/media.dart' as media;
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';

// TODO: Remove this bull-shit.

class Web extends ChangeNotifier {
  static final instance = Web();

  String current = '';
  bool exception = false;
  List<Track>? recommendations;

  Future<void> next() async {
    if (Configuration.instance.webRecent.isEmpty) return;
    if (current == Configuration.instance.webRecent.first) return;
    exception = false;
    notifyListeners();
    if (Configuration.instance.webRecent.isNotEmpty) {
      try {
        recommendations = await YTMClient.next(
          Configuration.instance.webRecent.first,
        );
        if (recommendations!.length == 1) {
          await next();
        }
        recommendations!.addAll(
          (await YTMClient.next(Plugins.redirect(recommendations!.last.uri)
                  .queryParameters['id']!))
              .skip(1),
        );
        current = Configuration.instance.webRecent.first;
        notifyListeners();
      } catch (_) {
        recommendations = [];
        exception = true;
        notifyListeners();
      }
    }
  }

  /// Plays a [Track] or a [Video] automatically handling conversion to local model [media.Track].
  Future<void> open(
    value, {
    int index = 0,
  }) async {
    if (value is Track) {
      Playback.instance.open(
        [media.Track.fromWebTrack(value.toJson())],
      );
      await Configuration.instance.save(
        webRecent: [Plugins.redirect(value.uri).queryParameters['id']!],
      );
      await next();
      if (recommendations != null) {
        Playback.instance.add(
          recommendations!
              .sublist(1)
              .map((e) => media.Track.fromJson(e.toJson()))
              .toList(),
        );
      }
    } else if (value is Video) {
      Playback.instance.open(
        [media.Track.fromWebVideo(value.toJson())],
      );
      await Configuration.instance.save(
        webRecent: [Plugins.redirect(value.uri).queryParameters['id']!],
      );
      await next();
      if (recommendations != null) {
        Playback.instance.add(
          recommendations!
              .sublist(1)
              .map((e) => media.Track.fromJson(e.toJson()))
              .toList(),
        );
      }
    } else if (value is List<Track>) {
      Playback.instance.open(
        value.map((e) => media.Track.fromWebTrack(e.toJson())).toList(),
        index: index,
      );
    }
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}
