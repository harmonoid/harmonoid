/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:harmonoid/core/collection.dart';

/// CollectionRefresh
/// -----------------
///
/// This [ChangeNotifier] acts as a listener to [Collection] when [Collection.index] or [Collection.refresh] is called.
/// It calls [ChangeNotifier.notifyListeners] periodically while music is being indexed, whose interval time is given by
/// [kCollectionRedrawRefractoryPeriod]. Thus, it avoids re-building UI unnecessarily very quickly.
///
/// Thus it results in following advantages than listening to [Collection] directly at the time of refreshing or indexing:
/// * It keeps music [Collection] usable for the user even when it is being indexed.
/// * Indexing music & calling [ChangeNotifier.notifyListeners] in [Collection] over every iteration causes too many UI rebuilds
///   which ultimately causes [Collection] to be not visible at all to the user until it is completely indexed.
/// * It allows to show the indexing progress wherever needed in the UI.
///
class CollectionRefresh extends ChangeNotifier {
  /// [CollectionRefresh] object instance.
  static late CollectionRefresh instance = CollectionRefresh();

  int? progress = 1;
  int total = 1;

  bool get isCompleted => progress == total;

  void set(int? progress, int total) {
    this.progress = progress;
    this.total = total;
    if (_timer == null) {
      notifyListeners();
      Collection.instance.redraw();
      _timer = Timer.periodic(
        kCollectionRedrawRefractoryPeriod,
        (_) {
          notifyListeners();
          Collection.instance.redraw();
        },
      );
    }
    if (progress == total) {
      notifyListeners();
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  // ignore: must_call_super
  void dispose() {}

  Timer? _timer;
}

/// Amount of time after which [Collection] should be redrawn if it is being indexed or refreshed.
const kCollectionRedrawRefractoryPeriod = Duration(seconds: 2);
