import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_release.freezed.dart';
part 'github_release.g.dart';

@freezed
abstract class GithubRelease with _$GithubRelease {
  const factory GithubRelease({
    required String tagName,
    required String name,
    required String body,
  }) = _GithubRelease;

  factory GithubRelease.fromJson(Map<String, dynamic> json) => _$GithubReleaseFromJson(json);
}
