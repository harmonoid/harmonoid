import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/models/playable.dart';
import 'package:harmonoid/core/media_player/base_media_player.dart';

/// {@template stub_mixin}
///
/// StubMixin
/// ---------
/// Stub (for reference) mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin StubMixin implements BaseMediaPlayer {
  static bool get supported => true;

  Future<void> ensureInitializedStub() async {
    if (!supported) return;

    const instance = null;

    _instanceStub = instance;

    addListener(_listenerStub);
  }

  Future<void> disposeStub() async {
    if (!supported) return;
    _instanceStub = null;
  }

  void resetFlagsStub() {
    _flagPlayableStub = null;
  }

  void _listenerStub() {
    _lockStub.synchronized(() async {
      if (_flagPlayableStub != current) {
        _flagPlayableStub = current;
        debugPrint(_instanceStub.toString());
      }
    });
  }

  Null _instanceStub;
  final Lock _lockStub = Lock();

  Playable? _flagPlayableStub;
}
