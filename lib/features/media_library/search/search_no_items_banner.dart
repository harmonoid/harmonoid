import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/utils/rendering.dart';

class SearchNoItemsBanner extends StatelessWidget {
  const SearchNoItemsBanner({super.key});

  static const _kImageWidth = 164.0;
  static const _kImageHeight = 164.0;
  static const _kImageAssetM3 = 'assets/vectors/search.svg';
  static const _kImageAssetM2Light = 'assets/vectors/search.svg';
  static const _kImageAssetM2Dark = 'assets/vectors/search_dark.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<String>(
                future: loadMaterialVectorAsset(
                  context,
                  material3: _kImageAssetM3,
                  material2Light: _kImageAssetM2Light,
                  material2Dark: _kImageAssetM2Dark,
                ),
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
                Localization.instance.SEARCH_BANNER_NO_ITEMS_TITLE,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                Localization.instance.SEARCH_BANNER_NO_ITEMS_SUBTITLE,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
