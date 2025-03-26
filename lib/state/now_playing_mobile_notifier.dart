import 'package:harmonoid/ui/media_library/media_library_screen.dart';
import 'package:harmonoid/ui/media_library/media_library_shell_route.dart';
import 'package:harmonoid/ui/now_playing/mobile/mobile_m2_now_playing_bar.dart';
import 'package:harmonoid/ui/now_playing/mobile/mobile_m3_now_playing_bar.dart';

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

  MobileM3NowPlayingBarState? _mobileM3NowPlayingBarStateRef;
  MobileM2NowPlayingBarState? _mobileM2NowPlayingBarStateRef;
  MediaLibraryScreenState? _mediaLibraryScreenStateRef;
  MediaLibraryShellRouteState? _mediaLibraryShellRouteStateRef;

  void setMobileM3NowPlayingBarStateRef(MobileM3NowPlayingBarState value) {
    _mobileM3NowPlayingBarStateRef = value;
  }

  void setMobileM2NowPlayingBarStateRef(MobileM2NowPlayingBarState value) {
    _mobileM2NowPlayingBarStateRef = value;
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
    _mobileM3NowPlayingBarStateRef?.maximizeNowPlayingBar();
    _mobileM2NowPlayingBarStateRef?.maximizeNowPlayingBar();
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
