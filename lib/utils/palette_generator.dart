import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:collection/collection.dart'
    show PriorityQueue, HeapPriorityQueue;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class EncodedImage {
  const EncodedImage(
    this.byteData, {
    required this.width,
    required this.height,
  });

  final ByteData byteData;

  final int width;

  final int height;
}

class PaletteGenerator with Diagnosticable {
  PaletteGenerator.fromColors(
    this.paletteColors, {
    this.targets = const <PaletteTarget>[],
  }) : selectedSwatches = <PaletteTarget, PaletteColor>{} {
    _sortSwatches();
    _selectSwatches();
  }

  static Future<PaletteGenerator> fromByteData(
    EncodedImage encodedImage, {
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilter> filters = const <PaletteFilter>[
      avoidRedBlackWhitePaletteFilter
    ],
    List<PaletteTarget> targets = const <PaletteTarget>[],
  }) async {
    assert(region == null || region != Rect.zero);
    assert(
        region == null ||
            (region.topLeft.dx >= 0.0 && region.topLeft.dy >= 0.0),
        'Region $region is outside the image ${encodedImage.width}x${encodedImage.height}');
    assert(
        region == null ||
            (region.bottomRight.dx <= encodedImage.width &&
                region.bottomRight.dy <= encodedImage.height),
        'Region $region is outside the image ${encodedImage.width}x${encodedImage.height}');
    assert(
      encodedImage.byteData.lengthInBytes ~/ 4 ==
          encodedImage.width * encodedImage.height,
      "Image byte data doesn't match the image size, or has invalid encoding. "
      'The encoding must be RGBA with 8 bits per channel.',
    );

    final _ColorCutQuantizer quantizer = _ColorCutQuantizer(
      encodedImage,
      maxColors: maximumColorCount,
      filters: filters,
      region: region,
    );
    final List<PaletteColor> colors = await quantizer.quantizedColors;
    return PaletteGenerator.fromColors(
      colors,
      targets: targets,
    );
  }

  static Future<PaletteGenerator> fromImage(
    ui.Image image, {
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilter> filters = const <PaletteFilter>[
      avoidRedBlackWhitePaletteFilter
    ],
    List<PaletteTarget> targets = const <PaletteTarget>[],
  }) async {
    final ByteData? imageData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (imageData == null) {
      throw 'Failed to encode the image.';
    }

    return PaletteGenerator.fromByteData(
      EncodedImage(
        imageData,
        width: image.width,
        height: image.height,
      ),
      region: region,
      maximumColorCount: maximumColorCount,
      filters: filters,
      targets: targets,
    );
  }

  static Future<PaletteGenerator> fromImageProvider(
    ImageProvider imageProvider, {
    Size? size,
    Rect? region,
    int maximumColorCount = _defaultCalculateNumberColors,
    List<PaletteFilter> filters = const <PaletteFilter>[
      avoidRedBlackWhitePaletteFilter
    ],
    List<PaletteTarget> targets = const <PaletteTarget>[],
    Duration timeout = const Duration(seconds: 15),
  }) async {
    assert(region == null || size != null);
    assert(region == null || region != Rect.zero);
    assert(
        region == null ||
            (region.topLeft.dx >= 0.0 && region.topLeft.dy >= 0.0),
        'Region $region is outside the image ${size!.width}x${size.height}');
    assert(region == null || size!.contains(region.topLeft),
        'Region $region is outside the image $size');
    assert(
        region == null ||
            (region.bottomRight.dx <= size!.width &&
                region.bottomRight.dy <= size.height),
        'Region $region is outside the image $size');
    final ImageStream stream = imageProvider.resolve(
      ImageConfiguration(size: size, devicePixelRatio: 1.0),
    );
    final Completer<ui.Image> imageCompleter = Completer<ui.Image>();
    Timer? loadFailureTimeout;
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
      loadFailureTimeout?.cancel();
      stream.removeListener(listener);
      imageCompleter.complete(info.image);
    });

    if (timeout != Duration.zero) {
      loadFailureTimeout = Timer(timeout, () {
        stream.removeListener(listener);
        imageCompleter.completeError(
          TimeoutException(
              'Timeout occurred trying to load from $imageProvider'),
        );
      });
    }
    stream.addListener(listener);
    final ui.Image image = await imageCompleter.future;
    ui.Rect? newRegion = region;
    if (size != null && region != null) {
      final double scale = image.width / size.width;
      newRegion = Rect.fromLTRB(
        region.left * scale,
        region.top * scale,
        region.right * scale,
        region.bottom * scale,
      );
    }
    return PaletteGenerator.fromImage(
      image,
      region: newRegion,
      maximumColorCount: maximumColorCount,
      filters: filters,
      targets: targets,
    );
  }

  static const int _defaultCalculateNumberColors = 16;

  final Map<PaletteTarget, PaletteColor> selectedSwatches;

  final List<PaletteColor> paletteColors;

  final List<PaletteTarget> targets;

  Iterable<Color>? get colors {
    if (paletteColors.isEmpty) {
      return null;
    }
    return paletteColors.map((e) => e.color);
  }

  PaletteColor? get vibrantColor => selectedSwatches[PaletteTarget.vibrant];

  PaletteColor? get lightVibrantColor =>
      selectedSwatches[PaletteTarget.lightVibrant];

  PaletteColor? get darkVibrantColor =>
      selectedSwatches[PaletteTarget.darkVibrant];

  PaletteColor? get mutedColor => selectedSwatches[PaletteTarget.muted];

  PaletteColor? get lightMutedColor =>
      selectedSwatches[PaletteTarget.lightMuted];

  PaletteColor? get darkMutedColor => selectedSwatches[PaletteTarget.darkMuted];

  PaletteColor? get dominantColor => _dominantColor;
  PaletteColor? _dominantColor;

  void _sortSwatches() {
    if (paletteColors.isEmpty) {
      _dominantColor = null;
      return;
    }

    paletteColors.sort((PaletteColor a, PaletteColor b) {
      return b.population.compareTo(a.population);
    });
    _dominantColor = paletteColors[0];

    paletteColors.sort((PaletteColor a, PaletteColor b) {
      final aScore = ((a.color.red - a.color.green).abs() +
                  (a.color.green - a.color.blue).abs() +
                  (a.color.blue - a.color.red).abs()) *
              a.color.computeLuminance(),
          bScore = ((b.color.red - b.color.green).abs() +
                  (b.color.green - b.color.blue).abs() +
                  (b.color.blue - b.color.red).abs()) *
              b.color.computeLuminance();
      return aScore.compareTo(bScore);
    });
    final data = [...paletteColors];
    data.removeWhere((paletteColor) {
      // Remove any colors that are too close to white or black (i.e. R, G & B values are nearly same), but not perfectly black or perfectly white.
      final r = paletteColor.color.red,
          g = paletteColor.color.green,
          b = paletteColor.color.blue;
      final d1 = (r - g).abs(), d2 = (g - b).abs(), d3 = (b - r).abs();
      final average = (r + g + b) / 3;
      return d1 < 16 && d2 < 16 && d3 < 16 && average >= 120 && average <= 220;
    });
    // Only be picky when there are enough colors.
    if (data.length > 2) {
      paletteColors.clear();
      paletteColors.addAll(data);
    }
  }

  void _selectSwatches() {
    final Set<PaletteTarget> allTargets =
        Set<PaletteTarget>.from(targets + PaletteTarget.baseTargets);
    final Set<Color> usedColors = <Color>{};
    for (final PaletteTarget target in allTargets) {
      target._normalizeWeights();
      final PaletteColor? targetScore =
          _generateScoredTarget(target, usedColors);
      if (targetScore != null) {
        selectedSwatches[target] = targetScore;
      }
    }
  }

  PaletteColor? _generateScoredTarget(
      PaletteTarget target, Set<Color> usedColors) {
    final PaletteColor? maxScoreSwatch =
        _getMaxScoredSwatchForTarget(target, usedColors);
    if (maxScoreSwatch != null && target.isExclusive) {
      usedColors.add(maxScoreSwatch.color);
    }
    return maxScoreSwatch;
  }

  PaletteColor? _getMaxScoredSwatchForTarget(
      PaletteTarget target, Set<Color> usedColors) {
    double maxScore = 0.0;
    PaletteColor? maxScoreSwatch;
    for (final PaletteColor paletteColor in paletteColors) {
      if (_shouldBeScoredForTarget(paletteColor, target, usedColors)) {
        final double score = _generateScore(paletteColor, target);
        if (maxScoreSwatch == null || score > maxScore) {
          maxScoreSwatch = paletteColor;
          maxScore = score;
        }
      }
    }
    return maxScoreSwatch;
  }

  bool _shouldBeScoredForTarget(
      PaletteColor paletteColor, PaletteTarget target, Set<Color> usedColors) {
    final HSLColor hslColor = HSLColor.fromColor(paletteColor.color);
    return hslColor.saturation >= target.minimumSaturation &&
        hslColor.saturation <= target.maximumSaturation &&
        hslColor.lightness >= target.minimumLightness &&
        hslColor.lightness <= target.maximumLightness &&
        !usedColors.contains(paletteColor.color);
  }

  double _generateScore(PaletteColor paletteColor, PaletteTarget target) {
    final HSLColor hslColor = HSLColor.fromColor(paletteColor.color);

    double saturationScore = 0.0;
    double valueScore = 0.0;
    double populationScore = 0.0;

    if (target.saturationWeight > 0.0) {
      saturationScore = target.saturationWeight *
          (1.0 - (hslColor.saturation - target.targetSaturation).abs());
    }
    if (target.lightnessWeight > 0.0) {
      valueScore = target.lightnessWeight *
          (1.0 - (hslColor.lightness - target.targetLightness).abs());
    }
    if (_dominantColor != null && target.populationWeight > 0.0) {
      populationScore = target.populationWeight *
          (paletteColor.population / _dominantColor!.population);
    }

    return saturationScore + valueScore + populationScore;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<PaletteColor>(
        'paletteColors', paletteColors,
        defaultValue: <PaletteColor>[]));
    properties.add(IterableProperty<PaletteTarget>('targets', targets,
        defaultValue: PaletteTarget.baseTargets));
  }
}

class PaletteTarget with Diagnosticable {
  PaletteTarget({
    this.minimumSaturation = 0.0,
    this.targetSaturation = 0.5,
    this.maximumSaturation = 1.0,
    this.minimumLightness = 0.0,
    this.targetLightness = 0.5,
    this.maximumLightness = 1.0,
    this.isExclusive = true,
  });

  final double minimumSaturation;

  final double targetSaturation;

  final double maximumSaturation;

  final double minimumLightness;

  final double targetLightness;

  final double maximumLightness;

  final bool isExclusive;

  double saturationWeight = _weightSaturation;

  double lightnessWeight = _weightLightness;

  double populationWeight = _weightPopulation;

  static const double _targetDarkLightness = 0.26;
  static const double _maxDarkLightness = 0.45;

  static const double _minLightLightness = 0.55;
  static const double _targetLightLightness = 0.74;

  static const double _minNormalLightness = 0.3;
  static const double _targetNormalLightness = 0.5;
  static const double _maxNormalLightness = 0.7;

  static const double _targetMutedSaturation = 0.3;
  static const double _maxMutedSaturation = 0.4;

  static const double _targetVibrantSaturation = 1.0;
  static const double _minVibrantSaturation = 0.35;

  static const double _weightSaturation = 0.24;
  static const double _weightLightness = 0.52;
  static const double _weightPopulation = 0.24;

  static final PaletteTarget lightVibrant = PaletteTarget(
    targetLightness: _targetLightLightness,
    minimumLightness: _minLightLightness,
    minimumSaturation: _minVibrantSaturation,
    targetSaturation: _targetVibrantSaturation,
  );

  static final PaletteTarget vibrant = PaletteTarget(
    minimumLightness: _minNormalLightness,
    targetLightness: _targetNormalLightness,
    maximumLightness: _maxNormalLightness,
    minimumSaturation: _minVibrantSaturation,
    targetSaturation: _targetVibrantSaturation,
  );

  static final PaletteTarget darkVibrant = PaletteTarget(
    targetLightness: _targetDarkLightness,
    maximumLightness: _maxDarkLightness,
    minimumSaturation: _minVibrantSaturation,
    targetSaturation: _targetVibrantSaturation,
  );

  static final PaletteTarget lightMuted = PaletteTarget(
    targetLightness: _targetLightLightness,
    minimumLightness: _minLightLightness,
    targetSaturation: _targetMutedSaturation,
    maximumSaturation: _maxMutedSaturation,
  );

  static final PaletteTarget muted = PaletteTarget(
    minimumLightness: _minNormalLightness,
    targetLightness: _targetNormalLightness,
    maximumLightness: _maxNormalLightness,
    targetSaturation: _targetMutedSaturation,
    maximumSaturation: _maxMutedSaturation,
  );

  static final PaletteTarget darkMuted = PaletteTarget(
    targetLightness: _targetDarkLightness,
    maximumLightness: _maxDarkLightness,
    targetSaturation: _targetMutedSaturation,
    maximumSaturation: _maxMutedSaturation,
  );

  static final List<PaletteTarget> baseTargets = <PaletteTarget>[
    lightVibrant,
    vibrant,
    darkVibrant,
    lightMuted,
    muted,
    darkMuted,
  ];

  void _normalizeWeights() {
    final double sum = saturationWeight + lightnessWeight + populationWeight;
    if (sum != 0.0) {
      saturationWeight /= sum;
      lightnessWeight /= sum;
      populationWeight /= sum;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is PaletteTarget &&
        minimumSaturation == other.minimumSaturation &&
        targetSaturation == other.targetSaturation &&
        maximumSaturation == other.maximumSaturation &&
        minimumLightness == other.minimumLightness &&
        targetLightness == other.targetLightness &&
        maximumLightness == other.maximumLightness &&
        saturationWeight == other.saturationWeight &&
        lightnessWeight == other.lightnessWeight &&
        populationWeight == other.populationWeight;
  }

  @override
  int get hashCode {
    return hashValues(
      minimumSaturation,
      targetSaturation,
      maximumSaturation,
      minimumLightness,
      targetLightness,
      maximumLightness,
      saturationWeight,
      lightnessWeight,
      populationWeight,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final PaletteTarget defaultTarget = PaletteTarget();
    properties.add(DoubleProperty('minimumSaturation', minimumSaturation,
        defaultValue: defaultTarget.minimumSaturation));
    properties.add(DoubleProperty('targetSaturation', targetSaturation,
        defaultValue: defaultTarget.targetSaturation));
    properties.add(DoubleProperty('maximumSaturation', maximumSaturation,
        defaultValue: defaultTarget.maximumSaturation));
    properties.add(DoubleProperty('minimumLightness', minimumLightness,
        defaultValue: defaultTarget.minimumLightness));
    properties.add(DoubleProperty('targetLightness', targetLightness,
        defaultValue: defaultTarget.targetLightness));
    properties.add(DoubleProperty('maximumLightness', maximumLightness,
        defaultValue: defaultTarget.maximumLightness));
    properties.add(DoubleProperty('saturationWeight', saturationWeight,
        defaultValue: defaultTarget.saturationWeight));
    properties.add(DoubleProperty('lightnessWeight', lightnessWeight,
        defaultValue: defaultTarget.lightnessWeight));
    properties.add(DoubleProperty('populationWeight', populationWeight,
        defaultValue: defaultTarget.populationWeight));
  }
}

typedef _ContrastCalculator = double Function(Color a, Color b, int alpha);

class PaletteColor with Diagnosticable {
  PaletteColor(this.color, this.population);

  static const double _minContrastTitleText = 3.0;
  static const double _minContrastBodyText = 4.5;

  final Color color;

  final int population;

  Color get titleTextColor {
    if (_titleTextColor == null) {
      _ensureTextColorsGenerated();
    }
    return _titleTextColor!;
  }

  Color? _titleTextColor;

  Color get bodyTextColor {
    if (_bodyTextColor == null) {
      _ensureTextColorsGenerated();
    }
    return _bodyTextColor!;
  }

  Color? _bodyTextColor;

  void _ensureTextColorsGenerated() {
    if (_titleTextColor == null || _bodyTextColor == null) {
      const Color white = Color(0xffffffff);
      const Color black = Color(0xff000000);

      final int? lightBodyAlpha =
          _calculateMinimumAlpha(white, color, _minContrastBodyText);
      final int? lightTitleAlpha =
          _calculateMinimumAlpha(white, color, _minContrastTitleText);

      if (lightBodyAlpha != null && lightTitleAlpha != null) {
        _bodyTextColor = white.withAlpha(lightBodyAlpha);
        _titleTextColor = white.withAlpha(lightTitleAlpha);
        return;
      }

      final int? darkBodyAlpha =
          _calculateMinimumAlpha(black, color, _minContrastBodyText);
      final int? darkTitleAlpha =
          _calculateMinimumAlpha(black, color, _minContrastTitleText);

      if (darkBodyAlpha != null && darkTitleAlpha != null) {
        _bodyTextColor = black.withAlpha(darkBodyAlpha);
        _titleTextColor = black.withAlpha(darkTitleAlpha);
        return;
      }

      _bodyTextColor = lightBodyAlpha != null
          ? white.withAlpha(lightBodyAlpha)
          : black.withAlpha(darkBodyAlpha ?? 255);
      _titleTextColor = lightTitleAlpha != null
          ? white.withAlpha(lightTitleAlpha)
          : black.withAlpha(darkTitleAlpha ?? 255);
    }
  }

  static double _calculateContrast(Color foreground, Color background) {
    assert(background.alpha == 0xff,
        'background can not be translucent: $background.');
    if (foreground.alpha < 0xff) {
      foreground = Color.alphaBlend(foreground, background);
    }
    final double lightness1 = foreground.computeLuminance() + 0.05;
    final double lightness2 = background.computeLuminance() + 0.05;
    return math.max(lightness1, lightness2) / math.min(lightness1, lightness2);
  }

  static int? _calculateMinimumAlpha(
      Color foreground, Color background, double minContrastRatio) {
    assert(background.alpha == 0xff,
        'The background cannot be translucent: $background.');
    double contrastCalculator(Color fg, Color bg, int alpha) {
      final Color testForeground = fg.withAlpha(alpha);
      return _calculateContrast(testForeground, bg);
    }

    final double testRatio = contrastCalculator(foreground, background, 0xff);
    if (testRatio < minContrastRatio) {
      return null;
    }
    foreground = foreground.withAlpha(0xff);
    return _binaryAlphaSearch(
        foreground, background, minContrastRatio, contrastCalculator);
  }

  static int _binaryAlphaSearch(
    Color foreground,
    Color background,
    double minContrastRatio,
    _ContrastCalculator calculator,
  ) {
    assert(background.alpha == 0xff,
        'The background cannot be translucent: $background.');
    const int minAlphaSearchMaxIterations = 10;
    const int minAlphaSearchPrecision = 1;

    int numIterations = 0;
    int minAlpha = 0;
    int maxAlpha = 0xff;
    while (numIterations <= minAlphaSearchMaxIterations &&
        (maxAlpha - minAlpha) > minAlphaSearchPrecision) {
      final int testAlpha = (minAlpha + maxAlpha) ~/ 2;
      final double testRatio = calculator(foreground, background, testAlpha);
      if (testRatio < minContrastRatio) {
        minAlpha = testAlpha;
      } else {
        maxAlpha = testAlpha;
      }
      numIterations++;
    }

    return maxAlpha;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Color>('color', color));
    properties
        .add(DiagnosticsProperty<Color>('titleTextColor', titleTextColor));
    properties.add(DiagnosticsProperty<Color>('bodyTextColor', bodyTextColor));
    properties.add(IntProperty('population', population, defaultValue: 0));
  }

  @override
  int get hashCode {
    return hashValues(color, population);
  }

  @override
  bool operator ==(Object other) {
    return other is PaletteColor &&
        color == other.color &&
        population == other.population;
  }
}

typedef PaletteFilter = bool Function(HSLColor color);

bool avoidRedBlackWhitePaletteFilter(HSLColor color) {
  bool _isBlack(HSLColor hslColor) {
    const double _blackMaxLightness = 0.05;
    return hslColor.lightness <= _blackMaxLightness;
  }

  bool _isWhite(HSLColor hslColor) {
    const double _whiteMinLightness = 0.95;
    return hslColor.lightness >= _whiteMinLightness;
  }

  bool _isNearRedILine(HSLColor hslColor) {
    const double redLineMinHue = 10.0;
    const double redLineMaxHue = 37.0;
    const double redLineMaxSaturation = 0.82;
    return hslColor.hue >= redLineMinHue &&
        hslColor.hue <= redLineMaxHue &&
        hslColor.saturation <= redLineMaxSaturation;
  }

  return !_isWhite(color) && !_isBlack(color) && !_isNearRedILine(color);
}

enum _ColorComponent {
  red,
  green,
  blue,
}

class _ColorVolumeBox {
  _ColorVolumeBox(
      this._lowerIndex, this._upperIndex, this.histogram, this.colors) {
    _fitMinimumBox();
  }

  final _ColorHistogram histogram;
  final List<Color> colors;

  final int _lowerIndex;
  int _upperIndex;

  late int _population;

  late int _minRed;
  late int _maxRed;
  late int _minGreen;
  late int _maxGreen;
  late int _minBlue;
  late int _maxBlue;

  int getVolume() {
    return (_maxRed - _minRed + 1) *
        (_maxGreen - _minGreen + 1) *
        (_maxBlue - _minBlue + 1);
  }

  bool canSplit() {
    return getColorCount() > 1;
  }

  int getColorCount() {
    return 1 + _upperIndex - _lowerIndex;
  }

  void _fitMinimumBox() {
    int minRed = 256;
    int minGreen = 256;
    int minBlue = 256;
    int maxRed = -1;
    int maxGreen = -1;
    int maxBlue = -1;
    int count = 0;
    for (int i = _lowerIndex; i <= _upperIndex; i++) {
      final Color color = colors[i];
      count += histogram[color]!.value;
      if (color.red > maxRed) {
        maxRed = color.red;
      }
      if (color.red < minRed) {
        minRed = color.red;
      }
      if (color.green > maxGreen) {
        maxGreen = color.green;
      }
      if (color.green < minGreen) {
        minGreen = color.green;
      }
      if (color.blue > maxBlue) {
        maxBlue = color.blue;
      }
      if (color.blue < minBlue) {
        minBlue = color.blue;
      }
    }
    _minRed = minRed;
    _maxRed = maxRed;
    _minGreen = minGreen;
    _maxGreen = maxGreen;
    _minBlue = minBlue;
    _maxBlue = maxBlue;
    _population = count;
  }

  _ColorVolumeBox splitBox() {
    assert(canSplit(), "Can't split a box with only 1 color");

    final int splitPoint = _findSplitPoint();
    final _ColorVolumeBox newBox =
        _ColorVolumeBox(splitPoint + 1, _upperIndex, histogram, colors);

    _upperIndex = splitPoint;
    _fitMinimumBox();
    return newBox;
  }

  _ColorComponent _getLongestColorDimension() {
    final int redLength = _maxRed - _minRed;
    final int greenLength = _maxGreen - _minGreen;
    final int blueLength = _maxBlue - _minBlue;
    if (redLength >= greenLength && redLength >= blueLength) {
      return _ColorComponent.red;
    } else if (greenLength >= redLength && greenLength >= blueLength) {
      return _ColorComponent.green;
    } else {
      return _ColorComponent.blue;
    }
  }

  int _findSplitPoint() {
    final _ColorComponent longestDimension = _getLongestColorDimension();
    int compareColors(Color a, Color b) {
      int makeValue(int first, int second, int third) {
        return first << 16 | second << 8 | third;
      }

      switch (longestDimension) {
        case _ColorComponent.red:
          final int aValue = makeValue(a.red, a.green, a.blue);
          final int bValue = makeValue(b.red, b.green, b.blue);
          return aValue.compareTo(bValue);
        case _ColorComponent.green:
          final int aValue = makeValue(a.green, a.red, a.blue);
          final int bValue = makeValue(b.green, b.red, b.blue);
          return aValue.compareTo(bValue);
        case _ColorComponent.blue:
          final int aValue = makeValue(a.blue, a.green, a.red);
          final int bValue = makeValue(b.blue, b.green, b.red);
          return aValue.compareTo(bValue);
      }
    }

    final List<Color> colorSubset =
        colors.sublist(_lowerIndex, _upperIndex + 1);
    colorSubset.sort(compareColors);
    colors.replaceRange(_lowerIndex, _upperIndex + 1, colorSubset);
    final int median = (_population / 2).round();
    for (int i = 0, count = 0; i <= colorSubset.length; i++) {
      count += histogram[colorSubset[i]]!.value;
      if (count >= median) {
        return math.min(_upperIndex - 1, i + _lowerIndex);
      }
    }
    return _lowerIndex;
  }

  PaletteColor getAverageColor() {
    int redSum = 0;
    int greenSum = 0;
    int blueSum = 0;
    int totalPopulation = 0;
    for (int i = _lowerIndex; i <= _upperIndex; i++) {
      final Color color = colors[i];
      final int colorPopulation = histogram[color]!.value;
      totalPopulation += colorPopulation;
      redSum += colorPopulation * color.red;
      greenSum += colorPopulation * color.green;
      blueSum += colorPopulation * color.blue;
    }
    final int redMean = (redSum / totalPopulation).round();
    final int greenMean = (greenSum / totalPopulation).round();
    final int blueMean = (blueSum / totalPopulation).round();
    return PaletteColor(
      Color.fromARGB(0xff, redMean, greenMean, blueMean),
      totalPopulation,
    );
  }
}

class _ColorCount {
  int value = 0;
}

class _ColorHistogram {
  final Map<int, Map<int, Map<int, _ColorCount>>> _hist =
      <int, Map<int, Map<int, _ColorCount>>>{};
  final DoubleLinkedQueue<Color> _keys = DoubleLinkedQueue<Color>();

  _ColorCount? operator [](Color color) {
    final Map<int, Map<int, _ColorCount>>? redMap = _hist[color.red];
    if (redMap == null) {
      return null;
    }
    final Map<int, _ColorCount>? blueMap = redMap[color.blue];
    if (blueMap == null) {
      return null;
    }
    return blueMap[color.green];
  }

  void operator []=(Color key, _ColorCount value) {
    final int red = key.red;
    final int blue = key.blue;
    final int green = key.green;

    bool newColor = false;

    Map<int, Map<int, _ColorCount>>? redMap = _hist[red];
    if (redMap == null) {
      _hist[red] = redMap = <int, Map<int, _ColorCount>>{};
      newColor = true;
    }

    Map<int, _ColorCount>? blueMap = redMap[blue];
    if (blueMap == null) {
      redMap[blue] = blueMap = <int, _ColorCount>{};
      newColor = true;
    }

    if (blueMap[green] == null) {
      newColor = true;
    }
    blueMap[green] = value;

    if (newColor) {
      _keys.add(key);
    }
  }

  void removeWhere(bool Function(Color key) predicate) {
    for (final Color key in _keys) {
      if (predicate(key)) {
        _hist[key.red]?[key.blue]?.remove(key.green);
      }
    }
    _keys.removeWhere((Color color) => predicate(color));
  }

  Iterable<Color> get keys {
    return _keys;
  }

  int get length {
    return _keys.length;
  }
}

class _ColorCutQuantizer {
  _ColorCutQuantizer(
    this.encodedImage, {
    this.maxColors = PaletteGenerator._defaultCalculateNumberColors,
    this.region,
    this.filters = const <PaletteFilter>[avoidRedBlackWhitePaletteFilter],
  }) : assert(region == null || region != Rect.zero);

  final EncodedImage encodedImage;
  final int maxColors;
  final Rect? region;
  final List<PaletteFilter> filters;

  Completer<List<PaletteColor>>? _paletteColorsCompleter;
  FutureOr<List<PaletteColor>> get quantizedColors async {
    if (_paletteColorsCompleter == null) {
      _paletteColorsCompleter = Completer<List<PaletteColor>>();
      _paletteColorsCompleter!.complete(_quantizeColors());
    }
    return _paletteColorsCompleter!.future;
  }

  Iterable<Color> _getImagePixels(ByteData pixels, int width, int height,
      {Rect? region}) sync* {
    final int rowStride = width * 4;
    int rowStart;
    int rowEnd;
    int colStart;
    int colEnd;
    if (region != null) {
      rowStart = region.top.floor();
      rowEnd = region.bottom.floor();
      colStart = region.left.floor();
      colEnd = region.right.floor();
      assert(rowStart >= 0);
      assert(rowEnd <= height);
      assert(colStart >= 0);
      assert(colEnd <= width);
    } else {
      rowStart = 0;
      rowEnd = height;
      colStart = 0;
      colEnd = width;
    }
    int byteCount = 0;
    for (int row = rowStart; row < rowEnd; ++row) {
      for (int col = colStart; col < colEnd; ++col) {
        final int position = row * rowStride + col * 4;

        final int pixel = pixels.getUint32(position);
        final Color result = Color((pixel << 24) | (pixel >> 8));
        byteCount += 4;
        yield result;
      }
    }
    assert(byteCount == ((rowEnd - rowStart) * (colEnd - colStart) * 4));
  }

  bool _shouldIgnoreColor(Color color) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    if (filters.isNotEmpty) {
      for (final PaletteFilter filter in filters) {
        if (!filter(hslColor)) {
          return true;
        }
      }
    }
    return false;
  }

  List<PaletteColor> _quantizeColors() {
    const int quantizeWordWidth = 5;
    const int quantizeChannelWidth = 8;
    const int quantizeShift = quantizeChannelWidth - quantizeWordWidth;
    const int quantizeWordMask =
        ((1 << quantizeWordWidth) - 1) << quantizeShift;

    Color quantizeColor(Color color) {
      return Color.fromARGB(
        color.alpha,
        color.red & quantizeWordMask,
        color.green & quantizeWordMask,
        color.blue & quantizeWordMask,
      );
    }

    final List<PaletteColor> paletteColors = <PaletteColor>[];
    final Iterable<Color> pixels = _getImagePixels(
      encodedImage.byteData,
      encodedImage.width,
      encodedImage.height,
      region: region,
    );
    final _ColorHistogram hist = _ColorHistogram();
    Color? currentColor;
    _ColorCount? currentColorCount;

    for (final Color pixel in pixels) {
      final Color quantizedColor = quantizeColor(pixel);
      final Color colorKey = quantizedColor.withAlpha(0xff);

      if (quantizedColor.alpha == 0x0) {
        continue;
      }
      if (currentColor != colorKey) {
        currentColor = colorKey;
        currentColorCount = hist[colorKey];
        if (currentColorCount == null) {
          hist[colorKey] = currentColorCount = _ColorCount();
        }
      }
      currentColorCount!.value = currentColorCount.value + 1;
    }

    hist.removeWhere((Color color) {
      return _shouldIgnoreColor(color);
    });
    if (hist.length <= maxColors) {
      paletteColors.clear();
      for (final Color color in hist.keys) {
        paletteColors.add(PaletteColor(color, hist[color]!.value));
      }
    } else {
      paletteColors.clear();
      paletteColors.addAll(_quantizePixels(maxColors, hist));
    }
    return paletteColors;
  }

  List<PaletteColor> _quantizePixels(
    int maxColors,
    _ColorHistogram histogram,
  ) {
    int volumeComparator(_ColorVolumeBox a, _ColorVolumeBox b) {
      return b.getVolume().compareTo(a.getVolume());
    }

    final PriorityQueue<_ColorVolumeBox> priorityQueue =
        HeapPriorityQueue<_ColorVolumeBox>(volumeComparator);

    priorityQueue.add(_ColorVolumeBox(
        0, histogram.length - 1, histogram, histogram.keys.toList()));

    _splitBoxes(priorityQueue, maxColors);

    return _generateAverageColors(priorityQueue);
  }

  void _splitBoxes(PriorityQueue<_ColorVolumeBox> queue, final int maxSize) {
    while (queue.length < maxSize) {
      final _ColorVolumeBox colorVolumeBox = queue.removeFirst();
      if (colorVolumeBox.canSplit()) {
        queue.add(colorVolumeBox.splitBox());

        queue.add(colorVolumeBox);
      } else {
        return;
      }
    }
  }

  List<PaletteColor> _generateAverageColors(
      PriorityQueue<_ColorVolumeBox> colorVolumeBoxes) {
    final List<PaletteColor> colors = <PaletteColor>[];
    for (final _ColorVolumeBox colorVolumeBox in colorVolumeBoxes.toList()) {
      final PaletteColor paletteColor = colorVolumeBox.getAverageColor();
      if (!_shouldIgnoreColor(paletteColor.color)) {
        colors.add(paletteColor);
      }
    }
    return colors;
  }
}
