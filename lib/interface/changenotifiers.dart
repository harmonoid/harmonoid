import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:harmonoid/constants/language.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/youtubemusic.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/utils.dart';

var nowPlaying = NowPlayingController();
var nowPlayingBar = NowPlayingBarController();

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

  double volumeBeforeMute = 1.0;

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
}

class NowPlayingBarController extends ChangeNotifier {
  double _height = 0.0;

  double get height {
    return this._height;
  }

  set height(double value) {
    this._height = value;
    this.notifyListeners();
  }
}

class CollectionRefreshController extends ChangeNotifier {
  int progress = 0;
  int total = 0;

  void setProgress(int progress) {
    this.progress = progress;
    this.notifyListeners();
  }

  void setTotal(int total) {
    this.total = total;
    this.notifyListeners();
  }

  void set(int progress, int total) {
    this.progress = progress;
    this.total = total;
    this.notifyListeners();
  }
}

class Visuals extends ChangeNotifier {
  Accent? accent;
  ThemeMode? themeMode;

  Visuals({required this.accent, required this.themeMode});

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
            ? Colors.white70
            : Color(0xCC222222),
      );
    }
    if (Platform.isAndroid || Platform.isIOS && context != null) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context!).brightness,
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
  Accent(light: Color(0xFFFF0000), dark: Color(0xFFFF0000)),
  Accent(light: Color(0xFF4285F4), dark: Color(0xFF82B1FF)),
  Accent(light: Color(0xFFF4B400), dark: Color(0xFFFFE57F)),
  Accent(light: Color(0xFF0F9D58), dark: Color(0xFF0F9D58)),
  Accent(light: Color(0xFFFF3D00), dark: Color(0xFFFF9E80)),
  Accent(light: Color(0xFF1DB954), dark: Color(0xFF1DB954)),
  Accent(light: Color(0xFF5B51D8), dark: Color(0xFFD1C4E9)),
  Accent(light: Color(0xFFF50057), dark: Color(0xFFFF80AB)),
  Accent(light: Color(0xFF424242), dark: Colors.grey.shade600),
];
