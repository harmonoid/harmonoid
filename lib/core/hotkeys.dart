import 'package:hotkey_manager/hotkey_manager.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/interface/changenotifiers.dart';

class HotKeys {
  static Future<void> initialize() async {
    await Future.wait(
      [
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.space,
            modifiers: [KeyModifier.control],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.playOrPause(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyN,
            modifiers: [KeyModifier.control],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.next(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyB,
            modifiers: [KeyModifier.control],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.back(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyM,
            modifiers: [KeyModifier.control],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.toggleMute(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyC,
            modifiers: [KeyModifier.control],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) {
            if (nowPlaying.volume <= 0) return;
            nowPlaying.volume -= 0.02;
            Playback.setVolume(nowPlaying.volume);
          },
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyV,
            modifiers: [KeyModifier.control],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) {
            if (nowPlaying.volume >= 1.0) return;
            nowPlaying.volume += 0.02;
            Playback.setVolume(nowPlaying.volume);
          },
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyZ,
            modifiers: [KeyModifier.control],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) {
            if (nowPlaying.position >= nowPlaying.duration) return;
            nowPlaying.position -= Duration(seconds: 10);
            Playback.seek(nowPlaying.position);
          },
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyX,
            modifiers: [KeyModifier.control],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) {
            if (nowPlaying.position <= Duration.zero) return;
            nowPlaying.position += Duration(seconds: 10);
            Playback.seek(nowPlaying.position);
          },
        ),
      ],
    );
  }
}
