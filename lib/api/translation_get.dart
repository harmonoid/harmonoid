import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/api/utils/constants.dart';

/// {@template translation_get}
///
/// TranslationGet
/// ---------------
///
/// {@endtemplate}
class TranslationGet {
  Future<List<String>?> call(String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'translation-get',
        method: HttpMethod.post,
        body: json.encode({
          'text': text,
          // TODO: Missing implementation.
          'to': 'en',
        }),
        headers: {'X-API-Key': apiKey},
      );
      if (response.status != 200) return null;
      final body = response.data;
      final bodySame = body?['same'] as bool?;
      final bodyText = body?['text'] as String?;
      if (bodySame == true || bodyText == null) return null;
      return bodyText.split('\n').map((e) => e.trim()).toList();
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return null;
  }
}
