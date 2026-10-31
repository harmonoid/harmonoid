import 'package:flutter/widgets.dart';

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier({
    this.highlightMediaLibraryAddFolder = false,
    this.highlightLyricsSection = false,
  });

  final bool highlightMediaLibraryAddFolder;
  final bool highlightLyricsSection;
}
