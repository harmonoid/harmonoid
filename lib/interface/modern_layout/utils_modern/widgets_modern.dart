/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart'
    hide ReorderableDragStartListener, Intent;
import 'package:flutter_switch/flutter_switch.dart';
import 'package:uri_parser/uri_parser.dart';
import 'package:animations/animations.dart';
import 'package:media_library/media_library.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:harmonoid/interface/modern_layout/settings_modern/settings_modern.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/state/now_playing_color_palette.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:harmonoid/state/mobile_now_playing_controller.dart';
import 'package:harmonoid/interface/file_info_screen.dart';
import 'package:harmonoid/interface/settings/about.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/web/web.dart';

class PopupMainMenuModern extends StatefulWidget {
  const PopupMainMenuModern({super.key});

  @override
  State<PopupMainMenuModern> createState() => _PopupMainMenuModernState();
}

class _PopupMainMenuModernState extends State<PopupMainMenuModern> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            24 * Configuration.instance.borderRadiusMultiplier),
        child: Material(
          color: Colors.transparent,
          child: PopupMenuButton(
            child: Icon(Broken.more_2),
            color: Color.alphaBlend(
                Theme.of(context).colorScheme.surface.withAlpha(100),
                Theme.of(context).cardTheme.color!),
            offset: Offset(0, kToolbarHeight + 12),
            onSelected: (value) async {
              // Prevent visual glitches when pushing a new route into the view.
              await Future.delayed(const Duration(milliseconds: 300));
              switch (value) {
                case 0:
                  {
                    final file = await pickFile(
                      label: Language.instance.MEDIA_FILES,
                      extensions: kSupportedFileTypes,
                    );
                    if (file != null) {
                      await Navigator.of(context).maybePop();
                      await Intent.instance.playURI(file.uri.toString());
                    }

                    break;
                  }
                case 1:
                  {
                    await Navigator.of(context).maybePop();
                    String input = '';
                    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      elevation: kDefaultHeavyElevation,
                      useRootNavigator: true,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setState) {
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
                                Form(
                                  key: formKey,
                                  child: TextFormField(
                                    autofocus: true,
                                    autocorrect: false,
                                    validator: (value) {
                                      final parser = URIParser(value);
                                      if (!parser.validate()) {
                                        debugPrint(value);
                                        // Empty [String] prevents the message from showing & does not distort the UI.
                                        return '';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) => input = value,
                                    keyboardType: TextInputType.url,
                                    textCapitalization: TextCapitalization.none,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (value) async {
                                      if (formKey.currentState?.validate() ??
                                          false) {
                                        await Navigator.of(context).maybePop();
                                        await Intent.instance.playURI(value);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                        12,
                                        30,
                                        12,
                                        6,
                                      ),
                                      hintText:
                                          Language.instance.FILE_PATH_OR_URL,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color!
                                              .withOpacity(0.4),
                                          width: 1.8,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color!
                                              .withOpacity(0.4),
                                          width: 1.8,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.8,
                                        ),
                                      ),
                                      errorStyle: TextStyle(height: 0.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      await Navigator.of(context).maybePop();
                                      await Intent.instance.playURI(input);
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: Text(
                                    Language.instance.PLAY.toUpperCase(),
                                    style: const TextStyle(
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );

                    break;
                  }

                case 2:
                  {
                    await FileInfoScreen.show(context);
                    break;
                  }
                case 3:
                  {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FadeThroughTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          child: WebTab(),
                        ),
                      ),
                    );
                    break;
                  }
                case 4:
                  {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FadeThroughTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          child: SettingsModern(),
                        ),
                      ),
                    );
                    break;
                  }
                case 5:
                  {
                    await Navigator.push(
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
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Broken.document_1),
                    title: Text(
                        "${Language.instance.PLAY} ${Language.instance.FILE}"),
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Broken.link_2),
                    title: Text(
                        "${Language.instance.PLAY} ${Language.instance.URL}"),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: ListTile(
                    leading: Icon(Broken.document_code_2),
                    title: Text(Language.instance.READ_METADATA),
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: ListTile(
                    leading: Icon(Broken.video_play),
                    title: Text(Language.instance.STREAM),
                  ),
                ),
                PopupMenuItem(
                  value: 4,
                  child: ListTile(
                    leading: Icon(Broken.setting_2),
                    title: Text(Language.instance.SETTING),
                  ),
                ),
                PopupMenuItem(
                  value: 5,
                  child: ListTile(
                    leading: Icon(Broken.info_circle),
                    title: Text(Language.instance.ABOUT_TITLE),
                  ),
                ),
              ];
            },
          ),
        ),
      ),
    );
  }
}

class MobileAppBarOverflowButtonModern extends StatefulWidget {
  final Color? color;
  MobileAppBarOverflowButtonModern({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  State<MobileAppBarOverflowButtonModern> createState() =>
      _MobileAppBarOverflowButtonModernState();
}

class _MobileAppBarOverflowButtonModernState
    extends State<MobileAppBarOverflowButtonModern> {
  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: Icon(
        Broken.more_2,
        color: widget.color ??
            Theme.of(context).appBarTheme.actionsIconTheme?.color,
      ),
      onPressed: () {
        final position = RelativeRect.fromRect(
          Offset(
                MediaQuery.of(context).size.width - tileMargin - 48.0,
                MediaQuery.of(context).padding.top +
                    kMobileSearchBarHeightModern +
                    (Scaffold.of(context).appBarMaxHeight?.toDouble() ?? 0.0) +
                    2 * tileMargin,
              ) &
              Size(160.0, 160.0),
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
          elevation: 4.0,
          constraints: BoxConstraints(
            maxWidth: double.infinity,
          ),
          items: [
            PopupMenuItem(
              value: 0,
              child: ListTile(
                leading: Icon(Icons.file_open),
                title: Text(Language.instance.OPEN_FILE_OR_URL),
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: ListTile(
                leading: Icon(Icons.code),
                title: Text(Language.instance.READ_METADATA),
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: ListTile(
                leading: Icon(Icons.waves),
                title: Text(Language.instance.STREAM),
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: ListTile(
                leading: Icon(Broken.setting_2),
                title: Text(Language.instance.SETTING),
              ),
            ),
            PopupMenuItem(
              value: 4,
              child: ListTile(
                leading: Icon(Broken.info_circle),
                title: Text(Language.instance.ABOUT_TITLE),
              ),
            ),
          ],
        ).then((value) async {
          // Prevent visual glitches when pushing a new route into the view.
          await Future.delayed(const Duration(milliseconds: 300));
          switch (value) {
            case 0:
              {
                await showDialog(
                  context: context,
                  builder: (ctx) => BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: SimpleDialog(
                      title: Text(
                        Language.instance.OPEN_FILE_OR_URL,
                      ),
                      children: [
                        ListTile(
                          onTap: () async {
                            final file = await pickFile(
                              label: Language.instance.MEDIA_FILES,
                              extensions: kSupportedFileTypes,
                            );
                            if (file != null) {
                              await Navigator.of(ctx).maybePop();
                              await Intent.instance
                                  .playURI(file.uri.toString());
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Theme.of(ctx).iconTheme.color,
                            child: Icon(
                              Icons.folder,
                            ),
                          ),
                          title: Text(
                            Language.instance.FILE,
                            style: isDesktop
                                ? Theme.of(ctx).textTheme.headlineMedium
                                : Theme.of(ctx)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontSize: 16.0,
                                    ),
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            await Navigator.of(ctx).maybePop();
                            String input = '';
                            final GlobalKey<FormState> formKey =
                                GlobalKey<FormState>();
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              elevation: kDefaultHeavyElevation,
                              useRootNavigator: true,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setState) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom -
                                          MediaQuery.of(context).padding.bottom,
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 4.0),
                                        Form(
                                          key: formKey,
                                          child: TextFormField(
                                            autofocus: true,
                                            autocorrect: false,
                                            validator: (value) {
                                              final parser = URIParser(value);
                                              if (!parser.validate()) {
                                                debugPrint(value);
                                                // Empty [String] prevents the message from showing & does not distort the UI.
                                                return '';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) => input = value,
                                            keyboardType: TextInputType.url,
                                            textCapitalization:
                                                TextCapitalization.none,
                                            textInputAction:
                                                TextInputAction.done,
                                            onFieldSubmitted: (value) async {
                                              if (formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                await Navigator.of(context)
                                                    .maybePop();
                                                await Intent.instance
                                                    .playURI(value);
                                              }
                                            },
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                12,
                                                30,
                                                12,
                                                6,
                                              ),
                                              hintText: Language
                                                  .instance.FILE_PATH_OR_URL,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color!
                                                      .withOpacity(0.4),
                                                  width: 1.8,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color!
                                                      .withOpacity(0.4),
                                                  width: 1.8,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 1.8,
                                                ),
                                              ),
                                              errorStyle:
                                                  TextStyle(height: 0.0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              await Navigator.of(context)
                                                  .maybePop();
                                              await Intent.instance
                                                  .playURI(input);
                                            }
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          child: Text(
                                            Language.instance.PLAY
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Theme.of(ctx).iconTheme.color,
                            child: Icon(
                              Icons.link,
                            ),
                          ),
                          title: Text(
                            Language.instance.URL,
                            style: isDesktop
                                ? Theme.of(ctx).textTheme.headlineMedium
                                : Theme.of(ctx)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontSize: 16.0,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                break;
              }
            case 1:
              {
                await FileInfoScreen.show(context);
                break;
              }
            case 2:
              {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: WebTab(),
                    ),
                  ),
                );
                break;
              }
            case 3:
              {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      child: SettingsModern(),
                    ),
                  ),
                );
                break;
              }
            case 4:
              {
                await Navigator.push(
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

class SettingsCardsModern extends StatelessWidget {
  const SettingsCardsModern({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(12.0),
      // padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(
            20 * Configuration.instance.borderRadiusMultiplier),
      ),
      child: child,
    );
  }
}

class CustomSwitchListTileModern extends StatefulWidget {
  final bool value;
  final void Function(bool) onChanged;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final IconData? icon;
  final Color? passedColor;
  CustomSwitchListTileModern(
      {Key? key,
      required this.value,
      required this.onChanged,
      required this.title,
      this.subtitle,
      this.leading,
      this.icon,
      this.passedColor})
      : super(key: key);

  @override
  State<CustomSwitchListTileModern> createState() =>
      _CustomSwitchListTileModernState();
}

class _CustomSwitchListTileModernState
    extends State<CustomSwitchListTileModern> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.white.withAlpha(10),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              20 * Configuration.instance.borderRadiusMultiplier),
        ),
        onTap: () {
          widget.onChanged(widget.value);
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        horizontalTitleGap: 0.0,
        minVerticalPadding: 8.0,
        leading: widget.icon != null
            ? Container(
                height: double.infinity,
                child: Icon(
                  widget.icon,
                  color: widget.passedColor ??
                      NowPlayingColorPalette.instance.modernColor,
                ),
              )
            : widget.leading,
        title: Text(
          widget.title.overflow,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : Theme.of(context).textTheme.displayMedium,
          maxLines: widget.subtitle != null ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: widget.subtitle != null
            ? Text(
                widget.subtitle!.overflow,
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: FittedBox(
          child: Row(
            children: [
              SizedBox(
                width: 12.0,
              ),
              AnimatedContainer(
                decoration: BoxDecoration(
                  color: widget.passedColor ??
                      NowPlayingColorPalette.instance.modernColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: widget.value
                      ? [
                          BoxShadow(
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              spreadRadius: 0,
                              color: widget.passedColor ??
                                  NowPlayingColorPalette.instance.modernColor)
                        ]
                      : null,
                ),
                duration: Duration(milliseconds: 400),
                child: FlutterSwitch(
                  activeColor: Colors.transparent,
                  toggleColor: Color.fromARGB(222, 255, 255, 255),
                  inactiveColor: Theme.of(context).disabledColor,
                  duration: Duration(milliseconds: 400),
                  borderRadius: 30.0,
                  padding: 4.0,
                  width: 40,
                  height: 21,
                  toggleSize: 14,
                  value: widget.value,
                  onToggle: (value) {
                    setState(() {
                      widget.onChanged(value);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomListTileModern extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final Widget? leading;
  final Color? passedColor;
  CustomListTileModern({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.leading,
    this.icon,
    this.passedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.white.withAlpha(10),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              20 * Configuration.instance.borderRadiusMultiplier),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        horizontalTitleGap: 0.0,
        minVerticalPadding: 8.0,
        leading: icon != null
            ? Container(
                height: double.infinity,
                child: Icon(
                  icon,
                  color: passedColor ??
                      NowPlayingColorPalette.instance.modernColor,
                ),
              )
            : leading,
        title: Text(
          title.overflow,
          style: isDesktop
              ? Theme.of(context).textTheme.headlineMedium
              : Theme.of(context).textTheme.displayMedium,
          maxLines: subtitle != null ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!.overflow,
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: AnimatedContainer(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          duration: Duration(milliseconds: 400),
          child: trailing,
        ),
        // trailing: trailing,
      ),
    );
  }
}

class AnimatingBackgroundModern extends StatefulWidget {
  final Widget child;
  final Color currentColor;
  final List<Color> currentColorsList;

  const AnimatingBackgroundModern(
      {super.key,
      required this.child,
      required this.currentColor,
      required this.currentColorsList});
  @override
  _AnimatingBackgroundModernState createState() =>
      _AnimatingBackgroundModernState();
}

class _AnimatingBackgroundModernState extends State<AnimatingBackgroundModern>
    with TickerProviderStateMixin {
  late List<Color> colorList;
  List<Alignment> alignmentList = [Alignment.topCenter, Alignment.bottomCenter];
  int index = 0;
  late Color bottomColor;
  late Color topColor;

  @override
  void initState() {
    super.initState();
    setState(() {
      bottomColor = widget.currentColor.withAlpha(150);
      topColor = widget.currentColor.withAlpha(200);
    });
    Timer(
      Duration(microseconds: 0),
      () {
        setState(
          () {
            bottomColor = Color(0xff33267C);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    colorList = [
      widget.currentColor.withAlpha(25),
      widget.currentColor.withAlpha(50),
    ];
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      onEnd: () {
        setState(
          () {
            index = index + 1;
            bottomColor = colorList[index % colorList.length];
            topColor = colorList[(index + 1) % colorList.length];
          },
        );
      },
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bottomColor, topColor],
        ),
      ),
      child: widget.child,
    );
  }
}

class AnimatedSwitchModern extends StatefulWidget {
  final bool isChecked;
  final Color? passedColor;

  const AnimatedSwitchModern(
      {super.key, required this.isChecked, this.passedColor});
  @override
  _AnimatedSwitchModernState createState() => _AnimatedSwitchModernState();
}

class _AnimatedSwitchModernState extends State<AnimatedSwitchModern>
    with TickerProviderStateMixin {
  late bool isChecked;
  Duration _duration = Duration(milliseconds: 370);
  late Animation<Alignment> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
    _animationController =
        AnimationController(vsync: this, duration: _duration);
    _animation =
        AlignmentTween(begin: Alignment.centerLeft, end: Alignment.centerRight)
            .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Center(
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(
                () {
                  if (_animationController.isCompleted) {
                    _animationController.reverse();
                  } else {
                    _animationController.forward();
                  }
                  isChecked = !isChecked;
                },
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 10,
              height: MediaQuery.of(context).size.width / 17,
              padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
              decoration: BoxDecoration(
                color: isChecked ? Colors.green : Colors.red,
                borderRadius: BorderRadius.all(
                  Radius.circular(99),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isChecked
                        ? Colors.green.withOpacity(0.6)
                        : Colors.red.withOpacity(0.6),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: _animation.value,
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            if (_animationController.isCompleted) {
                              _animationController.reverse();
                            } else {
                              _animationController.forward();
                            }
                            isChecked = !isChecked;
                          },
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 17,
                        height: MediaQuery.of(context).size.width / 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SmallPlayAllButton extends StatelessWidget {
  final IconData? icon;
  final void Function()? onTap;
  final double height;
  final double? width;
  const SmallPlayAllButton({
    super.key,
    this.icon,
    this.onTap,
    this.height = 8.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: height,
        height: width,
        margin: EdgeInsets.all(6.0),
        alignment: Alignment.center,
        // just a padding fix for [Broken.play] icon
        // padding: icon == null ? EdgeInsets.only(left: 0) : EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              8.0 * Configuration.instance.borderRadiusMultiplier),
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.background.withAlpha(225),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(1, 1))
          ],
        ),
        child: Icon(
          icon ?? Broken.play,
          // color: Theme.of(context).iconTheme.color,
          size: height * 0.6,
        ),
      ),
    );
  }
}

class MobileBottomNavigationBarModern extends StatefulWidget {
  final ValueNotifier<TabRoute> tabControllerNotifier;
  MobileBottomNavigationBarModern({
    Key? key,
    required this.tabControllerNotifier,
  }) : super(key: key);

  @override
  State<MobileBottomNavigationBarModern> createState() =>
      _MobileBottomNavigationBarModernState();
}

class _MobileBottomNavigationBarModernState
    extends State<MobileBottomNavigationBarModern> {
  late int _index;

  @override
  void initState() {
    super.initState();
    widget.tabControllerNotifier.addListener(onChange);
    _index = widget.tabControllerNotifier.value.index;
  }

  void onChange() {
    if (_index != widget.tabControllerNotifier.value.index) {
      setState(() {
        _index = widget.tabControllerNotifier.value.index;
      });
    }
  }

  @override
  void dispose() {
    widget.tabControllerNotifier.removeListener(onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Iterable<Color>?>(
      valueListenable: MobileNowPlayingController.instance.palette,
      builder: (context, value, _) => TweenAnimationBuilder<Color?>(
        duration: Duration(milliseconds: 400),
        tween: ColorTween(
          begin: Theme.of(context).primaryColor,
          end: value?.first ?? Theme.of(context).primaryColor,
        ),
        builder: (context, color, _) => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black45, blurRadius: 8.0),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              MobileNowPlayingController.instance.restore();
              if (index != _index) {
                widget.tabControllerNotifier.value =
                    TabRoute(index, TabRouteSender.bottomNavigationBar);
              }
              setState(() {
                _index = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Broken.music_dashboard),
                label: Language.instance.ALBUM,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Broken.music_circle),
                label: Language.instance.TRACK,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Broken.profile_2user),
                label: Language.instance.ARTIST,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Broken.music_library_2),
                label: Language.instance.PLAYLIST,
                backgroundColor: color ?? Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDraggableScrollableSheet extends StatefulWidget {
  List<Widget>? tracks;
  CustomDraggableScrollableSheet({super.key, this.tracks});

  @override
  State<CustomDraggableScrollableSheet> createState() =>
      _CustomDraggableScrollableSheetState();
}

class _CustomDraggableScrollableSheetState
    extends State<CustomDraggableScrollableSheet> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: DraggableScrollableSheet(
            key: Key("drag"),
            controller: DraggableScrollableController(),
            minChildSize: 0,
            initialChildSize: 0.3,
            maxChildSize: 1,
            snap: true,
            expand: false,
            snapSizes: const [
              0.55,
              1,
            ],
            builder: (context, scrollController) => SingleChildScrollView(
                  child: Column(
                    children: widget.tracks ?? [],
                  ),
                )));
  }
}
