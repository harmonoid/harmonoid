import 'package:freezed_annotation/freezed_annotation.dart';

part 'playable.freezed.dart';
part 'playable.g.dart';

@Deprecated(':/')
@freezed
abstract class Playable with _$Playable {
  const factory Playable({
    required String uri,
    required String title,
    required List<String> subtitle,
    required List<String> description,
  }) = _Playable;

  factory Playable.fromJson(Map<String, dynamic> json) => _$PlayableFromJson(json);
}
