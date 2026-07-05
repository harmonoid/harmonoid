import 'package:media_library/media_library.dart';

class SearchItemsPathExtra {
  final String query;
  final List<MediaLibraryItem> items;

  const SearchItemsPathExtra({
    required this.query,
    required this.items,
  });
}
