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
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'package:hotkey_manager/hotkey_manager.dart';

import 'package:harmonoid/core/playback.dart';

/// HotKeys
/// -------
///
/// Hotkey & keyboard shortcuts inside [Harmonoid](https://github.com/harmonoid/harmonoid).
///
class HotKeys {
  /// [HotKeys] object instance. Must call [HotKeys.initialize].
  static late HotKeys instance = HotKeys();

  static Future<void> initialize() async {
    await Future.wait(
      [
        HotKeyManager.instance.register(
          _spaceHotkey,
          keyDownHandler: (_) => Playback.instance.playOrPause(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyN,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.instance.next(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyB,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.instance.previous(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyM,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) => Playback.instance.toggleMute(),
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyC,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) {
            if (Playback.instance.volume <= 0) return;
            Playback.instance.setVolume(
              Playback.instance.volume - 0.02,
            );
          },
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyV,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) {
            if (Playback.instance.volume >= 100.0) return;
            Playback.instance.setVolume(
              Playback.instance.volume + 0.02,
            );
          },
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyZ,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) {
            if (Playback.instance.position >= Playback.instance.duration)
              return;
            Playback.instance.seek(
              Playback.instance.position - Duration(seconds: 10),
            );
          },
        ),
        HotKeyManager.instance.register(
          HotKey(
            KeyCode.keyX,
            modifiers: [KeyModifier.alt],
            scope: HotKeyScope.inapp,
          ),
          keyDownHandler: (_) {
            if (Playback.instance.position <= Duration.zero) return;
            Playback.instance.seek(
              Playback.instance.position + Duration(seconds: 10),
            );
          },
        ),
      ],
    );
  }

  Future<void> disableSpaceHotKey() async {
    await HotKeyManager.instance.unregister(_spaceHotkey);
  }

  Future<void> enableSpaceHotKey() async {
    await HotKeyManager.instance.register(
      _spaceHotkey,
      keyDownHandler: (_) => Playback.instance.playOrPause(),
    );
  }
}

final _spaceHotkey = HotKey(
  KeyCode.space,
  scope: HotKeyScope.inapp,
);
