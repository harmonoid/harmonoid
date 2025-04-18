// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyric.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Lyric _$LyricFromJson(Map<String, dynamic> json) {
  return _Lyric.fromJson(json);
}

/// @nodoc
mixin _$Lyric {
  int get timestamp => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this Lyric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lyric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LyricCopyWith<Lyric> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LyricCopyWith<$Res> {
  factory $LyricCopyWith(Lyric value, $Res Function(Lyric) then) =
      _$LyricCopyWithImpl<$Res, Lyric>;
  @useResult
  $Res call({int timestamp, String text});
}

/// @nodoc
class _$LyricCopyWithImpl<$Res, $Val extends Lyric>
    implements $LyricCopyWith<$Res> {
  _$LyricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lyric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LyricImplCopyWith<$Res> implements $LyricCopyWith<$Res> {
  factory _$$LyricImplCopyWith(
          _$LyricImpl value, $Res Function(_$LyricImpl) then) =
      __$$LyricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int timestamp, String text});
}

/// @nodoc
class __$$LyricImplCopyWithImpl<$Res>
    extends _$LyricCopyWithImpl<$Res, _$LyricImpl>
    implements _$$LyricImplCopyWith<$Res> {
  __$$LyricImplCopyWithImpl(
      _$LyricImpl _value, $Res Function(_$LyricImpl) _then)
      : super(_value, _then);

  /// Create a copy of Lyric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? text = null,
  }) {
    return _then(_$LyricImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LyricImpl implements _Lyric {
  const _$LyricImpl({required this.timestamp, required this.text});

  factory _$LyricImpl.fromJson(Map<String, dynamic> json) =>
      _$$LyricImplFromJson(json);

  @override
  final int timestamp;
  @override
  final String text;

  @override
  String toString() {
    return 'Lyric(timestamp: $timestamp, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LyricImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, text);

  /// Create a copy of Lyric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LyricImplCopyWith<_$LyricImpl> get copyWith =>
      __$$LyricImplCopyWithImpl<_$LyricImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LyricImplToJson(
      this,
    );
  }
}

abstract class _Lyric implements Lyric {
  const factory _Lyric(
      {required final int timestamp, required final String text}) = _$LyricImpl;

  factory _Lyric.fromJson(Map<String, dynamic> json) = _$LyricImpl.fromJson;

  @override
  int get timestamp;
  @override
  String get text;

  /// Create a copy of Lyric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LyricImplCopyWith<_$LyricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
