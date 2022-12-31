import 'package:flutter/material.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:external_media_provider/external_media_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/configuration.dart';

import 'package:harmonoid/web/state/parser.dart';

class Web {
  static final Web instance = Web();

  final PagingController<int, Track> pagingController =
      PagingController<int, Track>(firstPageKey: 0);

  Future<void> open(dynamic value, {int index = 0}) async {
    // WARNING: Gibberish code ahead.
    bool reload = Configuration.instance.webRecent.isEmpty;
    if (value is Track) {
      final id = ExternalMedia.redirect(value.uri).queryParameters['id']!;
      Playback.instance.open([Parser.track(value)]);
      await Configuration.instance.save(webRecent: [id]);
      final next = await YTMClient.next(id);
      Playback.instance.add(next.sublist(1).map(Parser.track).toList());
    } else if (value is Video) {
      final id = ExternalMedia.redirect(value.uri).queryParameters['id']!;
      Playback.instance.open([Parser.video(value)]);
      await Configuration.instance.save(webRecent: [id]);
      final next = await YTMClient.next(id);
      Playback.instance.add(next.sublist(1).map(Parser.track).toList());
    } else if (value is List<Track>) {
      final id = ExternalMedia.redirect(value.first.uri).queryParameters['id']!;
      Playback.instance.open(value.map(Parser.track).toList(), index: index);
      await Configuration.instance.save(webRecent: [id]);
    }
    if (reload) {
      pagingController.refresh();
      refreshCallback?.call();
    }
  }

  VoidCallback? refreshCallback;
}
