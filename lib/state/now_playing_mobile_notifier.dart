import 'package:harmonoid/ui/media_library/media_library_screen.dart';
import 'package:harmonoid/ui/media_library/media_library_shell_route.dart';
import 'package:harmonoid/ui/now_playing/mobile/m2_mobile_now_playing_bar.dart';
import 'package:harmonoid/ui/now_playing/mobile/m3_mobile_now_playing_bar.dart';

/// {@template now_playing_mobile_notifier}
///
/// NowPlayingMobileNotifier
/// -------------------------
/// Implementation to notify now playing bar & screen on mobile.
///
/// {@endtemplate}
class NowPlayingMobileNotifier {
  /// Singleton instance.
  static final NowPlayingMobileNotifier instance = NowPlayingMobileNotifier._();

  /// {@macro now_playing_mobile_notifier}
  NowPlayingMobileNotifier._();

  M3MobileNowPlayingBarState? _m3MobileNowPlayingBarStateRef;
  M2MobileNowPlayingBarState? _m2MobileNowPlayingBarStateRef;
  MediaLibraryScreenState? _mediaLibraryScreenStateRef;
  MediaLibraryShellRouteState? _mediaLibraryShellRouteStateRef;

  bool get maximized => (_m3MobileNowPlayingBarStateRef?.maximized ?? false) || (_m2MobileNowPlayingBarStateRef?.maximized ?? false);

  bool get slidingUpPanelOpened => (_m3MobileNowPlayingBarStateRef?.slidingUpPanelOpened ?? false) || (_m2MobileNowPlayingBarStateRef?.slidingUpPanelOpened ?? false);

  void setM3MobileNowPlayingBarStateRef(M3MobileNowPlayingBarState value) {
    _m3MobileNowPlayingBarStateRef = value;
  }

  void setM2MobileNowPlayingBarStateRef(M2MobileNowPlayingBarState value) {
    _m2MobileNowPlayingBarStateRef = value;
  }

  void setMediaLibraryScreenStateRef(MediaLibraryScreenState value) {
    _mediaLibraryScreenStateRef = value;
  }

  void setMediaLibraryShellRouteStateRef(MediaLibraryShellRouteState value) {
    _mediaLibraryShellRouteStateRef = value;
  }

  void showNowPlayingBar() {
    _mediaLibraryShellRouteStateRef?.mobileShowNowPlayingBar();
    _mediaLibraryScreenStateRef?.mobileShiftMediaLibraryRefreshButton();
  }

  void hideNowPlayingBar() {
    _mediaLibraryShellRouteStateRef?.mobileHideNowPlayingBar();
    _mediaLibraryScreenStateRef?.mobileUnshiftMediaLibraryRefreshButton();
  }

  void maximizeNowPlayingBar() {
    _m3MobileNowPlayingBarStateRef?.maximizeNowPlayingBar();
    _m2MobileNowPlayingBarStateRef?.maximizeNowPlayingBar();
  }

  void minimizeNowPlayingBar() {
    _m3MobileNowPlayingBarStateRef?.minimizeNowPlayingBar();
    _m2MobileNowPlayingBarStateRef?.minimizeNowPlayingBar();
  }

  void closeSlidingUpPanel() {
    _m3MobileNowPlayingBarStateRef?.closeSlidingUpPanel();
    _m2MobileNowPlayingBarStateRef?.closeSlidingUpPanel();
  }

  void showBottomNavigationBar() {
    _mediaLibraryShellRouteStateRef?.mobileShowBottomNavigationBar();
  }

  void hideBottomNavigationBar() {
    _mediaLibraryShellRouteStateRef?.mobileHideBottomNavigationBar();
  }

  void setBottomNavigationBarVisibility(double value) {
    _mediaLibraryShellRouteStateRef?.mobileSetBottomNavigationBarVisibility(value);
  }
}
