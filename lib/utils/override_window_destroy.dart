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

import 'package:flutter/services.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/core/collection.dart';

/// OverrideWindowDestroy
/// ---------------------
///
/// Overrides the `delete-event` signal of Flutter's GTK window on Linux.
/// A constantly running instance of `libmpv` caused `Segmentation Fault` upon close.
///
/// Calling [OverrideWindowDestroy.initialize] ensures that [Playback.instance.player]
/// is disposed & then window is destroyed.
///
abstract class OverrideWindowDestroy {
  static void initialize() async {
    const channel = const MethodChannel('override_window_destroy');
    channel.setMethodCallHandler((call) async {
      await Playback.player.dispose();
      await tagger.dispose();
      channel.invokeMethod('destroy_window');
    });
  }
}
