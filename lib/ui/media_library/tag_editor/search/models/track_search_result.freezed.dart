// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackSearchResult {

@JsonKey(name: 'TITLE') String get title;@JsonKey(name: 'ARTIST') String get artist;@JsonKey(name: 'ALBUM') String get album;@JsonKey(name: 'ALBUMARTIST') String get albumArtist;@JsonKey(name: 'DATE') String get date;@JsonKey(name: 'GENRE') String get genre;@JsonKey(name: 'TRACKNUMBER') String get trackNumber;@JsonKey(name: 'DISCNUMBER') String get discNumber;@JsonKey(name: 'COMMENT') String get comment;@JsonKey(name: 'LYRICS') String get lyrics;@JsonKey(name: 'COVER') String get cover;
/// Create a copy of TrackSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackSearchResultCopyWith<TrackSearchResult> get copyWith => _$TrackSearchResultCopyWithImpl<TrackSearchResult>(this as TrackSearchResult, _$identity);

  /// Serializes this TrackSearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackSearchResult&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album)&&(identical(other.albumArtist, albumArtist) || other.albumArtist == albumArtist)&&(identical(other.date, date) || other.date == date)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.trackNumber, trackNumber) || other.trackNumber == trackNumber)&&(identical(other.discNumber, discNumber) || other.discNumber == discNumber)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.lyrics, lyrics) || other.lyrics == lyrics)&&(identical(other.cover, cover) || other.cover == cover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,artist,album,albumArtist,date,genre,trackNumber,discNumber,comment,lyrics,cover);

@override
String toString() {
  return 'TrackSearchResult(title: $title, artist: $artist, album: $album, albumArtist: $albumArtist, date: $date, genre: $genre, trackNumber: $trackNumber, discNumber: $discNumber, comment: $comment, lyrics: $lyrics, cover: $cover)';
}


}

/// @nodoc
abstract mixin class $TrackSearchResultCopyWith<$Res>  {
  factory $TrackSearchResultCopyWith(TrackSearchResult value, $Res Function(TrackSearchResult) _then) = _$TrackSearchResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'TITLE') String title,@JsonKey(name: 'ARTIST') String artist,@JsonKey(name: 'ALBUM') String album,@JsonKey(name: 'ALBUMARTIST') String albumArtist,@JsonKey(name: 'DATE') String date,@JsonKey(name: 'GENRE') String genre,@JsonKey(name: 'TRACKNUMBER') String trackNumber,@JsonKey(name: 'DISCNUMBER') String discNumber,@JsonKey(name: 'COMMENT') String comment,@JsonKey(name: 'LYRICS') String lyrics,@JsonKey(name: 'COVER') String cover
});




}
/// @nodoc
class _$TrackSearchResultCopyWithImpl<$Res>
    implements $TrackSearchResultCopyWith<$Res> {
  _$TrackSearchResultCopyWithImpl(this._self, this._then);

  final TrackSearchResult _self;
  final $Res Function(TrackSearchResult) _then;

/// Create a copy of TrackSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? artist = null,Object? album = null,Object? albumArtist = null,Object? date = null,Object? genre = null,Object? trackNumber = null,Object? discNumber = null,Object? comment = null,Object? lyrics = null,Object? cover = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String,albumArtist: null == albumArtist ? _self.albumArtist : albumArtist // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,genre: null == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String,trackNumber: null == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as String,discNumber: null == discNumber ? _self.discNumber : discNumber // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,lyrics: null == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackSearchResult].
extension TrackSearchResultPatterns on TrackSearchResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackSearchResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _TrackSearchResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _TrackSearchResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'TITLE')  String title, @JsonKey(name: 'ARTIST')  String artist, @JsonKey(name: 'ALBUM')  String album, @JsonKey(name: 'ALBUMARTIST')  String albumArtist, @JsonKey(name: 'DATE')  String date, @JsonKey(name: 'GENRE')  String genre, @JsonKey(name: 'TRACKNUMBER')  String trackNumber, @JsonKey(name: 'DISCNUMBER')  String discNumber, @JsonKey(name: 'COMMENT')  String comment, @JsonKey(name: 'LYRICS')  String lyrics, @JsonKey(name: 'COVER')  String cover)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackSearchResult() when $default != null:
return $default(_that.title,_that.artist,_that.album,_that.albumArtist,_that.date,_that.genre,_that.trackNumber,_that.discNumber,_that.comment,_that.lyrics,_that.cover);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'TITLE')  String title, @JsonKey(name: 'ARTIST')  String artist, @JsonKey(name: 'ALBUM')  String album, @JsonKey(name: 'ALBUMARTIST')  String albumArtist, @JsonKey(name: 'DATE')  String date, @JsonKey(name: 'GENRE')  String genre, @JsonKey(name: 'TRACKNUMBER')  String trackNumber, @JsonKey(name: 'DISCNUMBER')  String discNumber, @JsonKey(name: 'COMMENT')  String comment, @JsonKey(name: 'LYRICS')  String lyrics, @JsonKey(name: 'COVER')  String cover)  $default,) {final _that = this;
switch (_that) {
case _TrackSearchResult():
return $default(_that.title,_that.artist,_that.album,_that.albumArtist,_that.date,_that.genre,_that.trackNumber,_that.discNumber,_that.comment,_that.lyrics,_that.cover);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'TITLE')  String title, @JsonKey(name: 'ARTIST')  String artist, @JsonKey(name: 'ALBUM')  String album, @JsonKey(name: 'ALBUMARTIST')  String albumArtist, @JsonKey(name: 'DATE')  String date, @JsonKey(name: 'GENRE')  String genre, @JsonKey(name: 'TRACKNUMBER')  String trackNumber, @JsonKey(name: 'DISCNUMBER')  String discNumber, @JsonKey(name: 'COMMENT')  String comment, @JsonKey(name: 'LYRICS')  String lyrics, @JsonKey(name: 'COVER')  String cover)?  $default,) {final _that = this;
switch (_that) {
case _TrackSearchResult() when $default != null:
return $default(_that.title,_that.artist,_that.album,_that.albumArtist,_that.date,_that.genre,_that.trackNumber,_that.discNumber,_that.comment,_that.lyrics,_that.cover);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackSearchResult implements TrackSearchResult {
  const _TrackSearchResult({@JsonKey(name: 'TITLE') required this.title, @JsonKey(name: 'ARTIST') required this.artist, @JsonKey(name: 'ALBUM') required this.album, @JsonKey(name: 'ALBUMARTIST') required this.albumArtist, @JsonKey(name: 'DATE') required this.date, @JsonKey(name: 'GENRE') required this.genre, @JsonKey(name: 'TRACKNUMBER') required this.trackNumber, @JsonKey(name: 'DISCNUMBER') required this.discNumber, @JsonKey(name: 'COMMENT') required this.comment, @JsonKey(name: 'LYRICS') required this.lyrics, @JsonKey(name: 'COVER') required this.cover});
  factory _TrackSearchResult.fromJson(Map<String, dynamic> json) => _$TrackSearchResultFromJson(json);

@override@JsonKey(name: 'TITLE') final  String title;
@override@JsonKey(name: 'ARTIST') final  String artist;
@override@JsonKey(name: 'ALBUM') final  String album;
@override@JsonKey(name: 'ALBUMARTIST') final  String albumArtist;
@override@JsonKey(name: 'DATE') final  String date;
@override@JsonKey(name: 'GENRE') final  String genre;
@override@JsonKey(name: 'TRACKNUMBER') final  String trackNumber;
@override@JsonKey(name: 'DISCNUMBER') final  String discNumber;
@override@JsonKey(name: 'COMMENT') final  String comment;
@override@JsonKey(name: 'LYRICS') final  String lyrics;
@override@JsonKey(name: 'COVER') final  String cover;

/// Create a copy of TrackSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackSearchResultCopyWith<_TrackSearchResult> get copyWith => __$TrackSearchResultCopyWithImpl<_TrackSearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackSearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackSearchResult&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album)&&(identical(other.albumArtist, albumArtist) || other.albumArtist == albumArtist)&&(identical(other.date, date) || other.date == date)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.trackNumber, trackNumber) || other.trackNumber == trackNumber)&&(identical(other.discNumber, discNumber) || other.discNumber == discNumber)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.lyrics, lyrics) || other.lyrics == lyrics)&&(identical(other.cover, cover) || other.cover == cover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,artist,album,albumArtist,date,genre,trackNumber,discNumber,comment,lyrics,cover);

@override
String toString() {
  return 'TrackSearchResult(title: $title, artist: $artist, album: $album, albumArtist: $albumArtist, date: $date, genre: $genre, trackNumber: $trackNumber, discNumber: $discNumber, comment: $comment, lyrics: $lyrics, cover: $cover)';
}


}

/// @nodoc
abstract mixin class _$TrackSearchResultCopyWith<$Res> implements $TrackSearchResultCopyWith<$Res> {
  factory _$TrackSearchResultCopyWith(_TrackSearchResult value, $Res Function(_TrackSearchResult) _then) = __$TrackSearchResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'TITLE') String title,@JsonKey(name: 'ARTIST') String artist,@JsonKey(name: 'ALBUM') String album,@JsonKey(name: 'ALBUMARTIST') String albumArtist,@JsonKey(name: 'DATE') String date,@JsonKey(name: 'GENRE') String genre,@JsonKey(name: 'TRACKNUMBER') String trackNumber,@JsonKey(name: 'DISCNUMBER') String discNumber,@JsonKey(name: 'COMMENT') String comment,@JsonKey(name: 'LYRICS') String lyrics,@JsonKey(name: 'COVER') String cover
});




}
/// @nodoc
class __$TrackSearchResultCopyWithImpl<$Res>
    implements _$TrackSearchResultCopyWith<$Res> {
  __$TrackSearchResultCopyWithImpl(this._self, this._then);

  final _TrackSearchResult _self;
  final $Res Function(_TrackSearchResult) _then;

/// Create a copy of TrackSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? artist = null,Object? album = null,Object? albumArtist = null,Object? date = null,Object? genre = null,Object? trackNumber = null,Object? discNumber = null,Object? comment = null,Object? lyrics = null,Object? cover = null,}) {
  return _then(_TrackSearchResult(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String,albumArtist: null == albumArtist ? _self.albumArtist : albumArtist // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,genre: null == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String,trackNumber: null == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as String,discNumber: null == discNumber ? _self.discNumber : discNumber // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,lyrics: null == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
