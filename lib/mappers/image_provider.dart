import 'package:flutter/rendering.dart';
import 'package:harmonoid/utils/async_file_image.dart';

/// Mappers for [ImageProvider].
extension ImageProviderMappers on ImageProvider {
  /// Converts to underlying resource.
  Future<dynamic> toResource() async {
    final instance = this;
    return switch (instance) {
      AsyncFileImage() => await instance.file,
      FileImage() => instance.file,
      NetworkImage() => instance.url,
      _ => null,
    };
  }

  /// Converts to [Uri].
  Future<Uri?> toUri() async {
    final instance = this;
    return switch (instance) {
      AsyncFileImage() => (await instance.file)?.uri,
      FileImage() => instance.file.uri,
      NetworkImage() => Uri.parse(instance.url),
      _ => null,
    };
  }
}
