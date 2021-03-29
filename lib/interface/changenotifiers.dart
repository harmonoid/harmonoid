import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/methods.dart';


class Server extends ChangeNotifier {
  String? homeAddress;
  
  Server({required String? homeAddress});

  void update({required String? homeAddress}) {
    this.homeAddress = homeAddress;
    this.notifyListeners();
    configuration.save(homeAddress: homeAddress);
  }
}


class Visuals extends ChangeNotifier {
  Accent? accent;
  ThemeMode? themeMode;
  TargetPlatform? platform;

  Visuals({required this.accent, required this.themeMode, required this.platform});

  void update({Accent? accent, ThemeMode? themeMode, TargetPlatform? platform}) {
    this.accent = accent ?? this.accent;
    this.themeMode = themeMode ?? this.themeMode;
    this.platform = platform ?? this.platform;
    this.notifyListeners();
    configuration.save(
      accent: this.accent,
      themeMode: this.themeMode,
      platform: this.platform,
    );
  }

  ThemeData get theme => Methods.getTheme(
    accentColor: this.accent!.light,
    themeMode: ThemeMode.light,
    platform: this.platform,
  );

  ThemeData get darkTheme => Methods.getTheme(
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
  new Accent(light: Color(0xFF6200EA), dark: Color(0xFFB388FF)),
  new Accent(light: Color(0xFF4285F4), dark: Color(0xFF82B1FF)),
  new Accent(light: Color(0xFFDB4437), dark: Color(0xFFFF8A80)),
  new Accent(light: Color(0xFFF4B400), dark: Color(0xFFFFE57F)),
  new Accent(light: Color(0xFF0F9D58), dark: Color(0xFF0F9D58)),
  new Accent(light: Color(0xFFFF3D00), dark: Color(0xFFFF9E80)),
  new Accent(light: Color(0xFF1DB954), dark: Color(0xFF1DB954)),
  new Accent(light: Color(0xFF5B51D8), dark: Color(0xFFD1C4E9)),
  new Accent(light: Color(0xFFF50057), dark: Color(0xFFFF80AB)),
  new Accent(light: Color(0xFF424242), dark: Color(0xFFE0E0E0)),
];