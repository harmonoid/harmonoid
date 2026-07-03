// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LyricssTable extends Lyricss
    with TableInfo<$LyricssTable, LyricsEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricssTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<String> track = GeneratedColumn<String>(
    'track',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Lyrics, String> lyrics =
      GeneratedColumn<String>(
        'lyrics',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Lyrics>($LyricssTable.$converterlyrics);
  @override
  List<GeneratedColumn> get $columns => [track, artist, duration, lyrics];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyricss';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    } else if (isInserting) {
      context.missing(_trackMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {track, artist, duration};
  @override
  LyricsEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsEntity(
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      lyrics: $LyricssTable.$converterlyrics.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}lyrics'],
        )!,
      ),
    );
  }

  @override
  $LyricssTable createAlias(String alias) {
    return $LyricssTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Lyrics, String, String> $converterlyrics =
      const LyricsConverter();
}

class LyricsEntity extends DataClass implements Insertable<LyricsEntity> {
  /// Track title.
  final String track;

  /// Track artist.
  final String artist;

  /// Track duration (in milliseconds).
  final int duration;

  /// Lyrics.
  final Lyrics lyrics;
  const LyricsEntity({
    required this.track,
    required this.artist,
    required this.duration,
    required this.lyrics,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track'] = Variable<String>(track);
    map['artist'] = Variable<String>(artist);
    map['duration'] = Variable<int>(duration);
    {
      map['lyrics'] = Variable<String>(
        $LyricssTable.$converterlyrics.toSql(lyrics),
      );
    }
    return map;
  }

  LyricssCompanion toCompanion(bool nullToAbsent) {
    return LyricssCompanion(
      track: Value(track),
      artist: Value(artist),
      duration: Value(duration),
      lyrics: Value(lyrics),
    );
  }

  factory LyricsEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsEntity(
      track: serializer.fromJson<String>(json['track']),
      artist: serializer.fromJson<String>(json['artist']),
      duration: serializer.fromJson<int>(json['duration']),
      lyrics: $LyricssTable.$converterlyrics.fromJson(
        serializer.fromJson<String>(json['lyrics']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'track': serializer.toJson<String>(track),
      'artist': serializer.toJson<String>(artist),
      'duration': serializer.toJson<int>(duration),
      'lyrics': serializer.toJson<String>(
        $LyricssTable.$converterlyrics.toJson(lyrics),
      ),
    };
  }

  LyricsEntity copyWith({
    String? track,
    String? artist,
    int? duration,
    Lyrics? lyrics,
  }) => LyricsEntity(
    track: track ?? this.track,
    artist: artist ?? this.artist,
    duration: duration ?? this.duration,
    lyrics: lyrics ?? this.lyrics,
  );
  LyricsEntity copyWithCompanion(LyricssCompanion data) {
    return LyricsEntity(
      track: data.track.present ? data.track.value : this.track,
      artist: data.artist.present ? data.artist.value : this.artist,
      duration: data.duration.present ? data.duration.value : this.duration,
      lyrics: data.lyrics.present ? data.lyrics.value : this.lyrics,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsEntity(')
          ..write('track: $track, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('lyrics: $lyrics')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(track, artist, duration, lyrics);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsEntity &&
          other.track == this.track &&
          other.artist == this.artist &&
          other.duration == this.duration &&
          other.lyrics == this.lyrics);
}

class LyricssCompanion extends UpdateCompanion<LyricsEntity> {
  final Value<String> track;
  final Value<String> artist;
  final Value<int> duration;
  final Value<Lyrics> lyrics;
  final Value<int> rowid;
  const LyricssCompanion({
    this.track = const Value.absent(),
    this.artist = const Value.absent(),
    this.duration = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LyricssCompanion.insert({
    required String track,
    required String artist,
    required int duration,
    required Lyrics lyrics,
    this.rowid = const Value.absent(),
  }) : track = Value(track),
       artist = Value(artist),
       duration = Value(duration),
       lyrics = Value(lyrics);
  static Insertable<LyricsEntity> custom({
    Expression<String>? track,
    Expression<String>? artist,
    Expression<int>? duration,
    Expression<String>? lyrics,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (track != null) 'track': track,
      if (artist != null) 'artist': artist,
      if (duration != null) 'duration': duration,
      if (lyrics != null) 'lyrics': lyrics,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LyricssCompanion copyWith({
    Value<String>? track,
    Value<String>? artist,
    Value<int>? duration,
    Value<Lyrics>? lyrics,
    Value<int>? rowid,
  }) {
    return LyricssCompanion(
      track: track ?? this.track,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      lyrics: lyrics ?? this.lyrics,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (track.present) {
      map['track'] = Variable<String>(track.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (lyrics.present) {
      map['lyrics'] = Variable<String>(
        $LyricssTable.$converterlyrics.toSql(lyrics.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricssCompanion(')
          ..write('track: $track, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('lyrics: $lyrics, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LyricsTranslationsTable extends LyricsTranslations
    with TableInfo<$LyricsTranslationsTable, LyricsTranslationEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsTranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<String> track = GeneratedColumn<String>(
    'track',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Lyrics?, String> lyrics =
      GeneratedColumn<String>(
        'lyrics',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Lyrics?>($LyricsTranslationsTable.$converterlyricsn);
  static const VerificationMeta _sameMeta = const VerificationMeta('same');
  @override
  late final GeneratedColumn<bool> same = GeneratedColumn<bool>(
    'same',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("same" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    track,
    artist,
    duration,
    language,
    lyrics,
    same,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics_translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsTranslationEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track')) {
      context.handle(
        _trackMeta,
        track.isAcceptableOrUnknown(data['track']!, _trackMeta),
      );
    } else if (isInserting) {
      context.missing(_trackMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('same')) {
      context.handle(
        _sameMeta,
        same.isAcceptableOrUnknown(data['same']!, _sameMeta),
      );
    } else if (isInserting) {
      context.missing(_sameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {track, artist, duration, language};
  @override
  LyricsTranslationEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsTranslationEntity(
      track: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      lyrics: $LyricsTranslationsTable.$converterlyricsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}lyrics'],
        ),
      ),
      same: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}same'],
      )!,
    );
  }

  @override
  $LyricsTranslationsTable createAlias(String alias) {
    return $LyricsTranslationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Lyrics, String, String> $converterlyrics =
      const LyricsConverter();
  static JsonTypeConverter2<Lyrics?, String?, String?> $converterlyricsn =
      JsonTypeConverter2.asNullable($converterlyrics);
}

class LyricsTranslationEntity extends DataClass
    implements Insertable<LyricsTranslationEntity> {
  /// Track title.
  final String track;

  /// Track artist.
  final String artist;

  /// Track duration (in milliseconds).
  final int duration;

  /// Target language code.
  final String language;

  /// Translated lyrics. Null when [same] is true.
  final Lyrics? lyrics;

  /// Whether the target language is the same as the source lyrics language.
  final bool same;
  const LyricsTranslationEntity({
    required this.track,
    required this.artist,
    required this.duration,
    required this.language,
    this.lyrics,
    required this.same,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track'] = Variable<String>(track);
    map['artist'] = Variable<String>(artist);
    map['duration'] = Variable<int>(duration);
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || lyrics != null) {
      map['lyrics'] = Variable<String>(
        $LyricsTranslationsTable.$converterlyricsn.toSql(lyrics),
      );
    }
    map['same'] = Variable<bool>(same);
    return map;
  }

  LyricsTranslationsCompanion toCompanion(bool nullToAbsent) {
    return LyricsTranslationsCompanion(
      track: Value(track),
      artist: Value(artist),
      duration: Value(duration),
      language: Value(language),
      lyrics: lyrics == null && nullToAbsent
          ? const Value.absent()
          : Value(lyrics),
      same: Value(same),
    );
  }

  factory LyricsTranslationEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsTranslationEntity(
      track: serializer.fromJson<String>(json['track']),
      artist: serializer.fromJson<String>(json['artist']),
      duration: serializer.fromJson<int>(json['duration']),
      language: serializer.fromJson<String>(json['language']),
      lyrics: $LyricsTranslationsTable.$converterlyricsn.fromJson(
        serializer.fromJson<String?>(json['lyrics']),
      ),
      same: serializer.fromJson<bool>(json['same']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'track': serializer.toJson<String>(track),
      'artist': serializer.toJson<String>(artist),
      'duration': serializer.toJson<int>(duration),
      'language': serializer.toJson<String>(language),
      'lyrics': serializer.toJson<String?>(
        $LyricsTranslationsTable.$converterlyricsn.toJson(lyrics),
      ),
      'same': serializer.toJson<bool>(same),
    };
  }

  LyricsTranslationEntity copyWith({
    String? track,
    String? artist,
    int? duration,
    String? language,
    Value<Lyrics?> lyrics = const Value.absent(),
    bool? same,
  }) => LyricsTranslationEntity(
    track: track ?? this.track,
    artist: artist ?? this.artist,
    duration: duration ?? this.duration,
    language: language ?? this.language,
    lyrics: lyrics.present ? lyrics.value : this.lyrics,
    same: same ?? this.same,
  );
  LyricsTranslationEntity copyWithCompanion(LyricsTranslationsCompanion data) {
    return LyricsTranslationEntity(
      track: data.track.present ? data.track.value : this.track,
      artist: data.artist.present ? data.artist.value : this.artist,
      duration: data.duration.present ? data.duration.value : this.duration,
      language: data.language.present ? data.language.value : this.language,
      lyrics: data.lyrics.present ? data.lyrics.value : this.lyrics,
      same: data.same.present ? data.same.value : this.same,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsTranslationEntity(')
          ..write('track: $track, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('language: $language, ')
          ..write('lyrics: $lyrics, ')
          ..write('same: $same')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(track, artist, duration, language, lyrics, same);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsTranslationEntity &&
          other.track == this.track &&
          other.artist == this.artist &&
          other.duration == this.duration &&
          other.language == this.language &&
          other.lyrics == this.lyrics &&
          other.same == this.same);
}

class LyricsTranslationsCompanion
    extends UpdateCompanion<LyricsTranslationEntity> {
  final Value<String> track;
  final Value<String> artist;
  final Value<int> duration;
  final Value<String> language;
  final Value<Lyrics?> lyrics;
  final Value<bool> same;
  final Value<int> rowid;
  const LyricsTranslationsCompanion({
    this.track = const Value.absent(),
    this.artist = const Value.absent(),
    this.duration = const Value.absent(),
    this.language = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.same = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LyricsTranslationsCompanion.insert({
    required String track,
    required String artist,
    required int duration,
    required String language,
    this.lyrics = const Value.absent(),
    required bool same,
    this.rowid = const Value.absent(),
  }) : track = Value(track),
       artist = Value(artist),
       duration = Value(duration),
       language = Value(language),
       same = Value(same);
  static Insertable<LyricsTranslationEntity> custom({
    Expression<String>? track,
    Expression<String>? artist,
    Expression<int>? duration,
    Expression<String>? language,
    Expression<String>? lyrics,
    Expression<bool>? same,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (track != null) 'track': track,
      if (artist != null) 'artist': artist,
      if (duration != null) 'duration': duration,
      if (language != null) 'language': language,
      if (lyrics != null) 'lyrics': lyrics,
      if (same != null) 'same': same,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LyricsTranslationsCompanion copyWith({
    Value<String>? track,
    Value<String>? artist,
    Value<int>? duration,
    Value<String>? language,
    Value<Lyrics?>? lyrics,
    Value<bool>? same,
    Value<int>? rowid,
  }) {
    return LyricsTranslationsCompanion(
      track: track ?? this.track,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      lyrics: lyrics ?? this.lyrics,
      same: same ?? this.same,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (track.present) {
      map['track'] = Variable<String>(track.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (lyrics.present) {
      map['lyrics'] = Variable<String>(
        $LyricsTranslationsTable.$converterlyricsn.toSql(lyrics.value),
      );
    }
    if (same.present) {
      map['same'] = Variable<bool>(same.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricsTranslationsCompanion(')
          ..write('track: $track, ')
          ..write('artist: $artist, ')
          ..write('duration: $duration, ')
          ..write('language: $language, ')
          ..write('lyrics: $lyrics, ')
          ..write('same: $same, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LyricsDatabase extends GeneratedDatabase {
  _$LyricsDatabase(QueryExecutor e) : super(e);
  $LyricsDatabaseManager get managers => $LyricsDatabaseManager(this);
  late final $LyricssTable lyricss = $LyricssTable(this);
  late final $LyricsTranslationsTable lyricsTranslations =
      $LyricsTranslationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lyricss,
    lyricsTranslations,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$LyricssTableCreateCompanionBuilder =
    LyricssCompanion Function({
      required String track,
      required String artist,
      required int duration,
      required Lyrics lyrics,
      Value<int> rowid,
    });
typedef $$LyricssTableUpdateCompanionBuilder =
    LyricssCompanion Function({
      Value<String> track,
      Value<String> artist,
      Value<int> duration,
      Value<Lyrics> lyrics,
      Value<int> rowid,
    });

class $$LyricssTableFilterComposer
    extends Composer<_$LyricsDatabase, $LyricssTable> {
  $$LyricssTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Lyrics, Lyrics, String> get lyrics =>
      $composableBuilder(
        column: $table.lyrics,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$LyricssTableOrderingComposer
    extends Composer<_$LyricsDatabase, $LyricssTable> {
  $$LyricssTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LyricssTableAnnotationComposer
    extends Composer<_$LyricsDatabase, $LyricssTable> {
  $$LyricssTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Lyrics, String> get lyrics =>
      $composableBuilder(column: $table.lyrics, builder: (column) => column);
}

class $$LyricssTableTableManager
    extends
        RootTableManager<
          _$LyricsDatabase,
          $LyricssTable,
          LyricsEntity,
          $$LyricssTableFilterComposer,
          $$LyricssTableOrderingComposer,
          $$LyricssTableAnnotationComposer,
          $$LyricssTableCreateCompanionBuilder,
          $$LyricssTableUpdateCompanionBuilder,
          (
            LyricsEntity,
            BaseReferences<_$LyricsDatabase, $LyricssTable, LyricsEntity>,
          ),
          LyricsEntity,
          PrefetchHooks Function()
        > {
  $$LyricssTableTableManager(_$LyricsDatabase db, $LyricssTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricssTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LyricssTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LyricssTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> track = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<Lyrics> lyrics = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricssCompanion(
                track: track,
                artist: artist,
                duration: duration,
                lyrics: lyrics,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String track,
                required String artist,
                required int duration,
                required Lyrics lyrics,
                Value<int> rowid = const Value.absent(),
              }) => LyricssCompanion.insert(
                track: track,
                artist: artist,
                duration: duration,
                lyrics: lyrics,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LyricssTableProcessedTableManager =
    ProcessedTableManager<
      _$LyricsDatabase,
      $LyricssTable,
      LyricsEntity,
      $$LyricssTableFilterComposer,
      $$LyricssTableOrderingComposer,
      $$LyricssTableAnnotationComposer,
      $$LyricssTableCreateCompanionBuilder,
      $$LyricssTableUpdateCompanionBuilder,
      (
        LyricsEntity,
        BaseReferences<_$LyricsDatabase, $LyricssTable, LyricsEntity>,
      ),
      LyricsEntity,
      PrefetchHooks Function()
    >;
typedef $$LyricsTranslationsTableCreateCompanionBuilder =
    LyricsTranslationsCompanion Function({
      required String track,
      required String artist,
      required int duration,
      required String language,
      Value<Lyrics?> lyrics,
      required bool same,
      Value<int> rowid,
    });
typedef $$LyricsTranslationsTableUpdateCompanionBuilder =
    LyricsTranslationsCompanion Function({
      Value<String> track,
      Value<String> artist,
      Value<int> duration,
      Value<String> language,
      Value<Lyrics?> lyrics,
      Value<bool> same,
      Value<int> rowid,
    });

class $$LyricsTranslationsTableFilterComposer
    extends Composer<_$LyricsDatabase, $LyricsTranslationsTable> {
  $$LyricsTranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Lyrics?, Lyrics, String> get lyrics =>
      $composableBuilder(
        column: $table.lyrics,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get same => $composableBuilder(
    column: $table.same,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LyricsTranslationsTableOrderingComposer
    extends Composer<_$LyricsDatabase, $LyricsTranslationsTable> {
  $$LyricsTranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get track => $composableBuilder(
    column: $table.track,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get same => $composableBuilder(
    column: $table.same,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LyricsTranslationsTableAnnotationComposer
    extends Composer<_$LyricsDatabase, $LyricsTranslationsTable> {
  $$LyricsTranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Lyrics?, String> get lyrics =>
      $composableBuilder(column: $table.lyrics, builder: (column) => column);

  GeneratedColumn<bool> get same =>
      $composableBuilder(column: $table.same, builder: (column) => column);
}

class $$LyricsTranslationsTableTableManager
    extends
        RootTableManager<
          _$LyricsDatabase,
          $LyricsTranslationsTable,
          LyricsTranslationEntity,
          $$LyricsTranslationsTableFilterComposer,
          $$LyricsTranslationsTableOrderingComposer,
          $$LyricsTranslationsTableAnnotationComposer,
          $$LyricsTranslationsTableCreateCompanionBuilder,
          $$LyricsTranslationsTableUpdateCompanionBuilder,
          (
            LyricsTranslationEntity,
            BaseReferences<
              _$LyricsDatabase,
              $LyricsTranslationsTable,
              LyricsTranslationEntity
            >,
          ),
          LyricsTranslationEntity,
          PrefetchHooks Function()
        > {
  $$LyricsTranslationsTableTableManager(
    _$LyricsDatabase db,
    $LyricsTranslationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsTranslationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LyricsTranslationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LyricsTranslationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> track = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<Lyrics?> lyrics = const Value.absent(),
                Value<bool> same = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricsTranslationsCompanion(
                track: track,
                artist: artist,
                duration: duration,
                language: language,
                lyrics: lyrics,
                same: same,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String track,
                required String artist,
                required int duration,
                required String language,
                Value<Lyrics?> lyrics = const Value.absent(),
                required bool same,
                Value<int> rowid = const Value.absent(),
              }) => LyricsTranslationsCompanion.insert(
                track: track,
                artist: artist,
                duration: duration,
                language: language,
                lyrics: lyrics,
                same: same,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LyricsTranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$LyricsDatabase,
      $LyricsTranslationsTable,
      LyricsTranslationEntity,
      $$LyricsTranslationsTableFilterComposer,
      $$LyricsTranslationsTableOrderingComposer,
      $$LyricsTranslationsTableAnnotationComposer,
      $$LyricsTranslationsTableCreateCompanionBuilder,
      $$LyricsTranslationsTableUpdateCompanionBuilder,
      (
        LyricsTranslationEntity,
        BaseReferences<
          _$LyricsDatabase,
          $LyricsTranslationsTable,
          LyricsTranslationEntity
        >,
      ),
      LyricsTranslationEntity,
      PrefetchHooks Function()
    >;

class $LyricsDatabaseManager {
  final _$LyricsDatabase _db;
  $LyricsDatabaseManager(this._db);
  $$LyricssTableTableManager get lyricss =>
      $$LyricssTableTableManager(_db, _db.lyricss);
  $$LyricsTranslationsTableTableManager get lyricsTranslations =>
      $$LyricsTranslationsTableTableManager(_db, _db.lyricsTranslations);
}
