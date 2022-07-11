/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:substring_highlight/substring_highlight.dart';

import 'package:harmonoid/web/web.dart';
import 'package:harmonoid/web/state/web.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/models/media.dart' as media;

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
  String _query = '';
  List<String> _suggestions = <String>[];
  int _highlightedSuggestionIndex = -1;
  late TextEditingController _searchBarController;
  HotKey? _hotKey;

  @override
  void dispose() {
    if (_hotKey != null) {
      HotKeyManager.instance.unregister(_hotKey!);
    }
    super.dispose();
  }

  Future<void> searchOrPlay(String value) async {
    if (value.isEmpty) return;
    final track = await YTMClient.player(value);
    if (track != null) {
      Web.open(track);
    } else {
      Configuration.instance.save(
        webSearchRecent:
            ([value] + Configuration.instance.webRecent).take(10).toList(),
      );
      Navigator.of(context).push(
        PageRouteBuilder(
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
              height: 7 * 32.0,
              width: 280.0,
              child: Material(
                color: Theme.of(context).cardColor,
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
                          textStyle: Theme.of(context).textTheme.headline3!,
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
        if (_hotKey == null) {
          _hotKey = searchBarHotkey;
          HotKeyManager.instance.register(
            _hotKey!,
            keyDownHandler: (_) {
              node.requestFocus();
            },
          );
        }
        _searchBarController = controller;
        return Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              HotKeys.instance.enableSpaceHotKey();
            }
          },
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
            width: 280.0,
            padding: EdgeInsets.only(bottom: 1.0),
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  HotKeys.instance.disableSpaceHotKey();
                } else {
                  HotKeys.instance.enableSpaceHotKey();
                }
              },
              child: TextField(
                autofocus: isDesktop,
                cursorWidth: 1.0,
                focusNode: node,
                controller: controller,
                onChanged: (value) async {
                  value = value.trim();
                  setState(() {
                    _highlightedSuggestionIndex = -1;
                    _query = value;
                  });
                  _suggestions = value.isEmpty
                      ? []
                      : await YTMClient.music_get_search_suggestions(value);
                  setState(() {});
                },
                onSubmitted: (query) {
                  searchOrPlay(query);
                },
                cursorColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                textAlignVertical: TextAlignVertical.bottom,
                style: Theme.of(context).textTheme.headline4,
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
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  trailingIconOnPressed: () {
                    searchOrPlay(_query);
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
  PlaylistImportDialog({Key? key}) : super(key: key);

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
        if (playlist != null) {
          setState(() {
            fetched = true;
          });
          final result = await Collection.instance.playlistAdd(playlist!.name);
          for (final track in playlist!.tracks) {
            await Collection.instance.playlistAddTrack(
              result,
              media.Track.fromWebTrack(track.toJson()),
            );
          }
          setState(() {
            saved = true;
          });
        }
      } on ArgumentError catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        playlist = null;
        setState(() {});
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  child: Text(
                    Language.instance.ERROR,
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.start,
                  ),
                  padding: EdgeInsets.only(
                    bottom: 16.0,
                    left: 4.0,
                  ),
                ),
                Padding(
                  child: Text(
                    Language.instance.INVALID_PLAYLIST_URL,
                    style: Theme.of(context).textTheme.headline3,
                    textAlign: TextAlign.start,
                  ),
                  padding: EdgeInsets.only(
                    bottom: 16.0,
                    left: 4.0,
                  ),
                ),
              ],
            ),
            actions: [
              MaterialButton(
                child: Text(
                  Language.instance.OK,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
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
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            child: Text(
              Language.instance.IMPORT_PLAYLIST_TITLE,
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.start,
            ),
            padding: EdgeInsets.only(
              bottom: 16.0,
              left: 4.0,
            ),
          ),
          Container(
            height: 40.0,
            width: 360.0,
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
            padding: EdgeInsets.only(top: 2.0),
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  HotKeys.instance.disableSpaceHotKey();
                } else {
                  HotKeys.instance.enableSpaceHotKey();
                }
              },
              child: TextField(
                autofocus: true,
                controller: _controller,
                cursorWidth: 1.0,
                onSubmitted: (_) => add(),
                cursorColor: Theme.of(context).brightness == Brightness.light
                    ? Color(0xFF212121)
                    : Colors.white,
                textAlignVertical: TextAlignVertical.bottom,
                style: Theme.of(context).textTheme.headline4,
                decoration: inputDecoration(
                  context,
                  Language.instance.IMPORT_PLAYLIST_SUBTITLE,
                  trailingIcon: Icon(
                    Icons.add,
                    size: 20.0,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  trailingIconOnPressed: add,
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
                  child: CircularProgressIndicator(
                    strokeWidth: 3.8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            if (fetched && !saved)
              Align(
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  height: 24.0,
                  width: 24.0,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            Container(
              width: 360.0,
              child: Text(
                '${Language.instance.PLAYLIST_NAME}: ${playlist?.name ?? ''}',
                style: Theme.of(context).textTheme.headline3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${Language.instance.TRACK}: ${[
                0,
                null
              ].contains(playlist?.tracks.length) ? '' : playlist?.tracks.length}',
              style: Theme.of(context).textTheme.headline3,
            ),
          ],
        ],
      ),
      actions: saved
          ? [
              MaterialButton(
                child: Text(
                  'DONE',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: Navigator.of(context).maybePop,
              ),
            ]
          : [
              MaterialButton(
                child: Text(
                  Language.instance.SAVE.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: add,
              ),
              MaterialButton(
                child: Text(
                  Language.instance.CANCEL.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: Navigator.of(context).maybePop,
              ),
            ],
    );
  }
}
