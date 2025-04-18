import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/mappers/color.dart';
import 'package:harmonoid/ui/router.dart';
import 'package:harmonoid/utils/rendering.dart';

class MediaLibraryNoItemsBanner extends StatelessWidget {
  const MediaLibraryNoItemsBanner({super.key});

  static const _kImageWidth = 164.0;
  static const _kImageHeight = 164.0;
  static const _kImageAssetM3 = 'assets/vectors/media_library.svg';
  static const _kImageAssetM2Light = 'assets/vectors/media_library.svg';
  static const _kImageAssetM2Dark = 'assets/vectors/media_library_dark.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: mediaLibraryScrollViewBuilderPadding,
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<String>(
                future: () async {
                  final theme = Theme.of(context);
                  if (isMaterial3) {
                    final data = await rootBundle.loadString(_kImageAssetM3);
                    return data
                        .replaceAll('"white"', '"${theme.colorScheme.surface.toHex()}"')
                        .replaceAll('"black"', '"${theme.colorScheme.onSurface.toHex()}"')
                        .replaceAll('"#651FFF"', '"${theme.colorScheme.primary.toHex()}"')
                        .replaceAll('"#B388FF"', '"${theme.colorScheme.inversePrimary.toHex()}"');
                  } else {
                    return await rootBundle.loadString(theme.brightness == Brightness.dark ? _kImageAssetM2Dark : _kImageAssetM2Light);
                  }
                }(),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data == null) {
                    return const SizedBox(
                      height: _kImageHeight,
                      width: _kImageWidth,
                    );
                  }
                  return SvgPicture.string(
                    data,
                    height: _kImageHeight,
                    width: _kImageWidth,
                    fit: BoxFit.contain,
                  );
                },
              ),
              const SizedBox(height: 16.0),
              Text(
                Localization.instance.MEDIA_LIBRARY_NO_ITEMS_TITLE,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                Localization.instance.MEDIA_LIBRARY_NO_ITEMS_SUBTITLE,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  context.push('/$kSettingsPath');
                },
                child: Text(label(Localization.instance.GO_TO_SETTINGS)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
