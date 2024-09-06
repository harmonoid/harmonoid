import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:harmonoid/core/media_library.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/settings/settings_section.dart';
import 'package:harmonoid/utils/rendering.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: Localization.instance.SETTINGS_SECTION_STATS_TITLE,
      subtitle: Localization.instance.SETTINGS_SECTION_STATS_SUBTITLE,
      children: [
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Consumer<MediaLibrary>(
            builder: (context, mediaLibrary, _) {
              return DataTable(
                headingRowHeight: 48.0,
                dataRowMinHeight: 48.0,
                dataRowMaxHeight: 48.0,
                columnSpacing: 0.0,
                horizontalMargin: 16.0,
                dividerThickness: 1.0,
                columns: [
                  const DataColumn(label: SizedBox(width: 32.0)),
                  DataColumn(label: Text(Localization.instance.TYPE)),
                  DataColumn(label: Text(Localization.instance.COUNT)),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: 32.0,
                          height: 32.0,
                          alignment: Alignment.center,
                          child: const Icon(Icons.music_note),
                        ),
                      ),
                      DataCell(Text(Localization.instance.TRACKS)),
                      DataCell(Text(mediaLibrary.tracks.length.toString())),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: 32.0,
                          height: 32.0,
                          alignment: Alignment.center,
                          child: const Icon(Icons.album),
                        ),
                      ),
                      DataCell(Text(Localization.instance.ALBUMS)),
                      DataCell(Text(mediaLibrary.albums.length.toString())),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: 32.0,
                          height: 32.0,
                          alignment: Alignment.center,
                          child: const Icon(Icons.person),
                        ),
                      ),
                      DataCell(Text(Localization.instance.ARTISTS)),
                      DataCell(Text(mediaLibrary.artists.length.toString())),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: 32.0,
                          height: 32.0,
                          alignment: Alignment.center,
                          child: const Icon(Icons.piano),
                        ),
                      ),
                      DataCell(Text(Localization.instance.GENRES)),
                      DataCell(Text(mediaLibrary.genres.length.toString())),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        if (isMobile) const SizedBox(height: 16.0),
      ],
    );
  }
}
