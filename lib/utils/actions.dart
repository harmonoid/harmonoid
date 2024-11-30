import 'package:flutter/material.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/go_router.dart';
import 'package:harmonoid/state/now_playing_color_palette_notifier.dart';
import 'package:harmonoid/state/now_playing_mobile_notifier.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/rendering.dart';

void intentNotifyOnPlaybackStateRestore() async {
  debugPrint('actions.dart: intentNotifyOnPlaybackStateRestore');
  await Future.delayed(const Duration(seconds: 1));

  if (isDesktop) {
    // NO/OP
  }
  if (isMobile) {
    NowPlayingMobileNotifier.instance.restore();
  }
}

void intentPlayOnMediaPlayerOpen() async {
  debugPrint('actions.dart: intentPlayOnMediaPlayerOpen');
  await Future.delayed(const Duration(seconds: 1));

  if (isDesktop) {
    if (!router.location.startsWith('/$kNowPlayingPath')) {
      router.push('/$kNowPlayingPath');
    }
  }
  if (isMobile) {
    NowPlayingMobileNotifier.instance.show();
  }
}

void mediaPlayerOpenOnOpen() async {
  debugPrint('actions.dart: mediaPlayerOpenOnOpen');
  await Future.delayed(const Duration(seconds: 1));

  if (isDesktop) {
    if (Configuration.instance.nowPlayingDisplayUponPlay && !router.location.startsWith('/$kNowPlayingPath')) {
      router.push('/$kNowPlayingPath');
    }
  }
  if (isMobile) {
    if (Configuration.instance.nowPlayingDisplayUponPlay) {
      NowPlayingMobileNotifier.instance.show();
    } else {
      NowPlayingMobileNotifier.instance.restore();
    }
  }
}

void mediaPlayerUpdateCurrentOnUpdateCurrent(String uri) {
  if (AsyncFileImage.isDefault(uri)) {
    AsyncFileImage.reset(uri);
    MediaPlayer.instance
      ..resetFlagsAudioService()
      ..resetFlagsDiscordRpc()
      ..resetFlagsMpris()
      ..resetFlagsSystemMediaTransportControls();
    NowPlayingColorPaletteNotifier.instance.resetCurrent();
  }
}
