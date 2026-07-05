// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GithubRelease _$GithubReleaseFromJson(Map<String, dynamic> json) =>
    _GithubRelease(
      tagName: json['tag_name'] as String,
      name: json['name'] as String,
      body: json['body'] as String,
    );

Map<String, dynamic> _$GithubReleaseToJson(_GithubRelease instance) =>
    <String, dynamic>{
      'tag_name': instance.tagName,
      'name': instance.name,
      'body': instance.body,
    };
