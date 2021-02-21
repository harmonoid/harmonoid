import 'package:harmonoid/scripts/collection.dart';

typedef RefreshCollectionMusic = void Function();
typedef RefreshCollectionSearch = void Function();
typedef RefreshThemeData = void Function();
typedef SetAccentColor = Future Function(Track accentColor);


abstract class States {

  static RefreshCollectionMusic refreshCollectionMusic;

  static RefreshCollectionSearch refreshCollectionSearch;

  static RefreshThemeData refreshThemeData;

  static SetAccentColor setAccentColor;
}
