import 'package:flutter/widgets.dart';

import 'package:harmonoid/core/configuration/configuration.dart';
import 'package:harmonoid/features/media_library/tracks/models/track_view_type.dart';

class TracksNotifier extends ChangeNotifier {
  TracksNotifier();

  TrackViewType viewType = Configuration.instance.mediaLibraryTrackViewType;

  void setViewType(TrackViewType value) {
    viewType = value;
    notifyListeners();
    Configuration.instance.set(mediaLibraryTrackViewType: value);
  }

  void toggleViewType() {
    setViewType(TrackViewType.values[(viewType.index + 1) % TrackViewType.values.length]);
  }
}
