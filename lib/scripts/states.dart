import 'package:flutter/material.dart';

typedef RefreshCollectionMusic = void Function();
typedef RefreshCollectionSearch = void Function();
typedef RefreshThemeMode = void Function(ThemeMode themeMode);


abstract class States {

  static RefreshCollectionMusic refreshCollectionMusic;

  static RefreshCollectionSearch refreshCollectionSearch;

}
