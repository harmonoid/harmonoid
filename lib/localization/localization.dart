import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:harmonoid/localization/localization_data.dart';

part 'localization.g.dart';
part 'values.g.dart';

/// {@template localization}
///
/// Localization
/// ------------
/// Implementation to get & set the current localization.
///
/// {@endtemplate}
class Localization extends LocalizationBase with ChangeNotifier {
  /// Singleton instance.
  static final Localization instance = Localization._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro localization}
  Localization._();

  /// Initializes the [instance].
  static Future<void> ensureInitialized({required LocalizationData localization}) async {
    if (initialized) return;
    initialized = true;
    await instance.set(value: localization);
  }

  /// Returns the available localizations.
  Future<Set<LocalizationData>> get values async {
    final data = await rootBundle.loadString('assets/localizations/index.json');
    return Set.from(json.decode(data).map((e) => LocalizationData.fromJson(e)));
  }

  /// Sets the current localization.
  @override
  Future<void> set({required LocalizationData value}) async {
    await super.set(value: value);
    notifyListeners();
  }
}
