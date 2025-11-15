import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:identity/identity.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/duration.dart';
import 'package:harmonoid/extensions/go_router.dart';
import 'package:harmonoid/extensions/string.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/replaygain.dart';
import 'package:harmonoid/models/replaygain.dart';
import 'package:harmonoid/ui/now_playing/now_playing_bar.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/slide_on_enter.dart';
import 'package:harmonoid/utils/widgets.dart';

class NowPlayingControlPanel extends StatefulWidget {
  const NowPlayingControlPanel({super.key});

  static Future<void> show(BuildContext context) async {
    final path = router.location.split('/').last;
    if (isDesktop) {
      await showDialog(
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.transparent,
        builder: (context) => SlideOnEnter(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                16.0 + (path == kNowPlayingPath ? 0.0 : NowPlayingBar.height),
              ),
              child: const NowPlayingControlPanel(),
            ),
          ),
        ),
      );
    }
    if (isTablet) {
      throw UnimplementedError();
    }
    if (isMobile) {
      await showModalBottomSheet(
        context: context,
        showDragHandle: isMaterial3OrGreater,
        elevation: kDefaultHeavyElevation,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => const Padding(
          padding: EdgeInsets.all(16.0),
          child: NowPlayingControlPanel(),
        ),
      );
    }
  }

  @override
  State<NowPlayingControlPanel> createState() => NowPlayingControlPanelState();
}

class NowPlayingControlPanelState extends State<NowPlayingControlPanel> {
  EdgeInsets get _contentPadding => isDesktop ? const EdgeInsets.only(left: 4.0, top: 12.0, bottom: 18.0) : const EdgeInsets.only(left: 4.0);

  final rate = (focusNode: FocusNode(), textEditingController: TextEditingController(text: MediaPlayer.instance.state.rate.toStringAsFixed(2)));
  final pitch = (focusNode: FocusNode(), textEditingController: TextEditingController(text: MediaPlayer.instance.state.pitch.toStringAsFixed(2)));
  final volume = (focusNode: FocusNode(), textEditingController: TextEditingController(text: MediaPlayer.instance.state.volume.round().toString()));
  final replayGainPreamp = (focusNode: FocusNode(), textEditingController: TextEditingController(text: MediaPlayer.instance.state.replayGainPreamp.toStringAsFixed(2)));

  void listener() {
    if (!rate.focusNode.hasFocus) {
      rate.textEditingController.text = MediaPlayer.instance.state.rate.toStringAsFixed(2);
    }
    if (!pitch.focusNode.hasFocus) {
      pitch.textEditingController.text = MediaPlayer.instance.state.pitch.toStringAsFixed(2);
    }
    if (!volume.focusNode.hasFocus) {
      volume.textEditingController.text = MediaPlayer.instance.state.volume.round().toString();
    }
    if (!replayGainPreamp.focusNode.hasFocus) {
      replayGainPreamp.textEditingController.text = MediaPlayer.instance.state.replayGainPreamp.toStringAsFixed(2);
    }
  }

  @override
  void initState() {
    super.initState();
    MediaPlayer.instance.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    rate.focusNode.dispose();
    pitch.focusNode.dispose();
    volume.focusNode.dispose();
    replayGainPreamp.focusNode.dispose();
    rate.textEditingController.dispose();
    pitch.textEditingController.dispose();
    volume.textEditingController.dispose();
    replayGainPreamp.textEditingController.dispose();
    MediaPlayer.instance.removeListener(listener);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: kDefaultHeavyElevation,
      child: Container(
        width: 256.0,
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localization.instance.CONTROL_PANEL,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      Localization.instance.BETA.uppercase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            const Divider(height: 1.0, thickness: 1.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildContent(context),
            ),
            const Divider(height: 1.0, thickness: 1.0),
            _buildCrossfadeDuration(context),
            const Divider(height: 1.0, thickness: 1.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildReplayGain(context),
            ),
            const Divider(height: 1.0, thickness: 1.0),
            _buildExclusiveAudio(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: isMaterial2 ? 16.0 : 0.0,
            bottom: 24.0,
          ),
          child: _buildContent(context),
        ),
        const Divider(height: 1.0, thickness: 1.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: _buildCrossfadeDuration(context),
        ),
        const Divider(height: 1.0, thickness: 1.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: _buildReplayGain(context),
        ),
        SizedBox(height: 16.0 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
      ],
    );
  }

  Widget _buildCrossfadeDuration(BuildContext context) {
    return SubscriptionReveal(
      child: Consumer<MediaPlayer>(
        builder: (context, mediaPlayer, _) {
          return Column(
            children: [
              InkWell(
                onTap: () => mediaPlayer.setCrossfadeDuration(mediaPlayer.state.crossfadeDuration == Duration.zero ? MediaPlayer.kDefaultCrossfadeDuration : Duration.zero),
                child: Container(
                  height: 48.0,
                  padding: isDesktop ? const EdgeInsets.only(left: 20.0, right: 16.0) : EdgeInsets.zero,
                  child: Row(
                    children: [
                      Text(
                        '${Localization.instance.CROSSFADE} ${mediaPlayer.state.crossfadeDuration > Duration.zero ? '(${mediaPlayer.state.crossfadeDuration.inSeconds}s)' : ''}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Switch(
                        value: mediaPlayer.state.crossfadeDuration != Duration.zero,
                        onChanged: (value) => mediaPlayer.setCrossfadeDuration(value ? Duration.zero : MediaPlayer.kDefaultCrossfadeDuration),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: isDesktop ? const EdgeInsets.symmetric(horizontal: 12.0) : EdgeInsets.zero,
                child: ScrollableSlider(
                  min: MediaPlayer.kMinCrossfadeDuration.inSeconds.toDouble(),
                  max: MediaPlayer.kMaxCrossfadeDuration.inSeconds.toDouble(),
                  interval: 1.0,
                  stepSize: 1.0,
                  showLabels: true,
                  labelFormatterCallback: (value, _) {
                    if (value == MediaPlayer.kMinCrossfadeDuration.inSeconds) {
                      return '${MediaPlayer.kMinCrossfadeDuration.inSeconds}s';
                    } else if (value == MediaPlayer.kMaxCrossfadeDuration.inSeconds) {
                      return '${MediaPlayer.kMaxCrossfadeDuration.inSeconds}s';
                    }
                    return '';
                  },
                  value: mediaPlayer.state.crossfadeDuration.inSeconds.clamp(MediaPlayer.kMinCrossfadeDuration.inSeconds.toDouble(), MediaPlayer.kMaxCrossfadeDuration.inSeconds.toDouble()).toDouble(),
                  onChanged: mediaPlayer.state.crossfadeDuration != Duration.zero ? (value) => mediaPlayer.setCrossfadeDuration(Duration(seconds: value.round())) : null,
                  onScrolledUp: () => mediaPlayer.setCrossfadeDuration(
                    (mediaPlayer.state.crossfadeDuration + const Duration(seconds: 1)).clamp(MediaPlayer.kMinCrossfadeDuration, MediaPlayer.kMaxCrossfadeDuration),
                  ),
                  onScrolledDown: () => mediaPlayer.setCrossfadeDuration(
                    (mediaPlayer.state.crossfadeDuration - const Duration(seconds: 1)).clamp(MediaPlayer.kMinCrossfadeDuration, MediaPlayer.kMaxCrossfadeDuration),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExclusiveAudio(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        return InkWell(
          onTap: () => mediaPlayer.setExclusiveAudio(!mediaPlayer.state.exclusiveAudio),
          child: Container(
            height: 48.0,
            padding: const EdgeInsets.only(left: 20.0, right: 16.0),
            child: Row(
              children: [
                Text(
                  Localization.instance.EXCLUSIVE_AUDIO,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Switch(
                  value: mediaPlayer.state.exclusiveAudio,
                  onChanged: (value) => mediaPlayer.setExclusiveAudio(value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReplayGain(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        return Column(
          children: [
            Row(
              children: [
                Text(
                  Localization.instance.REPLAYGAIN,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                ActionChip(
                  elevation: 0.0,
                  pressElevation: 0.0,
                  onPressed: () => mediaPlayer.setReplayGain(ReplayGain.values[(mediaPlayer.state.replayGain.index + 1) % ReplayGain.values.length]),
                  label: Text(mediaPlayer.state.replayGain.toLabel()),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  Localization.instance.PREAMP_GAIN,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                SizedBox(
                  height: 32.0,
                  width: 48.0,
                  child: DefaultTextFormField(
                    focusNode: replayGainPreamp.focusNode,
                    controller: replayGainPreamp.textEditingController,
                    onChanged: (value) => mediaPlayer.setReplayGainPreamp(double.tryParse(value) ?? 1.0),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'NaN',
                      contentPadding: _contentPadding,
                    ),
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]|\.'))],
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<MediaPlayer>(
      builder: (context, mediaPlayer, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localization.instance.SPEED,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => mediaPlayer.setRate(1.0),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.speed,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: ScrollableSlider(
                    min: 0.5,
                    max: 1.5,
                    value: mediaPlayer.state.rate.clamp(0.5, 1.5),
                    onChanged: (value) => mediaPlayer.setRate(value),
                    onScrolledUp: () => mediaPlayer.setRate(mediaPlayer.state.rate + 0.05),
                    onScrolledDown: () => mediaPlayer.setRate(mediaPlayer.state.rate - 0.05),
                  ),
                ),
                const SizedBox(width: 12.0),
                SizedBox(
                  height: 32.0,
                  width: 48.0,
                  child: DefaultTextFormField(
                    focusNode: rate.focusNode,
                    controller: rate.textEditingController,
                    onChanged: (value) => mediaPlayer.setRate(double.tryParse(value) ?? 1.0),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'NaN',
                      contentPadding: _contentPadding,
                    ),
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]|\.'))],
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              Localization.instance.PITCH,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => mediaPlayer.setPitch(1.0),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        FluentIcons.pulse_24_filled,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: ScrollableSlider(
                    min: 0.5,
                    max: 1.5,
                    value: mediaPlayer.state.pitch.clamp(0.5, 1.5),
                    onChanged: (value) => mediaPlayer.setPitch(value),
                    onScrolledUp: () => mediaPlayer.setPitch(mediaPlayer.state.pitch + 0.05),
                    onScrolledDown: () => mediaPlayer.setPitch(mediaPlayer.state.pitch - 0.05),
                  ),
                ),
                const SizedBox(width: 12.0),
                SizedBox(
                  height: 32.0,
                  width: 48.0,
                  child: DefaultTextFormField(
                    focusNode: pitch.focusNode,
                    controller: pitch.textEditingController,
                    onChanged: (value) => mediaPlayer.setPitch(double.tryParse(value) ?? 1.0),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'NaN',
                      contentPadding: _contentPadding,
                    ),
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]|\.'))],
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              Localization.instance.VOLUME_BOOST,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => mediaPlayer.setVolume(100.0),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.speaker,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: ScrollableSlider(
                    min: 100.0,
                    max: 200.0,
                    value: mediaPlayer.state.volume.clamp(100.0, 200.0),
                    onChanged: (value) => mediaPlayer.setVolume(value),
                    onScrolledUp: () => mediaPlayer.setVolume(mediaPlayer.state.volume + 5.0),
                    onScrolledDown: () => mediaPlayer.setVolume(mediaPlayer.state.volume - 5.0),
                  ),
                ),
                const SizedBox(width: 12.0),
                SizedBox(
                  height: 32.0,
                  width: 48.0,
                  child: DefaultTextFormField(
                    focusNode: volume.focusNode,
                    controller: volume.textEditingController,
                    onChanged: (value) => mediaPlayer.setVolume(double.tryParse(value) ?? 100.0),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'NaN',
                      contentPadding: _contentPadding,
                    ),
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]|'))],
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
