import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:identity/identity.dart';
import 'package:media_library/media_library.dart' hide FileSystemMediaLibrary;
import 'package:provider/provider.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/media_player_state.dart';
import 'package:harmonoid/state/lyrics/lyrics_notifier.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/features/now_playing/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/state/remote_config/models/remote_config_key.dart';
import 'package:harmonoid/state/remote_config/models/remote_config_value.dart';
import 'package:harmonoid/state/remote_config/remote_config_provider.dart';
import 'package:harmonoid/state/theme_notifier.dart';
import 'package:harmonoid/features/media_library/artists/state/artist_image_notifier.dart';
import 'package:harmonoid/features/media_library/folders/state/file_explorer_notifier.dart';
import 'package:harmonoid/features/media_library/tracks/state/tracks_notifier.dart';
import 'package:harmonoid/features/media_library/utils/rendering.dart';
import 'package:harmonoid/features/media_library/media_library_inaccessible_directories_screen.dart';
import 'package:harmonoid/features/media_library/mobile/mobile_media_library_search_bar.dart';
import 'package:harmonoid/features/media_library/tag_editor/tag_editor_demo.dart';
import 'package:harmonoid/routing/router.dart';
import 'package:harmonoid/features/update/state/update_notifier.dart';
import 'package:harmonoid/features/update/update.dart';
import 'package:harmonoid/features/user/login/login.dart';
import 'package:harmonoid/utils/actions.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/keyboard_shortcuts.dart';
import 'package:harmonoid/utils/macos_menu_bar.dart';
import 'package:harmonoid/utils/mouse_navigation.dart';
import 'package:harmonoid/utils/platform_utils.dart';
import 'package:harmonoid/utils/rendering.dart';

class HarmonoidApp extends StatefulWidget {
  const HarmonoidApp({super.key});

  @override
  State<HarmonoidApp> createState() => HarmonoidAppState();
}

class HarmonoidAppState extends State<HarmonoidApp> with WidgetsBindingObserver {
  @override
  BuildContext get context => router.routerDelegate.navigatorKey.currentContext!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasInaccessibleDirectories = await MediaLibraryInaccessibleDirectoriesScreen.showIfRequired(context);
      if (!hasInaccessibleDirectories && Configuration.instance.mediaLibraryRefreshUponStart) {
        FileSystemMediaLibrary.instance.refresh();
      }
      await Intent.instance.notify(playbackState: Configuration.instance.mediaPlayerPlaybackState);
      // HACK: It is very difficult to pass the entry point arguments to main like other platforms.
      //       This must be done after the [Player] instance inside [MediaPlayer] is initialized.
      if (Platform.isMacOS) {
        await const MethodChannel('com.alexmercerind/window_plus').invokeMethod('notifyUrls');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (NowPlayingMobileNotifier.instance.slidingUpPanelOpened) {
      NowPlayingMobileNotifier.instance.closeSlidingUpPanel();
      return true;
    }
    if (NowPlayingMobileNotifier.instance.maximized) {
      NowPlayingMobileNotifier.instance.minimizeNowPlayingBar();
      return true;
    }
    if (mediaLibrarySearchController.isAttached && mediaLibrarySearchController.isOpen && mediaLibrarySearchViewVisible) {
      mediaLibrarySearchController.closeView('');
      return true;
    }
    if (!router.canPop() && !fileExplorerCanPop) {
      PlatformUtils.instance.moveTaskToBack();
      return true;
    }
    return super.didPopRoute();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      Configuration.instance.set(mediaPlayerPlaybackState: MediaPlayer.instance.state.toPlaybackState());
    }
  }

  @override
  Widget build(BuildContext _) {
    return MultiProvider(
      providers: [
        MediaLibraryProvider(),
        ChangeNotifierProvider<FileSystemMediaLibrary>(create: (_) => FileSystemMediaLibrary.instance),
        ChangeNotifierProvider(create: (_) => MediaPlayer.instance),
        ChangeNotifierProvider(create: (_) => Localization.instance),
        ChangeNotifierProvider(create: (context) => ThemeNotifier.instance..update(context: context)),
        ChangeNotifierProvider(create: (_) => LyricsNotifier.instance),
        ChangeNotifierProvider(create: (_) => NowPlayingColorPaletteNotifier.instance),
        Provider(create: (_) => NowPlayingMobileNotifier.instance),
        ChangeNotifierProvider(create: (_) => UpdateNotifier(showUpdate: () => showUpdate(context))),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => UserNotifierFactory.create(),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (ctx) => SubscriptionNotifierFactory.create(
            userNotifier: ctx.read(),
            functions: SubscriptionFunctions(
              updateAvailable: () => context.read<UpdateNotifier>().updateAvailable,
              subscriptionPurchaseAvailable: () async {
                final remoteConfigProvider = RemoteConfigProvider();
                final response = await remoteConfigProvider.get(RemoteConfigKey.subscriptionPurchaseConfig);
                if (response is SubscriptionPurchaseConfigValue) {
                  final config = response.value;
                  final belowMinimumVersion = compareVersions(config.minVersion, kVersion);
                  final aboveMaximumVersion = compareVersions(kVersion, config.maxVersion);
                  final blacklistedVersion = config.blacklistedVersions.contains(kVersion);
                  return !belowMinimumVersion && !aboveMaximumVersion && !blacklistedVersion;
                }
                return false;
              },
              showUpdate: () => showUpdate(context),
              showLogin: () => showLogin(context),
              onSubscriptionUpdate: subscriptionNotifierOnSubscriptionUpdate,
              onSubscriptionError: (state) {
                showMessage(
                  context,
                  Localization.instance.SUBSCRIPTION_EXPIRED_TITLE,
                  Localization.instance.SUBSCRIPTION_EXPIRED_SUBTITLE,
                );
                subscriptionNotifierOnSubscriptionUpdate(state);
              },
              showTagEditorDemo: () => showTagEditorDemo(context),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ArtistImageNotifier()),
        ChangeNotifierProvider(create: (_) => FileExplorerNotifier()),
        ChangeNotifierProvider(create: (_) => TracksNotifier()),
      ],
      builder: (context, _) => Consumer2<ThemeNotifier, Localization>(
        builder: (context, themeNotifier, localization, _) => AdaptiveLayoutsLocalizations(
          code: localization.current.code,
          aToZ: Localization.instance.A_TO_Z,
          back: Localization.instance.BACK,
          dateAdded: Localization.instance.DATE_ADDED,
          files: Localization.instance.FILES,
          folders: Localization.instance.FOLDERS,
          grid: Localization.instance.GRID,
          hideHiddenFiles: Localization.instance.HIDE_HIDDEN_FILES,
          list: Localization.instance.LIST,
          more: Localization.instance.MORE,
          select: Localization.instance.SELECT,
          showHiddenFiles: Localization.instance.SHOW_HIDDEN_FILES,
          type: Localization.instance.TYPE,
          unselect: Localization.instance.UNSELECT,
          child: SubscriptionLocalizations.fromCode(
            code: localization.current.code,
            child: MacOSMenuBar(
              child: KeyboardShortcutsListener(
                child: MouseNavigationListener(
                  child: MaterialApp.router(
                    scrollBehavior: const DefaultScrollBehavior(),
                    debugShowCheckedModeBanner: false,
                    theme: themeNotifier.theme,
                    darkTheme: themeNotifier.darkTheme,
                    themeMode: themeNotifier.themeMode,
                    routerConfig: router,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DefaultScrollBehavior extends MaterialScrollBehavior {
  const DefaultScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const ClampingScrollPhysics();
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return const DefaultScrollPhysics();
      case TargetPlatform.iOS:
        return const BouncingScrollPhysics();
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast);
    }
  }
}

class DefaultScrollPhysics extends ScrollPhysics {
  const DefaultScrollPhysics({super.parent});

  @override
  BouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BouncingScrollPhysics(parent: buildParent(ancestor));
  }

  double frictionFactor(double overscrollFraction) {
    return 0.07 * math.pow(1 - overscrollFraction, 2);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) {
      return offset;
    }

    final double overscrollPastStart = math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd = math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast = math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) || (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing ? frictionFactor((overscrollPast - offset.abs()) / position.viewportDimension) : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) {
        return absDelta * gamma;
      }
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) {
      return value - position.pixels;
    }
    if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }
    if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
        constantDeceleration: 1400.0,
      );
    }
    return null;
  }

  @override
  double get minFlingVelocity => kMinFlingVelocity * 2.0;

  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign * math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(), 40000.0);
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5;

  @override
  double get maxFlingVelocity {
    return kMaxFlingVelocity * 8.0;
  }

  @override
  SpringDescription get spring {
    return SpringDescription.withDampingRatio(
      mass: 0.3,
      stiffness: 75.0,
      ratio: 1.3,
    );
  }
}

class MediaLibraryProvider extends InheritedProvider<MediaLibrary> {
  static late MediaLibrary instance;

  MediaLibraryProvider({
    super.key,
    super.dispose,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
         create: (_) {
           instance = FileSystemMediaLibrary.instance;
           return instance;
         },
         startListening: (e, value) {
           final notifier = value as ChangeNotifier;
           notifier.addListener(e.markNeedsNotifyDependents);
           return () => notifier.removeListener(e.markNeedsNotifyDependents);
         },
       );
}
