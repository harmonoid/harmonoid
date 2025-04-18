// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'localization_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocalizationData _$LocalizationDataFromJson(Map<String, dynamic> json) {
  return _LocalizationData.fromJson(json);
}

/// @nodoc
mixin _$LocalizationData {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;

  /// Serializes this LocalizationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalizationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalizationDataCopyWith<LocalizationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalizationDataCopyWith<$Res> {
  factory $LocalizationDataCopyWith(
          LocalizationData value, $Res Function(LocalizationData) then) =
      _$LocalizationDataCopyWithImpl<$Res, LocalizationData>;
  @useResult
  $Res call({String code, String name, String country});
}

/// @nodoc
class _$LocalizationDataCopyWithImpl<$Res, $Val extends LocalizationData>
    implements $LocalizationDataCopyWith<$Res> {
  _$LocalizationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalizationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? country = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalizationDataImplCopyWith<$Res>
    implements $LocalizationDataCopyWith<$Res> {
  factory _$$LocalizationDataImplCopyWith(_$LocalizationDataImpl value,
          $Res Function(_$LocalizationDataImpl) then) =
      __$$LocalizationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, String country});
}

/// @nodoc
class __$$LocalizationDataImplCopyWithImpl<$Res>
    extends _$LocalizationDataCopyWithImpl<$Res, _$LocalizationDataImpl>
    implements _$$LocalizationDataImplCopyWith<$Res> {
  __$$LocalizationDataImplCopyWithImpl(_$LocalizationDataImpl _value,
      $Res Function(_$LocalizationDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocalizationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? country = null,
  }) {
    return _then(_$LocalizationDataImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalizationDataImpl implements _LocalizationData {
  const _$LocalizationDataImpl(
      {required this.code, required this.name, required this.country});

  factory _$LocalizationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalizationDataImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final String country;

  @override
  String toString() {
    return 'LocalizationData(code: $code, name: $name, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalizationDataImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.country, country) || other.country == country));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, country);

  /// Create a copy of LocalizationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalizationDataImplCopyWith<_$LocalizationDataImpl> get copyWith =>
      __$$LocalizationDataImplCopyWithImpl<_$LocalizationDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalizationDataImplToJson(
      this,
    );
  }
}

abstract class _LocalizationData implements LocalizationData {
  const factory _LocalizationData(
      {required final String code,
      required final String name,
      required final String country}) = _$LocalizationDataImpl;

  factory _LocalizationData.fromJson(Map<String, dynamic> json) =
      _$LocalizationDataImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  String get country;

  /// Create a copy of LocalizationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalizationDataImplCopyWith<_$LocalizationDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
