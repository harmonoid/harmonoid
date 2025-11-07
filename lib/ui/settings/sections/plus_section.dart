import 'package:flutter/material.dart';
import 'package:identity/identity.dart';

import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/widgets.dart';

class PlusSection extends StatefulWidget {
  const PlusSection({super.key});

  @override
  State<PlusSection> createState() => _PlusSectionState();
}

class _PlusSectionState extends State<PlusSection> {
  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Plus⁺',
      subtitle: 'A little extra, for those who care',
      contentPadding: const EdgeInsets.symmetric(horizontal: 64.0 - 16.0),
      children: [
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Crossfade duration: 5 seconds',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 64.0,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ScrollableSlider(
            min: 0.0,
            max: 20.0,
            interval: 1.0,
            stepSize: 1.0,
            showLabels: true,
            labelFormatterCallback: (value, _) {
              return switch (value) {
                0 || 5 || 20 => '${value ~/ 1}s',
                _ => '',
              };
            },
            value: 5.0,
            onChanged: (value) {},
          ),
        ),
        const SizedBox(height: 8.0),
        ListItem(
          trailing: Switch(
            value: true,
            onChanged: (value) {},
          ),
          title: 'Crossfade between tracks',
          onTap: () {},
        ),
        ListItem(
          trailing: Switch(
            value: true,
            onChanged: (value) {},
          ),
          title: 'Display artist images',
          onTap: () {},
        ),
      ],
      childrenBuilder: (child) => SubscriptionReveal(child: child),
    );
  }
}
