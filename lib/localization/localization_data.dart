import 'package:freezed_annotation/freezed_annotation.dart';

part 'localization_data.freezed.dart';
part 'localization_data.g.dart';

@freezed
class LocalizationData with _$LocalizationData {
  const factory LocalizationData({
    required String code,
    required String name,
    required String country,
  }) = _LocalizationData;

  factory LocalizationData.fromJson(Map<String, dynamic> json) => _$LocalizationDataFromJson(json);
}
