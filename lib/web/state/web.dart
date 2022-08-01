/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'package:libmpv/libmpv.dart';
import 'package:flutter/material.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/models/media.dart' as media;

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
      final id = Plugins.redirect(value.uri).queryParameters['id']!;
      Playback.instance.open(
        [media.Track.fromWebTrack(value.toJson())],
      );
      bool reload = Configuration.instance.webRecent.isEmpty;
      await Configuration.instance.save(
        webRecent: [Plugins.redirect(value.uri).queryParameters['id']!],
      );
      if (reload) {
        debugPrint('Web.open: pagingController.refresh');
        pagingController.refresh();
        refreshCallback?.call();
      }
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
      bool reload = Configuration.instance.webRecent.isEmpty;
      await Configuration.instance.save(
        webRecent: [Plugins.redirect(value.uri).queryParameters['id']!],
      );
      if (reload) {
        debugPrint('Web.open: pagingController.refresh');
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
        value.map((e) => media.Track.fromWebTrack(e.toJson())).toList(),
        index: index,
      );
      bool reload = Configuration.instance.webRecent.isEmpty;
      await Configuration.instance.save(
        webRecent: [Plugins.redirect(value.first.uri).queryParameters['id']!],
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
