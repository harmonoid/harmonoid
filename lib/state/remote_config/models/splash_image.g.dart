// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SplashImage _$SplashImageFromJson(Map<String, dynamic> json) => _SplashImage(
  url: json['url'] as String,
  fit: json['fit'] as String,
  alignment: json['alignment'] as String,
  backgroundColor: json['background_color'] as String?,
);

Map<String, dynamic> _$SplashImageToJson(_SplashImage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'fit': instance.fit,
      'alignment': instance.alignment,
      'background_color': instance.backgroundColor,
    };
