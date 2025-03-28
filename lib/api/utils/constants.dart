import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/extensions/string.dart';

String get apiBaseUrl => Configuration.instance.apiBaseUrl.nullIfBlank() ?? const String.fromEnvironment('API_BASE_URL');
String get apiKey => Configuration.instance.apiBaseUrl.nullIfBlank() ?? const String.fromEnvironment('API_KEY');
