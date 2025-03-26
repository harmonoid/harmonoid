import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:measure_size/measure_size.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/extensions/build_context.dart';
import 'package:harmonoid/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/ui/now_playing/now_playing_bar.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class MediaLibraryShellRoute extends StatefulWidget {
  final Widget child;

  const MediaLibraryShellRoute({super.key, required this.child});

  @override
  State<MediaLibraryShellRoute> createState() => MediaLibraryShellRouteState();
}

class MediaLibraryShellRouteState extends State<MediaLibraryShellRoute> with TickerProviderStateMixin {
  static const Curve _kCurve = Curves.easeInOut;

  bool _mobileNowPlayingBarFlag = false;
  bool _mobileBottomNavigationBarFlag = false;
  double _mobileBottomNavigationBarHeight = 0.0;
  late final AnimationController _mobileNowPlayingBarController;
  late final AnimationController _mobileBottomNavigationBarController;

  @override
  void initState() {
    super.initState();
    const duration = MaterialRoute.kDefaultTransitionDuration;
    _mobileNowPlayingBarController = AnimationController(vsync: this, duration: duration, reverseDuration: duration);
    _mobileBottomNavigationBarController = AnimationController(vsync: this, duration: duration, reverseDuration: duration);
    _mobileBottomNavigationBarController.value = 1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NowPlayingMobileNotifier>().setMediaLibraryShellRouteStateRef(this));
  }

  @override
  void dispose() {
    _mobileNowPlayingBarController.dispose();
    _mobileBottomNavigationBarController.dispose();
    super.dispose();
  }

  void mobileShowNowPlayingBar() {
    if (!_mobileNowPlayingBarFlag) return;
    _mobileNowPlayingBarFlag = false;
    _mobileNowPlayingBarController.animateTo(0.0, curve: _kCurve);
  }

  void mobileHideNowPlayingBar() {
    if (_mobileNowPlayingBarFlag) return;
    _mobileNowPlayingBarFlag = true;
    _mobileNowPlayingBarController.animateTo(1.0, curve: _kCurve);
  }

  void mobileShowBottomNavigationBar() {
    if (!_mobileBottomNavigationBarFlag) return;
    _mobileBottomNavigationBarFlag = false;
    Future.delayed(MaterialRoute.kDefaultTransitionDuration, () {
      const value = 1.0;
      _mobileBottomNavigationBarController.animateTo(value, curve: _kCurve);
    });
  }

  void mobileHideBottomNavigationBar() {
    if (_mobileBottomNavigationBarFlag) return;
    _mobileBottomNavigationBarFlag = true;
    Future.delayed(MaterialRoute.kDefaultTransitionDuration, () {
      final value = MediaQuery.paddingOf(context).bottom / _mobileBottomNavigationBarHeight;
      _mobileBottomNavigationBarController.animateTo(value, curve: _kCurve);
    });
  }

  void mobileSetBottomNavigationBarVisibility(double value) {
    if (_mobileBottomNavigationBarFlag && value == 1.0) return;

    final double factor;
    if (_mobileBottomNavigationBarFlag) {
      factor = MediaQuery.paddingOf(context).bottom / _mobileBottomNavigationBarHeight;
    } else {
      factor = 1.0;
    }
    _mobileBottomNavigationBarController.value = value * factor;
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          bottom: NowPlayingBar.height,
          child: widget.child,
        ),
        const NowPlayingBar(),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return widget.child;
  }

  Widget _buildMobileLayout(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          MobileNowPlayingBarScrollNotifier(child: widget.child),
          AnimatedBuilder(
            animation: _mobileNowPlayingBarController,
            builder: (context, child) {
              final nowPlayingBarVisibility = _mobileNowPlayingBarController.value;
              if (nowPlayingBarVisibility == 1.0) {
                return const SizedBox.shrink();
              }
              if (viewInsets > 0.0) {
                return const SizedBox.shrink();
              }
              return Transform.translate(
                offset: Offset(0.0, NowPlayingBar.height * nowPlayingBarVisibility),
                child: child,
              );
            },
            child: const NowPlayingBar(),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _mobileBottomNavigationBarController,
        builder: (context, child) {
          final bottomNavigationBarHeight = _mobileBottomNavigationBarHeight;
          final bottomNavigationBarVisibility = _mobileBottomNavigationBarController.value;
          final path = context.location.split('/').last;
          final visible = [kAlbumsPath, kTracksPath, kArtistsPath, kGenresPath, kPlaylistsPath].contains(path);

          if (bottomNavigationBarVisibility == 0.0) {
            return const SizedBox.shrink();
          }
          if (!visible) {
            return Container(
              height: MediaQuery.paddingOf(context).bottom,
              color: Theme.of(context).navigationBarTheme.backgroundColor,
            );
          }
          return SizedBox(
            height: bottomNavigationBarHeight * bottomNavigationBarVisibility,
            child: Stack(
              children: [
                child!,
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      curve: _kCurve,
                      opacity: _mobileBottomNavigationBarFlag ? 1.0 : 0.0,
                      duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
                      child: Container(color: Theme.of(context).navigationBarTheme.backgroundColor),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          child: MeasureSize(
            onChange: (size) => setState(() => _mobileBottomNavigationBarHeight = size.height),
            child: const MobileNavigationBar(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}
