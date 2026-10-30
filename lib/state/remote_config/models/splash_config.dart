import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_config.freezed.dart';
part 'splash_config.g.dart';

@freezed
abstract class SplashConfig with _$SplashConfig {
  const factory SplashConfig({
    required String url,
    required String fit,
    required String alignment,
    required int delay,
    String? backgroundColor,
  }) = _SplashConfig;

  factory SplashConfig.fromJson(Map<String, dynamic> json) => _$SplashConfigFromJson(json);
}
