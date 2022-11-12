/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:flutter/material.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:media_engine/media_engine.dart';
import 'package:media_library/media_library.dart' as media;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:harmonoid/utils/helpers.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';

class Web {
  /// [Web] object instance.
  static final Web instance = Web();

  /// [PagingController] for infinitely scrolling recommendations.
  ///
  /// The reasons of this being here are:
  /// * Ability to share already fetched recommendations on other screens.
  /// * Ability to perform refresh once the user plays a [Track] or [Video]
  ///   for the first time to switch to recommendations page from the
  ///   "welcome page" dynamically. This is done from [open] method.
  final PagingController<int, Track> pagingController =
      PagingController<int, Track>(firstPageKey: 0);

  /// Starts playback of a [Track], [Video] or a [List] of [Track]s.
  /// Internally destructures the web specific models into local [media.Track].
  Future<void> open(
    value, {
    int index = 0,
  }) async {
    if (value is Track) {
      final id = LibmpvPluginUtils.redirect(value.uri).queryParameters['id']!;
      Playback.instance.open(
        [
          Helpers.parseWebTrack(value.toJson()),
        ],
      );
      bool reload = Configuration.instance.webRecent.isEmpty;
      await Configuration.instance.save(
        webRecent: [
          LibmpvPluginUtils.redirect(value.uri).queryParameters['id']!
        ],
      );
      if (reload) {
        pagingController.refresh();
        refreshCallback?.call();
      }
      final next = await YTMClient.next(id);
      Playback.instance.add(
        next.sublist(1).map((e) => media.Track.fromJson(e.toJson())).toList(),
      );
    } else if (value is Video) {
      final id = LibmpvPluginUtils.redirect(value.uri).queryParameters['id']!;
      Playback.instance.open(
        [
          Helpers.parseWebVideo(value.toJson()),
        ],
      );
      bool reload = Configuration.instance.webRecent.isEmpty;
      await Configuration.instance.save(
        webRecent: [
          LibmpvPluginUtils.redirect(value.uri).queryParameters['id']!
        ],
      );
      if (reload) {
        pagingController.refresh();
        refreshCallback?.call();
      }
      Playback.instance.add(
        (await YTMClient.next(id))
            .sublist(1)
            .map((e) => media.Track.fromJson(e.toJson()))
            .toList(),
      );
    } else if (value is List<Track>) {
      Playback.instance.open(
        value.map((e) => Helpers.parseWebTrack(e.toJson())).toList(),
        index: index,
      );
      bool reload = Configuration.instance.webRecent.isEmpty;
      await Configuration.instance.save(
        webRecent: [
          LibmpvPluginUtils.redirect(value.first.uri).queryParameters['id']!
        ],
      );
      if (reload) {
        debugPrint('Web.open: pagingController.refresh');
        pagingController.refresh();
        refreshCallback?.call();
      }
    }
  }

  VoidCallback? refreshCallback;
}
