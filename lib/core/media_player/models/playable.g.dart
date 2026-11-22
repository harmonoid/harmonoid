// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Playable _$PlayableFromJson(Map<String, dynamic> json) => _Playable(
  uri: json['uri'] as String,
  title: json['title'] as String,
  subtitle: (json['subtitle'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  description: (json['description'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PlayableToJson(_Playable instance) => <String, dynamic>{
  'uri': instance.uri,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'description': instance.description,
};
