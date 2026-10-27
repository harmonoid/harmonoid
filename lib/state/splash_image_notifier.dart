import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/state/remote_config/models/remote_config_key.dart';
import 'package:harmonoid/state/remote_config/models/remote_config_value.dart';
import 'package:harmonoid/state/remote_config/models/splash_image.dart';
import 'package:harmonoid/state/remote_config/remote_config_provider.dart';

class SplashImageNotifier extends ChangeNotifier {
  static final SplashImageNotifier instance = SplashImageNotifier._();

  SplashImageNotifier._();

  SplashImage? config;

  File? file;

  bool get hasImage => config != null && file != null;

  Future<void> load() async {
    try {
      if (!await _waitForConfiguration()) return;
      final cached = await RemoteConfigProvider().getCached(RemoteConfigKey.splashImage);
      if (cached is! SplashImageValue) return;
      final value = cached.value;
      if (value == null) return;
      final target = _fileForUrl(value.url);
      if (target == null || !await target.exists_() || await target.length_() == 0) return;
      if (config == value && file == target) return;
      config = value;
      file = target;
      notifyListeners();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> refresh() async {
    try {
      final response = await RemoteConfigProvider().get(RemoteConfigKey.splashImage);
      if (response is! SplashImageValue) return;
      final value = response.value;
      if (value == null) return;
      final target = _fileForUrl(value.url);
      if (target == null) return;
      if (await target.exists_() && await target.length_() > 0) return;
      final result = await http.get(Uri.parse(value.url));
      if (result.statusCode != 200 || result.bodyBytes.isEmpty) return;
      await _directory.create_();
      await target.write_(result.bodyBytes);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<bool> _waitForConfiguration() async {
    int attempts = 0;
    while (attempts < 300) {
      try {
        Configuration.instance.directory;
        return true;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    return false;
  }

  File? _fileForUrl(String url) {
    try {
      final name = url.split('/').last.split('?').first.split('#').first;
      if (name.isEmpty) return null;
      return File(join(_directory.path, name));
    } catch (_) {
      return null;
    }
  }

  Directory get _directory => Directory(join(Configuration.instance.directory.path, 'Splash', 'Image'));
}
