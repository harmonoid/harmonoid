import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/utils.dart';

CurrentlyPlaying currentlyPlaying = CurrentlyPlaying();

class CurrentlyPlaying extends ChangeNotifier {
  int? get index => _index;
  List<Track> get tracks => _tracks;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get isCompleted => _isCompleted;
  double get volume => _volume;
  double get rate => _rate;
  Duration get position => _position;
  Duration get duration => _duration;

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

  int? _index;
  List<Track> _tracks = <Track>[];
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isCompleted = false;
  double _volume = 1.0;
  double _rate = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
}

class Server extends ChangeNotifier {
  String? homeAddress;

  Server({required this.homeAddress});

  void update({required String? homeAddress}) {
    this.homeAddress = homeAddress;
    this.notifyListeners();
    configuration.save(homeAddress: homeAddress);
  }
}

class CollectionRefresh extends ChangeNotifier {
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
}

class NotificationLyrics extends ChangeNotifier {
  late bool enabled;

  NotificationLyrics({required this.enabled});

  void update({required bool enabled}) {
    this.enabled = enabled;
    this.notifyListeners();
    configuration.save(notificationLyrics: enabled);
  }
}

class Visuals extends ChangeNotifier {
  Accent? accent;
  ThemeMode? themeMode;
  TargetPlatform? platform;

  Visuals(
      {required this.accent, required this.themeMode, required this.platform});

  void update(
      {Accent? accent, ThemeMode? themeMode, TargetPlatform? platform}) {
    this.accent = accent ?? this.accent;
    this.themeMode = themeMode ?? this.themeMode;
    this.platform = platform ?? this.platform;
    if (Platform.isWindows || Platform.isLinux) {
      Acrylic.setEffect(
        effect: AcrylicEffect.acrylic,
        gradientColor: this.themeMode == ThemeMode.light
            ? Colors.white
            : Color(0xCC222222),
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
        platform: this.platform,
      );

  ThemeData get darkTheme => Utils.getTheme(
        accentColor: this.accent!.dark,
        themeMode: ThemeMode.dark,
        platform: this.platform,
      );
}

class Accent {
  final Color light;
  final Color dark;

  Accent({required this.light, required this.dark});
}

List<Accent?> accents = [
  Accent(
      light: Colors.deepPurpleAccent.shade700,
      dark: Colors.deepPurpleAccent.shade200),
  Accent(light: Color(0xFF4285F4), dark: Color(0xFF82B1FF)),
  Accent(light: Color(0xFFDB4437), dark: Color(0xFFFF8A80)),
  Accent(light: Color(0xFFF4B400), dark: Color(0xFFFFE57F)),
  Accent(light: Color(0xFF0F9D58), dark: Color(0xFF0F9D58)),
  Accent(light: Color(0xFFFF3D00), dark: Color(0xFFFF9E80)),
  Accent(light: Color(0xFF1DB954), dark: Color(0xFF1DB954)),
  Accent(light: Color(0xFF5B51D8), dark: Color(0xFFD1C4E9)),
  Accent(light: Color(0xFFF50057), dark: Color(0xFFFF80AB)),
  Accent(light: Color(0xFF424242), dark: Colors.grey.shade600),
];
