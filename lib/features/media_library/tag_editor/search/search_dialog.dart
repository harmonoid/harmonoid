import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/features/media_library/tag_editor/search/api/track_search.dart';
import 'package:harmonoid/features/media_library/tag_editor/search/models/track_search_result.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/utils/debouncer.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  static final double? _kDialogWidth = isDesktop ? kDesktopCenteredLayoutWidth : null;
  static const double _kSearchBarHeight = 48.0 + 1.0;
  static final double _kListItemHeight = linearTileHeight;
  static final int _kListItemCountDelta = isDesktop ? 1 : 0;

  final Debouncer _debouncer = Debouncer(timeout: const Duration(milliseconds: 300));
  final TrackSearch _trackSearch = TrackSearch();
  List<TrackSearchResult>? _results = [];

  void _onChanged(String value) async {
    _debouncer.run(() async {
      if (value.isEmpty) {
        setState(() => _results = []);
        return;
      }

      setState(() => _results = null);
      try {
        final results = await _trackSearch(value, limit: 3);
        setState(() => _results = results);
      } catch (exception, stacktrace) {
        setState(() => _results = []);
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
      }
    });
  }

  void _onItemPressed(TrackSearchResult result) {
    context.pop(result);
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      child: SizedBox(
        width: _kDialogWidth,
        height: _kSearchBarHeight + (results != null && results.isNotEmpty ? (results.length + _kListItemCountDelta) * _kListItemHeight : 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextFormField(
              autofocus: true,
              onChanged: (value) => _onChanged(value.trim()),
              decoration: InputDecoration(
                hintText: Localization.instance.SEARCH,
                suffix: _results != null
                    ? null
                    : const SizedBox(
                        width: 12.0,
                        height: 12.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                // HACK:
                contentPadding: isMobile ? const EdgeInsets.symmetric(horizontal: 12.0) : null,
              ),
            ),
            if (results != null && results.isNotEmpty) ...[
              const Divider(height: 1.0, thickness: 1.0),
              SizedBox(
                height: (results.length + _kListItemCountDelta) * _kListItemHeight,
                child: ListItemTable(
                  columns: [Localization.instance.TITLE, Localization.instance.ARTISTS],
                  itemCount: results.length,
                  itemBuilder: (context, i) => ListItemData(
                    key: ValueKey(i.toString()),
                    children: [
                      TappableText(text: [TappableTextData(text: results[i].title)]),
                      TappableText(text: [TappableTextData(text: results[i].artist)]),
                    ],
                  ),
                  leadingBuilder: (context, i) => Image.network(
                    results[i].cover,
                    width: _kListItemHeight,
                    height: _kListItemHeight,
                    cacheWidth: _kListItemHeight.toInt() * 2,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                  onItemPressed: (context, i) => _onItemPressed(results[i]),
                  physics: const NeverScrollableScrollPhysics(),
                  mobileSliverList: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
