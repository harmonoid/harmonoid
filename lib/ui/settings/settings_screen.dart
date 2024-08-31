import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/widgets.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverContentScreen(
      caption: kCaption,
      title: Language.instance.SETTINGS,
      slivers: const [
        SliverFillRemaining(),
      ],
    );
  }
}
