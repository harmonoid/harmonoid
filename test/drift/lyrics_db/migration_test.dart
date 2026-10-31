// ignore_for_file: unused_import
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:harmonoid/state/lyrics/database/database.dart';
import 'package:harmonoid/state/lyrics/models/lyrics_key.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUp(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('lyrics-db-migration', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final dir = await Directory.systemTemp.createTemp('lyrics_db_migration_');
            try {
              final schema = await verifier.schemaAt(fromVersion);
              final db = LyricsDatabase(dir, schema.newConnection());
              await verifier.migrateAndValidate(db, toVersion);
              await db.close();
            } finally {
              await dir.delete(recursive: true);
            }
          });
        }
      });
    }
  });

  test('lyrics-db-migration-v1-to-v2', () async {
    const oldLyrics = '[{"timestamp":0,"text":"Old"}]';
    const newLyrics = '[{"timestamp":0,"text":"New"}]';
    const oldTranslation = '[{"timestamp":0,"text":"पुराना"}]';
    const newTranslation = '[{"timestamp":0,"text":"नया"}]';

    // Duplicate entries across durations collapse, keeping the last entry.
    final oldLyricssData = <v1.LyricssData>[
      const v1.LyricssData(track: 'Track', artist: 'Artist', duration: 100000, lyrics: oldLyrics),
      const v1.LyricssData(track: 'Track', artist: 'Artist', duration: 200000, lyrics: newLyrics),
    ];
    final expectedNewLyricssData = <v2.LyricssData>[
      const v2.LyricssData(track: 'Track', artist: 'Artist', lyrics: newLyrics),
    ];

    final oldTranslationsData = <v1.LyricsTranslationsData>[
      const v1.LyricsTranslationsData(track: 'Track', artist: 'Artist', duration: 100000, language: 'hi', lyrics: oldTranslation, same: 0),
      const v1.LyricsTranslationsData(track: 'Track', artist: 'Artist', duration: 200000, language: 'hi', lyrics: newTranslation, same: 0),
    ];
    final expectedNewTranslationsData = <v2.LyricsTranslationsData>[
      const v2.LyricsTranslationsData(track: 'Track', artist: 'Artist', language: 'hi', lyrics: newTranslation, same: 0),
    ];

    final dir = await Directory.systemTemp.createTemp('lyrics_db_migration_');
    try {
      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: (connection) => LyricsDatabase(dir, connection),
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.lyricss, oldLyricssData);
          batch.insertAll(oldDb.lyricsTranslations, oldTranslationsData);
        },
        validateItems: (newDb) async {
          expect(await newDb.select(newDb.lyricss).get(), expectedNewLyricssData);
          expect(await newDb.select(newDb.lyricsTranslations).get(), expectedNewTranslationsData);
          // The per-track settings table is new in v2, so it migrates empty.
          expect(await newDb.select(newDb.lyricsTrackSettings).get(), isEmpty);
        },
      );
    } finally {
      await dir.delete(recursive: true);
    }
  });

}
