/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'package:hotkey_manager/hotkey_manager.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/interface/changenotifiers.dart';

/// HotKeys
/// -------
///
/// Hotkey mappings.
///
class HotKeys {
  static Future<void> initialize() async {
    await Future.wait(
      [
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.space,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.playOrPause(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyN,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.next(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyB,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.back(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyM,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.toggleMute(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyC,
            modifiers: [KeyModifier.alt],
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
            modifiers: [KeyModifier.alt],
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
            modifiers: [KeyModifier.alt],
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
            modifiers: [KeyModifier.alt],
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
