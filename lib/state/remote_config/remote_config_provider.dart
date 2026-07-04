import 'package:flutter/foundation.dart';

import 'package:harmonoid/state/remote_config/api/remote_config_get.dart';
import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/configuration/database/constants.dart';
import 'package:harmonoid/state/remote_config/models/remote_config_key.dart';
import 'package:harmonoid/state/remote_config/models/remote_config_value.dart';

class RemoteConfigProvider {
  static const String kStoragePrefix = '_REMOTE_CONFIG_';

  Future<RemoteConfigValue?> get(RemoteConfigKey key) async {
    RemoteConfigValue? result;

    try {
      final local = await getCached(key);
      if (local != null) {
        result = local;
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }

    try {
      final remote = await _remoteConfigGet.call(key);
      if (remote != null) {
        await setCached(key, remote);
        result = remote;
      }
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

  Future<void> setCached(RemoteConfigKey key, RemoteConfigValue value) async {
    await Configuration.instance.db.setValue(_transformKey(key), kTypeJson, jsonValue: _transformValue(key, value));
  }

  String _transformKey(RemoteConfigKey key) => '$kStoragePrefix${key.key}';

  Map<String, dynamic> _transformValue(RemoteConfigKey key, RemoteConfigValue value) => {'runtimeType': key.name, ...value.toJson()};

  final RemoteConfigGet _remoteConfigGet = RemoteConfigGet();
}
