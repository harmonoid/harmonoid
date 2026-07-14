import 'package:flutter/material.dart';

import 'package:harmonoid/features/media_library/tracks/models/track_view_type.dart';
import 'package:harmonoid/localization/localization.dart';

/// Mappers for [TrackViewType].
extension TrackViewTypeMappers on TrackViewType {
  /// Converts to toggle icon.
  IconData toToggleIcon() => switch (this) {
    TrackViewType.list => Icons.grid_view,
    TrackViewType.grid => Icons.list,
  };

  /// Converts to toggle label.
  String toToggleLabel() => switch (this) {
    TrackViewType.list => Localization.instance.GRID,
    TrackViewType.grid => Localization.instance.LIST,
  };
}
