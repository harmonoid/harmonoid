import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/models/replaygain.dart';

/// Mappers for [ReplayGain].
extension ReplayGainMappers on ReplayGain {
  /// Converts to property.
  String toProperty() => switch (this) {
        ReplayGain.off => 'no',
        ReplayGain.track => 'track',
        ReplayGain.album => 'album',
      };

  String toLabel() => switch (this) {
        ReplayGain.off => Localization.instance.OFF,
        ReplayGain.track => Localization.instance.TRACK,
        ReplayGain.album => Localization.instance.ALBUM,
      };
}
