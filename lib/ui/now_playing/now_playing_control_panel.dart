import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_player/media_player.dart';
import 'package:harmonoid/extensions/go_router.dart';
import 'package:harmonoid/localization/localization.dart';
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
      await showDialog(
        context: context,
        useRootNavigator: true,
        // NOTE: The default barrier color. I have no fucking idea why this isn't available in Flutter's [ThemeData].
        barrierColor: Colors.black54,
        builder: (context) => const SlideOnEnter(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: NowPlayingControlPanel(),
            ),
          ),
        ),
      );
    }
  }

  @override
  State<NowPlayingControlPanel> createState() => NowPlayingControlPanelState();
}

class NowPlayingControlPanelState extends State<NowPlayingControlPanel> {
  final rate = (focusNode: FocusNode(), textEditingController: TextEditingController(text: MediaPlayer.instance.state.rate.toStringAsFixed(2)));
  final pitch = (focusNode: FocusNode(), textEditingController: TextEditingController(text: MediaPlayer.instance.state.pitch.toStringAsFixed(2)));
  final volume = (focusNode: FocusNode(), textEditingController: TextEditingController(text: MediaPlayer.instance.state.volume.round().toString()));

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
    rate.textEditingController.dispose();
    pitch.textEditingController.dispose();
    volume.textEditingController.dispose();
    MediaPlayer.instance.removeListener(listener);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: kDefaultHeavyElevation,
      child: Container(
        width: 256.0,
        padding: const EdgeInsets.all(20.0),
        child: Consumer<MediaPlayer>(builder: (context, mediaPlayer, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                      Localization.instance.BETA.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
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
                    width: 40.0,
                    child: DefaultTextField(
                      focusNode: rate.focusNode,
                      controller: rate.textEditingController,
                      onChanged: (value) => mediaPlayer.setRate(double.tryParse(value) ?? 1.0),
                      cursorWidth: 1.0,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: inputDecoration(context, 'NaN', contentPadding: EdgeInsets.zero),
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
                    width: 40.0,
                    child: DefaultTextField(
                      focusNode: pitch.focusNode,
                      controller: pitch.textEditingController,
                      onChanged: (value) => mediaPlayer.setPitch(double.tryParse(value) ?? 1.0),
                      cursorWidth: 1.0,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: inputDecoration(context, 'NaN', contentPadding: EdgeInsets.zero),
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
                    width: 40.0,
                    child: DefaultTextField(
                      focusNode: volume.focusNode,
                      controller: volume.textEditingController,
                      onChanged: (value) => mediaPlayer.setVolume(double.tryParse(value) ?? 100.0),
                      cursorWidth: 1.0,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: inputDecoration(context, 'NaN', contentPadding: EdgeInsets.zero),
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]|'))],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    throw UnimplementedError();
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
