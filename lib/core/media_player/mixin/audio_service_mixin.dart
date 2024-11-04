import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:synchronized/synchronized.dart';

import 'package:harmonoid/core/media_player/base_media_player.dart';

/// {@template audio_service_mixin}
///
/// AudioServiceMixin
/// -----------------
/// package:audio_service mixin for [BaseMediaPlayer].
///
/// {@endtemplate}
mixin AudioServiceMixin implements BaseMediaPlayer {
  static const String kAndroidNotificationChannelId = 'com.alexmercerind.harmonoid';
  static const String kAndroidNotificationChannelName = 'Harmonoid';
  static const String kAndroidNotificationIcon = 'drawable/ic_stat_music_note';

  static bool get supported => Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  Future<void> ensureInitializedAudioService() async {
    if (!supported) return;

    final instance = await AudioService.init(
      builder: () => _AudioServiceImpl(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: kAndroidNotificationChannelId,
        androidNotificationChannelName: kAndroidNotificationChannelName,
        androidNotificationIcon: kAndroidNotificationIcon,
        androidNotificationClickStartsActivity: true,
        androidNotificationOngoing: true,
      ),
    );

    _instanceAudioService = instance;

    addListener(_listenerAudioService);
  }

  Future<void> disposeAudioService() async {
    if (!supported) return;

    await _instanceAudioService?.stop();
  }

  void resetFlagsAudioService() {}

  void _listenerAudioService() {
    _lockAudioService.synchronized(() async {});
  }

  _AudioServiceImpl? _instanceAudioService;
  final Lock _lockAudioService = Lock();
}

class _AudioServiceImpl extends BaseAudioHandler {}
