import 'package:flutter/widgets.dart';
import 'package:harmonoid/core/playback.dart';
import 'package:libmpv/libmpv.dart';

import 'package:harmonoid/models/media.dart';
import 'package:harmonoid/core/configuration.dart';

import 'package:harmonoid/youtube/youtube_api.dart';

class YouTube extends ChangeNotifier {
  static final instance = YouTube();

  String current = '';
  bool exception = false;
  List<Track>? recommendations;

  Future<void> fetchRecommendations() async {
    if (Configuration.instance.discoverRecent.isEmpty) return;
    if (current == Configuration.instance.discoverRecent.first) return;
    exception = false;
    notifyListeners();
    if (Configuration.instance.discoverRecent.isNotEmpty) {
      try {
        recommendations = await YoutubeApi.getRecommendations(
          Configuration.instance.discoverRecent.first,
        );
        if (recommendations!.length == 1) {
          await fetchRecommendations();
        }
        recommendations!.addAll(
          (await YoutubeApi.getRecommendations(
                  Plugins.redirect(recommendations!.last.uri)
                      .queryParameters['id']!))
              .skip(1),
        );
        current = Configuration.instance.discoverRecent.first;
        notifyListeners();
      } catch (_) {
        recommendations = [];
        exception = true;
        notifyListeners();
      }
    }
  }

  Future<void> open(Track track) async {
    Playback.instance.open(
      [track],
    );
    await Configuration.instance.save(
      discoverRecent: [Plugins.redirect(track.uri).queryParameters['id']!],
    );
    await fetchRecommendations();
    if (recommendations != null) {
      Playback.instance.add(recommendations!.sublist(1));
    }
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}
