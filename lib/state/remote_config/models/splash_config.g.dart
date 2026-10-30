// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SplashConfig _$SplashConfigFromJson(Map<String, dynamic> json) =>
    _SplashConfig(
      url: json['url'] as String,
      fit: json['fit'] as String,
      alignment: json['alignment'] as String,
      delay: (json['delay'] as num).toInt(),
      backgroundColor: json['background_color'] as String?,
    );

Map<String, dynamic> _$SplashConfigToJson(_SplashConfig instance) =>
    <String, dynamic>{
      'url': instance.url,
      'fit': instance.fit,
      'alignment': instance.alignment,
      'delay': instance.delay,
      'background_color': instance.backgroundColor,
    };
