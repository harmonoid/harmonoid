import 'package:media_library/media_library.dart';

/// Mappers for [MediaLibraryItem].
extension MediaLibraryItemMappers on MediaLibraryItem {
  /// Converts to [AsyncFileImage] key.
  String toImageKey() => '$runtimeType-$hashCode';
}
