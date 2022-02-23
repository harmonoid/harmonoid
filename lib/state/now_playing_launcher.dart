/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
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
