/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:ytm_client/ytm_client.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/utils/theme.dart';
import 'package:harmonoid/utils/helpers.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/web.dart';
import 'package:harmonoid/web/state/web.dart';

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
      Web.instance.open(track);
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
                          textStyle: Theme.of(context).textTheme.displaySmall!,
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
            width: 298.0,
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: 0.0,
              bottom: 0.0,
            ),
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
                autofocus: isDesktop,
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
                style: Theme.of(context).textTheme.headlineMedium,
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
                title: Text(
                  Language.instance.PLAYLISTS_TEXT_FIELD_LABEL,
                ),
                content: Container(
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
                      style: Theme.of(ctx).textTheme.headlineMedium,
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
            if (name.isEmpty) {
              throw FormatException(
                'name.isEmpty',
              );
            }
          }
          debugPrint(playlist?.name.toString());
          try {
            setState(() {
              fetched = true;
            });
          } catch (exception) {}
          final result =
              await Collection.instance.playlistCreateFromName(playlist!.name);
          await Collection.instance.playlistAddTracks(
            result,
            playlist!.tracks
                .map(
                  (track) => Helpers.parseWebTrack(
                    track.toJson(),
                  ),
                )
                .toList(),
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
                  Language.instance.OK,
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
              textAlignVertical: TextAlignVertical.center,
              style: Theme.of(context).textTheme.headlineMedium,
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
                  Language.instance.OK.toUpperCase(),
                ),
                onPressed: Navigator.of(context).maybePop,
              ),
            ]
          : [
              TextButton(
                child: Text(
                  Language.instance.SAVE.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: add,
              ),
              TextButton(
                child: Text(
                  Language.instance.CANCEL.toUpperCase(),
                ),
                onPressed: Navigator.of(context).maybePop,
              ),
            ],
    );
  }
}

class PlaylistImportBottomSheet extends StatefulWidget {
  PlaylistImportBottomSheet({Key? key}) : super(key: key);

  @override
  State<PlaylistImportBottomSheet> createState() =>
      _PlaylistImportBottomSheetState();
}

class _PlaylistImportBottomSheetState extends State<PlaylistImportBottomSheet> {
  final TextEditingController controller = TextEditingController();
  Playlist? playlist;
  bool fetched = false;
  bool saved = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void add() async {
    if (controller.text.isNotEmpty) {
      try {
        playlist = Playlist.fromRawURL(controller.text);
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
            await showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              builder: (ctx) => Container(
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom -
                      MediaQuery.of(ctx).padding.bottom,
                ),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4.0),
                    TextField(
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      onChanged: (value) {
                        playlist?.name = value;
                        name = value;
                      },
                      onSubmitted: (value) {
                        playlist?.name = value;
                        Navigator.of(ctx).maybePop();
                      },
                      decoration: InputDecoration(
                        hintText: Language.instance.PLAYLIST_NAME,
                        contentPadding: EdgeInsets.fromLTRB(
                          12,
                          30,
                          12,
                          6,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(ctx).iconTheme.color!.withOpacity(0.4),
                            width: 1.8,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(ctx).iconTheme.color!.withOpacity(0.4),
                            width: 1.8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(ctx).primaryColor,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: Navigator.of(ctx).maybePop,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(ctx).primaryColor,
                        ),
                      ),
                      child: Text(
                        Language.instance.OK.toUpperCase(),
                        style: const TextStyle(letterSpacing: 2.0),
                      ),
                    ),
                  ],
                ),
              ),
            );
            if (name.isEmpty) {
              throw FormatException(
                'name.isEmpty',
              );
            }
          }
          debugPrint(playlist?.name.toString());
          try {
            setState(() {
              fetched = true;
            });
          } catch (exception) {}
          final result =
              await Collection.instance.playlistCreateFromName(playlist!.name);
          await Collection.instance.playlistAddTracks(
            result,
            playlist!.tracks
                .map(
                  (track) => Helpers.parseWebTrack(
                    track.toJson(),
                  ),
                )
                .toList(),
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
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom -
            MediaQuery.of(context).padding.bottom,
      ),
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4.0),
          TextField(
            textCapitalization: TextCapitalization.none,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            autofocus: true,
            controller: controller,
            onSubmitted: (_) => add(),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                12,
                30,
                12,
                6,
              ),
              hintText: Language.instance.IMPORT_PLAYLIST_SUBTITLE,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                  width: 1.8,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                  width: 1.8,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.8,
                ),
              ),
            ),
          ),
          if (playlist != null) ...[
            const SizedBox(height: 12.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
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
                  ),
                ),
                if (playlist?.continuation != '' && !fetched)
                  Align(
                    child: Container(
                      margin: EdgeInsets.all(2.0).copyWith(
                        left: 16.0,
                        right: 16.0,
                      ),
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
              ],
            ),
          ],
          const SizedBox(height: 8.0),
          if (saved)
            ElevatedButton(
              onPressed: Navigator.of(context).maybePop,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor,
                ),
              ),
              child: Text(
                Language.instance.OK.toUpperCase(),
                style: const TextStyle(letterSpacing: 2.0),
              ),
            )
          else
            ElevatedButton(
              onPressed: add,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor,
                ),
              ),
              child: Text(
                Language.instance.ADD.toUpperCase(),
                style: const TextStyle(letterSpacing: 2.0),
              ),
            ),
        ],
      ),
    );
  }
}

class WebMobileAppBarOverflowButton extends StatefulWidget {
  final Color? color;
  final bool withinScreen;
  WebMobileAppBarOverflowButton({
    Key? key,
    this.color,
    this.withinScreen = true,
  }) : super(key: key);

  @override
  State<WebMobileAppBarOverflowButton> createState() =>
      _WebMobileAppBarOverflowButtonState();
}

class _WebMobileAppBarOverflowButtonState
    extends State<WebMobileAppBarOverflowButton> {
  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: Icon(
        Icons.more_vert,
        color: widget.color ??
            Theme.of(context)
                .extension<IconColors>()
                ?.appBarActionDarkIconColor,
      ),
      onPressed: () {
        final position = RelativeRect.fromRect(
          Offset(
                MediaQuery.of(context).size.width - tileMargin - 48.0,
                widget.withinScreen
                    ? (MediaQueryData.fromWindow(window).padding.top +
                        kMobileSearchBarHeight +
                        2 * tileMargin)
                    : (MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        2 * tileMargin),
              ) &
              Size(double.infinity, double.infinity),
          Rect.fromLTWH(
            0,
            0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
        );
        showMenu<int>(
          context: context,
          position: position,
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
          ),
          elevation: 4.0,
          items: [
            PopupMenuItem(
              value: 0,
              child: ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(Language.instance.SETTING),
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: ListTile(
                leading: Icon(
                  Icons.info,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: Text(Language.instance.ABOUT_TITLE),
              ),
            ),
          ],
        ).then((value) {
          switch (value) {
            case 0:
              {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: Settings(),
                    ),
                  ),
                );
                break;
              }
            case 1:
              {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: AboutPage(),
                    ),
                  ),
                );
                break;
              }
          }
        });
      },
    );
  }
}
