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
import 'package:flutter/widgets.dart';

class NowPlayingLauncher extends ChangeNotifier {
  static late NowPlayingLauncher instance;

  final VoidCallback launch;
  final VoidCallback exit;

  NowPlayingLauncher({
    required this.launch,
    required this.exit,
  }) {
    NowPlayingLauncher.instance = this;
  }

  void toggle() => maximized = !maximized;

  bool get maximized => _maximized;

  set maximized(bool value) {
    if (value == _maximized) return;
    if (value) {
      launch();
    } else {
      exit();
    }
    _maximized = value;
    notifyListeners();
  }

  bool _maximized = false;
}
