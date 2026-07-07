import 'package:flutter/widgets.dart';

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier({this.highlightMediaLibraryAddFolder = false});

  final bool highlightMediaLibraryAddFolder;
}
