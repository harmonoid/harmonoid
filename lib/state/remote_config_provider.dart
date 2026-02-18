import 'package:flutter/foundation.dart';

import 'package:harmonoid/api/remote_config_get.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/configuration/database/constants.dart';
import 'package:harmonoid/models/remote_config_key.dart';
import 'package:harmonoid/models/remote_config_value.dart';

class RemoteConfigProvider {
  static const String kStoragePrefix = '_REMOTE_CONFIG_';

  Future<RemoteConfigValue?> get(RemoteConfigKey key) async {
    RemoteConfigValue? result;

    try {
      result = await getCached(key);
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    try {
      result = await setCached(key, await _remoteConfigGet.call(key));
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    return result;
  }

  Future<RemoteConfigValue?> getCached(RemoteConfigKey key) async {
    final value = await Configuration.instance.db.getJson(_transformKey(key));
    if (value == null) return null;
    return RemoteConfigValue.fromJson(value);
  }

  Future<RemoteConfigValue?> setCached(RemoteConfigKey key, RemoteConfigValue? value) async {
    if (value == null) return null;
    await Configuration.instance.db.setValue(_transformKey(key), kTypeJson, jsonValue: _transformValue(key, value));
    return value;
  }

  String _transformKey(RemoteConfigKey key) => '$kStoragePrefix${key.key}';

  Map<String, dynamic> _transformValue(RemoteConfigKey key, RemoteConfigValue value) => {'runtimeType': key.name, ...value.toJson()};

  final RemoteConfigGet _remoteConfigGet = RemoteConfigGet();
}
