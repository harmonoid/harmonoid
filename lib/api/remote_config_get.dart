import 'package:flutter/foundation.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/api/utils/constants.dart';
import 'package:harmonoid/models/remote_config_key.dart';
import 'package:harmonoid/models/remote_config_value.dart';

/// {@template remote_config_get}
///
/// RemoteConfigGet
/// ---------------
///
/// {@endtemplate}
class RemoteConfigGet {
  Future<RemoteConfigValue?> call(RemoteConfigKey key) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'remote-config-get',
        method: HttpMethod.get,
        queryParameters: {'key': key.key},
        headers: {'X-API-Key': apiKey},
      );
      if (response.status != 200) return null;
      final body = response.data;
      return RemoteConfigValue.fromJson({'runtimeType': key.name, 'value': body});
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
