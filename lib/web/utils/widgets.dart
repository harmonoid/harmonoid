import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:substring_highlight/substring_highlight.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/utils/rendering.dart';

import 'package:harmonoid/web/web.dart';
import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/web/state/parser.dart';

import 'package:harmonoid/constants/language.dart';

class WebSearchBar extends StatefulWidget {
  final String? query;
  WebSearchBar({
    Key? key,
    this.query,
  }) : super(key: key);

  @override
  State<WebSearchBar> createState() => _WebSearchBarState();
}

class _WebSearchBarState extends State<WebSearchBar> {
  List<String> _suggestions = <String>[];
  int _highlightedSuggestionIndex = -1;
  late TextEditingController _searchBarController;

  Future<void> searchOrPlay(String value) async {
    if (value.isEmpty) return;
    final track = await YTMClient.player(value);
    if (track != null) {
      Web.instance.open(track);
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration:
              Theme.of(context).extension<AnimationDuration>()?.medium ??
                  Duration.zero,
          reverseTransitionDuration:
              Theme.of(context).extension<AnimationDuration>()?.medium ??
                  Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: WebSearch(
              query: value,
              future: YTMClient.search(value),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue:
          widget.query != null ? TextEditingValue(text: widget.query!) : null,
      optionsBuilder: (value) => value.text.isEmpty ? [] : _suggestions,
      optionsViewBuilder: (context, callback, _) => Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
              height: 4 * 32.0,
              width: 280.0,
              child: Material(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.0),
                  bottomRight: Radius.circular(4.0),
                ),
                elevation: 2.0,
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = _suggestions.elementAt(index);
                    return InkWell(
                      onTap: () {
                        callback(option);
                        searchOrPlay(option);
                      },
                      child: Container(
                        color: _highlightedSuggestionIndex == index
                            ? Theme.of(context).focusColor
                            : null,
                        height: 32.0,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 10.0),
                        child: SubstringHighlight(
                          text: option,
                          term: _searchBarController.text,
                          textStyle: Theme.of(context).textTheme.bodyLarge ??
                              TextStyle(),
                          textStyleHighlight: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      fieldViewBuilder: (context, controller, node, callback) {
        _searchBarController = controller;
        return Focus(
          onKey: (node, event) {
            var isArrowDownPressed =
                event.isKeyPressed(LogicalKeyboardKey.arrowDown);

            if (isArrowDownPressed ||
                event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
              _updateHighlightSuggestionIndex(isArrowDownPressed
                  ? _highlightedSuggestionIndex + 1
                  : _highlightedSuggestionIndex - 1);
              _updateSearchFieldWithHighlightSuggestion(controller);
            }

            return KeyEventResult.ignored;
          },
          child: Container(
            height: 40.0,
            width: 298.0,
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: 0.0,
              bottom: 0.0,
            ),
            padding: EdgeInsets.only(top: 2.0),
            child: Focus(
              child: CustomTextField(
                autofocus: true,
                cursorWidth: 1.0,
                focusNode: node,
                controller: controller,
                onChanged: (value) async {
                  value = value.trim();
                  setState(() {
                    _highlightedSuggestionIndex = -1;
                  });
                  _suggestions = value.isEmpty
                      ? []
                      : await YTMClient.music_get_search_suggestions(value);
                  setState(() {});
                },
                onSubmitted: (query) {
                  searchOrPlay(query);
                },
                textAlignVertical: TextAlignVertical.center,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: inputDecoration(
                  context,
                  Language.instance.COLLECTION_SEARCH_WELCOME,
                  trailingIcon: Transform.rotate(
                    angle: pi / 2,
                    child: Tooltip(
                      message: Language.instance.SEARCH,
                      child: Icon(
                        Icons.search,
                        size: 20.0,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  trailingIconOnPressed: () {
                    if (controller.text.isNotEmpty) {
                      searchOrPlay(controller.text);
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateHighlightSuggestionIndex(int newIndex) {
    if (newIndex < -1) newIndex++;
    setState(() {
      _highlightedSuggestionIndex =
          _suggestions.isEmpty ? -1 : newIndex % _suggestions.length;
    });
  }

  void _updateSearchFieldWithHighlightSuggestion(
      TextEditingController controller) {
    controller.text = _suggestions.elementAt(_highlightedSuggestionIndex);
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
  }
}

class PlaylistImportDialog extends StatefulWidget {
  const PlaylistImportDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<PlaylistImportDialog> createState() => _PlaylistImportDialogState();
}

class _PlaylistImportDialogState extends State<PlaylistImportDialog> {
  final TextEditingController _controller = TextEditingController();
  Playlist? playlist;
  bool fetched = false;
  bool saved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void add() async {
    if (_controller.text.isNotEmpty) {
      try {
        playlist = Playlist.fromRawURL(_controller.text);
        setState(() {});
        try {
          while (playlist?.continuation != '') {
            await YTMClient.playlist(playlist!);
            setState(() {});
          }
        } catch (exception, stacktrace) {
          debugPrint(exception.toString());
          debugPrint(stacktrace.toString());
        }
        if (playlist!.tracks.isNotEmpty) {
          if (playlist!.name.isEmpty) {
            debugPrint('playlist.name.isEmpty');
            await Navigator.of(context).maybePop();
            String name = '';
            await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(Language.instance.PLAYLISTS_TEXT_FIELD_LABEL),
                content: Container(
                  height: 40.0,
                  width: 360.0,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                  padding: EdgeInsets.only(top: 2.0),
                  child: Focus(
                    child: CustomTextField(
                      autofocus: true,
                      onChanged: (value) {
                        playlist?.name = value;
                        name = value;
                      },
                      cursorWidth: 1.0,
                      onSubmitted: (value) {
                        playlist?.name = value;
                        Navigator.of(ctx).maybePop();
                      },
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(ctx).textTheme.bodyLarge,
                      decoration: inputDecoration(
                        ctx,
                        Language.instance.PLAYLISTS_TEXT_FIELD_HINT,
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(
                      label(
                        context,
                        Language.instance.OK,
                      ),
                    ),
                    onPressed: Navigator.of(context).maybePop,
                  ),
                ],
              ),
            );
            debugPrint(name);
          }
          debugPrint(playlist?.name.toString());
          try {
            setState(() {
              fetched = true;
            });
          } catch (exception) {}
          final result = await Collection.instance.playlistCreateFromName(
            playlist!.name,
          );
          await Collection.instance.playlistAddTracks(
            result,
            playlist!.tracks.map((e) => Parser.track(e)).toList(),
          );
          try {
            setState(() {
              saved = true;
            });
          } catch (exception) {}
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                Language.instance.ERROR,
              ),
              content: Text(
                Language.instance.INTERNET_ERROR,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.start,
              ),
              actions: [
                TextButton(
                  child: Text(
                    label(
                      context,
                      Language.instance.OK,
                    ),
                  ),
                  onPressed: Navigator.of(context).maybePop,
                ),
              ],
            ),
          );
        }
      } on ArgumentError catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        playlist = null;
        setState(() {});
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              Language.instance.ERROR,
            ),
            content: Text(
              Language.instance.INVALID_PLAYLIST_URL,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.start,
            ),
            actions: [
              TextButton(
                child: Text(
                  label(
                    context,
                    Language.instance.OK,
                  ),
                ),
                onPressed: Navigator.of(context).maybePop,
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 40.0,
          width: 360.0,
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
          padding: EdgeInsets.only(top: 2.0),
          child: Focus(
            child: CustomTextField(
              autofocus: true,
              controller: _controller,
              cursorWidth: 1.0,
              onSubmitted: (_) => add(),
              textAlignVertical: TextAlignVertical.center,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: inputDecoration(
                context,
                Language.instance.IMPORT_PLAYLIST_SUBTITLE,
              ),
            ),
          ),
        ),
        if (playlist != null) ...[
          const SizedBox(height: 12.0),
          if (playlist?.continuation != '' && !fetched)
            Align(
              child: Container(
                margin: EdgeInsets.all(16.0),
                height: 24.0,
                width: 24.0,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  strokeWidth: 3.8,
                ),
              ),
            ),
          Container(
            width: 360.0,
            child: Text(
              '${Language.instance.PLAYLIST_NAME}: ${playlist?.name ?? ''}',
              style: Theme.of(context).textTheme.displaySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${Language.instance.TRACK}: ${[
              0,
              null
            ].contains(playlist?.tracks.length) ? '' : playlist?.tracks.length}',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ],
    );
    return AlertDialog(
      title: Text(
        Language.instance.IMPORT_PLAYLIST_TITLE,
      ),
      content: content,
      actions: saved
          ? [
              TextButton(
                child: Text(
                  label(
                    context,
                    Language.instance.OK,
                  ),
                ),
                onPressed: Navigator.of(context).maybePop,
              ),
            ]
          : [
              TextButton(
                child: Text(
                  label(
                    context,
                    Language.instance.SAVE,
                  ),
                ),
                onPressed: add,
              ),
              TextButton(
                child: Text(
                  label(
                    context,
                    Language.instance.CANCEL,
                  ),
                ),
                onPressed: Navigator.of(context).maybePop,
              ),
            ],
    );
  }
}
