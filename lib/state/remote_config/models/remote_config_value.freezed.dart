// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_config_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
RemoteConfigValue _$RemoteConfigValueFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'enableInAppReview':
          return EnableInAppReview.fromJson(
            json
          );
                case 'lyricsTranslationLanguages':
          return LyricsTranslationLanguages.fromJson(
            json
          );
                case 'subscriptionPurchaseConfig':
          return SubscriptionPurchaseConfigValue.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'RemoteConfigValue',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$RemoteConfigValue {

 Object get value;

  /// Serializes this RemoteConfigValue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteConfigValue&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'RemoteConfigValue(value: $value)';
}


}

/// @nodoc
class $RemoteConfigValueCopyWith<$Res>  {
$RemoteConfigValueCopyWith(RemoteConfigValue _, $Res Function(RemoteConfigValue) __);
}


/// Adds pattern-matching-related methods to [RemoteConfigValue].
extension RemoteConfigValuePatterns on RemoteConfigValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EnableInAppReview value)?  enableInAppReview,TResult Function( LyricsTranslationLanguages value)?  lyricsTranslationLanguages,TResult Function( SubscriptionPurchaseConfigValue value)?  subscriptionPurchaseConfig,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EnableInAppReview() when enableInAppReview != null:
return enableInAppReview(_that);case LyricsTranslationLanguages() when lyricsTranslationLanguages != null:
return lyricsTranslationLanguages(_that);case SubscriptionPurchaseConfigValue() when subscriptionPurchaseConfig != null:
return subscriptionPurchaseConfig(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EnableInAppReview value)  enableInAppReview,required TResult Function( LyricsTranslationLanguages value)  lyricsTranslationLanguages,required TResult Function( SubscriptionPurchaseConfigValue value)  subscriptionPurchaseConfig,}){
final _that = this;
switch (_that) {
case EnableInAppReview():
return enableInAppReview(_that);case LyricsTranslationLanguages():
return lyricsTranslationLanguages(_that);case SubscriptionPurchaseConfigValue():
return subscriptionPurchaseConfig(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EnableInAppReview value)?  enableInAppReview,TResult? Function( LyricsTranslationLanguages value)?  lyricsTranslationLanguages,TResult? Function( SubscriptionPurchaseConfigValue value)?  subscriptionPurchaseConfig,}){
final _that = this;
switch (_that) {
case EnableInAppReview() when enableInAppReview != null:
return enableInAppReview(_that);case LyricsTranslationLanguages() when lyricsTranslationLanguages != null:
return lyricsTranslationLanguages(_that);case SubscriptionPurchaseConfigValue() when subscriptionPurchaseConfig != null:
return subscriptionPurchaseConfig(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool value)?  enableInAppReview,TResult Function( List<Language> value)?  lyricsTranslationLanguages,TResult Function( SubscriptionPurchaseConfig value)?  subscriptionPurchaseConfig,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EnableInAppReview() when enableInAppReview != null:
return enableInAppReview(_that.value);case LyricsTranslationLanguages() when lyricsTranslationLanguages != null:
return lyricsTranslationLanguages(_that.value);case SubscriptionPurchaseConfigValue() when subscriptionPurchaseConfig != null:
return subscriptionPurchaseConfig(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool value)  enableInAppReview,required TResult Function( List<Language> value)  lyricsTranslationLanguages,required TResult Function( SubscriptionPurchaseConfig value)  subscriptionPurchaseConfig,}) {final _that = this;
switch (_that) {
case EnableInAppReview():
return enableInAppReview(_that.value);case LyricsTranslationLanguages():
return lyricsTranslationLanguages(_that.value);case SubscriptionPurchaseConfigValue():
return subscriptionPurchaseConfig(_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool value)?  enableInAppReview,TResult? Function( List<Language> value)?  lyricsTranslationLanguages,TResult? Function( SubscriptionPurchaseConfig value)?  subscriptionPurchaseConfig,}) {final _that = this;
switch (_that) {
case EnableInAppReview() when enableInAppReview != null:
return enableInAppReview(_that.value);case LyricsTranslationLanguages() when lyricsTranslationLanguages != null:
return lyricsTranslationLanguages(_that.value);case SubscriptionPurchaseConfigValue() when subscriptionPurchaseConfig != null:
return subscriptionPurchaseConfig(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class EnableInAppReview implements RemoteConfigValue {
  const EnableInAppReview(this.value, {final  String? $type}): $type = $type ?? 'enableInAppReview';
  factory EnableInAppReview.fromJson(Map<String, dynamic> json) => _$EnableInAppReviewFromJson(json);

@override final  bool value;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of RemoteConfigValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnableInAppReviewCopyWith<EnableInAppReview> get copyWith => _$EnableInAppReviewCopyWithImpl<EnableInAppReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnableInAppReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnableInAppReview&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'RemoteConfigValue.enableInAppReview(value: $value)';
}


}

/// @nodoc
abstract mixin class $EnableInAppReviewCopyWith<$Res> implements $RemoteConfigValueCopyWith<$Res> {
  factory $EnableInAppReviewCopyWith(EnableInAppReview value, $Res Function(EnableInAppReview) _then) = _$EnableInAppReviewCopyWithImpl;
@useResult
$Res call({
 bool value
});




}
/// @nodoc
class _$EnableInAppReviewCopyWithImpl<$Res>
    implements $EnableInAppReviewCopyWith<$Res> {
  _$EnableInAppReviewCopyWithImpl(this._self, this._then);

  final EnableInAppReview _self;
  final $Res Function(EnableInAppReview) _then;

/// Create a copy of RemoteConfigValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(EnableInAppReview(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class LyricsTranslationLanguages implements RemoteConfigValue {
  const LyricsTranslationLanguages(final  List<Language> value, {final  String? $type}): _value = value,$type = $type ?? 'lyricsTranslationLanguages';
  factory LyricsTranslationLanguages.fromJson(Map<String, dynamic> json) => _$LyricsTranslationLanguagesFromJson(json);

 final  List<Language> _value;
@override List<Language> get value {
  if (_value is EqualUnmodifiableListView) return _value;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_value);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of RemoteConfigValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LyricsTranslationLanguagesCopyWith<LyricsTranslationLanguages> get copyWith => _$LyricsTranslationLanguagesCopyWithImpl<LyricsTranslationLanguages>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LyricsTranslationLanguagesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LyricsTranslationLanguages&&const DeepCollectionEquality().equals(other._value, _value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_value));

@override
String toString() {
  return 'RemoteConfigValue.lyricsTranslationLanguages(value: $value)';
}


}

/// @nodoc
abstract mixin class $LyricsTranslationLanguagesCopyWith<$Res> implements $RemoteConfigValueCopyWith<$Res> {
  factory $LyricsTranslationLanguagesCopyWith(LyricsTranslationLanguages value, $Res Function(LyricsTranslationLanguages) _then) = _$LyricsTranslationLanguagesCopyWithImpl;
@useResult
$Res call({
 List<Language> value
});




}
/// @nodoc
class _$LyricsTranslationLanguagesCopyWithImpl<$Res>
    implements $LyricsTranslationLanguagesCopyWith<$Res> {
  _$LyricsTranslationLanguagesCopyWithImpl(this._self, this._then);

  final LyricsTranslationLanguages _self;
  final $Res Function(LyricsTranslationLanguages) _then;

/// Create a copy of RemoteConfigValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(LyricsTranslationLanguages(
null == value ? _self._value : value // ignore: cast_nullable_to_non_nullable
as List<Language>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SubscriptionPurchaseConfigValue implements RemoteConfigValue {
  const SubscriptionPurchaseConfigValue(this.value, {final  String? $type}): $type = $type ?? 'subscriptionPurchaseConfig';
  factory SubscriptionPurchaseConfigValue.fromJson(Map<String, dynamic> json) => _$SubscriptionPurchaseConfigValueFromJson(json);

@override final  SubscriptionPurchaseConfig value;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of RemoteConfigValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionPurchaseConfigValueCopyWith<SubscriptionPurchaseConfigValue> get copyWith => _$SubscriptionPurchaseConfigValueCopyWithImpl<SubscriptionPurchaseConfigValue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionPurchaseConfigValueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionPurchaseConfigValue&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'RemoteConfigValue.subscriptionPurchaseConfig(value: $value)';
}


}

/// @nodoc
abstract mixin class $SubscriptionPurchaseConfigValueCopyWith<$Res> implements $RemoteConfigValueCopyWith<$Res> {
  factory $SubscriptionPurchaseConfigValueCopyWith(SubscriptionPurchaseConfigValue value, $Res Function(SubscriptionPurchaseConfigValue) _then) = _$SubscriptionPurchaseConfigValueCopyWithImpl;
@useResult
$Res call({
 SubscriptionPurchaseConfig value
});


$SubscriptionPurchaseConfigCopyWith<$Res> get value;

}
/// @nodoc
class _$SubscriptionPurchaseConfigValueCopyWithImpl<$Res>
    implements $SubscriptionPurchaseConfigValueCopyWith<$Res> {
  _$SubscriptionPurchaseConfigValueCopyWithImpl(this._self, this._then);

  final SubscriptionPurchaseConfigValue _self;
  final $Res Function(SubscriptionPurchaseConfigValue) _then;

/// Create a copy of RemoteConfigValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(SubscriptionPurchaseConfigValue(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as SubscriptionPurchaseConfig,
  ));
}

/// Create a copy of RemoteConfigValue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionPurchaseConfigCopyWith<$Res> get value {
  
  return $SubscriptionPurchaseConfigCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}


/// @nodoc
mixin _$SubscriptionPurchaseConfig {

@JsonKey(name: 'max_version') String get maxVersion;@JsonKey(name: 'min_version') String get minVersion;@JsonKey(name: 'blacklisted_versions') List<String> get blacklistedVersions;
/// Create a copy of SubscriptionPurchaseConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionPurchaseConfigCopyWith<SubscriptionPurchaseConfig> get copyWith => _$SubscriptionPurchaseConfigCopyWithImpl<SubscriptionPurchaseConfig>(this as SubscriptionPurchaseConfig, _$identity);

  /// Serializes this SubscriptionPurchaseConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionPurchaseConfig&&(identical(other.maxVersion, maxVersion) || other.maxVersion == maxVersion)&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&const DeepCollectionEquality().equals(other.blacklistedVersions, blacklistedVersions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxVersion,minVersion,const DeepCollectionEquality().hash(blacklistedVersions));

@override
String toString() {
  return 'SubscriptionPurchaseConfig(maxVersion: $maxVersion, minVersion: $minVersion, blacklistedVersions: $blacklistedVersions)';
}


}

/// @nodoc
abstract mixin class $SubscriptionPurchaseConfigCopyWith<$Res>  {
  factory $SubscriptionPurchaseConfigCopyWith(SubscriptionPurchaseConfig value, $Res Function(SubscriptionPurchaseConfig) _then) = _$SubscriptionPurchaseConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'max_version') String maxVersion,@JsonKey(name: 'min_version') String minVersion,@JsonKey(name: 'blacklisted_versions') List<String> blacklistedVersions
});




}
/// @nodoc
class _$SubscriptionPurchaseConfigCopyWithImpl<$Res>
    implements $SubscriptionPurchaseConfigCopyWith<$Res> {
  _$SubscriptionPurchaseConfigCopyWithImpl(this._self, this._then);

  final SubscriptionPurchaseConfig _self;
  final $Res Function(SubscriptionPurchaseConfig) _then;

/// Create a copy of SubscriptionPurchaseConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxVersion = null,Object? minVersion = null,Object? blacklistedVersions = null,}) {
  return _then(_self.copyWith(
maxVersion: null == maxVersion ? _self.maxVersion : maxVersion // ignore: cast_nullable_to_non_nullable
as String,minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,blacklistedVersions: null == blacklistedVersions ? _self.blacklistedVersions : blacklistedVersions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionPurchaseConfig].
extension SubscriptionPurchaseConfigPatterns on SubscriptionPurchaseConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionPurchaseConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionPurchaseConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionPurchaseConfig value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPurchaseConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionPurchaseConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPurchaseConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'max_version')  String maxVersion, @JsonKey(name: 'min_version')  String minVersion, @JsonKey(name: 'blacklisted_versions')  List<String> blacklistedVersions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionPurchaseConfig() when $default != null:
return $default(_that.maxVersion,_that.minVersion,_that.blacklistedVersions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'max_version')  String maxVersion, @JsonKey(name: 'min_version')  String minVersion, @JsonKey(name: 'blacklisted_versions')  List<String> blacklistedVersions)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPurchaseConfig():
return $default(_that.maxVersion,_that.minVersion,_that.blacklistedVersions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'max_version')  String maxVersion, @JsonKey(name: 'min_version')  String minVersion, @JsonKey(name: 'blacklisted_versions')  List<String> blacklistedVersions)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPurchaseConfig() when $default != null:
return $default(_that.maxVersion,_that.minVersion,_that.blacklistedVersions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionPurchaseConfig implements SubscriptionPurchaseConfig {
  const _SubscriptionPurchaseConfig({@JsonKey(name: 'max_version') required this.maxVersion, @JsonKey(name: 'min_version') required this.minVersion, @JsonKey(name: 'blacklisted_versions') required final  List<String> blacklistedVersions}): _blacklistedVersions = blacklistedVersions;
  factory _SubscriptionPurchaseConfig.fromJson(Map<String, dynamic> json) => _$SubscriptionPurchaseConfigFromJson(json);

@override@JsonKey(name: 'max_version') final  String maxVersion;
@override@JsonKey(name: 'min_version') final  String minVersion;
 final  List<String> _blacklistedVersions;
@override@JsonKey(name: 'blacklisted_versions') List<String> get blacklistedVersions {
  if (_blacklistedVersions is EqualUnmodifiableListView) return _blacklistedVersions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blacklistedVersions);
}


/// Create a copy of SubscriptionPurchaseConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionPurchaseConfigCopyWith<_SubscriptionPurchaseConfig> get copyWith => __$SubscriptionPurchaseConfigCopyWithImpl<_SubscriptionPurchaseConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionPurchaseConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionPurchaseConfig&&(identical(other.maxVersion, maxVersion) || other.maxVersion == maxVersion)&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&const DeepCollectionEquality().equals(other._blacklistedVersions, _blacklistedVersions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxVersion,minVersion,const DeepCollectionEquality().hash(_blacklistedVersions));

@override
String toString() {
  return 'SubscriptionPurchaseConfig(maxVersion: $maxVersion, minVersion: $minVersion, blacklistedVersions: $blacklistedVersions)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionPurchaseConfigCopyWith<$Res> implements $SubscriptionPurchaseConfigCopyWith<$Res> {
  factory _$SubscriptionPurchaseConfigCopyWith(_SubscriptionPurchaseConfig value, $Res Function(_SubscriptionPurchaseConfig) _then) = __$SubscriptionPurchaseConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'max_version') String maxVersion,@JsonKey(name: 'min_version') String minVersion,@JsonKey(name: 'blacklisted_versions') List<String> blacklistedVersions
});




}
/// @nodoc
class __$SubscriptionPurchaseConfigCopyWithImpl<$Res>
    implements _$SubscriptionPurchaseConfigCopyWith<$Res> {
  __$SubscriptionPurchaseConfigCopyWithImpl(this._self, this._then);

  final _SubscriptionPurchaseConfig _self;
  final $Res Function(_SubscriptionPurchaseConfig) _then;

/// Create a copy of SubscriptionPurchaseConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxVersion = null,Object? minVersion = null,Object? blacklistedVersions = null,}) {
  return _then(_SubscriptionPurchaseConfig(
maxVersion: null == maxVersion ? _self.maxVersion : maxVersion // ignore: cast_nullable_to_non_nullable
as String,minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,blacklistedVersions: null == blacklistedVersions ? _self._blacklistedVersions : blacklistedVersions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
