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

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/youtubemusic.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/utils.dart';
import 'package:harmonoid/constants/language.dart';

var nowPlaying = NowPlayingController();
var nowPlayingBar = NowPlayingBarController();
var collectionRefresh = CollectionRefreshController();

class NowPlayingController extends ChangeNotifier {
  int? get index => _index;
  List<Track> get tracks => _tracks;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get isCompleted => _isCompleted;
  double get volume => _volume;
  double get rate => _rate;
  Duration get position => _position;
  Duration get duration => _duration;
  String get state => _state;
  bool get isShuffling => _isShuffling;
  bool get isRepeating => _isRepeating;

  set index(int? index) {
    this._index = index;
    this.notifyListeners();
  }

  set tracks(List<Track> tracks) {
    this._tracks = tracks;
    this.notifyListeners();
  }

  set isPlaying(bool isPlaying) {
    this._isPlaying = isPlaying;
    this.notifyListeners();
  }

  set isBuffering(bool isBuffering) {
    this._isBuffering = isBuffering;
    if (!this._isBuffering) this._state = language!.STRING_BUFFERING;
    this.notifyListeners();
  }

  set isCompleted(bool isCompleted) {
    this._isCompleted = isCompleted;
    this.notifyListeners();
  }

  set volume(double volume) {
    this._volume = volume;
    this.notifyListeners();
  }

  set rate(double rate) {
    this._rate = rate;
    this.notifyListeners();
  }

  set position(Duration position) {
    this._position = position;
    this.notifyListeners();
  }

  set duration(Duration duration) {
    this._duration = duration;
    this.notifyListeners();
  }

  set state(String state) {
    this._state = state;
    this.notifyListeners();
  }

  set isShuffling(bool isShuffling) {
    this._isShuffling = isShuffling;
    this.notifyListeners();
  }

  set isRepeating(bool isRepeating) {
    this._isRepeating = isRepeating;
    this.notifyListeners();
  }

  int? _index;
  List<Track> _tracks = <Track>[];
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isCompleted = false;
  double _volume = 1.0;
  double _rate = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _state = language!.STRING_BUFFERING;
  bool _isShuffling = false;
  bool _isRepeating = false;

  @override
  // ignore: must_call_super
  void dispose() {}
}

class NowPlayingBarController extends ChangeNotifier {
  double _height = 0.0;
  bool _maximized = false;

  double get height {
    return this._height;
  }

  set height(double value) {
    if (maximized) return;
    this._height = value;
    this.notifyListeners();
  }

  bool get maximized {
    return this._maximized;
  }

  set maximized(bool value) {
    if (value)
      this._height = 0.0;
    else
      this._height = 72.0;
    this._maximized = value;
    this.notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}

class CollectionRefreshController extends ChangeNotifier {
  int progress = 0;
  int total = 1;
  Timer? timer;

  void set(int progress, int total) {
    this.progress = progress;
    this.total = total;
    if (this.timer == null) {
      this.notifyListeners();
      collection.redraw();
      this.timer = Timer.periodic(
        Duration(seconds: 1),
        (_) {
          this.notifyListeners();
          collection.redraw();
        },
      );
    }
    if (this.progress == this.total) {
      this.notifyListeners();
      collection.redraw();
      this.timer?.cancel();
      this.timer = null;
    }
  }

  @override
  // ignore: must_call_super
  void dispose() {}
}

class Visuals extends ChangeNotifier {
  Accent? accent;
  ThemeMode? themeMode;
  BuildContext? context;

  Visuals(
      {required this.accent, required this.themeMode, required this.context});

  void update(
      {Accent? accent,
      ThemeMode? themeMode,
      TargetPlatform? platform,
      BuildContext? context}) {
    this.accent = accent ?? this.accent;
    this.themeMode = themeMode ?? this.themeMode;
    if (Platform.isWindows) {
      Acrylic.setEffect(
        effect: configuration.acrylicEnabled!
            ? AcrylicEffect.acrylic
            : AcrylicEffect.disabled,
        gradientColor: this.themeMode == ThemeMode.light
            ? Color(0x22DDDDDD)
            : Color(0xCC222222),
      );
    }
    if ((Platform.isAndroid || Platform.isIOS) && context != null) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white54
              : Colors.black38,
          statusBarBrightness: Theme.of(context).brightness,
          statusBarIconBrightness: Theme.of(context).brightness,
        ),
      );
    }
    this.notifyListeners();
    configuration.save(
      accent: this.accent,
      themeMode: this.themeMode,
    );
  }

  void updateAppBar(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black38
            : Colors.white54,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  ThemeData get theme => Utils.getTheme(
        accentColor: this.accent!.light,
        themeMode: ThemeMode.light,
      );

  ThemeData get darkTheme => Utils.getTheme(
        accentColor: this.accent!.dark,
        themeMode: ThemeMode.dark,
      );
}

class YouTubeStateController extends ChangeNotifier {
  List<Track> recommendations = <Track>[];
  String? recommendation;
  bool exception = false;
  Future<void> updateRecommendations(Track track) async {
    this.recommendation = track.trackId!;
    try {
      this.recommendations = await track.recommendations;
      // TODO (alexmercerind): Sometimes recommendations are not fetched & we're stuck so retrying is the best option for now. Improve in future.
      if (this.recommendations.length == 1) {
        this.recommendations = await track.recommendations;
      }
      configuration.save(
        discoverRecent: [
          track.trackId!,
        ],
      );
      this.exception = false;
    } catch (exception) {
      this.exception = true;
    }
    this.notifyListeners();
  }
}

final FlutterLocalNotificationsPlugin notification =
    FlutterLocalNotificationsPlugin();
final InitializationSettings notificationSettings = InitializationSettings(
  android: AndroidInitializationSettings('mipmap/ic_launcher'),
);

class NotificationLyricsController extends ChangeNotifier {
  late bool enabled;

  NotificationLyricsController({required this.enabled});

  void update({required bool enabled}) {
    this.enabled = enabled;
    this.notifyListeners();
    configuration.save(notificationLyrics: enabled);
  }
}

class Accent {
  final Color light;
  final Color dark;

  Accent({required this.light, required this.dark});
}

List<Accent?> accents = [
  Accent(
    light: Colors.deepPurpleAccent.shade400,
    dark: Colors.deepPurpleAccent.shade200,
  ),
  Accent(light: Color(0xFFE53935), dark: Color(0xFFE53935)),
  Accent(light: Color(0xFF4285F4), dark: Color(0xFF82B1FF)),
  Accent(light: Color(0xFFF4B400), dark: Color(0xFFFFE57F)),
  Accent(light: Color(0xFF0F9D58), dark: Color(0xFF0F9D58)),
  Accent(light: Color(0xFFFF3D00), dark: Color(0xFFFF9E80)),
  Accent(light: Color(0xFF1DB954), dark: Color(0xFF1DB954)),
  Accent(light: Color(0xFF5B51D8), dark: Color(0xFFD1C4E9)),
  Accent(light: Color(0xFFF50057), dark: Color(0xFFFF80AB)),
  Accent(light: Color(0xFF424242), dark: Colors.grey.shade600),
];
